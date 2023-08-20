## [S3 コスト最適化](https://www.youtube.com/watch?v=EeJhcsScWIo&list=PLzWGOASvSx6FIwIC2X1nObr1KcMCBBlqY&index=15&ab_channel=AmazonWebServicesJapan%E5%85%AC%E5%BC%8F)

- 1G のオブジェクトを 1000 個
  - 年300ドル
  - コスト最適化後
    - 年24.9ドル

### ストレージサービス

- OBJECT
  - S3
- BLOCK
  - EBS
- FILE
  - EFS
  - FSx
- BACKUP
  - AWS Backup

### オブジェクトストレージとは

- 特徴
  - **HTTP/HTTPS** でアクセス
  - **一意のキー**に対するオブジェクト（データ）が存在
  - 階層構造をとるファイルストレージとは異なり**フラットな構造！**
- メリット
  - スケールが容易で、大容量のデータ保存が可能
  - オブジェクト単位でのアクセス制御
  - 高い可用性と耐障害性
  - カスタマイズしたメタデータ追加可能

### S3

- 耐久性
  - 最低３つの AZ
- 継続的な値下げ
- ストレージクラスの登場
- 代表的な料金
  - ストレージ
  - リクエスト
    - 静的ファイルのホスティングに注意
  - データ転送
- オブジェクトタグ
  - key, value
  - 10 個まで設定可能
- Storage Lens
  - ダッシュボード
- ストレージクラス分布
  - ストレージクラスのレコメンド
  - 標準 or 標準 IA クラスの推奨のみが対応
- S3 インベントリ
  - オブジェクトのリストを表示

### ストレージクラス

- S3 標準- 低頻度アクセス IA
  - データ取り出し料金
  - 最低保存期間
  - 最小オブジェクトサイズ
  - 45％ほどの料金
- Glacier
  - Instant Retrieval
    - m秒単位のアクセス
    - 20％ほどの料金
  - Flexible Retrieval
    - 迅速取り出し
      - 250MB までだが、1-5 分！！
    - 標準取り出し
      - 3-5 時間！
  - Deep Archive
    - 標準 12 時間以内

### 継続的なサイジング

- アプリから直接アップロードする場合
  - ストレージクラスを指定して PUT
- 利用頻度がある程度予測可能な場合
  - ライフサイクルポリシー
    - フィルター
      - **最小・最大オブジェクトサイズ**
      - たぐ
      - プリフィックス
    - アクション
      - クラスの移動
      - オブジェクトの削除
      - 不完全なマルチパートアップロードの削除
      - 非現行バージョンのストレージクラス変更・削除
- データの利用頻度が予測不可能な場合
  - Intelligent-Tiering

### そのほか

- [Amazon S3 Glacier ストレージクラスへのログの圧縮とアーカイブ](https://aws.amazon.com/jp/blogs/news/compressing-and-archiving-logs-to-the-amazon-s3-glacier-storage-classes/)
  - ログデータは圧縮してからクラス変更するなど、データサイズが大きいほど有効
