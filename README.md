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

## ✨ Key Features

- **Fully Automated CD:** Merging to `main` triggers a zero-downtime deployment to Cloud Run.
- **Integrated CI:** Pull Requests are automatically tested and "Dry-Run" built to prevent production regressions.
- **Stateless & Scalable:** The backend is designed for high-concurrency and scales to zero when not in use (Cost Optimization).
- **Enterprise Security:** No hardcoded credentials or JSON keys; uses temporary OIDC identity handshakes.

---

## 🛠️ Day 0: Local Development & Quickstart

### 1. Prerequisites

- Install [uv](https://github.com/astral-sh/uv) (Python package manager)
- Python 3.12+
- [gcloud CLI](https://cloud.google.com/sdk/docs/install)
- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [Docker](https://www.docker.com/) (Required for local deployment testing)
- [GitHub CLI](https://cli.github.com/) (Required to set deployment secrets)

### 2. Authentication

Before running the deployment, ensure your local CLIs are authenticated:

#### Google Cloud

```bash
# Log in to the gcloud CLI
gcloud auth login

# Set your active project
gcloud config set project <YOUR_PROJECT_ID>

# Required for Terraform to access GCP APIs
gcloud auth application-default login
```

#### GitHub

```bash
# Log in to the GitHub CLI
gh auth login
```

### 3. Customizing Configuration (Optional)

If you want to run Terraform manually (without `deploy.sh`), you should create a variable file in the `infra/` directory:

```hcl
# infra/terraform.tfvars
project_id      = "your-project-id"
github_username  = "your-github-username"
github_repo_name = "sre-portfolio"
```

### 4. Setup and test for local deployment

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

**The Bootstrap Workflow (`deploy.sh`):**

1.  **SRE Pre-flight Checks:** Verifies `gcloud` authentication and Docker engine status before starting.
2.  **Asset Preparation:** Compiles production Tailwind CSS and runs the full Pytest suite.
3.  **Phase 1 Infra (Registry):** Targeted Terraform apply to create the **Artifact Registry** (The "Home" for your images).
4.  **Containerization:** Builds the `linux/amd64` Docker image locally and pushes it to the new registry.
5.  **Phase 2 Infra (Full Stack):** Final Terraform apply to provision **Cloud Run**, **GCS Buckets**, **IAM Roles**, and **Uptime Monitoring**.
6.  **Identity Setup:** Provisions the **Workload Identity Pool** needed for GitHub Actions (Day 2+).

---

## 🌍 Day 2+: Continuous Deployment (GitHub Actions)

Once Day 1 is complete, you will use **GitHub Actions** for all future app updates. This ensures true separation of concerns: Terraform handles infrastructure, GitHub handles code.

### 1. Configure GitHub Secrets (CRITICAL One-time setup)

After running `deploy.sh`, you **must** configure GitHub with the "Keyless" OIDC provider. This allows GitHub to talk to Google Cloud without using insecure JSON keys.

```bash
# 1. Set your Project ID
gh secret set GCP_PROJECT_ID --body "$(gcloud config get-value project)"

# 2. Set the WIF Provider
# Get the full provider path from Terraform output:
WIF_VALUE=$(terraform -chdir=infra output -raw workload_identity_provider)
gh secret set GCP_WIF_PROVIDER --body "$WIF_VALUE"
```

### 💡 Why this pipeline is "Solid" (SRE Audit):

- **Keyless Authentication:** Uses Workload Identity Federation (OIDC) instead of static service account keys.
- **Immutable Tagging:** Every deployment is tagged with the Git commit hash (`github.sha`), providing a perfect audit trail.
- **Separation of Concerns:** Application updates happen in GitHub; Infrastructure remains locked in Terraform. No state drift.

### 2. The SRE Deployment Flow (CI/CD)

This project enforces a professional **Shift-Left Testing** model. You should _never_ push code directly to the `main` branch.

Instead, follow the Branch-and-PR workflow:

```bash
# 1. Create a new feature branch
git checkout -b feature/update-portfolio

# 2. Make your code changes, then commit them
git add [file/directory]
git commit -m "feat: [description]"

# 3. Push your branch to GitHub
git push origin [branch-name]
```

**What happens next?**

1. **Continuous Integration (CI):** When you open a Pull Request against `main`, the `ci.yml` workflow will automatically trigger. It will run all Pytest suites and perform a dry-run Docker build to ensure your code is stable.
2. **Continuous Deployment (CD):** Once the CI checks pass and you click **Merge Pull Request**, the `deploy.yml` workflow takes over. It builds the final container, pushes it to Artifact Registry, and deploys the new revision to Cloud Run with zero downtime.

_(Note: Due to Terraform's `lifecycle` blocks, GitHub Actions deploying new images will **not** cause state drift with your infrastructure code)._

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
