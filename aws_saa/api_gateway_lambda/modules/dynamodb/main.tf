variable "prefix" {
  type = string
}

variable "env" {
  type = string
}

resource "aws_dynamodb_table" "employee_list" {
  name         = "${var.prefix}_${var.env}_employee_list"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

locals {
  # initial data setup
  json_data = file("${path.module}/src/members.json")
  members   = jsondecode(local.json_data)
}

resource "aws_dynamodb_table_item" "employee_list_item" {
  for_each = local.members

  table_name = aws_dynamodb_table.employee_list.name
  hash_key   = aws_dynamodb_table.employee_list.hash_key

  item = jsonencode(each.value)
}

# output for module user
output "employee_list_table" {
  value = aws_dynamodb_table.employee_list
}
