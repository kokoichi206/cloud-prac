# CloudFront-S3
AWS-SAA でよくみる構成を作ってみようシリーズ [#1](https://github.com/kokoichi206/cloud-prac/issues/1)

## Architecture

![](./docs/cf_s3.svg)

## S3 upload

```sh
# aws s3 ls --profile=PROFILE_NAME
aws s3 ls

# 個別
aws s3 cp sample.txt s3://mybucketname/ --acl public-read
# まとめて
aws s3 sync . s3://mybucketname/ --include "*" --acl public-read --cache-control "max-age=3600"
```

```sh
aws s3 cp spa/index.html s3://aws-s3-bucket-cloudfront-static/ --acl public-read
```
