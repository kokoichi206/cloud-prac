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
