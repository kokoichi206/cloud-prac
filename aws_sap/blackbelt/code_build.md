## [AWS CodeBuild](https://www.youtube.com/watch?v=Zzv1_ztf-B0&ab_channel=AmazonWebServicesJapan%E5%85%AC%E5%BC%8F)

2020/11 の内容なので古いかもお

### AWS CodeBuild

- Build, Test のフェーズで使用
- フルマネージド
- CloudWatch によるモニタリング可能
- 実行方法
  - Management Console
  - CLI
  - Tools and SDKs
  - CodePipeline
- 仕組み
  - ビルドプロジェクト
  - ビルド環境
- 結果の通知
  - SNS
  - Chatbot
- ビルド仕様
  - buildspec ファイル
- 出力
  - S3 に送られたり
- ソースの作成

### buildspec.yml

- 構成要素
  - version
  - linux ユーザ
  - 環境変数
  - proxy サーバ設定
  - バッチビルド設定
  - コマンド
  - テストレポート
  - CodeBuild 出力
  - キャッシュ設定
- 必須は2つのみ
  - version
  - コマンド
- 
