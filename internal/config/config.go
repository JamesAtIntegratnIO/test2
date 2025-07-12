package config

import (
    "os"
    "strconv"
)

// Config holds all configuration for the application
type Config struct {
    Server   ServerConfig   `json:"server"`
    
    Redis    RedisConfig    `json:"redis"`
    
    Logger   LoggerConfig   `json:"logger"`
}

// ServerConfig holds server configuration
type ServerConfig struct {
    Port            string `json:"port"`
    Host            string `json:"host"`
    ReadTimeout     int    `json:"read_timeout"`
    WriteTimeout    int    `json:"write_timeout"`
    ShutdownTimeout int    `json:"shutdown_timeout"`
}




// RedisConfig holds Redis configuration
type RedisConfig struct {
    Addr     string `json:"addr"`
    Password string `json:"password"`
    DB       int    `json:"db"`
}




// LoggerConfig holds logger configuration
type LoggerConfig struct {
    Level  string `json:"level"`
    Format string `json:"format"`
}

// Load loads configuration from environment variables
func Load() (*Config, error) {
    config := &Config{
        Server: ServerConfig{
            Port:            getEnv("PORT", "8080"),
            Host:            getEnv("HOST", "0.0.0.0"),
            ReadTimeout:     getEnvAsInt("READ_TIMEOUT", 30),
            WriteTimeout:    getEnvAsInt("WRITE_TIMEOUT", 30),
            ShutdownTimeout: getEnvAsInt("SHUTDOWN_TIMEOUT", 30),
        },
        
        
        Redis: RedisConfig{
            Addr:     getEnv("REDIS_ADDR", "localhost:6379"),
            Password: getEnv("REDIS_PASSWORD", ""),
            DB:       getEnvAsInt("REDIS_DB", 0),
        },
        
        
        Logger: LoggerConfig{
            Level:  getEnv("LOG_LEVEL", "info"),
            Format: getEnv("LOG_FORMAT", "json"),
        },
    }

    return config, nil
}

// getEnv gets an environment variable with a default value
func getEnv(key, defaultValue string) string {
    if value := os.Getenv(key); value != "" {
        return value
    }
    return defaultValue
}

// getEnvAsInt gets an environment variable as integer with a default value
func getEnvAsInt(key string, defaultValue int) int {
    if value := os.Getenv(key); value != "" {
        if intValue, err := strconv.Atoi(value); err == nil {
            return intValue
        }
    }
    return defaultValue
}
