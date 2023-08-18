## [Amazon ElastiCache](https://www.youtube.com/watch?v=-NU1U8_fxo4&list=PLzWGOASvSx6FIwIC2X1nObr1KcMCBBlqY&index=46&ab_channel=AmazonWebServicesJapan%E5%85%AC%E5%BC%8F)

### 概要

- Purpose-build databases
  - relational
  - key value
  - document
  - in memory
  - graph
  - time-series
  - ledger
  - wide column
- in memory
  - パフォーマンス マイクロ秒レイテンシ
  - 100 万リクエスト/s
- インメモリデータベースのパフォーマンス
  - 高速: メモリは **SSD より少なくとも 50 倍高速**
  - 予測可能: **キーインデクシング、ディスクシークなし**
- 基本用語と概念
  - フルマネージドなインメモリ db
  - redis & memcached 互換
  - セキュア
- memcached
  - 2003 リリース
  - シンプル、インメモリ、LRU キャッシュ
  - 単純な key-value ストア
  - シンプルなため**マルチスレッドで動作可能**
  - スケーリングが容易
  - 永続化はサポートしない
- redis
  - 2009
  - 豊富なデータ構造
  - レプリケーションによる高可用性
  - スナップショット・リストアによる永続性
  - LUA スクリプティング
- インメモリ耐久性スペクトラム
  - elasticache for memcached
    - 揮発性
  - elasticache for redis
    - 半耐久性
    - スナップショット + 非同期レプリケーション
  - memoryDB for redis
    - 耐久性
    - マルチ AZ トランザクションログ
- インメモリ DB はセルフマネージが難しい

### ElastiCache for Redis

- データ型
  - string, list, set, sorted set, hash, streams, geospatial,..
- Cluster Mode Disabled
  - 特徴
    - 1 つのプライマリノードと、0-5 個のレプリカ
    - プライマリへの書き込み
    - プライマリとレプリカの読み取り
    - MultiAZ & 自動フェイルオーバー
  - 垂直スケーリング
    - 以下の変更がダウンタイムなしで行える
      - instanctype.large
      - instanctype.2xlarge
- Cluster Mode Enabled
  - 特徴
    - 1つのプライマリノードと、シャードごとに 0-5 個のレプリカ
    - 最大500のーど
    - シャードの追加・削除
  - 水平スケーリング
    - スロットを分割する

### ユースケース

- キャッシングの概念
  - RDS に読み込み・書き込み
    - クエリの応答時間をカイン
    - サービスからの負荷を軽減
  - RDS 以外にも、さまざまなもの前におくことを検討できる
  - Lazy Loading
    - step
      - キャッシュから読み込む
      - ソースから読み込む（ない場合）
      - キャッシュに書き込む
      - （一定時間後にそのデータは消す）
    - 長所
      - 不要なデータを避ける
      - 即効性
    - 短所
      - キャッシュミスは高額になるかも
      - データの新鮮さ
  - Write Through
    - step
      - ソースに書き込む
      - lambda 関数をトリガーする
      - キャッシュを更新する
    - 長所
      - データが古くなることはない
      - 書き込みは待てるが、読み込みのレイテンシ要件がシビアな時
    - 短所
      - 不要なデータ、キャッシュの死蔵
- ユースケース
  - セッションストア
  - 地理空間情報
  - チャットアプリ
  - メディアストリーミング
- セッションストア
  - スケールイン・アップが可能になる
- メッセージキュー
- 地理空間クエリ
  - 現在地に近くにいる人・場所の検索とか！
    - へーーー
  - geo-based queries

### 重要・最新機能

- auto scaling
  - シャードやレプリカを自動的に追加する
  - cloud watch メトリクスを使用して水平方向にスケールイン・スケールアウトする
- データ階層化機能を備えた r6gd ノード
  - データ自体が大きく、その一部にしかアクセスしないようなワークロードに向いている
  - RAM + SSD の構成
- SLA が 99.99% に
  - redis 6.2 以降
  - multi-az 必須
- redis7 をサポート
  - shared pub/sub
  - 既存クラスターの転送中の暗号化
  - enhanced i/o multiplexing
