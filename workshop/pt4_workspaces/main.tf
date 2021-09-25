resource "aws_s3_bucket" "test_bucket" {
  bucket = "test-bucket" // hint: you need different names for buckets, -${terraform.workspace}
}
