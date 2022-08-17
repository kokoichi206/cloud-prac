resource "aws_security_group" "ec2-sg" {
  name = "${var.prefix}-ec2-sg"

  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = { for i in var.ingress_config : i.port => i }

    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 Key Pairs
resource "aws_key_pair" "ec2-key" {
  key_name   = "common-ssh"
  public_key = tls_private_key._.public_key_openssh
}

resource "tls_private_key" "_" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# EC2
resource "aws_instance" "main" {
  ami           = "ami-011facbea5ec0363b"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ec2-key.key_name
  vpc_security_group_ids = [
    aws_security_group.ec2-sg.id,
  ]
  subnet_id                   = var.subnet_id
  associate_public_ip_address = "true"

  ebs_block_device {
    device_name = "/dev/xvda"
    volume_type = "gp2"
    volume_size = 30
  }

  tags = {
    Name = "${var.prefix}-${var.env}"
  }
}
