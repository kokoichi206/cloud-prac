resource "aws_ecs_cluster" "example" {
  name = "example"
}

# タスク定義
resource "aws_ecs_task_definition" "example" {
  family = "example"
  # タスクサイズ
  cpu    = "256"
  memory = "512"
  # Fargate 起動タイプの場合 awsvpc を指定
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions    = file("./container_definitions.json")
  # ログようにロール追加
  execution_role_arn = module.ecs_task_execution_role.iam_role_arn
}

# ECSサービス
resource "aws_ecs_service" "example" {
  name            = "example"
  cluster         = aws_ecs_cluster.example.arn
  task_definition = aws_ecs_task_definition.exampl.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  # latest は latest じゃない可能性があるので、バージョンは明示する！
  # https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/platform_versions.html
  platform_version = "1.3.0"
  # タスクの起動に時間がかかる場合、十分な猶予期間を設定する必要がある
  health_check_grace_period_seconds = 60

  network_configuration {
    assign_public_ip = false
    security_groups  = [module.nginx_sg.security_group_id]

    subnets = [
      aws_subnet.private_0.id,
      aws_subnet.private_1.id,
    ]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.example.arn
    container_name   = "example"
    container_port   = 80
  }

  lifecycle {
    # デプロイのたびに差分が出るのを防ぐ
    ignore_changes = [task_definition]
  }
}

module "nginx_sg" {
  source      = "./security_group"
  name        = "nginx-sg"
  vpc_id      = aws_vpc.example.id
  port        = 80
  cidr_blocks = [aws_vpc.example.cidr_block]
}
