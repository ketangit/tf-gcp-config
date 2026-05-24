resource "google_artifact_registry_repository" "puzzle" {
  provider = google-beta

  project       = var.project_id
  location      = var.region
  repository_id = "puzzle"
  format        = "DOCKER"
  description   = "Docker images for fractal-cut services"

  cleanup_policy_dry_run = false

  cleanup_policies {
    id     = "keep-tagged-10"
    action = "KEEP"
    most_recent_versions {
      keep_count = 3
    }
  }

  cleanup_policies {
    id     = "delete-untagged-7d"
    action = "DELETE"
    condition {
      tag_state  = "UNTAGGED"
      older_than = "604800s" # 7 days
    }
  }

  depends_on = [google_project_service.apis]
}

resource "google_artifact_registry_repository_iam_member" "deployer_writer" {
  project    = var.project_id
  location   = var.region
  repository = google_artifact_registry_repository.puzzle.name
  role       = "roles/artifactregistry.writer"
  member     = "serviceAccount:${google_service_account.deployer.email}"
}
