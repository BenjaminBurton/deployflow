package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"time"
)

type Response struct {
	Message   string    `json:"message"`
	Service   string    `json:"service"`
	Timestamp time.Time `json:"timestamp"`
}

type HealthResponse struct {
	Status string `json:"status"`
}

type DataResponse struct {
	Data      []string  `json:"data"`
	Count     int       `json:"count"`
	Timestamp time.Time `json:"timestamp"`
}

func main() {
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	mux := http.NewServeMux()

	// Routes
	mux.HandleFunc("/", homeHandler)
	mux.HandleFunc("/health", healthHandler)
	mux.HandleFunc("/ready", readyHandler)
	mux.HandleFunc("/api/data", dataHandler)

	server := &http.Server{
		Addr:         ":" + port,
		Handler:      loggingMiddleware(mux),
		ReadTimeout:  15 * time.Second,
		WriteTimeout: 15 * time.Second,
		IdleTimeout:  60 * time.Second,
	}

	log.Printf("🚀 Go service starting on port %s", port)
	if err := server.ListenAndServe(); err != nil {
		log.Fatal(err)
	}
}

func loggingMiddleware(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		start := time.Now()
		next.ServeHTTP(w, r)
		log.Printf("%s %s %s", r.Method, r.RequestURI, time.Since(start))
	})
}

func homeHandler(w http.ResponseWriter, r *http.Request) {
	response := Response{
		Message:   "DeployFlow Go Backend Service",
		Service:   "go-service",
		Timestamp: time.Now(),
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	response := HealthResponse{
		Status: "healthy",
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(response)
}

func readyHandler(w http.ResponseWriter, r *http.Request) {
	response := HealthResponse{
		Status: "ready",
	}

	w.Header().Set("Content-Type", "application/json")
	w.WriteHeader(http.StatusOK)
	json.NewEncoder(w).Encode(response)
}

func dataHandler(w http.ResponseWriter, r *http.Request) {
	sampleData := []string{
		"Kubernetes",
		"Docker",
		"CI/CD",
		"DevOps",
		"Microservices",
	}

	response := DataResponse{
		Data:      sampleData,
		Count:     len(sampleData),
		Timestamp: time.Now(),
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(response)
}
