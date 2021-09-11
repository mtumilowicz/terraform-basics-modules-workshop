* https://www.terraform.io/docs/language/dependency-lock.html
* https://discuss.hashicorp.com/t/terraform-0-14-the-dependency-lock-file/15696


1. if you run any terraform command without init before:
    terraform validate
    ╷
    │ Error: Could not load plugin
    │
    │
    │ Plugin reinitialization required. Please run "terraform init".
1. https://www.terraform.io/docs/language/dependency-lock.html
    A Terraform configuration may refer to two different kinds of external dependency that come from outside of its own codebase:

    Providers, which are plugins for Terraform that extend it with support for interacting with various external systems.
    Both of these dependency types can be published and updated independently from Terraform itself and from the
    configurations that depend on them.
    For that reason, Terraform must determine which versions of those dependencies are potentially compatible with
    the current configuration and which versions are currently selected for use.

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
