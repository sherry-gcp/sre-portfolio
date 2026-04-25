resource "google_artifact_registry_repository" "portfolio-repo" {
  repository_id = var.repo_id
  format        = "DOCKER"
  location      = var.region
  description   = "Docker repository for portfolio app image"
  depends_on    = [time_sleep.wait_for_services]
}
