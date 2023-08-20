## [Amazon Route53 Resolver](https://www.youtube.com/watch?v=6nf6vIQha1g&list=PLzWGOASvSx6FIwIC2X1nObr1KcMCBBlqY&index=16&ab_channel=AmazonWebServicesJapan%E5%85%AC%E5%BC%8F)

### Route53 Hosted Zone

- 特定の VPC からの問い合わせと、それ以外からの問い合わせの識別 → 異なる応答
  - Public Hosted Zone
  - Private Hosted Zone
- Resolver 構成
  - フォワーダー
    - for VPC
  - フルサービスリゾルバー
    - for Internet

### Route53 Resolver for Hybrid Clouds

- 構成
  - Resolver Rule
  - Outbound Endpoint
  - Inbound Endpoint
    - VPC 内の Amazon Route53 Resolver にアクセスするための入り口
- オンプレから VPC 向けゾーンの名前解決
  - Inbound Endpoint
  - リゾルバールールの変更は不要
    - タイプ: 再帰
- オンプレからインターネット向けゾーン名前解決解決
  - リゾルバールールの変更は不要
- VPC からオンプレ向けゾーンの名前解決
  - **フォワーダーの**リゾルバールールに転送ルールを**追加する**
    - ドメイン: オンプレのネームサーバー
    - タイプ: 転送
  - フォワーダーからの参照では **Outbound Endpoint を通り、オンぷれのネームサーバーに**アクセスされる
- 転送ルールタイプ
  - 転送
  - システム
    - 上書きする
  - 再帰的
- エンドポイント
  - 1つにつき1ヶ月1万円ほどかかる
  - 実体は ENIs
    - 仕組み上セキュリティグループの指定が必須

### dig

- Header は重要
  - status, flags

### DNS クエリのログ記録

- 内容
  - 指定 VPC で発生するクエリとその応答
  - Inbound Endpoint
  - Outbound Endpoint
  - Firewall
- GuardDuty との連携
  - クエリのログ とは別の内容が連携される
    - 互いに干渉しない
  - DNS のリクエストとその応答のログが脅威検出の分析に利用される
  - EC2 インスタンスが AWS の DNS リゾルバーを使用している（デフォルト）場合のみ

### Firewall

- DNS のデータ保護
- アウトバウンド DNS トラフィックをフィルタリングする
- domain での設定
  - ip では無理よねそりゃ
- cf:
  - Network Firewall

### そのほか

- NAT64
  - IPv6 から IPv4 へのネットワークアドレス変換を行う
  - IPv4 サービスに向かう通信は NAT Gateway を経由
- DNS64
  - 名前解決の応答として IPv6 アドレスを返す
  - IPv6 が存在しない場合は IPv4 から合成する
- 料金
  - VPC 内のインスタンスからのクエリは無料
- TFP Fallback を想定し、TCP53 も開ける
  - [rfc7766](https://tex2e.github.io/rfc-translater/html/rfc7766.html)
- [初心者のための DNS 運用入門](https://dnsops.jp/event/20140626/dns-beginners-guide2014-mizuno.pdf)
