variable "project_id" {
  type        = string
  description = "The GCP Project ID"
}

variable "region" {
  type        = string
  default     = "asia-southeast1"
  description = "Primary region for resources"
}

 variable "service_name" {
  type        = string
  default     = "portfolio-api"
  description = "The name of the Cloud Run service"
}

variable "repo_id" {
  type        = string
  description = "Artifact Registry repository name"
  default     = "portfolio-repo"
}

variable "image_tag" {
  type        = string
  default     = "v1"
  description = "The specific tag of the Docker image to deploy (provided by CI/CD)"
}

variable "firestore_name" {
  type        = string
  description = "Firestore database default name"
  default     = "(default)"
}

variable "github_username" {
  type        = string
  description = "GitHub username for Cloud Build trigger"
  default     = ""
}

variable "github_repo_name" {
  type        = string
  description = "GitHub repository name for Cloud Build trigger"
  default     = ""
}

variable "pipeline_file" {
  type        = string
  description = "Pipeline filename for CI/CD yaml"
  default     = ""
}

