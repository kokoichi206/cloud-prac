variable "prefix" {
  type = string
}

variable "employee_list_table-name" {
  type = string
}

variable "tr_lambda_role-arn" {
  type = string
}

variable "tr_api-execution-arn" {
  type = string
}


data "archive_file" "tr_lambda" {
  type        = "zip"
  source_dir  = "${path.module}/src"
  output_path = "${path.module}/upload/lambda.zip"
}

resource "aws_lambda_function" "tr_lambda" {
  filename      = data.archive_file.tr_lambda.output_path
  function_name = "${var.prefix}_tr_lambda"
  role          = var.tr_lambda_role-arn
  # ここが定数で入ってるの嫌やな？
  handler          = "tr_lambda.handler"
  source_code_hash = data.archive_file.tr_lambda.output_base64sha256
  runtime          = "python3.8"
  timeout          = 35
  environment {
    variables = {
      TABLE_NAME = var.employee_list_table-name
    }
  }
}

resource "aws_lambda_permission" "tr_lambda_permit" {
  statement_id  = "AllowAPIGatewayGetTrApi"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.tr_lambda.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${var.tr_api-execution-arn}/test/GET/"
}

output "tr_lambda-invoke-arn" {
  value = aws_lambda_function.tr_lambda.invoke_arn
}
