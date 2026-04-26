resource "google_service_account" "cloudrun_sa" {
  account_id   = var.service_name
  display_name = "Cloud Run Service Account for SRE Portfolio"
  depends_on   = [google_project_service.services]
}

resource "google_storage_bucket_iam_member" "api_storage_viewer" {
  bucket = google_storage_bucket.assets_bucket.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.cloudrun_sa.email}"
}

data "google_project" "project" {
  project_id = var.project_id
}


resource "google_service_account" "github_actions_sa" {
  account_id   = "github-actions-deployer"
  display_name = "GitHub Actions Deployment SA (Keyless)"
  depends_on   = [time_sleep.wait_for_services]
}

resource "google_project_iam_member" "github_actions_roles" {
  for_each = toset([
    "roles/run.developer",
    "roles/artifactregistry.writer",
    "roles/iam.serviceAccountUser"
  ])
  project = var.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"
}


resource "google_iam_workload_identity_pool" "github_pool" {
  workload_identity_pool_id = "github-pool"
  display_name              = "GitHub Identity Pool"
  description               = "Identity pool for GitHub Actions"
  depends_on                = [time_sleep.wait_for_services]
}

resource "google_iam_workload_identity_pool_provider" "github_provider" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"
  display_name                       = "GitHub Provider"

  attribute_mapping = {
    "google.subject"             = "assertion.sub"
    "attribute.actor"            = "assertion.actor"
    "attribute.repository"       = "assertion.repository"
    "attribute.repository_owner" = "assertion.repository_owner"
  }

  attribute_condition = "assertion.repository_owner == '${var.github_username}'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

resource "google_service_account_iam_member" "wif_sa_user" {
  service_account_id = google_service_account.github_actions_sa.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_pool.name}/attribute.repository/${var.github_username}/${var.github_repo_name}"
}
