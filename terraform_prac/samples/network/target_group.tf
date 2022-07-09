resource "aws_lb_target_group" "example" {
  name = "example"
  # Lambda, EC2 instance, IP 等の設定。
  # ECS Fargate では「ip」を指定。
  target_type = "ip"
  vpc_id      = aws_vpc.example.id
  port        = 80
  # 多くの場合、HTTPS の終端は ALB で行うため protocol は HTTP となる。
  protocol             = "HTTP"
  deregistration_delay = 300

  health_check {
    path                = "/"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 5
    interval            = 30
    matcher             = 200
    port                = "traffic-port"
    protocol            = "HTTP"
  }

  depends_on = [aws_lb.example]
}
