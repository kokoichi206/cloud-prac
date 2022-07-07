## setup

- 「プログラムによるアクセス」を付与した IAM ユーザーを作成

``` sh
pip3 install awscli --upgrade
aws --version

export AWS_ACCESS_TOKEN_KEY_ID=xxx
export AWS_SECRET_ACCESS_KEY=yyy/eee/ppp/aaa
export AWS_DEFAULT_REGION=ap-northeast-1

aws sts get-caller-identity --query Account --output text
```

### Terraform
Terraform をとりあえず動かすには Homebrew が手軽。
実運用では頻繁に Terraform のバージョンアップが発生するので tfenv 等の利用が必要。

``` sh
brew install tfenv
tfenv --version

tfenv list-remote
# 現環境最新
tfenv install 1.2.4
# 1.0.2 以降は arm 版にも対応。
tfenv install 1.0.6
tfenv install 1.1.8

tfenv list
tfenv use 1.2.4

# .terraform-version により統一が可能!!
tfenv install
```

#### cf. Dockernized Terraform
Terraform は Docker Hub で公式イメージが配布されており、Docker さえ入っていればどこでも実行できるシンプルさ！

``` sh
docker pull hashicorp/terraform:1.2.4
docker run --rm hashicorp/terraform:1.2.4 --version

docker run --rm -i -v $PWD:/work -w /work \
    -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
    -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
    -e AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION \
    hashicorp/terraform:1.2.4 <command>
```

### git-secrets
クレデンシャル流出防止のためのもの。

``` sh
brew install git-secrets

git secrets --register-aws --global
git secrets --install ~/.git-templates/git-secrets
git config --global init.templatedir '~/.git-templates/git-secrets'
```


## Basic Operations
``` sh
terraform init
terraform plan
terraform apply
terraform destroy
```

[Create default VPC](https://docs.aws.amazon.com/ja_jp/vpc/latest/userguide/default-vpc.html#create-default-vpc)

```
aws ec2 create-default-vpc
```

「既存リソースをそのまま変更する」ケースか「リソースが作り直しになる」ケースかは常に確認する！


## Basic Syntax

### variable
u can override the variables in .tf file like this.

``` sh
terraform plan -var 'example_instance_type=t3.nano'
```

local variables ("locals" syntax) cannot be overwritten in runtime.


### Provider
Terraform can be used not only in AWS but also in GCP, Azure and so on. This is achieved by "Provider".


### Module
Before you use "module", you have to do `terraform get` or `terraform init` command


### RDS
`my.cnf` (MySQL) に定義するようなデータベースの設定は、DB パラメータグループに記述

RDS や ElastiCache の apply は時間がかかる。


### ECR
Docker クライアントの認証

``` sh
# 「Error saving credentials: error storing credentials - err: exit status 1,」
# と出たときは "~/.docker/config.json" の内容を一部削除する。
# https://techblog.recochoku.jp/6190
$(aws ecr get-login --region $AWS_DEFAULT_REGION --no-include-email)
# docker イメージの指定方法。。。
docker push XXXXXX.dkr.ecr.ap-northeast-1.amazonaws.com/example:latest
```


### CodeBuild
CodeBuild が使用する IAM ロールの持つ権限

- ビルド出力アーティファクトを保存するための S3 操作権限
- ビルドログを出力する為の CloudWatch Logs 操作権限
- Docker イメージをプッシュするための ECR 操作権限

CodeBuild のビルド処理を規定するのが「buildspec.yml」であり、アプリケーションコードのプロジェクトルートに配置する！（Dockerfile と同じ部分）

``` sh
export GITHUB_TOKEN=XXXXXXXX
```

### CodePipeline
3 つのステージからなる

1. Source: Github からソースコードを取得する
2. Build: CodeBuild を実行し、ECR に Docker イメージをプッシュする
3. Deploy: ECS へ Docker イメージをデプロイする

秘密鍵が tf ファイルに平文で書き込まれる問題は、**一回断念して諦めるしかない！**そのあと上書きする。

### GitHub Webhook
CodePipeline では Webhook のリソースを、通知する側とされる側のそれぞれで実装する！


### SSH レスオペレーション
Session Manager を導入し、SSH ログインを不要にする。「SSH の鍵管理」も「SSH のポート解放」も行わない。
また、Session Manager で全ての操作ログを保存できる。コマンドの実行結果も自動的に残せる。
Amazon Linux2 には最初からインストール済み。

### インスタンスプロファイル
AWS のサービスに権限を付与する場合、これまでは IAM ロールを関連づけてきた。
しかし EC2 は特殊で、直接 IAM ロールを関連づけできない。かわりに、IAM ロールをラップしたインスタンスプロファイルを関連づけて権限を付与する。

### Session Manager
Session Manager 用の AmazonSSMManagedInstanceCore ポリシーをベースにしつつ、S3バケトット CloudWatch Logs への書き込み権限を付与する。
SSMパラメータストアと ECR への参照権限。

Session Manager の操作ログを自動保存するためには SSM Document を作成する必要がある。ログの保存先には S3 バケットと CloudWatch Logs を指定可能。

SSH ログインなしに、シェルアクセスを実現するサービス。サーバーに専属のエージェントをインストールして、そのエージェント経由でコマンドを実行する。

### ローカル環境
Session Manager を使うために、Session Manager Plugin のインストールが必要。

``` sh
# macOS での手順
cd /tmp
curl "https://s3.amazonaws.com/session-manager-downloads/plugin/latest/mac/sessionmanager-bundle.zip" -o "sessionmanager-bundle.zip"
unzip sessionmanager-bundle.zip
sudo ./sessionmanager-bundle/install -i /usr/local/sessionmanagerplugin -b /usr/local/bin/session-manager-plugin
rm -rf sessionmanager-bundle sessionmanager-bundle.zip

## インストールの確認
$ session-manager-plugin

The Session Manager plugin was installed successfully. Use the AWS CLI to start a session.
```


### Logging

### ログの永続化
CloudWatch Logs は便利だが、ストレージとしては割高。
そこでログを S3 バケットに永続化する！ログ永続化は Kinesis Data Firehose と連携させることで実現。

ECS -> CloudWatch Logs -> Kinesis Data Firehose -> S3

### ベストプラクティス
- Terraform のバージョンを固定する
- プロバイダバージョンを固定する
    - 特に AWS プロバイダは進化が早く、環境差異が出やすい
    - terraform init を忘れない
- 削除操作を防止する
    - lifecycle -> prevent_destroy
- コードフォーマットをかける
    - 標準で実装されている！
    - `terraform fmt`
    - `terraform fmt -recursive`
    - `terraform fmt -recursive -check`
- バリデーションをかける
    - `terraform validate`
    - 注: サブディレクトリ配下までは実行されない
    - `terraform init` を事前に行う必要がある
- オートコンプリートを有効にする
    - `terraform -install-autocomplete`

``` sh
find . -type f -name '*.tf' -exec dirname {} \; | sort -u |\
    xargs -I {} terraform validate {}
```

- プラグインキャッシュを有効にする
- TFLint で不正なコードを検知する
    - `brew install tflint`
    - `tflint`
    - `tflint --deep --aws-region=ap-northeast-1`
        - invalid instance type のチェックなど、AWS API を使った詳細なチェック
        - クレデンシャルの設定が必要

### ベストプラクティス for AWS
- ネットワーク系デフォルトリソースの使用を避ける！
- データストア系デフォルトリソースの使用を避ける！
- 暗黙的な依存関係を把握する
    - リソースによっては、暗黙的に他のリソースに依存（EIP, NAT -> InternetGateway）
    - 暗黙的な依存関係はドキュメントに記載があることが多い
    - "depends_on" を定義して、依存関係を明示することで、正しい順番でリソース操作ができ、Terraform の動作が安定する
        - プログラム都合？
- 暗黙的に作られるリソースに注意する
    - サービスにリンクされたロール（Service-Linked Role）という、IAM ロールの特殊版が存在する

### 高度な構文
- 三項演算子
    - `instance_type = var.env == "prod" ? "m5.large" : "t3.micro"`
    - `terraform plan -var 'env=stage'`
- count というメタ引数による、複数リソース作成

``` terraform
resource "aws_vpc" "examples" {
    count = 3
    cidr_block = "10.${count.index}.0.0/16"
}
```

- 主要なデータソース
    - `data "aws_caller_identity" "current" {}`
    - `data "aws_region" "current" {}`
    - `data "aws_elb_service_account" "current" {}`
    - ハードコードを減らそう！
- 組み込み関数
    - file
    - `terraform console`
    - cidrsubnet("10.1.0.0/16", 8, 3)
    - Numeric Functions
        - max, floor, pow
    - String Functions
        - substr, format, split
    - Collection Functions
        - flatten, concat, length
    - Filesystem Functions

``` sh
#!/bin/bash
# install.sh
yum install -y ${package}
```

``` terraform
templatefile("${path.module}/install.sh", { package = "httpd" })
```

- ランダム文字列
    - Random プロバイダの random_string リソースを使う




## Memo
- AMI: Amazon Machine Image
- HCL: HachiCorp Configuration Language
- arn: Amazon Resource Name

### CLI
- Only 'yes' will be accepted to confirm.


## Questions
- How(Where) to get ami number?

### Terraform
- engress, ingress
- protocol = "-1"
