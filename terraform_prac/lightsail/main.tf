module "lightsail" {
  source = "./modules/lightsail"
  prefix = var.prefix
  env    = var.env
}
