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
  description = "GitHub repo in owner/name format for the app deploy workflow (e.g. ketangit/fractal-cut)"
  type        = string
}

variable "infra_github_repo" {
  description = "GitHub repo in owner/name format for the infra tofu workflow (e.g. ketangit/tf-gcp-config)"
  type        = string
}

variable "state_bucket" {
  description = "Name of the GCS bucket used for OpenTofu state (must be created before tofu init)"
  type        = string
}
