## はじめに

- コンテナ
  - アプリケーションコンテナ（k8s, Docker）
    - アプリの実行に必要な最小限のコード
    - イミュータブルなコンテナを実行することが推奨される
  - システムコンテナ（LXC, LXD）
    - Linux ディストリビューションそのもの
    - 仮想マシンに近い扱い
- 基本的な作成方法
  - cgroup, namespace, root ディレクトリの変更
- k8s
  - CRI: Container Runtime Interface を使用
  - ユーザーは CRI に準拠した好みのコンテナランタイムを選択できる
    - containerd
    - CRI-O
- コンテナ、コンテナイメージを管理する
  - Docker CLI
  - Podman
    - デーモンコンポーネントへの依存を取り除きたい

## sec 1

- リスクは種類が異なり、脅威の相対的重要度も変わる
- 脅威モデリング
- コンテナキュイモデル
  - 関係するアクターの洗い出し
    - 外部攻撃者
    - 内部攻撃者
      - 環境の一部にアクセスすることに成功した攻撃者
    - 内部関係者
    - 不注意な関係者
    - アプリケーションプロセス
- 攻撃ベクトルの検討
  - **コンテナのライフサイクル**の各段階における脅威を調べる
- マルチテナント
  - マシンリソースの共有
  - 共有マシン
  - 仮想マシン
    - かなり強く隔離している
    - マルチテナントとは違う
    - 仮想マシンを管理するハイパーバイザにアクセスできない
      - いかなるソフトウェアも共有しない
  - コンテナのマルチテナント
    - コンテナ間の分離は VM 間ほど強力ではない
    - k8s
      - Namespace を利用してマシンのクラスタを細分化
      - 異なる個人、チーム、またはアプリケーションで利用できる
- セキュリティの原則
  - 最小権限
  - 多層防御
  - 攻撃対象領域の縮小

## sec 2

- コンテナは**ホストから見える Linux プロセスを実行**する
  - コンテナかしたプロセスは通常のプロセスのようにシステムコールを使用
    - パーミッションと権限を必要とする
- システムコール
  - プログラミング言語で抽象化されている
    - アプリ開発者として最も低レイヤーの抽象化は glibc や Go の syscall かも
    - [A beginner's guide to syscalls - Liz Rice (Aqua Security)](https://www.oreilly.com/library/view/oscon-2017/9781491976227/video306637.html)
  - アプリコンテナは、**コンテナかどうかに関わらず、全く同じ方法でシステムコールを呼ぶ**
    - １つのホスト上の**すべてのコンテナが同じカーネルを共有しているかはセキュリテイ上重要**
- ファイルパーミッション
  - 通常: ファイルの実行によって起動するプロセスはユーザー ID (UID) を継承する
  - ファイルに setuid ビットが設定されている場合、**プロセスは**そのファイルの所有者のユーザー ID を持つことになる
    - UID = 0 => root の UID
    - プログラムに必要で**一般ユーザーには拡張されていない特権を与えるため**に使用される
    - ping 実行ファイルが RAW ソケットを開く権限が必要、など
      - ping 実行ファイルに setuid ビットを設定し root ユーザーが所有する状態でインストールするなど

``` sh
$ cp "$(which sleep)" ./mysleep
$ ls -l mysleep
-rwxr-xr-x 1 ubuntu ubuntu 30944 Nov 28 12:45 mysleep

# setuid ビットを on にする
$ chmod +s mysleep
$ ls -l mysleep
-rwsr-sr-x 1 ubuntu ubuntu 30944 Nov 28 12:45 mysleep
```

- setuid のセキュリティ影響
  - bash に setuid をするとシェルないのすべてのユーザー操作は root の者になる？
    - 実際には ping と同じようにユーザー ID をリセットし、権限昇格を防ぐようになる！
  - 権限昇格の入り口になる
  - 昔の時代に、**非 root ユーザーに特別な特権を付与するための仕組み**を提供していた
- capability
  - スレッドに対して割り当てる
  - スレッドが特定のアクションを実行できるかを決定

``` sh
man capabilities

$ ps
    PID TTY          TIME CMD
 258998 pts/9    00:00:00 bash
1115045 pts/9    00:00:00 ps
# プロセスに割り当てられている capability の確認。
$ getpcaps 258998
258998: =

$ sudo bash
root@ubuntu:/home/ubuntu/work/linux/container# ps
    PID TTY          TIME CMD
1115430 pts/9    00:00:00 sudo
1115431 pts/9    00:00:00 bash
1115439 pts/9    00:00:00 ps
root@ubuntu:/home/ubuntu/work/linux/container# getpcaps 1115431
1115431: =ep
```

- 権限昇格
  - すでに root として動作しているソフトウェアを探し、そのソフトウェアにある既知の脆弱性を利用する

## sec 3

control group (cgroup)

- cgroup
  - メモリ、CPU、ネットワーク入出力などのリソースを制限
  - What Have Namespaces Done for You Lately?
    - https://www.youtube.com/watch?v=MHv6cWjvQjM
- 階層
  - 管理対象のリソースの種類ごとに cgroup の階層がある
    - 各階層は cgroup のコントローラーによって管理される
  - パラメータと情報がある

``` sh
$ ls /sys/fs/cgroup/
blkio  cpu,cpuacct  cpuset   freezer  net_cls,net_prio  perf_event  rdma     unified
cpu    cpuacct      devices  net_cls  net_prio          pids        systemd

$ sudo apt install cgroup-tools

# コンテナ内じゃなく host での shell から確認。
$ cat /proc/$$/cgroup
10:cpuset:/
9:rdma:/
8:freezer:/
7:pids:/user.slice/user-1000.slice/session-7047.scope
6:cpu,cpuacct:/user.slice
5:perf_event:/
4:devices:/user.slice
3:net_cls,net_prio:/
2:blkio:/user.slice
1:name=systemd:/user.slice/user-1000.slice/session-7047.scope
0::/user.slice/user-1000.slice/session-7047.scope

lscgroup cpu:/
```

``` sh
# プロセスを cgroup に割り当てる方法。
## プロセス id を cgroup.procs ファイルに書き込むだけ！

# Docker の作成する cgroup
$ ls */docker | grep docker
blkio/docker:
cpu,cpuacct/docker:
cpu/docker:
cpuacct/docker:
cpuset/docker:
devices/docker:
freezer/docker:
net_cls,net_prio/docker:
net_cls/docker:
net_prio/docker:
perf_event/docker:
pids/docker:
rdma/docker:
systemd/docker:
unified/docker:
```

やっぱり自分のカーネルは memory をサポートしてないらしい。

``` sh
$ docker run --rm --memory 100M -d alpine sleep 100000
Unable to find image 'alpine:latest' locally
latest: Pulling from library/alpine
579b34f0a95b: Pull complete
Digest: sha256:eece025e432126ce23f223450a0326fbebde39cdf496a85d8c016293fc851978
Status: Downloaded newer image for alpine:latest
WARNING: Your kernel does not support memory limit capabilities or the cgroup is not mounted. Limitation discarded.
883374c69b10b4809664588247844c5bdf3ca758be4b4dd3330cde2a9bb629c3
```

- cgroup v2
  - Linux カーネルは 2016~
  - **一般的なコンテナランタイムの実装は cgroup v1 を前提**としている
    - 今はどう？流石に v2 ？
- v1 と v2 の違い
  - **cgroup v2 ではプロセスがコントローラごとに異なる cgroup に所属できない！**
  - v1 ではプロセスは memory/mygroup と pids/yourgroup に参加できた
    - v2 ではよりシンプルになった
  - v2 で rootless コンテナのサポートが強化
- Docker での cgroup v2
  - v20.10 以降、cgroup v2 のサポート
  - cgroup **v2 に対応したホストマシンのカーネルとコンテナランタイムが必要**
  - **コンテナの cgroup バージョンはホストマシンに依存**
    - カーネル起動オプションに systemd.unified_cgroup_hierarchy=1 の設定？

Docker での cgroup について

https://docs.docker.com/config/containers/runmetrics/#enumerate-cgroups

``` sh
$ grep cgroup /proc/mounts
tmpfs /sys/fs/cgroup tmpfs ro,nosuid,nodev,noexec,mode=755 0 0
cgroup2 /sys/fs/cgroup/unified cgroup2 rw,nosuid,nodev,noexec,relatime,nsdelegate 0 0
cgroup /sys/fs/cgroup/systemd cgroup rw,nosuid,nodev,noexec,relatime,xattr,name=systemd 0 0
cgroup /sys/fs/cgroup/blkio cgroup rw,nosuid,nodev,noexec,relatime,blkio 0 0
cgroup /sys/fs/cgroup/net_cls,net_prio cgroup rw,nosuid,nodev,noexec,relatime,net_cls,net_prio 0 0
cgroup /sys/fs/cgroup/devices cgroup rw,nosuid,nodev,noexec,relatime,devices 0 0
cgroup /sys/fs/cgroup/perf_event cgroup rw,nosuid,nodev,noexec,relatime,perf_event 0 0
cgroup /sys/fs/cgroup/cpu,cpuacct cgroup rw,nosuid,nodev,noexec,relatime,cpu,cpuacct 0 0
cgroup /sys/fs/cgroup/pids cgroup rw,nosuid,nodev,noexec,relatime,pids 0 0
cgroup /sys/fs/cgroup/freezer cgroup rw,nosuid,nodev,noexec,relatime,freezer 0 0
cgroup /sys/fs/cgroup/rdma cgroup rw,nosuid,nodev,noexec,relatime,rdma 0 0
cgroup /sys/fs/cgroup/cpuset cgroup rw,nosuid,nodev,noexec,relatime,cpuset 0 0

# 自分の使ってる Docker は cgroup v1 っぽいな。。。
$ docker run -it --rm ubuntu bash
root@acc5bdb366fd:/# mount | grep cgroup
tmpfs on /sys/fs/cgroup type tmpfs (rw,nosuid,nodev,noexec,relatime,mode=755)
cgroup on /sys/fs/cgroup/systemd type cgroup (ro,nosuid,nodev,noexec,relatime,xattr,name=systemd)
cgroup on /sys/fs/cgroup/blkio type cgroup (ro,nosuid,nodev,noexec,relatime,blkio)
cgroup on /sys/fs/cgroup/net_cls,net_prio type cgroup (ro,nosuid,nodev,noexec,relatime,net_cls,net_prio)
cgroup on /sys/fs/cgroup/devices type cgroup (ro,nosuid,nodev,noexec,relatime,devices)
cgroup on /sys/fs/cgroup/perf_event type cgroup (ro,nosuid,nodev,noexec,relatime,perf_event)
cgroup on /sys/fs/cgroup/cpu,cpuacct type cgroup (ro,nosuid,nodev,noexec,relatime,cpu,cpuacct)
cgroup on /sys/fs/cgroup/pids type cgroup (ro,nosuid,nodev,noexec,relatime,pids)
cgroup on /sys/fs/cgroup/freezer type cgroup (ro,nosuid,nodev,noexec,relatime,freezer)
cgroup on /sys/fs/cgroup/rdma type cgroup (ro,nosuid,nodev,noexec,relatime,rdma)
cgroup on /sys/fs/cgroup/cpuset type cgroup (ro,nosuid,nodev,noexec,relatime,cpuset)
```
