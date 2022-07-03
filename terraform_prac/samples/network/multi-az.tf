resource "aws_vpc" "example_az" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    "Name" = "example_az"
  }
}

# public subnet
resource "aws_subnet" "public_0" {
  vpc_id                  = aws_vpc.example_az.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1a"
}

# public subnet
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.example_az.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "ap-northeast-1c"
}
