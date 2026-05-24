output "workload_identity_provider" {
  description = "→ GitHub secret GCP_WORKLOAD_IDENTITY_PROVIDER"
  value       = google_iam_workload_identity_pool_provider.github.name
}

output "service_account_email" {
  description = "→ GitHub secret GCP_SERVICE_ACCOUNT"
  value       = google_service_account.deployer.email
}

output "project_id" {
  description = "→ GitHub secret GCP_PROJECT_ID"
  value       = var.project_id
}

output "state_bucket" {
  description = "GCS bucket holding OpenTofu state"
  value       = var.state_bucket
}
