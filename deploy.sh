#!/bin/bash
set -e

echo "🚀 Starting 1-Click SRE Portfolio Deployment..."

# 0. Set variables
PROJECT_ID=$(gcloud config get-value project)
REGION="asia-southeast1"
IMAGE_TAG=$(date +%Y%m%d%H%M%S)
IMAGE_PATH="$REGION-docker.pkg.dev/$PROJECT_ID/portfolio-repo/api:$IMAGE_TAG"

echo "🎨 Step 1: Compiling Production CSS..."
if [ -f "./tailwindcss-macos-arm64" ]; then
    ./tailwindcss-macos-arm64 -i ./web/css/input.css -o ./web/css/main.css --minify
else
    echo "⚠️ Tailwind binary not found, skipping local compilation..."
fi

echo "🧪 Step 2: Running Automated Tests..."
PYTHONPATH=. uv run pytest

echo "📦 Step 3: Provisioning Artifact Registry..."
terraform -chdir=infra init
terraform -chdir=infra apply -target=google_artifact_registry_repository.repo -auto-approve

echo "🐳 Step 4: Building and Pushing Docker Image..."
gcloud auth configure-docker $REGION-docker.pkg.dev --quiet
docker build --platform linux/amd64 -t $IMAGE_PATH .
docker push $IMAGE_PATH

echo "☁️ Step 5: Provisioning Cloud Run, GCS, and IAM..."
# Pass the project_id and image_tag directly to Terraform
terraform -chdir=infra apply \
  -var="project_id=$PROJECT_ID" \
  -var="image_tag=$IMAGE_TAG" \
  -auto-approve

echo "✅ Deployment Complete! Your serverless portfolio is live with version $IMAGE_TAG."
