## AVP: Amazon Verified Permissions

- [Amazon Verified Permissions](https://aws.amazon.com/jp/verified-permissions/)
- 認可の責務を AVP に委譲する
  - アプリケーション変更なしに
  - リアルタイムに
  - 誰が何にアクセス許可・不許可を設定できる
- [Cedar (シーダー)](https://aws.amazon.com/jp/about-aws/whats-new/2023/05/cedar-open-source-language-access-control/)
  - AWS が開発した言語
  - 数 msec でレスポンスがかえる
- 認証と認可
  - 認証は1回通したらセッション期間は
  - 認可は常に使うのでレスポンスが遅いと困る
- tips
  - 要素は一意にする
    - 名前、パスは避ける
  - ビジネスロジックに絶対認可をかかない！
    - API を分ける
  - 責務の分割とは
    - アプリケーション開発者がポリシーも書く
    - ポリシーはポリシー管理者が書く
  - サービスのパターン
    - サービス A, サービス B ごとに AVP を立てる
    - サービスをまとめて AVP を立てる

## [AWS Workshops](https://workshops.aws/)

- 観点
  - 完走できること
    - 古くなってない
  - 学びがあること
- おすすめ
- [IAM policy evaluation workshop](https://catalog.us-east-1.prod.workshops.aws/workshops/6dc3124a-6bd4-46eb-b5c4-be438a82ba3d/en-US)
- [AWS Networking Workshop](https://catalog.workshops.aws/networking/)
  - 8 hours
  - vpc endpoint 特におすすめ
- [AWS Network Firewall Workshop](https://catalog.workshops.aws/networkfirewall/en-US)
- [Security for Developers](https://catalog.workshops.aws/sec4devs/en-US)
- そのほか
  - [bridgecrew](https://bridgecrew.io/infrastructure-as-code-security/terraform/)
    - terraform のハンズオン？

## Sysdig

- [Sysdig](https://sysdig.jp/)
  - クラウドイノベーションをセキュアに加速
- sysdig のツール
  - system call をキャプチャする
  - falco
    - 怪しい動きを検知する
  - 何やってもセキュリティでやられる時はやられる
    - 振る舞い検知の重要度 up
- クラウドネイティブセキュリティ
  - 脆弱性管理
  - 設定管理
    - posture
  - ID & アクセス管理
  - 脅威検知及び対応
- エージェントレスが流行っている
  - sysdig では、エージェントとエージェントレスのいいとこどり

## Network Firewall + DNS Firewall

- Network Firewall
  - Suricata 互換の AWS マネージド
    - シグネチャ型 IPS/IDS
  - できること
    - パケットフィルタリング
    - 中央管理
    - 可視性
    - マネージドグループ
  - Stateful
    - Alert all, Alert established
      - TCP のハンドシェイクとかも見るのかどうか
    - SNI は暗号化されないので、その辺で判断したり
  - できないこと
    - 暗号化された完全なアウトバウンドけんさ
    - 完全なドメインベースでのフィルタリング
      - SNI は偽造が容易
    - TLS インスペクション
- Handshake
  - TLS のクライアントはろー
    - SNI とかとか暗号化されてない
    - ESNI だとそこも暗号化されるが、発展中の技術
- Route53 Resolver DNS Firewall
  - できること
    - DNS フィルタリング
    - 中央管理
    - 可視性
    - マネージドグループ
  - できないこと
    - hosts に書かれた宛先の名前解決検査
    - IP 直接通信
- Tips
  - [re: Inforce 2023 Threat Detection and Incident Response](https://www.youtube.com/watch?v=Q9CIOB_xm_Q&list=PL2yQDdvlhXf9g6i7Xaqzl4b6nTr45RH3y&ab_channel=AWSEvents)

## Capital One の漏洩について

- CapitalOne
  - 大手金融機関
  - 独自のデータセンターから AWS への完全移行 2015-2020
  - OSS へのフルコミット
  - [Hygieia](https://github.com/hygieia/hygieia)
  - 役員が全員 IT に精通
  - DepOps への取り組み
    - DevSecOps の先駆的企業
      - 高品質で機能するソフトウェアをより速く提供する
  - Qualys
- 事件の概要
  - 不正アクセスにより１億人をこえる個人情報が流出
  - WAF の設定ミスに起因して SSRF 攻撃を許した
  - 手口
    - WAF: Apatche + mod_security リバースプロキシとして構成
      - ProxyRequests On は絶対だめ！
        - オープンプロキシになってしまう
    - 不要なクレデンシャルが WAF に付与されていた
  - IMDSv1
    - Instance MetaData Service
    - 169.254.169.254
      - 仮想的なエンドポイント
      - インスタンスの設定情報が取れる！
  - なぜ攻撃を受けたか
    - S3 ストレージのアクセス権が WAF のインスタンスに付与されていた
    - WAF がオープン PROXY になっていた
    - IMDS が無効化されていなかった
- 事件に至った考察
  - MIT の論文とかもでてるらしい
    - https://dl.acm.org/doi/10.1145/3546068
      - 組織的なもの・メンタルモデルまで踏み込んでる
    - セキュリティエンジニアの離職率の高さ
      - 2018 に 1/3 が退職
  - open proxy は見抜けなかったのか？
  - 設定監査では前までなかった
  - [徳丸さんの 2018 の記事](https://blog.tokumaru.org/2018/12/introduction-to-ssrf-server-side-request-forgery.html)
- 質問
  - open proxy は前からあった問題
  - IMDS はクラウド独自の問題
  - S3 で、透過的な暗号化をしている限りは漏洩してしまう
    - クライアント側で暗号化してアップロードするのであれば良い
    - 鍵管理は関係なさそう

## DevSecOps

- [snyk](https://go.snyk.io/jp.html)
  - スニーク
  - クラウドネイティブ
    - アプリとインフラの境目が曖昧になっている
      - **セキュリティリスクが分散してしまった！**
  - Snyk
    - 分散したセキュリティリスクを一元的に対応
    - 迅速な開発とセキュリティの両立を支援
- DevSecOps on Cloud?
  - infinity のマーク
  - DevOps にセキュリティを入れたもの？
  - 開発者とクラウドチーム（セキュリティチームも！）が協力し、迅速な開発を行う
  - **Shift Left**
    - はじめの方でセキュリティリスクは検知！
  - 自動化
  - DevSecOps は、セキュリティを
    - 自分のこととして考える
    - チームのこととして考える
    - 他のチームの立場を考えて行動する
- memo
  - [OWASP top10](https://www.synopsys.com/ja-jp/glossary/what-is-owasp-top-10.html)

## AWS WAF と Datadog ASM

- 多層防御と W-A Framework
  - Well-Architected
  - アプリケーション層におけるセキュリティ対策においても、単一の対策ではなく複数の対策を組み合わせることが重要
- AWS products
  - Shield
  - Firewall Manager
  - WAF
  - Network Firewall
- アプリケーションセキュリティツール
  - セキュリティスキャンツール
    - DAST
    - IAST
    - SAST
    - SCA
  - ランタイム保護ツール
    - WAF
    - RASP
      - Runtime Application Self Protection
  - 一般的な web アプリケーション攻撃
    - パス
    - CSRF
    - SSRF
- Cloud WAF の役割
  - Web アプリケーションへの攻撃・脆弱性に対し、エッジでの防御を行える
    - そのため、リバースプロキシや DDoS 攻撃対策としても利用できる
  - AWS WAF
    - アプリ到達**前**に、**ルールベースで管理**
  - Datadog ASM (Application Security Management)
    - アプリに到達したリクエストを**コンテキストベースで管理**
    - Security Signal として検出
- Datadog ASM In-App WAF

## AWS IoT Core

- [IoT Core](https://aws.amazon.com/jp/iot-core/)
  - 100 万分あたり 14 円くらい
  - MQTT
  - HTTP メッセージング料金
  - スケール、迅速対応、コスト削減
  - フルマネージドシステム
- セキュリティ
  - 企業ごとが保持するドローンの MQTT メッセージをセキュアに制御する
  - システム上で許可してるドローンシリアルナンバーのみに対して、自動で証明書を払い出す
    - Bootstrap Certificate
- SRT 配信システム
  - 低遅延・高映像品質なリアルタイム
  - ドローン上から配信！

## IAM Identity Center

- IAM Identity Center
  - AWS Single Sign-On の後継
  - ID フェデレーション
    - シングルサインオンを実現する方式の1つ
    - １つの組織（管理ドメイン）を超えて、他の管理ドメインのサービスにもログインできるようにする処理のこと
    - SAML など標準技術を適応して実現することが多い
  - ID フェデレーションをもっと簡単に
  - アクセス権限セット
