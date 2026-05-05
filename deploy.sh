#!/bin/bash
set -e

echo "🚀 Starting Portfolio Deployment..."

# --- SRE Pre-flight Checks ---
echo "🔍 Checking authentication..."
if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q "@"; then
    echo "❌ Error: No active gcloud account found. Please run: gcloud auth login"
    exit 1
fi
echo "   ✅ gcloud authenticated."

echo "🔍 Checking GitHub authentication..."
if ! gh auth status > /dev/null 2>&1; then
    echo "❌ Error: Not logged into GitHub CLI. Please run: gh auth login"
    exit 1
fi
echo "   ✅ GitHub authenticated."

echo "🔍 Checking Docker engine..."
if ! docker info > /dev/null 2>&1; then
    echo "❌ Error: Docker daemon is not running. Please start Docker Desktop."
    exit 1
fi
echo "   ✅ Docker is running."

PROJECT_ID=$(gcloud config get-value project)
REGION="asia-southeast1"
IMAGE_TAG=$(date +%Y%m%d%H%M%S)
IMAGE_PATH="$REGION-docker.pkg.dev/$PROJECT_ID/portfolio-repo/api:$IMAGE_TAG"

GITHUB_FULL_REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
GITHUB_USERNAME=$(echo $GITHUB_FULL_REPO | cut -d'/' -f1)
GITHUB_REPO_NAME=$(echo $GITHUB_FULL_REPO | cut -d'/' -f2)

TF_VARS="-var=project_id=$PROJECT_ID -var=image_tag=$IMAGE_TAG -var=github_username=$GITHUB_USERNAME -var=github_repo_name=$GITHUB_REPO_NAME"

echo "🎨 STEP 1: COMPILING PRODUCTION CSS..."
if [ -f "./tailwindcss-macos-arm64" ]; then
    ./tailwindcss-macos-arm64 -i ./web/css/input.css -o ./web/css/main.css --minify
    echo "   ✅ CSS updated."
else
    echo "   ⚠️ Tailwind binary not found, skipping local compilation..."
fi

echo ""
echo "====================================================="
echo "🧪 STEP 2: RUNNING AUTOMATED TESTS..."
echo "====================================================="
uv sync
PYTHONPATH=. uv run pytest
echo "   ✅ All tests passed."

echo ""
echo "====================================================="
echo "📦 STEP 3: BOOTSTRAPPING REGISTRY..."
echo "====================================================="
terraform -chdir=infra init > /dev/null

echo "   $ terraform -chdir=infra plan -target=google_artifact_registry_repository.portfolio-repo"
terraform -chdir=infra plan -target=google_artifact_registry_repository.portfolio-repo $TF_VARS -out=tfplan-registry

echo ""
echo "====================================================="
echo "🚀 EXECUTING REGISTRY PLAN..."
echo "====================================================="
sleep 2

terraform -chdir=infra apply "tfplan-registry"

echo ""
echo "====================================================="
echo "🐳 STEP 4: BUILDING & PUSHING DOCKER IMAGE..."
echo "====================================================="
gcloud auth configure-docker $REGION-docker.pkg.dev --quiet
docker build --platform linux/amd64 -t $IMAGE_PATH .
docker push $IMAGE_PATH

echo ""
echo "====================================================="
echo "🏗️ STEP 5: PROVISIONING FULL INFRASTRUCTURE..."
echo "====================================================="
echo "   📍 Creating domain mapping first..."
terraform -chdir=infra apply $TF_VARS -target=google_cloud_run_domain_mapping.portfolio_domain -auto-approve

echo "   📍 Provisioning remaining resources..."
terraform -chdir=infra plan $TF_VARS -out=tfplan-full
terraform -chdir=infra apply "tfplan-full"

echo "✅ Deployment Complete!"
echo "   -> URL: $(terraform -chdir=infra output -raw service_url)"

BEAT_URL=$(terraform -chdir=infra output -raw beat_url 2>/dev/null || echo "")
if [ -n "$BEAT_URL" ]; then
    echo ""
    echo "💓 Pinging Cronitor Beat..."
    curl --retry 3 --retry-delay 2 -s "$BEAT_URL" > /dev/null
    echo "   ✅ Beat registered."
fi
