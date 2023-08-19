## [CloudWatch の概要と基本](https://www.youtube.com/watch?v=fzVkJne3OMI&list=PLzWGOASvSx6FIwIC2X1nObr1KcMCBBlqY&index=33&ab_channel=AmazonWebServicesJapan%E5%85%AC%E5%BC%8F)

### オブザーバビリティ

- 可観測性
- **システムで何が起こっているかといった状況を把握てできている**状態のこと
  - 多くの場合、システムを計測（インストルメント）して、メトリクス・ログ・トレースを収集すること
- 運用上の優秀性・ビジネス目標を達成することにも役立つ
- システム状態把握に必要な３本柱
  - ログ
    - 予測不可能な振る舞いを発見するのに役立つ
    - CloudWatch Logs
  - メトリクス
    - 傾向の把握、予測に役立つ
    - CloudWatch Metrics
  - トレース
    - リクエストの流れと、リクエスト構造の両方を可視化することで因果関係の追跡に役立つ
    - AWS X-ray
- ＋イベント？
  - イベント＝状態の変化
  - モニタリングと業務機能双方で活用される
  - EventBridge
    - CloudWatch Events から派生したもの
    - パートナーサービスなどとも連携できるようになっている

### AWS におけるオブサーバビリティ

- AWS をフル活用するパターン
  - サービス
    - CloudWatch Logs
    - CloudWatch Metrics
    - AWS X-ray
  - 送信元は AWS Native Service 以外も可能
    - ADOT から X-ray, CloudWatch Metrics
    - FluentD や Fluent-bit から CloudWatch Logs 等
- Open Source のマネージドサービスを使うパターン

### CloudWatch

- 機能一覧
  - Infrastructure
  - Application Monitoring
  - Insights
- メトリクスとは
  - 時間感覚で計測されたデータの数値表現
  - EC2 の標準メトリクス
    - 5分間間隔での計測は無料
    - 詳細モニタリングの有効化で1分間の取得が可能
    - データの保管期間は解像度で異なる
- CloudWatch Metrics の考え方
  - データポイントの収集
    - 何かしらのメトリクス
    - 名前区間位含まれる
    - 位置に識別する dimension (instance id など) が振られる
  - Statistic
    - sum, max, min, average, percentile, trim, etc.
  - Period
    - どの間隔でポイントを打つか
    - 1 sec, 5 sec, 1 min, 1 hour, ...
- AWS サービス
  - 多くのサービスでメトリクスとログを標準で発行
- CloudWatch Metrics Insights
  - SQL ベースのクエリや選択式のビルダー
- Metrics Math
- メトリクスをアクションに繋げる
  - アラームの作り方
    - 静的閾値に基づくアラーム
    - Metrics Insights クエリによる CloudWatch アラーム
    - CloudWatch 異常検知に基づいたアラーム
    - 複合アラーム
  - アクション
    - SNS, EC2, Auto Scaling, Systems Manager
- CloudWatch Alarm
  - EC2, AutoScaling
  - SNS
  - EventBridge
    - StepFunctions
    - SystemsManager
- ログとは
  - タイムスタンプが記録された、時間お経過とともに起こったイベントの記録
- CloudWatch Logs
  - 仕組み
    - ロググループ
      - ログの保持期間
    - ログストリーム
    - ログイベント
- 統合 CloudWatch エージェント
  - CloudWatch Logs, Metrics 双方に対応しているエージェント
  - クラウドでもオンプレミスでも利用可能
  - Linux, Windows でも利用可能
  - インストール方法
    - コマンドラインで実行
    - SSM を活用
    - IaC で（CFn で合わせて Agent も導入）
      - Cloud Formations
      - AWS 以外でも使いたい場合はあまり適さないかも。。。
- Systems Manager
  - step
    - SSM Agent の導入
    - 統合 CloudWatch Agent の一括セットアップ
      - 設定ファイルを SSM ParameterStore へ格納
      - SSM RunCommand で CloudWatch Agent を一括インストール
      - SSM RunCommand で Parameter Store の設定を一括ロード
- CloudWatch Logs subscription
  - Lambda を活用した OpenSearch Service へのストリーミング
  - Kinesis Data Firehose を活用した S3 等へのデータ転送
- CloudWatch Internet Monitor
  - インターネットアクセスの状況評価
    - ラスベガスからのアクセスのパフォーマンスが落ちてる、など
- CloudWatch ServiceLens
  - X-Ray の状況なども
- CloudWatch Container Insights

### 他機能

- Dashboard
  - クロスリージョン・クロスアカウント対応
- Metrics Explorer
- Resource Health
  - EC2 の状況を自動で検出・視覚化
-

### そのほか

- Everything falls, all the time.
  - 形あるものは必ず壊れる
