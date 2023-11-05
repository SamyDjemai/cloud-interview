#!/bin/sh
set -e

VERSION_NUMBER="1.0"

SCRIPT_PATH=$(dirname "$0")

# For each app in the `apps` directory, build its Docker image and deploy it to Minikube
for app in "$SCRIPT_PATH"/../../apps/*; do
  # Get the app name from the directory name
  app_name=$(basename "$app")

  # Build the Docker image
  echo "🏗 Building Docker image for $app_name..."
  docker build -t "$app_name:$VERSION_NUMBER" "$app"
  echo "✅ Docker image $app_name:$VERSION_NUMBER is built."

  # Load the Docker image into Minikube
  echo "🚀 Loading Docker image $app_name:$VERSION_NUMBER into Minikube..."
  minikube image load "$app_name:$VERSION_NUMBER"
  echo "✅ Docker image $app_name:$VERSION_NUMBER is loaded into Minikube."
done
