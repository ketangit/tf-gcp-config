# tf-gcp-config

OpenTofu configuration that provisions the GCP infrastructure backing the [`fractal-cut`](https://github.com/ketangit/fractal-cut) CI/CD pipeline.

## What this provisions

| Resource | Details |
|---|---|
| Artifact Registry | `puzzle` Docker repo in `us-east4` with a cleanup policy (keep 3 tagged, delete untagged after 7 days) |
| Service account | `puzzle-deployer` with `roles/run.admin` and `roles/artifactregistry.writer` |
| Workload Identity Federation | GitHub OIDC pool + provider, scoped to `ketangit/fractal-cut` |
| GCP APIs | Cloud Run, Artifact Registry, IAM, IAM Credentials, STS, Resource Manager |

The Cloud Run services (`puzzle-backend`, `puzzle-frontend`) are **not** managed here — they are created by the `fractal-cut` deploy workflow on first push.

## First-time setup

See [`gcp-bootstrap.md`](./gcp-bootstrap.md) for the full walkthrough. The short version:

```bash
# 1. Create the state bucket (one-time, outside OpenTofu)
gcloud storage buckets create gs://YOUR-BUCKET-NAME \
  --project=YOUR_PROJECT_ID \
  --location=us-east4 \
  --uniform-bucket-level-access \
  --public-access-prevention

# 2. Create infra/terraform.tfvars (gitignored)
cat > infra/terraform.tfvars <<EOF
project_id   = "YOUR_PROJECT_ID"
github_repo  = "ketangit/fractal-cut"
state_bucket = "YOUR-BUCKET-NAME"
EOF

# 3. Apply
cd infra
tofu init -backend-config="bucket=YOUR-BUCKET-NAME"
tofu apply
```

## GitHub secrets (fractal-cut repo)

After `tofu apply`, copy the outputs into **fractal-cut → Settings → Secrets → Actions**:

```bash
tofu output workload_identity_provider  # → GCP_WORKLOAD_IDENTITY_PROVIDER
tofu output service_account_email       # → GCP_SERVICE_ACCOUNT
tofu output project_id                  # → GCP_PROJECT_ID
```

## Ongoing changes

Push to `main` via PR. The `tofu.yml` workflow plans on PRs and applies on merge.

```
feature/* | fix/* | chore/*  →  PR  →  main
```

Branch protection on `main` requires the `Plan / Apply` status check to pass and signed commits.

## Local commands

```bash
cd infra
tofu validate
tofu fmt
tofu plan
tofu apply
tofu output
tofu destroy   # full teardown
```

