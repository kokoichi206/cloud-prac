## Intro

Kubernetes + AWS + IaC

## Kubernetes

- Kubernetes は複数のコンポーネントを組み合わせて作られる
- コンポーネントの集合体を Cluster と呼ぶ
  - コントロールプレーン
    - kube-api
    - kube-controller-manager
    - kube-scheduler
    - cloud-controller-manager
    - etcd
  - Node からなるデータプレーン
    - kube-proxy
    - kubelet
    - container runtime
- コントロールプレーン
  - 各 Node や Node 上の Pod を制御するためのコンポーネント群
  - ダウンすると Cluster 操作, Pod の維持ができなくなる
    - 冗長構成必須
  - kube-apiserver
    - 全体における司令塔
    - kubectl を使って kube-apiserver と通信できる
    - kube-apiserver が他のコンポーネントとやり取りを行う
  - kube-scheduler
    - 新しい Pod 作成時、それらの適切な Node を選択しスケジューリングする
  - etcd
    - 可用性と一貫性に優れた分散型のキーバリューストア
- データプレーン
  - Pod や Service などの基本的なワークロードは Node 上で動く
  - Node コンポーネントは、それらのワークロードの実行に必要な環境を提供する
  - kubelet
    - 各 Node 上で動作するエージェント
    - Pod がマニフェスト通り動作してるかを確認する
  - kube-prox
    - 各 Node で動作
    - Service の一部の実装
    - Cluster 内外のネットワークトラフィックの制御
  - Container Runtime
    - **Node で Pod を実行する**ための実行環境

## AWS

- [アクセスキー忘れた](https://docs.aws.amazon.com/ja_jp/IAM/latest/UserGuide/id_credentials_access-keys.html#Using_CreateAccessKey)
- [aws-cli](https://github.com/aws/aws-cli)

``` sh
export AWS_ACCESS_KEY_ID=AKIAXXXXXXX
export AWS_SECRET_ACCESS_KEY=AHAHAHAHAHAHAHAHAHAHAHAHAHA
export AWS_DEFAULT_REGION=ap-northeast-1
```

``` sh
# 現在設定されている IAM ユーザー情報の確認
aws sts get-caller-identity

kubectl version --client --short

# https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/eksctl.html
eksctl version
0.129.0


cat ~/.kube/config
# eksctl を使うと, ~/.kube/config の情報を勝手に読み込んでくれる
eksctl create cluster \
    --name eks-cluster \
    --version 1.24 \
    --with-oidc \
    --nodegroup-name eks-cluster-node-group \
    --node-type t2.micro \
    --nodes 1 \
    --nodes-min 1

    --node-type c5.large \
```

![](../imgs/eks_console.png)

## Pod

- 1 つ以上のコンテナから構成された Kubernetes で実行できるワークロードの最小単位
- Pod には複数のコンテナを配置可能
  - コンテナはネットワーク・ストレージ・CPU・メモリなど、コンピューティングリソースを共有
  - Pod ないのコンテナはそれぞれ個別の IP を持た**ない**

``` sh
kubectl apply -f pod.yml

# https://kubernetes.io/ja/docs/tasks/tools/install-kubectl/
# linux -> darwin : amd64 -> arm64
curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.25.0/bin/darwin/arm64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl125
kubectl125 version --client --short

curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.23.0/bin/darwin/arm64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl123
kubectl123 version --client --short

kubectl123 apply -f pod.yml
```

- Replicaset
  - Pod の数を維持する役割
- Job
  - Deployment と同様に複数の Pod を実行する
  - バッチ処理の実行
  - 失敗時のリトライ回数の設定等も可能
- Service
  - Cluster の内外を問わず Pod をネットワークの中に公開するための抽象的な方法
    - Cluster IP
    - Node Port
    - LoadBalancer
- Ingress
  - LoadBalancer と同じく、Pod を Cluster 外部に公開するための機能を提供
  - LoadBalancer が L4 での通信なのに対し、L7 そうでの通信
- Storage
  - コンテナでのデータを永続化したい場合
  - 同一 Pod 内の複数のコンテナからデータを共有したい場合
- Volume
  - Pod から利用できるストレージ領域
- Access Modes
- ConfigMap
  - データを Key, Value 形式で Cluster に登録する
  - 環境ごとに固有で機密性のないデータを Pod から参照するためのもの
  - spec.containers.[].env
- Secret
  - base64 でエンコードして Node に登録

## 削除

``` sh
kubectl delete svc service

eksctl delete cluster --name eks-cluster
```


## memo

- EKS: Elastic Kubernetes Service
  - eksctl は EKS の作成を行うための CLI ツール
