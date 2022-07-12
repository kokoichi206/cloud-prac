variable "prefix" {
  type        = string
  default     = "api_gw_lambda"
  description = "The prifix of the service"
}

variable "env" {
  type        = string
  default     = "development"
  description = "The environment where the service works (production, staging, development)"
}
