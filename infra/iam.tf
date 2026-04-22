resource "google_service_account" "cloudrun_sa" {
  account_id   = var.service_name
  display_name = "Cloud Run Service Account for SRE Portfolio"
  depends_on = [google_project_service.services]
}

resource "google_project_iam_member" "firestore_user" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.cloudrun_sa.email}"
}

data "google_project" "project" {
  project_id = var.project_id
}

resource "google_project_iam_member" "default_cloudbuild_roles" {
  for_each = toset([
    "roles/container.developer",
    "roles/iam.serviceAccountUser",
    "roles/cloudbuild.builds.builder",
    "roles/logging.logWriter",
    "roles/artifactregistry.admin",
    "roles/storage.admin",
    "roles/run.admin"
  ])
  project    = var.project_id
  role       = each.key
  member = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  depends_on = [google_project_service.services]
}




