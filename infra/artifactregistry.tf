resource "google_artifact_registry_repository" "portfolio-repo" {
  repository_id = var.repo_id
  format        = "DOCKER"
  location      = var.region
  description   = "Docker repository for portfolio app image"
  depends_on    = [time_sleep.wait_for_services]

  cleanup_policies {
    id     = "keep-minimum-versions"
    action = "KEEP"
    most_recent_versions {
      keep_count = 3
    }
  }

  cleanup_policies {
    id     = "delete-old-versions"
    action = "DELETE"
    condition {
      older_than = "1209600s"
    }
  }
}
