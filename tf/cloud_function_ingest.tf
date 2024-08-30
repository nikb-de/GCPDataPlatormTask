resource "google_storage_bucket" "function_bucket" {
  name          = "${var.project_id}-function-source"
  location      = var.region
  force_destroy = true
}

resource "google_storage_bucket_object" "ingest_function_zip" {
  name   = "ingest_function.zip"
  bucket = google_storage_bucket.function_bucket.name
  source = "ingest_function.zip"  # Path to your zip file containing the function code
}

resource "google_cloudfunctions_function" "ingest_function" {
  name        = "offerIngestFunction"
  runtime     = "python310"
  entry_point = "ingest_offer_event"
  source_archive_bucket = google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.ingest_function_zip.name
  trigger_http = false

  event_trigger {
    event_type = "google.pubsub.topic.publish"
    resource   = google_pubsub_subscription.offer_subscription.id
  }

  environment_variables = {
    BUCKET_NAME = google_storage_bucket.offer_data_bucket.name
  }
}
