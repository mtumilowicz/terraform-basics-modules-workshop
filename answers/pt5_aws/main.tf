provider "aws" {
  region = "us-east-1"
  access_key = "123"
  secret_key = "xyz"
  skip_credentials_validation = true
  skip_requesting_account_id = true
  skip_metadata_api_check = true
  s3_force_path_style = true
  endpoints {
    ec2            = "http://localhost:4566"
    s3             = "http://localhost:4566"
  }
}

resource "aws_s3_bucket" "test-bucket" {
  bucket = "demo-bucket-terraform"
  acl    = "public-read"

  tags = {
    Name = "S3Bucket"
  }
}

resource "aws_instance" "test-instance" {
  ami           = "ami-0d57c0143330e1fa7"
  instance_type = "t2.micro"

  tags = {
    Name = "HelloWorld"
  }
}
