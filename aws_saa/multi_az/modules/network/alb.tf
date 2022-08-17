# SecurityGroup for ALB
# https://www.terraform.io/docs/providers/aws/r/security_group.html
resource "aws_security_group" "main" {
  name        = "main"
  description = "main security group for ALB of ${var.prefix}"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "main-multi-az"
  }
}

# SecurityGroup Rule
# https://www.terraform.io/docs/providers/aws/r/security_group.html
resource "aws_security_group_rule" "alb_http" {
  security_group_id = aws_security_group.main.id

  type = "ingress"

  from_port = 80
  to_port   = 80
  protocol  = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
}

resource "aws_lb" "main" {
  name               = "main-multi-az"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.main.id]
  subnets = [
    aws_subnet.public_1a.id,
    aws_subnet.public_1c.id,
  ]
  ip_address_type = "ipv4"

  tags = {
    name = "main-multi-az"
  }
}

resource "aws_lb_target_group" "main" {
  name             = "higa-TGN"
  target_type      = "instance"
  protocol_version = "HTTP1"
  port             = 80
  protocol         = "HTTP"
  vpc_id           = aws_vpc.main.id

  tags = {
    name = "higa-TGN"
  }

  health_check {
    interval            = 30
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2
    matcher             = "200,301"
  }
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.main.arn
  }
}
