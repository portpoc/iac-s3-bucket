variable "bucket_name" {
  type        = string
  description = "The name of the S3 data bucket. Must be globally unique across AWS."
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9\\-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "Bucket name must be 3-63 characters, lowercase letters, numbers, or hyphens, and cannot start or end with a hyphen."
  }
}

variable "environment" {
  type        = string
  description = "Deployment environment. Must be one of the DSV canonical environment names."
  validation {
    condition     = contains(["dev", "tst", "qua", "ppr", "prd"], var.environment)
    error_message = "Environment must be one of: dev, tst, qua, ppr, prd."
  }
}

variable "owner" {
  type        = string
  description = "Team or individual responsible for this bucket (DSV required tag: owner)."
}

variable "cost_center" {
  type        = string
  description = "Cost center code for billing (DSV required tag: cost-center)."
}

variable "region" {
  type        = string
  description = "AWS region where the bucket will be created. Must be a DSV-approved region."
  default     = "eu-west-1"
  validation {
    condition     = contains(["eu-west-1", "eu-central-1", "us-east-1", "us-west-2"], var.region)
    error_message = "Region must be one of the DSV-approved regions: eu-west-1, eu-central-1, us-east-1, us-west-2."
  }
}
