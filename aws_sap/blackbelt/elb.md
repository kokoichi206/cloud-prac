## [Elastic Load Balancing](https://www.youtube.com/watch?v=gKCK0RDAhnw&list=PLzWGOASvSx6FIwIC2X1nObr1KcMCBBlqY&index=18&ab_channel=AmazonWebServicesJapan%E5%85%AC%E5%BC%8F)

ネットワークソリューション部

### ELB

- VPC 上のロードバランサー
- 目的
  - スケーラビリティ
  - アベイラビリティ
- 特徴
  - オートスケール
  - 重量課金
  - マネージド
- ELB 自体もスケーラブル
- 種類
  - ALB
    - L7 のコンテントベース
  - NLB
    - L4 + TLS オフロード
  - CLB
    - 過去のもの
- コンポーネント
  - スキーム
    - public ip を設定してインターネットに公開するか
  - リスナー
    - ELB が Listen するプロトコルとポート番号を決定
  - ターゲットグループ
    - リスナーに対して設定
  - ターゲット
    - ELB がトラフィックを転送する EC2 インスタンスなどのリソースやエンドポイント
- ターゲットタイプ
  - インスタンス
  - IP アドエrす
  - Lambda 関数
  - ALB
    - NLB のターゲットに ALB を指定、など
- VPC への設置
  - AZ ごとに1つのサブネットを指定
  - ALB は2つ以上の AZ を必ず利用
- セキュリティグループ
  - ALB はセキュリティグループを指定できる
- クライアントからのアクセス
  - FQDN が付与されるので、それを利用する
  - IP を直接指定するのは非推奨
  - 特に ALB は IP アドレスがスケールアウトするため非推奨
- NLB
  - 暖気不要で、数百万リクエスト/s も捌ける

### 負荷分散

- 2 パターン
  - DNS ラウンドロビン
  - ルーティング時の分散
- ルーティングアルゴリズム
  - ALB
    - ラウンドロビン
      - デフォルト
    - 最初海処理リクエストルーティング
  - NLB
    - フローハッシュアルゴリズム
    - プロトコル、送信先・送信元アドレス、送信先・送信元ポート、TCP シーケンス番号が一致している通信をフロートみなす
      - 一致している場合は同じターゲットにルーティングする
- クロスゾーン負荷分散
  - ALB はデフォルトで有効
  - NLB はデフォルトで無効
- ターゲットグループの正常性
  - 正常ターゲット数を下回った動きの設定
    - 名前解決の結果から消える
  - ルーティングフェイルオーバー
- コネクションタイムアウト
  - ALB
    - 1-4000s で設定可能
  - NLB
    - 350s で固定
- スティッキーセッション
  - デフォルトでは無効
  - ALB では Cookie ベースで制御
  - NLB では送信元 IP アドレスベース
- ヘルスチェック
  - ELB は正常なターゲットにのみトラフィックをルーティングする

### セキュリティ

- SSL/TLS termination
  - ELB 側で SSL/TLS 終端できる
  - パターン
    - ELB で SSL 終端し、ターゲットとの通信は SSL なし
      - バックエンドの EC2 とは SSL 処理せずに済む
      - 負荷をオフロードできる
      - 基本はこれ
    - ELB で SSL 終端し、ターゲットとは別途 SSL
    - ELB では SSL 終端せず、ターゲットに TCP リスナーで送信、バックエンドで SSL
      - NLB のみ
- セキュリティポリシー
  - SSL/TLS 利用時、事前定義されたセキュリティポリシーを利用
- ACM
  - 無料で証明書を利用可能
  - ELB に対する証明書の設定を数クリックで完了
  - 自動更新
  - **ドメイン認証タイプなので、より上位（OV, EV）を利用するには、サードパーティの証明書を取得し、インポートが必要**

### IPv6

- IPv6 Single Stack は不可
- インターネット向け、内部向け双方に対応

### ALB 固有機能

- 特徴
  - L7 ロードバランサー
  - HTTP/HTTPS, ws, grpc に対応
  - リスナールールによるコンテンツベースのルーティング
  - ユーザー認証機能
  - ネイティブ HTTP/2
  - lambda 関数
  - xff ヘッダでクライアントの ip を記録
  - waf との連携
- コンテンツベースのルーティング
  - パスベースのルーティング
  - ホスト名ベースのルーティング
- ユーザー認証機能
  - Cognito による認証
  - OIDC IdP による認証
- 加重ターゲットグループ
  - 1つのリスナーに、ヒュくすうのターゲットグループを設定し、割合を設定できる
  - Blue-Green デプロイをしたい場合に活用できる

### NLB 固有機能

- 特徴
  - L4
  - 高スループット、低レイテンシ
  - 固定 IP
  - 送信元 IP, port の保持
    - 透過的
  - ALB をターゲットに指定可
- source ip/port の保持
  - target はクライアントと直接通信してるかのように見える
- ターゲットタイプ ALB
  - ALB に対して固定 IP でアクセスしたい
  - ALB 配下のアプリケーションサービスを PrivateLink で別 VPC に提供したい
  - HTTP/HTTPS と他のプロトコルを併用するようなアプリケーションを構成したい
- TCP では VPC Flow Log で代替
- **セキュリティグループはない**

### 他サービスとの連携

- Auto Scaling
  - ELB のヘルスチェックの結果を Auto Scaling に反映可能
- ECS との連携例
  - 動的ポートマッピング
  - ECS のコンソール画面で連携可能
- WAF
  - リクエストレートによるアクセス制限
  - クロスサイトスクリプティングや SQL インジェクションからの保護
  - フェイルオープンを設定可能
- AWS Global Accelerator との連携
  - エンドポイントに ALB, NLB を指定できる
  - ALB の IP を固定に見せることもできる
- lambda をターゲットにする