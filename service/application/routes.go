package application

import (
	"bytes"
	"net/http"
	"next-task-svc/utils"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

func auth(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		token := r.Header.Get(Bearer)
		if token == "" {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		if val := utils.VerifyToken(token); val {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		next(w, r)
	}
}

func cache(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if cachedResponse := utils.GetCache(r.URL.Path); cachedResponse != nil {
			w.Header().Set("Content-Type", "application/json")
			w.Write(cachedResponse)
			return
		}

		crw := &customResponseWriter{
			ResponseWriter: w,
			body:           &bytes.Buffer{},
		}

		next(crw, r)

		if crw.statusCode == http.StatusOK || crw.statusCode == 0 {
			utils.SetCache(crw.body.Bytes(), r.URL.Path)
		}

		w.Header().Set("Content-Type", "application/json")
		w.Write(crw.body.Bytes())
	}
}

// Add this custom ResponseWriter structure
type customResponseWriter struct {
	http.ResponseWriter
	statusCode int
	body       *bytes.Buffer
}

func (crw *customResponseWriter) Write(b []byte) (int, error) {
	return crw.body.Write(b)
}

func (crw *customResponseWriter) WriteHeader(statusCode int) {
	crw.statusCode = statusCode
	crw.ResponseWriter.WriteHeader(statusCode)
}

func (a *App) loadRoutes() {
	router := chi.NewRouter()
	router.Use(middleware.Logger)
	router.Get("/", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("NEXT-TASK"))
		w.WriteHeader(http.StatusOK)
	})

	router.Route("/misc", a.misc)
	router.Route("/user", a.user)
	router.Route("/task", a.task)

	a.router = router
}

func (a *App) misc(router chi.Router) {
	router.Get("/lookup", cache(GetLookups))
}

func (a *App) user(router chi.Router) {
	router.Get("/", auth(GetUser))
	router.Post("/anonymous", AddAnonymousUser)
}

func (a *App) task(router chi.Router) {
	router.Post("/", auth(AddTask))
	router.Put("/{id}", auth(UpdateTask))
	router.Post("/byuser", auth(GetTaskbyUser))
}
