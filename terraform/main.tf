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

variable "bucket_prefix" {
  description = "User-provided prefix for the temp bucket name"
  type        = string
  default     = "tf-agent-temp"
}

resource "random_id" "bucket_suffix" {
  byte_length = 4
}

resource "google_storage_bucket" "temp_bucket" {
  name          = "${var.bucket_prefix}-${random_id.bucket_suffix.hex}"
  project       = var.project_id
  location      = var.region
  force_destroy = true # Important for easy cleanup in a prototype

  uniform_bucket_level_access = true

  labels = {
    env        = "prototype"
    iac        = "terraform-agent"
    created-by = "iac-agent"
  }
}

output "bucket_name" {
  description = "The full name of the created temporary bucket"
  value       = google_storage_bucket.temp_bucket.name
}

output "bucket_url" {
  description = "The URL of the created temporary bucket"
  value       = google_storage_bucket.temp_bucket.url
}

terraform {
  backend "gcs" {
    bucket = "devops-agent-logs-08122b60" # Your existing backend bucket
    prefix = "terraform/state/temp_bucket_prototype" # Different prefix for isolation
  }
}
