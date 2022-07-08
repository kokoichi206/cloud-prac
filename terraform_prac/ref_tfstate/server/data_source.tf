data "aws_vpc" "staging" {
  # タグに基づいた参照！
  # network ディレクトリの tfstate ファイルに一切依存しない！！
  # さらに、リソースの識別子（実装）に損しない
  tags = {
    "Environment" = "Staging"
  }
}

data "aws_subnet" "public_staging" {
  # タグに基づいた参照！
  tags = {
    "Environment" = "Staging"
    "Accessibility" = "Public"
  }

  # タグに基づいた参照！
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.staging.id]
  }
  filter {
    name   = "cidr-block"
    values = ["192.168.0.0/24"]
  }
}

resource "aws_instance" "server" {
  ami                    = "ami-0c3fd0f5d33134a76"
  instance_type          = "t3.micro"
  vpc_security_group_ids = [aws_security_group.server.id]
  subnet_id              = data.aws_subnet.public_staging.id
}
resource "aws_security_group" "server" {
  vpc_id = data.aws_vpc.staging.id
}
