package server

import (
    "context"
    "net/http"
    "time"

    "github.com/gin-gonic/gin"
    "github.com/gin-contrib/cors"
    
    "github.com/redis/go-redis/v9"
    "test2/internal/logger"
    "test2/internal/handlers"
    "test2/internal/middleware"
)

// Server represents the HTTP server
type Server struct {
    router *gin.Engine
    server *http.Server
    logger logger.Logger
    
    cache  *redis.Client
}

// Config holds server configuration
type Config struct {
    Port   string
    Logger logger.Logger
    
    Cache  *redis.Client
}

// New creates a new server instance
func New(cfg Config) *Server {
    // Set Gin mode
    gin.SetMode(gin.ReleaseMode)

    router := gin.New()
    
    // Add middleware
    router.Use(gin.Recovery())
    router.Use(middleware.LoggerMiddleware(cfg.Logger))
    
    
    // CORS configuration
    corsConfig := cors.DefaultConfig()
    corsConfig.AllowOrigins = []string{"http://localhost:3000", "http://localhost:5173"}
    corsConfig.AllowMethods = []string{"GET", "POST", "PUT", "DELETE", "OPTIONS"}
    corsConfig.AllowHeaders = []string{"Origin", "Content-Type", "Authorization"}
    corsConfig.AllowCredentials = true
    router.Use(cors.New(corsConfig))
    

    server := &Server{
        router: router,
        logger: cfg.Logger,
        
        cache:  cfg.Cache,
    }

    server.setupRoutes()
    return server
}

// setupRoutes configures all routes
func (s *Server) setupRoutes() {
    // Create handler dependencies
    deps := handlers.Dependencies{
        Logger: s.logger,
        
        Cache:  s.cache,
    }

    // Health endpoints
    s.router.GET("/health", handlers.HealthCheck(deps))
    s.router.GET("/", handlers.Welcome(deps))

    
    // API routes
    api := s.router.Group("/api/v1")
    {
        

        

        
        // Cache routes
        cache := api.Group("/cache")
        {
            cache.GET("/test", handlers.CacheTest(deps))
        }
        
    }
    
}

// Start starts the HTTP server
func (s *Server) Start() error {
    s.server = &http.Server{
        Addr:         ":8080",
        Handler:      s.router,
        ReadTimeout:  30 * time.Second,
        WriteTimeout: 30 * time.Second,
    }

    s.logger.Info("Server starting on port 8080")
    return s.server.ListenAndServe()
}

// Shutdown gracefully shuts down the server
func (s *Server) Shutdown(ctx context.Context) error {
    return s.server.Shutdown(ctx)
}
