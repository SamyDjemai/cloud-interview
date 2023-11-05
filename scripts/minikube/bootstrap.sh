#!/bin/sh
set -e

# Get system OS and architecture
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m | tr '[:upper:]' '[:lower:]')

# Convert architecture name to Minikube's format
if [ "$ARCH" = "x86_64" ]; then
  ARCH="amd64"
fi

# Check if Minikube is installed
echo "🔍 Checking if Minikube is installed..."
if ! [ -x "$(command -v minikube)" ]; then
  echo "❌ Minikube is not installed. Installing..."
  curl -Lo minikube "https://storage.googleapis.com/minikube/releases/latest/minikube-$OS-$ARCH"
  sudo install minikube /usr/local/bin/minikube
  rm minikube
fi
echo "✅ Minikube is installed."

# Start Minikube
echo "🚀 Starting Minikube..."
minikube start --driver=docker --container-runtime=containerd --cni=bridge
echo "✅ Minikube is started."

# Install Traefik
echo "🏗 Installing Traefik..."
helm repo update
helm install --repo=https://traefik.github.io/charts --version "25.0.0" \
  traefik traefik --create-namespace --namespace=traefik
echo "✅ Traefik is installed."

echo "🎉 All done!"

