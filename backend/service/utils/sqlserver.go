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

var db *sql.DB
var Err_Business = errors.New("business error")

type status struct {
	Status     int
	Message    string
	LogMessage string
	Result     any
}

// DBInit checks connectivity to SQL Server also acts as initalizer
func DBInit(connStr string) error {
	var err error
	db, err = sql.Open("sqlserver", connStr)
	if err != nil {
		return fmt.Errorf("unable to open connection: %w", err)
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	return db.PingContext(ctx)
}

func DBClose() {
	if db == nil {
		return
	}
	db.Close()
}

// ExecuteSP executes the given SP name and returns the result map
// TODO Unit test
// 1. transaction commit / rollback
// 2.
func ExecuteSP(sp string, result any, params any, fieldsOmit string) (error, bool) {
	if db == nil {
		err := errors.New("connection not established to DB(check if DBInit is called at startup)")
		Logger("%v", err)
		return err, false
	}

	tx, err := db.Begin()
	if err != nil {
		Logger("Error starting transaction: `%v`", err)
	}

	defer func() {
		if err != nil {
			Logger("Rolling back %s.", sp)
			err := tx.Rollback()
			if err != nil {
				Logger("Rollback failed")
			}
		} else {
			err = tx.Commit()
			if err != nil {
				Logger("Commit failed")
			}
		}
	}()

	var args []any
	if params != nil {
		prepareArgs(params, &args, fieldsOmit)
	}

	rows, err := tx.Query(sp, args...)
	if err != nil {
		Logger("Failed to exec %s: `%v`", sp, err)
		return err, false
	}

	defer rows.Close()

	err, isBusinessErr := parseRows(rows, result)
	if err != nil {
		if isBusinessErr {
			return err, true
		}
		Logger("Failed to parse result set for %s: `%v`", sp, err)
		return err, false
	}

	return nil, false
}

// converts input struct to array of sql.NamedArg.
//
// Limitation: Can only traverse structs 2 levels down.
// Unit test
// non struct fail
// omit fields are removed
//
//	check returns tvp vs normal
func prepareArgs(params any, args *[]any, omitFields string) {
	for i := range reflect.TypeOf(params).NumField() {
		paramType := reflect.TypeOf(params).Field(i)
		if strings.Contains(omitFields, paramType.Name) {
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

// Currently supports 1 result set
// or 1 status result set + 1 output result set
//
// TODO : Look for atl method since all SPs have fixed schema
// and using refl is overhead.
// Unit test
// no result case
// status case 1- busns err, internal, success
// result is array of struct
func parseRows(rows *sql.Rows, result any) (error, bool) {
	var schema reflect.Value
	var res reflect.Value
	if result != nil {
		schema = reflect.New(reflect.TypeOf(result).Elem().Elem())
		res = reflect.ValueOf(result).Elem()
	}

	for cont := true; cont; cont = rows.NextResultSet() {
		for rows.Next() {
			cols, err := rows.Columns()
			if err != nil {
				return err, false
			}
			if strings.Join(cols, ",") == ColumnSet_Status {
				var status status
				if err := rows.Scan(&status.Status, &status.Message, &status.LogMessage, &status.Result); err != nil {
					return err, false
				}

				if status.Status == DBStatus_Success {
					if result != nil {
						continue
					}
					return nil, false
				}

				if status.Status == DBStatus_BusinessError {
					return fmt.Errorf("%w : %v", Err_Business, status.Message), true
				}

				if status.Status == DBStatus_InternalError {
					Logger("DB Error %s %s", status.Message, status.LogMessage)
					return fmt.Errorf("db error"), false
				}
			}

			row := make([]any, len(cols))
			rowPointers := make([]any, len(cols))
			for i := range row {
				rowPointers[i] = &row[i]
			}

			if err := rows.Scan(rowPointers...); err != nil {
				return err, false
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
	}

	if err := rows.Err(); err != nil {
		return err, false
	}

	return nil, false
}

/*
 a bit faster 🍑 not type safe

func parseRows(rows *sql.Rows, result *[]map[string]any) error {
	cols, err := rows.Columns()
	if err != nil {
		return err
	}

	for rows.Next() {
		row := make([]any, len(cols))
		rowPointers := make([]any, len(cols))
		for i := range row {
			rowPointers[i] = &row[i]
		}

		if err := rows.Scan(rowPointers...); err != nil {
			return err
		}

		res := make(map[string]any, 0)
		for i, col := range cols {
			res[col] = *(rowPointers[i].(*any))
		}
		*result = append(*result, res)
	}

	if err := rows.Err(); err != nil {
		return err
	}

	return nil
}*/
