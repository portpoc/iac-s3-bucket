# iac-s3-bucket

A reusable Terraform module that provisions a **secure, DSV-compliant AWS S3 bucket** with server-access logging, versioning, AES-256 encryption, and full public-access blocking.

---

## Overview

This module creates **two S3 buckets**:

| Bucket | Purpose |
|--------|---------|
| `<bucket_name>` | Primary data bucket with versioning & encryption |
| `<bucket_name>-logs` | Companion access-log bucket (AES-256 encrypted, no versioning) |

All resources are tagged according to DSV standards and managed exclusively via Terraform.

---

## Features

- 🔒 **Public access fully blocked** on both buckets
- 🔐 **AES-256 server-side encryption** (SSE-S3) with bucket key enabled
- 📜 **Versioning enabled** on the data bucket
- 📂 **Server-access logging** from the data bucket into the companion log bucket
- 🏷️ **DSV mandatory tags**: `owner`, `cost-center`, `environment`, `data-classification`, `managed-by`
- 🚀 **CI/CD ready** — plan on PR, apply on merge via GitHub Actions (OIDC, no long-lived credentials)

---

## Usage

```hcl
module "s3_bucket" {
  source = "./modules/aws-s3-bucket"

  bucket_name = "my-app-data-dev"
  environment = "dev"
  owner       = "platform-team"
  cost_center = "CC-1234"
  region      = "eu-west-1"
}
```

---

## Requirements

| Name | Version |
|------|---------|
| terraform | `>= 1.5.0` |
| aws | `~> 5.0` |

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `bucket_name` | Globally unique S3 bucket name (3–63 chars, lowercase, hyphens allowed, cannot start/end with hyphen) | `string` | — | ✅ |
| `environment` | Deployment environment. One of: `dev`, `tst`, `qua`, `ppr`, `prd` | `string` | — | ✅ |
| `owner` | Team or individual responsible for this bucket (DSV tag: `owner`) | `string` | — | ✅ |
| `cost_center` | Cost center code for billing (DSV tag: `cost-center`) | `string` | — | ✅ |
| `region` | AWS region. One of: `eu-west-1`, `eu-central-1`, `us-east-1`, `us-west-2` | `string` | `eu-west-1` | ❌ |

---

## Outputs

| Name | Description |
|------|-------------|
| `data_bucket_id` | Name (ID) of the data S3 bucket |
| `data_bucket_arn` | ARN of the data S3 bucket |
| `data_bucket_region` | AWS region the data bucket was created in |
| `log_bucket_id` | Name (ID) of the access-log bucket |
| `log_bucket_arn` | ARN of the access-log bucket |

---

## Repository Structure

```
iac-s3-bucket/
├── .github/
│   └── workflows/
│       ├── plan.yml       # Triggered on pull requests — runs terraform plan
│       └── apply.yml      # Triggered on merge to main — runs terraform apply
├── modules/
│   └── aws-s3-bucket/
│       ├── main.tf        # S3 data & log bucket resources
│       ├── variables.tf   # Input variable definitions
│       ├── outputs.tf     # Output value definitions
│       ├── versions.tf    # Provider & Terraform version constraints
│       └── schema.json    # Variable schema contract for self-service actions
├── 01-requirements/       # Requirements analysis artifacts
├── 02-architecture/       # Architecture decision records (ADRs)
└── 03-pipeline-engineer/  # Pipeline engineering artifacts
```

---

## CI/CD

The pipeline uses **GitHub Actions with OIDC federation** — no long-lived AWS credentials are stored as secrets.

| Workflow | Trigger | Action |
|----------|---------|--------|
| `plan.yml` | Pull request | `terraform plan` — output posted as PR comment |
| `apply.yml` | Merge to `main` (or `workflow_dispatch`) | `terraform apply` — provisions resources |

---

## Security & Compliance

- All public access is blocked at the bucket and account policy level
- Server-side encryption (AES-256 / SSE-S3) is enforced on both buckets
- Access logs are scoped to the source bucket ARN — no wildcard principals
- Log bucket uses `BucketOwnerPreferred` ownership so the DSV account retains ownership of all log objects
- Log bucket versioning is intentionally omitted (append-only logs; versioning would double storage cost with no operational benefit — accepted deviation per security audit)

---

## DSV Approved Regions

| Region | Location |
|--------|----------|
| `eu-west-1` | Ireland (default) |
| `eu-central-1` | Frankfurt |
| `us-east-1` | N. Virginia |
| `us-west-2` | Oregon |

---

## Contributing

1. Fork the repo and create a feature branch
2. Run `terraform fmt` and `terraform validate` before committing
3. Open a PR — the `plan.yml` workflow will comment with the plan output
4. Request review from the owning team
5. Merge to `main` to trigger `apply.yml`
