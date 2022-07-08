resource "aws_vpc" "staging" {
  cidr_block = "192.168.0.0/16"

  # ↓↓↓↓↓ 追加 ↓↓↓↓↓
  tags = {
    "Environment" = "Staging"
  }
  # ↑↑↑↑↑ 追加 ↑↑↑↑↑
}
resource "aws_subnet" "public_staging" {
  vpc_id     = aws_vpc.staging.id
  cidr_block = "192.168.0.0/24"

  # ↓↓↓↓↓ 追加 ↓↓↓↓↓
  tags = {
    "Environment"   = "Staging"
    "Accessibility" = "Public"
  }
  # ↑↑↑↑↑ 追加 ↑↑↑↑↑
}

output "vpc_id" {
  value = aws_vpc.staging.id
}
output "subnet_id" {
  value = aws_subnet.public_staging.id
}


# リモートステートで参照するため
terraform {
  backend "s3" {
    bucket = "tfstate-pragmatic-terraform-kokoichi-stage"
    key    = "network/terraform.tfstate"
    region = "ap-northeast-1"
  }
}

# SSM パラメータストアで連携するため
resource "aws_ssm_parameter" "vpc_id" {
  name  = "/staging/vpc/id"
  value = aws_vpc.staging.id
  type  = "String"
}
resource "aws_ssm_parameter" "subnet_id" {
  name  = "/staging/public/subnet/id"
  value = aws_subnet.public_staging.id
  type  = "String"
}
