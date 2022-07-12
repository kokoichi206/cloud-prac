variable "prefix" {
  type = string
}

variable "table-name" {
  type = string
}

variable "lambda_role-arn" {
  type = string
}

data "archive_file" "lambda" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/upload/lambda.zip"
}

resource "aws_lambda_function" "lambda" {
  filename      = data.archive_file.lambda.output_path
  function_name = "${var.prefix}_lambda"
  memory_size   = 128

  role = var.lambda_role-arn

  handler          = "lambda.handler"
  source_code_hash = data.archive_file.lambda.output_base64sha256
  runtime          = "python3.8"
  timeout          = 30
  environment {
    variables = {
      TABLE_NAME = var.table-name
    }
  }
}
