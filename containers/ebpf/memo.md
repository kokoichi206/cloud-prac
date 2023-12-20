- eBPF
  - クラウドネイティブの範囲を超えて、近年最も注目されている技術
  - [Parca](https://github.com/parca-dev/parca)
  - 十分に高度な技術は魔法と見分けがつかない。。。
    - どういうトリックなのかは知りたい！
- https://github.com/lizrice/learning-ebpf
- Windows 用の eBPF も開発中
- [oreilly online-learning](https://www.oreilly.com/online-learning/?utm_medium=search&utm_source=google.com&utm_campaign=B2B+Search&utm_content=live+demo&gad_source=1&gclid=CjwKCAiA-P-rBhBEEiwAQEXhH5NXs2ov7RQmtqNdvnAaDz-CCQIQOvh7W9EFmWLIYTw2a7MADAgaQxoCp4cQAvD_BwE)

## sec 1

- eBPF
  - **カーネルの振る舞いを変更できるカスタムコードを、カーネルの内部に動的にロード**し、実行可能！
  - 高性能ネットワーク、可観測性、セキュリティツール
- Berkeley Packet Filter
  - 元は BSD Packet Filter
    - のちに Berkeley Packet Filter になる
  - 1993 の論文
  - フィルタを動かせる擬似的な機械
    - プログラマが自分で描いたフィルタプログラムを**カーネルの中で実行できる**こと！
  - Linux には 1997 に導入！
    - 2.1.75 のカーネルバージョン
    - tcpdump ユーティリティ
  - カーネル v3.5
    - seccomp-bpf
  - **拡張されていくにつれ、『packet filter』という名前の意味は薄れていった。。。**
- BPF -> eBPF
  - extended BPF
  - カーネル v3.18 (2014) から
    - 64 ビットのマシンに最適化
    - eBPF Map
      - BPF のプログラムとユーザ空間のアプリケーションの両方からアクセス可能なデータ構造
    - bpf システムコール
      - ユーザ空間のプログラムとカーネル内部の eBPF が相互作用可能に
    - ヘルパ関数
    - eBPF 検証器
- kprobe (kernel probe)
  - 2005 ~
  - カーネル内のほとんどの命令に対して**フックを入れて追加の命令を実行可能に**
- eBPF と BPF はほぼ同義で使われている
- Linux カーネル
  - **アプリケーションとハードウェアの間に存在するソフトウェアのレイヤ**
  - ユーザ空間で動くアプリケーションからハードウェアへとシステムコールを介してリクエスト
- カーネルモジュール
  - **カーネルの振る舞いを変更したり拡張できる**
  - 一方、安全性の担保が難しい
- eBPF プログラムの動的ロード
  - **一度ロードされて JIT コンパイルされたら CPU 上のネイティブなマシン命令として実行される**
- クラウドネイティブ
  - k8s
    - ノード上のすべてのコンテナは同じカーネルの上で動作している
      - **カーネル上で eBPF を動かすとそのノード上すべてのコンテナについて影響させられる**
  - eBPF の動的ロード
    - アプリ側の改修・設定の変更が不要
    - カーネルにロードされてイベントに**アタッチしたらすぐに**観測開始！
  - **サイドカーモデルの欠点を解決！**

## sec 2

- [BCC: BPF Compiler Collection](https://github.com/iovisor/bcc)

``` sh
# not worked...
# pip3 install bcc
# pip3 install numba
apt install python3-bpfcc

$ python3 hello.py
bpf: Failed to load program: Operation not permitted

Traceback (most recent call last):
  File "hello.py", line 14, in <module>
    b.attach_kprobe(event=syscall, fn_name="hello")
  File "/usr/lib/python3/dist-packages/bcc/__init__.py", line 679, in attach_kprobe
    fn = self.load_func(fn_name, BPF.KPROBE)
  File "/usr/lib/python3/dist-packages/bcc/__init__.py", line 408, in load_func
    raise Exception("Need super-user privileges to run")
Exception: Need super-user privileges to run


$ sudo python3 hello.py

node-1854076 [003] d..3 959752.559641: 0: Hello World              sh-1854077 [002] d..3 959752.567826: 0: Hello World     cpuUsage.sh-1854078 [002] d..3 959752.588893: 0: Hello World     cpuUsage.sh-1854079 [000] d..3 959752.599838: 0: Hello World     cpuUsage.sh-1854080 [001] d..3 959752.604636: 0: Hello World     cpuUsage.sh-1854081 [003] d..3 959752.609435: 0: Hello World     cpuUsage.sh-1854082 [003] d..3 959752.614165: 0: Hello World     start_mysql-1854083 [003] d..3 959753.165679: 0: Hello World     cpuUsage.sh-1854084 [003] d..3 959753.620526: 0: Hello World     cpuUsage.sh-1854085 [003] d..3 959753.630123: 0: Hello World     cpuUsage.sh-1854087 [003] d..3 959753.638078: 0: Hello World     cpuUsage.sh-1854089 [000] d..3 959753.644629: 0: Hello World     start_mysql-1854091 [002] d..3 959754.173340: 0: Hello World ...
```

- ヘルパ関数
  - extended BPF とクラシックな BPF の違いの１つ
  - eBPF プログラムが Linux のシステムと相互作用をするための関数の集まり
- eBPF はなんらかの**イベントにアタッチ**させる必要がある！

``` sh
# bpf_trace_printk が出力を送る擬似ファイル先。
$ sudo ls -la /sys/kernel/debug/tracing/trace_pipe
-r--r--r-- 1 root root 0 Jan  1  1970 /sys/kernel/debug/tracing/trace_pipe

$ sudo cat /sys/kernel/debug/tracing/trace_pipe
```

- BPF Map
  - eBPF プログラムとユーザ空間の両方からアクセスできるデータ構造！
  - BPF (NOT eBPF) には存在しない機能！
  - 広義の key-value ストア
  - kernel v5.1 から排他制御のためのスピンロックなど
- ハッシュテーブル Map

``` sh
# BCC のマクロ。
BPF_HASH(counter_table);
```

- BCC から使える C 言語は、C そのものではない
  - C ににてるが、いくつかのショートカット・マクロを使えるようにしたもの
  - BCC が正しい C 言語に変換してコンパイルされる
- PERF リングバッファ Map
  - BPF リングバッファも新しくある
- **リングバッファ**
  - メモリの一部の領域を論理的な輪のように使う
  - 書き込みと読み出しのポインタが別々
  - 読み出しが書き込みに追いついたら、それ以上読み出せない
  - 書き込みが読み出しに追いついたら、**ドロップカウンタ**が増加する
- `bpf_get_current_pid_tgid`
  - ６４ビットの値を返す
    - 上位の 32 bit がプロセス ID を示す
    - 下位の 32 bit がスレッド ID を示す
- イベントが実行されたコンテクスト情報を eBPF から取得できる
- 関数呼び出し
  - コンパイラによりジャンプ命令になる
    - cf: 関数のインライン展開等
- **Tail Call**: 末尾呼び出し
  - 別の eBPF プログラムを呼び出して実行し、実行時のコンテクストを置き換える
    - execve システムコールが普通のプロセスに対してしていることと近い！
    - つまり！**Tail Call の実行が完了しても呼び出し元の eBPF プログラムには復帰しない！**
  - eBPF 固有の概念ではない
    - スタックオーバーフローを防ぐ
    - スタックが 512 バイトしかない eBPF においてはメリットが大きいってだけ

## Links

- https://github.com/lizrice/ebpf-beginners?tab=readme-ov-file
