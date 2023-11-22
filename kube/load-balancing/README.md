``` sh
brew install kubectl
```

``` sh
$ kubectl version
Client Version: v1.28.4
Kustomize Version: v5.0.4-0.20230601165947-6ce0bf390ce3
Server Version: v1.28.2

$ kubectl config get-contexts

CURRENT   NAME             CLUSTER          AUTHINFO         NAMESPACE
*         docker-desktop   docker-desktop   docker-desktop

# context を docker-desktop を向ける。
$ kubectl config use-context docker-desktop

$ kubectl get pods -A
NAMESPACE     NAME                                     READY   STATUS                   RESTARTS      AGE
kube-system   coredns-5dd5756b68-hcrvf                 1/1     Running                  1 (63m ago)   23h
kube-system   coredns-5dd5756b68-jfhmj                 1/1     Running                  1 (63m ago)   23h
kube-system   etcd-docker-desktop                      1/1     Running                  1 (63m ago)   23h
kube-system   kube-apiserver-docker-desktop            1/1     Running                  1 (62m ago)   23h
kube-system   kube-controller-manager-docker-desktop   1/1     Running                  1 (63m ago)   23h
kube-system   kube-proxy-7txg2                         1/1     Running                  1 (63m ago)   23h
kube-system   kube-scheduler-docker-desktop            1/1     Running                  1 (63m ago)   23h
kube-system   storage-provisioner                      0/1     ContainerStatusUnknown   0             23h
kube-system   vpnkit-controller                        0/1     ContainerStatusUnknown   0             23h
```

## helm

``` sh
$ brew install kubernetes-helm

$ helm version
version.BuildInfo{Version:"v3.13.2", GitCommit:"2a2fb3b98829f1e0be6fb18af2f6599e0f4e8243", GitTreeState:"clean", GoVersion:"go1.21.4"}

helm repo update
```


``` sh
helm search hub jenkins

helm repo add jenkins https://artifacthub.io/packages/helm/jenkinsci/...

helm repo add brigade https://brigadecore.github.io/charts
```

``` sh
helm create load-balancing

```

## kubectl

``` sh
kubectl create namespace <name space>
```
