# Architecture Decision Records — DSV AWS S3 Bucket Module

## ADR-1: Two-Bucket Pattern (Data + Log)

### Context
Access logging must be enabled per requirements. The logging target must be a separate bucket to avoid circular dependencies and to prevent log data from being co-mingled with application data.

### Options Considered
- **A) Single bucket** — self-logging. Not supported by AWS (circular reference).
- **B) Two buckets** — separate data bucket and dedicated log bucket co-provisioned by the same module.
- **C) External log bucket** — caller provides an existing bucket ARN. Increases coupling; the module cannot guarantee the log bucket exists.

### Decision
Option B: Two buckets co-provisioned in the same module call.

### Consequences
- Log bucket is always present and consistently configured when the data bucket is created.
- Slightly higher resource count (10 resources vs 5), but all within a single `terraform apply`.
- Log bucket has no versioning (append-only logs; versioning would double storage cost with no operational benefit — see MEDIUM finding in security audit).

---

## ADR-2: Block All Public Access Unconditionally

### Context
Data classification is `internal`. DSV baseline requires no public S3 endpoints for internal data.

### Options Considered
- **A) Hardcoded block** — all four `aws_s3_bucket_public_access_block` settings hardcoded to `true`, no variable.
- **B) Configurable** — a variable lets callers choose. Risk: a misconfigured call exposes internal data.

### Decision
Option A: All four `aws_s3_bucket_public_access_block` settings hardcoded to `true`.

### Consequences
- Eliminates the blast radius of an operator accidentally setting `public=true`.
- Any future requirement for a public bucket must use a different module.

---

## ADR-3: SSE-S3 (AES-256) Over SSE-KMS

### Context
Encryption at rest is required. Two options exist: AWS-managed keys (SSE-S3, free) vs customer-managed keys (SSE-KMS, requires KMS key management and adds per-request cost).

### Options Considered
- **A) SSE-S3 (AES-256)** — managed by AWS, zero additional cost.
- **B) SSE-KMS** — customer-managed key, additional KMS API cost (~$0.03/10k requests), requires key provisioning.

### Decision
Option A: SSE-S3 with AES-256. Internal classification does not require a customer-managed key.

### Consequences
- Zero additional encryption cost.
- AWS manages key rotation automatically.
- If data classification is upgraded to `confidential` or `restricted` in future, this module must be updated to use SSE-KMS.

---

## ADR-4: Versioning Always Enabled

### Context
Versioning protects against accidental deletion and overwrites. It was explicitly required.

### Options Considered
- **A) Always enabled** — hardcoded, no variable.
- **B) Optional (default on)** — a variable allows callers to disable.

### Decision
Option A: Always enabled. The requirements stated "always enabled" explicitly.

### Consequences
- Storage costs increase over time as older object versions accumulate. Callers should configure S3 Lifecycle rules independently if storage cost is a concern.
- No risk of accidentally deploying a bucket without versioning.

---

## ADR-5: Log Bucket Co-Provisioned in Same Module Call

### Context
The log bucket must exist before the data bucket can enable logging. It must be consistently configured.

### Options Considered
- **A) Co-provisioned** — both buckets in the same module, dependency managed by Terraform.
- **B) Pre-existing** — caller passes a log bucket ARN/name. Decouples resources but requires manual setup.

### Decision
Option A: Co-provisioned. The module guarantees the log bucket exists and is correctly configured every time.

### Consequences
- Destroying the module destroys both buckets. Callers must ensure log data is retained if needed before `terraform destroy`.
- Simpler caller interface — only the data bucket name is required.
