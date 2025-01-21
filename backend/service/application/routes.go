package application

import (
	"net/http"

	"github.com/go-chi/chi/v5"
	"github.com/go-chi/chi/v5/middleware"
)

func auth(next http.HandlerFunc) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		token := r.Header.Get("Authorization")
		if token != "valid-token" {
			http.Error(w, "Unauthorized", http.StatusUnauthorized)
			return
		}

		// Token is valid, proceed to the next handler
		next(w, r)
	}
}

func (a *App) loadRoutes() {
	router := chi.NewRouter()
	router.Use(middleware.Logger)
	router.Get("/", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("NEXT-TASK"))
		w.WriteHeader(http.StatusOK)
	})

	router.Route("/misc", a.misc)
	router.Route("/task", a.task)

	a.router = router
}

func (a *App) misc(router chi.Router) {
	router.Get("/lookup", GetLookups)
}

func (a *App) task(router chi.Router) {
	router.Post("/", AddTask)
	router.Put("/{id}", UpdateTask)
	router.Post("/byuser", GetTaskbyUser)
}
