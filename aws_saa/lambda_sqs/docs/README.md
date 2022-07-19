## AWS Document

## Architecture

![](./architecture.svg)

## なにをしているか

1. SQS のメッセージを発行。
1. Lambda が受信。
1. S3 に書き込み。
