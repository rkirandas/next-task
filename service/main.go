package main

import (
	"context"
	"fmt"
	"os"
	"os/signal"
	"strconv"

	app "next-task-svc/application"
	"next-task-svc/utils"
)

func main() {
	app := app.New(LoadConfig())
	defer utils.DBClose()
	defer utils.CloseFileLogger()
	ctx, cancel := signal.NotifyContext(context.Background(), os.Interrupt)
	defer cancel()

	err := app.Start(ctx)
	if err != nil {
		utils.Logger(fmt.Sprintf("Failed to start app! %v", err)) // wont log file since its not setup yet
		os.Exit(1)
	}
}

func LoadConfig() app.Config {
	cfg := app.Config{}

	if port, exists := os.LookupEnv("SERVER_PORT"); exists {
		var err error
		cfg.ServerPort, err = strconv.Atoi(port)
		if err != nil {
			utils.Logger("Invalid server port in env: %s", err)
			os.Exit(1)
		}
	} else {
		utils.Logger("Missing required environment variable: SERVER_PORT")
		os.Exit(1)
	}

	if secret, exists := os.LookupEnv("SECRET"); exists {
		utils.SetSecretKey(secret)
	} else {
		utils.Logger("Missing required environment variable: SECRET")
		os.Exit(1)
	}

	cfg.SqlServerCs = fmt.Sprintf("Server=%s;database=%s;user=%s;Password=%s;",
		os.Getenv("CONTAINER"), os.Getenv("DB"), os.Getenv("USER"), os.Getenv("PASSWORD"))
	sqlErr := utils.DBInit(cfg.SqlServerCs)
	if sqlErr != nil {
		utils.Logger("Shutting down! %s", sqlErr)
		os.Exit(1)
	}

	go utils.SetupLogFile("next_task")
	utils.InitCache()
	return cfg
}
