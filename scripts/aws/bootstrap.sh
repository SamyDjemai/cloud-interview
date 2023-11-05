#!/bin/sh

CLUSTER_NAME="samyd-ornikar-prod"

SCRIPT_PATH=$(dirname "$0")

# Run setup_kubectl.sh
echo "🔥 Running setup_kubectl.sh..."
"$SCRIPT_PATH"/setup_kubectl.sh

# Install Traefik
echo "🏗 Installing Traefik..."
helm repo update
helm install --repo=https://traefik.github.io/charts --version "25.0.0" \
  traefik traefik --create-namespace --namespace=traefik
echo "✅ Traefik is installed."

# Install Cluster Autoscaler
echo "🏗 Installing Cluster Autoscaler..."
helm install --repo=https://kubernetes.github.io/autoscaler --version "9.29.4" \
  cluster-autoscaler cluster-autoscaler --namespace=kube-system \
  --set "autoDiscovery.clusterName=$CLUSTER_NAME" \
  --set 'awsRegion=eu-west-3'
echo "✅ Cluster Autoscaler is installed."
