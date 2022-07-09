## Steps

1. S3 のバケット作成
1. バケットに SPA をアップロードできる仕組み
1. CloudFront からアクセス

### S3 upload

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
