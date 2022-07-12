output "api_gateway_domain" {
  value = module.api_gateway.aws_api_gateway_invoke_url
}
