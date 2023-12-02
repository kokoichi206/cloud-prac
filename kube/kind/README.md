## [kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)

``` sh
kind create cluster --name local-dev

kind delete cluster --name local-dev
kind create cluster --name local-dev --config k8s-cluster-config.yaml


kind get clusters


kubectl get services

# check configurations
helm install sample-service --dry-run --debug ./sample-service-helm

# with node port (access from outside)
helm install sample-service ./sample-service-helm --set service.type=NodePort --set service.nodePort=31234


❯ kubectl get services

NAME                                 TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
kubernetes                           ClusterIP   10.96.0.1       <none>        443/TCP        21m
sample-service-sample-service-helm   NodePort    10.98.250.140   <none>        80:31234/TCP   41s


helm delete sample-service


❯ kubectl get pods
NAME                                                  READY   STATUS    RESTARTS   AGE
sample-service-sample-service-helm-6b44897c57-btrfz   0/1     Evicted   0          8m45s
sample-service-sample-service-helm-6b44897c57-bznsn   0/1     Pending   0          117s
sample-service-sample-service-helm-6b44897c57-nqwhj   0/1     Evicted   0          23m

kubectl describe pod sample-service-sample-service-helm-6b44897c57-btrfz

❯ kubectl get nodes
NAME             STATUS   ROLES           AGE   VERSION
docker-desktop   Ready    control-plane   35m   v1.28.2

# Pending のまま問題。
# https://qiita.com/nykym/items/dcc572c21885543d94c8
❯ kubectl describe node docker-desktop | grep Taints
Taints:             node.kubernetes.io/disk-pressure:NoSchedule
#   Warning  FailedScheduling  11m (x2 over 16m)  default-scheduler  0/1 nodes are available: 1 node(s) had
#   untolerated taint {node.kubernetes.io/disk-pressure: }. preemption: 0/1 nodes are available: 1 Preemption is not helpful for scheduling..

kubectl taint nodes docker-desktop node.kubernetes.io/disk-pressure:NoSchedule-
kubectl taint node docker-desktop node.kubernetes.io/disk-pressure:NoSchedule-



kubectl get nodes -o json | jq '.items[].spec.taints'


helm uninstall sample-service

helm install sample-service ./sample-service-helm --set service.type=NodePort --set service.nodePort=31234

helm upgrade sample-service ./sample-service-helm --set service.type=NodePort --set service.nodePort=31234


# kind にローカルの dockerfile を登録する。
kind load --name local-dev docker-image sample-service:latest

kind load --name local-dev docker-image golang-bff:latest



helm upgrade -n kube-system --install -f values.yaml metrics-server metrics-server/metrics-server


helm upgrade -n kube-system --install -f values.yaml metrics-server metrics-server/metrics-server

helm uninstall -n kube-system metrics-server metrics-server/metrics-server


helm upgrade -n kube-system --install -f values.yaml metrics-server metrics-server/metrics-server



helm uninstall -n kube-system metrics-server metrics-server/metrics-server


kind load --name local-dev docker-image golang-bff:latest
kind load --name local-dev docker-image sample-service:latest
kind load --name local-dev docker-image my-nginx:latest
kind load --name local-dev docker-image golang-grpc:latest

helm upgrade sample-service ./sample-service-helm --set service.type=NodePort --set service.nodePort=31234


helm install sample-service ./sample-service-helm --set service.type=NodePort --set service.nodePort=31234


## dnsutils を入れる
kubectl apply -f https://k8s.io/examples/admin/dns/dnsutils.yaml
kubectl exec dnsutils -- nslookup golang-grpc-server
kubectl exec dnsutils -- cat /etc/resolv.conf
```

- metadata の不要なラベルを削除
- この辺の記載を合わせる
  - deployment
    - spec.selector.matchLabels
    - spec.template.metadata.labels
  - service
    - spec.selector


## Ingress

- [controller を有効にする](https://kind.sigs.k8s.io/docs/user/ingress/#ingress-nginx)

``` sh
kind create cluster --name local-dev-ingress --config cluster-with-ingress.yaml



kubectl exec -it nginx-ingress-controller-xxx-yyy -- cat nginx.conf

```


## k8s dashboard

``` sh
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml
kubectl get pod -n kubernetes-dashboard
kubectl create serviceaccount -n kubernetes-dashboard admin-user\nkubectl create clusterrolebinding -n kubernetes-dashboard admin-user --clusterrole cluster-admin --serviceaccount=kubernetes-dashboard:admin-user
token=$(kubectl -n kubernetes-dashboard create token admin-user)
echo $token
kubectl proxy
echo see: http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/\#/workloads\?namespace\=default




$ kubectl exec dnsutils -- nslookup golang-grpc-server
Server:         10.96.0.10
Address:        10.96.0.10#53

Name:   golang-grpc-server.default.svc.cluster.local
Address: 10.244.0.35
Name:   golang-grpc-server.default.svc.cluster.local
Address: 10.244.0.36
Name:   golang-grpc-server.default.svc.cluster.local
Address: 10.244.0.34
Name:   golang-grpc-server.default.svc.cluster.local
Address: 10.244.0.29
Name:   golang-grpc-server.default.svc.cluster.local
Address: 10.244.0.33
```

## ERRORs

### selector

``` sh
helm upgrade sample-service ./sample-service-helm --set service.type=NodePort --set service.nodePort=31234
Error: UPGRADE FAILED: cannot patch "debian" with kind Deployment: Deployment.apps "debian" is invalid: spec.selector: Invalid value: v1.LabelSelector{MatchLabels:map[string]string{"app":"debian"}, MatchExpressions:[]v1.LabelSelectorRequirement(nil)}: field is immutable
make: *** [upgrade] Error 1
```

> 表示されたエラーは、KubernetesにおけるDeploymentのspec.selectorフィールドの不変性に関連しています。Kubernetesでは、一度作成されたDeploymentのspec.selectorフィールドは変更できません。このエラーメッセージは、既存のDeploymentのspec.selectorを変更しようとしたときに発生します。

## DNS

![](imgs/service-dns.png)

書いてみた。

https://koko206.hatenablog.com/entry/2023/11/25/020948

## Auto Scaling

- k8s の機能
  - Cluster Auto Scaling
    - pod がスケジューリングできない状況になった時、クラウドプロバイダが提供する API を通して自動で Node を追加
    - https://github.com/kubernetes/autoscaler/tree/master/cluster-autoscaler
    - EKS ならこれがベストらしい: https://karpenter.sh/
  - Pod Auto Scaling
    - HPA
    - VPA

### [HPA](https://kubernetes.io/ja/docs/tasks/run-application/horizontal-pod-autoscale-walkthrough/)

- Metrics APIを介してメトリクスを提供するために、Metrics serverによるモニタリングがクラスター内にデプロイされている必要があります

``` sh
kubectl edit deploy metrics-server -n kube-system
```

``` yaml
      - args:
        - --cert-dir=/tmp
        - --secure-port=4443
        - --v=2
        - --kubelet-insecure-tls
        - --kubelet-preferred-address-types=InternalIP
```

``` sh
kt top pod

kc get hpa

# watch する！
kc get hpa -w
```

サーバー側のコネクション時間の設定とかして切断を切ったりしなくとも、hpa で増えた pod にリクエストされてるように見える。。。？

→ 嘘だった。。。されてなかった。

Server 側で Timeout しておくと、接続が切れたタイミングでその時の数に合わせられることは確認した。

### Links

- [Kubernetes上でgRPCサービスを動かす](https://deeeet.com/writing/2018/03/30/kubernetes-grpc/)
  - 2018/03

## Subcharts

- [helm-best-practice](https://www.argonaut.dev/blog/helm-best-practices)

## Next

- pod 増やす
  - 外に出す
    - ２つ以上だと reverse proxy 的なのがいる？
- grpc でロードバランサー

## 疑問

- Namespace って、区切られた間でできないことってある？
  - どれくらいの粒度で区切るのがいい？

## Links

- [Local kubernetes with kind, helm and a sample service](https://faun.pub/local-kubernetes-with-kind-helm-and-a-sample-service-4755e3e6eff4)
- [kind でローカルの Dockerfile を使う](https://renjith85.medium.com/local-docker-registry-in-kubernetes-cluster-using-kind-8230075a7817)
- [distroless/base](https://github.com/GoogleContainerTools/distroless/blob/main/base/README.md)
