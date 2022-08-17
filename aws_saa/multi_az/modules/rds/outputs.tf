output "user_name" {
  value       = var.db_username
  description = "Username"
}

output "address" {
  value       = aws_db_instance.rds.address
  description = "The address of RDS for EC2 to access"
}

# endpoint = address:port
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance
output "endpoint" {
  value       = aws_db_instance.rds.endpoint
  description = "The endpoint of RDS for EC2 to access"
}
