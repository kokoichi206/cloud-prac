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
S3 bucket name should be GLOBALLY unique!

バケットポリシーで、S3バケットへのアクセス権を設定。ALBのようなAWSのサービスからS3へ書き込みを行う場合に必要。

### NAT: Network Address Translation
プライベートネットワークからインターネットへアクセスすることを可能にする。

NAT ゲートウェイには EIP: Elastic IP Address が必要。


### public subnet のマルチ AZ 化
aws_subnet と aws_route_table_association を変更する。

### private subnet のマルチ AZ 化
プライベートネットワークのマルチ AZ 化のポイントは、NAT ゲートウェイの冗長化であり、パブリックネットワークと比べると変更すべきリソースが多い。


### ファイアウォール
サブネットレベルで動作する「ネットワーク ACL」とインスタンスレベルで動作する「セキュリティグループ」。

### セキュリティグループ
OS へ到達する前にネットワークレベルでパケットをフィルタリングできる。


### ALB: Application Load Balancer
default_action の type は、主に次の３つある

- forward
    - リクエストを別のターゲットグループに転送
- fixed-response
    - 固定の HTTP レスポンスを応答
- redirect
    - 別の URL にリダイレクト


### Route53
ドメインの登録はさすがに terraform ではできないので、各自で済ませてもろて

CNAME レコードは「ドメイン名⇨CNAMEレコードのドメイン名⇨IPアドレス」、ALIASレコードは「ドメイン名⇨IPアドレス」という流れで名前解決、パフォーマンスが高い。


### ACM: AWS Certificate Manager
SSL 証明書を、ACM で作成する。
ACM は煩雑な SSL 証明書の管理を担ってくれるマネージドサービスで、ドメイン検証をサポートしている。

サブドメインに対しても証明書を発行させることができて、「*.example.com」のようにして**ワイルドカード証明書**とする！


### 任意のターゲットへリクエストをフォワード
ALB がリクエストをフォワードする対象を「ターゲットグループ」と呼ぶ。







## 疑問
- IAM ロールに IAM ポリシーを関連づけないと機能しない
    - aws_iam_role_policy_attachment のへん
    - これはコンソールではどういう作業にあたるか

