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
