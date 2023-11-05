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

# Log into AWS ECR
echo "🔑 Logging into AWS ECR..."
aws ecr get-login-password --region eu-west-3 | docker login --username AWS --password-stdin "$ECR_REGISTRY"
echo "✅ Logged into AWS ECR."

SCRIPT_PATH=$(dirname "$0")

# For each app in the `apps` directory, build its Docker image and push it to AWS ECR
for app in "$SCRIPT_PATH"/../../apps/*; do
  # Get the app name from the directory name
  app_name=$(basename "$app")

  # Get the full Docker image tag that we will use to push to AWS ECR
  IMAGE_TAG="$IMAGE_TAG_PREFIX/$app_name:$VERSION_NUMBER"

  # Build the Docker image using the Dockerfile in the app directory
  echo "🏗 Building Docker image for $app_name..."
  docker build -t "$app_name:$VERSION_NUMBER" "$app"
  echo "✅ Docker image $app_name:$VERSION_NUMBER is built."

  # Tag the Docker image
  echo "🏷 Tagging Docker image $IMAGE_TAG..."
  docker tag "$app_name:$VERSION_NUMBER" "$IMAGE_TAG"
  echo "✅ Docker image $IMAGE_TAG is tagged."

  # Push the Docker image to AWS ECR
  echo "🚀 Pushing Docker image $IMAGE_TAG to AWS ECR..."
  aws ecr describe-repositories --no-cli-pager --repository-names "$REPO_PREFIX/$app_name" || aws ecr create-repository --no-cli-pager --repository-name "$REPO_PREFIX/$app_name"
  docker push "$IMAGE_TAG"
  echo "✅ Docker image $IMAGE_TAG is pushed to AWS ECR."
done
