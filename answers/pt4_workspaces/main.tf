resource "aws_s3_bucket" "test-bucket" {
  bucket = "demo-bucket-terraform-${terraform.workspace}"
}
