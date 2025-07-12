# test2 Development Makefile
.PHONY: help dev dev-backend dev-frontend dev-backend-inner dev-frontend-inner dev-stop build test clean deploy db-up db-down db-reset db-logs redis-up redis-down redis-remove services-up services-down docker-build docker-up docker-down score-generate score-up score-down score-restart score-build score-logs

# Default target
.DEFAULT_GOAL := help

# Project Configuration
PROJECT_NAME=test2
DB_NAME=test2
DB_USER=test2
DB_PASSWORD=test2
DB_PORT=5432
DB_CONTAINER=test2-postgres
REDIS_PORT=6379
REDIS_CONTAINER=test2-redis

# Score.dev Configuration
SCORE_BACKEND=score-backend.yaml
SCORE_FRONTEND=score-frontend.yaml

# Check if we're in Nix environment
define check_nix_env
	if [ -z "$$IN_NIX_SHELL" ] && [ -z "$$NIX_PATH" ]; then \
		echo "⚠️  Not in Nix environment. Entering nix develop..."; \
		if command -v nix >/dev/null 2>&1; then \
			nix develop --command make $(1); \
		else \
			echo "❌ Nix is not installed or not in PATH"; \
			echo "   Please install Nix or run the command manually"; \
			exit 1; \
		fi; \
	else \
		echo "✅ Already in Nix environment or Nix available"; \
		make $(1); \
	fi
endef

help: ## Show this help message
	@echo "🚀 test2 Development Commands"
	@echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	@echo "💡 Most commands auto-detect Nix environment and will run 'nix develop' if needed"
	@echo ""
	@echo "📦 Score.dev Commands (Recommended):"
	@echo "  score-up       Start full-stack app using Score.dev + Docker Compose"
	@echo "  score-down     Stop Score.dev services"
	@echo "  score-restart  Restart Score.dev services"
	@echo "  score-generate Generate compose.yaml from Score files"
	@echo ""
	@echo "🔧 Development Commands:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

check-nix: ## Check if we're in a Nix environment
	@if [ -n "$$IN_NIX_SHELL" ]; then \
		echo "✅ In Nix shell environment"; \
	elif [ -n "$$NIX_PATH" ]; then \
		echo "✅ Nix is available in PATH"; \
	else \
		echo "❌ Nix environment not detected"; \
		echo "   Run 'nix develop' first or use 'make dev' to enter Nix environment"; \
	fi

nix-shell: ## Enter Nix development environment
	@echo "🐚 Entering Nix development environment..."
	@nix develop

# Development targets
dev: ## Start development environment
	@$(call check_nix_env,dev-inner)

dev-inner:
	@echo "🔧 Starting development environment..."
	@echo "🚀 Starting services..."
	@$(MAKE) services-up
	@echo "⏳ Waiting for services to be ready..."
	@timeout 30 bash -c 'until docker exec $(DB_CONTAINER) pg_isready -U $(DB_USER) -d $(DB_NAME) >/dev/null 2>&1; do sleep 1; done' || echo "⚠️  Database readiness check timed out, continuing anyway..."
	@timeout 10 bash -c 'until docker exec $(REDIS_CONTAINER) redis-cli ping >/dev/null 2>&1; do sleep 1; done' || echo "⚠️  Redis readiness check timed out, continuing anyway..."
	@$(MAKE) dev-backend-inner

dev-backend: ## Start backend development
	@$(call check_nix_env,dev-backend-inner)

dev-backend-inner:
	@echo "📦 Installing Go dependencies..."
	GOCACHE=$$(pwd)/.go-cache GOMODCACHE=$$(pwd)/.go-mod-cache go mod download
	GOCACHE=$$(pwd)/.go-cache GOMODCACHE=$$(pwd)/.go-mod-cache go mod tidy
	@echo "🚀 Starting backend server..."
	GOCACHE=$$(pwd)/.go-cache GOMODCACHE=$$(pwd)/.go-mod-cache go run cmd/server/main.go

dev-frontend: ## Start frontend development
	@$(call check_nix_env,dev-frontend-inner)

dev-frontend-inner:
	@echo "📦 Installing frontend dependencies..."
	cd frontend && npm install
	@echo "🚀 Starting frontend server..."
	cd frontend && npm run dev

dev-stop: ## Stop development services
	@echo "🛑 Stopping development services..."
	@$(MAKE) db-down || echo "Database was not running"
	@$(MAKE) redis-down || echo "Redis was not running"
	@echo "✅ Development services stopped"

# Build targets
build: ## Build the application
	@$(call check_nix_env,build-inner)

build-inner:
	@echo "🏗️  Building application..."
	@echo "🏗️  Building Go binary..."
	GOCACHE=$$(pwd)/.go-cache GOMODCACHE=$$(pwd)/.go-mod-cache go build -o bin/test2 cmd/server/main.go

# Test targets
test: ## Run tests
	@$(call check_nix_env,test-inner)

test-inner:
	@echo "🧪 Running tests..."
	GOCACHE=$$(pwd)/.go-cache GOMODCACHE=$$(pwd)/.go-mod-cache go test -v ./...

# Clean target
clean: ## Clean build artifacts
	@echo "🧹 Cleaning build artifacts..."
	rm -rf bin/ .go-cache .go-mod-cache
	GOCACHE=$$(pwd)/.go-cache GOMODCACHE=$$(pwd)/.go-mod-cache go clean
# Database targets
db-up: ## Start database
	@echo "🗄️  Starting database..."
	@if docker ps -a --format '{{.Names}}' | grep -q "^$(DB_CONTAINER)$$" ; then \
		if docker ps --format '{{.Names}}' | grep -q "^$(DB_CONTAINER)$$" ; then \
			echo "✅ Database $(DB_CONTAINER) is already running"; \
		else \
			echo "🔄 Starting existing database container..."; \
			docker start $(DB_CONTAINER); \
			echo "✅ Database started on port $(DB_PORT)"; \
		fi; \
	else \
		echo "🆕 Creating new database container..."; \
		docker run -d --name $(DB_CONTAINER) -e POSTGRES_DB=$(DB_NAME) -e POSTGRES_USER=$(DB_USER) -e POSTGRES_PASSWORD=$(DB_PASSWORD) -p $(DB_PORT):5432 postgres:15-alpine; \
		echo "✅ Database created and started on port $(DB_PORT)"; \
	fi

db-down: ## Stop database
	@echo "🗄️  Stopping database..."
	@if docker ps --format '{{.Names}}' | grep -q "^$(DB_CONTAINER)$$" ; then \
		docker stop $(DB_CONTAINER); \
		echo "✅ Database stopped"; \
	else \
		echo "ℹ️  Database $(DB_CONTAINER) is not running"; \
	fi

db-remove: ## Remove database container
	@echo "🗑️  Removing database container..."
	@if docker ps -a --format '{{.Names}}' | grep -q "^$(DB_CONTAINER)$$" ; then \
		docker stop $(DB_CONTAINER) || true; \
		docker rm $(DB_CONTAINER); \
		echo "✅ Database container removed"; \
	else \
		echo "ℹ️  Database container $(DB_CONTAINER) does not exist"; \
	fi

db-reset: ## Reset database (remove and recreate)
	@echo "🗄️  Resetting database..."
	@$(MAKE) db-remove
	@$(MAKE) db-up
	@echo "✅ Database reset"

db-logs: ## Show database logs
	@echo "🗄️  Database logs:"
	@if docker ps -a --format '{{.Names}}' | grep -q "^$(DB_CONTAINER)$$" ; then \
		docker logs $(DB_CONTAINER); \
	else \
		echo "❌ Database container $(DB_CONTAINER) does not exist"; \
	fi
# Redis targets
redis-up: ## Start Redis
	@echo "🔴 Starting Redis..."
	@if docker ps -a --format '{{.Names}}' | grep -q "^$(REDIS_CONTAINER)$$" ; then \
		if docker ps --format '{{.Names}}' | grep -q "^$(REDIS_CONTAINER)$$" ; then \
			echo "✅ Redis $(REDIS_CONTAINER) is already running"; \
		else \
			echo "🔄 Starting existing Redis container..."; \
			docker start $(REDIS_CONTAINER); \
			echo "✅ Redis started on port $(REDIS_PORT)"; \
		fi; \
	else \
		echo "🆕 Creating new Redis container..."; \
		docker run -d --name $(REDIS_CONTAINER) -p $(REDIS_PORT):6379 redis:7-alpine; \
		echo "✅ Redis created and started on port $(REDIS_PORT)"; \
	fi

redis-down: ## Stop Redis
	@echo "🔴 Stopping Redis..."
	@if docker ps --format '{{.Names}}' | grep -q "^$(REDIS_CONTAINER)$$" ; then \
		docker stop $(REDIS_CONTAINER); \
		echo "✅ Redis stopped"; \
	else \
		echo "ℹ️  Redis $(REDIS_CONTAINER) is not running"; \
	fi

redis-remove: ## Remove Redis container
	@echo "🗑️  Removing Redis container..."
	@if docker ps -a --format '{{.Names}}' | grep -q "^$(REDIS_CONTAINER)$$" ; then \
		docker stop $(REDIS_CONTAINER) || true; \
		docker rm $(REDIS_CONTAINER); \
		echo "✅ Redis container removed"; \
	else \
		echo "ℹ️  Redis container $(REDIS_CONTAINER) does not exist"; \
	fi

redis-logs: ## Show Redis logs
	@echo "🔴 Redis logs:"
	@if docker ps -a --format '{{.Names}}' | grep -q "^$(REDIS_CONTAINER)$$" ; then \
		docker logs $(REDIS_CONTAINER); \
	else \
		echo "❌ Redis container $(REDIS_CONTAINER) does not exist"; \
	fi
# Combined targets
services-up: ## Start all services (database + redis)
	@echo "🚀 Starting all services..."
	@$(MAKE) db-up
	@$(MAKE) redis-up
	@echo "✅ All services started"

services-down: ## Stop all services
	@echo "🛑 Stopping all services..."
	@$(MAKE) db-down
	@$(MAKE) redis-down
	@echo "✅ All services stopped"

# Score.dev Commands (Recommended)
score-build: ## Build Docker images for Score.dev
	@echo "🐳 Building Docker images for Score.dev..."
	@docker build -t test2/backend:latest .
	@echo "✅ Docker images built successfully"

score-generate: ## Generate compose.yaml from Score files
	@echo "📋 Generating compose.yaml from Score files..."
	@score-compose init --no-sample || true
	@score-compose generate $(SCORE_BACKEND) --publish 8080:8080
	@echo "✅ Generated compose.yaml from Score files"

score-up: ## Start full-stack app using Score.dev + Docker Compose
	@echo "🚀 Starting test2 with Score.dev..."
	@make score-build
	@make score-generate
	@docker compose up -d
	@echo ""
	@echo "✅ test2 is running!"
	@echo "🔧 Backend:  http://localhost:8080"
	@echo "📊 Health:   http://localhost:8080/health"

score-down: ## Stop Score.dev services
	@echo "🛑 Stopping Score.dev services..."
	@docker compose down
	@echo "✅ Services stopped"

score-restart: ## Restart Score.dev services
	@echo "🔄 Restarting Score.dev services..."
	@make score-down
	@make score-up

score-logs: ## View logs from Score.dev services
	@echo "📋 Viewing service logs..."
	@docker compose logs -f

# Legacy Score.dev targets (deprecated)
score-generate-legacy: ## Generate deployment manifests using Score (deprecated)
	@echo "📊 Generating deployment manifests..."
	@if [ -f "score.yaml" ]; then \
		echo "🎯 Generating Docker Compose from score.yaml..."; \
		score-compose generate score.yaml; \
		echo "🎯 Generating Kubernetes from score.yaml..."; \
		score-k8s generate score.yaml; \
	fi
	@if [ -f "score-backend.yaml" ]; then \
		echo "🎯 Generating Docker Compose from score-backend.yaml..."; \
		score-compose generate score-backend.yaml; \
		echo "🎯 Generating Kubernetes from score-backend.yaml..."; \
		score-k8s generate score-backend.yaml; \
	fi
	@if [ -f "score-frontend.yaml" ]; then \
		echo "🎯 Generating Docker Compose from score-frontend.yaml..."; \
		score-compose generate score-frontend.yaml; \
		echo "🎯 Generating Kubernetes from score-frontend.yaml..."; \
		score-k8s generate score-frontend.yaml; \
	fi
	@echo "✅ Deployment manifests generated"

# Docker targets (legacy)
docker-build: ## Build Docker images (legacy)
	@echo "🐳 Building Docker images..."
	docker build -t test2:latest .
	@echo "✅ Docker images built"

docker-up: ## Start application with Docker Compose (legacy)
	@echo "🐳 Starting application with Docker Compose..."
	@$(MAKE) score-generate-legacy
	docker-compose up -d
	@echo "✅ Application started"

docker-down: ## Stop Docker Compose (legacy)
	@echo "🐳 Stopping Docker Compose..."
	docker-compose down
	@echo "✅ Application stopped"

# Deploy target
deploy: ## Deploy application
	@echo "🚀 Deploying application..."
	@$(MAKE) build
	@$(MAKE) score-generate
	@echo "✅ Application deployed"
