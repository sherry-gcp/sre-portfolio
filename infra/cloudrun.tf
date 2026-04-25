resource "google_project_service" "cloud_run_api" {
  project = var.project_id
  service = "run.googleapis.com"

  disable_on_destroy = false
}

resource "google_project_service" "monitoring_api" {
  project            = var.project_id
  service            = "monitoring.googleapis.com"
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
      max_instance_count = 1
    }
  }

  depends_on = [
    google_project_service.cloud_run_api
  ]
}


resource "google_cloud_run_service_iam_member" "public_access" {
  location = google_cloud_run_v2_service.api_server.location
  project  = google_cloud_run_v2_service.api_server.project
  service  = google_cloud_run_v2_service.api_server.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

resource "google_monitoring_uptime_check_config" "https_check" {
  display_name = "SRE Portfolio API Health Check"
  timeout      = "10s"
  period       = "60s"

  http_check {
    path         = "/health"
    port         = "443"
    use_ssl      = true
    validate_ssl = true
  }
  monitored_resource {
    type = "uptime_url"
    labels = {
      project_id = var.project_id
      host       = replace(google_cloud_run_v2_service.api_server.uri, "https://", "")
    }
  }

  depends_on = [google_project_service.monitoring_api]
}

resource "google_monitoring_alert_policy" "uptime_alert" {
  display_name = "App is DOWN: SRE Portfolio"
  combiner     = "OR"
  conditions {
    display_name = "Uptime check failure"
    condition_threshold {
      filter          = "metric.type=\"monitoring.googleapis.com/uptime_check/check_passed\" AND resource.type=\"uptime_url\" AND metric.label.check_id=\"${google_monitoring_uptime_check_config.https_check.uptime_check_id}\""
      duration        = "120s"
      comparison      = "COMPARISON_GT"
      threshold_value = "1"
      aggregations {
        alignment_period   = "60s"
        per_series_aligner = "ALIGN_FRACTION_TRUE"
      }
    }
  }
  documentation {
    content = "The Store Locator API is unreachable at ${google_cloud_run_v2_service.api_server.uri}. Please check Cloud Run logs."
  }
}
