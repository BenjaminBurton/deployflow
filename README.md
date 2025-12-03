# DeployFlow

A production-ready CI/CD pipeline demonstrating containerized microservices deployment with automated testing, security scanning, and Kubernetes orchestration.

## 🏗️ Architecture

DeployFlow consists of two microservices:
- **Node.js Express API**: Frontend service handling HTTP requests
- **Go HTTP Server**: Backend service for business logic

Both services are containerized, tested, and deployed to Kubernetes through automated CI/CD pipelines.

## 🚀 Features

- **Automated CI/CD Pipeline**: GitHub Actions workflow for building, testing, and deploying
- **Container Security Scanning**: Vulnerability scanning with Trivy
- **Multi-Stage Docker Builds**: Optimized container images
- **Kubernetes Deployment**: Automated deployment to K3s cluster
- **Health Checks**: Liveness and readiness probes
- **Service Discovery**: Internal service communication

## 📋 Prerequisites

- Kubernetes cluster (K3s or EKS)
- Docker
- kubectl
- GitHub account

## 🚀 Quick Start with DevContainer
```bash
# Build and start DevContainer
devcontainer up --workspace-folder .

# Exec into container
devcontainer exec --workspace-folder . bash
```

## 🌐 API Endpoints

### Node.js Service (Port 3000)
- `GET /` - Health check
- `GET /api/status` - Service status
- `GET /api/backend` - Calls Go service

### Go Service (Port 8080)
- `GET /` - Health check
- `GET /health` - Health probe
- `GET /api/data` - Returns sample data

## 👤 Author

**Benjamin** - DevOps Engineer
- AWS Community Builder (Containers)

---

Built with ❤️ as part of my DevOps learning journey
