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
func ExecuteSP(sp string, connStr string, hasWrite bool) ([]map[string]any, error) {
	db, err := sql.Open("sqlserver", connStr)
	if err != nil {
		log.Printf("Unable to open connection: `%v`", err)
		return nil, err
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
		return nil, err
	}
	defer rows.Close()

	results := make([]map[string]any, 0)

	err = parseResultSet(rows, &results)
	if err != nil {
		log.Printf("Failed to parse result set for %s: `%v`", sp, err)
		return nil, err
	}

	return results, nil
}

func parseResultSet(rows *sql.Rows, results *[]map[string]any) error {
	cols, err := rows.ColumnTypes()
	if err != nil {
		log.Printf("Error on getting column types")
		return err
	}

	var dbRow = make([]any, len(cols))
	for i, col := range cols {
		dbRow[i] = reflect.New(reflect.PointerTo(col.ScanType())).Interface()
	}

	for rows.Next() {
		result := make(map[string]any)
		scanErr := rows.Scan(dbRow...)
		if scanErr != nil {
			log.Printf("Error on scanning row")
			return err
		}

		for i, dbCol := range dbRow {
			result[cols[i].Name()] = nil
			if reflectValue := reflect.Indirect(reflect.Indirect(reflect.ValueOf(dbCol))); reflectValue.IsValid() {
				result[cols[i].Name()] = reflectValue.Interface()
			}
		}

		*results = append(*results, result)
	}

	if err := rows.Err(); err != nil {
		log.Printf("Error on getting rows")
		return err
	}

	return nil
}
