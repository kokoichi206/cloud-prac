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


```

- metadata の不要なラベルを削除
- この辺の記載を合わせる
  - deployment
    - spec.selector.matchLabels
    - spec.template.metadata.labels
  - service
    - spec.selector


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
