resource "aws_cloudwatch_log_group" "for_ecs" {
  # CloudWatch Logs のグループ名
  name              = "/ecs/example"
  retention_in_days = 180
}

# ポリシーデータソースの参照
data "aws_iam_policy" "ecs_task_execution_role_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ポリシードキュメント
data "aws_iam_policy_document" "ecs_task_execution" {
  # source_json で既存のポリシーを継承できる
  source_json = data.aws_iam_policy.ecs_task_execution_role_policy.policy

  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameters", "kms:Decrypt"]
    resources = ["*"]
  }
}

# IAM ロール
module "ecs_task_execution_role" {
  source     = "./iam_role"
  name       = "ecs-task-execution"
  identifier = "ecs-tasks.amazonaws.com"
  policy     = data.aws_iam_policy_document.ecs_task_execution.json
}
