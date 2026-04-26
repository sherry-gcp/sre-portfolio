# Sherry's SRE Portfolio

![Build Status](https://github.com/sherry-gcp/sre-portfolio/actions/workflows/deploy.yml/badge.svg)
![GCP](https://img.shields.io/badge/Google_Cloud-4285F4?style=flat&logo=google-cloud&logoColor=white)

> A compilation of my cloud projects showcasing my cloud skills and resillience as a self-taught learner. Portfolio site is deployed on a serverless Cloud Run service.

A high-performance, serverless SRE portfolio designed for scalability and resilience. This project demonstrates a transition from static HTML to a dynamic, event-driven architecture on Google Cloud.

## 🚀 Infrastructure & CI/CD
This portfolio uses a **Separation of Concerns** architecture:
1.  **Infrastructure Provisioning:** Terraform manages core resources (GCS, IAM, WIF). Run manually for infra changes.
2.  **App Deployment:** GitHub Actions builds images and deploys new revisions to Cloud Run.
3.  **Security:** Keyless authentication via **Workload Identity Federation (WIF)**.

---

## 🛠️ Day 0: Local Development & Quickstart

### 1. Prerequisites
*   Install [uv](https://github.com/astral-sh/uv) (Python package manager)
*   Python 3.12+
*   [gcloud CLI](https://cloud.google.com/sdk/docs/install)
*   [Terraform](https://developer.hashicorp.com/terraform/downloads)
*   [Docker](https://www.docker.com/) (Required for local deployment testing)

### 2. Setup
```bash
# Install dependencies
uv sync

# Compile Tailwind CSS
./tailwindcss-macos-arm64 -i ./web/css/input.css -o ./web/css/main.css --minify

# Run tests
PYTHONPATH=. uv run pytest

# Start Dev Server
uv run uvicorn main:app --reload
```

---

## 🏗️ Day 1: Infrastructure Bootstrap

This project uses a dedicated bash script to securely establish your core infrastructure. **Terraform must create the Cloud Run service first** to ensure it receives the strict IAM bindings and memory limits configured in code, rather than Google's default settings.

Run the bootstrap script from your local machine:
```bash
chmod +x deploy.sh
./deploy.sh
```

**What this script does:**
1. Runs tests and compiles CSS.
2. Initializes Terraform and creates the Artifact Registry.
3. Uses local Docker to build and push the initial image.
4. Runs a full `terraform apply` to provision the Cloud Run service, GCS Bucket, and Workload Identity Federation (WIF) pool.

---

## 🌍 Day 2+: Continuous Deployment (GitHub Actions)

Once Day 1 is complete, you will use **GitHub Actions** for all future app updates. This ensures true separation of concerns: Terraform handles infrastructure, GitHub handles code.

### 1. Configure GitHub Secrets (One-time setup)
After running `deploy.sh`, configure GitHub with the "Keyless" OIDC provider outputted by Terraform:

```bash
# Set your Project ID
gh secret set GCP_PROJECT_ID --body "$(gcloud config get-value project)"

# Set the WIF Provider (Check the end of your deploy.sh output for this value)
gh secret set GCP_WIF_PROVIDER --body "projects/123456789/locations/global/workloadIdentityPools/github-pool/providers/github-provider"
```

### 2. The Deployment Flow
To deploy new code changes (like updating `web/` HTML or CSS), simply push to the repository:

```bash
git add .
git commit -m "feat: updated portfolio content"
git push origin main
```
GitHub Actions will build the new image and update the Cloud Run revision with zero downtime. Due to Terraform's `lifecycle` blocks, this will **not** cause state drift with your infrastructure code.

---

## 📂 Project Structure
```text
├── api/                # FastAPI Backend & Models
│   ├── data/           # JSON Project Database
│   └── routers/        # API Endpoints
├── infra/              # Terraform HCL files
├── tests/              # Pytest automated suite
└── web/                # Frontend Assets
    ├── html/           # Jinja2 Templates
    ├── css/            # Compiled Tailwind CSS
    └── js/             # Vanilla JS Logic
```

## 🛡️ SRE Audit & Security
This project follows Enterprise SRE standards:
- **Zero-Trust:** Keyless OIDC authentication (No JSON keys).
- **Least Privilege:** CI/CD only has `run.developer` and `artifactregistry.writer` roles.
- **Drift Management:** Terraform `lifecycle` blocks prevent state conflicts during deployments.
- **Structured Logging:** JSON-formatted logs for Google Cloud Observability.

## 📝 License
**MIT License**. See [LICENSE](LICENSE) file for details.
