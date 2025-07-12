package handlers

import (
    "test2/internal/logger"
    
    "github.com/redis/go-redis/v9"
)

// Dependencies holds all handler dependencies
type Dependencies struct {
    Logger logger.Logger
    
    Cache  *redis.Client
}

// Response represents a standard API response
type Response struct {
    Success bool        `json:"success"`
    Message string      `json:"message,omitempty"`
    Data    interface{} `json:"data,omitempty"`
    Error   string      `json:"error,omitempty"`
}

// ErrorResponse represents an error response
type ErrorResponse struct {
    Success bool   `json:"success"`
    Error   string `json:"error"`
    Code    int    `json:"code"`
}

// SuccessResponse represents a success response
type SuccessResponse struct {
    Success bool        `json:"success"`
    Message string      `json:"message,omitempty"`
    Data    interface{} `json:"data,omitempty"`
}
