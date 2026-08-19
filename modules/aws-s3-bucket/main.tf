locals {
  common_tags = {
    owner               = var.owner
    cost-center         = var.cost_center
    environment         = var.environment
    data-classification = "internal"
    managed-by          = "terraform"
  }

  log_bucket_name = "${var.bucket_name}-logs"
}

# ---------------------------------------------------------------------------
# Log bucket — must exist before the data bucket enables server-access logging
# ---------------------------------------------------------------------------
resource "aws_s3_bucket" "log" {
  bucket = local.log_bucket_name
  tags   = local.common_tags
}

resource "aws_s3_bucket_public_access_block" "log" {
  bucket = aws_s3_bucket.log.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "log" {
  bucket = aws_s3_bucket.log.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# BucketOwnerPreferred: required so the S3 logging delivery principal
# can write log objects and the DSV account owns them.
resource "aws_s3_bucket_ownership_controls" "log" {
  bucket = aws_s3_bucket.log.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Allow the S3 logging service to deliver logs into the log bucket.
# Policy is scoped to the source bucket ARN — no wildcard principals.
resource "aws_s3_bucket_policy" "log" {
  bucket = aws_s3_bucket.log.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "S3ServerAccessLogsPolicy"
        Effect = "Allow"
        Principal = {
          Service = "logging.s3.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.log.arn}/*"
        Condition = {
          ArnLike = {
            "aws:SourceArn" = aws_s3_bucket.data.arn
          }
        }
      }
    ]
  })
}

# ---------------------------------------------------------------------------
# Data bucket
# ---------------------------------------------------------------------------
resource "aws_s3_bucket" "data" {
  bucket = var.bucket_name
  tags   = local.common_tags
}

resource "aws_s3_bucket_public_access_block" "data" {
  bucket = aws_s3_bucket.data.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_versioning" "data" {
  bucket = aws_s3_bucket.data.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "data" {
  bucket = aws_s3_bucket.data.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
    bucket_key_enabled = true
  }
}

# MEDIUM: Log bucket does not have versioning enabled.
# Rationale: access logs are append-only; enabling versioning would double
# log storage cost with no operational benefit. Non-blocking per security audit.
resource "aws_s3_bucket_logging" "data" {
  bucket        = aws_s3_bucket.data.id
  target_bucket = aws_s3_bucket.log.id
  target_prefix = "${var.bucket_name}/"

  depends_on = [
    aws_s3_bucket_policy.log,
    aws_s3_bucket_ownership_controls.log,
  ]
}
