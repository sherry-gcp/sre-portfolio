# Cloud Portfolio

[![GitHub Actions](https://img.shields.io/github/actions/workflow/status/sherry-gcp/sre-portfolio/deploy.yml?branch=main&style=flat-square&logo=github-actions&logoColor=white)](https://github.com/sherry-gcp/sre-portfolio/actions)
[![Better Stack](https://img.shields.io/badge/BetterStack-Operational-10b981?style=flat-square&logo=better-stack&logoColor=white)](https://status.sherrym.dev)
[![GCP](https://img.shields.io/badge/Google_Cloud-Asia--Southeast1-4285F4?style=flat-square&logo=google-cloud&logoColor=white)](https://cloud.google.com/)

> A serverless portfolio demonstrating cloud-native architecture. Built on Google Cloud using fully managed compute (Cloud Run) and object storage (GCS).

## Tech Stack

| Layer              | Technology                                          |
| :----------------- | :-------------------------------------------------- |
| **Backend**        | FastAPI, Python 3.12+, `uv`                         |
| **Frontend**       | Stitch AI, Vanilla JS, Tailwind CSS, Jinja2         |
| **Infrastructure** | Cloud Run, GCS, Cloud DNS, Terraform                |
| **Security**       | Workload Identity Federation                        |
| **CI/CD**          | GitHub Actions, Docker, Cloud Build                 |
| **Observability**  | Cloud Logging, Better Stack (Uptime + Heartbeats)   |

## Quickstart

### 1. Prerequisites

- [uv](https://github.com/astral-sh/uv)
- Python 3.12+
- [gcloud CLI](https://cloud.google.com/sdk/docs/install)
- [Terraform](https://developer.hashicorp.com/terraform/downloads)
- [Docker](https://www.docker.com/)
- [GitHub CLI](https://cli.github.com/)

### 2. Local Authentication

- Google Cloud
  ```bash
  gcloud init
  gcloud auth application-default login
  ```
- GitHub
  ```bash
  gh auth login
  ```

### 3. Configure Terraform variables
- Edit the infra/terraform.tfvars file
  ```hcl
  project_id      = "your-project-id"
  github_username  = "your-github-username"
  github_repo_name = "sre-portfolio"
  ```

### 4. Setup and test for local deployment

- Install dependencies
  ```bash
  uv sync
  ```
- Compile Tailwind CSS
  ```bash
  ./tailwindcss-macos-arm64 -i ./web/css/input.css -o ./web/css/main.css --minify
  ```
- Run tests
  ```bash
  PYTHONPATH=. uv run pytest
  ```
- Start app
  ```bash
  uv run uvicorn main:app
  ```

## Infrastructure Bootstrap

- Run the bootstrap script:

  ```bash
  chmod +x deploy.sh
  ./deploy.sh
  ```

> Bootstrap Workflow (`deploy.sh`):
>
> 1.  Verifies `gcloud` and `GitHub` authentication and checks Docker engine status.
> 2.  Installs project dependencies, compiles Tailwind CSS, and runs `pytest`.
> 3.  Provisions **Artifact Registry** via Terraform.
> 4.  Builds the Docker image locally and pushes it to the registry.
> 5.  Provisions the full **infrastructure**: **Cloud Run**, **GCS Buckets**, **Cloud DNS**, **IAM Roles and Permissions**.
> 6.  Pings Better Stack monitoring.

## Continuous Delivery (GitHub Actions)

### Configure GitHub Secrets

> Configure GitHub with the "Keyless" OIDC provider. This allows GitHub to talk to Google Cloud without using insecure JSON keys.

- Set your Project ID
  ```bash
  gh secret set GCP_PROJECT_ID --body "$(gcloud config get-value project)"
  ```
- Set Workload Identity Federation (WIF) provider from Terraform output:
  ```bash
  WIF_VALUE=$(terraform -chdir=infra output -raw workload_identity_provider)
  gh secret set GCP_WIF_PROVIDER --body "$WIF_VALUE"
  ```

### Deployment Flow

This project enforces **the Shift-Left Testing model** and follows a Branch-and-PR workflow:

> Test locally → Test in PR → Build → Deploy → Success

- Create a new feature branch
  ```bash
  git checkout -b feature/branch-name
  ```
- Make your code changes, then commit them
  ```bash
  git add [file/directory]
  git commit -m "feat: [description]"
  ```
- Push your branch to GitHub
  ```bash
  git push origin [branch-name]
  ```

> **GitOps Pipeline**
>
> - **Continuous Integration (CI):** Triggered on **Pull Request** to run automated validation:
>   - PR Open ➔ Pytest Audit ➔ Dry-Run Build ➔ Success
> - **Continuous Delivery (CD):** Deployment is triggered manually from **`main`** (via GitHub Actions `workflow_dispatch`):
>   - Manual Trigger ➔ OIDC Auth ➔ Immutable Build ➔ Artifact Push ➔ Cloud Run Rollout ➔ Success



## Project Structure

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

## License

**MIT License**. See [LICENSE](LICENSE.md) file for details.
