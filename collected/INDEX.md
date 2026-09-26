# 収集したAutoLISPファイルの索引

**再配布が許可されていることを確認できたもの**だけを集めています。AutoLISP関連ファイル（.lsp / .lisp / .dcl / .scr / .mnl / .mnu）が合計 **1,936個** あります。

- 第1部: GitHubのリポジトリ（MIT / GPL-3.0）… 24リポジトリ、557ファイル
- 第2部: Webサイト・その他（利用規約やファイル冒頭で再配布許可を確認）… 9か所、1,379ファイル＋書庫1個
- 取得日: 2026-09-26

## 第2部: Webサイト等から収録したもの

| フォルダ | 許可の種類 | ファイル数 | 内容 | 分野 |
|---|---|---|---|---|
| atlisp-org__atlisp-lib | MIT | 860 | 中国の @lisp 関数ライブラリ（文字列・リスト・図形・ブロック・ファイル操作など）。LISPを自作する人向け | |
| web__draftsperson-net | ファイルごとの許可文（大半は「無償・著作権表示を残せば配布可」） | 233 | 1990年代の定番フリーLISP。Autodesk社のBonusツール（BURST、TXTEXP、EXTRIM、MPEDIT、REVCLOUD、TEXTMASK等）、壁作図DTWALL、家具・キャビネット・垂木・トラス作図、3D、文字編集、RockLisp一式など | 🏢 建築 |
| kruuger__CADPL-Pack-v1 | GPL | 143 | ポーランドの関数ライブラリ（ブロック・選択・辞書・DCLなど） | |
| web__autolisp-ru | サイトが「自由に配布可」と明記 | 122 | ロシアの kpblc 氏の作品（属性の書き出し・読み込み、パージ、ワイプアウト削除、動的ブロック操作、画層作成など） | |
| web__gilesdarling | 「複製・改変可」 | 5 | 英国の道路設計向け（測点、ポリライン向き反転、縦断曲線など） | |
| web__cadforum | 許可文 / GPL | 3 | 点の読込（ASCPOINT）、線をギザギザに（ROUGHEN）、歯車作図（TRUEGEAR） | |
| web__manusoft | 「自由に改変・配布可」 | 2 | DWGのバージョン判定、64bit判定 | |
| web__paracadd | 許可文 | 2 | 全分解（MXPLODE）、図面状態表示（XSTATUS） | |
| web__vector-LISPで描こう | 「未改変の書庫なら転載自由」 | 書庫1個 | 日本の「LISPで描こう!!」一式（ボルト・アンカー等の部品作図）。書庫のまま収録 | |

各フォルダの `SOURCE.txt` に、取得元と許可の根拠（原文）を記録しています。

**ご注意（第2部）**
- 「改変禁止」を条件に許可されているファイルがあります。**このリポジトリ内のファイルは書き換えないでください。** 改造したい場合は、コピーを別の場所に作ってください。
- 1990年代のものは古いAutoCAD向けで、今のAutoCADでは動かない場合があります。

---

# 第1部: GitHubのリポジトリ

- 収録: 24リポジトリ、計557ファイル
- 各フォルダの `SOURCE.txt` に取得元URL・取得時点のコミット・ライセンスを記録しています。
- 各フォルダには元の `LICENSE`（ライセンス文）と `README` もそのまま入れています。**使う・配る際はライセンス文を消さないでください。**
- 🏢 = 建築・設備・図面管理に関係するもの

## ご注意

- **動作確認はしていません。** AutoCADで使う前に、必ずテスト用の図面で試してください。
- **GPL-3.0 のもの**は、改変して配布する場合、改変後のソースも同じ GPL-3.0 で公開する必要があります。社内だけで使う分には問題ありません。
- 他の作者（Lee Mac 氏など）のコードが混ざっているファイルは、ライセンスが異なるため**除外**しました（下の「除外したファイル」参照）。そのため、一部のツールは部品が欠けて動かない可能性があります。
- `adalkondan__AutoCAD-LISP-files` は1990年代のインドの設計会社で作られたらしい古いツール群で、作者名（basu、Murali など）とアップロード者が異なります。アップロード者がMITライセンスを付けていますが、出所が完全には確認できないため、社外への再配布は慎重にしてください。

## 一覧

| フォルダ | ライセンス | ファイル数 | 内容 | 分野 |
|---|---|---|---|---|
| dtgoitia__civil-autolisp | MIT | 150 | 土木向けツール集（排水管・マンホール表・レベル・座標・画層管理など）。`Dump folder` に多数の小ツール | 🏢 排水 |
| manualChair__commonlib | MIT | 210 | 日本の作者による関数ライブラリ（Common Lisp風の便利関数）。LISPを自作する人向けの部品集 | |
| adalkondan__AutoCAD-LISP-files | MIT | 56 | 鋼材（インド規格I形鋼・チャンネル・アングル）、ボルト・ナット、ベースプレート、連番、文字編集など | 🏢 鉄骨 |
| mf4633__C3D-AutoCAD | MIT | 31 | 小さなコマンド集（方位記入、面積・長さ合計、勾配ラベル、全レイアウトPDF化など） | |
| caadxyz__caad4lisp | MIT | 20 | 建築設計用ツール（壁・開口・通り芯・建築寸法）とライブラリ。BricsCAD/IntelliCADにも対応 | 🏢 建築 |
| vjspab__autocad-lisp-toolkit | MIT | 17 | 区画割り・区画寸法・CSV出力など敷地計画向け | 🏢 配置計画 |
| dentonyoder__LISP | GPL-3.0 | 11 | 作図自動化ツール（矢印、アイソメ図作成、3Dポリラインなど） | |
| A-Nony-Mus__Autolisp-Utilities | GPL-3.0 | 10 | 自作の便利コマンド集 | |
| XIIIMICT__AutoLISP-models | MIT | 10 | 3Dソリッド作成の例（大学課題） | |
| ankaibua-spec__autolisp-civil-tools | GPL-3.0 | 9 | 土木・測量ツール（AutoCAD/BricsCAD） | |
| jacobdein__AutoLISP | MIT | 8 | ポリラインの長さ・面積、結合など | |
| LetsBIMtogether__AutoLisp | MIT | 7 | 建築設計者向け：室寸法・扉寸法の自動記入、AIA/NCS標準画層（1,453画層）作成、文字背景マスク、タグ検索 | 🏢 建築 |
| ddddo86__AutoLSP | MIT | 7 | 各種便利コマンド（ベトナム系） | |
| ivashinpavel07__AutoCAD-AutoLISP-MLeaderSmartAlign | MIT | 3 | マルチ引出線をきれいに整列 | |
| juninholiveira__yoprint | MIT | 3 | 一括PDF印刷 | 🏢 図面管理 |
| gizmon__gz_msgbox | MIT | 3 | 日本の作者（GizmoLabs）によるメッセージボックス表示用の部品 | |
| FranGarcia94__Copy-bounded-area-AutoCAD | GPL-3.0 | 2 | 多角形で囲んだ範囲だけをコピー | |
| fauzanalfi__cad-lsp-library | MIT | 2 | 文字の一括コピー、外部参照のバインド＋全分解 | 🏢 図面管理 |
| jasonacox__AutoLispCogo | MIT | 2 | 座標計算（COGO）関数 | |
| debear81__lispCGtools | MIT | 1 | 断面性能・重心計算（※主要ファイルはLee Mac氏のコードを含むため除外。単体では動かない可能性大） | |
| drzkid96__xrl-xref-reload | MIT | 1 | 外部参照の再読込 | 🏢 図面管理 |
| SkeletonTM__FrameFinder | MIT | 1 | 図枠を自動検出して印刷・レイアウト作成（ロシアGOST図枠） | 🏢 図面管理 |
| eva-molina__WallForge | MIT | 1 | データから壁の平面図を自動作図 | 🏢 建築 |
| zackad-vault__autolisp | MIT | 1 | 各種スクリプト | |

## 除外したファイル

### 他の作者のコードを含むため（ライセンスが異なる／不明）

| ファイル | 理由 |
|---|---|
| dtgoitia/civil-autolisp/0 - Function library.lsp | Lee Mac氏・gile氏のコードを含む |
| dtgoitia/civil-autolisp/Dump folder/0 - Function library.lsp | 同上 |
| dtgoitia/civil-autolisp/Dump folder/LmListManipulation.lsp | Lee Mac氏のコード |
| dtgoitia/civil-autolisp/Dump folder/variantListLibrary.lsp | gile氏のコード |
| dtgoitia/civil-autolisp/Dump folder/downloaded/ 内の2ファイル | 他サイトからのダウンロード品 |
| dtgoitia/civil-autolisp/Dump folder/3dOffset.lsp | Gian Paolo Cattaneo氏作 |
| dtgoitia/civil-autolisp/Dump folder/CopyBlock.lsp | Tony Tanzillo氏作 |
| dtgoitia/civil-autolisp/Dump folder/ColourConversion.lsp | Autodeskフォーラム投稿者作 |
| dtgoitia/civil-autolisp/Dump folder/PLDIET.lsp | Cadalyst掲載の他者コードを含む |
| dtgoitia/civil-autolisp/Dump folder/Ploting.lsp ほか4件（ReadingASCIIFilesWithAutoLisp / IndexToTrueColor / Deployment / ControlMenus） | 外部フォーラム・サイトからの引用を含む |
| adalkondan/AutoCAD-LISP-files/CHELEV.LSP, COUNT.LSP | Tony Tanzillo氏作（All Rights Reserved） |
| adalkondan/AutoCAD-LISP-files/VSCALE.LSP | Autodesk社の著作物 |
| adalkondan/AutoCAD-LISP-files/etext.lsp | Prasad Chodankar氏作（Cadalyst Tip） |
| A-Nony-Mus/Autolisp-Utilities/neat.lsp | Lee Mac氏のコードを含む |
| debear81/lispCGtools/source/CG_2D.lsp, CG_3D.lsp, CG_helpers.lsp | Lee Mac氏のコードを含む／依存 |
| thelegendofbrian/C3D-Utils/src/archive-on-save.lsp | Lee Mac氏のコードを含む（このリポジトリは収録ゼロのため丸ごと除外） |

### 暗号化されていて中身を確認できないため

adalkondan/AutoCAD-LISP-files の ACAD.lsp、AUTOPATH.LSP、LENGTH.LSP、Multiply.lsp、SETUPA.LSP、SETUPE.lsp、SETUPP.LSP、SETUPP-old.lsp、VCT.LSP、vctt.lsp（計10件）
