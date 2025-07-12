package middleware

import (
    "time"

    "github.com/gin-gonic/gin"
    "test2/internal/logger"
)

// LoggerMiddleware returns a Gin middleware that logs requests
func LoggerMiddleware(logger logger.Logger) gin.HandlerFunc {
    return func(c *gin.Context) {
        start := time.Now()
        path := c.Request.URL.Path
        raw := c.Request.URL.RawQuery

        // Process request
        c.Next()

        // Log request
        end := time.Now()
        latency := end.Sub(start)

        clientIP := c.ClientIP()
        method := c.Request.Method
        statusCode := c.Writer.Status()
        
        if raw != "" {
            path = path + "?" + raw
        }

        logger.WithFields(map[string]interface{}{
            "status":     statusCode,
            "method":     method,
            "path":       path,
            "ip":         clientIP,
            "latency":    latency,
            "user_agent": c.Request.UserAgent(),
        }).Info("Request processed")
    }
}
