# 他のCADにあって AutoCAD にない機能（汎用2D）

調査日：2026-09-29　／　比較先：AutoCAD 2027（本体＋Express Tools。業種別ツールセットは含めない）

互換CAD（BricsCAD・IJCAD・ZWCAD・GstarCAD・DraftSight・ARES Commander）と、互換ではない2D CAD（Jw_cad・DRA-CAD・Vectorworks）の公式ヘルプ・マニュアル・カタログを調べ、**AutoCAD にない・弱い機能**を集めました。AutoLISP で再現したり、新しいコマンドを考えたりするための材料です。

- **対象**：どの分野でも使える2Dの機能（作図・編集・選択・文字・寸法・画層・ブロック・印刷・図面管理・入力の補助）。
- **対象外**：建具・壁・階段などの自動作図、3D、BIM、機械・土木の専用機能、クラウド。
- 見つかった **298件**（製品ごとの一覧は下の「元の調査」）を、同じ考え方の機能ごとに **88個のアイデア**にまとめました。LISP では難しいもの・専門的なものは最後に「除外」としてまとめています。
- 説明はすべて言い換えです（各製品の説明文はそのまま載せていません）。作るときも、考え方だけを参考にし、名前や説明文はまねしません。

> **点数について**：「参考点」は、使う前に外から見て付けた目安です（汎用性×2・時短×2＋AutoCADとの差＋世界の無料LISPの少なさ＋作りやすさ、21点満点）。「世界の無料LISP」は、`00_世界のAutoLISP総合一覧_採点.xlsx`（6,942件）を言葉で検索した**おおよその件数**で、関係のないものが混じったり、漏れたりしています。

## おすすめ10

| 順 | ID | アイデア | 理由 |
|---|---|---|---|
| 1 | I01 | 入力中に線の長さ・角度・図面の数字を拾う | 長さや角度を毎回測って打ち直す手間がなくなる。世界の無料LISPにもほとんどない。コマンドの途中で呼べる形にする |
| 2 | E01 | 包絡処理 | Jw_cad から移った人が一番困る機能。無料LISPは有料のものが少しあるだけ |
| 3 | E02 | 基準線まで一括伸縮 | 伸ばす線と縮める線を区別せず、1回で基準線にそろう。E01・E03 と一緒に「Jw風の線編集セット」にできる |
| 4 | I04 | 今の画層へ貼り付け（倍率・回転つき） | よく使う操作なのに AutoCAD になく、世界の無料LISPにも見当たらない。作りやすい |
| 5 | I02 | 属性取得（見本1クリックで画層・色・線種を今の設定に） | AutoCAD の LAYMCUR は画層だけ。色・線種・文字スタイルまで一度にそろう |
| 6 | N01 | 数字の文字の計算（合計・単価×数量など） | 数量表や拾いの確認で使える。似たLISPはあるが、Jw_cad の表計算のような「2つの列の掛け算」は少ない |
| 7 | S01 | つながった線を1クリックで選ぶ | AutoCAD にない選び方。ほかのコマンドの途中でも使えるようにすると便利 |
| 8 | C08 | 部分拡大図（範囲を切り取って倍率コピー） | 詳細図づくりの手間が減る。無料LISPは見当たらない |
| 9 | L01 | 画層の表示・非表示を入れ替える | 隠れている図形の確認がすぐできる。1コマンドで作れる |
| 10 | D02 | 寸法の結合・分割 | 並んだ寸法を通し寸法にまとめる／1本を2つに分ける。AutoCAD にない |

**次点**：T01 連番記入・P01 図枠の自動一括印刷・E03 2線の間を消す・C01 両側複線などは便利さでは上位ですが、世界の無料LISPにすでに多くあるため、作るなら「ほかにない一工夫」が要ります。D05（寸法の文字の重なり）は YokeruText で対応済みです。

## アイデア一覧（分類別）

「持っているCAD」は、その考え方の機能がある製品です。「LISP」は再現のしやすさ（可／簡易なら可／難しい）。

### 線の編集

| ID | アイデア | 持っているCAD | AutoCADとの差 | LISP | 世界の無料LISP | 参考点 |
|---|---|---|---|---|---|---|
| E01 | 包絡処理：範囲内で交わる線の角・T字・十字の余分をまとめて整える（Jw_cad 経験者が一番困る点。IJCAD も独自に搭載） | IJCAD・Jw_cad | ない（TRIM・FILLET を何度も） | 簡易なら可 | 5件 | 19 |
| E02 | 基準線まで一括伸縮：伸びる線も縮む線もまとめて基準線にそろえる（突出寸法・指示点まで）（伸ばす・縮めるを区別せずに1回で） | IJCAD・Jw_cad・Vectorworks | 一部（EXTEND と TRIM が別々、Shift 切替） | 可 | 10件 | 19 |
| E03 | 2本の基準線の間／四角の内側・外側をまとめて消す | Jw_cad・DRA-CAD | 一部（Express の EXTRIM は片側のみ） | 可 | 23件 | 18 |
| E04 | 交点でまとめて切る（すき間付き・またぎ表現・刃にした線で切る） | IJCAD・GstarCAD・ARES Commander・Vectorworks | ない（BREAKATPOINT は1点ずつ） | 可 | 20件 | 17 |
| E05 | 記号・ブロックを置くと下の線を自動で切る／隠す（アイデア集 T20 と同じ） | IJCAD・GstarCAD | ない（ワイプアウトを手で） | 可 | 14件 | 18 |
| E06 | 2本の線を角でつないで1本のポリラインに（Connect/Combine） | Vectorworks | 一部（FILLET 0 → JOIN の2手） | 可 | 0件 | 16 |
| E07 | なぞって次々トリム・延長（PowerTrim）（AutoCAD 2021 以降でかなり近い） | DraftSight・ARES Commander | 一部（TRIM のクイックモードでフェンス可） | 簡易なら可 | 2件 | 13 |
| E08 | 線で横切って切り分け（閉じた形も2つに）／描いた形で穴あけ・切り抜き | Vectorworks | ない | 簡易なら可 | 9件 | 15 |
| E09 | 閉じた形の足し算・引き算・外形線をポリラインで | BricsCAD・IJCAD・GstarCAD | 一部（REGION→UNION→ポリラインに戻す手間） | 簡易なら可 | 42件 | 13 |
| E10 | ポリラインの辺を直接操作（辺の平行移動・頂点のまとめ追加削除・円弧化） | BricsCAD・DRA-CAD・Vectorworks | 一部（多機能グリップ） | 可 | 19件 | 14 |
| E11 | 点の多い線を軽くする・ガタガタの線に合う直線/円弧を引く・ほぼ水平を水平に（PDF・GIS から取り込んだ図形向け） | BricsCAD・IJCAD・DRA-CAD・Vectorworks | ない | 簡易なら可 | 20件 | 12 |

### 平行線・分割・コピー

| ID | アイデア | 持っているCAD | AutoCADとの差 | LISP | 世界の無料LISP | 参考点 |
|---|---|---|---|---|---|---|
| C01 | 両側に平行線・留線付き（長方形）・端点指定・つながった線まとめて・複数距離を一度に | IJCAD・Jw_cad・DRA-CAD | 一部（OFFSET は片側1回ずつ） | 可 | 27件 | 18 |
| C02 | 中心線を一発：2線・2円・2点の間に、クリックした長さで | Jw_cad | 一部（CENTERLINE は2線のみ・線の長さで決まる） | 可 | 11件 | 17 |
| C03 | 2線の間の等分・割付・振分・角度分割・馬目地／2点間にピッチでコピー | Jw_cad・DRA-CAD・Vectorworks | ない（DIVIDE は1つの図形だけ） | 可 | 18件 | 17 |
| C04 | コピーの便利オプション（前回と同じ量で続ける・ピッチ/等分コピー・回転角を複数） | GstarCAD・Jw_cad | 一部（COPY の配列オプション） | 可 | 10件 | 15 |
| C05 | たくさんの図形を、それぞれの中心で反転・90度回転 | DRA-CAD・Vectorworks | ない（基点は1つ） | 可 | 9件 | 18 |
| C06 | 整列・等間隔に並べる（左揃え・中央揃え・分布。パワポの「配置」） | BricsCAD・IJCAD・GstarCAD・ARES Commander・DRA-CAD・Vectorworks | ない（ALIGN は別物） | 可 | 88件 | 17 |
| C07 | X・Y別の倍率・面積で指定・枠に合わせる拡大縮小 | IJCAD・GstarCAD・Vectorworks | ない（SCALE は縦横同じ） | 可 | 9件 | 14 |
| C08 | 部分拡大図：範囲で切り取って倍率を変えてコピー（枠で切る） | IJCAD・GstarCAD・Jw_cad | ない（ビューポートで代用） | 簡易なら可 | 0件 | 18 |
| C09 | ブロックを線の向きに合わせて挿入・図形をブロックに置き換え | BricsCAD・Vectorworks | 一部（Smart Blocks の配置候補） | 可 | 37件 | 14 |
| C10 | 四角の便利描き（寸法入力＋9点の基準位置・多重・傾き）・L面取り | GstarCAD・Jw_cad | 一部（RECTANG は角が基準） | 可 | 1件 | 14 |
| C11 | 線を寸法に変換・線端に矢印や点・片矢印線 | IJCAD・Jw_cad・Vectorworks | ない | 可 | 21件 | 13 |

### 入力補助

| ID | アイデア | 持っているCAD | AutoCADとの差 | LISP | 世界の無料LISP | 参考点 |
|---|---|---|---|---|---|---|
| I01 | 入力中に、既存の線の長さ・角度・図面の数値文字を拾って入れる（＋入力欄で計算） | BricsCAD・Jw_cad | 一部（'CAL、クイック計測） | 可 | 2件 | 20 |
| I02 | 見本の図形1クリックで、画層・色・線種を今の設定に（属性取得）＋設定セットの登録 | Jw_cad・DRA-CAD | 一部（LAYMCUR は画層だけ） | 可 | 4件 | 19 |
| I03 | コマンドごとに画層を自動で切り替える | IJCAD・GstarCAD・DraftSight | 一部（文字・寸法・引出線・ハッチ・表などは変数で可能。線などは不可） | 簡易なら可 | 2件 | 15 |
| I04 | 貼り付けを今の画層へ／倍率・回転を指定して貼る | DraftSight・ARES Commander・Jw_cad | ない | 可 | 0件 | 19 |
| I05 | 印刷しない仮点・補助線と、まとめて消去 | Jw_cad・DRA-CAD | 一部（Defpoints 画層で代用） | 可 | 3件 | 14 |
| I06 | 斜めの線を基準に直交・カーソルを回す | BricsCAD・IJCAD・GstarCAD・Jw_cad | 一部（UCS・SNAPANG） | 可 | 7件 | 13 |
| I07 | 線上の距離・割合の位置に点・スナップ | Jw_cad・Vectorworks | 一部（MEASURE・M2P） | 可 | 1件 | 14 |
| I08 | 2つの図形の間の距離を表示し、数値を打ち直して動かす | BricsCAD | 一部（クイック計測は表示だけ） | 簡易なら可 | 1件 | 15 |
| I10 | 写す項目を選べるプロパティコピー（組み合わせを名前付きで保存） | Vectorworks | 一部（MATCHPROP の設定は1組だけ） | 可 | 25件 | 14 |
| I09 | クリップボードの履歴から選んで貼る | DRA-CAD | ない | 簡易なら可 | 0件 | 12 |

### 選択

| ID | アイデア | 持っているCAD | AutoCADとの差 | LISP | 世界の無料LISP | 参考点 |
|---|---|---|---|---|---|---|
| S01 | つながった線を1クリックで全部選ぶ（連続線選択） | ZWCAD・Jw_cad | ない | 可 | 5件 | 18 |
| S02 | 範囲選択の切替（文字を含む/含まない・範囲の外・枠で切り取った内側） | Jw_cad | ない | 可 | 0件 | 17 |
| S03 | 選択を反転（選んでいないものを選ぶ） | DRA-CAD・Vectorworks | ない | 可 | 5件 | 14 |
| S04 | 閉じたポリラインの中にあるものを選ぶ | DRA-CAD | 一部（WP で頂点をなぞる） | 可 | 4件 | 17 |
| S05 | 選んだ図形の組を記憶して呼び出す | Jw_cad | 一部（GROUP） | 可 | 4件 | 13 |
| S06 | 条件で選ぶ（範囲内で同じ画層・ブロック・色、比べる項目を選べる似たもの選択、条件の保存） | BricsCAD・ZWCAD・GstarCAD・Vectorworks | 一部（QSELECT・FILTER・SELECTSIMILAR） | 可 | 11件 | 17 |

### 文字

| ID | アイデア | 持っているCAD | AutoCADとの差 | LISP | 世界の無料LISP | 参考点 |
|---|---|---|---|---|---|---|
| T01 | 番号を増やしながら書く・コピー、クリックで数字を1つ増減（アイデア集 T15） | IJCAD・Jw_cad・DRA-CAD | ない（Express の TCOUNT は既存の文字に付番） | 可 | 110件 | 19 |
| T02 | 文字をつなぐ・切る・中身を入れ替える | IJCAD・GstarCAD・Jw_cad・DRA-CAD | 一部（TXT2MTXT はマルチテキストになる） | 可 | 39件 | 16 |
| T03 | 全角⇔半角の一括変換 | Jw_cad・DRA-CAD | ない（TCASE は大文字小文字だけ） | 可 | 0件 | 17 |
| T04 | 前後に付け足す・置換リストで一括置換・中の数字を一斉に計算（＋100 など） | DRA-CAD | 一部（FIND は1組ずつ） | 可 | 74件 | 16 |
| T05 | 複数の文字を一覧で書き換え・続けて編集・見本から内容や位置を写す・高さ等をまとめて変更 | BricsCAD・IJCAD・DRA-CAD | 一部（プロパティで共通値のみ） | 可 | 23件 | 16 |
| T06 | 文字の均等割付・行間と文字数で並べ直す | Jw_cad | 一部（TEXTALIGN は位置だけ） | 可 | 5件 | 15 |
| T07 | テキストファイルの各行を、行間を決めて1行ずつの文字で置く | IJCAD・Jw_cad | 一部（マルチテキストの読み込み） | 可 | 1件 | 14 |
| T08 | 線・円弧・ポリラインに沿って文字（等間隔・割付）（アイデア集 T22） | IJCAD・DRA-CAD・Vectorworks | 一部（ARCTEXT は円弧だけ） | 可 | 23件 | 12 |
| T09 | よく使う文言の登録・呼び出し（注記辞書・キーノート凡例） | GstarCAD・Vectorworks | 一部（ツールパレット） | 可 | 3件 | 16 |

### 数字・集計

| ID | アイデア | 持っているCAD | AutoCADとの差 | LISP | 世界の無料LISP | 参考点 |
|---|---|---|---|---|---|---|
| N01 | 数字の文字の合計・平均・個数・四則演算（単価×数量など）を図面に書く | IJCAD・Jw_cad・DRA-CAD | ない | 可 | 65件 | 19 |
| N02 | 図形の長さ・面積・個数を種類別（画層・ブロック・色）に集計（アイデア集 T16） | IJCAD・ZWCAD・Jw_cad・DRA-CAD・Vectorworks | 一部（COUNT はブロックの数、クイック計測） | 可 | 82件 | 16 |
| N03 | 長さ・面積・勾配・距離・座標を文字で書き込む（測定結果書込）（アイデア集 T13） | IJCAD・GstarCAD・Jw_cad・DRA-CAD・Vectorworks | 一部（フィールドを手で） | 可 | 145件 | 16 |
| N04 | 面積表（番号付き・三斜求積・追従） | IJCAD・ZWCAD・GstarCAD・ARES Commander・Jw_cad・DRA-CAD | ない | 簡易なら可 | 20件 | 14 |
| N05 | 座標の書き出し・座標から作図（アイデア集 T27） | GstarCAD・Jw_cad・DRA-CAD | ない | 可 | 43件 | 13 |

### 寸法

| ID | アイデア | 持っているCAD | AutoCADとの差 | LISP | 世界の無料LISP | 参考点 |
|---|---|---|---|---|---|---|
| D01 | 手で書き換えた寸法値に印を付ける（アイデア集 T07） | BricsCAD | ない | 可 | 16件 | 17 |
| D02 | 並んだ寸法を1本にまとめる／1本を2つに分ける／隣に次の寸法を足す | ZWCAD・DRA-CAD・Vectorworks | ない | 可 | 7件 | 18 |
| D03 | 線と交わる所すべてに連続寸法を一度に／数値を並べて連続寸法 | DraftSight・Jw_cad | 一部（QDIM は選んだ図形の端点） | 可 | 55件 | 18 |
| D04 | 累進寸法（基点からの累計を1本の寸法線に） | Jw_cad | 一部（座標寸法） | 簡易なら可 | 1件 | 13 |
| D05 | 寸法の文字の重なりをずらす・寸法を並べ直す（YokeruText で対応済み） | ZWCAD・DraftSight | 一部（DIMSPACE） | 可 | 5件 | 15 |
| D06 | 寸法の矢印をまとめて反転・見本の寸法スタイルに合わせる | IJCAD・ARES Commander | 一部（矢印の反転は1つずつ） | 可 | 2件 | 14 |
| D07 | マルチ引出線の文字を線や円に沿って並べる | BricsCAD | 一部（MLEADERALIGN は直線上） | 可 | 3件 | 12 |

### 画層・表示順

| ID | アイデア | 持っているCAD | AutoCADとの差 | LISP | 世界の無料LISP | 参考点 |
|---|---|---|---|---|---|---|
| L01 | 表示中と非表示の画層を入れ替える（ロックも） | Jw_cad・DRA-CAD | ない | 可 | 5件 | 18 |
| L02 | 画層の順番で表示順（前後）をそろえる | BricsCAD・GstarCAD | ない | 可 | 3件 | 17 |
| L03 | 画層などの名前を一括変更（前後に付ける・連番・プレビュー） | Vectorworks | 一部（RENAME のワイルドカード） | 可 | 11件 | 15 |
| L04 | 外部参照・画像・PDF をまとめて背面へ | ARES Commander | 一部（DRAWORDER を1つずつ） | 可 | 1件 | 14 |
| L05 | 条件で一時的に色分け表示（元の設定は変えない） | Vectorworks | ない | 簡易なら可 | 0件 | 14 |

### ブロック

| ID | アイデア | 持っているCAD | AutoCADとの差 | LISP | 世界の無料LISP | 参考点 |
|---|---|---|---|---|---|---|
| B01 | ブロックを開かずに、中身の色・画層・文字高さ・線幅をまとめて変える | IJCAD・GstarCAD | 一部（SETBYLAYER・REFEDIT） | 可 | 29件 | 16 |
| B02 | ブロックの基点を、図形を動かさずに変える | GstarCAD・ARES Commander | ない（ブロックエディタで BASE、位置がずれる） | 可 | 18件 | 17 |
| B03 | ブロックをそれぞれの挿入点で一括スケール | ARES Commander | ない | 可 | 7件 | 14 |
| B04 | 属性に連番を振る・振り直す（アイデア集 T15） | IJCAD・GstarCAD | ない | 可 | 20件 | 15 |
| B05 | 同じ形の線のまとまりをブロック化・並んだものを配列にまとめる（AutoCAD に入ったので優先度低） | BricsCAD | 一部（AutoCAD 2025 の Smart Blocks：検索して変換） | 簡易なら可 | 3件 | 13 |
| B06 | 図形からハッチパターンを作る | DraftSight | ない | 可 | 7件 | 12 |

### 印刷・レイアウト

| ID | アイデア | 持っているCAD | AutoCADとの差 | LISP | 世界の無料LISP | 参考点 |
|---|---|---|---|---|---|---|
| P01 | モデル空間の図枠を自動で見つけて一括印刷・PDF（アイデア集 T04（世界に多数）） | ZWCAD・GstarCAD | ない（PUBLISH はレイアウト単位） | 可 | 38件 | 19 |
| P02 | 範囲と縮尺からビューポートを自動作成（アイデア集 T05） | IJCAD・GstarCAD | ない | 可 | 12件 | 18 |
| P03 | レイアウトの一覧管理（まとめて複製・削除・並べ替え・名前） | BricsCAD | 一部（タブの右クリック） | 可 | 30件 | 12 |
| P04 | 印刷範囲（図枠）ごとに別の図面ファイルに分けて保存 | DRA-CAD | ない | 簡易なら可 | 3件 | 16 |
| P05 | 複数の図面を1枚に並べる（大判に自動割付） | ZWCAD・GstarCAD | ない | 簡易なら可 | 0件 | 14 |
| P06 | 別の図面のレイアウトの中身を取り込む | BricsCAD | 一部（レイアウトの読み込み） | 簡易なら可 | 0件 | 11 |

### 図面管理・検図

| ID | アイデア | 持っているCAD | AutoCADとの差 | LISP | 世界の無料LISP | 参考点 |
|---|---|---|---|---|---|---|
| M01 | 図面の健康診断をまとめて（手順セットを保存）・遠くに飛んだ図形を探す（アイデア集 T10） | BricsCAD | 一部（PURGE・AUDIT が別々） | 可 | 2件 | 18 |
| M02 | 複数の図面を開かずにまとめて名前削除（アイデア集 T02） | GstarCAD | ない | 簡易なら可 | 11件 | 15 |
| M03 | 同じ図面の中の2か所を比べて違いを色で示す（アイデア集 T09） | IJCAD | 一部（DWG比較はファイルどうし） | 簡易なら可 | 15件 | 14 |
| M04 | 指摘メモ（赤い吹き出し）・雲マークに改訂番号を持たせる | ZWCAD・ARES Commander・Vectorworks | 一部（REVCLOUD・トレース） | 可 | 16件 | 12 |
| M05 | 図形をロックして編集させない | IJCAD・ZWCAD・GstarCAD | ない | 簡易なら可 | 8件 | 11 |
| M06 | 図面の単位を変えて図形・文字・寸法を換算 | GstarCAD | 一部（INSUNITS と SCALE を手で） | 可 | 14件 | 11 |
| M07 | 線で描いた表の編集・Excel への書き出し（アイデア集 T23） | IJCAD・GstarCAD・DraftSight | 一部（表オブジェクトなら書き出し可） | 簡易なら可 | 37件 | 13 |
| M08 | 凡例（使っている記号・ハッチ・線種）を自動作成（アイデア集 T17） | Vectorworks | ない | 可 | 8件 | 14 |
| M09 | 前にした文字の修正を覚えておき、別の図面の同じ文字を知らせる | DRA-CAD | ない | 簡易なら可 | 0件 | 14 |
| M10 | 印刷したときと同じ大きさで画面に表示（実寸表示） | DRA-CAD | ない | 簡易なら可 | 0件 | 12 |
| M11 | QRコード・バーコードを図面に入れる | BricsCAD・ZWCAD・GstarCAD・DRA-CAD | ない | 難しい | 9件 | 9 |
| M12 | 画層・ブロック・スタイルなどを1つの画面でまとめて管理 | BricsCAD・DraftSight | 一部（各管理画面が別々） | 簡易なら可 | 0件 | 11 |

## 除外したもの

- **LISPでは難しい（画面・マウス操作）**：Quad（BricsCAD）、Rollover Tips（BricsCAD）、Hotkey Assistant（BricsCAD）、Adaptive Grid Snap ＋ Nudge（BricsCAD）、ルーペパレット（DRA-CAD／Vectorworks）、MAGNIFIER（GstarCAD）、Mouse Gestures（DraftSight）、Move with Arrow Keys（ARES Commander）、Head-up Display Toolbar（ARES Commander）、Mouse Gestures（ARES Commander）、EnterPoint（ARES Commander）、Dynamic Print Preview（ARES Commander）、Undo Snapshot（ZWCAD）、SMARTMOUSE（ZWCAD）、クロックメニュー（Jw_cad）、レイヤ一覧（Jw_cad）、連動表示（DRA-CAD）
- **LISPでは難しい（そのほか）**：COPYGUIDED（BricsCAD）、MOVEGUIDED（BricsCAD）、UNDOENT（BricsCAD）、HATCHEDITEXT（BricsCAD）、PARAMETRIZE2D（BricsCAD）、VOICEMANAGER（GstarCAD）、ImageTracer（DraftSight）、Dimension Palette（DraftSight）、Dimension Location Snap（ARES Commander）、Smart Match（ZWCAD）、Similar Search（ZWCAD）、SMARTVOICE／VOICEMAN（ZWCAD）、Sizedrive（ZWCAD）、JWW 読み込み・書き出し（IJCAD）、JWW 読み込み（ZWCAD）、レイヤの3状態（Jw_cad）、縮尺の異なるレイヤグループ（Jw_cad）、串刺し編集（DRA-CAD）、Classes（Vectorworks）、Create Class using Object Attributes／Update Class Attributes from Object（Vectorworks）
- **専門的・自動作図・その他（汎用性が低い）**：線分の円弧化（DRA-CAD）、さざなみ線変換（DRA-CAD）、矩形割付（DRA-CAD）、長穴（DRA-CAD）、Stipple ツール（Vectorworks）、Symmetric Draw（GstarCAD）、ZC／SALPL（GstarCAD）、曲線［サイン曲線］［2次曲線］（Jw_cad）、線記号変形（Jw_cad）、外部変形「通り芯自動作図」（Jw_cad）、COPYEDATA / MOVEEDATA / DELEDATA / EDITEDATA（BricsCAD）、SAVEFILEFOLDER / SUPPORTFOLDER / TEMPLATEFOLDER（BricsCAD）、SCREENSHOT（BricsCAD）、LispExplorer（ARES Commander）、IJTANCIR3ENT／TANCIR3ENT（IJCAD）、IJTANCIR2ENT（IJCAD）、SETTINGS / SETTINGSSEARCH（BricsCAD）、MMTEXT（IJCAD）、IJLAYLIST（IJCAD）、Find パネル化（ZWCAD）
- **図枠・シート管理（アイデア集 T06 と同じ）**：Drawing Label（Vectorworks）、Title Block Manager（Vectorworks）
- **複数図面への一括処理（アイデア集 T03 と同じ）**：SCRIPTGENERATOR（IJCAD）

各製品の調査で「AutoCAD にもあるので除外」としたものは、下の元の調査ファイルの末尾にまとめています。

## 元の調査（製品ごと・出典URLつき）

| ファイル | 件数 |
|---|---|
| [01_BricsCAD.md](01_BricsCAD.md) | 39 |
| [02_IJCAD・ZWCAD.md](02_IJCAD・ZWCAD.md) | 66 |
| [03_GstarCAD・DraftSight・ARES.md](03_GstarCAD・DraftSight・ARES.md) | 65 |
| [04_Jw_cad.md](04_Jw_cad.md) | 61 |
| [05_DRA-CAD・Vectorworks.md](05_DRA-CAD・Vectorworks.md) | 67 |

表計算用：[00_他CADにあってAutoCADにない機能_採点.xlsx](00_他CADにあってAutoCADにない機能_採点.xlsx)（アイデア別・元の298件・世界の無料LISPとの照合）

## 調べ方の注意

- IJCAD の独自機能は公式の「PLUS ツール・拡張ツール 使い方一覧」（2022年版）とカタログ（2026）が中心で、その後に増減したものがあるかもしれません。
- ZWCAD 2026・Vectorworks 2026 の新機能は、公式の短い説明しか確かめられていないものがあります。ARES Commander は同じ土台の ARES Mechanical 2027 のヘルプで確かめました。
- 「AutoCADとの差」は調査時点の見立てです。作る前に AutoCAD 2027 で本当にないか、もう一度確かめます。
