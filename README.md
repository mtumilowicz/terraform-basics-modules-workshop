[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

# terraform-basics-modules-workshop
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
* goals of this workshop
    * introduction to infrastructure as a code
    * introduction to terraform
        * provider, resources, data, variables, outputs
        * standard functions, meta-arguments and expressions
        * modules
    * introduction to terraform version manager: https://github.com/tfutils/tfenv
* plan for the workshop
    * fill the scaffolds and follow the hints in directories:
        1. pt1_basics
        1. pt2_modules
    * note that `docker provider` differs for unix and windows os:
        ```
        provider "docker" {
          // host = "unix:///var/run/docker.sock" // macos
          // host = "npipe:////.//pipe//docker_engine" // windows
        }
        ```
        you should uncomment appropriate one


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
        * is a state management tool + CRUD operations
            * anything that is CRUD can be managed by terraform
            * uses the same APIs as automation script
                * difference: not only deployment but also infrastructure management
            * understands dependencies between resources
            * can detect and correct configuration drift
                * drift means real-world state of infrastructure =/= state defined in configuration
                * cannot detect drift of resources that are not managed by terraform
                * does not continuously monitor infrastructure (it is not like Kubernetes)
                    * detects drift only when: `terraform plan` is run
                    * fix drift only when: `terraform apply` is run
        * is a simple state management engine
    * packer
        * example: build AWS AMIs based on templates
            * Amazon Machine Image (AMI) provides the information required to launch an instance
        * instead of installing the software after booting up an instance, you create an AMI
        with all needed software from a machine image
            * machine image = pre-configured operating system + software
        * speed up boot times of instances
        * common approach when running horizontally scaled apps
    * ainsible
        * install software after the infrastructure is provisioned
        * has a focus on automating the installation and configuration of software
        * example: security updates

## terraform structure
* terraform is separated into 3 separate parts
    * core
        * parsing configuration files
        * resource state management
        * construction of the Resource Graph (DAG)
        * plan execution
        * communication with plugins over RPC
        * contains language interpreter, the CLI and how to interact with providers
            * no code to interact with the API of the cloud providers
                * that code is in providers, which be installed separately by invoking `terraform init`
    * plugins (providers and provisioners)
        * implementations for a specific service, such as AWS, or provisioner, such as bash
        * separate process communicating with terraform binary over an RPC interface
        * providers
            * maps terraform Resources into cloud Services
            * handles authentication
        * provisioners
            * executes commands/scripts on the designated Resource after creation, or on destruction
    * upstream
       * terraform does not create resources - it makes the cloud api to create it
       * api: aws, google cloud, github, etc

## project structure
* `.terraform`
    * binary of the providers (initialized during `terraform init`)
* `terraform.lock.hcl`
    * problem: providers and modules can be published and updated independently from Terraform itself
        * Terraform must determine which versions of those dependencies are potentially compatible with the
        current configuration
    * provider dependency lockfile
    * created when `terraform init`
    * tracks versions of providers and modules
    * should be committed to git
    * re-runs of terraform will use the same provider/module versions
        * example: terraform is ran by other members or using automation
* `*.tf` files
    * configuration files
    * terraform concatenates all `.tf` files together (the context is a module - explained in the module section)
* `*.tfvars` files
    * values assignments to variables
* `terraform.tfstate`
    * is the state file used to keep track of the resources
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
        * "lineage" and "serial" matters only during validation when `terraform state push`
            * pushing the state to the currently configured backend
    * what happens when removed?
        * it is not recreate automatically
        * use `terraform import` to manually recreate it
    * it’s important not to edit or delete (terraform will lose track of the resources)
* `terraform.tfstate.backup`
    * in case to recover to the last deployed state
* module directories
    * module is a collection of `.tf` files kept together in a directory
    * nested directories are treated as completely separate modules
        * are not automatically included in the configuration
    * root module = main directory
    * terraform treats the entire module as a single document
        * separating various blocks into different files is purely for the convenience of readers
            * no effect on the module's behavior

## module
* powerful way to reuse code
* are self-contained packages of code
* allow you to create reusable components by grouping related resources together
* https://registry.terraform.io/namespaces/terraform-aws-modules
* root module - the directory where you run terraform apply
* you may have one or more child modules
* convention: three configuration files per module
    * `main.tf` - entry point
    * `outputs.tf` - all output variables
    * `variables.tf` - all input variables
    * additional: `versions.tf`, `providers.tf`, and `README.md` in the root module

## language
* providers
    * interact with cloud providers
    * each provider defines a set of resources
    * example: AWS provider - S3, EC2, etc
* resources
    * describe infrastructure objects
    * example: ec2, vpc, database
        * https://registry.terraform.io/providers/hashicorp/aws/latest/docs
    * have inputs and outputs
        * inputs are called arguments
        * outputs are called attributes
        * arguments are passed through the resource and are also available as attributes
        * computed attributes = available after the creation
            * example: AWS `arn:partition:service:region:account-id:resource-type:resource-id`
    * implement the resource schema interface
        * definitions of CRUD functions hooks
        * Terraform invokes these hooks when certain conditions are met
            * example
                * `Create()` is called during resource creation
                * `Read()` during plan generation
* variables
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
    * variables should be validated
        * example - usually internal ports are fixed
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
        * terraform automatically loads variable definitions if
            * named exactly `terraform.tfvars`
            * names ending in `.auto.tfvars`
        * other way to load variables: `terraform apply --var-file prod.tfvars`
* datasources
    * fetch data from outside of the terraform
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
    * are an anti-pattern, and they may even be deprecated in a newer version of Terraform
        * example
            * sometimes resources are marked "created" and it takes a few more seconds before they are truly ready
                * don't: insert delays with the local-exec provisioner
                * do: `resource "time_sleep"` and `depends_on = [time_sleep.wait_30_seconds]`
    * resource provisioners are essentially backdoors to the Terraform runtime
    * provisioners can execute arbitrary code on either a local or remote machine as part of resource
    creation or destruction
    * used for various tasks, such as bootstrapping, copying files
    * call external scripts, there is an implicit dependency on the OS interpreter
    * should be used only as a method of last resort
    * types
        * local-provisioner (execute something locally after spinning up a VM)
        * remote-provisioner (execute something remote on the VM)

## standard operations
* `terraform init`
    * determines which plugins are necessary (based on configuration files)
    * install plugins if needed
        * providers resides in `.terraform/providers/`
        * if any versions that meets the constraint are installed -> chooses newest one
        * otherwise -> downloads and installs the newest acceptable from the Terraform Registry
        * otherwise -> initialization fails
    * writes a lock file
* `terraform plan`
    * what Terraform intends to do
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
    * advice: always run plan before deploying
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
    * checks if configuration is syntactically valid regardless of any provided variables or existing state
* `terraform fmt`
    * rewrite files to a canonical format and style
* workspaces
    * `terraform workspace new / delete workspaceName`
    * `terraform workspace list`
    * `terraform workspace select workspaceName`
    * `terraform workspace show`

## standard functions, meta-arguments and expression
* https://www.terraform.io/docs/language/functions/index.html
    * `join(separator, list)`
        * `join(", ", ["foo", "bar", "baz"])` -> `foo, bar, baz`
    * `alltrue(list)`
        * `alltrue(["true", true])` -> `true`
    * `length(any)`
        * `length("hello")` -> `1`
        * `length({"a" = "b"})` -> `1`
        * `length(["a", "b"])` -> `2`
    * `lookup(map, key, default)`
        * `lookup({a="ay", b="bee"}, "c", "what?")` -> `what?`
    * `templatefile(path, vars)`
        * `templatefile("${path.module}/backends.tpl", { port = 8080, ip_addrs = ["10.0.0.1", "10.0.0.2"] })`
    * expanding function arguments: `...`
        * expanded list into separate arguments
        * `min([55, 2453, 2]...)`
* meta-arguments
    * providers
        * specifies which provider configurations will be available inside the module
    * `for_each` and `count`
        * sometimes you want to manage several similar objects (like a fixed pool of compute instances) without
        writing a separate block for each one
        * count
            * accepts a number and creates that many instances
            * `count.index` - (starting with 0) corresponding to current instance
            * is sensible for any changes in list order
                * terraform will force replacement of all resources of which the index in the list has changed
            * example
                ```
                resource "aws_instance" "server" {
                  count = 4 # create four similar EC2 instances

                  ami           = "ami-a1b2c3d4"
                  instance_type = "t2.micro"

                  tags = {
                    Name = "Server ${count.index}"
                  }
                }
                ```
        * `for_each`
            * accepts a map or a set of strings, and creates an instance for each item
            * `each.key`, `each.value`
            * example
                ```
                resource "aws_iam_user" "the-accounts" {
                  for_each = toset( ["Todd", "James", "Alice", "Dottie"] )
                  name     = each.key
                }
                ```
    * `depends_on`
        * handle hidden resource or module dependencies
        * used when relies on some other resource's but doesn't access any of that resource's data
        * should be used only as a last resort
        * example
            * software running in this EC2 instance needs access to the S3 API in order to boot properly
                * `aws_instance depends_on aws_iam_role_policy`
* expressions
    * for
        * `[for o in var.list : o.id]`
    * splat
        * more concise way to express a common operation performed with a `for`
        * `[for o in var.list : o.id]` -> `var.list[*].id`
        * does not work for maps
