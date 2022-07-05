data "aws_iam_policy_document" "ec2_for_ssm" {
  # ----- deprecated! -----
  # source_json = data.aws_iam_policy.ec2_for_ssm.policy
  source_policy_documents = [data.aws_iam_policy.ec2_for_ssm.policy]

  statement {
    effect    = "Allow"
    resources = ["*"]

    actions = [
      "s3:PutObject",
      "logs:PutLogEvents",
      "logs:CreateLogStream",
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ssm:GetParameter",
      "ssm:GetParameters",
      "ssm:GetParametersByPath",
      "kms:Decrypt",
    ]
  }
}

data "aws_iam_policy" "ec2_for_ssm" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

module "ec2_for_ssm_role" {
  source     = "./iam_role"
  name       = "ec2-for-ssm"
  identifier = "ec2.amazonaws.com"
  policy     = data.aws_iam_policy_document.ec2_for_ssm.json
}

# IAM ロールに変わるインスタンスプロファイル
resource "aws_iam_instance_profile" "ec2_for_ssm" {
  name = "ec2-for-ssm"
  role = module.ec2_for_ssm_role.iam_role_name
}

# オペレーションサーバーの構築
resource "aws_instance" "for_operation" {
  ami                  = "ami-0c3fd0f5d33134a76"
  instance_type        = "t3.micro" # オペレーションサーバーなので低スペックで問題ない
  iam_instance_profile = aws_iam_instance_profile.ec2_for_ssm.name
  # プライベートサブネットを指定して外部アクセスを遮断
  subnet_id = aws_subnet.private.id
  # プロビジョニングスクリプト！
  user_data = file("./user_data.sh")
}

output "operation_instance_id" {
  value = aws_instance.for_operation.id
}

# オペレーションログ保存用の S3 バケット
resource "aws_s3_bucket" "operation" {
  bucket = "operation-pragmatic-terraform-kokoichi"

  # ----- deprecated! -----
  # lifecycle_rule {
  #   enabled = true

  #   expiration {
  #     days = "180"
  #   }
  # }
}

# see: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/guides/version-4-upgrade#s3-bucket-refactor
resource "aws_s3_bucket_lifecycle_configuration" "operation" {
  bucket = aws_s3_bucket.operation.id

  rule {
    id     = "Delete old uploads"
    status = "Enabled"

    expiration {
      days = 180
    }
  }
}

# オペレーションログ保存用の CloudWatch Logs
resource "aws_cloudwatch_log_group" "operation" {
  name              = "/operation"
  retention_in_days = 180
}

# SSM Document
resource "aws_ssm_document" "session_manager_run_shell" {
  # この名前にしておくと、AWS CLI を使うときにオプション指定を省略できる
  name            = "SSM-SessionManagerRunShell"
  document_type   = "Session"
  document_format = "JSON"

  content = <<EOF
    {
      "schemaVersion": "1.0",
      "description": "Document to hold regional settings for Session Manager",
      "sessionType": "Standard_Stream",
      "inputs": {
        "s3BucketName": "${aws_s3_bucket.operation.id}",
        "cloudWatchLogGroupName": "${aws_cloudwatch_log_group.operation.name}"
      }
    }
  EOF
}
