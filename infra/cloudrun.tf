resource "google_project_service" "cloud_run_api" {
  project = var.project_id
  service = "run.googleapis.com"

  disable_on_destroy = false
}


resource "google_cloud_run_v2_service" "api_server" {
  name     = var.service_name
  location = var.region
  ingress  = "INGRESS_TRAFFIC_ALL"

  template {
    service_account = google_service_account.cloudrun_sa.email

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.repo_id}/api:${var.image_tag}"

      resources {
        limits = {
          cpu    = "1"
          memory = "512Mi"
        }
      }

      ports {
        container_port = 8000
      }
    }

    scaling {
      min_instance_count = 0
      max_instance_count = 2
    }
  }

  lifecycle {
    ignore_changes = [
      template[0].containers[0].image,
      template[0].labels,
      client,
      client_version
    ]
  }

  depends_on = [
    google_project_service.cloud_run_api,
    google_service_account.cloudrun_sa
  ]
}


resource "google_cloud_run_service_iam_member" "public_access" {
  location = google_cloud_run_v2_service.api_server.location
  project  = google_cloud_run_v2_service.api_server.project
  service  = google_cloud_run_v2_service.api_server.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

