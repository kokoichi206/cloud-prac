variable "prefix" {
  type        = string
  default     = "s3-old-example"
  description = "The prifix of the service"
}

variable "env" {
  type        = string
  default     = "development"
  description = "The environment where the service works (production, staging, development)"
}
