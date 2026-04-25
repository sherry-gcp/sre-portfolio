resource "google_storage_bucket" "assets_bucket" {
  name                        = "portfolio-assets-${var.project_id}"
  location                    = var.region
  force_destroy               = true
  uniform_bucket_level_access = true

  cors {
    origin          = ["*"]
    method          = ["GET", "HEAD", "OPTIONS"]
    response_header = ["*"]
    max_age_seconds = 3600
  }
}

resource "google_storage_bucket_iam_member" "public_rule" {
  bucket = google_storage_bucket.assets_bucket.name
  role   = "roles/storage.objectViewer"
  member = "allUsers"
}
