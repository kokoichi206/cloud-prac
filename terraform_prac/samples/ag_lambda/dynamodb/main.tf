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

resource "aws_dynamodb_table_item" "employee_list_item" {
  table_name = aws_dynamodb_table.employee_list.name
  hash_key   = "EmployeeId"
  item = jsonencode({
    EmployeeId = {
      S = "a00000110"
    },
    FirstName = {
      S = "Taro"
    },
    LastName = {
      S = "Momo"
    },
    Office = {
      S = "Nagoya"
    }
  })
}

output "employee_list_table" {
  value = aws_dynamodb_table.employee_list
}
