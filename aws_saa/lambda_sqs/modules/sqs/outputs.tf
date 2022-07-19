output "arn" {
  value       = aws_sqs_queue.terraform_queue.arn
  description = "arn of sqs"
}
