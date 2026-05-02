output "service_url" {
  value = google_cloud_run_v2_service.api_server.uri
}

output "workload_identity_provider" {
  value       = "projects/${data.google_project.project.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github_pool.workload_identity_pool_id}/providers/${google_iam_workload_identity_pool_provider.github_provider.workload_identity_pool_provider_id}"
  description = "The Workload Identity Provider ID for GitHub Actions"
}

output "heartbeat_url" {
  value = var.heartbeat_url
}
