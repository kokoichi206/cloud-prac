variable "prefix" {
  type = string
}

resource "aws_dynamodb_table" "employee_list" {
  name         = "${var.prefix}_employee_list"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "EmployeeId"
  attribute {
    name = "EmployeeId"
    type = "S"
  }
}

locals {
  json_data = file("${path.module}/src/members.json")
  members   = jsondecode(local.json_data)
}

resource "aws_dynamodb_table_item" "employee_list_item" {
  for_each = local.members

  table_name = aws_dynamodb_table.employee_list.name
  hash_key   = aws_dynamodb_table.employee_list.hash_key

  item = jsonencode(each.value)
  # item = jsonencode({
  #   EmployeeId = {
  #     S = "a00000110"
  #   },
  #   FirstName = {
  #     S = "Taro"
  #   },
  #   LastName = {
  #     S = "Momo"
  #   },
  #   Office = {
  #     S = "Nagoya"
  #   }
  # })
}

output "employee_list_table" {
  value = aws_dynamodb_table.employee_list
}
