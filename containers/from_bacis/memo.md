## コンテナ？

コンテナとは単なるプロセスである。

``` sh
$ docker run --rm -it -d ubuntu sleep 100

# ホスト側のプロセスとして確認できる。
# VM もプロセスであることに変わりはないよね。？
$ ps aux | grep sleep
root     3586782  1.6  0.0   2200   764 pts/0    Ss+  02:32   0:00 sleep 100

# また、コンテナからはホストのプロセスは見えない。
$ docker run --rm -it ubuntu ps auxf
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1 11.0  0.0   6404  1636 pts/0    Rs+  02:34   0:00 ps auxf
```

``` mermaid
graph LR
    subgraph Docker デーモン TB
    dockerd[dockerd] --> containerd[containerd] --> |コンテナ実行| runc[runc]
    end
    user[クライアント] -->|UNIX ドメインソケット<br>TCP 通信| dockerd[Dockerデーモン]
```

- dockerd
  - コンテナイメージの管理・ネットワーク管理を行うデーモン
  - Docker デーモンとも
- ランタイムの標準仕様
  - CRI, OCI Spec
- 高レイヤランタイム
  - コンテナやネットワークの管理を担うランタイム
  - rootfs 展開、低レイヤとのやり取り
  - クライアントと高レイヤランタイムのやり取り
    - dockerd, kubelet
  - CRI: Container Runtime Interface を実装しているものがある
    - CRI ランタイムとも呼ばれる
  - 実装例
    - Docker
      - 低レイヤランタイムの呼び出しに containerd を使用
      - CRI は実装されていない
    - containerd
      - CNCF で開発されているコンテナランタイム
      - 拡張可能
    - CRI-O
      - CNCF のプロジェクト
      - k8s にフォーカスされている
- 低レイヤランタイム
  - コンテナとして実行する**プロセスを、ホストから分離して**実行
  - OCI: Open Container Initiative に仕様が定められている
    - OCI ランタイムとも呼ばれる
  - 実装例
    - runc
      - OCI Runtime のリファレンス実装
      - Go と一部 C での実装
    - crun
      - OCI Runtime
      - すべて C で実装
        - メモリ使用量が少なく高速
    - gVisor
      - secure
      - Cloud Run, App Engine
    - Kata Containers

## コンテナの仕組み

- Docker デーモンはコンテナの操作に REST API を提供している。
  - [api docs](https://docs.docker.com/engine/api/v1.42/)
    - e.g. `docker ps` is GET `/containers/json`

``` sh
curl --unix-socket /var/run/docker.sock http://v1.40/containers/json

## ----------- which version should i use? -------------
curl --unix-socket /var/run/docker.sock http://localhost/version > localhost_version
$ cat localhost_version | jq '{ApiVersion, MinAPIVersion}'
{
  "ApiVersion": "1.43",
  "MinAPIVersion": "1.12"
}


curl --unix-socket /var/run/docker.sock \
    -X POST \
    -H 'Content-Type: application/json' \
    'http://v1.40/images/create?fromImage=ubuntu&tag=latest'

$ cat request.json
{
    "AttachStdin": false,
    "AttachStdout": true,
    "AttachStderr": true,
    "Tty": true,
    "OpenStdin": false,
    "StdinOnce": false,
    "Entrypoint": "/bin/bash",
    "Image": "ubuntu:latest"
}

curl --unix-socket /var/run/docker.sock \
    -X POST \
    -H 'Content-Type: application/json' \
    --data @request.json \
    'http://v1.40/containers/create'
{"Id":"f3bcb95a8ff8d25b084e7527374c04381e979270479a7d393c75903451fdc4ad","Warnings":[]}

$ docker ps -a --no-trunc | grep ubuntu
f3bcb95a8ff8d25b084e7527374c04381e979270479a7d393c75903451fdc4ad   ubuntu:latest   "/bin/bash"   29 seconds ago   Created

# コンテナを起動する。
curl --unix-socket /var/run/docker.sock \
    -X POST \
    -H 'Content-Type: application/json' \
    'http://v1.40/containers/f3bcb95a8ff8d25b084e7527374c04381e979270479a7d393c75903451fdc4ad/start'


$ docker ps -a --no-trunc | grep ubuntu
f3bcb95a8ff8d25b084e7527374c04381e979270479a7d393c75903451fdc4ad   ubuntu:latest   "/bin/bash"   4 minutes ago   Up 20 seconds

# コマンドの実行。
## exec に送信する, DetachKeys を送ってるのが面白い。
curl --unix-socket /var/run/docker.sock \
    -X POST \
    -H 'Content-Type: application/json' \
    --data-binary '{"AttachStdin": true, "AttachStdout": true, "AttachStderr": true, "Cmd": ["uname", "-a"], "DetachKeys": "ctrl-p,ctrl-q", "Tty": true}' \
    'http://v1.40/containers/f3bcb95a8ff8d25b084e7527374c04381e979270479a7d393c75903451fdc4ad/exec'
{"Id":"d91dad0667f147b04a618b7757f60b926061c1729258f5ed32320d698c49fa12"}

## 上で出てきた Id を使う。
curl --unix-socket /var/run/docker.sock \
    -X POST \
    -H 'Content-Type: application/json' \
    --data-binary '{"Detach": false, "Tty": false}' \
    'http://v1.40/exec/d91dad0667f147b04a618b7757f60b926061c1729258f5ed32320d698c49fa12/start' --output /tmp/output.txt

$ cat /tmp/output.txt
{Linux f3bcb95a8ff8 5.4.0-1045-raspi #49-Ubuntu SMP PREEMPT Wed Sep 29 17:49:16 UTC 2021 aarch64 aarch64 aarch64 GNU/Linux
```

### レイヤ構造

``` Dockerfile
FROM alpine:latest

RUN apk update
RUN apk add curl

COPY localhost_version /etc/localhost_version
```

``` sh
docker build -t myimage:test .

mkdir dump
docker save myimage:test -o dump/myimage.tar

cd dump
tar xf myimage.tar
rm myimage.tar

#
resolvectl status
resolvectl status eth0

DOCKER_OPTS="--dns 8.8.8.8"
```

### Capability

``` sh
$ nc -l 80
nc: Permission denied

# Capability を与えると一般ユーザ権限でも 1024 未満のポートでサービスが起動できる。
$ cp /usr/bin/nc mync
$ sudo setcap 'CAP_NET_BIND_SERVICE=ep' ./mync
$ ./mync -l 80
```

コンテナアプリケーションへの capability の付与・削除は '-cap-add', 'cap-drop' で可能。

### ns

``` sh
# ns 一覧の確認
sudo lsns

# 特定のプロセスがどの ns に属しているかの確認。
$ ls /proc/$$/ns/
cgroup  ipc  mnt  net  pid  pid_for_children  user  uts

$ ls -l /proc/self/ns/*
lrwxrwxrwx 1 ubuntu ubuntu 0 Dec  5 18:44 /proc/self/ns/cgroup -> 'cgroup:[4026531835]'
lrwxrwxrwx 1 ubuntu ubuntu 0 Dec  5 18:44 /proc/self/ns/ipc -> 'ipc:[4026531839]'
lrwxrwxrwx 1 ubuntu ubuntu 0 Dec  5 18:44 /proc/self/ns/mnt -> 'mnt:[4026531840]'
lrwxrwxrwx 1 ubuntu ubuntu 0 Dec  5 18:44 /proc/self/ns/net -> 'net:[4026531905]'
lrwxrwxrwx 1 ubuntu ubuntu 0 Dec  5 18:44 /proc/self/ns/pid -> 'pid:[4026531836]'
lrwxrwxrwx 1 ubuntu ubuntu 0 Dec  5 18:44 /proc/self/ns/pid_for_children -> 'pid:[4026531836]'
lrwxrwxrwx 1 ubuntu ubuntu 0 Dec  5 18:44 /proc/self/ns/user -> 'user:[4026531837]'
lrwxrwxrwx 1 ubuntu ubuntu 0 Dec  5 18:44 /proc/self/ns/uts -> 'uts:[4026531838]'
```

### Seccomp

- Seccomp: secure computing mode
- **システムコールとその引数を制限**できる
- Mode 1
  - 厳しい制約
- Mode 2
  - BPF: Berkeley Packet Filter
  - 任意のシステムコールが制限可能に！
- Docker がデフォルトで禁止しているシステムコール
  - https://docs.docker.com/engine/security/seccomp/#significant-syscalls-blocked-by-the-default-profile

### LSM: Linux Security Module

- MAC: Mandatory Access Control を提供するカーネルの機能
- 実装例
  - SAppArmor
    - Ubuntu, Debian
  - SELinux
    - CentOS, Fedora
- root 権限であってもアクセスを制御可能
- Docker -> [docker-default](https://matsuand.github.io/docs.docker.jp.onthefly/engine/security/apparmor/)
  - コンテナが利用するもので、Docker デーモンが利用するものではない
  - proc などを Read-Only でマウントしている

## 攻撃手法

- アタックサーフェスを最小にする！
- コンテナランタイムへの攻撃
  - Docker API への攻撃（コンテナランタイムに Docker を使用してる場合）
    - Docker API に外部から攻撃できるようになってないか
- コンテナの設定不備
  - capability
    - CAP_SYSLOG
      - dmesg の削除
    - CAP_NET_RAW
      - ARP スプーフィングなどの、ネットワークを盗聴する攻撃
    - CAP_SYS_ADMIN
      - ケーパビリティの中で**特に権限が高い**
      - 権限昇格
  - 特権コンテナ
    - 全てのデバイスファイルにアクセスできる
    - セキュリティオプションが無効になってるものがある
      - 分離レベルが弱い
- DOS 攻撃
  - Fork 攻撃
    - Fok Bomb
  - ディスク容量の圧迫
- DooD: Docker Outside Of Docker

``` sh
docker run --rm -it alpine sh

# Fork 爆弾
f() { f | f & }; f
```

- Linux カーネルへの攻撃
  - Dirty COW
    - 非特権ユーザーが読み取り専用のメモリへ書き込めてしまう
  - Dirty Pipe
- サプライチェーン攻撃
  - サードパーティに位置するソフトウェアを改ざんし、アプリケーションやその実行環境で悪意のあるコードを実行する
  - 対策
    - 信頼できるイメージを使用する
    - イメージに対してマルウェアスキャンを実行する

## いい感じのコンテナイメージ

- コンテナイメージの実物
  - **ファイルシステムをレイヤとして保持して１つにまとめたもの**
- Trivy
  - subcommands
    - image
    - filesystem
    - config
      - Dockerfile や k8s マニフェストなどの設定ミスを検出する
  - flags
    - --ignore-unfixed

``` sh
# trivy による Dockerfile のスキャン。
## ===== 便利そう。 =====
trivy config .

# trivy config --policy policy/ --namespaces user .
```

- Secret の取り扱い
  - docker build の --secret オプション
  - Docker 18.06 からイメージビルドのバックエンドとして Buildkit ！！

``` sh
docker build -t go-test:latest --build-arg GIT_PASSWORD=top-secret .

docker save go-test:latest | tar -xC dump/

# あれだと思う, deploy 用の IMAGE を用意する時だと build 時に渡した argument は残ってなさそう！！
```

- ベストプラクティス
  - イメージはタグだけではなく、イメージのダイジェストを指定する方がいい
    - 乗っ取られた場合に検知可能
  - Distroless イメージの使用
    - **アタックサーフェスを減らす！**
    - 静的リンクされたシングルバイナリになる Go, Rust とは抜群に相性がいい

## コンテナランタイムの運用

- ケーパビリティの制限
  - 不要なものの削除
- システムコールの制限
  - Seccomp
    - ファイルレスマルウェア？
    - Seccomp プロファイルの自動生成
      - strace, eBPF などで可能
      - docker-slim を使った生成方法
- docker-slim
  - コンテナイメージのサイズを圧縮するためのツール
  - **アプリケーションを動的解析して Seccomp プロファイルや AppArmor プロファイルを作成する機能もある**
  - k8s なら SPO とかも
    - https://kubernetes.io/blog/2023/05/18/seccomp-profiles-edge/
- リソースの制限
  - デフォルトでは何もかかってない
  - CPU, memory
    - k8s の request, limit でいい？
  - process 数
    - pids-limit at Docker
  - ストレージ使用量
    - storage-opt at Docker
- cpulimit, ulimit
  - cgroups v1 + Rootless モードの時は、リソース制限が適用できない
    - **cgroups 以外の仕組みでリソース制限**が必要
  - SIGSTOP, SIGCONT シグナルを常にプロセスに送ることで、使用量を制御する
    - ここを解除できる capability もあるよ！
      - CAP_SYS_RESOURCE, CAP_SYS_ADMIN
- ユーザー
  - User Namespace
    - ホストの UID/GID とは別に、ホスト側の一般ユーザーをコンテナの root に対応させたりできる
      - **root として動作することが求められるアプリケーションを安全に動かせる**
- Rootless モード
  - **Docker のランタイム自体も非 root で動かす！**
    - ランタイムに脆弱性があった倍位の被害軽減
- No New Privileges による権限昇格の防止
- Network
  - デフォルトでは全ての Pod が互いに通信することが可能
    - **コンテナに侵入された場合に横展開される**
  - Network Policy → 特定の Pod 同士のみが疎通可能にする
  - Istio → アプリ同士の認証
- Falco
- Sysdig
- **コンテナランタイム**
  - EKS の場合って、どうなってるんだろ

``` sh
curl http://169.254.169.254/latest/meta-data/iam/security-credentials
```

- コンテナの操作ログの記録
  - Docker API のアクセスログ
  - Docker events でコンテナの実行ログを取得

これよさそう！
https://github.com/docker/docker-bench-security

``` sh
git clone https://github.com/docker/docker-bench-security.git
cd docker-bench-security
sudo sh docker-bench-security.sh
```

## Links

- [OWASP: Docker Security Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Docker_Security_Cheat_Sheet.html)
- [OWASP: k8s security](https://cheatsheetseries.owasp.org/cheatsheets/Kubernetes_Security_Cheat_Sheet.html#assess-the-privileges-used-by-containers)
- [CIS Benchmark](https://www.cisecurity.org/cis-benchmarks)
