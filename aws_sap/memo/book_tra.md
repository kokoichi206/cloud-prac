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

## links

- https://aws.amazon.com/jp/architecture/well-architected/?wa-lens-whitepapers.sort-by=item.additionalFields.sortDate&wa-lens-whitepapers.sort-order=desc&wa-guidance-whitepapers.sort-by=item.additionalFields.sortDate&wa-guidance-whitepapers.sort-order=desc
- https://explore.skillbuilder.aws/learn
  - https://explore.skillbuilder.aws/learn/external-ecommerce;view=none;redirectURL=?ctldoc-catalog-0=l-_ja~se-SAP
- https://www.youtube.com/playlist?list=PLzWGOASvSx6FIwIC2X1nObr1KcMCBBlqY
