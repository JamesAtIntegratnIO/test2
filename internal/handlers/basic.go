package handlers

import (
    "net/http"
    "context"
    "time"

    "github.com/gin-gonic/gin"
)

// HealthCheck returns the health status of the application
func HealthCheck(deps Dependencies) gin.HandlerFunc {
    return func(c *gin.Context) {
        status := map[string]string{
            "status":  "ok",
            "service": "test2",
        }

        

        
        // Check Redis connection
        if deps.Cache != nil {
            ctx := context.Background()
            _, err := deps.Cache.Ping(ctx).Result()
            if err != nil {
                status["redis"] = "down"
            } else {
                status["redis"] = "up"
            }
        }
        

        c.JSON(http.StatusOK, status)
    }
}

// Welcome returns a welcome message
func Welcome(deps Dependencies) gin.HandlerFunc {
    return func(c *gin.Context) {
        response := SuccessResponse{
            Success: true,
            Message: "Welcome to test2",
            Data: map[string]interface{}{
                "version": "1.0.0",
                "service": "test2",
            },
        }

        deps.Logger.Info("Welcome endpoint accessed")
        c.JSON(http.StatusOK, response)
    }
}


// CacheTest tests the Redis cache
func CacheTest(deps Dependencies) gin.HandlerFunc {
    return func(c *gin.Context) {
        if deps.Cache == nil {
            c.JSON(http.StatusServiceUnavailable, ErrorResponse{
                Success: false,
                Error:   "Cache not available",
                Code:    http.StatusServiceUnavailable,
            })
            return
        }

        ctx := context.Background()
        key := "test_key"
        value := "test_value"

        // Set a test value
        err := deps.Cache.Set(ctx, key, value, time.Minute).Err()
        if err != nil {
            c.JSON(http.StatusInternalServerError, ErrorResponse{
                Success: false,
                Error:   "Failed to set cache value",
                Code:    http.StatusInternalServerError,
            })
            return
        }

        // Get the test value
        retrieved, err := deps.Cache.Get(ctx, key).Result()
        if err != nil {
            c.JSON(http.StatusInternalServerError, ErrorResponse{
                Success: false,
                Error:   "Failed to get cache value",
                Code:    http.StatusInternalServerError,
            })
            return
        }

        // Delete the test value
        deps.Cache.Del(ctx, key)

        c.JSON(http.StatusOK, SuccessResponse{
            Success: true,
            Message: "Cache test successful",
            Data: map[string]interface{}{
                "set_value":      value,
                "retrieved_value": retrieved,
                "match":          value == retrieved,
            },
        })
    }
}

