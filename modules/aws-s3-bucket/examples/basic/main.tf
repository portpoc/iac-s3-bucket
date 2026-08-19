provider "aws" {
  region = "eu-west-1"
}

module "s3_bucket" {
  source = "../../"

  bucket_name = "dsv-example-app-dev"
  environment = "dev"
  owner       = "platform-team"
  cost_center = "CC-1234"
  region      = "eu-west-1"
}

output "data_bucket_id" {
  value = module.s3_bucket.data_bucket_id
}

output "data_bucket_arn" {
  value = module.s3_bucket.data_bucket_arn
}
