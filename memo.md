## Terraform


### [Dependency Lock File](https://www.terraform.io/language/files/dependency-lock)
This lock file should **NOT** be excluded by gitignore.

> The lock file is always named .terraform.lock.hcl, and this name is intended to signify that it is a lock file for various items that Terraform caches in the .terraform subdirectory of your working directory.

> Terraform automatically creates or updates the dependency lock file each time you run the terraform init command. **You should include this file in your version control repository** so that you can discuss potential changes to your external dependencies via code review, just as you would discuss potential changes to your configuration itself.
