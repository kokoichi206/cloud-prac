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

お, mac の方は cgroup v2 だった！

``` sh
docker run -it --rm ubuntu bash
root@65b6c9ae2a65:/# mount | grep cgroup
cgroup on /sys/fs/cgroup type cgroup2 (ro,nosuid,nodev,noexec,relatime)
```

## sec 4

コンテナの分離。コンテナ間、およびコンテナとホストがどの程度分離されているかを把握する！

コンテナは仮想マシンではないことを頭に叩き込んでおく。

- namespace
  - プロセスの**見ることのできる**リソースを制御
    - cf: cgroup = 使用できるリソースの制御
  - プロセスは常に TYPE ごとにそれぞれ１つの namespace に所属する！

``` sh
# 自分のマシンの namespace を確認。
$ lsns
        NS TYPE   NPROCS    PID USER   COMMAND
4026531835 cgroup     31 258998 ubuntu /bin/bash --init-file /home/ubuntu/.vscode-server/bin/2b35e1e6d88f1ce073683991d1eff528
4026531836 pid        31 258998 ubuntu /bin/bash --init-file /home/ubuntu/.vscode-server/bin/2b35e1e6d88f1ce073683991d1eff528
4026531837 user       31 258998 ubuntu /bin/bash --init-file /home/ubuntu/.vscode-server/bin/2b35e1e6d88f1ce073683991d1eff528
4026531838 uts        31 258998 ubuntu /bin/bash --init-file /home/ubuntu/.vscode-server/bin/2b35e1e6d88f1ce073683991d1eff528
4026531839 ipc        31 258998 ubuntu /bin/bash --init-file /home/ubuntu/.vscode-server/bin/2b35e1e6d88f1ce073683991d1eff528
4026531840 mnt        31 258998 ubuntu /bin/bash --init-file /home/ubuntu/.vscode-server/bin/2b35e1e6d88f1ce073683991d1eff528
4026531905 net        31 258998 ubuntu /bin/bash --init-file /home/ubuntu/.vscode-server/bin/2b35e1e6d88f1ce073683991d1eff528

# root 以外では不正確な情報の可能性がある。
$ sudo lsns
```

ホスト名の分離, 時間じゃないんかーい

UTS: Unix Timesharing System

``` sh
$ hostname
ubuntu
# 各コンテナにランダムな ID を付与している。あん
$ docker run -it --rm ubuntu bash
root@66e4e9af18ce:/# hostname
66e4e9af18ce

# 親のプロセスから共有されていない namespace でプログラムを実行できる！
$ man unshare

# 新しい UTS namespace を持つ、新しいプロセスで sh シェルが実行される。
$ sudo unshare --uts sh
# hostname
ubuntu
# hostname experiment
# hostname
experiment
# exit
$ hostname
ubuntu
```

プロセス ID の分離。

``` sh
# Docker コンテナ内で ps しても、そのコンテナ内で動作しているプロセスしか表示されない。
# ホスト上で動作しているプロセスは出てこない！
root@66e4e9af18ce:/# ps -eaf
UID          PID    PPID  C STIME TTY          TIME CMD
root           1       0  0 11:39 pts/0    00:00:00 bash
root          11       1  1 11:44 pts/0    00:00:00 ps -eaf
```

PID namespace により実現されている！

``` sh
$ sudo unshare --pid sh
# whoami
root
# whoami
sh: 2: Cannot fork
# whoami
sh: 3: Cannot fork
# ls
sh: 4: Cannot fork
# exit

$ ps fa
    PID TTY      STAT   TIME COMMAND
 262156 pts/0    Ss     0:00 /bin/bash --init-file /home/ubuntu/.vscode-server/bin/2b35e1e6d88f1ce073683991d1eff5284a32690f/o
2022110 pts/0    Sl+    0:00  \_ docker run -it --rm ubuntu bash

# sudo unshare --pid --fork sh で開いた時。
# unshare プロセスの子プロセスとして実行されるようになる。
$ ps fa
 262156 pts/0    Ss     0:00 /bin/bash --init-file /home/ubuntu/.vscode-server/bin/2b35e1e6d88f1ce073683991d1eff5284a32690f/o
2028433 pts/0    S      0:00  \_ sudo unshare --pid --fork sh
2028434 pts/0    S      0:00      \_ unshare --pid --fork sh
2028435 pts/0    S+     0:00          \_ sh


$ man ps | grep /proc
       This ps works by reading the virtual files in /proc.  This ps does not need to be setuid kmem or have any
```

実行中のプロセス ID の namespace に関係なく ps は実行中のプロセスに関する情報を /proc に探しに行く！

ps が新しい namespace の情報のみを返すには、カーネルが ns のプロセスに関する情報を書き込める新たな /proc ディレクトリのコピーが必要。
proc が root 直下であることを考えると、これは root ディレクトリの変更を意味する。

**root ディレクトリの変更**

``` sh
$ mkdir new_root

# 新しい root ディレクトリの中に bin ディレクトリがなく、/bin/bash を実行できないことが原因！
$ sudo chroot new_root/
chroot: failed to run command ‘/bin/bash’: No such file or directory

# https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/aarch64/


mkdir alpine
cd alpine/
curl -o alpine.tar.gz https://dl-cdn.alpinelinux.org/alpine/v3.18/releases/aarch64/alpine-minirootfs-3.18.0-aarch64.tar.gz
ls
tar xvf alpine.tar.gz
rm alpine.tar.gz
cd ..

sudo chroot alpine ls
```

ns と root ディレクトリ変更を組み合わせる。

途中、プロセス情報を格納するために proc タイプの擬似ファイルシステムとしてマウントしている。

``` sh
r$ sudo unshare --pid --fork chroot alpine sh
/ # ls
bin    dev    etc    home   lib    media  mnt    opt    proc   root   run    sbin   srv    sys    tmp    usr    var
/ # ps
PID   USER     TIME  COMMAND
/ # mount -t proc proc proc
/ # ps
PID   USER     TIME  COMMAND
    1 root      0:00 sh
    5 root      0:00 ps
```

マウントの分離。

バインドマウントができると source ディレクトリの内容も target で利用できるようになる。

``` sh
$ sudo unshare --mount sh
# mkdir source
# ls
alpine  main.go  mysleep  new_root  source
# touch source/HELLO
# ls source
HELLO
# mkdir target
# ls target
# mount --bind source target
# ls target
HELLO
```

ネットワークインタフェースとルーティングテーブルの隔離。

network ns

``` sh
$ sudo lsns -t net
        NS TYPE NPROCS     PID USER                NETNSID NSFS COMMAND
4026531905 net     278       1 root             unassigned      /sbin/init fixrtc splash
4026532304 net       1 2835439 rtkit            unassigned      /usr/libexec/rtkit-daemon
4026532382 net       2  670078 root                      1      /usr/bin/dumb-init /entrypoint run --user=gitlab-runner --wor
4026532461 net       6  670099 systemd-coredump          0      postgres
4026532526 net       1  670108 root                      2      /go/bin/all-in-one-linux
4026532595 net       1 1999108 root                      3      sleep 100000


$ sudo unshare --net bash
root@ubuntu:/home/ubuntu/work/linux/container# lsns -t net
        NS TYPE NPROCS     PID USER                NETNSID NSFS COMMAND
4026531905 net     277       1 root             unassigned      /sbin/init fixrtc splash
4026532304 net       1 2835439 rtkit            unassigned      /usr/libexec/rtkit-daemon
4026532382 net       2  670078 root             unassigned      /usr/bin/dumb-init /entrypoint run --user=gitlab-runner --wor
4026532461 net       6  670099 systemd-coredump unassigned      postgres
4026532526 net       1  670108 root             unassigned      /go/bin/all-in-one-linux
4026532595 net       1 1999108 root             unassigned      sleep 100000
4026532659 net       2 2066121 root             unassigned      bash
```

``` sh
$ sudo unshare --net bash
# 最初はループバックインタフェースしかない！！！ -> コンテナへは通信できない。
root@ubuntu:/home/ubuntu/work/linux/container# ip a
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
```

仮想イーサネットインタフェースのペアを作成。コンテナの ns とデフォルトの network ns を接続する。

``` sh
# 別のターミナルで。
$ sudo su
root@ubuntu:/home/ubuntu/work/linux# lsns -t net
        NS TYPE NPROCS     PID USER                NETNSID NSFS COMMAND
4026531905 net     286       1 root             unassigned      /sbin/init fixrtc splash
4026532304 net       1 2835439 rtkit            unassigned      /usr/libexec/rtkit-daemon
4026532382 net       2  670078 root                      1      /usr/bin/dumb-init /entrypoint run --user=gitlab-runner --wor
4026532461 net       6  670099 systemd-coredump          0      postgres
4026532526 net       1  670108 root                      2      /go/bin/all-in-one-linux
4026532595 net       1 1999108 root                      3      sleep 100000
4026532659 net       1 2076651 root             unassigned      bash

# type veth = 仮想イーサネットペア
root@ubuntu:/home/ubuntu/work/linux# ip link add ve1 netns 2076651 type veth peer name ve2 netns 1
You have new mail in /var/mail/root
```

この状態で元々作成していた bash から ip a を再度調べる。
コンテナのプロセス内部から見えるようになっている！

``` sh
root@ubuntu:/home/ubuntu/work/linux/container# ip a
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: ve1@if30: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether ce:4a:d5:d2:a5:a6 brd ff:ff:ff:ff:ff:ff link-netnsid 0
You have new mail in /var/mail/root
```

link は down になっているので立ち上げる。

``` sh
# コンテナ内
root@ubuntu:/home/ubuntu/work/linux/container# ip link set ve1 up
# ホストのルート
root@ubuntu:/home/ubuntu/work/linux# ip link set ve2 up

# 立ち上がったことを確認
root@ubuntu:/home/ubuntu/work/linux/container# ip a
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: ve1@if30: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether ce:4a:d5:d2:a5:a6 brd ff:ff:ff:ff:ff:ff link-netnsid 0
    inet6 fe80::cc4a:d5ff:fed2:a5a6/64 scope link
       valid_lft forever preferred_lft forever
```

IP トラフィックを送信するために IP アドレスを付与。

``` sh
# コンテナ内
root@ubuntu:/home/ubuntu/work/linux/container# ip addr add 192.168.1.100/24 dev ve1
# ホストのルート
root@ubuntu:/home/ubuntu/work/linux# ip addr add 192.168.1.200/24 dev ve2

# コンテナ内のルーティングテーブルに IP 経路を追加する効果もある。
# network ns はルーティングテーブルも分離するため、これはホストとは独立している！
root@ubuntu:/home/ubuntu/work/linux/container# ip route
192.168.1.0/24 dev ve1 proto kernel scope link src 192.168.1.100


root@ubuntu:/home/ubuntu/work/linux/container# ip link set lo up
root@ubuntu:/home/ubuntu/work/linux/container# ping 192.168.1.100
PING 192.168.1.100 (192.168.1.100) 56(84) bytes of data.
64 bytes from 192.168.1.100: icmp_seq=1 ttl=64 time=0.063 ms
64 bytes from 192.168.1.100: icmp_seq=2 ttl=64 time=0.113 ms
64 bytes from 192.168.1.100: icmp_seq=3 ttl=64 time=0.117 ms
^C
--- 192.168.1.100 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2030ms
rtt min/avg/max/mdev = 0.063/0.097/0.117/0.024 ms
```

user ns

プロセスがユーザーおよびグループ ID の独自のビューを持てるようにする。
プロセス ID と同じく、ユーザーとグループはホスト上に存在するが、異なる ID を持つことができる。

**コンテナ内の ID 0 の root ユーザーを、ホスト上の非 root ユーザーにマッピングすることができる！**

一般に新しい ns を作成するには root ユーザー権限が必要 ⇨ そのため Docker デーモンは root ユーザで実行される！
しかし user ns は例外！

``` sh
$ unshare --user bash
$ id
uid=65534(nobody) gid=65534(nogroup) groups=65534(nogroup)
$ echo $$
2090816
```

ns の内側とホストとのユーザー ID の対応づけは `/proc/<pid>/uid_map` に存在する。

``` sh
# 子プロセスから見たマッピングする最小 ID, ホスト上でマッピングされるべき最小 ID, マッピングされる ID の数。
## どういった意味で最小、っていってるんだっけ。
ubuntu@ubuntu:~/work/linux$ sudo echo '0 1000 1' > /proc/2090816/uid_map

nobody@ubuntu:~/work/linux/container$ id
uid=0(root) gid=65534(nogroup) groups=65534(nogroup)

nobody@ubuntu:~/work/linux/container$ capsh --print | grep Current
Current: =ep
```

user ns を利用すると、非特権ユーザーがコンテナ化されたプロセス内で事実上 root ユーザーとして振る舞える！
→ rootless コンテナ


プロセス間通信
（IPC namespace: Inter Process Communication）

IPC を利用するには、２つのプロセスが同じ IPC ns のメンバーである必要がある。

``` sh
ubuntu@ubuntu:~/work/linux$ ipcmk -M 1000
Shared memory id: 2
ubuntu@ubuntu:~/work/linux$ ipcs

------ Message Queues --------
key        msqid      owner      perms      used-bytes   messages

------ Shared Memory Segments --------
key        shmid      owner      perms      bytes      nattch     status
0x0052e2c1 0          postgres   600        56         6
0xeae3a8d4 1          ubuntu     644        1000       0
0xf568846f 2          ubuntu     644        1000       0

------ Semaphore Arrays --------
key        semid      owner      perms      nsems
```

独自の IPC ns を持つプロセスには表示されない。

``` sh
ubuntu@ubuntu:~/work/linux$ sudo unshare --ipc sh
# ipcs

------ Message Queues --------
key        msqid      owner      perms      used-bytes   messages

------ Shared Memory Segments --------
key        shmid      owner      perms      bytes      nattch     status

------ Semaphore Arrays --------
key        semid      owner      perms      nsems

# whoami
root
```

cgroup ns

cgroup ファイルシステムの chroot のようなもの。
プロセスが自分の cgroup よりも上位の cgroup ディレクトリの設定を閲覧できないようにする。

``` sh
ubuntu@ubuntu:~/work/linux$ cat /proc/self/cgroup
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
ubuntu@ubuntu:~/work/linux$ sudo unshare --cgroup bash
root@ubuntu:/home/ubuntu/work/linux# cat /proc/self/cgroup
10:cpuset:/
9:rdma:/
8:freezer:/
7:pids:/
6:cpu,cpuacct:/
5:perf_event:/
4:devices:/
3:net_cls,net_prio:/
2:blkio:/
1:name=systemd:/
0::/
```

ホストから見たコンテナ**プロセス**

``` sh
ubuntu@ubuntu:~/work/linux$ docker run --rm -it ubuntu bash
root@9db3142074d4:/# sleep 1000 &
[1] 10
```

ホストから見ると、2120918 が割り当てられている。

``` sh
ubuntu@ubuntu:~/work/linux$ ps -C sleep
    PID TTY          TIME CMD
1221091 ?        00:00:00 sleep
1999108 ?        00:00:00 sleep
2119619 ?        00:00:00 sleep
2119870 ?        00:00:00 sleep
2120918 pts/0    00:00:00 sleep
2120935 ?        00:00:00 sleep
```

プロセス ID が大きく異なるが、**どちらも同じプロセスを指している**ことに変わりはない！

このように、**コンテナ内のプロセスはホストから見える。**

コンテナを実行するために特別に設計された『Thin OS』ディストリビューションもいくつか存在する！

## sec 5

- 仮想マシン: VM
  - vs コンテナ
    - 両者に本当に明瞭な違いがあるわけではない
    - VM はカーネルを含む OS 全体のコピーを実行する
    - コンテナはホストマシンのカーネルを共有する
- マシンの起動
  - 特権レベルの階層
    - x86 プロセッサでは4段階
    - カーネルはリング0、ユーザー空間はリング3で動作
- VMM: Virtual Machine Monitor
  - Type1, Type2 がある
- Type1 VMM (ハイパーバイザ)
  - 専用のカーネルレベルの VMM プログラムが実行される
    - ハイパーバイザはリング0で動作
  - ハイパーバイザはハードウェア（またはベアメタル）上で動作し、その下に OS はない
  - **ゲスト OS カーネルはリング1で実行される！**
- Type2 VMM
  - ホストされた VM
    - ホスト OS の上に VMM, ゲスト OS が乗ってくる
- KVM: Kernelbased Virtual Machines
  - 中間的な立場のものもある
- トラップ & エミュレート
  - CPU 命令の中にはリング0でしか実行できない特権的なものもある
    - 上位のリングで実行を試みた場合、トラップが発動する
  - VMM は、ゲスト OS が特権命令によって互いに干渉しないように防いでいる
- **仮想マシンは強力な分離境界を持つ**
  - ハイパーバイザはシンプル？
    - Linux カーネルのコード行数は2000万行以上
    - Xen ハイパーバイザは5万行程度
- 仮想マシンのデメリット
  - 起動時間が、コンテナに比べてずっと長い
  - カーネルを動かすためのオーバーヘッドがある
- 分離の点から比較
  - コンテナがカーネルを共有しているという単純な事実は、**ただ分離しただけではコンテナの方が脆弱性が高い**ことを意味する

## sec 6

- コンテナイメージ
  - root ファイルシステム
    - FROM, ADD, COPY, RUN
  - 設定情報
    - USER, PORT, ENV
- **OCI: Open Container Initiative**
  - コンテナイメージとランタイムに関する標準を定義

``` sh
docker image inspect mysql:8.0.27
```

- build
  - コマンドを API リクエストに変換し、Docker ソケットを介して Docker デーモンに送信する
- Docker デーモン
  - コンテナとコンテナイメージの両方を実行・管理する
  - コンテナの作成には ns の作成が必要であるため root としての実行が必要
    - Docker デーモンへ依存せずにコンテナイメージをビルドするための代替ツールが出てきた
- デーモンレスビルド
  - [BuildKit](https://docs.docker.jp/develop/develop-images/build_enhancements.html)
    - Docker の rootless ビルドモードの基礎になる
  - podman
  - bazel
    - 毎回同じイメージを再現できる
  - Kaniko
    - k8s 内でのビルド
- コンテナレジストリ
- ビルド時のセキュリティ
  - ベースイメージ
    - ベースイメージが小さいほど、不要なコードが含まれる可能性が小さくなり攻撃対象領域も小さくなる
  - マルチステージビルド
  - 非 root ユーザー
  - setuid バイナリを避ける
  - 不要なコードを避ける
- レジストリのセキュリティ
  - イメージの署名？
  - in-todo
- デプロイのセキュリティ
  - アドミッションコントロール
    - コンテナにインスタンス化する前に、コンテナイメージに対していくつかの重要なセキュリティチェックを実行できる！

## sec 7

- 脆弱性
  - レスポンシブル・ディスクロージャ
    - 発表前に修正プログラムを提供できる形にする
  - CVE: Common Volnerabilities and Exposures
    - 脆弱性に対する識別子
  - NVD: National Vulnerability Database
    - 影響を受けるパッケージの全バージョンのリスト
- アプリケーションレベルの脆弱性
  - コンパイル言語
    - サードパーティの依存関係は共有ライブラリとしてインストール or ビルド時にバイナリにリンクされる
  - アプリケーションが依存関係を持たない場合、公開されたパッケージの脆弱性はスキャンできない
- イミュータブルコンテナ
  - コンテナ起動後に、**追加のソフトウェアをファイルシステムにダウンロードするのを防ぐ仕組みはない**
  - **定期スキャン**
    - パッチバージョンって、固定しておいた方がいいのか？
      - **スキャンする時に、パッチバージョンが最新のものだと検出できない可能性がありそう**

## sec 8

- サンドボックス
  - アプリケーションを分離してリソースへのアクセスを制限する
- seccomp: secure computing mode
  - アプリケーションが実行できるシステムコールを制限する
  - Docker のデフォルト seccomp プロファイルは、300 以上のシステムコールのうち 40 以上をブロックする
    - **悪影響はほとんどないので使用するのがいい**
  - Docker では seccomp がデフォルトで使用される
    - k8s にはデフォルトで適応されるものがなさそう
  - [k8s seccomp](https://kubernetes.io/docs/tutorials/security/seccomp/)
    - kind の例もある
- システムコールをより正確に把握する
  - strace
  - eBPF: extended Berkeley Packet Filter
    - **seccomp は BPF を使用して送信されるシステムコールを制限している**

``` sh
ubuntu@ubuntu:~/work/linux$ strace -c echo hello
hello
% time     seconds  usecs/call     calls    errors syscall
------ ----------- ----------- --------- --------- ----------------
 47.47    0.003495        3495         1           execve
 21.08    0.001552          40        38        20 openat
 10.88    0.000801          29        27         6 newfstatat
  7.61    0.000560          26        21           mmap
  5.19    0.000382          19        20           close
  1.55    0.000114          28         4           mprotect
  1.28    0.000094          31         3           munmap
  1.21    0.000089          29         3           read
  0.86    0.000063          21         3           brk
  0.62    0.000046          46         1         1 faccessat
  0.60    0.000044          44         1           write
  0.34    0.000025          25         1           getrandom
  0.30    0.000022          22         1           prlimit64
  0.27    0.000020          20         1           set_tid_address
  0.26    0.000019          19         1           futex
  0.26    0.000019          19         1           rseq
  0.24    0.000018          18         1           set_robust_list
------ ----------- ----------- --------- --------- ----------------
100.00    0.007363                   128        27 total
```

- AppArmor: Application Armor
  - LSM: Linux Security Module の１つ
  - 強制アクセス制御
    - MAC: Mandatory Access Control

``` sh
ubuntu@ubuntu:~/work/linux$ cat /sys/module/apparmor/parameters/enabled
Y
```

- SELinux: Security-Enhanced Linux
  - LSM の1種
  - Red Hat のディストリビューションをホストで使ってる場合、SELinux はすでに有効な可能性が高い
  - プロセスがファイルやその他のプロセスにアクセスできるかを制限する

``` sh
ls -lZ
ps -axZ

ps fax
```

- Kata Containers
  - コンテナを別の仮想マシン内で実行
  - AWS: コンテナを実行するために特別に設計された軽量の仮想マシン
- Firecracker
  - ハイパーバイザによる安全な分離と共有カーネルを使わない仮想マシン
  - 起動時間が100ms程度！！
  - Lambda, Fargate
  - **一般的なカーネルには含まれるが、コンテナでは不要な機能を削除したため高速**
    - 必要不可欠なデバイス以外を取り除く
- Unikernel
  - **アプリケーションとそのアプリケーションが必要とする OS の部分からなる専用のマシンイメージを作成する**
  - ハイパーバイザ上で直接実行可能
    - **通常の仮想マシンと同じレベルの分離**
  - 爆速な起動時間

## sec 9

- デフォルトでは root で実行される
  - root として実行されている Docker デーモンが代わりにコンテナを作成
  - 攻撃者が root として実行されているコンテナから外に出てしまうと、ホストへの完全な root アクセスを持つことになる
- root で実行する良さ
  - 1024 以下のポートを開くには `CAP_NET_BIND_SERVICE` が必要
    - 最も簡単には root ユーザで実行すること
  - パッケージマネージャを使用してソフトウェアをインストールするケース
    - apt, yum
- コンテナ**実行時に**ソフトウェアのパッケージ**インストールをしない**
  - **ビルド時にやる**
  - なぜ
    - 非効率
    - 脆弱性のスキャンができない
    - 読み取り専用で実行できるようになる
      - docker -> --read-only, k8s -> ReadOnlyRootFileSystem
    - イミュータブルコンテナ

``` sh
$ whoami
ubuntu
$ docker run -it alpine sh
/ # whoami
root
/ # sleep 100

# 別ターミナルから確認。ホストの root と同じであることがわかる。
$ ps -fC sleep
UID          PID    PPID  C STIME TTY          TIME CMD
root      137019  136503  0 18:17 pts/0    00:00:00 sleep 100
```

- `--privileged` オプション
  - **コンピューティング史上最も危険なフラグ**と呼ばれてるらしい。。。

``` sh
# ここで付与されている capability は実装に依存している。
$ docker run --rm --network=host alpine sh -c 'apk add -U libcap; capsh -
-print | grep Current'
Current: cap_chown,cap_dac_override,cap_fowner,cap_fsetid,cap_kill,cap_setgid,cap_setuid,cap_setpcap,cap_net_bind_service,cap_net_raw,cap_sys_chroot,cap_mknod,cap_audit_write,cap_setfcap=ep
Current IAB: !cap_dac_read_search,!cap_linux_immutable,!cap_net_broadcast,!cap_net_admin,!cap_ipc_lock,!cap_ipc_owner,!cap_sys_module,!cap_sys_rawio,!cap_sys_ptrace,!cap_sys_pacct,!cap_sys_admin,!cap_sys_boot,!cap_sys_nice,!cap_sys_resource,!cap_sys_time,!cap_sys_tty_config,!cap_lease,!cap_audit_control,!cap_mac_override,!cap_mac_admin,!cap_syslog,!cap_wake_alarm,!cap_block_suspend,!cap_audit_read

# privileged 付き。
$ docker run --rm -it --network=host --privileged alpine sh -c 'apk add -U libcap; capsh --print | grep Current'
fetch https://dl-cdn.alpinelinux.org/alpine/v3.18/main/aarch64/APKINDEX.tar.gz
fetch https://dl-cdn.alpinelinux.org/alpine/v3.18/community/aarch64/APKINDEX.tar.gz
Current: =ep
Current IAB:
```

- `=ep`
  - https://unix.stackexchange.com/questions/515881/what-does-the-ep-capability-mean
    - `=` は `all=` と同じ
    - p = capabilities permitted
    - e = capabilities effective

- **サイドカーコンテナ**
  - アプリケーションコンテナの **ns に意図的にアクセスすることで、アプリケーションから機能を委譲する**

## sec 10

- コンテナファイアウォール
  - コンテナとの間で流れるトラフィックを制御可
    - k8s → ネットワークポリシー（ネットワークプラグイン）
  - 他のネットワークセキュリティツールと組み合わせ
- OSI 参照モデル
  - L4:
    - TCP, UDP が使われる
    - port 番号が適応される
  - L3:
    - IP パケットが通過する
    - IPv4, IPv6
  - L2:
    - MAC アドレス
  - L1:
    - コンテナのネットワークインタフェースは L1 でも仮想化されている
- コンテナの IP アドレス
  - k8s では pod が独自の IP アドレスを持つ
    - IP アドレスによって他のすべての Pod にアクセスできる
      - 通常とは考え方が異なる
  - **NAT はプライベートネットワーク内で IP アドレスの大部分を再利用できることを意味する**
  - k8s
    - ネットワークセキュリティポリシー
    - セグメンテーション
  - Service in k8s
    - **NAT の一種！**
- L3/L4 のルーティング
  - L3:
    - IP パケットのネクストホップの決定に関係
    - 負荷分散、NAT、ファイアウォールなどなども可能
  - cf. L4 で動作させれば、ポート番号にも対応できる
  - [netfilter](https://netfilter.org/) というカーネルの機能に依存
- iptables
  - netfilter を使用してカーネルで処理される IP パケットの処理ルールを設定
    - filter table
    - nat table
  - k8s の service の数が多くなると性能問題につながる
    - IPVS の使用
      - IP Virtual Server
      - ハッシュテーブル

``` sh
while true; do echo -e "hello" | nc -l 8001 -N; done

$ curl localhost:8001
curl: (1) Received HTTP/0.9 when not allowed
$ curl --http0.9 localhost:8001
hello


while true; do echo -e "HTTP/1.1 200 OK\r\n\r\nhello" | nc -l 8001 -N; done

$ curl localhost:8001
hello
```

iptables のルール変更

``` sh
$ sudo iptables -I INPUT -j REJECT -p tcp --dport=8001

$ sudo iptables -L | grep 8001 -C2
Chain INPUT (policy DROP)
target     prot opt source               destination
REJECT     tcp  --  anywhere             anywhere             tcp dpt:8001 reject-with icmp-port-unreachable
ufw-before-logging-input  all  --  anywhere             anywhere
ufw-before-input  all  --  anywhere             anywhere

# iptables によって弾かれた！
$ curl localhost:8001
curl: (7) Failed to connect to localhost port 8001: Connection refused
```

見てきたように、ネットワークポリシーは L4 までで動作する。

- サービスメッシュ
  - L5-7 で実装される
  - クラウドネイティブなエコシステムの例
    - Istio, Envoy,mLinkerd
  - いろいろ
    - mTLS
    - ネットワークポリシー
  - サービスメッシュのサイドカーコンテナ
    - プリケーションと同じ pod に存在する
- Istio Ambient Mesh (2022/09)
  - サイドカーが廃止になった
  - メリット
    - 運用の簡素化
    - リソースの効率的な利用

## Links

- [docker guide/layers](https://docs.docker.com/build/guide/layers/)
- [A Go Programmer's Guide to Syscalls](https://www.youtube.com/watch?v=01w7viEZzXQ&ab_channel=GopherAcademy)
