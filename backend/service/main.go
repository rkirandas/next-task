package main

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"strconv"

	"github.com/joho/godotenv"

	app "next-task-svc/application"
	"next-task-svc/utils"
)

func main() {
	app := app.New(LoadConfig())
	defer utils.DBClose()

	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt)
	defer cancel()

	err := app.Start(ctx)
	if err != nil {
		utils.Logger(fmt.Sprintf("Failed to start app! %v", err))
		os.Exit(1)
	}
}

func LoadConfig() app.Config {
	cfg := app.Config{}

	err := godotenv.Load()
	if err != nil {
		utils.Logger("Couldn't Load local env file. Err: %s", err)
		os.Exit(1)
	}

	if port, exists := os.LookupEnv("SERVER_PORT"); exists {
		cfg.ServerPort, err = strconv.Atoi(port)
		if err != nil {
			utils.Logger("Invalid server port in env: %s", err)
			os.Exit(1)
		}
	} else {
		utils.Logger("Missing required environment variable: SERVER_PORT")
		os.Exit(1)
	}

	if sqlServerCs, exists := os.LookupEnv("SQL_SERVER_CS"); exists {
		cfg.SqlServerCs = sqlServerCs
	} else {
		utils.Logger("Missing required environment variable: SQL_SERVER_CS")
		os.Exit(1)
	}

	sqlErr := utils.DBInit(cfg.SqlServerCs)

	if sqlErr != nil {
		utils.Logger("Shutting down! %s", sqlErr)
		os.Exit(1)
	}
	return cfg
}
