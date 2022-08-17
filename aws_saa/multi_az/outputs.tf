output "ssh_command" {
  value       = "ssh -i ${var.key_name} ec2-user@${module.ec2.public_ip}"
  description = "SSH command to access EC2"
}

output "sql_connect_command" {
  value       = "mysql -h ${module.rds.address} -P 3306 -u ${module.rds.user_name} -p"
  description = "Command to connect RDS"
}
