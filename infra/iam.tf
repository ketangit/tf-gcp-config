resource "google_service_account" "deployer" {
  project      = var.project_id
  account_id   = "puzzle-deployer"
  display_name = "fractal-cut CI/CD deployer"

  depends_on = [google_project_service.apis]
}

resource "google_project_iam_member" "deployer_run_admin" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${google_service_account.deployer.email}"
}

# Roles required for tofu plan/apply from tf-gcp-config CI
resource "google_project_iam_member" "deployer_editor" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.deployer.email}"
}

resource "google_project_iam_member" "deployer_iam_security_admin" {
  project = var.project_id
  role    = "roles/iam.securityAdmin"
  member  = "serviceAccount:${google_service_account.deployer.email}"
}

resource "google_project_iam_member" "deployer_wif_admin" {
  project = var.project_id
  role    = "roles/iam.workloadIdentityPoolAdmin"
  member  = "serviceAccount:${google_service_account.deployer.email}"
}

resource "google_project_iam_member" "deployer_project_iam_admin" {
  project = var.project_id
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = "serviceAccount:${google_service_account.deployer.email}"
}
