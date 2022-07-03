## setup

- 「プログラムによるアクセス」を付与した IAM ユーザーを作成

``` sh
pip3 install awscli --upgrade
aws --version

export AWS_ACCESS_TOKEN_KEY_ID=xxx
export AWS_SECRET_ACCESS_KEY=yyy/eee/ppp/aaa
export AWS_DEFAULT_REGION=ap-northeast-1

aws sts get-caller-identity --query Account --output text
```

### Terraform
Terraform をとりあえず動かすには Homebrew が手軽。
実運用では頻繁に Terraform のバージョンアップが発生するので tfenv 等の利用が必要。

``` sh
brew install tfenv
tfenv --version

tfenv list-remote
# 現環境最新
tfenv install 1.2.4
# 1.0.2 以降は arm 版にも対応。
tfenv install 1.0.6
tfenv install 1.1.8

tfenv list
tfenv use 1.2.4

# .terraform-version により統一が可能!!
tfenv install
```

#### cf. Dockernized Terraform
Terraform は Docker Hub で公式イメージが配布されており、Docker さえ入っていればどこでも実行できるシンプルさ！

``` sh
docker pull hashicorp/terraform:1.2.4
docker run --rm hashicorp/terraform:1.2.4 --version

docker run --rm -i -v $PWD:/work -w /work \
    -e AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID \
    -e AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY \
    -e AWS_DEFAULT_REGION=$AWS_DEFAULT_REGION \
    hashicorp/terraform:1.2.4 <command>
```

### git-secrets
クレデンシャル流出防止のためのもの。

``` sh
brew install git-secrets

git secrets --register-aws --global
git secrets --install ~/.git-templates/git-secrets
git config --global init.templatedir '~/.git-templates/git-secrets'
```


## Basic Operations
``` sh
terraform init
terraform plan
terraform apply
terraform destroy
```

[Create default VPC](https://docs.aws.amazon.com/ja_jp/vpc/latest/userguide/default-vpc.html#create-default-vpc)

```
aws ec2 create-default-vpc
```

「既存リソースをそのまま変更する」ケースか「リソースが作り直しになる」ケースかは常に確認する！


## Basic Syntax

### variable
u can override the variables in .tf file like this.

``` sh
terraform plan -var 'example_instance_type=t3.nano'
```

local variables ("locals" syntax) cannot be overwritten in runtime.


### Provider
Terraform can be used not only in AWS but also in GCP, Azure and so on. This is achieved by "Provider".








## Memo
- AMI: Amazon Machine Image
- HCL: HachiCorp Configuration Language

## Questions
- How(Where) to get ami number?

### Terraform
- engress, ingress
- protocol = "-1"
