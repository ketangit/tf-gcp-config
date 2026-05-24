# GCP Bootstrap

One-time setup to provision the infrastructure that `fractal-cut`'s CI/CD pipeline depends on.

## Prerequisites

- `gcloud` CLI authenticated (`gcloud auth login && gcloud auth application-default login`)
- `tofu` installed (`brew install opentofu` or [opentofu.org](https://opentofu.org/docs/intro/install/))
- A GCP project already created with billing enabled:
  ```bash
  gcloud billing accounts list
  gcloud billing projects link YOUR_PROJECT_ID \
    --billing-account=XXXXXX-XXXXXX-XXXXXX
  ```

## 1. Create the state bucket

OpenTofu state must live somewhere before OpenTofu itself can run, so create the bucket manually:

```bash
gcloud storage buckets create gs://YOUR-BUCKET-NAME \
  --project=YOUR_PROJECT_ID \
  --location=us-east4 \
  --uniform-bucket-level-access \
  --public-access-prevention
```

Pick a name like `YOUR_PROJECT_ID-tfstate`. Bucket names are globally unique.

## 2. Create terraform.tfvars

Create `infra/terraform.tfvars` (already gitignored):

```hcl
project_id   = "YOUR_PROJECT_ID"
github_repo  = "ketangit/fractal-cut"
state_bucket = "YOUR-BUCKET-NAME"
```

## 3. Init, plan, apply

```bash
cd infra
tofu init -backend-config="bucket=YOUR-BUCKET-NAME"
tofu plan
tofu apply
```

Expect ~12 resources created: 6 API enablements, 1 Artifact Registry repo, 1 service account, 2 IAM bindings, 1 WIF pool, 1 WIF provider, 1 SA IAM binding.

## 4. Copy outputs to GitHub secrets

```bash
tofu output
```

Go to **fractal-cut → Settings → Secrets and variables → Actions** and create:

| Secret name | Value |
|---|---|
| `GCP_PROJECT_ID` | `tofu output -raw project_id` |
| `GCP_WORKLOAD_IDENTITY_PROVIDER` | `tofu output -raw workload_identity_provider` |
| `GCP_SERVICE_ACCOUNT` | `tofu output -raw service_account_email` |

## 5. Configure the tofu.yml workflow (this repo)

In **tf-gcp-config → Settings → Secrets and variables → Actions** add:

| Name | Kind | Value |
|---|---|---|
| `GCP_WORKLOAD_IDENTITY_PROVIDER` | Secret | same as above |
| `GCP_SERVICE_ACCOUNT` | Secret | same as above |
| `GCP_PROJECT_ID` | Secret | same as above |
| `TF_STATE_BUCKET` | Secret | `YOUR-BUCKET-NAME` |
| `TARGET_GITHUB_REPO` | Variable | `ketangit/fractal-cut` |

After this, pushes to `main` that touch `infra/**` will plan and auto-apply via the `opentofu/setup-opentofu@v1` workflow.

## Re-running after changes

```bash
cd infra
tofu plan   # review diff
tofu apply  # or just push to main and let CI do it
```

## Teardown

```bash
cd infra
tofu destroy
# then delete the state bucket manually:
gcloud storage rm -r gs://YOUR-BUCKET-NAME
```
