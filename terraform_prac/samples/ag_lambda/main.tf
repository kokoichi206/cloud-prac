module "dynamodb" {
  source = "./dynamodb"
  prefix = "sample1"
}

module "iam" {
  source                  = "./iam_role"
  prefix                  = "sample1"
  employee_list_table-arn = module.dynamodb.employee_list_table.arn
}

module "lambda" {
  source                   = "./lambda"
  prefix                   = "sample1"
  employee_list_table-name = module.dynamodb.employee_list_table.name
  tr_lambda_role-arn       = module.iam.tr_lambda_role-arn
  tr_api-execution-arn     = module.api_gateway.tr_api-execution-arn
}

module "api_gateway" {
  source               = "./api-gateway"
  prefix               = "sample1"
  tr_lambda-invoke-arn = module.lambda.tr_lambda-invoke-arn
}
