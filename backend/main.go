package main

import (
	"fmt"
	"log"
	"net/http"
)

func healthzHandler(w http.ResponseWriter, _ *http.Request) {
	_, _ = fmt.Fprintf(w, "OK")
}

func main() {
	http.HandleFunc("/healthz", healthzHandler)

	fmt.Println("Starting server on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
