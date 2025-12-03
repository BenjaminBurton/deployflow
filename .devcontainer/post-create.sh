#!/bin/bash

echo "🚀 Setting up DeployFlow DevContainer..."

# Update system
echo "📦 Updating system..."
apt-get update
apt-get install -y curl wget git vim tmux zsh build-essential ca-certificates gnupg lsb-release

# Install Docker CLI (not daemon, just CLI to use host Docker via socket)
echo "📦 Installing Docker CLI..."
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce-cli

# Install Node.js 24
echo "📦 Installing Node.js 24..."
curl -fsSL https://deb.nodesource.com/setup_24.x | bash -
apt-get install -y nodejs

# Install Go 1.24
echo "📦 Installing Go 1.24..."
wget https://go.dev/dl/go1.24.0.linux-arm64.tar.gz
rm -rf /usr/local/go && tar -C /usr/local -xzf go1.24.0.linux-arm64.tar.gz
rm go1.24.0.linux-arm64.tar.gz
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
export PATH=$PATH:/usr/local/go/bin

# Install kubectl
echo "📦 Installing kubectl..."
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/arm64/kubectl"
chmod +x kubectl
mv kubectl /usr/local/bin/

# Install Helm
echo "📦 Installing Helm..."
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Install Neovim
echo "📦 Installing Neovim..."
apt-get install -y neovim

# Install Oh My Zsh
echo "📦 Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
chsh -s $(which zsh)

# Install k3d (K3s in Docker) for local Kubernetes
echo "🐳 Installing k3d..."
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Create k3d cluster (lightweight for single node)
echo "🎯 Creating lightweight k3d cluster..."
k3d cluster create deployflow-cluster \
  --api-port 6550 \
  --servers 1 \
  --agents 0 \
  --port "3000:30000@server:0" \
  --port "8080:30001@server:0" \
  --wait

# Set up kubeconfig
mkdir -p ~/.kube
k3d kubeconfig get deployflow-cluster > ~/.kube/config
export KUBECONFIG=~/.kube/config

# Verify cluster
echo "✅ Verifying cluster..."
kubectl cluster-info
kubectl get nodes

# Install Node.js dependencies
if [ -d "node-service" ]; then
  echo "📦 Installing Node.js dependencies..."
  cd node-service && npm install && cd ..
fi

# Initialize Go module
if [ -d "go-service" ]; then
  echo "📦 Initializing Go module..."
  cd go-service && go mod tidy && cd ..
fi

echo ""
echo "✨ DevContainer setup complete!"
echo ""
echo "🎯 Quick commands:"
echo "   kubectl get nodes          - Check cluster nodes"
echo "   kubectl get pods -A        - List all pods"
echo "   k3d cluster list           - List k3d clusters"
echo "   node --version             - Check Node version"
echo "   go version                 - Check Go version"
echo ""
echo "🚀 Ready to deploy!"
