# SSM パラメータストアを使うと、任意の値をグローバル変数のように扱える
data "aws_ssm_parameter" "vpc_id" {
  name = "/staging/vpc/id"
}
data "aws_ssm_parameter" "subnet_id" {
  name = "/staging/public/subnet/id"
}

resource "aws_instance" "server" {
  ami                    = "ami-0c3fd0f5d33134a76"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.server.id]
  subnet_id              = data.aws_ssm_parameter.subnet_id.value
}
resource "aws_security_group" "server" {
  vpc_id = data.aws_ssm_parameter.vpc_id.value
}
