resource "google_firestore_database" "database" {
  name            = var.firestore_name
  project         = var.project_id
  location_id     = var.region
  type            = "FIRESTORE_NATIVE"
  deletion_policy = "DELETE"
  depends_on      = [time_sleep.wait_for_services]
}
