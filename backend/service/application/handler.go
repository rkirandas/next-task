package application

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"reflect"

	_ "github.com/microsoft/go-mssqldb"
)

type Lookup struct {
	Lookup string `json:"lookup"`
	Key    string `json:"key"`
	Value  uint   `json:"value"`
}

const (
	Sp_GetLookup = "GetLookups_SP"
)

// GetLookups returns all lookup kv pairs for apps
func (app *App) GetLookups(w http.ResponseWriter, r *http.Request) {
	db, err := sql.Open("sqlserver", app.config.SqlServerCs)
	if err != nil {
		log.Printf("unable to open connection to SQL Server: `%v`", err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	defer db.Close()

	tx, err := db.Begin()
	if err != nil {
		log.Printf("error starting transaction: `%v`", err)
	}

	defer func() {
		if err != nil {
			log.Printf("transaction failed for %s: `%v`", Sp_GetLookup, err)
			tx.Rollback()
		} else {
			err = tx.Commit()
		}
	}()

	rows, err := tx.Query(fmt.Sprintf("EXEC %s", Sp_GetLookup))
	if err != nil {
		log.Printf("failed to exec %s: `%v`", Sp_GetLookup, err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	defer rows.Close()

	var res []Lookup

	cols, err := rows.ColumnTypes()
	if err != nil {
		log.Printf("error fetching columns for %s: `%v`", Sp_GetLookup, err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	var dbRow = make([]any, len(cols))

	for i, col := range cols {
		dbRow[i] = reflect.New(reflect.PointerTo(col.ScanType())).Interface()
	}

	var result map[string]any
	for rows.Next() {
		scanErr := rows.Scan(dbRow...)
		if scanErr != nil {
			log.Printf("parsing output of %s failed: `%v`", Sp_GetLookup, scanErr)
			w.WriteHeader(http.StatusInternalServerError)
			return
		}

		for i, dbCol := range dbRow {
			if reflectValue := reflect.Indirect(reflect.Indirect(reflect.ValueOf(dbCol))); reflectValue.IsValid() {
				result[cols[i].Name()] = reflectValue.Interface()
			} else {
				result[cols[i].Name()] = nil
			}
		}
	}

	for _, val := range result {
		fmt.Printf("Value is %v\n", val)
	}
	if err := rows.Err(); err != nil {
		log.Printf("rows iteration error on the output of %s: `%v`", Sp_GetLookup, err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")

	jsonData, err := json.Marshal(res)
	if err != nil {
		log.Printf("encoding error on %s: `%v`", Sp_GetLookup, err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	w.Write(jsonData)
}
