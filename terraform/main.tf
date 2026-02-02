provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {
  description = "The GCP Project ID"
  type        = string
}

variable "region" {
  description = "The region for the bucket"
  type        = string
  default     = "us-central1"
}

variable "bucket_name_prefix" {
  description = "Prefix for the log bucket name"
  type        = string
  default     = "app-logs"
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "google_storage_bucket" "log_bucket" {
  name          = "${var.bucket_name_prefix}-${random_id.bucket_suffix.hex}"
  project       = var.project_id
  location      = var.region
  force_destroy = false # Set to true only if you want to allow deletion of non-empty buckets

  uniform_bucket_level_access = true

  lifecycle {
    prevent_destroy = true # Safety feature
  }

  labels = {
    env  = "logs"
    iac  = "terraform"
  }
}

output "bucket_name" {
  value = google_storage_bucket.log_bucket.name
}

output "bucket_url" {
  value = google_storage_bucket.log_bucket.url
}
terraform {
  backend "gcs" {
    bucket = "devops-agent-logs-08122b60"
    prefix = "terraform/state"
  }
}

