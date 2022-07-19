resource "aws_sqs_queue" "terraform_queue" {
  name                      = "${var.prefix}-${var.env}"
  delay_seconds             = 90
  max_message_size          = 2048
  message_retention_seconds = 86400
  receive_wait_time_seconds = 10

  tags = {
    Environment = var.env
  }
}

resource "aws_lambda_event_source_mapping" "default" {
  event_source_arn = aws_sqs_queue.terraform_queue.arn
  function_name    = var.lambda_function_name
}
