package main

import (
    "fmt"
    "os"
)

func main() {
    fmt.Println("Please use 'go run cmd/server/main.go' to start the server")
    fmt.Println("Or build with 'go build -o bin/server cmd/server/main.go'")
    os.Exit(1)
}
