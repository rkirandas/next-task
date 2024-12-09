package application

import (
	"encoding/json"
	"log"
	"net/http"
	"next-task-svc/utils"

	_ "github.com/microsoft/go-mssqldb"
)

const (
	Sp_GetLookup = "GetLookups_SP"
)

// GetLookups returns all lookup kv pairs for apps
func (app *App) GetLookups(w http.ResponseWriter, r *http.Request) {
	results, err := utils.ExecuteSP(Sp_GetLookup, app.config.SqlServerCs, false)
	if err != nil {
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	w.Header().Set("Content-Type", "application/json")

	jsonData, err := json.Marshal(results)
	if err != nil {
		log.Printf("Encoding error on %s: `%v`", Sp_GetLookup, err)
		w.WriteHeader(http.StatusInternalServerError)
		return
	}
	w.Write(jsonData)
}
