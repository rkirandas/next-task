package application

import (
	"net/http"

	"github.com/go-chi/chi/v5"
)

func (a *App) loadRoutes() {
	router := chi.NewRouter()
	//router.Use(middleware.Logger)
	router.Get("/", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
	})

	router.Route("/misc", a.misc)
	//router.Route("/task", a.task)

	a.router = router
}

func (a *App) misc(router chi.Router) {
	router.Get("/lookup", a.GetLookups)
}
