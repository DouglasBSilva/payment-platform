package main

import (
	"log"
	"net/http"

	"github.com/DouglasBSilva/payment-platform/ledger/internal/api"
)

func main() {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /healthz", api.Health)
	log.Fatal(http.ListenAndServe(":5000", mux))
}
