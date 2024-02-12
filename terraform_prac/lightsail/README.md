## Architecture

![](./docs/imgs/infra.svg)

``` sh
# TODO: サービス名なんかも terraform から持ってきたい。
$ aws lightsail push-container-image --region ap-northeast-1 --service-name sns-app-production --label production --image sns-app-backend:latest

# 上記コマンド実行時に『Cannot connect to the Docker daemon』のエラーが出た時は DOCKER_HOST を上書きする。
# https://koko206.hatenablog.com/entry/2024/02/12/195159
$ DOCKER_HOST=unix:///Users/kokoichi/.docker/run/docker.sock aws lightsail push-container-image --region ap-northeast-1 --service-name sns-app-production --label production --image sns-app-backend:latest
```

### 2. terraform の更新

``` sh
$ terraform version
Terraform v1.7.3

# 期待した差分のみであることを確認する。
$ terraform plan

$ terraform apply
```

## Links

- [provider backend](https://developer.hashicorp.com/terraform/language/settings/backends/s3)

### Cloud services

- [AWS: Lightsail](https://lightsail.aws.amazon.com/ls/webapp/home/containers)
- [S3 (terraform.state)](https://s3.console.aws.amazon.com/s3/buckets/sns-app-kokoichi206?region=ap-northeast-1&bucketType=general&tab=objects)
