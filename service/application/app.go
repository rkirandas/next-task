package application

/*#TODO(@rkirandas) : Error logging mechanism*/
import (
	"context"
	"fmt"
	"net/http"
	"time"
)

type Config struct {
	SqlServerCs string
	ServerPort  int
}

type App struct {
	router http.Handler
	config Config
}

func New(config Config) *App {
	app := &App{
		config: config,
	}

	app.loadRoutes()

	return app
}

func (a *App) Start(ctx context.Context) error {
	var err error

	server := &http.Server{
		Addr:    fmt.Sprintf(":%d", a.config.ServerPort),
		Handler: a.router,
	}
	fmt.Println("Starting server")

	ch := make(chan error, 1)

	go func() {
		err := server.ListenAndServe()
		if err != nil {
			ch <- fmt.Errorf("failed to start server: %w", err)
		}
		close(ch)
	}()

	select {
	case err = <-ch:
		return err
	case <-ctx.Done():
		timeout, cancel := context.WithTimeout(context.Background(), time.Second*10)
		defer cancel()

		return server.Shutdown(timeout)
	}
}
