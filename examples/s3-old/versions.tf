terraform {
  required_version = "= 1.2.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.8"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}
