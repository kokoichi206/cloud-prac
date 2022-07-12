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
