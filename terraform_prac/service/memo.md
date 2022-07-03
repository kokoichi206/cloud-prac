## System

- バッチのジョブ管理や暗号化のための鍵管理、アプリケーションの設定管理は全てマネージドサービスで管理し、運用負荷の低減。
- デプロイパイプラインの構築による継続的デリバリーの実現
- オペレーションサーバーの構築
    - ログの検索と永続化

### Policy Document
JSON or aws_iam_policy_document

### Role
IAM ロールでは、自信を何のサービスに関連づけるかの宣言、「信頼ポリシー」を行う必要がある。


### IAM role module
``` terraform
module "describe_regions_for_ec2" {
    source = "./iam_role"
    name = "describe-regions-for-ec2"
    identifier = "ec2.amazonaws.com"
    policy = data.aws_iam_policy_document.allow_describe_regions.json
}
```

### S3: Simple Storage Service






## 疑問
- IAM ロールに IAM ポリシーを関連づけないと機能しない
    - aws_iam_role_policy_attachment のへん
    - これはコンソールではどういう作業にあたるか

