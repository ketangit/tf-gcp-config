# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

OpenTofu configuration that provisions GCP infrastructure for the `fractal-cut` app: Artifact Registry, Workload Identity Federation, and IAM for the `ketangit/fractal-cut` GitHub Actions deploy pipeline. All resources live under `infra/`.

## Commands

```bash
# Always pass bucket at init time — it cannot be a variable in backend config
cd infra && tofu init -backend-config="bucket=BUCKET_NAME"

tofu validate
tofu fmt            # format all .tf files
tofu fmt -check     # check only, no writes (used in CI)
tofu plan           # requires terraform.tfvars to be present locally
tofu apply
tofu output         # print the three GitHub secret values after apply
```

## Key gotchas

- **`terraform.tfvars` is gitignored** — must be present locally with `project_id`, `github_repo`, and `state_bucket` before plan/apply will work.
- **State bucket is not managed by tofu** — it must be created with `gcloud storage buckets create` before `tofu init` (circular dependency). See `gcp-bootstrap.md`.
- **`google-beta` provider is required** for `google_artifact_registry_repository` — the cleanup_policies block is beta-only. Always use `provider = google-beta` on that resource.
- **API enablement must come first** — all resources that depend on a GCP API use `depends_on = [google_project_service.apis]`. Keep this pattern on new resources.

## CI behavior

- Push to `main` (paths: `infra/**`) → plan + apply
- PR → plan only (apply is gated by `if: github.ref == 'refs/heads/main' && github.event_name == 'push'`)
- `workflow_dispatch` is available for manual runs

## Branch convention

Use `feature/`, `fix/`, or `chore/` prefixes. All changes via PR — no direct pushes to main.
