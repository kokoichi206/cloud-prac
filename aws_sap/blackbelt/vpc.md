## [VPC](https://www.youtube.com/watch?v=JAzsGRS_o4c&list=PLzWGOASvSx6FIwIC2X1nObr1KcMCBBlqY&index=180&ab_channel=AmazonWebServicesJapan%E5%85%AC%E5%BC%8F)

### VPC について

- データセンターのこれから
  - クラウドで仮想ネットワークを構築
  - クラウドの悩み・不安
    - インターネット接続部分のスケールアウト
    - 冗長性？
    - 社内と専用線で接続したい
    - セキュリティ面
  - VPC でそれらを解決！
- VPC
  - 論理的なネットワーク分離
    - 必要に応じて接続
  - ネットワークのコントロールが可能
- VPC のコンポーネント
  - 死ぬほどある
- 組み方概要
  - まず全体のネットワーク空間を VPC として定義
- step
  - アドレスレンジを選択
    - 今どきクラスなんてない！
    - 1つ目のアドレスぶろくは変更できない！
  - AZ における subnet を選択
    - az は1つ以上のデータセンターで構成される
    - 最短で 1m sec くらい az 間では離れている
      - 100 km くらい
    - サブネットに対して AZ とアドレスを選択
    - **サブネットで利用できない IP アドレス**（/24 の例）
      - 0: ネットワークアドレス
      - 1: VPC ルータ
      - 2: Amazon が提供する DNS サービス
        - Route53 resolver
      - 3: AWS で予約
      - 255: ブロードキャスト（VPC ではブロードキャストはサポートされてない）
  - インタネットへの経路を設定
    - パケットがどこに向かえば良いかを示すもの
    - 作成時にデフォルトで1つルートテーブルが作成される
    - **subnet を跨ぐときは必ず仮想ルータを通る**
      - テーブルの Look Up
      - **EC2 からはデフォルトゲートしか向かわない！**
    - public subnet
      - internet gateway を通る時のみ public ip を使う
  - VPC の IN/OUT トラフィックを許可
    - セキュリティグループ: SG In Out
      - ステートフル Firewall
      - subnet から EC2 インスタンスに出る時と入る時
      - **ホワイトリスト型**
      - 全てのルールを適応
    - Network ACLs
      - ステートレス Firewall
      - subnet 単位で適応
      - Internet gateway から subnet に出る時と入る時
      - **ブラックリスト型**
        - allow, deny
      - 番号の順序通りに適応

### Ingress Routing

- IG, VGW に対するアウトバウンド・インバウンド双方のトラフィくを特定のインスタンスの ENI に向けることができる
- VPC に出入りする全トラフィックが特定 EC2 インスタンスを通過することを強制
  - IDS/IPS や Firewall による監視・通信制御を効果的に実行可能

### ハイブリッド接続

- VPC とプライベートネットワーク接続
  - VPN 接続
    - Site-to-Site VPN
      - 1つの VPN 接続は 2 つの IPSec
      - ルーティングはできればダイナミック（BGP）にしたい
    - エンドポイントを利用した Client VPN
      - Client VPN エンドポイント
        - マネージドである
  - 専用線接続
    - Direct Connect を利用、一貫性のあるネットワーク接続
    - ルーティングは BGP のみ
    - 接続先
      - VPC
      - AWS クラウド
      - Transit Gateway
- Direct Connect Gateway
  - Hub となり、同一アカウントに所属する複数のリージョン・ロケーションから複数の VPC に接続できる機能
- 冗長化
  - VPN と Direct Connect
  - Direct Connect が優先される
- Transit Gateway
  - **Multicast 対応！**

### そのほか

- Amazon Time Sync Service
  - NTP サーバーの IP アドレスとして用意されてるものがある
- VPC Traffic Mirroring
  - 脅威検出（フォレンジック）
  - コンテンツモニタリング
  - 問題判別
