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

variable "domain_name" {
  type        = string
  description = "Custom domain to map to Cloud Run service"
}

variable "managed_zone" {
  type        = string
  description = "Cloud DNS managed zone name for the domain"
}

variable "betterstack_api_token" {
  type        = string
  description = "BetterStack (Better Uptime) API Token"
  sensitive   = true
  default     = ""
}

variable "status_page_url" {
  type        = string
  description = "Public status page URL (BetterStack or similar)"
  default     = ""
}

variable "heartbeat_url" {
  type        = string
  description = "BetterStack Heartbeat URL"
  default     = ""
}

