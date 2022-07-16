variable "bucket_id" {
  type        = string
  description = "s3 bucket id"
}

variable "bucket_domain_name" {
  type        = string
  description = "bucket domain name"
}

variable "qualified_lambda_arn" {
  type        = string
  description = "arn value of lambda"
}

variable "lambda_version" {
  type        = string
  description = "version of lambda"
}
