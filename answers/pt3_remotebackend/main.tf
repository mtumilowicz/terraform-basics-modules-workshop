resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state"

  lifecycle { prevent_destroy = true }
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "terraform-lock"
  read_capacity  = 0
  write_capacity = 0
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
