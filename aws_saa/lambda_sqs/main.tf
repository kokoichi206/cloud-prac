module "sqs" {
  source = "./modules/sqs"
  prefix = var.prefix
  env    = var.env
}
