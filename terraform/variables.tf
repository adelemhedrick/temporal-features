variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region"
  default     = "us-central1"
}

variable "service_account_email" {
  description = "Email of the service account to grant BigQuery dataset access"
  type        = string
}