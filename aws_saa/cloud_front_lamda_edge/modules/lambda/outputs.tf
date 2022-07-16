output "qualified_arn" {
  value = aws_lambda_function.lambda.arn
  # qualified_arn = arn + version
  # value       = aws_lambda_function.lambda.qualified_arn
  description = "The lambda arn"
}

output "qualified_version" {
  value       = aws_lambda_function.lambda.version
  description = "The lambda version"
}
