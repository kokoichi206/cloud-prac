# Main database
module "dynamodb" {
  source = "./modules/dynamodb"
  prefix = var.prefix
  env    = var.env
}

module "iam" {
  source    = "./modules/iam_role"
  prefix    = var.prefix
  table-arn = module.dynamodb.employee_list_table.arn
}

module "lambda" {
  source          = "./modules/lambda"
  prefix          = var.prefix
  table-name      = module.dynamodb.employee_list_table.name
  lambda_role-arn = module.iam.lambda_role-arn
}
