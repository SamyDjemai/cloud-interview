#!/bin/sh
set -e

# Shut down Minikube
echo "🚀 Shutting down Minikube..."
minikube delete
