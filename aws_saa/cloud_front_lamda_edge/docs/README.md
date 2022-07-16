## AWS Document

## Architecture

![](./architecture.svg)

## なにをしているか

1. CloudFront のドメインにアクセス。
1. クエリパラメーターに`name`が含まれるか確認。
1. `name`の値が、ID として DynamoDB に含まれているか確認。
1. 上の結果により、リダイレクトする URL を変更している。
