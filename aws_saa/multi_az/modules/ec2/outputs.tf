output "public_ip" {
  value       = aws_instance.main.public_ip
  description = "Public IP Address of the ec2 instance"
}
