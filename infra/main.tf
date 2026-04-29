resource "google_project_service" "services" {
  for_each = toset([
    "compute.googleapis.com",
    "artifactregistry.googleapis.com",
    "cloudbuild.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iam.googleapis.com",
    "storage.googleapis.com"
  ])
  service            = each.key
  disable_on_destroy = false
}


resource "time_sleep" "wait_for_services" {
  depends_on      = [google_project_service.services]
  create_duration = "30s"
}

