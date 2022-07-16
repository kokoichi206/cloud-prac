variable "prefix" {
  type        = string
  description = "prefix"
}

variable "table-arnlist" {
  type        = list(string)
  description = "arn list of dynamodb (for multi region)"
}

variable "table-name" {
  type        = string
  description = "table name of dynamodb"
}

variable "cloud_front_arn" {
  type        = string
  description = "arn of the cloud front to connect"
}
