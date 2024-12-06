package utils

import (
	"context"
	"database/sql"
	"fmt"
	"time"

	_ "github.com/microsoft/go-mssqldb"
)

// #TODO : integrate with an ORM library like GORM

// HealthCheckSQLServer checks connectivity to SQL Server
func HealthCheckSQLServer(connStr string) error {
	return withDB(connStr, func(db *sql.DB) error {
		ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
		defer cancel()
		return db.PingContext(ctx)
	})
}

// withDB  internally handle connection lifecycle and enforce closure
// such as executing a function or query and closing the connection automatically
func withDB(connStr string, action func(*sql.DB) error) error {
	db, err := sql.Open("sqlserver", connStr)
	if err != nil {
		return fmt.Errorf("unable to open connection: %w", err)
	}
	defer db.Close()

	return action(db)
}
