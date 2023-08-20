## [Systems Manager Overview](https://www.youtube.com/watch?v=g5ndLFklyb4&list=PLzWGOASvSx6FIwIC2X1nObr1KcMCBBlqY&index=49&ab_channel=AmazonWebServicesJapan%E5%85%AC%E5%BC%8F)

### AWS Systems Manager: SSM

- **ハイブリッドクラウド環境**のための安全な**エンドツーエンドの管理ソリューション**
- 運用管理
- アプリケーション管理
- ノード管理

### SSM を使うには

- サーバを**マネージドノードにする**
  - EC2 の他、オンプレのインスタンスも含められる
  - step
    - SSM Agent の導入
      - Amazon Linux, Ubuntu など一部のオフィシャルイメージ（AMIs）には導入済み
    - アウトバウンド経路確保（以下のどちらか）
      - インターネット経由
      - VPC エンドポイント経由
    - マネージドノードにするために、権限付与
      - EC2 に明示的に付与（従来の方法）
      - デフォルトのホスト管理設定（DHMC）を有効に（新しい方法！）
        - 全インスタンスをマネージドにすることが容易に
        - Instance Metadata Service Version 2 (IMDSv2) が有効化されている必要
- オンプレミス
  - SSM でアクティベーションコードを生成

### SSM で始める運用管理

- SSM Agent
  - 任意のノードをリモートで管理
    - EC2 インスタンス
    - エッジデバイス
  - SSM Agent は SYSTEM(Windows), root(Linux) で稼働
  - [source code](https://github.com/aws/amazon-ssm-agent)
- Systems Manager ドキュメント
  - 実行するアクションを定義したもの
  - JSON or YAML
  - 主なドキュメントタイプ
    - Automation
    - Command
    - Session
    - Policy
- 運用管理
