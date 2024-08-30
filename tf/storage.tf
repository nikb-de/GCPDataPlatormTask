resource "google_storage_bucket" "offer_data_bucket" {
  location = "var.region"
  name     = "${var.project_id}-offer-data"
  force_destroy = true
}

