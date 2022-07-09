terraform {
  required_version = "~> 1.2.2"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

# CloudFrount 用
# エイリアスでアクセスできるようにしてある
provider "aws" {
  alias  = "virginia"
  region = "us-east-1"
}
