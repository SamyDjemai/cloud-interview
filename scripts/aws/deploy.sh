#!/bin/sh
set -e

VERSION_NUMBER="1.0"
REPO_PREFIX="samyd-ornikar"

# Get current AWS account ID
echo "🔍 Getting current AWS account ID..."
ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
echo "✅ Current AWS account ID is $ACCOUNT_ID"

ECR_REGISTRY="$ACCOUNT_ID.dkr.ecr.eu-west-3.amazonaws.com"
IMAGE_TAG_PREFIX="$ECR_REGISTRY/$REPO_PREFIX"

SCRIPT_PATH=$(dirname "$0")

# For each chart in the `charts` directory, upgrade the chart
for chart in "$SCRIPT_PATH"/../../charts/*; do
  # Get the chart name from the directory name
  chart_name=$(basename "$chart")

  # Get the full Docker image tag that we will use to push to AWS ECR
  IMAGE_REPOSITORY="$IMAGE_TAG_PREFIX/$chart_name"

  # Install or upgrade the chart
  echo "🏗 Installing or upgrading $chart_name chart..."
  helm upgrade --install "$chart_name" "$chart" --set image.repository="$IMAGE_REPOSITORY" --set image.tag="$VERSION_NUMBER"
  echo "✅ $chart_name chart is installed or upgraded."
done
