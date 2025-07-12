# test2

> 

Generated with [Kekstarter](https://github.com/your-org/kekstarter) - Internal Developer Platform

## 🚀 Quick Start

### Option 1: Score.dev + Docker Compose (Recommended)

This is the easiest way to get started and matches the production deployment model.

```bash
# Clone the repository
git clone <your-repo-url>
cd test2

# Start the full stack (builds images, generates manifests, starts services)
make score-up

# View logs
make score-logs

# Stop services
make score-down
```

**Services will be available at:**
- 🔧 **Backend API**: http://localhost:8080
- 📊 **Health Check**: http://localhost:8080/health

### Option 2: Native Development (requires Nix)

For hot reload and faster development cycles:

## 🛠️ Development Environment

The project includes a complete development environment with:

- **Languages:**
  - Go 1.23
  - Go tools (golangci-lint, gotools, delve)

- **Development Tools:**
  - Docker & Docker Compose
  - Score.dev CLI tools (score-compose, score-k8s)
  - Git and development utilities

- **Build Tools:**
  - Make for task automation
  - Nix for reproducible builds

## 📁 Project Structure

```
test2/
├── README.md                     # This file
├── Makefile                      # Build and development commands
├── flake.nix                     # Nix development environment
├── .gitignore                    # Git ignore patterns
├── score.yaml                    # Score.dev full-stack configuration
├── score-backend.yaml            # Score.dev backend configuration
├── score-frontend.yaml           # Score.dev frontend configuration
├── cmd/                          # Application entry points
│   └── main.go                   # Main application
├── internal/                     # Internal packages
│   ├── handlers/                 # HTTP handlers
│   ├── models/                   # Data models
│   └── config/                   # Configuration
├── pkg/                          # Public packages
├── go.mod                        # Go module definition
├── go.sum                        # Go dependencies
└── Dockerfile                    # Container configuration
```

## 🔧 Available Commands

All commands are available through the Makefile and automatically detect the Nix environment:

### Development Commands

```bash
make dev          # Start development environment
make build        # Build the application
make test         # Run tests
make clean        # Clean build artifacts
```

### Score.dev Commands

```bash
# Start full stack with Score.dev (recommended)
make score-up

# View logs
make score-logs

# Stop services
make score-down

# Restart services (rebuild images + restart)
make score-restart

# Generate compose.yaml from Score files
make score-generate

# Build Docker images manually
make score-build

# View all available commands
make help
```

**Key Commands:**
- **`make score-up`**: Complete one-command startup (build images → generate manifests → start services)
- **`make score-down`**: Stop all services cleanly
- **`make score-restart`**: Rebuild and restart everything
- **`make score-logs`**: View real-time logs from all services

### Docker Commands

```bash
make docker-build    # Build Docker images
make docker-up       # Start with Docker Compose
make docker-down     # Stop Docker Compose
```

### Nix Commands

```bash
make nix-shell      # Enter Nix development shell
make check-nix      # Check if in Nix environment
```

## 🌟 Features

This project includes the following features:
- **CORS** - Cross-origin resource sharing
- **Redis** - Redis caching

## 🔧 Configuration

### Environment Variables
**Backend Configuration:**
- `PORT` - Server port (default: 8080)
- `LOG_LEVEL` - Log level (default: info)
- `REDIS_HOST` - Redis host
- `REDIS_PORT` - Redis port
- `REDIS_PASSWORD` - Redis password

## 🚀 Deployment

### Development Environment (Docker Compose)

```bash
# Start full stack locally
make score-up

# Check services
docker compose ps

# View logs
make score-logs

# Stop services
make score-down
```

### Production Environment (Kubernetes)

```bash
# Generate Kubernetes manifests
make score-generate-legacy

# Deploy to Kubernetes
kubectl apply -f manifests.yaml
```

### Score.dev Configuration

This project uses **separate Score.dev workload specifications** for frontend and backend, following Score.dev best practices:
- **`score-backend.yaml`**: Backend service configuration

**Why Separate Score Files?**

Score.dev treats each `.yaml` file as a separate **workload**. Using separate files allows:
- Independent scaling of frontend and backend
- Proper service discovery and networking
- Correct port exposure for each service
- Better alignment with microservices architecture

## 🧪 Testing

Run tests with:
```bash
make test
```
For Go projects, this runs:
- Unit tests with `go test`
- Race condition detection
- Coverage reporting

## 🔍 Troubleshooting

### Common Issues

1. **Nix not found:**
   - Make sure Nix is installed: https://nixos.org/download/
   - Restart your terminal after installation

2. **Permission denied on Docker:**
   - Add your user to the docker group: `sudo usermod -aG docker $USER`
   - Restart your terminal

3. **Port already in use:**
   - Check what's using the port: `lsof -i :8080`
   - Kill the process or change the port in configuration

### Getting Help

- Check the [Kekstarter documentation](https://github.com/your-org/kekstarter)
- Review the [Score.dev documentation](https://docs.score.dev/)
- Open an issue in the project repository

## 📚 Additional Resources

- [Nix Documentation](https://nixos.org/manual/nix/stable/)
- [Score.dev Documentation](https://docs.score.dev/)
- [Docker Documentation](https://docs.docker.com/)
- [Go Documentation](https://golang.org/doc/)

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

---

*This project was generated with [Kekstarter](https://github.com/your-org/kekstarter)*
