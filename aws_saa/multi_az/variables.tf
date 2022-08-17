variable "prefix" {
  type        = string
  default     = "multi_az"
  description = "The prifix of the service"
}

variable "env" {
  type        = string
  default     = "development"
  description = "The environment where the service works (production, staging, development)"
}

variable "key_name" {
  type    = string
  default = "ec2_key"
}
