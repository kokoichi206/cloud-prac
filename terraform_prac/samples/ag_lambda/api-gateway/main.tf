variable "prefix" {
  type = string
}

variable "tr_lambda-invoke-arn" {
  type = string
}

resource "aws_api_gateway_rest_api" "tr_api" {
  name = "${var.prefix}_tr_api"
}

resource "aws_api_gateway_method" "tr_api_get" {
  authorization = "NONE"
  http_method   = "GET"
  resource_id   = aws_api_gateway_rest_api.tr_api.root_resource_id
  rest_api_id   = aws_api_gateway_rest_api.tr_api.id
}

resource "aws_api_gateway_integration" "tr_api_get" {
  http_method             = aws_api_gateway_method.tr_api_get.http_method
  resource_id             = aws_api_gateway_rest_api.tr_api.root_resource_id
  rest_api_id             = aws_api_gateway_rest_api.tr_api.id
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.tr_lambda-invoke-arn
}

resource "aws_api_gateway_deployment" "tr_api" {
  depends_on = [
    aws_api_gateway_integration.tr_api_get
  ]
  rest_api_id = aws_api_gateway_rest_api.tr_api.id
  stage_name  = "test"
  triggers = {
    redeployment = filebase64("${path.module}/main.tf")
  }
}

output "tr_api-execution-arn" {
  value = aws_api_gateway_rest_api.tr_api.execution_arn
}
