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


### コンテナオーケストレーション in AWS
ECS or EKS
「EC2起動タイプ」or「Fargate起動タイプ」

ECSクラスタは、Docker コンテナを実行するホストサーバーを、論理的に束ねるリソース。

### ECSサービス
通常、コンテナはタスクが完了したらすぐに終了する。
そうならないための ECS サービス。何らかの理由でタスクが終了してしまった場合、自動的に新しいタスクを起動してくれる機能付き。

また、ECS サービスは ALB との橋渡し役にもなる。
インターネットからのリクエストは ALB で受け、そのリクエストをコンテナにフォワードする。

### Fargate
Fargate ではホストサーバーにログインできず、コンテナのログを直接確認できない。
そこで、CloudWatch Logs と連携し、ログを記録できるようにする。


### ECS タスク実行 IAM ロール
[AmazonECSTaskExecutionRolePolicy](https://docs.aws.amazon.com/ja_jp/AmazonECS/latest/developerguide/task_execution_IAM_role.html)は AWS が管理しているポリシー。
CloudWatch Logs や ECR の操作権限を持つ。

### CloudWatch Logs
Docker コンテナが CloudWatch Logs にログを投げられるようにもする必要がある。

awslogs-group の部分には CloudWatch Logs のグループ名を指定する

``` sh
aws logs filter-log-events --log-group-name /ecs/example
```

### バッチ
「アプリケーションレベルでどこまで制御し、ジョブ管理システムでどこまでサポートするか」について、しっかり設計する必要がある。

重要な観点

- ジョブ管理
    - 起動タイミング
- エラーハンドリング
    - エラー通知
    - ロギング
- リトライ
    - リトライできるアプリケーション設計
- 依存関係の制御
    - job A の後に job B をやらなければならない、など

### ジョブ管理システム
システムが成長すると cron では限界がきて Rundeck や JP1 などが使われるようになる。

### ECS Scheduled Tasks
ある程度の規模までであれば ECS Scheduled Tasks で代用可能。
エラーハンドリングやリトライはアプリケーションレベルで実装する必要があり、依存関係制御もできない。

### CloudWatch イベントから ECS を起動する
AmazonEC2ContainerServiceEventsRole ポリシーを持った IAM ロールの作成

schedule_expression は cron 式と rate 式をサポートしている。
cron のタイムゾーンは UTC！

### KMS: Key Management Service
エンベロープ暗号化。
カスタマーマスターキーの自動生成したデータキーを使用し、暗号化と復号。


### 設定管理
ECSのようなコンテナ環境では、設定をコンテナ起動時に注入する。実行環境ごとに異なる設定の例

- DB のホスト名・ユーザー名・パスワード
- Twitter, Facebook などの外部サービスのクレデンシャル
- 管理者あてのメールアドレス

### SSM パラメータストア
平文

``` sh
# 平文で保存するときは --type String をつける
aws ssm put-parameter --name 'plain_name' --value 'plain value' --type String
# 表示されるメッセージ
{
    "Version": 1,
    "Tier": "Standard"
}
# 参照する
aws ssm get-parameter --output text --name 'plain_name' --query Parameter.Value

# 値を更新するときは --overwrite オプション必須
aws ssm put-parameter --name 'plain_name' --type String --value 'modified value' --overwrite
# バージョンが上がった！
{
    "Version": 2,
    "Tier": "Standard"
}
```

暗号化

``` sh
# --type SecureString をつける
aws ssm put-parameter --name 'encryption_name' --value 'encryption value' --type SecureString
# 表示されるメッセージ
{
    "Version": 1,
    "Tier": "Standard"
}
# 参照する
aws ssm get-parameter --output text --query Parameter.Value --name 'encryption_name' --with-decryption
aws ssm get-parameter --output text --query Parameter.Value --name 'encryption_name'
```

SSM パラメータストアのアチアを、ECS の Docker コンテナ内で環境変数として参照する！
平文の値と暗号化した値は透過的に扱うことができ、ECS で意識する必要はない。
**ECS から SSM パラメータストアの値を参照する権限**は必要。

``` terraform
# 権限の付与
data "aws_iam_policy_document" "ecs_task_execution" {
  source_json = data.aws_iam_policy.ecs_task_execution_role_policy.policy

  statement {
    effect    = "Allow"
    actions   = ["ssm:GetParameters", "kms:Decrypt"]
    resources = ["*"]
  }
}
```

ECS のコンテナで使うときは valueFrom で SSM パラメータストアのキー名を設定する。
魔法感がして好きじゃない。。。

``` terraform
"secrets": [
    {
        "name": "DB_USERNAME",
        "valueFrom": "/db/username"
    },
    {
        "name": "DB_PASSWORD",
        "valueFrom": "/db/password"
    }
]
```




## 疑問
- IAM ロールに IAM ポリシーを関連づけないと機能しない
    - aws_iam_role_policy_attachment のへん
    - これはコンソールではどういう作業にあたるか

