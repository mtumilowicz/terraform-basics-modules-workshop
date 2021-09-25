provider "aws" {
  region                      = "us-east-1"
  access_key                  = "123"
  secret_key                  = "xyz"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  s3_force_path_style         = true
  endpoints {
    dynamodb = "http://localhost:4566"
    s3       = "http://localhost:4566"
    ec2      = "http://localhost:4566"
  }
}