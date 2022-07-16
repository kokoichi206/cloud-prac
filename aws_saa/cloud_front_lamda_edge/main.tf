# Main database
module "dynamodb" {
  source = "./modules/dynamodb"
  prefix = var.prefix
  env    = var.env

  providers = {
    aws = aws.virginia
  }
}

# 日本の Edge で動くのであれば必要。
module "dynamodb_tokyo" {
  source = "./modules/dynamodb"
  prefix = var.prefix
  env    = var.env
}

module "lambda" {
  source = "./modules/lambda"
  prefix = var.prefix
  table-arnlist = [
    module.dynamodb.employee_list_table.arn,
    module.dynamodb_tokyo.employee_list_table.arn
  ]
  table-name      = module.dynamodb.employee_list_table.name
  cloud_front_arn = module.cloud_front.cloud_front_arn

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
  source               = "./modules/cloud_front"
  bucket_id            = module.s3.bucket_id
  bucket_domain_name   = module.s3.aws_s3_bucket_domain_name
  qualified_lambda_arn = module.lambda.qualified_arn
  lambda_version       = module.lambda.qualified_version
}
