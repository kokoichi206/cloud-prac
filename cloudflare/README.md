## 疑問

### Proxied とは

cloudflare の DNS  Records サービスをを、A レコードの登録 + Proxied として使ってみた。
A レコードに登録したグローバル IP は、すでに別のドメインとして動いてる Apache サーバーで、ドメイン経由の HTTPS アクセスしかできないようにしてるつもり（IP によるアクセスは）。
cloudflare には globalIP の情報しか与えてないのに、なんでそのサーバーにアクセスできるのがわからない。
