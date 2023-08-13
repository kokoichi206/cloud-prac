## ネットワーク

- インスタンスからのアクセス
  - インターネットゲートウェイがアタッチされた VPC のパブリクサブネットで EC2 を起動
  - インタネットゲートウェイがアタッチされ、NAT ゲートウェイが起動している VPC のプライベートサブネットで EC2 を起動
  - VPC エンドポイントを設定
- VPC エンドポイント
  - ゲートウェイエンドポイント
    - コスト発生しない
  - インターフェイスエンドポイント
    - ENI: Elastic Network Interface
      - Privatelink
    - オンプレや他リージョンの VPC からのアクセスの場合は、この方が構成がシンプルになるかも
- VPN
  - AWS クライアント VPN
    - 運用負荷が少ない！
  - ソフトウェア VPN
    - VPN 接続両端を完全にコントロールする必要がある
- Active Directory
  - AWS Managed Microsoft AD
  - AD Connector
- SSO
  - 相互認証（証明書）
- AD
  - Simple AD
  - AWS Managed Microsoft AD
    - 5000 ユーザー以上
    - 他ドメインとの信頼関係
    - MFA

## 運用

- サービス
  - CodeGuru
    - ソースコードのレビューによって、バグや問題の抽出、パフォーマンスの最適化
  - CodeStar
    - CICD パイプライン
  - OpsWorks
    - Chef, Puppet
- CodeCommit
  - リポジトリサービス
- CodeBuild
  - ビルドとテスト
  - S3 や ECR の保存等
- CodeDeploy

### デプロイ

- ECS のデプロイ設定
  - Canary: カナリア
    - 最初一定の割合のみリリースした後、**指定した期間後に**残りのリリースをかんろうさせる
  - Linear: リニア
    - 最初一定の割合のみリリースした後、**指定した間隔でデプロイ対象を増分**
  - ECSAllAtOnce
    - 一度に全てのコンテナにデプロイ
- Lambda
  - バージョン
    - immutable
  - エイリアス
    - バージョンと紐付ける
  - 紐付けもを CodeDeploy の設定で割合指定できる
- CloudFormation
  - テンプレートをもとに、AWS リソースを**スタックという単位**で作成
  - DeletionPolicy
  - CreationPolicy
- AWS CDK
  - ソースコードから CloudFormation テンプレートを作成
- Elastic Beanstalk
  - 開発者が素早く AWS を使い始めることができるようにするサービス
  - 環境を複数作成可

### デプロイパターン

- ローリングデプロイ
  - 指定したバッチサイズずつ更新デプロイする！！！
- ブルー・グリーンデプロイ
  - 現在のアプリをブルー、新しいバージョンをグリーンとしてデプロイ
  - リクエストの送信先をブルーからグリーンに切り替えてリリースとする
- ブルー・グリーンデプロイパターン
  - Route53 の荷重ルーティングを用いる
  - ALB を用いる
    - ALB の設定に変更がない場合に使用できる
  - Auto Scaling
    - 一時的に希望するインスタンスを増やす
  - Elastic Beanstalk
    - eb clone コマンドで同じ環境の作成後、、、
  - CodePipeline + ECS
- SAM: Serverless Application Model
  - CloudFormation の拡張！
  - Serverless
    - S3, Lambda, API Gateway, DynamoDB

## Security

- ルートユーザーにしかできないタスク
  - アカウント設定の変更
  - アクセスキーの作成
  - IAM アクセスの有効化
  - MFA Delete
  - S3 バケットポリシーの修復
- ルートユーザー使用時に通知
  - GuardDuty
  - CloudWatch Logs

## Storage ?

- AWS Storage Gateway
  - オンプレから S3 などの AWS のストレージサービスを透過的に使用
    - オンプレのアプリデータのバックアップ先として AWS を使用できたりする
  - ゲートウェイ
    - S3 ファイルゲートウェイ
    - ボリュームゲートウェイ
      - iSCSI: Internet Small Computer System Interface
        - IP ネットワークを利用して SAN を構築するプロトコル規格
      - iSCSI ブロックストレージボリュームを必要とする時！
      - 保管型とキャッシュ型
    - テープゲートウェイ
    - FSx ファイルゲートウェイ

## RPO, RTO

- シナリオ4つ
  - バックアップ & リカバリー
  - パイロットライト
  - ウォームスタンバイ
  - マルチサイト アクティブ/アクティブ
- AWS Global Accelerator
  - ヘルスチェク
    - トラフィック転送を即時開始
  - 固定化されたエニーキャスト IP アドレスを使用するので、DNS キャッシュの影響を受けない
- AWS Fault Injection Simulator
  - 災害時に発生しうる状態をシミュレーション
  - 特定のサブネットへのトラフィックを止めたり、インスタンスを停止したり
- 疎結合アーキ
  - SNS: FIFO トピック
  - SQS: FIFO キュー
  - DLQ: 障害時にメッセージが失われないようにする
- DB
  - RDS Proxy
  - Aurora サーバーレス
    - Data API
      - RDS Proxy の代わり？みたいなもの？
      - Secrets Manager が必要
- Auto Scaling
  - スケーリングポリシー
    - スケジュール
    - シンプルスケーリングポリシー
      - クールダウン
    - ステップスケーリングポリシー
      - ウォームアップ
    - 予測スケーリングポリシー
  - クールダウン
    - 一定期間経過するまで、次のスケールアクションは行われない
  - ライフサイクルフック
- Route53
  - 連携可能サービス
    - ヘルスチェック
    - SNS
    - CloudWatch
  - フェイルオーバールーティングポリシ
  - 位置情報ルーティングポリシー
  - レイテンシールーティングポリシー
- Quotas
  - サービス使用量の制限確認
  - クォータモニタ

### パフォーマンス

- インスタンスタイプ
  - m6g.large
    - m: ファミリー
    - 6: 世代
    - g: 追加機能
    - large: サイズ
  - 追加機能
    - d: インスタンスストアが使用できる
    - n: ネットワーク強化
    - a: AMD プロセッサ搭載
    - g: Graviton プロセッサ搭載
      - EC2 に最高のパフォーマンスを提供できるよう AWS が設計しているもの
  - インスタンスファミリー
    - 汎用
      - T3, T4g, M5, M6g, A1
    - コンピューティング最適化
      - HPC, 機械学習推論、メディアトランスコード
      - C5, C7g
    - メモリ最適化
      - 大きなデータセット処理
      - R5, R6g, X1
    - 高速コンピューティング
      - 機械学習推論、GPU グラフィックス処理
      - P4, G5, F1, Trn1
    - ストレージ最適化
      - ビッグデータ処理
      - I3, D3, H1
  - バーストパフォーマンスインスタンス
    - T2, T3, T3a, T4g
    - ベースラインを超えた CPU 利用を、クレジットから補填できる
      - ベースラインに満たないときはクレジットに貯蓄される
  - 拡張ネットワーきんぐ
    - シングルルート I/O 仮想化: SR-IOV
  - プレイスメントグループ
    - クラスタ
    - パーティション
    - スプレッド
- S3
  - マルチパートアップロード
    - アップロードが完了せず、不完全な状態で残ってしまったものも、ストレージ料金の対象になる
      - ライフサイクルポリシーで自動削除が可能
  - Transfer Acceleration
    - S3 のバケットから離れた地域からのアップロードが実行される場合の、レイテンシー改善
- DynamoDB
  - パーティションキーの値のハッシュ値によって分散保存される
  - キーの設計に注意
    - 日付での設計においては、suffix をつけたりとか
- CloudFront
  - Web コンテンツ配信
  - オリジンへのアクセス制限
    - S3
      - OAC: Origin Access Control
    - ALB
      - カスタムヘッダー
      - IP アドレス制限
  - 動画配信
    - S3 にアップロードされた動画を、Elemental MediaConvert で HLS などに変換 → S3 に保存
      - CloudFront から配信
    - Medialive, MediaStore, CloudFront のコンボもある

## links

- https://aws.amazon.com/jp/architecture/well-architected/?wa-lens-whitepapers.sort-by=item.additionalFields.sortDate&wa-lens-whitepapers.sort-order=desc&wa-guidance-whitepapers.sort-by=item.additionalFields.sortDate&wa-guidance-whitepapers.sort-order=desc
- https://explore.skillbuilder.aws/learn
  - https://explore.skillbuilder.aws/learn/external-ecommerce;view=none;redirectURL=?ctldoc-catalog-0=l-_ja~se-SAP
- https://www.youtube.com/playlist?list=PLzWGOASvSx6FIwIC2X1nObr1KcMCBBlqY
