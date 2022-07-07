terraform {
  required_version = "1.2.2"
  # https://learn.hashicorp.com/tutorials/terraform/provider-versioning#explore-terraform-tf
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
