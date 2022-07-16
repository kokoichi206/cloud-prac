data "aws_iam_policy_document" "s3_bucket_policy" {
  statement {
    sid    = "PublicReadForGetBucketObjects"
    effect = "Allow"

    principals {
      identifiers = ["*"]
      type        = "*"
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "arn:aws:s3:::${local.bucket_name}/*"
    ]
  }
}
