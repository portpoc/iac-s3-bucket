# Validation Report — modules/aws-s3-bucket v0.1.0

Generated: 2026-08-19T00:00:00Z

---

## Step 2a — Structural & Functional Validation (iac-validator-tester)

| Check | Result |
|-------|--------|
| `terraform fmt -check` | ✅ PASS |
| `tflint` | ✅ PASS |
| `terraform validate` | ✅ PASS |
| `terraform plan` (examples/basic) | ✅ PASS — 10 resources planned |
| Test: versioning=Enabled | ✅ PASS |
| Test: all public_access_block=true | ✅ PASS |
| Test: sse_algorithm=AES256 on both buckets | ✅ PASS |
| Test: logging target_bucket set correctly | ✅ PASS |
| Test: log bucket policy scoped to source ARN | ✅ PASS |

**Tests run: 5 / Tests passed: 5 / Errors: 0**

---

## Step 2b — Security & Compliance Audit (iac-security-compliance-auditor)

| Rule | Description | Result |
|------|-------------|--------|
| SEC-01 | Public access blocked — data bucket | ✅ PASS |
| SEC-01 | Public access blocked — log bucket | ✅ PASS |
| SEC-02 | SSE-S3 encryption — data bucket | ✅ PASS |
| SEC-02 | SSE-S3 encryption — log bucket | ✅ PASS |
| SEC-03 | No wildcard/public bucket policy | ✅ PASS |
| SEC-04 | Versioning enabled — data bucket | ✅ PASS |
| SEC-05 | Access logging configured | ✅ PASS |
| SEC-06 | Log bucket policy scoped to source bucket ARN | ✅ PASS |
| SEC-07 | DSV required tags on all resources | ✅ PASS |
| SEC-08 | data-classification=internal enforced | ✅ PASS |
| MEDIUM | Log bucket has no versioning | ⚠️ MEDIUM — documented in main.tf. Access logs are append-only; enabling versioning would double log storage cost with no operational benefit. Non-blocking. |

**Rules checked: 11 / HIGH findings: 0 / CRITICAL findings: 0 / MEDIUM (documented): 1**

Verdict: ✅ **PASS** — zero blocking findings.

---

## Step 2c — Cost Estimation (iac-cost-estimator)

Tool: Infracost | Plan: examples/basic/main.tf | Date: 2026-08-19

| Resource | Monthly Base | Worst-case (100 GB) |
|----------|-------------|---------------------|
| Data bucket (storage @ $0.023/GB) | $0.00 | ~$2.30 |
| Log bucket (storage @ $0.023/GB) | $0.00 | ~$2.30 |
| S3 API requests (estimated) | $0.00 | ~$0.50 |
| **Total** | **$0.00** | **~$5.10** |

`autoscaler_worst_case_monthly`: N/A (no compute resources)
Currency: USD
Threshold: €500/month

**Verdict: ✅ PASS** — estimated cost is well below the €500/month threshold. No `# COST-REVIEW` flags required.
