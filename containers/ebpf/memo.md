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

## Links

- https://github.com/lizrice/ebpf-beginners?tab=readme-ov-file
