module "sqs" {
  source               = "./modules/sqs"
  prefix               = var.prefix
  env                  = var.env
  lambda_function_name = module.lambda.lambda_arn
}

module "lambda" {
  source  = "./modules/lambda"
  prefix  = var.prefix
  sqs_arn = module.sqs.arn
}
