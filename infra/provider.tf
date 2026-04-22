terraform {
  # backend "gcs" {
  #   bucket = "YOUR_GCS_BUCKET_NAME"
  #   prefix = "terraform/state"
  # }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.20.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "~> 0.11.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

