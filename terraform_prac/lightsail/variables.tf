variable "prefix" {
  type        = string
  default     = "sns-app-sample"
  description = "The prifix of the service"
}

variable "env" {
  type        = string
  default     = "production"
  description = "The environment where the service works (production, staging, development)"
}
