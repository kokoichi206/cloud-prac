## sec 0
継続的にビジネスを発展させるために、テクノロジーを駆使して失敗に対する影響を最小限にしつつ、スピーディに利用者価値を提供していくことが重要。これを実現するキーテクノロジーの１つがパブリッククラウドとコンテナ技術。

Kubernetes は開発が活発がゆえに、バージョンアップも頻繁で小規模な組織では追従してくことが大変。

## sec 1
「コンテナ」とは他のプロセスとは隔離されたあ状態でOS上にソフトウェアを実行する技術。

コンテナ利用におけるアプリケーションでは、依存関係を含めたパッケージがリリース単位。

コンテナのメリット：優れた再現性とポータビリティ。
アプリ単位の再現性が担保される。
プロセス単位なので起動が高速。

コンテナの代表的なプラットフォームが Docker であり、**コンテナのライフサイクルを管理するためのプラットフォーム！**
「Build, Ship, Run !」

コンテナオーケストレータ
- Kubernetes
    - OSS
- Amazon ECS
    - AWS の完全なサポートが受けられる

オーケストレータとして ECS, ホスト OS として Fargate, レジストリとして ECR という立ち位置。


## sec 2
Kubernetes は Kubenetes コントロールプレーンと Kubenetes ノード（Worker ノード）から構成されている。
Kubernetes を運用する上で最も難しいことは、コントロールプレーンを健全に保つこと。EKS を利用することで、Kubernetes コントロールプレーンの管理を AWS に委ねることが可能。

Fargate: ECS と EKS の両方で動作する、コンテナ向けサーバーレスコンピューティングエンジン。ホスト管理が不要になる！

ECS or EKS（コントロールプレーン）の軸と、on EC2 or on Fargate（データプレーン）の軸。

Fargate: ECS Exec により、コンテナに対して対話型のシェル　or １つのコマンドが実行可能となった。

Fargate は製薬として GPU 未対応。

[AWS roadmap](https://github.com/aws/containers-roadmap/projects/1)


## sec 3
Well-Architected フレームワークの５つの柱

- 運用上の優秀性
- セキュリティ
- 信頼性
- パフォーマンス効率
- コスト最適化

システム全体を俯瞰しつつ、内部状態まで深掘りできるような状態を「オブザーバビリティ（可観測性）」という。

### ロギング
ECS/Fargate 構成でのアプリケーションログの収集方法として、CloudWatch Logs を活用する方法と FireLens を活用する方法が考えられる。

ログドライバーとして FireLens を指定すると、ログ保存観点のコスト最適化と障害時運用の両立が図れる。
Fluent Bit は CloudWatch Logs と S3 への同時ログ転送に対応している。

### トレース設計
「X-Ray」：トレース情報の取得をサポートするサービス。

### CI/CD
AWS が提供するマネージド CI/CD サービス、CodeXxx。

- 影響分離の観点やインフラレイヤでの品質担保の観点から、プロダクション環境とは別にステージング環境を設けたい。
- 開発効率化の観点からステージング環境とは別に開発環境を用意したい
- ガバナンス強化の観点からプロダクション環境の CI/CD パイプラインは他の環境から分離したい
    - アカウントを環境ごとに用意
    - リソースが分離してしまうのを防ぐため、共有リソースようアカウントも用意

#### パイプラインファーストな思想
クラウドの利点を最大限活用する、という観点でクラウドネイティブを推進する際のキーファクター！
アプリケーション開発が本格化する前に CI/CD パイプラインを用意する。

#### イメージタグのルール
ルールを決めてそれに統一させればいいが、決まってないのであれば、環境ごとの識別子+コードリポジトリのコミットID付与、が良さげ。

### セキュリティ
[セキュリティドキュメント](https://docs.aws.amazon.com/ja_jp/security/)

[NIST SP800-190](https://www.tis.jp/special/platform_knowledge/cloud16/)

- イメージへの脆弱性
    - ECR のイメージプッシュ時スキャンを有効に
    - Trivy 等
    - スキャンを継続的かつ自動的に実施する
- イメージ設定の不具合
    - CIS (The Center for Internet Security)
    - Dockle 等
- コンテナからの無制限ネットワークアクセス
    - WAF
        - 連携可能
            - CloudFront
            - ALB
            - API Gateway

### 信頼性設計
障害、復旧、可用性、自動

Everything fails all the time. -> Design for Failure

ALB ターゲットグループに ECS タスクを登録しておくと、ECS タスク障害時に ALB 側が対象の ECS タスクをターゲットから自動的に除外する。

メンテナンス時の Sorry コンテンツ、Sorry ページ。ALB リスなルールの優先度を変更することで可能。


## sec 4
デフォルト VPC はデフォルトルートの宛先が Any(0.0.0.0/0) となっており、プロダクション環境のネットワーク設定として使うには不十分。せってミスを防ぐためにも、アカウント作成後にデフォルト VPC を削除する人も多い！

[使わせてモらた cloudformation](https://github.com/uma-arai/sbcntr-resources/blob/main/cloudformations/network_step1.yml)

### Cloud9
マネジメント用のコンソール用意。慣れてる人はローカルでよい。
Cloud9 の実態は EC2 インスタンス。

Cloud9 はデフォルトではログインした AWS ユーザーの権限で自動的に認証権限が設定される仕組みがある！

AWS Managed TEmporary Credentials (AMTC)

### サンプルのアプリ用意
```
git clone https://github.com/uma-arai/sbcntr-frontend.git

node -v
npm i -g nvm

nvm ls-remote | grep v14.16.1
nvm install v14.16.1
nvm alias default v14.16.1
node -v

npm i -g yarn

cd /home/ec2-user/environment/sbcntr-frontend/
yarn install --pure-lockfile --production

npx blitz -v
```

```
cd /home/ec2-user/environment/
git clone https://github.com/uma-arai/sbcntr-backend.git
cd /home/ec2-user/environment/sbcntr-backend/
```

本来、フロントエンドとバックエンドのアプリケーションは別サブネットにおくことが多いが、今回はわかりやすさのために同一サブネットにしている。

### ECR
KMS 暗号化を有効に。
ECR は VPC 内ではなくリージョンごとに存在するリージョンサービスなため、VPC 内の管理サーバ上から ECR にアクセスするためには、インターネット向けの Outbound 通信が可能か、VPC エンドポイントによる内部アクセスが必要となる。

エンドポイントには以下サービスが必要

- インタフェース型
    - ecr.api
    - ecr.dkr
- ゲートウェイ型
    - com....s3

``` sh
# aws_account_id 等取得方法
aws sts get-caller-identity
```

Cloud9 で提供されている AMTC を OFF にし、VPC エンドポイント経由で操作できるように準備。

### コンテナアプリケーションの登録
``` sh
docker image rm -f $(docker image ls -q)
docker image ls

cd xxx-backend
docker image build -t sbcntr-backend:v1 .

docker image ls --format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}"
```

ECR 内のコンテナイメージを AWS アカウントごとに識別している関係上、IMAGE ID として**決められた形式**で登録する必要がある！

``` sh
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)

docker image tag sbcntr-backend:v1 ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-backend:v1
docker image ls --format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}"
```

``` sh
# 
aws configure
# ECR への等小禄は Docker CLI ベースで実施
aws ecr --region ap-northeast-1 get-login-password | docker login --username AWS --password-stdin https://${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-backend

aws ecr --region ap-northeast-1 get-login-password | docker login --username AWS --password-stdin https://${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-backend



docker image push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-backend:v1
```

ECRリポジトリでDockerクライアント認証がエラーになってしまうので、１回保留。
terraform の方をやる。









## メモ
- GA: (General Availability:一般利用可能)
