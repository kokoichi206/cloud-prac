variable "prefix" {
  type        = string
  default     = "multi-az"
  description = "The prifix of the service"
}

variable "env" {
  type        = string
  default     = "development"
  description = "The environment where the service works (production, staging, development)"
}

variable "db_name" {}

variable "db_username" {
  default = "root"
}

variable "db_password" {
  default = "rootroot"
}

variable "vpc_id" {}

variable "pri_subnet_ids" {}
