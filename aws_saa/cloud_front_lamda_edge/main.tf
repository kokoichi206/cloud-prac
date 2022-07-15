# Main database
module "dynamodb" {
  source = "./modules/dynamodb"
  prefix = var.prefix
  env    = var.env
}

module "lambda" {
  source     = "./modules/lambda"
  prefix     = var.prefix
  table-arn  = module.dynamodb.employee_list_table.arn
  table-name = module.dynamodb.employee_list_table.name

  providers = {
    aws = aws.virginia
  }
}

module "s3" {
  source = "./modules/s3"
  prefix = var.prefix
  env    = var.env
}

module "cloud_front" {
  source             = "./modules/cloud_front"
  bucket_id          = module.s3.bucket_id
  bucket_domain_name = module.s3.aws_s3_bucket_domain_name
}
