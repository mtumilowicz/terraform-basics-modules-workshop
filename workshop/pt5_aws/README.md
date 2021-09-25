1. goal: create s3 bucket with tag: S3Bucket and ec2 instance with tag: EC2Instance
1. verify that resources were created
    * aws --endpoint-url=http://localhost:4566 s3 ls
    * aws --endpoint-url=http://localhost:4566 ec2 describe-instances