output "data_bucket_id" {
  description = "The name (ID) of the S3 data bucket."
  value       = aws_s3_bucket.data.id
}

output "data_bucket_arn" {
  description = "The ARN of the S3 data bucket."
  value       = aws_s3_bucket.data.arn
}

output "data_bucket_region" {
  description = "The AWS region the data bucket was created in."
  value       = aws_s3_bucket.data.region
}

output "log_bucket_id" {
  description = "The name (ID) of the access-log bucket."
  value       = aws_s3_bucket.log.id
}

output "log_bucket_arn" {
  description = "The ARN of the access-log bucket."
  value       = aws_s3_bucket.log.arn
}
