package application

import (
	"encoding/json"
	"net/http"
	"strconv"
	"strings"

	"next-task-svc/utils"

	"github.com/go-chi/chi/v5"
)

// GetLookups returns all lookup kv pairs for apps
func (app *App) GetLookups(w http.ResponseWriter, r *http.Request) {
	var lookup []Lookup
	err, _ := utils.ExecuteSP(Sp_GetLookup, &lookup, nil, "")
	if err != nil {
		http.Error(w, http_500, http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")

	jsonData, err := json.Marshal(lookup)
	if err != nil {
		utils.Logger("Encoding error on %s: `%v`", Sp_GetLookup, err)
		http.Error(w, http_500, http.StatusInternalServerError)
		return
	}

	w.Write(jsonData)
}

// GetTaskbyUser gets tasks by user id using pagination
func (app *App) GetTaskbyUser(w http.ResponseWriter, r *http.Request) {
	var request TaskByUser
	var response []Tasks
	var fieldsOmit []string

	err := json.NewDecoder(r.Body).Decode(&request)
	if err != nil {
		utils.Logger("Decoding error on %s: `%v`", Sp_GetActiveTasksByUser, err)
		http.Error(w, httP_400, http.StatusBadRequest)
		return
	}
	validatorMsg := utils.RequestValidator(request, &fieldsOmit)
	if validatorMsg != "" {
		http.Error(w, strings.ToLower(validatorMsg), http.StatusBadRequest)
		return
	}

	err, _ = utils.ExecuteSP(Sp_GetActiveTasksByUser, &response, request, strings.Join(fieldsOmit, ""))
	if err != nil {
		http.Error(w, http_500, http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	jsonData, err := json.Marshal(response)
	if err != nil {
		utils.Logger("Encoding error on %s: `%v`", Sp_GetActiveTasksByUser, err)
		http.Error(w, http_500, http.StatusInternalServerError)
		return
	}
	w.Write(jsonData)
}

// AddTask adds a new task and returns first set of tasks for that user
func (app *App) AddTask(w http.ResponseWriter, r *http.Request) {
	var request Task
	var response []Tasks
	var fieldsOmit = []string{"IsArchived", "Status"}

	err := json.NewDecoder(r.Body).Decode(&request)
	if err != nil {
		utils.Logger("Decoding error on %s: `%v`", Sp_AddTask, err)
		http.Error(w, httP_400, http.StatusBadRequest)
		return
	}
	validatorMsg := utils.RequestValidator(request, &fieldsOmit)
	if validatorMsg != "" {
		http.Error(w, strings.ToLower(validatorMsg), http.StatusBadRequest)
		return
	}

	err, isBusinessErr := utils.ExecuteSP(Sp_AddTask, &response, request, strings.Join(fieldsOmit, ""))
	if err != nil {
		if isBusinessErr {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		http.Error(w, http_500, http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	jsonData, err := json.Marshal(response)
	if err != nil {
		utils.Logger("Encoding error on %s: `%v`", Sp_AddTask, err)
		http.Error(w, http_500, http.StatusInternalServerError)
		return
	}
	w.Write(jsonData)
}

func (app *App) UpdateTask(w http.ResponseWriter, r *http.Request) {
	var request Task
	var response []Tasks
	var fieldsOmit = []string{"UserID"}

	taskId, err := strconv.ParseInt(chi.URLParam(r, "id"), 10, 64)
	if err != nil {
		http.Error(w, "Provide UserID", http.StatusBadRequest)
		return
	}

	err = json.NewDecoder(r.Body).Decode(&request)
	if err != nil {
		utils.Logger("Decoding error on %s: `%v`", Sp_UpdateTask, err)
		http.Error(w, httP_400, http.StatusBadRequest)
		return
	}
	request.TaskID = taskId

	validatorMsg := utils.RequestValidator(request, &fieldsOmit)
	if validatorMsg != "" {
		http.Error(w, strings.ToLower(validatorMsg), http.StatusBadRequest)
		return
	}

	err, isBusinessErr := utils.ExecuteSP(Sp_UpdateTask, &response, request, strings.Join(fieldsOmit, ""))
	if err != nil {
		if isBusinessErr {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		http.Error(w, http_500, http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	jsonData, err := json.Marshal(response)
	if err != nil {
		utils.Logger("Encoding error on %s: `%v`", Sp_UpdateTask, err)
		http.Error(w, http_500, http.StatusInternalServerError)
		return
	}
	w.Write(jsonData)
}
