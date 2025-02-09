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
func GetLookups(w http.ResponseWriter, r *http.Request) {
	var lookup []Lookup
	_, err := utils.ExecuteSP(Sp_GetLookup, &lookup, nil, nil)
	if err != nil {
		http.Error(w, Http_500, http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")

	jsonData, err := json.Marshal(lookup)
	if err != nil {
		utils.Logger("Encoding error on %s: `%v`", Sp_GetLookup, err)
		http.Error(w, Http_500, http.StatusInternalServerError)
		return
	}

	w.Write(jsonData)
}

// GetUser returns user info from token
func GetUser(w http.ResponseWriter, r *http.Request) {
	var user []User

	var uuid = struct {
		UUID string
	}{getUUIDFromHeader(r)}

	_, err := utils.ExecuteSP(Sp_GetUser, &user, uuid, nil)
	if err != nil {
		http.Error(w, Http_500, http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")

	jsonData, err := json.Marshal(user)
	if err != nil {
		utils.Logger("Encoding error on %s: `%v`", Sp_GetLookup, err)
		http.Error(w, Http_500, http.StatusInternalServerError)
		return
	}

	w.Write(jsonData)
}

// AddAnonymousUser adds Anonymous User
func AddAnonymousUser(w http.ResponseWriter, r *http.Request) {
	var request NewUser
	var response []User
	err := json.NewDecoder(r.Body).Decode(&request)
	if err != nil {
		utils.Logger("Decoding error on %s: `%v`", Sp_AddUser, err)
		http.Error(w, Http_400, http.StatusBadRequest)
		return
	}

	validatorMsg := utils.RequestValidator(request, nil)
	if validatorMsg != "" {
		http.Error(w, strings.ToLower(validatorMsg), http.StatusBadRequest)
		return
	}

	_, err = utils.ExecuteSP(Sp_AddUser, &response, request, nil)
	if err != nil {
		http.Error(w, Http_500, http.StatusInternalServerError)
		return
	}

	//Creating Bearer
	response[0].UUID = utils.GenerateToken(response[0].UUID)

	w.Header().Set("Content-Type", "application/json")
	jsonData, err := json.Marshal(response)
	if err != nil {
		utils.Logger("Encoding error on %s: `%v`", Sp_AddUser, err)
		http.Error(w, Http_500, http.StatusInternalServerError)
		return
	}
	w.Write(jsonData)
}

// GetTaskbyUser gets tasks by user id using pagination
func GetTaskbyUser(w http.ResponseWriter, r *http.Request) {
	var request TaskByUser
	var response []Tasks
	var fieldsOmit []string

	err := json.NewDecoder(r.Body).Decode(&request)
	if err != nil {
		utils.Logger("Decoding error on %s: `%v`", Sp_GetActiveTasksByUser, err)
		http.Error(w, Http_400, http.StatusBadRequest)
		return
	}
	request.UUID = getUUIDFromHeader(r)

	validatorMsg := utils.RequestValidator(request, &fieldsOmit)
	if validatorMsg != "" {
		http.Error(w, strings.ToLower(validatorMsg), http.StatusBadRequest)
		return
	}

	_, err = utils.ExecuteSP(Sp_GetActiveTasksByUser, &response, request, &fieldsOmit)
	if err != nil {
		http.Error(w, Http_500, http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	jsonData, err := json.Marshal(response)
	if err != nil {
		utils.Logger("Encoding error on %s: `%v`", Sp_GetActiveTasksByUser, err)
		http.Error(w, Http_500, http.StatusInternalServerError)
		return
	}
	w.Write(jsonData)
}

// AddTask adds a new task and returns first set of tasks for that user
func AddTask(w http.ResponseWriter, r *http.Request) {
	var request Task
	var fieldsOmit = []string{"IsArchived", "Status"}
	var tasks []Tasks
	err := json.NewDecoder(r.Body).Decode(&request)
	if err != nil {
		utils.Logger("Decoding error on %s: `%v`", Sp_AddTask, err)
		http.Error(w, Http_400, http.StatusBadRequest)
		return
	}
	request.UUID = getUUIDFromHeader(r)

	validatorMsg := utils.RequestValidator(request, &fieldsOmit)
	if validatorMsg != "" {
		http.Error(w, strings.ToLower(validatorMsg), http.StatusBadRequest)
		return
	}

	result, err := utils.ExecuteSP(Sp_AddTask, &tasks, request, &fieldsOmit)
	if err != nil {
		if result.IsBusinessError {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		http.Error(w, Http_500, http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	jsonData, err := json.Marshal(tasks)
	if err != nil {
		utils.Logger("Encoding error on %s: `%v`", Sp_AddTask, err)
		http.Error(w, Http_500, http.StatusInternalServerError)
		return
	}
	w.Write(jsonData)
}

func UpdateTask(w http.ResponseWriter, r *http.Request) {
	var request Task
	var response []Tasks
	var fieldsOmit = []string{}

	taskId, err := strconv.ParseInt(chi.URLParam(r, "id"), 10, 64)
	if err != nil {
		http.Error(w, "Provide TaskID", http.StatusBadRequest)
		return
	}

	err = json.NewDecoder(r.Body).Decode(&request)
	if err != nil {
		utils.Logger("Decoding error on %s: `%v`", Sp_UpdateTask, err)
		http.Error(w, Http_400, http.StatusBadRequest)
		return
	}
	request.UUID = getUUIDFromHeader(r)
	request.TaskID = taskId

	validatorMsg := utils.RequestValidator(request, &fieldsOmit)
	if validatorMsg != "" {
		http.Error(w, strings.ToLower(validatorMsg), http.StatusBadRequest)
		return
	}

	result, err := utils.ExecuteSP(Sp_UpdateTask, &response, request, &fieldsOmit)
	if err != nil {
		if result.IsBusinessError {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		http.Error(w, Http_500, http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	jsonData, err := json.Marshal(response)
	if err != nil {
		utils.Logger("Encoding error on %s: `%v`", Sp_UpdateTask, err)
		http.Error(w, Http_500, http.StatusInternalServerError)
		return
	}
	w.Write(jsonData)
}

func getUUIDFromHeader(r *http.Request) string {
	token := r.Header.Get(Bearer)
	parts := strings.Split(token, ".")
	if len(parts) != 2 {
		return ""
	}

	return parts[0]
}
