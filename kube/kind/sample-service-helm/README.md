Helm の素振りリポジトリ

- subcharts を使った Helm の分割
- Go を用いた gRPC の負荷分散
  - autoscaling の確認

## TODO

- secret をどう渡すべきか
- Helmfile
- Istio などのサイドカー
- セキュリティ関連の記述

## Security

[SecurityContext で](https://kubernetes.io/ja/docs/tasks/configure-pod-container/security-context/)設定する。

### read-only

[Docker の --read-only](https://docs.docker.jp/engine/reference/commandline/run.html#id25) と同等のこと。

機能してることを確認。

``` sh
$ kc exec -it debian-6979cdbcfb-9x759 sh
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.
# apt update
Reading package lists... Done
E: List directory /var/lib/apt/lists/partial is missing. - Acquire (30: Read-only file system)
# echo hoge
hoge
# mkdir pien
mkdir: cannot create directory 'pien': Read-only file system
```

### Capability

ビットマスク形式で指定されている。

- CapInh: Inheritable capabilities - プロセスが継承可能な権限。
- CapPrm: Permitted capabilities - プロセスが許可されている権限。
- CapEff: Effective capabilities - 実際にプロセスが使える権限。
- CapBnd: Bounding capabilities - 制限されている権限。

``` sh
$ cat /proc/1/status
...
CapInh: 0000000000000000
CapPrm: 00000000a80425fb
CapEff: 00000000a80425fb
CapBnd: 00000000a80425fb
CapAmb: 0000000000000000
...

$ apt install libcap2-bin
$ capsh --decode=00000000a80425fb
0x00000000a80425fb=cap_chown,cap_dac_override,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_net_bind_service,cap_net_raw,cap_sys_chroot,cap_mknod,cap_audit_write,cap_setfcap
```

### Mkdir

この辺は何で制限されるか。

``` sh
# log
│ 2023/12/06 15:05:20 failed to create directory:mkdir app-tmp: read-only file system                               │
│ Stream closed EOF for default/golang-bff-server-f8fdb44f-tvdr5 (golang-bff)
```

read-only を外した。

``` sh
# わかった, current root (top) が root の持ち物であるため nonroot でフォルダの作成に失敗している。
│ 2023/12/06 15:06:49 failed to create directory:mkdir app-tmp: permission denied                                   │
```

nonroot の uid, gid を求めるために debug オプションをつけたイメージで shell に入る。

``` sh
/app-workdir $ id
uid=65532(nonroot) gid=65532(nonroot) groups=65532(nonroot)
```

kubectl -n default debug golang-grpc-server-6cc858b489-9jb7l -it my-ephemeral-container --image=ubuntu target=golang-grpc
kubectl -n default debug golang-grpc-server-6cc858b489-9jb7l -it my-ephemeral-container image=ubuntu target=target-container

### no new privileges

setuid されたバイナリなどを通した権限昇格を防ぐ。

k8s では [allowPrivilegeEscalation](https://kubernetes.io/ja/docs/tasks/configure-pod-container/security-context/) で制御する。

### PID limits

https://kubernetes.io/docs/concepts/policy/pid-limiting/

kubelet のコマンドパラメーターとして渡すか、configuration ファイルに書く必要があるとのこと。

readOnlyRootFilesystem にするのは Fork Bomb 対策にはなってない。

``` sh
kc exec -it debian-6979cdbcfb-9p8w7 sh
kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead.

$ ulimit -a
time(seconds)        unlimited
file(blocks)         unlimited
data(kbytes)         unlimited
stack(kbytes)        8192
coredump(blocks)     unlimited
memory(kbytes)       unlimited
locked memory(kbytes) 82000
process              unlimited
nofiles              1048576
vmemory(kbytes)      unlimited
locks                unlimited
rtprio               0
```

``` sh
# worker node に入る。
❯ docker ps | grep kind
a9f2499de92e   kindest/node:v1.27.3        "/usr/local/bin/entr…"   45 minutes ago      Up 45 minutes      127.0.0.1:50169->6443/tcp, 0.0.0.0:9900->31234/tcp                    local-dev-control-plane
bfcaf24aa3ab   kindest/node:v1.27.3        "/usr/local/bin/entr…"   45 minutes ago      Up 45 minutes                                                                            local-dev-worker
be21ff3e5836   kindest/node:v1.27.3        "/usr/local/bin/entr…"   2 weeks ago         Up 28 hours        0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp, 127.0.0.1:58349->6443/tcp   kind-control-plane

❯ docker exec -it local-dev-worker /bin/sh
$ cat /var/lib/kubelet/kubeadm-flags.env
KUBELET_KUBEADM_ARGS="--container-runtime-endpoint=unix:///run/containerd/containerd.sock --node-ip=172.26.0.3 --node-labels=ingress-ready=true --pod-infra-container-image=registry.k8s.io/pause:3.9 --provider-id=kind://docker/kind/kind-control-plane"

KUBELET_KUBEADM_ARGS="--network-plugin=cni --pod-infra-container-image=k8s.gcr.io/pause:3.2 --dynamic-config-dir=/var/lib/kubelet-dynamic"

$ vim /var/lib/kubelet/kubeadm-flags.env
# 以下 option を追加。
# --dynamic-config-dir=/var/lib/kubelet-dynamic

# kubelet 再起動。
systemctl restart kubelet
systemctl status kubelet

```

### trivy チェック

trivy を使って cluster に対して確認ができる。

``` sh
trivy k8s --report=summary cluster

kc get ns trivy-temp -o json > temp.json
vim temp.json
curl -H "Content-Type: application/json" -X PUT --data-binary @temp.json http://127.0.0.1:8001/api/v1/namespaces/trivy-temp/finalize

trivy kubernetes deployment/golang-bff-server

trivy kubernetes deployment/golang-grpc-server
```

<details><summary>出力例</summary>

MEDIUM は対応しておきたい気がする。

``` sh
$ trivy kubernetes deployment/golang-grpc-server

default-Deployment-golang-grpc-server-1056612738.yaml (kubernetes)

Tests: 152 (SUCCESSES: 141, FAILURES: 11, EXCEPTIONS: 0)
Failures: 11 (UNKNOWN: 0, LOW: 7, MEDIUM: 4, HIGH: 0, CRITICAL: 0)

MEDIUM: Container 'golang-grpc' of Deployment 'golang-grpc-server' should set 'securityContext.allowPrivilegeEscalation' to false
══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
A program inside the container can elevate its own privileges and run as root, which might give the program control over the container and node.

See https://avd.aquasec.com/misconfig/ksv001
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 default-Deployment-golang-grpc-server-1056612738.yaml:158-174
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 158 ┌                 - image: golang-grpc:latest
 159 │                   imagePullPolicy: IfNotPresent
 160 │                   name: golang-grpc
 161 │                   ports:
 162 │                     - containerPort: 8080
 163 │                       name: http
 164 │                       protocol: TCP
 165 │                   resources:
 166 └                     limits:
 ...
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────


LOW: Container 'golang-grpc' of Deployment 'golang-grpc-server' should add 'ALL' to 'securityContext.capabilities.drop'
══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
The container should drop all default capabilities and add only those that are needed for its execution.

See https://avd.aquasec.com/misconfig/ksv003
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 default-Deployment-golang-grpc-server-1056612738.yaml:158-174
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 158 ┌                 - image: golang-grpc:latest
 159 │                   imagePullPolicy: IfNotPresent
 160 │                   name: golang-grpc
 161 │                   ports:
 162 │                     - containerPort: 8080
 163 │                       name: http
 164 │                       protocol: TCP
 165 │                   resources:
 166 └                     limits:
 ...
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────


MEDIUM: Container 'golang-grpc' of Deployment 'golang-grpc-server' should set 'securityContext.runAsNonRoot' to true
══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
Force the running image to run as a non-root user to ensure least privileges.

See https://avd.aquasec.com/misconfig/ksv012
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 default-Deployment-golang-grpc-server-1056612738.yaml:158-174
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 158 ┌                 - image: golang-grpc:latest
 159 │                   imagePullPolicy: IfNotPresent
 160 │                   name: golang-grpc
 161 │                   ports:
 162 │                     - containerPort: 8080
 163 │                       name: http
 164 │                       protocol: TCP
 165 │                   resources:
 166 └                     limits:
 ...
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────


MEDIUM: Container 'golang-grpc' of Deployment 'golang-grpc-server' should specify an image tag
══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
It is best to avoid using the ':latest' image tag when deploying containers in production. Doing so makes it hard to track which version of the image is running, and hard to roll back the version.

See https://avd.aquasec.com/misconfig/ksv013
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 default-Deployment-golang-grpc-server-1056612738.yaml:158-174
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 158 ┌                 - image: golang-grpc:latest
 159 │                   imagePullPolicy: IfNotPresent
 160 │                   name: golang-grpc
 161 │                   ports:
 162 │                     - containerPort: 8080
 163 │                       name: http
 164 │                       protocol: TCP
 165 │                   resources:
 166 └                     limits:
 ...
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────


LOW: Container 'golang-grpc' of Deployment 'golang-grpc-server' should set 'securityContext.readOnlyRootFilesystem' to true
══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
An immutable root file system prevents applications from writing to their local disk. This can limit intrusions, as attackers will not be able to tamper with the file system or write foreign executables to disk.

See https://avd.aquasec.com/misconfig/ksv014
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 default-Deployment-golang-grpc-server-1056612738.yaml:158-174
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 158 ┌                 - image: golang-grpc:latest
 159 │                   imagePullPolicy: IfNotPresent
 160 │                   name: golang-grpc
 161 │                   ports:
 162 │                     - containerPort: 8080
 163 │                       name: http
 164 │                       protocol: TCP
 165 │                   resources:
 166 └                     limits:
 ...
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────


LOW: Container 'golang-grpc' of Deployment 'golang-grpc-server' should set 'securityContext.runAsUser' > 10000
══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
Force the container to run with user ID > 10000 to avoid conflicts with the host’s user table.

See https://avd.aquasec.com/misconfig/ksv020
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 default-Deployment-golang-grpc-server-1056612738.yaml:158-174
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 158 ┌                 - image: golang-grpc:latest
 159 │                   imagePullPolicy: IfNotPresent
 160 │                   name: golang-grpc
 161 │                   ports:
 162 │                     - containerPort: 8080
 163 │                       name: http
 164 │                       protocol: TCP
 165 │                   resources:
 166 └                     limits:
 ...
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────


LOW: Container 'golang-grpc' of Deployment 'golang-grpc-server' should set 'securityContext.runAsGroup' > 10000
══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
Force the container to run with group ID > 10000 to avoid conflicts with the host’s user table.

See https://avd.aquasec.com/misconfig/ksv021
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 default-Deployment-golang-grpc-server-1056612738.yaml:158-174
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 158 ┌                 - image: golang-grpc:latest
 159 │                   imagePullPolicy: IfNotPresent
 160 │                   name: golang-grpc
 161 │                   ports:
 162 │                     - containerPort: 8080
 163 │                       name: http
 164 │                       protocol: TCP
 165 │                   resources:
 166 └                     limits:
 ...
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────


LOW: Either Pod or Container should set 'securityContext.seccompProfile.type' to 'RuntimeDefault'
══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
According to pod security standard 'Seccomp', the RuntimeDefault seccomp profile must be required, or allow specific additional profiles.

See https://avd.aquasec.com/misconfig/ksv030
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 default-Deployment-golang-grpc-server-1056612738.yaml:158-174
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 158 ┌                 - image: golang-grpc:latest
 159 │                   imagePullPolicy: IfNotPresent
 160 │                   name: golang-grpc
 161 │                   ports:
 162 │                     - containerPort: 8080
 163 │                       name: http
 164 │                       protocol: TCP
 165 │                   resources:
 166 └                     limits:
 ...
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────


MEDIUM: container golang-grpc of deployment golang-grpc-server in default namespace should specify a seccomp profile
══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
A program inside the container can bypass Seccomp protection policies.

See https://avd.aquasec.com/misconfig/ksv104
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────


LOW: container should drop all
══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
Containers must drop ALL capabilities, and are only permitted to add back the NET_BIND_SERVICE capability.

See https://avd.aquasec.com/misconfig/ksv106
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 default-Deployment-golang-grpc-server-1056612738.yaml:158-174
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
 158 ┌                 - image: golang-grpc:latest
 159 │                   imagePullPolicy: IfNotPresent
 160 │                   name: golang-grpc
 161 │                   ports:
 162 │                     - containerPort: 8080
 163 │                       name: http
 164 │                       protocol: TCP
 165 │                   resources:
 166 └                     limits:
 ...
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────


LOW: deployment golang-grpc-server in default namespace should set spec.securityContext.runAsGroup, spec.securityContext.supplementalGroups[*] and spec.securityContext.fsGroup to integer greater than 0
══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════════
According to pod security standard 'Non-root groups', containers should be forbidden from running with a root primary or supplementary GID.

See https://avd.aquasec.com/misconfig/ksv116
──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
```

</details>

## Gateway API

### [GAMMA](https://gateway-api.sigs.k8s.io/concepts/gamma/?h=gamma)

- Service Mesh でのルーティング
  - [East/West traffic ともいうらしい](https://gateway-api.sigs.k8s.io/concepts/glossary/#eastwest-traffic)
    - 外界とのやり取りは North/South traffic
- [KubeCon: What's New in gRPC ](https://kccncna2023.sched.com/event/1R2ut/whats-new-in-grpc-kevin-nilson-gina-yeh-google-richard-belleville-independent?iframe=no&w=100%&sidebar=yes&bg=no)
  - 動画10分くらいの位置

[Getting started](https://gateway-api.sigs.k8s.io/guides/)

### Links

- [KubeCon: Modern Load Balancing](https://kccncna2023.sched.com/event/1R2s6?iframe=no)

## Links

- [Pod でルートファイルシステムを読み取り専用にする securityContext.readOnlyRootFilesystem](https://kakakakakku.hatenablog.com/entry/2022/04/19/104313)
  - nginx で特定ファイルへの書き込みを許可する
- [nobody in ubuntu](https://wiki.ubuntu.com/nobody)
  - 65534
- [エフェメラルコンテナ](https://kubernetes.io/ja/docs/concepts/workloads/pods/ephemeral-containers/)
  - 1.23 からデフォルトで有効？
  - まだ β ？
