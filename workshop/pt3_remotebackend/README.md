1. goal: set up remote state with locking
1. first, we need to create s3 bucket and dynamodb for locking
    * comment `backend.tf` then init and apply
    * verify that s3 bucket is created
        * aws --endpoint-url=http://localhost:4566 s3 ls
    * verify that s3 bucket is empty
        * aws --endpoint-url=http://localhost:4566 s3 ls s3://terraform-state
1. if we have our infrastructure ready, define remote backend
    * uncomment `backend.tf` then init and apply
    * verify that remote state exists
        * aws --endpoint-url=http://localhost:4566 s3 ls s3://terraform-state/dev/
    * stdout the content of remote state
        * aws --endpoint-url=http://localhost:4566 s3 cp s3://terraform-state/dev/terraform.tfstate -
1. verify locking is working
    * from two consoles start `terraform apply -auto-approve` and verify that one fails
