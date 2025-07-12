package cache

import (
    "context"
    "time"

    "github.com/redis/go-redis/v9"
    "test2/internal/config"
)

var rdb *redis.Client

// Initialize initializes the Redis connection
func Initialize(cfg config.RedisConfig) (*redis.Client, error) {
    rdb = redis.NewClient(&redis.Options{
        Addr:     cfg.Addr,
        Password: cfg.Password,
        DB:       cfg.DB,
    })

    // Test the connection
    ctx := context.Background()
    _, err := rdb.Ping(ctx).Result()
    if err != nil {
        return nil, err
    }

    return rdb, nil
}

// GetClient returns the Redis client
func GetClient() *redis.Client {
    return rdb
}

// Close closes the Redis connection
func Close() error {
    if rdb != nil {
        return rdb.Close()
    }
    return nil
}

// Set sets a key-value pair with expiration
func Set(key string, value interface{}, expiration time.Duration) error {
    ctx := context.Background()
    return rdb.Set(ctx, key, value, expiration).Err()
}

// Get gets a value by key
func Get(key string) (string, error) {
    ctx := context.Background()
    return rdb.Get(ctx, key).Result()
}

// Delete deletes a key
func Delete(key string) error {
    ctx := context.Background()
    return rdb.Del(ctx, key).Err()
}

// Exists checks if a key exists
func Exists(key string) (bool, error) {
    ctx := context.Background()
    count, err := rdb.Exists(ctx, key).Result()
    return count > 0, err
}

// SetJSON sets a JSON value
func SetJSON(key string, value interface{}, expiration time.Duration) error {
    ctx := context.Background()
    return rdb.Set(ctx, key, value, expiration).Err()
}

// GetJSON gets a JSON value
func GetJSON(key string) (string, error) {
    ctx := context.Background()
    return rdb.Get(ctx, key).Result()
}

