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

variable "vpc_id" {
  type        = string
  description = "The ID of VPC"
}

variable "subnet_id" {
  type        = string
  description = "The value of subnet_id where ec2 server lives"
}

variable "ingress_config" {
  type = list(object({
    port        = string
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      port        = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      port        = 3306
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    }
  ]
  description = "list of ingress config"
}
