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

## preface
* goals of this workshops
    * introduction to infrastructure as a code
    * introduction to terraform
        * provider, resources, data, variables, outputs
        * for_each, count
        * modules
        * remote backends and workspaces
        * aws with localstack
* plan for the workshop:
    1. pt1_basics
    1. pt2_modules
    1. pt3_remotebackend
    1. pt4_aws

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
  * local-provisioner (execute something locally after spinning up a VM)
  * remote-provisioner (execute something remote on the VM)
  * packer (build AMI, then launch AMI)
  * cloud init (user_data in aws_instance)
    * will run after ec2 instance will launch for the first time
    * Resource provisioners are especially interesting because they are essentially back-
      doors to the Terraform runtime.
      * Provisioners can execute arbitrary code on either a
      local or remote machine, which has many obvious security implications
          * Resource provisioners allow you to execute scripts on local or remote machines as
            part of resource creation or destruction
          * They are used for various tasks, such as boot-
            strapping, copying files, hacking into the mainframe, etc.
          * Because resource provisioners call external scripts, there is an implicit
            dependency on the OS interpreter.
          * Provisioners allow you to dynamically extend functionality on resources by hooking
            into resource lifecycle events. There are two kinds of resource provisioners:
             Creation-time provisioners
             Destruction-time provisioners
          * Most people who use provisioners exclusively use creation-time provisioners: for
            example, to run a script or kick off some miscellaneous automation task
          * Sometimes resources are marked “cre-
            ated” when actually it takes a few more seconds before they are truly ready.
            * By inserting delays with the local-exec provisioner, you can solve many of these strange
            race condition–style bugs.
          * Resource provisioners should be used only as a method of last resort.
            * The main advantage of Terraform is that it’s declarative and stateful.
            * When you make calls out to external scripts, you undermine these core principles.
          * HashiCorp has publicly stated that resource provisioners
            are an anti-pattern, and they may even be deprecated in a newer version of Terraform
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
* Provisioners are used to execute scripts on a local or remote machine as part of resource creation or destruction
  * provisioner "local-exec" {
    command = "echo ${aws_instance.testInstance.public_ip} >> public_ip.txt"
    }
* terraform templates
  * data "template_file" "template1" { }
  * resource "aws_instance" "web" { ... user_data = data.template_file.template1.rendered }
* data "terraform_remote_state" "aws-state" { backend = s3 }
  * useful to generate outputs
    * datasources provide you with dynamic information
        * example: list of AMIs
        * data sources - way terraform can query aws and return results (perform API request)
            * data "aws_instance" "dbsearch" {
              * filter {
                * name = "tag:Name"
                * values = ["DB Server"]
              * }
            * }
* providers
      * The AWS provider is responsible for
        understanding API interactions, making authenticated requests, and exposing
        resources to Terraform
      * Even though we have declared the AWS provider, Terraform still needs to
        download and install the binary from the Terraform Registry


## standard operations
* terraform init
    * When terraform init is run, Terraform reads configuration files in the working directory to determine which plugins are necessary, searches for installed plugins in several locations, sometimes downloads additional plugins, decides which plugin versions to use, and writes a lock file to ensure Terraform will use the same plugin versions in this directory until terraform init runs again.
    * After locating any installed plugins, terraform init compares them to the configuration's version constraints and chooses a version for each plugin as follows:

      If any acceptable versions are installed, Terraform uses the newest installed version that meets the constraint (even if the Terraform Registry has a newer acceptable version).
      If no acceptable versions are installed and the plugin is one of the providers distributed by HashiCorp, Terraform downloads the newest acceptable version from the Terraform Registry and saves it in a subdirectory under .terraform/providers/.
      If no acceptable versions are installed and the plugin is not distributed in the Terraform Registry, initialization fails and the user must manually install an appropriate version.
* terraform plan with export -> terraform apply with that plan
* terraform apply = terraform plan -out file ; terraform apply file ; rm file
    * terraform init
    * terraform apply
      * --auto-approve
    * terraform plan
    * terraform destroy
    * terraform refresh
* terraform plan
    * You should always run
    terraform plan before deploying
    * terraform plan informs
      you about what Terraform intends to do and acts as a linter, letting you know about
      any syntax or dependency errors
    * The three main stages of a terraform plan are as follows:
      1. Read the configuration and state.
         * main.tf
         * Terraform reads your configuration and state files (if they exist).
      1. Determine actions to take.
         * terraform.tfstate
         * Terraform performs a calculation to determine what needs to be done to achieve
           the desired state. This can be one of Create() , Read() , Update() , Delete() , or No-op .
      1. Output the plan.
         * An execution plan ensures that actions occur in the right order to avoid dependency problems.
         * This is more relevant when you have lots of resources.
    * algo
        1. Refresh state
        2. Read configuration: main.tf
        3. Read state: terraform.tfstate
        4. Resource in state?
            * YES -> Read()
                1. Has changes?
                    * Yes -> Is Destroy Plan?
                        * Yes -> Delete()
                        * No -> Update()
                    * No -> No-op
            * NO - Create()
        5. Output plan
    * As you can see, Terraform has noticed that we altered the content attribute and is
      therefore proposing to destroy the old resource and create a new resource in its stead.
      * This is done rather than updating the attribute in place because content is marked
      as a force new attribute, which means if you change it, the whole resource is tainted.
        * This is a classic example of immutable infrastructure, although not all attributes of
          managed Terraform resources behave like this
        * In fact, most resources have regular in-
          place (i.e. mutable) updates
                  * If one of the force-new attributes ( ami , instance_type , user_data ) was modified,
                    then during a subsequent terraform apply , the existing resource would be
                    destroyed before the new one was created
                      * This is Terraform’s default behavior
                      * The
                        drawback is that there is downtime between when the old resource is destroyed and
                        the replacement resource is provisioned
                      * This downtime is not negligi-
                        ble and can be anywhere from five minutes to an hour or more, depending on the
                        upstream API.

## module
* information flow
  * powerful way to reuse code
  * use external modules or write modules yourself
  * https://registry.terraform.io/namespaces/terraform-aws-modules
    * https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest
    * Modules are self-contained packages of code that allow you to create reusable compo-
      nents by grouping related resources together
    * Modules are useful tools for promoting software abstraction and code reuse.
    * 4.2.1 Module syntax
        * When I think about modules, the analogy of building with toy blocks always comes to
          mind
        * If resources and data sources are the individual building blocks of Terraform,
          then modules are prefabricated groupings of many such blocks
        * module "lb_sg" { }
    * 4.2.2 What is the root module?
        * Every workspace has a root module; it’s the directory where you run terraform apply
        * Under the root module, you may have one or more child modules to help you organ-
          ize and reuse configuration
        * Modules can be sourced either locally (meaning they are
          embedded within the root module) or remotely (meaning they are downloaded from
          a remote location as part of terraform init )
        * children-within-children module pattern is called nested modules
        * HashiCorp strongly recommends that every module follow certain code conventions
          known as the standard module structure
          (www.terraform.io/docs/modules/index.html#standard-module-structure)
          * three Terraform configuration files per module:
             main.tf—the primary entry point
             outputs.tf—declarations for all output values
             variables.tf—declarations for all input variables
          * versions.tf, providers.tf, and README.md are considered required files
            in the root module
* 4.3 Root module
    * is the top-level module
    * It’s where user-supplied input variables are
      configured and where Terraform commands such as terraform init and terra-
      form apply are run
    * In our root module, there will be three input variables and two output values
        * input variables are namespace , ssh_keypair , and region
        * two output values are db_password and lb_dns_name
    * The namespace variable is a project identifier
        * project_name and environment
* Remote modules can be fetched from the Terraform Registry with either terra-
  form init or terraform get
  * But not only the Terraform configuration is downloaded; everything in those modules is downloaded.
Terraform always runs in the context of a single root module. A complete Terraform configuration consists of a root module and the tree of child modules (which includes the modules called by the root module, any modules called by those modules, etc.).

In Terraform CLI, the root module is the working directory where Terraform is invoked. (You can use command line options to specify a root module outside the working directory, but in practice this is rare. )
In Terraform Cloud and Terraform Enterprise, the root module for a workspace defaults to the top level of the configuration directory (supplied via version control repository or direct upload), but the workspace settings can specify a subdirectory to use instead.

## remote backend
* create resources first, then uncomment the backend cofiguration, then init
    * workspaces should be discussed here
* When using a non-local backend, Terraform will not persist the state anywhere on disk except in the case of a non-recoverable error where writing the state to the backend failed. This behavior is a major benefit for backends: if sensitive values are in your state, using a remote backend allows you to use Terraform without that state ever being persisted to disk.
* In the case of an error persisting the state to the backend, Terraform will write the state locally. This is to prevent data loss.
* Backends are responsible for supporting state locking if possible.
    * Terraform will lock your state for all operations that could write state.
    * This prevents others from acquiring the lock and potentially corrupting your state.
* Terraform has a force-unlock command to manually unlock the state if unlocking failed.
    * If you unlock the state when someone else is holding the lock it could cause multiple writers.
    * To protect you, the force-unlock command requires a unique lock ID. Terraform will output this lock ID if unlocking fails
  * can keep sensitive information off disk
  * s3 supports encryption at rest, authentication & authorization
  * dynamodb locking
    * sometimes when terraform crashes or users internet connection breaks during terraform apply
    the lock will stay
      * terraform force-unlock <id>
      * this command will not touch the state, it'll just remove the lock file, so it's safe
      as long as nobody is really still doing an apply
  * you need to be aware that secrets can be stored in your state file
    * for example, when you create a database, the initial database password will be in the state file
    * if you have a remote state, then it will not be stored on disk locally (it will only be kept in memory when
    you run terraform apply)
      * increases security
  * make sure only terraform administrators have access to s3 bucket where the state resides
* In Terraform, race conditions
  occur when two people are trying to access the same state file at the same time, such as
  when one is performing a terraform apply and another is performing terraform
  destroy
    * If this happens, your state file can become out of sync with what’s actually
      deployed, resulting in what is known as a corrupted state
    * Using a remote backend end
      with a state lock prevents this from happening
 Store sensitive information securely
    * In the unlikely event that two people try to deploy against the same remote backend
      at the same time, only one user will be able to acquire the state lock—the other will
      fail.

## workspaces
  * when you create a new workspace, you start with empty state
  * cannot be used for a "fully isolated" setup that you'd need when you want
  to run terraform for multiple environments (staging / testing / prod)
  * even though a workspace gives you an empty state you're still using the same state
  the same backend configuration (workspaces are the technically equivalent of renaming your state file)
  * in real world scenarios you typically use re-usable modules and really split out the state over
  multiple backends (for example your staging backend will be on s3 on your staging aws account and your
  prod backend will be in an s3 bucket on the prod aws account, following multi-account strategy)
* project structure
  * you want to separate your development and production environments completely
  * for complete isolation, it's best to create multiple AWS accounts, and use one account
  for dev, another for prod, and a third one for billing


## aws
aws --endpoint-url=http://localhost:4566 s3 ls
aws --endpoint-url=http://localhost:4566 ec2 describe-instances


1. if you run any terraform command without init before:
    terraform validate
    ╷
    │ Error: Could not load plugin
    │
    │
    │ Plugin reinitialization required. Please run "terraform init".
1. https://www.terraform.io/docs/language/dependency-lock.html
    A Terraform configuration may refer to two different kinds of external dependency that come from outside of its own codebase:



    Version constraints within the configuration itself determine which versions of dependencies are potentially
    compatible, but after selecting a specific version of each dependency Terraform remembers the decisions
    it made in a dependency lock file so that it can (by default) make the same decisions again in future.

    At present, the dependency lock file tracks only provider dependencies. Terraform does not remember version
    selections for remote modules, and so Terraform will always select the newest available module version
    that meets the specified version constraints. You can use an exact version constraint to ensure that
    Terraform will always select the same module version.

    You should include this file in your version control repository so that you can discuss potential changes
    to your external dependencies via code review, just as you would discuss potential changes to your
    configuration itself.

    When terraform init is working on installing all of the providers needed for a configuration, Terraform considers
    both the version constraints in the configuration and the version selections recorded in the lock file.

    If a particular provider has no existing recorded selection, Terraform will select the newest available version
    that matches the given version constraint, and then update the lock file to include that selection.

    If a particular provider already has a selection recorded in the lock file, Terraform will always re-select
    that version for installation, even if a newer version has become available.

    Terraform will also verify that each package it installs matches at least one of the checksums it previously
    recorded in the lock file, if any, returning an error if none of the checksums match

    This separates the idea of which provider versions a module/configuration is compatible with (the version
    constraints) from which versions a configuration is currently using (the lock file).

    It will check the downloaded provider packages against the checksums it saw the first time you saw the
    provider, raising an error if any package does not match.
        This therefore implements a “trust on first use” model where you can, if you wish, perform audits or
        other checks on new provider versions you intend to use and then use the lock file to remember the
        checksums of the packages you audited, so you’ll know if the upstream provider package is modified
        in some way after you reviewed it.
1. .terraform directory is in turn just a local cache of remote the items the lock file describes.
1. http://127.0.0.1:8080/test.html
1. for_each vs count
    * count
        * In the past (before Terraform 0.12.6) the only way to create multiple instances of the same resource was to use a count parameter.
        * Quite often there was some list defined somewhere and we’d create so many instances of a resource as many elements the list has
        * Now, count is sensible for any changes in list order, this means that if for some reason order of the list is changed, terraform will force replacement of all resources of which the index in the list has changed
        * In example below I added one more element to the list (as first element, at list index 0) and this is what terraform is trying to do as a result:
        * Not only my new resource is getting added, but ALL the other resources are being recreated, this is a DISASTER
    * for_each
        * It takes a map / set as input and uses the key of a map as an index of instances of created resource.
1. show why validation is important (internal_port - if you change from 8080 it will not work)

## secrets management
* Terraform is an infrastructure provisioning
  technology and therefore handles a lot of secrets—more than most people realize.
  Secrets like database passwords, personal identification information (PII), and
  encryption keys may all be consumed and managed by Terraform.
* Worse, many of
  these secrets appear as plaintext, either in Terraform state or in log files.
  * Sensitive information will inevitably find its way into Terraform state pretty much no
    matter what you do.
  * Terraform does not treat attributes containing sensitive data any differ-
    ently than it treats non-sensitive attributes.
    * Therefore, any and all sensitive data is put
      in the state file, which is stored as plaintext JSON.
  * Because you can’t prevent secrets
    from making their way into Terraform state, it’s imperative that you treat the state file
    as sensitive and secure it accordingly.
    * Only three configuration blocks can store stateful information (sensitive or otherwise)
    in Terraform: resources, data sources, and output values.
    * Other kinds of configuration blocks (pro-
      viders, input variables, local values, modules, etc.) do not store stateful data.
      * Any of
        these other blocks may leak sensitive information in other ways, but at least you do not
        need to worry about them saving sensitive information to the state file.
* example
    * https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
        * two secrets: var.username and var.password .
          * Since both of these
            attributes are defined as required , if you want Terraform to provision an RDS data-
            base, you must be willing to accept that your master username and password secret val-
            ues exist in Terraform state
        * username and password appear
                  as plaintext in Terraform state
* you need to treat the state file as secret and gate who has access to it
    * Encryption at rest is the act of translating data into a format that cannot be decrypted
      except by authorized users
    * Even if a malicious user were to gain
      physical access to the machines storing encrypted data, the data would be useless to
      them.
    * Encrypting data in transit is just as important as encrypting data at rest.
      * The standard
        way to do this is to ensure that data is exclusively transmitted over SSL/TLS, which
        is enabled by default for most backends including S3, Terraform Cloud, and Terraform
        Enterprise
* static secrets
      * Static secrets are sensitive values that do not change, or at least do not change often.
      * Most secrets can be classified as static secrets.
      * Things like username and passwords,
        long-lived oAuth tokens, and config files containing credentials are all examples of
        static secrets.
        * There are two major ways to pass static secrets into Terraform: as environment variables
          and as Terraform variables.
            * I recommend passing secrets as environment variables
              whenever possible because it is far safer than the alternative.
    * Environment variables do
      not show up in the state or plan files, and it’s harder for malicious users to access your
      sensitive values as compared to Terraform variables.
    * example
            * When configuring a Terraform provider, you definitely do not want to pass sensitive
              information as regular Terraform variables:
              provider "aws" {
                region = "us-west-2"
                access_key = var.access_key // A very bad idea!
                secret_key = var.secret_key // A very bad idea!
              }
    * The recommended approach is therefore to configure providers using environ-
      ment variables:
      provider "aws" {
        region = "us-west-2"
      }
        * If you wish to deploy an RDS database, you are stuck setting username and password
          as Terraform variables, since there is no option for using environment variables
    * After running Terraform in automation, you should seek to isolate sensitive Terra-
      form variables from non-sensitive Terraform variables.
          * Terraform does not automatically
            load variable-definition files with any name other than terraform.tfvars , but you
            can specify other files using the -var-file flag.
            * For instance, if you have non-sensi-
              tive data stored in production.tfvars (possibly checked into Git) and sensitive
              data stored in secrets.tfvars (definitely not checked into Git), the following com-
              mand will do the trick:
              * terraform apply \
                -var-file="secrets.tfvars" \
                -var-file="production.tfvars"
        * Sensitive variables can be defined by setting the sensitive argument to true:
        * Variables defined as sensitive appear in Terraform state but are redacted from CLI
          output.
            * Defining a variable as sensitive prevents users from accidently exposing secrets but
              does not stop motivated individuals.
              * Consider instead the following code, which redirects var.password to local
                _file
      * Secrets should be rotated periodically: at least once every 90 days, or in response to
        known security threats.
        * AWS Secrets Manager
