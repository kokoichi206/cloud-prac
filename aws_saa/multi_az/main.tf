module "network" {
  source = "./modules/network"
}

module "rds" {
  source = "./modules/rds"

  db_name        = "multi-az-prac-main"
  vpc_id         = module.network.vpc_id
  pri_subnet_ids = module.network.pri_subnet_ids
}

module "ec2" {
  source = "./modules/ec2"

  key_name  = var.key_name
  vpc_id    = module.network.vpc_id
  subnet_id = module.network.pub_subnet_ids[0]
}
