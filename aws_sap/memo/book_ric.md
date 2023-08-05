## ストレージ

- [EBS](https://aws.amazon.com/jp/ebs/)
  - EC2 と**ネットワークで**接続される
    - ネットワークの帯域が用意できない場合、想定したストレージ性能が出ないことも
  - EBS 最適化（EBS Optimized）

## DB

- [DynamoDB](https://aws.amazon.com/jp/dynamodb/)
  - kay, value データストア
- [DocumentDB](https://aws.amazon.com/jp/documentdb/)
  - JOIN-like なデータ群をマネージドする用途に特化
    - XML, JSON などの半構造化データ
  - MongoDB 互換
  - ドキュメント指向 DB
    - アプリケーションで使いやすい形でデータを格納
  - フレキシブルなスキーマ
  - 豊富なアドホッククエリ、集計クエリ、柔軟なインデックス
    - DynamoDB との違い
    - RDB と死ぬほど大きな差はない (DynamoDB 比)
- [Neptune](https://aws.amazon.com/jp/neptune/)
  - グラフ DB

## Analytics

S3 などの保存料が安価になったことで、これまでアーカイブされていたデータも分析対象になった。

- Athena
  - S3 に保存されたデータに対し、標準 SQL を実行可能
  - クラスタノード・EC2 を持たない
- CloudSearch
  - マネージド型の検索機能
- Elasticsearch
  - CloudSearch はフラットな構造しか無理？
  - Kibana が標準でつく

## 統合

- SNS: Simple Notification Service
- SQS: Simple Queue Service
  - キューの数は監視可能 → Auto Scaling で EC2 インスタンス増やす等
  - DLQ: Dead Letter Queue
- SES: Email
- [elastictranscoder](https://aws.amazon.com/jp/elastictranscoder/)
  - S3 に保存された動画ファイルを変換し、変換後のファイルを CloudFront

## AI

- Rekognition
  - input として動画・画像を提供することで簡単に認識を実現可能
- [Polly](https://aws.amazon.com/jp/polly/)
  - テキストデータから音声データの変換
- Transcribe
  - 音声から言語を認識し、テキストに変換
- Comprehend
  - 自然言語の内容をインプットとし、話者の感情を推論
- Lex
  - 音声やテキストをインプットとし、対話型インタフェースを提供
  - Amazon Alexa のような自然言語大和ロボットを作りやすくなる！
- Forecast
  - 時系列予測サービス
- Personalize
  - レコメンデーションサービス

## セクリティ

- STS: Security Token Service
  - IAM に含まれる一機能
  - 一時的セキュリティ認証情報を発行する
  - シークレットキー・シークレットアクセスキーをアプリケーションに埋め込む必要がなくなる！！！
- KMS: Key Management Service
  - データの暗号化に用いられる暗号化キーの作成と管理を容易にするマネージドサービス
  - 利用者側で生成した暗号化キーのインポートも可能！
    - CMK: Customer Master Key
- CloudHSM
  - 暗号化キーを生成・管理するための専用ハードウェア
- Certificate Manager
  - ここで発行されたサーバー証明書のインポートが可能なサービス
    - ELB, CloudFront, API Gateway
    - EC2 はだめ！！！
- Shield
  - Standard, Advanced
- Secrets Manager
- GuardDuty
  - AWS 上での操作やづおさをモニタリングし、セキュリティ上の脅威を検出するサービス

## 管理

- CloudFormation
  - インフラ構成を JSON, YAML スクリプトで記述
  - 環境の自動構築
- CloudTail
  - API アクセスをログに記録するサービス
- Config
  - AWS リソースの構成管理サービス
  - AWS Config Rules
    - ルールに違反した構成変更の検知・通知
- OpsWorks
  - Chef や Puppet といったインフフラ構成管理ツールを利用
  - スタック、レイヤー、レシピ
- 

