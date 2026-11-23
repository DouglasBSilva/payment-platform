package main

import (
	"context"
	"log"
	"net/http"
	"os"

	"github.com/DouglasBSilva/payment-platform/ledger/internal/api"
	"github.com/jackc/pgx/v5/pgxpool"
)

func main() {
	dbpool := databaseConnection()
	defer dbpool.Close()
	mux := http.NewServeMux()
	mux.HandleFunc("GET /healthz", api.Health)
	log.Fatal(http.ListenAndServe(":5000", mux))
}

func databaseConnection() *pgxpool.Pool {
	databaseUrl := os.Getenv("LEDGER_APP_URL")
	if databaseUrl == "" {
		log.Fatal("Missing database configuration")
	}

	dbpool, err := pgxpool.New(context.Background(), databaseUrl)

	if err != nil {
		log.Fatalf("Unable to connect to database: %v \n", err)
	}

	err = dbpool.Ping(context.Background())

	if err != nil {
		log.Fatalf("Database unreachable: %v \n", err)
	}

	return dbpool
}
