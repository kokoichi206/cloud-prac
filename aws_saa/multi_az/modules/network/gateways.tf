resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
}

resource "aws_eip" "nat_0" {
  vpc        = true
  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "natgw_0" {
  allocation_id = aws_eip.nat_0.id
  subnet_id     = aws_subnet.public_1a.id
  depends_on    = [aws_internet_gateway.main]
}

resource "aws_eip" "nat_1" {
  vpc        = true
  depends_on = [aws_internet_gateway.main]
}

resource "aws_nat_gateway" "natgw_1" {
  allocation_id = aws_eip.nat_1.id
  subnet_id     = aws_subnet.public_1c.id
  depends_on    = [aws_internet_gateway.main]
}
