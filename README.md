# Sherry's SRE Portfolio

![Build Status](https://github.com/sherry-gcp/sre-portfolio/actions/workflows/deploy.yml/badge.svg)
![GCP](https://img.shields.io/badge/Google_Cloud-4285F4?style=flat&logo=google-cloud&logoColor=white)

> A compilation of my cloud projects showcasing my cloud skills and resillience as a self-taught learner. Portfolio site is deployed on a serverless Cloud Run service.

A high-performance, serverless SRE portfolio designed for scalability and resilience. This project demonstrates a transition from static HTML to a dynamic, event-driven architecture on Google Cloud.

## 🚀 Infrastructure & CI/CD
This portfolio uses a **1-Click Deployment** architecture:
1.  **CI/CD:** GitHub Actions runs `pytest` on every push.
2.  **Containerization:** Automated Docker builds pushed to Artifact Registry.
3.  **IaC:** Terraform manages Cloud Run, GCS, and IAM permissions.
4.  **Static Assets:** High-performance delivery via Google Cloud Storage.

---

## 🛠️ Local Development

### 1. Prerequisites
*   Install [uv](https://github.com/astral-sh/uv)
*   Python 3.12+

### 2. Setup
```bash
# Install dependencies
uv sync

# Run tests
PYTHONPATH=. uv run pytest

# Start Dev Server
uv run uvicorn main:app --reload
```

---

## 🌍 Production Deployment (GitHub Actions)

To enable automated deployment, add the following **Secrets** to your GitHub repository (`Settings > Secrets and variables > Actions`):

| Secret | Description |
| :--- | :--- |
| `GCP_PROJECT_ID` | Your Google Cloud Project ID (e.g., `sreport01`) |
| `GCP_SA_KEY` | The JSON key for your Deployment Service Account |

### How to get the `GCP_SA_KEY`:
1.  Go to **IAM & Admin > Service Accounts** in GCP Console.
2.  Create a Service Account (e.g., `github-deployer`).
3.  Grant roles: `Cloud Run Admin`, `Storage Admin`, `Artifact Registry Administrator`, `Service Account User`.
4.  Create a **JSON Key**, download it, and paste the entire contents into the `GCP_SA_KEY` secret.

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

## 📝 License
**MIT License**. See [LICENSE](LICENSE) file for details.
