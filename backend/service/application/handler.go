package application

import (
	"encoding/json"
	"log"
	"net/http"

	"next-task-svc/utils"
)

// GetLookups returns all lookup kv pairs for apps
func (app *App) GetLookups(w http.ResponseWriter, r *http.Request) {
	var lookup []Lookup
	err := utils.ExecuteSP(Sp_GetLookup, app.config.SqlServerCs, &lookup)
	if err != nil {
		http.Error(w, http_500, http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")

	jsonData, err := json.Marshal(lookup)
	if err != nil {
		log.Printf("Encoding error on %s: `%v`", Sp_GetLookup, err)
		http.Error(w, http_500, http.StatusInternalServerError)
		return
	}

	w.Write(jsonData)
}

// AddTask adds a new task and returns first set of tasks for that user
func (app *App) AddTask(w http.ResponseWriter, r *http.Request) {
	var request AddTask

	err := json.NewDecoder(r.Body).Decode(&request)
	if err != nil {
		log.Printf("Decoding error on %s: `%v`", Sp_AddTask, err)
		http.Error(w, http_500, http.StatusInternalServerError)
		return
	}

	// w.Header().Set("Content-Type", "application/json")

	// jsonData, err := json.Marshal(lookup)
	// if err != nil {
	// 	log.Printf("Encoding error on %s: `%v`", Sp_GetLookup, err)
	// 	http.Error(w, http_500, http.StatusInternalServerError)
	// 	return
	// }
	// w.Write(jsonData)
}
