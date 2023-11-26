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



## memo


``` sh
 helm install mychart ./

NAME: mychart
LAST DEPLOYED: Wed Nov 22 21:39:43 2023
NAMESPACE: default
STATUS: deployed
REVISION: 1
TEST SUITE: None
❯ helm get manifest mychart
---
# Source: load-balancing/templates/configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: mychart-configmap
data:
  myvalue: "Hello World"


❯ helm ls

NAME    NAMESPACE       REVISION        UPDATED                                 STATUS          CHART                   APP VERSION
mychart default         1               2023-11-22 21:39:43.958454 +0900 JST    deployed        load-balancing-0.1.0    1.16.0
❯ heml uninstall mychart
zsh: command not found: heml
❯ helm uninstall mychart
release "mychart" uninstalled
❯ helm ls
NAME    NAMESPACE       REVISION        UPDATED STATUS  CHART   APP VERSION
```

## nginx

``` sh
helm repo add bitnami https://charts.bitnami.com/bitnami

helm search repo nginx
NAME                                    CHART VERSION   APP VERSION     DESCRIPTION
bitnami/nginx                           15.4.3          1.25.3          NGINX Open Source is a web server that can be a...
bitnami/nginx-ingress-controller        9.9.2           1.9.3           NGINX Ingress Controller is an Ingress controll...
bitnami/nginx-intel                     2.1.15          0.4.9           DEPRECATED NGINX Open Source for Intel is a lig...

# create and switch namespace
❯ kubectl create ns web
namespace/web created
❯ kubectl config set-context --current --namespace=web
Context "docker-desktop" modified.


helm install nginx01 bitnami/nginx
NAME: nginx01
LAST DEPLOYED: Wed Nov 22 21:47:25 2023
NAMESPACE: web
STATUS: deployed
REVISION: 1
TEST SUITE: None
NOTES:
CHART NAME: nginx
CHART VERSION: 15.4.3
APP VERSION: 1.25.3


helm uninstall nginx01

helm install nginx01 bitnami/nginx
kubectl get pods -n default
kubectl get pods -n web


kubectl get svc --namespace web -w nginx01
NAME      TYPE           CLUSTER-IP      EXTERNAL-IP   PORT(S)        AGE
nginx01   LoadBalancer   10.97.178.251   localhost     80:31722/TCP   49s


❯ kubectl get pods -n web
NAME                      READY   STATUS    RESTARTS   AGE
nginx01-fb878bcc7-tdjfv   1/1     Running   0          3m36s

kubectl -n web exec -it nginx01-fb878bcc7-tdjfv bash
```

https://medium.com/@surangajayalath299/create-a-helm-chart-and-deploy-on-kubernetes-f436aca92e47

``` sh
helm install nginx-suranga . -n web
```


## Links

- [Artifact Hub](https://artifacthub.io/packages/helm/bitnami/nginx)
- [nginx traffic expose parameters](https://artifacthub.io/packages/helm/bitnami/nginx#traffic-exposure-parameters)
