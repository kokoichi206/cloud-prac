terraform {
  backend "s3" {
    bucket = "tfstate-pragmatic-terraform-kokoichi"
    key    = "main/terraform.tfstate"
    region = "ap-northeast-1"
  }
}
