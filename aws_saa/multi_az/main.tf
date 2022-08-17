module "network" {
  source = "./modules/network"
}

module "rds" {
  source = "./modules/rds"

  db_name        = "multi-az-prac-main"
  vpc_id         = module.network.vpc_id
  pri_subnet_ids = module.network.pri_subnet_ids
}
