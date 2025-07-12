{
  description = "test2 - ";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    score-compose-src = {
      url = "github:score-spec/score-compose";
      flake = false;
    };
    score-k8s-src = {
      url = "github:score-spec/score-k8s";
      flake = false;
    };
    # Go-specific inputs can be added here
  };

  outputs = { self, nixpkgs, flake-utils, score-compose-src, score-k8s-src }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        # Go version for backend
        go = pkgs.go_1_23;
        
        # Score.dev packages - always available
        score-compose = pkgs.buildGoModule {
          pname = "score-compose";
          version = "0.28.0";
          src = score-compose-src;
          vendorHash = "sha256-CCvTvo2YMgD4JXrMPUZqE73Y+34QYy+kyxMWtdNvIFg=";
          subPackages = [ "cmd/score-compose" ];
          env.CGO_ENABLED = "0";
          doCheck = false;
          meta = with pkgs.lib; {
            description = "Score CLI for generating Docker Compose manifests";
            homepage = "https://score.dev";
            license = licenses.asl20;
          };
        };
        
        score-k8s = pkgs.buildGoModule {
          pname = "score-k8s";
          version = "0.5.2";
          src = score-k8s-src;
          vendorHash = "sha256-aGyh/vgCoF38e8iiMsNr9YKsKriU5n3T9DoiopNamHU=";
          subPackages = [ "cmd/score-k8s" ];
          env.CGO_ENABLED = "0";
          doCheck = false;
          meta = with pkgs.lib; {
            description = "Score CLI for generating Kubernetes manifests";
            homepage = "https://score.dev";
            license = licenses.asl20;
          };
        };
        
        # Development tools
        devTools = with pkgs; [
          # Version control
          git
          
          # Code quality
          gnumake
          
          # Docker and containerization
          docker
          docker-compose
          
          # Score.dev tools - always available
          score-compose
          score-k8s
          # Go development tools
          go
          golangci-lint
          gotools
          delve
        ];
        
        # Environment variables
        envVars = {
          PROJECT_NAME = "test2";
          PROJECT_ROOT = builtins.toString ./.;
          GO111MODULE = "on";
          GOPATH = "${builtins.toString ./.}/.go";
        };
        
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = devTools;
          
          shellHook = ''
            echo "🚀 Welcome to test2 Development Environment"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "Go version: $(go version)"
            echo "Docker: $(docker --version)"
            echo "Score-compose: $(score-compose --version)"
            echo "Score-k8s: $(score-k8s --version)"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo ""
            echo "📁 Project Structure:"
            echo "  cmd/         - Application entrypoints"
            echo "  internal/    - Internal packages"
            echo "  pkg/         - Public packages"
            echo "  docs/        - Documentation"
            echo ""
            echo "🔧 Available Commands:"
            echo "  make dev     - Start development environment"
            echo "  make build   - Build the application"
            echo "  make test    - Run tests"
            echo "  make deploy  - Deploy application"
            echo ""
            echo "✅ Environment configured successfully!"
            
            # Set environment variables
            ${builtins.concatStringsSep "\n" (pkgs.lib.mapAttrsToList (name: value: "export ${name}=\"${value}\"") envVars)}
          '';
        };
      });
}
