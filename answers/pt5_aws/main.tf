resource "aws_s3_bucket" "test_s3" {
  bucket = "test-bucket"

  tags = {
    Name = "S3Bucket"
  }
}

resource "aws_instance" "test_ec2" {
  ami           = "ami-0d57c0143330e1fa7"
  instance_type = "t2.micro"

  tags = {
    Name = "EC2Instance"
  }
}
