output "vpc_id" {
  value = aws_vpc.main.id
}

output "vpc_cidr" {
  value = aws_vpc.main.cidr_block
}

output "pub_subnet_ids" {
  value = [
    aws_subnet.public_1a.id,
    aws_subnet.public_1c.id,
  ]
}

output "pri_subnet_ids" {
  value = [
    aws_subnet.private_1a.id,
    aws_subnet.private_1c.id,
  ]
}
