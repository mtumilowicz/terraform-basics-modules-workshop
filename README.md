# terraform-workshop
* references
    * https://discuss.hashicorp.com/t/terraform-0-14-the-dependency-lock-file/15696
    * https://medium.com/@business_99069/terraform-count-vs-for-each-b7ada2c0b186
    * https://hub.docker.com/r/danjellz/http-server
    * https://discuss.hashicorp.com/t/validate-list-object-variables/18291/2
    * https://github.com/morethancertified/mtc-terraform
    * https://github.com/edgar-anascimento/terraform-localstack-setup
    * [[#122​] Terraform i AWS - odtwarzalna infrastruktura w 10 minut - Maciej Rostański](https://www.youtube.com/watch?v=87wIafVYK9I)
    * [When Terraform alone isn't enough - Marcin Żbik](https://www.youtube.com/watch?v=nR1U9sdcR3k)
    * [Version-Controlled Infrastructure with GitHub & Terraform with Seth Vargo](https://www.youtube.com/watch?v=2TWqi7dLSro)
    * [[#128​] Infrastructure as a Code - AWS + Terraform + Ansible - Daniel Kossakowski](https://www.youtube.com/watch?v=BSHpZcy-BAo)
    * [DevOps Crash Course (Docker, Terraform, and Github Actions)](https://www.youtube.com/watch?v=OXE2a8dqIAI)
    * [Terraform Course - Automate your AWS cloud infrastructure](https://www.youtube.com/watch?v=SLB_c_ayRMo)
    * [Terraform for AWS - Beginner to Expert 2021 (0.12)](https://www.udemy.com/course/terraform-fast-track)
    * [Learn DevOps: Infrastructure Automation With Terraform](https://www.udemy.com/course/learn-devops-infrastructure-automation-with-terraform)
    * [More than Certified in Terraform](https://www.udemy.com/course/terraform-certified/)
    * [Terraform in Action](https://www.manning.com/books/terraform-in-action)
    * https://www.packer.io/intro
    * https://www.terraform.io/docs
    * https://acloudguru.com/hands-on-labs/exploring-terraform-state-functionality
    * https://www.andreagrandi.it/2017/08/25/getting-latest-ubuntu-ami-with-terraform/
    * https://learn.hashicorp.com/tutorials/terraform
    * https://pilotcoresystems.com/insights/what-are-terraform-workspaces
    * https://medium.com/@diogok/terraform-workspaces-and-locals-for-environment-separation-a5b88dd516f5
    * https://shanidgafur.github.io/blog/terraform-workspaces-for-multi-region-deployment

## preface
* goals of this workshops
    * introduction to infrastructure as a code
    * introduction to terraform
        * provider, resources, data, variables, outputs
        * for_each, count
        * modules
        * remote backends and workspaces
        * aws with localstack
        * secrets management
* plan for the workshop
    * follow the hints from appropriate directories:
        1. pt1_basics
        1. pt2_modules
        1. pt3_remotebackend
        1. pt4_workspaces
        1. pt5_aws

## infrastructure as a code
* is the process of managing and provisioning infrastructure through definition files
* what is infrastructure?
    * anything that could be controlled through an API
    * usually: cloud-based infrastructure
* infrastructure provisioning vs configuration management
    * inherently different problems
    * provisioning = deploying infrastructure
        * Terraform favors immutable infrastructure
        * immutable infrastructure = infrastructure as a disposable commodity
    * configuration management = application delivery on virtual machines (VMs)
        * CM tools favor mutable infrastructure
            * mutable infrastructure = updates on existing servers
* terraform vs packer vs ainsible
    * terraform
        * automates provisioning of the infrastructure
        * makes your infrastructure auditable
            * keep your infrastructure change history in git
        * cloud agnostic
            * integrates with different clouds through providers (plugins)
        * a state management tool that performs CRUD operations on managed resources
            * anything that can be represented as CRUD can be managed as a Terraform resource
            * uses the same APIs you would use if you were writing an automation script
                * difference: not only deployment but also infrastructure management
            * understands dependencies between resources
            * can even detect and correct for configuration drift
        * is a simple state management engine
    * packer
        * example: build AWS AMIs based on templates
        * instead of installing the software after booting up an instance, you
        can create an AMI with all the necessary software on from a machine image
            * machine image is a single static unit that contains a pre-configured operating system
            and installed software which is used to quickly create new running machines
        * speed up boot times of instances
        * common approach when you run a horizontally scaled app layer or a cluster
* ainsible
    * install software after the infrastructure is provisioned
    * has a focus on automating the installation and configuration of software
    * example: security updates

## introduction

### terraform structure
* terraform is separated into 3 separate parts
    * core
        * reading and interpolating configuration files and modules
        * resource state management
        * construction of the Resource Graph (DAG)
        * plan execution
        * communication with plugins over RPC
        * contains language interpreter, the CLI and how to interact with providers
            * doesn't contain the code to interact with the API of the cloud providers to create resources
            * that code is in providers, which be installed separately when invoking "terraform init"
    * plugins (providers and provisioners)
        * exposes an implementation for a specific service, such as AWS, or provisioner, such as bash
        * executed as a separate process and communicate with the main Terraform binary over an RPC interface
        * providers
            * define Resources that map to specific Services
            * authentication with the Infrastructure Provider
        * provisioners
            * executing commands or scripts on the designated Resource after creation, or on destruction
    * upstream
          * terraform does not create resources - it makes the cloud api to create it
              * api (aws api, google cloud api, github api, ...)

### project structure
* `.terraform`
    * binary of the provider (initialized with during `terraform init`)
* `terraform.lock.hcl`
    * provider dependency lockfile
        * providers (plugins for Terraform that extend it with support for interacting with various external systems)
              Both of these dependency types can be published and updated independently from Terraform itself and from the
              configurations that depend on them.
              For that reason, Terraform must determine which versions of those dependencies are potentially compatible with
              the current configuration and which versions are currently selected for use.
    * created when `terraform init`
    * tracks versions of providers and modules
    * should be committed to git
    * re-runs of terraform will use the same provider/module versions
        * for example when terraform is ran by other members of your team or using automation
* `*.tf` files
    * configuration files are stored in plain text files with the `.tf` file extension
    * terraform concatenates all `.tf` files together (the context is a module - explained below)
* `*.tfvars` files
    * values assignments to variables
* `terraform.tfstate`
    * is the state file that Terraform uses to keep track of the resources it manages
        * used to perform diffs during the plan and detect configuration drift
    * example
        ```
        {
          "version": 4,
          "terraform_version": "1.0.5",
          "serial": 10, // monotonically increasing with every apply and destroy
          "lineage": "d7fe6d32-593e-60c6-52f2-dff37b956408", // unique ID assigned to a state when it is created
          "outputs": {}, // outputs from last apply
          "resources": []
        }
        ```
        * "lineage" and "serial" matters only during validation when `terraform state push` (push the state specified
        to the currently configured backend)
    * what happens when removed?
        * it is not recreate automatically
        * use `terraform import` to manually recreate it
    * it’s important not to edit, delete, or Terraform could potentially lose track of the resources it manages
* `terraform.tfstate.backup`
    * terraform leaves behind a `terraform.tfstate.backup` file in case you need to recover to the last deployed
    state
* module directories
    * module is a collection of `.tf` files kept together in a directory
        * nested directories are treated as completely separate modules, and are not automatically included in
        the configuration
    * root module = main directory
    * terraform evaluates all of the configuration files in a module, effectively treating the entire module
    as a single document
        * separating various blocks into different files is purely for the convenience of readers and has
        no effect on the module's behavior

### language
* providers
    * interact with cloud providers
    * each provider adds a set of resource types and/or data sources that Terraform can manage
    * example: AWS provider
* resources
    * describe one or more infrastructure objects
    * example: ec2, vpc, database
    * have inputs and outputs
        * inputs are called arguments
        * outputs are called attributes
        * arguments are passed through the resource and are also available as attributes
        * there are also computed attributes that are only available after the creation
            * example: AWS `arn:partition:service:region:account-id:resource-type:resource-id`
    * implement the resource schema interface
        * schema mandates, above all, definitions of CRUD functions hooks
        * Terraform invokes these hooks when certain conditions are met
            * example
                * `Create()` is called during resource creation
                * `Read()` during plan generation
* variables
    * variables should be validated
        * example - usualy internal ports are fixed
            ```
            variable "internal_port" {
              type    = number
              default = 8080

              validation {
                condition     = var.internal_port == 8080
                error_message = "The internal port must be 8080."
              }
            }
            ```
    * declare variables in `.tfvars`
        * terraform also automatically loads variable definitions if:
            * named exactly `terraform.tfvars`
            * names ending in `.auto.tfvars`
        * otherwise append `--var-file prod.tfvars` to the terraform command
            * example: `terraform apply --var-file prod.tfvars`
    * three types
        * input
        * output
            * pass values between modules
            * print values to the CLI
        * local
            * like temporary variables
            * used for calculations, concatenations, conditionals
            * example
                ```
                locals {
                  name_suffix = "${var.resource_tags["project"]}-${var.resource_tags["environment"]}"
                }
                 module "vpc" {
                   source  = "terraform-aws-modules/vpc/aws"
                   version = "2.66.0"

                   name = "vpc-${local.name_suffix}" // instead of "vpc-${var.resource_tags["project"]}-${var.resource_tags["environment"]}"
                   ...
                 }
                ```
* datasources
    * allow data to be fetched from outside of the terraform
    * example
        ```
        data "aws_ami" "ubuntu" {
            most_recent = true

            filter {
                name   = "name"
                values = ["ubuntu/images/hvm-ssd/ubuntu-xenial-16.04-amd64-server-*"]
            }

            filter {
                name   = "virtualization-type"
                values = ["hvm"]
            }

            owners = ["099720109477"] # Canonical
        }

        resource "aws_instance" "web" {
            ami           = "${data.aws_ami.ubuntu.id}"
            instance_type = "t2.micro"

            tags {
                Name = "HelloUbuntu"
            }
        }
        ```
* provisioners VM
    * resource provisioners are essentially backdoors to the Terraform runtime
    * provisioners can execute arbitrary code on either a local or remote machine as part of resource
    creation or destruction
    * used for various tasks, such as bootstrapping, copying files
    * call external scripts, there is an implicit dependency on the OS interpreter
    * should be used only as a method of last resort
    * are an anti-pattern, and they may even be deprecated in a newer version of Terraform
        * example
            * sometimes resources are marked "created" and it takes a few more seconds before they are truly ready
                * don't: insert delays with the local-exec provisioner
                * do: `resource "time_sleep"` and `depends_on = [time_sleep.wait_30_seconds]`
    * types
        * local-provisioner (execute something locally after spinning up a VM)
        * remote-provisioner (execute something remote on the VM)

## standard operations
* `terraform init`
    * reads configuration files in the working directory to determine which plugins are necessary
    * install plugins if needed
        * if any versions that meets the constraint are installed -> chooses newest one
        * otherwise -> downloads the newest acceptable from the Terraform Registry and saves it in a subdirectory
        under `.terraform/providers/`
        * otherwise -> initialization fails and the user must manually install an appropriate version
    * writes a lock file
* `terraform plan`
    * informs you about what Terraform intends to do, letting you know about any syntax or dependency errors
    * always run plan before deploying
    * algorithm
        1. refresh state
        1. read configuration
        1. read state
        1. resource in state?
            * YES -> `Read()`
                1. has changes?
                    * Yes -> is destroy plan?
                        * Yes -> `Delete()`
                        * No -> `Update()`
                    * No -> `No-op`
            * NO - `Create()`
        1. output plan
    * digression
        * if an attribute is marked as an ForceNew - the resource is destroyed and recreated
           ```
           "ami": {
           	Type:     schema.TypeString,
           	Required: true,
           	ForceNew: true,
           }
           ```
        * most resources have regular in-place updates
* `terraform apply`
    * executes the actions proposed in a Terraform plan
    * is shortcut for: `terraform plan -out file; terraform apply file; rm file`
    * useful flag: `-auto-approve`
* `terraform destroy`
    * destroy all remote objects managed by configuration
* `terraform show`
    * human-readable output from a state
* `terraform validate`
    * checks that verify whether a configuration is syntactically valid and internally consistent, regardless
    of any provided variables or existing state
* `terraform fmt`
    * rewrite Terraform configuration files to a canonical format and style
* workspaces
    * `terraform workspace new / delete workspaceName`
    * `terraform workspace list`
    * `terraform workspace select workspaceName`
    * `terraform workspace show`

## standard functions
* count vs for_each
    * count
      * module xxx { count = ["instance1", "instance2", "instance3"] }
        * module.xxx_count[0].resource
        * module.xxx_count[1].resource
        * module.xxx_count[2].resource
        * indexed by index in the list; if you remove instance2, resource3 will be recreated
    * for each
      * is a map where you could define your own key
      * locals { mymap = { Instance1 = ..., Instance2 = ... } }
      * module xxx { for_each = local.mymap instance_name = each.key }}
      1. for_each vs count
          * count
              * In the past (before Terraform 0.12.6) the only way to create multiple instances of the same resource was to use a count parameter.
              * Quite often there was some list defined somewhere and we’d create so many instances of a resource as many elements the list has
              * Now, count is sensible for any changes in list order, this means that if for some reason order of the list is changed, terraform will force replacement of all resources of which the index in the list has changed
              * In example below I added one more element to the list (as first element, at list index 0) and this is what terraform is trying to do as a result:
              * Not only my new resource is getting added, but ALL the other resources are being recreated, this is a DISASTER
          * for_each
              * It takes a map / set as input and uses the key of a map as an index of instances of created resource.
* splat expression

## module
* powerful way to reuse code
* are self-contained packages of code that allow you to create reusable components by grouping
related resources together
* if resources are the individual building blocks, modules are prefabricated groupings of many
such blocks
* https://registry.terraform.io/namespaces/terraform-aws-modules
* root module - the directory where you run terraform apply
* you may have one or more child modules
* convention: three configuration files per module
    * `main.tf` - entry point
    * `outputs.tf` - all output variables
    * `variables.tf` - all input variables
    * additional: `versions.tf`, `providers.tf`, and `README.md` in the root module

## remote backend
* in short: where state is stored
    * example: local or S3
* when using a non-local backend, Terraform will not persist the state anywhere on disk
    * major benefit: no sensitive values persisted to disk
    * remark: when writing state to the backend fails - Terraform will write the state locally
* major benefit: keep sensitive information off disk
    * for example: when you create a database, the initial database password will be in the state file
* increases security
    * for example: s3 supports encryption at rest, authentication & authorization

## workspaces
* allows you to create different and independent states on the same configuration
* are technically equivalent to renaming your state file
    * partition the Terraform state so that many instances to the same resource can exists within it
    * when working in one workspace, changes will not affect resources in another workspace
* initially the backend has only one workspace: "default"
* used for testing
    * for example, a new temporary workspace to freely experiment with changes without affecting the default workspace
* used for multi-region deployment
    ```
    provider "aws" {
     region = "${terraform.workspace}"
    }
    ```
* workspaces alone are not a suitable tool for system decomposition
    * cannot be used for a "fully isolated" setup for multiple environments (staging / testing / prod)
    * each subsystem should have its own separate configuration and backend (complete separation)
        * for complete isolation, it's best to create multiple AWS accounts, and use one account for dev, another
        for prod, and a third one for billing

## secrets management
* Terraform handles a lot of secrets—more than most people realize
    * sensitive information will inevitably find its way into Terraform no matter what you do
        * you should treat the state file as sensitive and secure it accordingly
            * gate who has access to it
            * encryption at rest
            * encrypting data in transit (SSL/TLS)
            * most of it enabled by default for S3
    * example: database passwords, personal identification information (PII), encryption keys...
* all sensitive data is put in the state file (stored as plaintext JSON)
* only three configuration blocks can store stateful information (sensitive or otherwise)
    * resources
    * data sources
    * and output values
    * other kinds of configuration blocks do not store stateful data
        * but may leak sensitive information in other ways
        * at least: not saving sensitive information to the state file
* example
    * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
    ```
    resource "aws_db_instance" "default" {
      allocated_storage    = 10
      engine               = "mysql"
      engine_version       = "5.7"
      instance_class       = "db.t3.micro"
      name                 = "mydb"
      username             = "foo" // required
      password             = "foobarbaz" // required
      parameter_group_name = "default.mysql5.7"
      skip_final_snapshot  = true
    }
    ```
* static secrets
    * are sensitive values that do not change (at least not often)
    * in general: most secrets
    * two major ways to pass static secrets into Terraform
        * as environment variables
            * should be used whenever possible
            * example (a very bad idea)
                ```
                provider "aws" {
                  region = "us-west-2"
                  access_key = var.access_key // required, but can be sourced from the AWS_ACCESS_KEY_ID environment variable
                  secret_key = var.secret_key // required, but can be sourced from the AWS_SECRET_ACCESS_KEY environment variable
                }
                ```
                * solution: use aws-vault
            * digression: RDS database you have to set username and password as Terraform variables - there is no
            option for environment variables
        * as Terraform variables
    * sensitive variables can be defined by setting the sensitive argument to true
        * example
            ```
            variable "db_username" {
              description = "Database administrator username"
              type        = string
              sensitive   = true
            }
            ```
        * appear in Terraform state but are redacted from CLI output
        * prevents users from accidentally exposing secrets but does not stop motivated individuals
            * you could just redirects var.db_username to local _file
    * terraform in automation: isolate sensitive variables from non-sensitive variables
        * reminder: terraform does not automatically load variable with any name other filename
        than `terraform.tfvars`
        * example
            * non-sensi-tive data stored in: `production.tfvars` (and commited to git)
            * sensitive data stored in `secrets.tfvars` (not commited to git)
            * command terraform apply -var-file="secrets.tfvars" -var-file="production.tfvars"

## workshops
1. aws --endpoint-url=http://localhost:4566 s3 ls
1. aws --endpoint-url=http://localhost:4566 ec2 describe-instances
1. http://127.0.0.1:8080/test.html
1. terraform workspace new us-east-1
1. terraform workspace new us-west-2
1. terraform workspace select us-east-1
1. terraform workspace select us-west-2