package utils

import (
	"context"
	"database/sql"
	"fmt"
	"log"
	"reflect"
	"time"

	_ "github.com/microsoft/go-mssqldb"
)

// HealthCheckSQLServer checks connectivity to SQL Server
func HealthCheckSQLServer(connStr string) error {
	db, err := sql.Open("sqlserver", connStr)
	if err != nil {
		return fmt.Errorf("unable to open connection: %w", err)
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	return db.PingContext(ctx)

}

// ExecuteSP executes the given SP name and returns the result map
func ExecuteSP(sp string, connStr string, hasWrite bool, result any) error {
	db, err := sql.Open("sqlserver", connStr)
	if err != nil {
		log.Printf("Unable to open connection: `%v`", err)
		return err
	}
	defer db.Close()

	tx, err := db.Begin()
	if err != nil {
		log.Printf("Error starting transaction: `%v`", err)
	}

	defer func() {
		if err != nil {
			log.Printf("Transaction failed for %s: `%v`", sp, err)
			tx.Rollback()
		} else {
			err = tx.Commit()
		}
	}()

	rows, err := tx.Query(fmt.Sprintf("EXEC %s", sp))
	if err != nil {
		log.Printf("Failed to exec %s: `%v`", sp, err)
		return err
	}
	defer rows.Close()

	if result == nil {
		return nil
	}

	err = parseRows(rows, result)
	if err != nil {
		log.Printf("Failed to parse result set for %s: `%v`", sp, err)
		return err
	}

	return nil
}

func parseRowsV2(rows *sql.Rows, result *[]map[string]any) error {
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
}

func parseRows(rows *sql.Rows, result any) error {
	cols, err := rows.Columns()
	if err != nil {
		return err
	}

	schema := reflect.New(reflect.TypeOf(result).Elem().Elem())
	res := reflect.ValueOf(result).Elem()

	for rows.Next() {
		row := make([]any, len(cols))
		rowPointers := make([]any, len(cols))
		for i := range row {
			rowPointers[i] = &row[i]
		}

		if err := rows.Scan(rowPointers...); err != nil {
			return err
		}

		for i, col := range cols {
			schema.Elem().FieldByName(col).Set(
				reflect.ValueOf(row[i]).Convert(
					schema.Elem().FieldByName(col).Type()))
		}

		res.Set(reflect.Append(res, reflect.Value(schema).Elem()))
	}

	if err := rows.Err(); err != nil {
		return err
	}

	return nil
}
