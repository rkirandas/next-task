package main

import (
	"context"
	"log"
	"os"
	"os/signal"
	"strconv"

	"github.com/joho/godotenv"

	app "next-task-svc/application"
)

func main() {
	app := app.New(LoadConfig())

	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt)
	defer cancel()

	err := app.Start(ctx)
	if err != nil {
		log.Printf("failed to start app: %v", err)
	}
}

func LoadConfig() app.Config {
	cfg := app.Config{}

	err := godotenv.Load()
	if err != nil {
		log.Fatalf("Couldn't Load local env file. Err: %s", err)
	}

	if port, exists := os.LookupEnv("SERVER_PORT"); exists {
		cfg.ServerPort, err = strconv.Atoi(port)
		if err != nil {
			log.Fatalf("Invalid server port in env: %s", err)
		}
	} else {
		log.Fatalf("Missing required environment variable: SERVER_PORT")
	}

	if sqlServerCs, exists := os.LookupEnv("SQL_SERVER_CS"); exists {
		cfg.SqlServerCs = sqlServerCs
	} else {
		log.Fatalf("Missing required environment variable: SQL_SERVER_CS")
	}

	// //sqlErr := utils.HealthCheckSQLServer(cfg.SqlServerCs)

	// if sqlErr != nil {
	// 	log.Fatalf("Shutting down!\n%s", sqlErr)
	// }
	return cfg
}
