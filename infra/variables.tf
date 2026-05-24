variable "project_id" {
  description = "GCP project ID"
  type        = string
}

variable "region" {
  description = "GCP region for all resources"
  type        = string
  default     = "us-east4"
}

variable "github_repo" {
  description = "GitHub repo in owner/name format (e.g. ketangit/fractal-cut)"
  type        = string
}

variable "state_bucket" {
  description = "Name of the GCS bucket used for OpenTofu state (must be created before tofu init)"
  type        = string
}
