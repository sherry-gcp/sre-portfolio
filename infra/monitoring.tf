resource "google_project_service" "monitoring_api" {
  project            = var.project_id
  service            = "monitoring.googleapis.com"
  disable_on_destroy = false
}

resource "google_monitoring_uptime_check_config" "https_check" {
  display_name = "SRE Portfolio API Health Check"
  timeout      = "60s"
  period       = "300s"

  selected_regions = [
    "USA",
    "EUROPE",
    "ASIA_PACIFIC"
  ]

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

  depends_on = [
    google_project_service.monitoring_api,
    google_cloud_run_service_iam_member.public_access
  ]
}

resource "google_monitoring_alert_policy" "uptime_alert" {
  display_name = "App is DOWN: SRE Portfolio"
  combiner     = "OR"
  conditions {
    display_name = "Uptime check failure"
    condition_threshold {
      filter          = "metric.type=\"monitoring.googleapis.com/uptime_check/check_passed\" AND resource.type=\"uptime_url\" AND metric.label.check_id=\"${google_monitoring_uptime_check_config.https_check.uptime_check_id}\""
      duration        = "600s"
      comparison      = "COMPARISON_GT"
      threshold_value = "1"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_FRACTION_TRUE"
      }
    }
  }

  documentation {
    content = "The Portfolio API is unreachable at ${google_cloud_run_v2_service.api_server.uri}. Check Cloud Run logs for errors."
  }
}
