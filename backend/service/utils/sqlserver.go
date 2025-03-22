package utils

import (
	"context"
	"database/sql"
	"errors"
	"fmt"
	"reflect"
	"strings"
	"time"

	mssql "github.com/microsoft/go-mssqldb"
)

var Err_Business = errors.New("business error")

type Status struct {
	Status     int
	Message    string
	LogMessage string
	Result     any
}

type SPResult struct {
	Status          Status
	IsBusinessError bool
}

type txClient interface {
	Rollback() error
	Commit() error
	Query(query string, args ...any) (*sql.Rows, error)
}

type Tran struct {
	Tx txClient
}

var conn *sql.DB

// DBInit checks connectivity to SQL Server also acts as initalizer (should be called once)
func DBInit(connStr string) error {
	var err error
	conn, err = sql.Open("sqlserver", connStr)
	if err != nil {
		return fmt.Errorf("unable to open connection: %w", err)
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	err = conn.PingContext(ctx)
	if err != nil {
		return fmt.Errorf("connection closed while pinging: %w", err)
	}

	return nil
}

func CreateTran() (*Tran, error) {
	if conn == nil {
		err := errors.New("DB connection not initialized. Call InitDB first")
		Logger("%v", err)
		return nil, err
	}

	tx, err := conn.Begin()
	if err != nil {
		Logger("Error starting transaction: `%v`", err)
		return nil, err
	}

	return &Tran{
		Tx: tx,
	}, nil
}

func DBClose() {
	if conn == nil {
		return
	}
	conn.Close()
}

// ExecuteSP executes the given SP name and returns the result map
func (tx *Tran) ExecuteSP(sp string, result any, params any, fieldsOmit *[]string) (SPResult, error) {
	var args []any
	var err error

	if params != nil {
		prepareArgs(params, &args, fieldsOmit)
	}

	defer func() {
		if err != nil {
			err := tx.Tx.Rollback()
			if err != nil {
				Logger("Rollback failed for %s. %v", sp, err)
			}
		} else {
			err = tx.Tx.Commit()
			if err != nil {
				Logger("Commit failed for %s. %v", sp, err)
			}
		}
	}()

	rows, err := tx.Tx.Query(sp, args...)
	if err != nil {
		Logger("Failed to exec %s: `%v`", sp, err)
		return SPResult{}, err
	}
	if rows == nil {
		return SPResult{}, err
	}

	defer rows.Close()

	res, parseErr := parseRows(rows, result)
	if parseErr != nil {
		if !res.IsBusinessError {
			err = parseErr
			Logger("Failed to parse result set for %s: `%v`", sp, parseErr)
		}
		return res, parseErr
	}

	return res, nil
}

func prepareArgs(params any, args *[]any, omitFields *[]string) {
	var skipParam bool
	for i := range reflect.TypeOf(params).NumField() {
		skipParam = false
		paramType := reflect.TypeOf(params).Field(i)
		if omitFields != nil {
			for j := 0; j < len(*omitFields); j++ {
				if (*omitFields)[j] == paramType.Name {
					skipParam = true
					continue
				}
			}
		}

		if skipParam {
			continue
		}
		paramVal := reflect.ValueOf(params).Field(i).Interface()
		if paramType.Type.Kind() == reflect.Array|reflect.Slice {
			tvp_type := strings.Split(paramType.Type.Elem().String(), ".")
			*args = append(*args, sql.Named(paramType.Name, mssql.TVP{
				TypeName: tvp_type[len(tvp_type)-1],
				Value:    paramVal,
			}))
		} else {
			*args = append(*args, sql.Named(paramType.Name,
				paramVal,
			))
		}
	}
}

func parseRows(rows *sql.Rows, result any) (SPResult, error) {
	var spResult SPResult
	var schema reflect.Value
	var res reflect.Value
	if result != nil {
		schema = reflect.New(reflect.TypeOf(result).Elem().Elem())
		res = reflect.ValueOf(result).Elem()
	}

	for {
		for rows.Next() {
			cols, err := rows.Columns()
			if err != nil {
				return spResult, err
			}
			if strings.Join(cols, ",") == ColumnSet_Status {
				var status Status
				if err := rows.Scan(&status.Status, &status.Message, &status.LogMessage, &status.Result); err != nil {
					return spResult, err
				}

				if status.Status == DBStatus_Success {
					if result != nil {
						spResult.Status = status
						continue
					}
					return SPResult{Status: status}, nil
				}

				if status.Status == DBStatus_BusinessError {
					return SPResult{IsBusinessError: true}, fmt.Errorf("%w : %v", Err_Business, status.Message)
				}

				if status.Status == DBStatus_InternalError {
					Logger("DB Error %s %s", status.Message, status.LogMessage)
					return spResult, fmt.Errorf("db error")
				}
			}

			row := make([]any, len(cols))
			rowPointers := make([]any, len(cols))
			for i := range row {
				rowPointers[i] = &row[i]
			}

			if err := rows.Scan(rowPointers...); err != nil {
				return spResult, err
			}

			for i, col := range cols {
				field := schema.Elem().FieldByName(col)
				if row[i] == nil || !field.IsValid() {
					continue
				}
				rowVal := reflect.ValueOf(row[i])
				if rowVal.IsValid() && rowVal.CanConvert(field.Type()) {
					field.Set(rowVal.Convert(field.Type()))
				}
			}
			res.Set(reflect.Append(res, reflect.Value(schema).Elem()))
		}
		if !rows.NextResultSet() {
			break
		}
	}

	if err := rows.Err(); err != nil {
		return spResult, err
	}

	return spResult, nil
}
