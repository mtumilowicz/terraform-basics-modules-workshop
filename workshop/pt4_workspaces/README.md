1. goal: multi-region deployment
1. problem: you need to deploy s3 bucket in us-east-1 and us-west-2
1. naive solution: create two resources with aliased providers
    ```
    provider "aws" {
      alias  = "west"
      region = "us-west-2"
    }

    resource "aws_instance" "foo" {
      provider = aws.west

      # ...
    }
    ```
1. better solution: use workspaces per region
    * terraform workspace new us-east-1
    * terraform workspace new us-west-2
    * terraform workspace select us-east-1
    * terraform workspace select us-west-2
    * define region in provider as terraform.workspace
    * define suffix in resource as ${terraform.workspace}
    * apply in each workspace and verify that s3 buckets were created
        * aws --endpoint-url=http://localhost:4566 s3 ls