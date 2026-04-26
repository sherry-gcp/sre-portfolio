#!/bin/bash
set -e

echo "🚀 Starting 1-Click SRE Portfolio Deployment..."

# 0. Set variables
PROJECT_ID=$(gcloud config get-value project)
REGION="asia-southeast1"
IMAGE_TAG=$(date +%Y%m%d%H%M%S)
IMAGE_PATH="$REGION-docker.pkg.dev/$PROJECT_ID/portfolio-repo/api:$IMAGE_TAG"

echo "🎨 Step 1: Compiling Production CSS..."
echo "   -> Running Tailwind CLI (No-Node standalone binary)"
if [ -f "./tailwindcss-macos-arm64" ]; then
    ./tailwindcss-macos-arm64 -i ./web/css/input.css -o ./web/css/main.css --minify
    echo "   ✅ main.css updated successfully."
else
    echo "   ⚠️ Tailwind binary not found, skipping local compilation..."
fi

echo "🧪 Step 2: Running Automated Tests..."
echo "   -> Validating API endpoints, Pydantic models, and project data"
PYTHONPATH=. uv run pytest
echo "   ✅ All tests passed. Code is stable."

echo "📦 Step 3: Bootstrapping Infrastructure..."
echo "   -> Initializing Terraform and provisioning Artifact Registry"
terraform -chdir=infra init
terraform -chdir=infra apply -target=google_artifact_registry_repository.repo -auto-approve

echo "🐳 Step 4: Building and Pushing Docker Image..."
echo "   -> Platform: linux/amd64 | Tag: $IMAGE_TAG"
gcloud auth configure-docker $REGION-docker.pkg.dev --quiet
docker build --platform linux/amd64 -t $IMAGE_PATH .
docker push $IMAGE_PATH
echo "   ✅ Container image pushed to Artifact Registry."

echo "🏗️ Step 5: Provisioning Full Infrastructure (Part 2 - Cloud Run & IAM)..."
terraform -chdir=infra apply \
  -var="project_id=$PROJECT_ID" \
  -var="image_tag=$IMAGE_TAG" \
  -auto-approve

echo "✅ Application Deployment Complete!"
echo "   -> Version: $IMAGE_TAG"
echo "   -> URL: $(gcloud run services describe portfolio-api --region $REGION --format 'value(status.url)')"
echo "   -> SRE Status: Active | Monitoring: Enabled"
