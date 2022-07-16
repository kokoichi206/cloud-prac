variable "prefix" {
  type        = string
  default     = "cloud_front_lambda_edge"
  description = "The prifix of the service"
}

variable "env" {
  type        = string
  default     = "development"
  description = "The environment where the service works (production, staging, development)"
}
