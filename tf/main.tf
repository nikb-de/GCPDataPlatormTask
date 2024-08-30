provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_pubsub_topic" "user_offers" {
  name = "user_offers"
}

resource "google_pubsub_topic" "offer_tasks" {
  name = "offer_tasks"
}

variable "project_id" {
  description = "The ID of the GCP project"
}

variable "region" {
  description = "The GCP region"
  default = "europe-west10"
}




