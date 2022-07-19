variable "prefix" {
  type        = string
  default     = "lambda_sqs"
  description = "The prifix of the service"
}

variable "env" {
  type        = string
  default     = "development"
  description = "The environment where the service works (production, staging, development)"
}
