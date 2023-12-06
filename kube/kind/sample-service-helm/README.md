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

## Links

- [Pod でルートファイルシステムを読み取り専用にする securityContext.readOnlyRootFilesystem](https://kakakakakku.hatenablog.com/entry/2022/04/19/104313)
  - nginx で特定ファイルへの書き込みを許可する
