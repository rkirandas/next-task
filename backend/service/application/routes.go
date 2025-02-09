package application

import (
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
	router.Get("/lookup", GetLookups)
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
