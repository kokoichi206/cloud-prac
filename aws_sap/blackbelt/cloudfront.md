## [CloudFront Cache Control](https://www.youtube.com/watch?v=acdiWZK2Z0Y&list=PLzWGOASvSx6FIwIC2X1nObr1KcMCBBlqY&index=24&ab_channel=AmazonWebServicesJapan%E5%85%AC%E5%BC%8F)

### CloudFront について

- エンドユーザーの近くに探しに行く
- 通信のレイテンシーをカイン
- CDN: Content Delivery Network
  - オリジンサーバーからのデータを、近くの拠点でキャッシュ
  - オリジンの負荷をオフロード
- メリット
  - グローバルインフラストラクチャ
  - エッジロケーションをキャッシュサーバーとして活用
  - さまざまな機能や他の AWS サービスとの連携
    - エッジ関数の実行
    - TLS/SSL 終端
    - セキュリティ対策
- REC
  - リージョナルエッジキャッシュ

### 運用方法について

- キャッシュ戦略
  - どういうコンテンツがあるか
  - コンテンツ更新の頻度
  - 誰がどういう方法でキャッシュを更新するか
- 更新方法
  - ファイル名にバージョン識別子を使用して更新する
  - 同じ名前を使用してファイルを更新する
    - メタ情報（ヘッダーとか）をうまく使っている
      - etag
      - last-modified
- キャッシュ期限が切れた後の挙動について
  - キャッシュしたコンテンツに変更がない場合
    - Etag/LastModified といったコンテンツに紐づいてるヘッダーの値を用いて、オリジンサーバーに確認のリクエストを送る
      - If-Modified-Since
    - レスポンスとして上記の値に変更がなければ、304 が返ってきて、コンテンツのキャッシュ期間は更新される
      - x-cache
  - キャッシュしたコンテンツに変更がある場合
    - 200 と新しいコンテンツが帰ってくる
      - x-cache
- キャッシュキーを用いて別のコンテンツとしてキャッシュする
  - クエリの中のものとか

### Cache Policy

- パスごとに設定が可能
- 3つのセクション
  - TTL 設定
    - Cache-Control, Expires ヘッダーに連動
  - キャッシュキー設定
    - ヘッダー、クエリ、Cookie の要素を指定できる
  - 圧縮サポート
- コントロール機能
  - GET/HEAD/OPTION のみ
  - TTL = 0 は、CloudFront ではキャッシュしない

### [レポート/モニタリング/ロギング](https://www.youtube.com/watch?v=tIkfu7NAeQE&ab_channel=AmazonWebServicesJapan%E5%85%AC%E5%BC%8F)

- CloudFront コンソール
  - キャッシュ統計
    - ダウンロードを完了しなかった GET リクエストの割合など
  - 人気オブジェクト
    - ディストリビューションごとのリクエスト数 top50 とか
  - トップリファラー
  - ビューワーの情報
    - デバイス種別
    - ブラウザ
    - OS
    - ロケーション
- モニタリング機能
  - CloudWatch と統合された機能
  - バージニア北部に出力
  - CloudFront Functions
  - CloudWatch Internet Monitor
    - インターネットからアクセスした際の可用性とパフォーマンスのメトリクス
- ロギング機能
  - リクエストのログ
    - 標準ログ
      - S3 に保存
      - S3 Select
        - 標準ログに対して、クエリを実行することが可能
      - Athena
        - アテナ
        - **複数の標準ログに**対して、クエリを実行
      - QuickSight を使用した可視化: BI
        - テーブル情報を可視化
    - リアルタイムログ
      - Kinesis Data Streams に連携
      - OpenSearch Service と組み合わせて、運用ダッシュボードを作成可能
      - CMCD: Common Media Client Data + Grafana
  - エッジ関数のログ
    - CloudFront Functions のログ
      - console.log() ステートメント
  - サービスアクティビティのログ
    - CloudTail による API アクティビティのログ


### Tips

- Origin Request Policy
  - オリジンに転送するリクエストとキャッシュキーを分離して取り扱うことにより、柔軟なキャッシュ設定が可能

### そのほか

- [クエリ文字列パラメータに基づくコンテンツのキャッシュ](https://docs.aws.amazon.com/ja_jp/AmazonCloudFront/latest/DeveloperGuide/QueryStringParameters.html)
