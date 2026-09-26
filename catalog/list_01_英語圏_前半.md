# 世界のAutoLISP一覧 ① 英語圏・前半

調査日: 2026-09-26　収録: **696件**

対象サイト: Lee Mac Programming（229）、draftsperson.net（139）、JefferyPSanders.com（89）、JTB World（79）、CAD Authority（71）、AutoLISP Exchange（40）、gilesdarling.me.uk（31）、ManuSoft（18）

- 「コマンド」欄はAutoCADで入力する名前です（「-」はサイトに記載なし）。
- 説明は「何のためのツールか」だけの一言です。詳しく知りたいものがあれば聞いてください。
- 使う場合は各リンク先から入手してください（再配布不可のサイトが多いため、ファイル本体はここにはありません）。
- CAD Corner は draftsperson.net と同じ内容だったため省略。AutoLISPcourse.com は実在するファイルか確認できないもの（アイデアの題名だけの可能性）が大半だったため除外しました。

## 開発のヒントになりそうなもの（ピックアップ）

| アイデア | 例 | ヒント |
|---|---|---|
| **複数図面を開かずに一括処理** | BFind（文字置換）、BAttE（属性編集）、Copy to Drawings、Steal | 「1図面ずつ開いて同じ作業」を丸ごと無くす系。社内の定型修正に効く |
| **図形と連動して自動更新する表示** | Areas to Field、Length Field、midlen、utb（図枠属性の自動更新） | 面積・長さを「フィールド」で書くと、図形を直しても数値が勝手に追従する |
| **コマンドに応じて画層を自動切替** | Layer Director（LDON） | 「寸法を描くと寸法画層に」など、画層の切り替え忘れを無くす |
| **ブロック挿入時に下の線を自動で切る** | Automatic Block Break（ABB） | 配管・配線上にバルブや器具記号を置く設備図で特に便利 |
| **連番の自動記入** | NumInc、incarray、TCount | 室番号・建具番号・器具番号など。接頭辞・桁数・増分の設定がポイント |
| **集計して表にする** | blkcount（ブロック数を表に）、cav（属性値の出現数）、attsum（属性値の合計） | 器具数・建具数の拾い出しを図面から直接行う |
| **Excelとの往復** | DrawExcel、CAD2FILE、CSVTable、ATTEXP / XLS2TBL | 図面の情報をExcelへ、Excelの表を図面へ |
| **建築要素のパラメトリック作図** | DTWALL（壁）、CGRID（部屋中心の天井割付）、Stair Calculator、キャビネット・垂木・トラス | 寸法を入れるだけで決まった形を描く。日本の建具・天井割付に置き換えると有望 |
| **設備の二重線化・展開図** | L2PIPE（線→二重線配管）、HVAC Suite、LITIO（ダクト展開図）、PipeLay | 単線で描いてから二重線・展開図に変換する発想 |
| **図面の健全化を自動で** | AAUDIT（監査＋パージ＋全体表示）、PURGEH、Purge-Point | 提出前の「お掃除」を1コマンドにまとめる |

## 目次

- [文字・テキスト（81件）](#01文字)
- [寸法（11件）](#02寸法)
- [引出線・注記（14件）](#03引出線注記)
- [ブロック・属性（61件）](#04ブロック属性)
- [画層（レイヤー）（32件）](#05画層)
- [線・ポリラインの編集（61件）](#06線ポリライン編集)
- [作図（図形を描く）（29件）](#07作図図形生成)
- [ハッチ・面積・長さの集計（29件）](#08ハッチ面積長さ集計)
- [選択・絞り込み（6件）](#09選択フィルタ)
- [表・Excel・CSV連携（17件）](#10表Excel連携)
- [印刷・レイアウト・図枠（27件）](#11印刷レイアウト図枠)
- [外部参照・図面管理・一括処理（28件）](#12外部参照図面管理一括処理)
- [座標・測量・土木（51件）](#13座標測量土木)
- [建築（27件）](#14建築)
- [設備（空調・衛生・電気・配管）（4件）](#15設備)
- [構造・鉄骨・機械（22件）](#16構造鉄骨機械)
- [3D（7件）](#17_3D)
- [表示・UCS・ビュー（5件）](#18表示UCSビュー)
- [設定・環境（19件）](#19設定環境)
- [LISP開発用の部品（関数ライブラリ）（119件）](#20開発ライブラリ)
- [その他（ゲーム・計算・便利小物）（46件）](#21その他)

<a id="01文字"></a>
## 文字・テキスト（81件）

| コマンド | 名前 | 何をするツールか | 作者・サイト |
|---|---|---|---|
| FindReplace / FR | FindReplace | 開いた全図面の文字を検索置換 | [AutoLISP Exchange](https://autolisp-exchange.com/LISP/FindReplace.lsp)（Terry Miller） |
| Text-Box / TB | Text-Box | 文字を囲む矩形を作図 | [AutoLISP Exchange](https://autolisp-exchange.com/LISP/Text-Box.lsp)（Terry Miller） |
| TM | TM | 文字・属性・寸法値をコピー一致 | [AutoLISP Exchange](https://autolisp-exchange.com/LISP/TM.lsp)（Terry Miller） |
| CURVETXT | CurveText.lsp | 円弧・円に沿って文字配置 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| INCNUM | IncrementalNumbering.lsp | クリックで連番・連字を記入 | [CAD Authority](https://cadauthority.com/download/autocad/autocad-incremental-numbering-lisp-incnum/)（CADAuthority） |
| MTCLEAN | MTextClean.lsp | MTEXTの書式上書きを除去 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| TXTALIGN | TextAlignment.lsp | 文字を基準に整列 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| TCASE | TextCaseSwitcher.lsp | 文字の大文字小文字を切替 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| TXTFIT | TextFitToWidth.lsp | 文字を2点間幅に合わせる | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| T2M | TextToMtext.lsp | 複数文字をMTEXTに統合 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| TXT | mstxt.lsp | 複数種の文字を順に編集 | [JTB World](https://jtbworld.com/?view=article&id=219:autocad-mstxt-lsp&catid=2)（JTB World (Jimmy Bergmark)） |
| PM | PersonalMtextSymbols.lsp | MTEXT右クリックに記号追加 | [JTB World](https://jtbworld.com/autocad-personalmtextsymbols-lsp)（JTB World (Jimmy Bergmark)） |
| txp | Text on circle/spline | 円・スプライン沿いに文字記入 | [JTB World](https://jtbworld.com/justlisp)（Mark Beggs） |
| tx | Text Precedence | 文字の下の図形を切り抜き記入 | [JTB World](https://jtbworld.com/justlisp)（Mark Beggs） |
| - | TextFunctions.lsp | 文字スタイルを一括変更 | [JTB World](https://jtbworld.com/autocad-textfunctions-lsp)（JTB World (Jimmy Bergmark)） |
| th | TextHeight.lsp | 基点を保ち文字高さ変更 | [JTB World](https://jtbworld.com/autocad-textheight-lsp)（JTB World (Jimmy Bergmark)） |
| TSH0 | tsh0.lsp | 全文字スタイル高さを0に | [JTB World](https://jtbworld.com/autocad-tsh0-lsp)（JTB World (Jimmy Bergmark)） |
| txtrot | txtRot.lsp | 文字を指定角度に回転 | [JTB World](https://jtbworld.com/autocad-txtrot-lsp)（JTB World (Jimmy Bergmark)） |
| AU | Au | 文字に下線コードを付加 | [JefferyPSanders.com](https://jefferypsanders.com/AU.LSP)（Jeffery P. Sanders） |
| CASE | CASE | 文字の大文字小文字を変換 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_CASE.html)（Jeffery P. Sanders） |
| CASE | Case (reverse) | 文字の大文字小文字を反転 | [JefferyPSanders.com](https://jefferypsanders.com/CASE.LSP)（Jeffery P. Sanders） |
| CHTXHT | ChTxHt | 文字高さを変更 | [JefferyPSanders.com](https://jefferypsanders.com/CHTXHT.LSP)（Jeffery P. Sanders） |
| CHTXLY | ChTxLy | 文字の画層を変更 | [JefferyPSanders.com](https://jefferypsanders.com/CHTXLY.LSP)（Jeffery P. Sanders） |
| CHTXRT | ChTxRt | 文字の回転角を変更 | [JefferyPSanders.com](https://jefferypsanders.com/CHTXRT.LSP)（Jeffery P. Sanders） |
| CHTXST | ChTxSt | 文字スタイルを変更 | [JefferyPSanders.com](https://jefferypsanders.com/CHTXST.LSP)（Jeffery P. Sanders） |
| CRTEXT | CrText | 円形に文字を配置 | [JefferyPSanders.com](https://jefferypsanders.com/CRTEXT.LSP)（Jeffery P. Sanders） |
| EBT | EBT | 空白文字を削除 | [JefferyPSanders.com](https://jefferypsanders.com/EBT.lsp)（Jeffery P. Sanders） |
| LTR | LTR | 線の角度に文字を回転 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_examp.html)（Jeffery P. Sanders） |
| MA | Ma | 文字内容を一致させる | [JefferyPSanders.com](https://jefferypsanders.com/MA.LSP)（Jeffery P. Sanders） |
| MIXTXT | MixTxt | 文字内の単語を入替え | [JefferyPSanders.com](https://jefferypsanders.com/MIXTXT.LSP)（Jeffery P. Sanders） |
| NUMBERX | NumberX | 縦並び文字を上から連番化 | [JefferyPSanders.com](https://jefferypsanders.com/NUMBERX.LSP)（Jeffery P. Sanders） |
| PRETX | PreTx | 文字に接頭辞を付加 | [JefferyPSanders.com](https://jefferypsanders.com/PRETX.LSP)（Jeffery P. Sanders） |
| RRR | RRR | 文字の検索と置換 | [JefferyPSanders.com](https://jefferypsanders.com/RRR.LSP)（Jeffery P. Sanders） |
| Simplex | Simplex | ハッチ可能な中抜き文字作成 | [JefferyPSanders.com](https://jefferypsanders.com/Simplex.lsp)（Jeffery P. Sanders） |
| SPCTEXT | SpcText | 文字間にスペース挿入 | [JefferyPSanders.com](https://jefferypsanders.com/SPCTEXT.LSP)（Jeffery P. Sanders） |
| STX / USTX | StText | 文字の伸縮・解除 | [JefferyPSanders.com](https://jefferypsanders.com/STTEXT.LSP)（Jeffery P. Sanders） |
| SWAPTXT | SwapTxt | 2つの文字内容を入替え | [JefferyPSanders.com](https://jefferypsanders.com/SWAPTXT.LSP)（Jeffery P. Sanders） |
| TEXTIN | TextIn | テキストファイルを図面に記入 | [JefferyPSanders.com](https://jefferypsanders.com/TEXTIN.LSP)（Jeffery P. Sanders） |
| TEXTOUT | TextOut | 図面の文字をファイル出力 | [JefferyPSanders.com](https://jefferypsanders.com/TEXTOUT.LSP)（Jeffery P. Sanders） |
| TOTALTX | TotalTx | 数値文字を合計 | [JefferyPSanders.com](https://jefferypsanders.com/TOTALTX.LSP)（Jeffery P. Sanders） |
| TXTCNT | TXTCNT | 同一文字の出現数を集計 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_examp.html)（Jeffery P. Sanders） |
| WORDS | Words | 図面内の単語数を数える | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_WORDS.html)（Jeffery P. Sanders） |
| AT | Align Text | 文字を基点で一直線に整列 | [Lee Mac Programming](https://www.lee-mac.com/aligntext.html) |
| ATC | Align Text to Curve | 文字を曲線に沿って配置 | [Lee Mac Programming](https://www.lee-mac.com/curvealignedtext.html) |
| DTCurve / DTRemove | Align Text to Curve (Auto Re-align) | 曲線沿い文字を自動再配置 | [Lee Mac Programming](https://www.lee-mac.com/dtcurve.html) |
| tbox / rtbox | Associative Textbox | 文字に連動する囲み枠を作図 | [Lee Mac Programming](https://www.lee-mac.com/assoctextbox.html) |
| bmask | Background Mask | 文字に背景マスクを設定 | [Lee Mac Programming](https://www.lee-mac.com/mask.html) |
| BT | Box Text | 文字を矩形で囲む | [Lee Mac Programming](https://www.lee-mac.com/boxtext.html) |
| copyfield | Copy Field | フィールドを他の文字へコピー | [Lee Mac Programming](https://www.lee-mac.com/copyfield.html) |
| ctx / stx | Copy or Swap Text | 文字内容のコピー・入替え | [Lee Mac Programming](https://www.lee-mac.com/copytext.html) |
| TxAlign | Dynamic Text Alignment | 文字の位置・角度を動的調整 | [Lee Mac Programming](https://www.lee-mac.com/dynamictextalignment.html) |
| fieldmath | Field Arithmetic | フィールド同士の計算式作成 | [Lee Mac Programming](https://www.lee-mac.com/fieldmath.html) |
| fieldformat | Field Formatting Code | フィールド書式コードを取得 | [Lee Mac Programming](https://www.lee-mac.com/fieldformat.html) |
| fieldobjects | Field Objects | フィールド参照先の図形を表示 | [Lee Mac Programming](https://www.lee-mac.com/fieldobjects.html) |
| incarray / incarrayd | Incremental Array | 連番を増やしながら配列複写 | [Lee Mac Programming](https://www.lee-mac.com/incrementalarray.html) |
| NumInc | Incremental Numbering Suite | 連番文字・属性を配置 | [Lee Mac Programming](https://www.lee-mac.com/numinc.html) |
| Label | Label | 曲線に沿ったラベル配置 | [Lee Mac Programming](https://www.lee-mac.com/label.html) |
| MFF | Match Field Formatting | フィールド書式を一致させる | [Lee Mac Programming](https://www.lee-mac.com/matchfieldformatting.html) |
| MatchTextProps / MTP | Match Text Properties | 文字プロパティを一致させる | [Lee Mac Programming](https://www.lee-mac.com/matchtextprops.html) |
| mljust | Multiline Justification | マルチ引出線文字位置を調整 | [Lee Mac Programming](https://www.lee-mac.com/mljust.html) |
| - | Quick Field | フィールド作成コマンドを量産 | [Lee Mac Programming](https://www.lee-mac.com/quickfield.html) |
| qmrg / qspl | Quick Merge & Split | 文字の結合・分割 | [Lee Mac Programming](https://www.lee-mac.com/quickmerge.html) |
| mteditreactoron / mteditreactoroff | Select all MText or MLeader Content on Double-Click | ダブルクリックで全文字選択 | [Lee Mac Programming](https://www.lee-mac.com/mteditreactor.html) |
| CurveText | Slinky Text | 文字を曲線形状に配置 | [Lee Mac Programming](https://www.lee-mac.com/slinkytext.html) |
| strike / strike2 / strike3 | Strikethrough Text | 文字に取消線・下線を追加 | [Lee Mac Programming](https://www.lee-mac.com/strikethrough.html) |
| TextCalc / TC | Text Calculator | 文字数値で計算 | [Lee Mac Programming](https://www.lee-mac.com/textcalculator.html) |
| TCount | Text Counter | 文字に連番を付加 | [Lee Mac Programming](https://www.lee-mac.com/tcount.html) |
| t2w | Text to Words | 文字を単語ごとに分割 | [Lee Mac Programming](https://www.lee-mac.com/texttowords.html) |
| T2M | Text2MText Upgraded | 文字をマルチテキスト化 | [Lee Mac Programming](https://www.lee-mac.com/text2mtext.html) |
| - | Add or Subtract Text Values (dp2.lsp) | 数値文字に値を加減算 | [draftsperson.net](https://draftsperson.net/lisproutines/dp2.lsp) |
| - | Copy and Change Text (ct.lsp) | 文字を複写して内容を変更 | [draftsperson.net](https://draftsperson.net/lisproutines/ct.lsp) |
| - | Date Stamp (tip667.zip) | 日付スタンプを記入 | [draftsperson.net](https://draftsperson.net/lisproutines/tip667.zip) |
| - | Edit Utilities (edits.lsp) | 色・文字内容・文字幅を変更 | [draftsperson.net](https://draftsperson.net/lisproutines/edits.lsp) |
| - | Match Text (Matchtxt.lsp) | 文字内容を選択文字に合わせる | [draftsperson.net](https://draftsperson.net/lisproutines/Matchtxt.lsp) |
| - | Match Text Height and Style (chgtext.lsp) | 文字高さ・スタイルを合わせる | [draftsperson.net](https://draftsperson.net/lisproutines/chgtext.lsp) |
| - | Numbering (numbering.lsp) | 連番・連続記号を記入 | [draftsperson.net](https://draftsperson.net/lisproutines/numbering.lsp) |
| - | Standardize Text (cht.lsp) | 選択文字を標準化・修正 | [draftsperson.net](https://draftsperson.net/lisproutines/cht.lsp) |
| - | Text Along Arc (atext.zip) | 円弧に沿って文字配置 | [draftsperson.net](https://draftsperson.net/lisproutines/atext.zip) |
| - | Text Height by Scale (textsize.zip) | 尺度から文字高さを計算 | [draftsperson.net](https://draftsperson.net/lisproutines/textsize.zip) |
| - | Text with Break (tb.lsp) | 文字記入し交差線を切断 | [draftsperson.net](https://draftsperson.net/lisproutines/tb.lsp) |
| - | Viewport Text Scale (vptext.lsp) | VP尺度で文字を尺度変更 | [draftsperson.net](https://draftsperson.net/lisproutines/vptext.lsp) |

<a id="02寸法"></a>
## 寸法（11件）

| コマンド | 名前 | 何をするツールか | 作者・サイト |
|---|---|---|---|
| BV / Bevel / BVS | Bevel | 開先（ベベル）寸法を作図 | [AutoLISP Exchange](https://autolisp-exchange.com/LISP/Bevel.lsp)（Terry Miller） |
| DimStyles / DS | DimStyles | 尺度別寸法スタイル作成 | [AutoLISP Exchange](https://autolisp-exchange.com/LISP/DimStyles.lsp)（Terry Miller） |
| DM | DM | 寸法スタイルを一致・更新 | [AutoLISP Exchange](https://autolisp-exchange.com/LISP/DM.lsp)（Terry Miller） |
| DPL | DPL | ポリラインを1クリックで寸法記入 | [AutoLISP Exchange](https://autolisp-exchange.com/LISP/DPL.lsp)（Terry Miller） |
| DIMRST | DimReset.lsp | 上書き寸法値を実測値に戻す | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| EDIM | EasyDim.lsp | ポリライン全周に寸法記入 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| ai_dim_textbelow | AI_DIM_TEXTBELOW | 寸法値を寸法線の下に移動 | [JTB World](https://jtbworld.com/autolisp-visual-lisp)（JTB World (Jimmy Bergmark)） |
| DIMLINECHANGE / DLC | dimlinechange.lsp | 寸法の線を現在画層へ変更 | [JTB World](https://jtbworld.com/autocad-dimlinechange-lsp)（JTB World (Jimmy Bergmark)） |
| ISODIM | ISODIM | 等角図寸法を作成 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_ISODIM.html)（Jeffery P. Sanders） |
| dimoverlap | Dimension Overlap | 重なった寸法を検出 | [Lee Mac Programming](https://www.lee-mac.com/dimoverlap.html) |
| - | Polyline Cumulative Distances (pdistr13.lsp) | ポリライン頂点に累積距離表示 | [draftsperson.net](https://draftsperson.net/lisproutines/pdistr13.lsp) |

<a id="03引出線注記"></a>
## 引出線・注記（14件）

| コマンド | 名前 | 何をするツールか | 作者・サイト |
|---|---|---|---|
| DL | DL | 文字に揃えた引出線を作図 | [AutoLISP Exchange](https://autolisp-exchange.com/LISP/DL.lsp)（Terry Miller） |
| ARROW | ArrowHead.lsp | 線に方向矢印を付加 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| LEADTXT | LeadText.lsp | 背景マスク付きマルチ引出線 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| QCLOUD | QuickCloud.lsp | 尺度に応じた雲マーク作成 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| CLOUD | Cloud | 改訂雲マークを作図 | [JefferyPSanders.com](https://jefferypsanders.com/CLOUD.LSP)（Jeffery P. Sanders） |
| DLD | DLD | 引出線文字横に縦線を追加 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_examp.html)（Jeffery P. Sanders） |
| NOTES | Notes | マスタファイルから注記挿入 | [JefferyPSanders.com](https://jefferypsanders.com/NOTES.zip)（Jeffery P. Sanders） |
| - | BALLOON.LSP | バルーン付き引出線を作成 | [ManuSoft](https://www.manusoft.com/resources/freebies/lisp/)（Owen Wengerd (ManuSoft)） |
| - | Arc Leader (arcl.lsp) | 円弧状の引出線を作図 | [draftsperson.net](https://draftsperson.net/lisproutines/arcl.lsp) |
| - | Box, Delta and Note Symbols (symbols.zip) | 四角・三角・丸記号と引出線 | [draftsperson.net](https://draftsperson.net/lisproutines/symbols.zip) |
| - | Line and Text (le.lsp) | 線を引いて文字を記入 | [draftsperson.net](https://draftsperson.net/lisproutines/le.lsp) |
| - | Note with Leader (note.zip) | 定型注記を引出線付きで記入 | [draftsperson.net](https://draftsperson.net/lisproutines/note.zip) |
| - | Pitch Triangle (ps_v15.zip) | 勾配三角記号を配置 | [draftsperson.net](https://draftsperson.net/lisproutines/ps_v15.zip) |
| - | Squiggly Leader (AL2.LSP) | 波線の引出線を作図 | [draftsperson.net](https://draftsperson.net/lisproutines/AL2.LSP) |

<a id="04ブロック属性"></a>
## ブロック・属性（61件）

| コマンド | 名前 | 何をするツールか | 作者・サイト |
|---|---|---|---|
| BLMENU / BLIB / INBL | Blk_Lib (Block Library) | スライド付ブロックライブラリ管理 | [AutoLISP Exchange](https://autolisp-exchange.com/LISP/Blk_Lib.lsp)（Terry Miller） |
| BLKCNT | BlockCounter.lsp | ブロック数を集計し表作成 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| BFZ | BlockFixZero.lsp | ブロック内図形を0画層へ | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| BLKREP | BlockReplace.lsp | ブロックを別ブロックに置換 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| BSM | BlockScaleMaster.lsp | 複数ブロックを個別に尺度変更 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| BURSTALL | BurstAll.lsp | 属性を文字化して分解 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| FRATT | FindReplaceAttr.lsp | 属性値を一括検索置換 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| INSPT | InsPtMove.lsp | ブロック挿入基点を変更 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| RENBLK | RenameBlocksBatch.lsp | ブロック名を一括リネーム | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| AttDefToMText | AttDefToMText.lsp | 属性定義をマルチテキスト化 | [JTB World](https://jtbworld.com/autocad-attdeftomtext-lsp)（JTB World (Jimmy Bergmark)） |
| AttDefToText | AttDefToText.lsp | 属性定義を文字に変換 | [JTB World](https://jtbworld.com/autocad-attdeftotext-lsp)（JTB World (Jimmy Bergmark)） |
| insrot / ax-insrot | insrot.lsp | 属性付きブロックを回転挿入 | [JTB World](https://jtbworld.com/autocad-insrot-lsp)（JTB World (Jimmy Bergmark)） |
| ATTINC | ATTINC | 属性値を連番で増加 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_AttInc.html)（Jeffery P. Sanders） |
| BLKOUT | BLKOUT | ネストブロックを個別ファイル化 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_BLKOUT.html)（Jeffery P. Sanders） |
| BLKTREE | BLKTREE | ブロック構造をツリー表示 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_blktree.html)（Jeffery P. Sanders） |
| BLOCKMASTER | BLOCKMASTER | 挿入時に属性を自動入力 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_blockmaster.html)（Jeffery P. Sanders） |
| BLOCKS | BLOCKS | 名前・属性でブロックを集計 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_blocks.html)（Jeffery P. Sanders） |
| CNTBLK | CNTBLK | ブロック数を集計（属性条件可） | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_cntblk.html)（Jeffery P. Sanders） |
| LIBRARY | LIBRARY | スライド付ブロックライブラリ | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_library.html)（Jeffery P. Sanders） |
| NODESERT | NodeSert | 全ての点にブロック挿入 | [JefferyPSanders.com](https://jefferypsanders.com/nodesert.lsp)（Jeffery P. Sanders） |
| RepAtt | RepAtt | 一致する属性値を一括置換 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_RepAtt.html)（Jeffery P. Sanders） |
| SafeX | SafeX | 属性を文字に残してブロック分解 | [JefferyPSanders.com](https://jefferypsanders.com/SAFEX.lsp)（Jeffery P. Sanders） |
| XMINSERT | XMINSERT | MINSERTを分解 | [JefferyPSanders.com](https://jefferypsanders.com/xminsert.lsp)（Jeffery P. Sanders） |
| addtoblock | Add Objects to Block | 既存ブロック定義に図形を追加 | [Lee Mac Programming](https://www.lee-mac.com/addobjectstoblock.html) |
| A2A | Area Field to Attribute | 面積フィールドを属性に挿入 | [Lee Mac Programming](https://www.lee-mac.com/areafieldtoattribute.html) |
| AttCol | Attribute Colour | 属性の色を一括変更 | [Lee Mac Programming](https://www.lee-mac.com/attributecolour.html) |
| MvAtt / RoAtt / EdAtt | Attribute Modification Suite | 属性の移動・回転・編集 | [Lee Mac Programming](https://www.lee-mac.com/attmodsuite.html) |
| ABB / ABBE / ABBS | Automatic Block Break | ブロック挿入時に線を自動切断 | [Lee Mac Programming](https://www.lee-mac.com/autoblockbreak.html) |
| autolabelon / autolabeloff | Automatically Label Attributes | 頂点座標を属性に自動記入 | [Lee Mac Programming](https://www.lee-mac.com/autolabelattributes.html) |
| blkcount / blkcountsettings | Block Counter | ブロック数を集計し表作成 | [Lee Mac Programming](https://www.lee-mac.com/blockcounter.html) |
| pburst / nburst | Burst Upgraded | 属性付きブロックを分解 | [Lee Mac Programming](https://www.lee-mac.com/upgradedburst.html) |
| CBP / CBPR | Change Block Base Point | ブロック基点を変更 | [Lee Mac Programming](https://www.lee-mac.com/changeblockinsertion.html) |
| CB / RB | Copy or Rename Block Reference | ブロックを複製・名前変更 | [Lee Mac Programming](https://www.lee-mac.com/copyblock.html) |
| cav | Count Attribute Values | 属性値の出現数を集計 | [Lee Mac Programming](https://www.lee-mac.com/countattributevalues.html) |
| delblocks | Delete Blocks | ブロック定義と参照を一括削除 | [Lee Mac Programming](https://www.lee-mac.com/deleteblocks.html) |
| attw | Dynamic Attribute Width | 属性の幅を動的に調整 | [Lee Mac Programming](https://www.lee-mac.com/dynattwidth.html) |
| DBCount | Dynamic Block Counter | ダイナミックブロックを集計 | [Lee Mac Programming](https://www.lee-mac.com/dynamicblockcounter.html) |
| ENB | Extract Nested Block | ネストブロックを抽出 | [Lee Mac Programming](https://www.lee-mac.com/extractnestedblock.html) |
| JBP | Justify Block Base Point | ブロック基点を位置合わせ | [Lee Mac Programming](https://www.lee-mac.com/justifybasepoint.html) |
| L2A | Length Field to Attribute | 長さフィールドを属性に挿入 | [Lee Mac Programming](https://www.lee-mac.com/lengthfieldtoattribute.html) |
| MatchAttribs | Match Attributes | 属性値をブロック間でコピー | [Lee Mac Programming](https://www.lee-mac.com/matchattribs.html) |
| BlockCount | Nested Block Counter | ネストブロックも含め集計 | [Lee Mac Programming](https://www.lee-mac.com/nestedblockcounter.html) |
| nburst | Nested Burst | ネストした属性ブロックを分解 | [Lee Mac Programming](https://www.lee-mac.com/nestedburst.html) |
| nmove | Nested Move | ブロック内図形を移動 | [Lee Mac Programming](https://www.lee-mac.com/nestedmove.html) |
| attsum | Sum Attribute Values | 属性数値を合計 | [Lee Mac Programming](https://www.lee-mac.com/sumattributes.html) |
| - | FIXBLOCK.LSP | ブロック要素を0画層・BYBLOCKに | [ManuSoft](https://www.manusoft.com/resources/freebies/lisp/)（Owen Wengerd (ManuSoft)） |
| - | MAKEBLOK.LSP | 選択図形を無名ブロック化 | [ManuSoft](https://www.manusoft.com/resources/freebies/lisp/)（Owen Wengerd (ManuSoft)） |
| - | Attribute Name Edit (attedit.zip) | 属性名を変更 | [draftsperson.net](https://draftsperson.net/lisproutines/attedit.zip) |
| - | Auto Rename Blocks (arenam.zip) | ブロック名を対応表で一括変更 | [draftsperson.net](https://draftsperson.net/lisproutines/arenam.zip) |
| - | Block Count (BC.LSP) | 特定ブロックの数を数える | [draftsperson.net](https://draftsperson.net/lisproutines/BC.LSP) |
| - | Block Extender (BlockExtender.zip) | ブロック管理ツール(試用版) | [draftsperson.net](https://draftsperson.net/lisproutines/BlockExtender.zip) |
| - | Block Report (blkrpt.zip) | ブロック挿入数をレポート | [draftsperson.net](https://draftsperson.net/lisproutines/blkrpt.zip) |
| - | Block Scale (bscale.lsp) | ブロックを各挿入点で尺度変更 | [draftsperson.net](https://draftsperson.net/lisproutines/bscale.lsp) |
| - | Block Scale 5.1 (bsc51.zip) | ブロックを個別に尺度変更 | [draftsperson.net](https://draftsperson.net/lisproutines/bsc51.zip) |
| - | Blocks to ByLayer (bylaybk.zip) | ブロック定義をBYLAYER化 | [draftsperson.net](https://draftsperson.net/lisproutines/bylaybk.zip) |
| - | Detail Book (DetailBook.zip) | 詳細図ライブラリの整理管理 | [draftsperson.net](https://draftsperson.net/lisproutines/DetailBook.zip) |
| - | Fix Block Layers (fixblock.zip) | ブロック内要素を0画層・BYBLOCKに | [draftsperson.net](https://draftsperson.net/lisproutines/fixblock.zip) |
| - | Paste As Block (pasteasblock.LSP) | 選択図形をブロック化して配置 | [draftsperson.net](https://draftsperson.net/lisproutines/pasteasblock.LSP) |
| - | Template Block Library (templt.zip) | アイコンメニュー式ブロックライブラリ | [draftsperson.net](https://draftsperson.net/lisproutines/templt.zip) |
| - | Update Block Layer and Colour (updblock.zip) | ブロック内の画層・色を一括更新 | [draftsperson.net](https://draftsperson.net/lisproutines/updblock.zip) |
| - | WBLOCK All Blocks (wblkall.zip) | 全ブロックをWBLOCK書き出し | [draftsperson.net](https://draftsperson.net/lisproutines/wblkall.zip) |

<a id="05画層"></a>
## 画層（レイヤー）（32件）

| コマンド | 名前 | 何をするツールか | 作者・サイト |
|---|---|---|---|
| CBLFIX | ColorByLayerFix.lsp | 全図形をByLayerに修正 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| DEL0LAY | DeleteEmptyLayers.lsp | 未使用画層を削除 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| LFREEZE | LayerFreezeSelect.lsp | 図形選択で画層フリーズ | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| LISO | LayerIsoPro.lsp | 他画層をフェードして画層分離 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| LMELT | LayerMelt.lsp | 画層の図形を現在画層へ統合 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| LSTOG | LayerStateToggle.lsp | 画層状態を切替 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| LTRANSB | LayerTranslator.lsp | 対応表で画層名を一括変換 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| LWALK | LayerWalkDCL.lsp | 画層をダイアログで閲覧 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| LOCKALL | LockAllLayers.lsp | 現在画層以外を全ロック | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| ChangeNoPlotLayers | ChangeNoPlottableLayers.LSP | 非印刷画層の図形をDefpointsへ | [JTB World](https://jtbworld.com/autocad-change-no-plottable-layers-lsp)（JTB World (Jimmy Bergmark)） |
| dlf | DLF.lsp | 画層フィルタを削除 | [JTB World](http://blog.jtbworld.com/2005/03/delete-autocad-layer-filters.html)（JTB World (Jimmy Bergmark)） |
| llfp | layer-list.LSP | 画層一覧をファイル出力 | [JTB World](https://jtbworld.com/autocad-layer-list-lsp)（JTB World (Jimmy Bergmark)） |
| layer-lw-list | layer-lw-list.LSP | 画層・線太さ一覧を作図 | [JTB World](https://jtbworld.com/autocad-layer-lw-list-lsp)（JTB World (Jimmy Bergmark)） |
| - | layer-state.LSP | 状態別に画層を一覧 | [JTB World](https://jtbworld.com/autocad-layer-state-lsp)（JTB World (Jimmy Bergmark)） |
| - | layer-toggle-freeze.lsp | 画層の凍結を切替え | [JTB World](https://jtbworld.com/autocad-layer-toggle-freeze-lsp)（JTB World (Jimmy Bergmark)） |
| layers-erase | layers-erase.LSP | 凍結・非表示画層を削除 | [JTB World](https://jtbworld.com/autocad-layers-erase-lsp)（JTB World (Jimmy Bergmark)） |
| - | PurgeReconciledLayers.LSP | 調整済画層情報を削除 | [JTB World](https://jtbworld.com/autocad-purgereconciledlayers-lsp)（JTB World (Jimmy Bergmark)） |
| SaveVPlayers / LoadVPlayers / CopyVPlayers | VPlayers.lsp | VP凍結画層を保存・復元 | [JTB World](https://jtbworld.com/autocad-vplayers-lsp)（JTB World (Jimmy Bergmark)） |
| CLAY | CLAY | マスタリストから画層作成 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_CLAY.html)（Jeffery P. Sanders） |
| FZ / UFZ | FZ / UFZ | 全画層の凍結・解凍 | [JefferyPSanders.com](https://jefferypsanders.com/FZ.LSP)（Jeffery P. Sanders） |
| REMF | REMF | 画層フィルタを一括削除 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_remf.html)（Jeffery P. Sanders） |
| LDON / LDOFF | Layer Director | コマンド毎に画層を自動切替 | [Lee Mac Programming](https://www.lee-mac.com/layerdirector.html) |
| LDOrder | Layer Draw Order | 画層単位で表示順序を変更 | [Lee Mac Programming](https://www.lee-mac.com/layerdraworder.html) |
| LayerExtract | Layer Extractor | 画層ごとに別図面へ書出し | [Lee Mac Programming](https://www.lee-mac.com/layerextract.html) |
| pslay / rpslay | Layer Prefix/Suffix | 画層名に接頭辞・接尾辞を付加 | [Lee Mac Programming](https://www.lee-mac.com/pslay.html) |
| Layers2DWGs | Layers to Drawings | 画層を個別図面に分割 | [Lee Mac Programming](https://www.lee-mac.com/layerstodrawings.html) |
| - | Delete Layer (del-layer.lsp) | 図形ごと画層を削除 | [draftsperson.net](https://draftsperson.net/lisproutines/del-layer.lsp) |
| - | Layer Match (Lmatch.lsp) | 図形の画層を選択図形に合わせる | [draftsperson.net](https://draftsperson.net/lisproutines/Lmatch.lsp) |
| - | Layer Set (ls.lsp) | 画層を設定 | [draftsperson.net](https://draftsperson.net/lisproutines/ls.lsp) |
| - | Layer Tools (lt.zip) | 図形選択で画層を操作 | [draftsperson.net](https://draftsperson.net/lisproutines/lt.zip) |
| - | Move Layer (Mlayer.zip) | 画層全体を選択して移動 | [draftsperson.net](https://draftsperson.net/lisproutines/Mlayer.zip) |
| - | Set Layer from Entity (sl.lsp) | 選択図形の画層を現在画層に | [draftsperson.net](https://draftsperson.net/lisproutines/sl.lsp) |

<a id="06線ポリライン編集"></a>
## 線・ポリラインの編集（61件）

| コマンド | 名前 | 何をするツールか | 作者・サイト |
|---|---|---|---|
| COP | COP | 距離・角度で連続コピー | [AutoLISP Exchange](https://autolisp-exchange.com/LISP/COP.lsp)（Terry Miller） |
| TESTDL | DelDupLine | 重複線・短い線を削除 | [AutoLISP Exchange](https://autolisp-exchange.com/Other/DelDupLine.lsp)（Tihomir Bojanic） |
| BRKALL | BreakAll.lsp | 全交点で一括切断 | [CAD Authority](https://cadauthority.com/download/autocad/autolisp/autocad-breakall-lisp-break-intersections/)（CADAuthority） |
| CHMALL | ChamferMulti.lsp | ポリライン全角を面取り | [CAD Authority](https://cadauthority.com/free-download/autocad/autocad-bulk-chamfer-polyline-lisp/)（CADAuthority） |
| C2P | CircleToPolyline.lsp | 円をポリラインに変換 | [CAD Authority](https://cadauthority.com/download/autocad/convert-circle-to-polyline-autocad-lisp/)（CADAuthority） |
| FZ | FilletZero.lsp | 半径0でフィレット | [CAD Authority](https://cadauthority.com/download/autocad/autocad-fillet-radius-0-lisp-fz/)（CADAuthority） |
| FLATZ | FlattenZ.lsp | Z座標を0にして2D化 | [CAD Authority](https://cadauthority.com/download/autocad/flatten-z-autocad-flatz-lisp/)（CADAuthority） |
| JOINALL | JoinAll.lsp | 接する線・円弧を一括ポリライン化 | [CAD Authority](https://cadauthority.com/download/autocad/autocad-join-lines-arcs-polylines-lisp/)（CADAuthority） |
| OKL | OverkillLite.lsp | 重複図形を高速削除 | [CAD Authority](https://cadauthority.com/download/autocad/autocad-overkilllite-fast-duplicate-removal-lisp/)（CADAuthority） |
| PLW | PolyWidthChange.lsp | ポリライン幅を一括変更 | [CAD Authority](https://cadauthority.com/free-download/autocad/batch-change-polyline-width-autocad-plw/)（CADAuthority） |
| REVPL | ReversePolyline.lsp | ポリラインの向きを反転 | [CAD Authority](https://cadauthority.com/free-download/autocad/reverse-polyline-direction-autocad/)（CADAuthority） |
| SCALEREL | ScaleRelative.lsp | 基準長さで尺度変更 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| SCALEXY | ScaleXY.lsp | XY別倍率で尺度変更 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| S2P | SplineToPoly.lsp | スプラインをポリラインに変換 | [CAD Authority](https://cadauthority.com/download/autocad/autocad-spline-to-polyline-cnc-autolisp/)（CADAuthority） |
| jf / pljoinfuzz | pljoinfuzz.lsp | 許容差付きで線を結合 | [JTB World](https://jtbworld.com/autocad-pljoinfuzz-lsp)（JTB World (Jimmy Bergmark)） |
| ANGX | AngX | 線の角度に合わせて回転 | [JefferyPSanders.com](https://jefferypsanders.com/ANGX.LSP)（Jeffery P. Sanders） |
| CC | CopyC | 距離・角度指定で連続コピー | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_examp.html)（Jeffery P. Sanders） |
| OverLapF | OverLapF | 重複線を結合・削除 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_remdup.html)（Jeffery P. Sanders） |
| SWAPENT | SwapEnt | 2つの図形の位置を入替え | [JefferyPSanders.com](https://jefferypsanders.com/SWAPENT.LSP)（Jeffery P. Sanders） |
| apv | Add Polyline Vertex | ポリラインに頂点を追加 | [Lee Mac Programming](https://www.lee-mac.com/addpolyvertex.html) |
| OA | Align Objects to Curve | 図形を曲線に沿って整列配置 | [Lee Mac Programming](https://www.lee-mac.com/objectalign.html) |
| CMeasure | Centered Measure | 曲線を中央揃えで等間隔配置 | [Lee Mac Programming](https://www.lee-mac.com/centeredmeasure.html) |
| cbrk | Circle Break | 円を2点で切断 | [Lee Mac Programming](https://www.lee-mac.com/circlebreak.html) |
| dex | Double Extend | 線の両端を境界まで延長 | [Lee Mac Programming](https://www.lee-mac.com/doubleextend.html) |
| DoubleOffset / DOff | Double Offset | 両側に同時オフセット | [Lee Mac Programming](https://www.lee-mac.com/doubleoffset.html) |
| DynOff | Dynamic Offset | 動的プレビュー付きオフセット | [Lee Mac Programming](https://www.lee-mac.com/dynamicoffset.html) |
| e2a | Ellipse to Arc | 楕円を円弧ポリラインに変換 | [Lee Mac Programming](https://www.lee-mac.com/ellipsetoarc.html) |
| tlpline | Limited Length Polyline | 指定長さまでポリライン作図 | [Lee Mac Programming](https://www.lee-mac.com/totallengthpline.html) |
| mpl | Multi-Polyline | 複数ポリラインを同時作図 | [Lee Mac Programming](https://www.lee-mac.com/mpline.html) |
| ML2PL | Multilines to Polylines | マルチラインをポリライン化 | [Lee Mac Programming](https://www.lee-mac.com/mlinetopline.html) |
| brk / brko | Object Break | 交差部で図形を切断 | [Lee Mac Programming](https://www.lee-mac.com/objectbreak.html) |
| offsec | Offset Polyline Section | ポリラインの一部区間をオフセット | [Lee Mac Programming](https://www.lee-mac.com/offsetpolysection.html) |
| outline | Outline Objects | 選択図形の外形線を作成 | [Lee Mac Programming](https://www.lee-mac.com/outlineobjects.html) |
| PolyInfo | Polyline Information | ポリライン頂点情報を一覧表示 | [Lee Mac Programming](https://www.lee-mac.com/polyinfo.html) |
| PolyOutline / mPolyOutline | Polyline Outline | 幅付きポリラインの外形線作成 | [Lee Mac Programming](https://www.lee-mac.com/polyoutline.html) |
| polyout / mpolyout | Polyline Outline (Advanced) | 可変幅ポリラインの外形線作成 | [Lee Mac Programming](https://www.lee-mac.com/advpolyoutline.html) |
| PJ / PC / PW | Polyline Programs | ポリライン結合・閉合・幅変更 | [Lee Mac Programming](https://www.lee-mac.com/polylineprograms.html) |
| ptaper | Polyline Taper | ポリラインをテーパー幅に | [Lee Mac Programming](https://www.lee-mac.com/polytaper.html) |
| QM / QMD / QMO / QMOD | Quick Mirror | 線を軸に素早く鏡像 | [Lee Mac Programming](https://www.lee-mac.com/quickmirror.html) |
| segs | Segment Curve | 曲線を直線分割 | [Lee Mac Programming](https://www.lee-mac.com/segmentcurve.html) |
| FILLET (再定義) | 3DFILLET.LSP | 非UCS平面の線もフィレット | [ManuSoft](https://www.manusoft.com/resources/freebies/lisp/)（Owen Wengerd (ManuSoft)） |
| (PWIDTH) | PWIDTH.LSP | 全ポリラインの幅を変更 | [ManuSoft](https://www.manusoft.com/resources/freebies/lisp/)（Owen Wengerd (ManuSoft)） |
| STRETCH (再定義) | STRETCH.LSP | 改良版ストレッチコマンド | [ManuSoft](https://www.manusoft.com/resources/freebies/lisp/)（Owen Wengerd (ManuSoft)） |
| - | Arcs to Circles (atc.zip) | 円弧を円に変換 | [draftsperson.net](https://draftsperson.net/lisproutines/atc.zip) |
| - | AutoPK Edit Tools (autopk.zip) | 図形編集コマンド集 | [draftsperson.net](https://draftsperson.net/lisproutines/autopk.zip) |
| - | Break at Intersection (BK.LSP) | 交点で線を切断 | [draftsperson.net](https://draftsperson.net/lisproutines/BK.LSP) |
| BP | Breakpoint (breakpoint.LSP) | 指定1点で図形を切断 | [draftsperson.net](https://draftsperson.net/lisproutines/breakpoint.LSP) |
| - | Building Line (BL.LSP) | 角度固定のポリラインで建築線作図 | [draftsperson.net](https://draftsperson.net/lisproutines/BL.LSP) |
| - | Change Entity Properties (CHG3.LSP) | 図形プロパティを番号選択で変更 | [draftsperson.net](https://draftsperson.net/lisproutines/CHG3.LSP) |
| - | Double Offset (dof.zip) | 両側にオフセットし元図形を削除 | [draftsperson.net](https://draftsperson.net/lisproutines/dof.zip) |
| - | Flatten (flat.lsp) | 3D図形を2Dに平坦化 | [draftsperson.net](https://draftsperson.net/lisproutines/flat.lsp) |
| - | Freehand Lines (Freehand.lsp) | 線を手描き風に変形 | [draftsperson.net](https://draftsperson.net/lisproutines/Freehand.lsp) |
| - | Join 2 Polylines (Join2.zip) | 2本のポリラインを結合 | [draftsperson.net](https://draftsperson.net/lisproutines/Join2.zip) |
| - | Line or Arc to Polyline (c2p.LSP) | 線・円弧をポリラインに変換 | [draftsperson.net](https://draftsperson.net/lisproutines/c2p.LSP) |
| - | Polyline Tools (pt.zip) | 複数ポリラインの幅・画層等を一括変更 | [draftsperson.net](https://draftsperson.net/lisproutines/pt.zip) |
| SCB / SC / SCD | Rectangle Trim (SCB / SC / SCD) (trims.zip) | 矩形の内外を一括トリム消去 | [draftsperson.net](https://draftsperson.net/lisproutines/trims.zip) |
| - | Rotate to Entity (Rot2ent.lsp) | 図形の角度に合わせて回転 | [draftsperson.net](https://draftsperson.net/lisproutines/Rot2ent.lsp) |
| - | Trim to Point (trim to point.lsp) | 指定点の仮線でトリム | [draftsperson.net](https://draftsperson.net/lisproutines/trim%20to%20point.lsp) |
| - | Zero Elevation (zp.lsp) | 線の標高を0にする | [draftsperson.net](https://draftsperson.net/lisproutines/zp.lsp) |
| - | Zero Radius Fillet (FILLET0.LSP) | 半径0でフィレット | [draftsperson.net](https://draftsperson.net/lisproutines/FILLET0.LSP) |
| PLINESWAPENDS | PLINESWAPENDS.LSP | ポリラインの向きを反転 | [gilesdarling.me.uk](http://www.gilesdarling.me.uk/lisproutines.shtml#plineswapends)（Giles Darling） |

<a id="07作図図形生成"></a>
## 作図（図形を描く）（29件）

| コマンド | 名前 | 何をするツールか | 作者・サイト |
|---|---|---|---|
| BPOLYX | BoundaryPoly.lsp | 点指定で境界ポリライン作成 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| CLD | CenterlineDraw.lsp | 2線間に中心線を作図 | [CAD Authority](https://cadauthority.com/download/autocad/autocad-centerline-lisp-no-x-error/)（CADAuthority） |
| PCOPY | PathCopy.lsp | パスに沿って等間隔複写 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| TANDRAW | TangentDraw.lsp | 2円に接する接線を作図 | [CAD Authority](https://cadauthority.com/free-download/autocad/draw-tangent-lines-autocad-lisp/)（CADAuthority） |
| mpt / 3pt / 4pt / mpt3 | mpt.lsp | 2点・3点の中点を取得 | [JTB World](https://jtbworld.com/autocad-mpt-lsp)（JTB World (Jimmy Bergmark)） |
| tp | Tape Measure | 巻尺形状を作図 | [JTB World](https://jtbworld.com/justlisp)（Mark Beggs） |
| BRKLINE | BrkLine | 破断線を作図 | [JefferyPSanders.com](https://jefferypsanders.com/BRKLINE.LSP)（Jeffery P. Sanders） |
| DRLIM | DrLim | 図面範囲を線で作図 | [JefferyPSanders.com](https://jefferypsanders.com/DRLIM.LSP)（Jeffery P. Sanders） |
| MATCH | Match | マッチラインを作図 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_MATCH.html)（Jeffery P. Sanders） |
| SBox | SBox | 影付きボックスを作図 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_SBox.html)（Jeffery P. Sanders） |
| ShrinkWrap | ShrinkWrap | 図形外周を境界で囲む | [JefferyPSanders.com](https://jefferypsanders.com/ShrinkWrap.lsp)（Jeffery P. Sanders） |
| 3PR / 3PRD | 3-Point Rectangle | 3点指定で矩形を作図 | [Lee Mac Programming](https://www.lee-mac.com/3pointrectangle.html) |
| aarc / aarcsettings | Arrow Arc | 矢印付き円弧を作図 | [Lee Mac Programming](https://www.lee-mac.com/arrowarc.html) |
| CL / CLRemove | Associative Centerlines | 円に連動する中心線を作図 | [Lee Mac Programming](https://www.lee-mac.com/associativecenterlines.html) |
| BBRN / BBRA / BBRR | Bounding Box Reactor | 図形外接矩形を連動表示 | [Lee Mac Programming](https://www.lee-mac.com/boundingboxreactor.html) |
| CLine | Centerline | 円・円弧に中心線を作図 | [Lee Mac Programming](https://www.lee-mac.com/centreline.html) |
| ctan | Circle Tangents | 2円の接線を動的作図 | [Lee Mac Programming](https://www.lee-mac.com/circletangents.html) |
| cwipe / c2wipe | Circular Wipeout | 円形ワイプアウトを作成 | [Lee Mac Programming](https://www.lee-mac.com/cwipe.html) |
| DGrid / DGridD | Draw Grid | 格子線を作図 | [Lee Mac Programming](https://www.lee-mac.com/drawgrid.html) |
| bisect | Dynamic Angle Bisection | 角の二等分線を動的作図 | [Lee Mac Programming](https://www.lee-mac.com/dynamicanglebisection.html) |
| isopoly | Isometric Polygon | 等角図用の多角形を作図 | [Lee Mac Programming](https://www.lee-mac.com/isopoly.html) |
| MEC / MECM | Minimum Enclosing Circle | 最小外接円を作図 | [Lee Mac Programming](https://www.lee-mac.com/minimumenclosingcircle.html) |
| star | Star | 星形を作図 | [Lee Mac Programming](https://www.lee-mac.com/star.html) |
| XX / XH / XV / XA | XLine | 構築線を素早く作図 | [Lee Mac Programming](https://www.lee-mac.com/xline.html) |
| TINT | TINT.LSP | 2線の仮想交点を取得 | [ManuSoft](https://www.manusoft.com/resources/freebies/lisp/)（Owen Wengerd (ManuSoft)） |
| - | Circle Tangent to Three Points (ttt.zip) | 3点に接する円を作図 | [draftsperson.net](https://draftsperson.net/lisproutines/ttt.zip) |
| - | Slot with Rounded Ends (slot1.zip) | 両端丸の長穴を作図 | [draftsperson.net](https://draftsperson.net/lisproutines/slot1.zip) |
| - | Spline Perpendiculars (sper.lsp) | スプラインへの垂線を作図 | [draftsperson.net](https://draftsperson.net/lisproutines/sper.lsp) |
| - | Trigonometric Function Graphs (tgraph.zip) | 三角関数グラフを作図 | [draftsperson.net](https://draftsperson.net/lisproutines/tgraph.zip) |

<a id="08ハッチ面積長さ集計"></a>
## ハッチ・面積・長さの集計（29件）

| コマンド | 名前 | 何をするツールか | 作者・サイト |
|---|---|---|---|
| AREATBL | AreaTable.lsp | 面積ラベルと集計表を作成 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| HTB | HatchToBack.lsp | ハッチを全て背面へ | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| TOTAREA | TotalArea.lsp | 複数閉ポリラインの面積合計 | [CAD Authority](https://cadauthority.com/download/autocad/autocad-multi-polyline-area-calculator-lisp/)（CADAuthority） |
| TOTLEN | TotalLength.lsp | 線・円弧・ポリラインの総延長 | [CAD Authority](https://cadauthority.com/download/autocad/autolisp/autocad-total-length-lisp-totlen/)（CADAuthority） |
| accdist / accdist1 / accdist2 | accdist.lsp | 距離を累積計測 | [JTB World](https://jtbworld.com/autocad-accdist-lsp)（JTB World (Jimmy Bergmark)） |
| aream | AreaM.lsp | 選択図形の合計面積 | [JTB World](https://jtbworld.com/autocad-aream-lsp)（JTB World (Jimmy Bergmark)） |
| areaOfObject | areaOfObject.lsp | 選択図形の面積を表示 | [JTB World](https://jtbworld.com/autocad-area-of-object-lsp)（JTB World (Jimmy Bergmark)） |
| AT / ATC / ATM | AreaText.lsp | ポリライン面積を文字記入 | [JTB World](https://jtbworld.com/autocad-areatext-lsp)（JTB World (Jimmy Bergmark)） |
| bomlengths | BOMLengths.lsp | 複数図形の長さを集計 | [JTB World](https://jtbworld.com/autocad-bomlengths-lsp)（JTB World (Jimmy Bergmark)） |
| hm / hatch_move | Hatch_Move.lsp | ハッチ基点を移動 | [JTB World](https://jtbworld.com/autocad-hatch-move-lsp)（JTB World (Jimmy Bergmark)） |
| hb / hbl / hatchb | HATCHB.LSP | ハッチ境界を再作成 | [JTB World](https://jtbworld.com/autocad-hatchb-lsp)（JTB World (Jimmy Bergmark)） |
| hatchbase | HatchBase.lsp | ハッチ基点を一括変更 | [JTB World](https://jtbworld.com/autocad-hatchbase-lsp)（JTB World (Jimmy Bergmark)） |
| lengthOfObject | lengthOfObject.lsp | 図形の長さ・周長を表示 | [JTB World](https://jtbworld.com/autocad-lengthofobject-lsp)（JTB World (Jimmy Bergmark)） |
| LTXT | LengthText.lsp | 図形の長さを文字記入 | [JTB World](https://jtbworld.com/autocad-lengthtext-lsp)（JTB World (Jimmy Bergmark)） |
| ADDLEN | ADDLEN | 選択図形の合計長さを算出 | [JefferyPSanders.com](https://jefferypsanders.com/ADDLEN.lsp)（Jeffery P. Sanders） |
| GA | GA | 内部指定で面積・周長を取得 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_GetArea.html)（Jeffery P. Sanders） |
| GetArea | GetArea (example) | ポリライン累積面積を記入 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_examp.html)（Jeffery P. Sanders） |
| AT / AF | Area Label | 面積を表やファイルに書出し | [Lee Mac Programming](https://www.lee-mac.com/arealabel.html) |
| A2F | Areas to Field | 複数面積の合計をフィールド化 | [Lee Mac Programming](https://www.lee-mac.com/areastofield.html) |
| chainlen | Chain Length | 連続図形の合計長さを計測 | [Lee Mac Programming](https://www.lee-mac.com/chainlength.html) |
| LF / AF | Length & Area Field | 長さ・面積のフィールド作成 | [Lee Mac Programming](https://www.lee-mac.com/lengthfield.html) |
| midlen | Length at Midpoint | 曲線中点に長さを記入 | [Lee Mac Programming](https://www.lee-mac.com/midlen.html) |
| IntLen / IntLenM | Length Between Intersections | 交点間の長さを計測 | [Lee Mac Programming](https://www.lee-mac.com/intersectionslength.html) |
| sht | Show Hatch Text | 文字上のハッチを除去表示 | [Lee Mac Programming](https://www.lee-mac.com/showhatchtext.html) |
| tlen | Total Length & Area Programs | 選択図形の合計長さ・面積 | [Lee Mac Programming](https://www.lee-mac.com/totallengthandarea.html) |
| - | CALCAREA.LSP | 部屋番号と面積をCSV出力 | [ManuSoft](https://www.manusoft.com/resources/freebies/lisp/)（Owen Wengerd (ManuSoft)） |
| - | Cumulative Distance (cumdist.lsp) | 複数点の累積距離を計測 | [draftsperson.net](https://draftsperson.net/lisproutines/cumdist.lsp) |
| - | How Far (howfar.zip) | 距離計測の拡張 | [draftsperson.net](https://draftsperson.net/lisproutines/howfar.zip) |
| - | Zone Area or Length (zone.lsp) | 画層上ポリラインの面積・長さ合計 | [draftsperson.net](https://draftsperson.net/lisproutines/zone.lsp) |

<a id="09選択フィルタ"></a>
## 選択・絞り込み（6件）

| コマンド | 名前 | 何をするツールか | 作者・サイト |
|---|---|---|---|
| GP / XGP / PUG | Groups | グループ作成・分解・削除 | [AutoLISP Exchange](https://autolisp-exchange.com/LISP/Groups.lsp)（Terry Miller） |
| OBJCNT | ObjectCounter.lsp | 範囲内の図形数をレポート | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| vpc / vpw | vpsel.lsp | ビューポート内図形を選択 | [JTB World](https://jtbworld.com/autocad-vpsel-lsp)（JTB World (Jimmy Bergmark)） |
| cs | Chain Selection | 連結した図形をまとめて選択 | [Lee Mac Programming](https://www.lee-mac.com/chainsel.html) |
| selcounton / selcountoff | Selection Counter | 選択数をリアルタイム表示 | [Lee Mac Programming](https://www.lee-mac.com/selectioncounter.html) |
| - | Delete Annotation Routines (Delete_Routines.rar) | 文字・寸法・引出線を一括削除 | [draftsperson.net](https://draftsperson.net/lisproutines/Delete_Routines.rar) |

<a id="10表Excel連携"></a>
## 表・Excel・CSV連携（17件）

| コマンド | 名前 | 何をするツールか | 作者・サイト |
|---|---|---|---|
| DrawExcel / DES | DrawExcel | Excel表を図面に作図 | [AutoLISP Exchange](https://autolisp-exchange.com/LISP/DrawExcel.lsp)（Terry Miller） |
| - | GetExcel | Excelセル値の読書き関数 | [AutoLISP Exchange](https://autolisp-exchange.com/LISP/GetExcel.lsp)（Terry Miller） |
| ATTEXP | AttributeExport.lsp | 属性をCSV・Excelに出力 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| XLS2TBL | ExcelToTable.lsp | CSV・Excelから表を作成 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| TBL2XLS | TableToExcel.lsp | 表をExcelに出力 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| CreateLT | CAO_Link_Templates.lsp | CAOリンクテンプレート作成・削除 | [JTB World](https://jtbworld.com/autocad-cao-link-templates-lsp)（JTB World (Jimmy Bergmark)） |
| - | Axcel | Excel表をAutoCADに作図（旧版） | [JefferyPSanders.com](https://jefferypsanders.com/autolisp.html)（Jeffery P. Sanders） |
| - | Axcel2016 | Excel表をAutoCADに作図 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp.html)（Jeffery P. Sanders） |
| - | AxcelPts | Excel座標から点を作図 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp.html)（Jeffery P. Sanders） |
| CAD2FILE | CAD2FILE | 図形データをExcel・CSV出力 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_cad2file.html)（Jeffery P. Sanders） |
| CSVTable | CSVTable | CSVから表を作図 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_CSVTABLE.html)（Jeffery P. Sanders） |
| ETable | ETable | 図形情報を表に出力しラベル付け | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_etable.html)（Jeffery P. Sanders） |
| - | GETCELLS | Excelセル値を取得する関数 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_GetCells.html)（Jeffery P. Sanders） |
| NUM | Num.lsp | チャート用の数値を自動作成 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp.html)（Jeffery P. Sanders） |
| XL | XL | ExcelデータをAutoCADへ取込み | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_XL.html)（Jeffery P. Sanders） |
| MacAtt / MacAttExt / MacAttEdit | Global Attribute Extractor & Editor | 複数図面の属性を抽出・編集 | [Lee Mac Programming](https://www.lee-mac.com/macatt.html) |
| - | TABLES.ZIP | カスタム表を定義・挿入 | [ManuSoft](https://www.manusoft.com/resources/freebies/lisp/)（Owen Wengerd (ManuSoft)） |

<a id="11印刷レイアウト図枠"></a>
## 印刷・レイアウト・図枠（27件）

| コマンド | 名前 | 何をするツールか | 作者・サイト |
|---|---|---|---|
| PlotDwgs / PD | PlotDwgs | 開いた図面・フォルダを一括印刷 | [AutoLISP Exchange](https://autolisp-exchange.com/LISP/PlotDwgs.lsp)（Terry Miller） |
| LAYREN | LayoutRename.lsp | レイアウト名を一括変更 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| VLOCKALL | ViewportLockAll.lsp | 全ビューポートをロック | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| ZALLLAY | ZoomAllLayouts.lsp | 全レイアウトで範囲ズーム | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| DeleteEmptyLayouts | DeleteEmptyLayouts | 空のレイアウトを削除 | [JTB World](https://jtbworld.com/autolisp-visual-lisp)（JTB World (Jimmy Bergmark)） |
| emptyornot | emptyornot | 各レイアウトの空き状況表示 | [JTB World](https://jtbworld.com/autolisp-visual-lisp)（JTB World (Jimmy Bergmark)） |
| - | GetPlotDevices.lsp | プロッタ・印刷スタイル取得 | [JTB World](https://jtbworld.com/autocad-getplotdevices-lsp)（JTB World (Jimmy Bergmark)） |
| getvpscale | getvpscale.lsp | ビューポート尺度を取得 | [JTB World](https://jtbworld.com/autocad-getvpscale-lsp)（JTB World (Jimmy Bergmark)） |
| LayoutsToDwgs | LayoutsToDwgs.lsp | レイアウトを個別図面に書出し | [JTB World](https://jtbworld.com/autocad-export-layouts-to-drawings-layoutstodwgs-lsp)（JTB World (Jimmy Bergmark)） |
| - | pagesetup.lsp | ページ設定関連ルーチン | [JTB World](https://jtbworld.com/autocad-pagesetup-lsp)（JTB World (Jimmy Bergmark)） |
| - | PlotDevicesFunctions.lsp | 印刷デバイス関連関数 | [JTB World](https://jtbworld.com/autocad-plotdevicesfunctionsl-sp)（JTB World (Jimmy Bergmark)） |
| plotdialog | plotdialog.lsp | 印刷ダイアログを強制表示 | [JTB World](https://jtbworld.com/autocad-plotdialog-lsp)（JTB World (Jimmy Bergmark)） |
| - | Remove Sheet Set association | シートセット関連付けを解除 | [JTB World](http://blog.jtbworld.com/2005/10/remove-sheet-set-association-on-sheet.html)（JTB World (Jimmy Bergmark)） |
| vpc | viewportcenter.LSP | ビューポート中心座標を取得 | [JTB World](https://jtbworld.com/autocad-viewportcenter-lsp)（JTB World (Jimmy Bergmark)） |
| vp-outline | vp-outline.LSP | ビューポート外形をモデルに作図 | [JTB World](https://jtbworld.com/autocad-vp-outline-lsp)（JTB World (Jimmy Bergmark)） |
| LAYOUTS | LAYOUTS | 一覧からレイアウトを選択 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_LAYOUTS.html)（Jeffery P. Sanders） |
| SelectPlotter | SelectPlotter | 一覧からプリンタを選択 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_selectplotter.html)（Jeffery P. Sanders） |
| C2L / C2AL | Copy to Layouts | 図形を複数レイアウトへコピー | [Lee Mac Programming](https://www.lee-mac.com/copytolayouts.html) |
| DFL / DFAL | Delete From Layouts | 複数レイアウトから図形削除 | [Lee Mac Programming](https://www.lee-mac.com/deletefromlayouts.html) |
| lfname / lfnumber / lfsheet | Layout Field | レイアウト名・番号をフィールド化 | [Lee Mac Programming](https://www.lee-mac.com/layoutfield.html) |
| ms2ps | Modelspace to Paperspace | モデル図形を紙空間へ移動 | [Lee Mac Programming](https://www.lee-mac.com/ms2ps.html) |
| RL | Renumber Layouts | レイアウト名を連番に変更 | [Lee Mac Programming](https://www.lee-mac.com/renumberlayouts.html) |
| TabSort | TabSort | レイアウトタブを並べ替え | [Lee Mac Programming](https://www.lee-mac.com/tabsort.html) |
| utb | Update Titleblock Attributes | 図枠属性を自動更新 | [Lee Mac Programming](https://www.lee-mac.com/updatetitleblock.html) |
| VPO / VPOL / VPOA | Viewport Outline | ビューポート外形をモデルに作図 | [Lee Mac Programming](https://www.lee-mac.com/vpoutline.html) |
| - | A4 Title Block (tba.zip) | A4図枠をダイアログ入力で挿入 | [draftsperson.net](https://draftsperson.net/lisproutines/tba.zip) |
| - | Viewport Grid (vpgrid.lsp) | ビューポートに座標グリッド配置 | [draftsperson.net](https://draftsperson.net/lisproutines/vpgrid.lsp) |

<a id="12外部参照図面管理一括処理"></a>
## 外部参照・図面管理・一括処理（28件）

| コマンド | 名前 | 何をするツールか | 作者・サイト |
|---|---|---|---|
| CDC / ODC | OpenDwgsCmds | 開いた全図面でコマンド実行 | [AutoLISP Exchange](https://autolisp-exchange.com/LISP/OpenDwgsCmds.lsp)（Terry Miller） |
| Scrs | Scrs | スクリプトを作成し一括実行 | [AutoLISP Exchange](https://autolisp-exchange.com/LISP/Scrs.lsp)（Terry Miller） |
| AAUDIT | AutoAudit.lsp | 監査・パージ・ズームを自動実行 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| DWGVER | DrawingVersion.lsp | 日付・パスのスタンプ記入 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| PURGEH | PurgeHard.lsp | 登録アプリ含め徹底パージ | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| XPATHFIX | XrefPathFix.lsp | 外部参照パスを相対パス化 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| XRELOAD | XrefReloadAll.lsp | 全外部参照を再ロード | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| btx / BlockToXref | BlockToXref.lsp | ブロックを外部参照に変換 | [JTB World](https://jtbworld.com/autocad-blocktoxref-lsp)（JTB World (Jimmy Bergmark)） |
| - | Purge unreferenced images | 未参照イメージを削除 | [JTB World](http://blog.jtbworld.com/2009/06/purge-unreferenced-images-in-autocad.html)（JTB World (Jimmy Bergmark)） |
| purge-point / purge-all-point 他 | Purge-Point.lsp | POINT5等の不要オブジェクト削除 | [JTB World](https://jtbworld.com/autocad-purge-point-lsp)（JTB World (Jimmy Bergmark)） |
| count-layer-states | purger.lsp | 各種名前削除を静かに実行 | [JTB World](https://jtbworld.com/autocad-purger-lsp)（JTB World (Jimmy Bergmark)） |
| - | SOpen.lsp | SDIに依存しない図面を開く | [JTB World](https://jtbworld.com/autocad-sopen-lsp)（JTB World (Jimmy Bergmark)） |
| - | XrefRename.lsp | 外部参照名とパスを変更 | [JTB World](https://jtbworld.com/autocad-xrefrename-lsp)（JTB World (Jimmy Bergmark)） |
| xrp | XrefRepath.lsp | 外部参照を相対パス化 | [JTB World](http://www.jtbworld.com/download/XrefRepath.lsp)（JTB World (Jimmy Bergmark)） |
| ATTMAP | ATTMAP | 属性値を他図面へ一括転記 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_attmap.html)（Jeffery P. Sanders） |
| BatchLisp | BatchLisp | LISPを複数図面で一括実行 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_batchlisp.html)（Jeffery P. Sanders） |
| CPYXREF | CPYXREF | 外部参照・ブロック内図形をコピー | [JefferyPSanders.com](https://jefferypsanders.com/CPYXREF.lsp)（Jeffery P. Sanders） |
| batte | Batch Attribute Editor | 複数図面の属性を一括編集 | [Lee Mac Programming](https://www.lee-mac.com/batte.html) |
| BFind | Batch Find & Replace Text | 複数図面の文字を一括置換 | [Lee Mac Programming](https://www.lee-mac.com/bfind.html) |
| c2dwg | Copy to Drawings | 図形を複数図面へコピー | [Lee Mac Programming](https://www.lee-mac.com/copytodrawing.html) |
| C2X | Copy to XRef | 図形を外部参照図面へコピー | [Lee Mac Programming](https://www.lee-mac.com/copytoxref.html) |
| IB | Import Block | 他図面からブロックを読込み | [Lee Mac Programming](https://www.lee-mac.com/copyblockfromdrawing.html) |
| RXL | Reset XRef Layers | 外部参照画層を初期化 | [Lee Mac Programming](https://www.lee-mac.com/resetxreflayers.html) |
| WScript | Script Writer | 複数図面用スクリプト作成 | [Lee Mac Programming](https://www.lee-mac.com/scriptwriter.html) |
| Steal / StealAll / StealLast / StealTemplate / StealTemplates | Steal from Drawing | 他図面から定義を取り込み | [Lee Mac Programming](https://www.lee-mac.com/steal.html) |
| - | PURGEB.LSP | 未参照ブロックを一括パージ | [ManuSoft](https://www.manusoft.com/resources/freebies/lisp/)（Owen Wengerd (ManuSoft)） |
| - | SuperPurge | 強力パージで不要データ削除(ARX) | [ManuSoft](https://www.manusoft.com/resources/apps/)（Owen Wengerd (ManuSoft)） |
| - | DWGguard TNT (DWGguardTNT.zip) | 図面の変更を防止 | [draftsperson.net](https://draftsperson.net/lisproutines/DWGguardTNT.zip) |

<a id="13座標測量土木"></a>
## 座標・測量・土木（51件）

| コマンド | 名前 | 何をするツールか | 作者・サイト |
|---|---|---|---|
| COORDLBL | CoordinateLabeler.lsp | 点の座標を引出線で表示 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| GRIDGEN | GridGenerator.lsp | 座標グリッドを生成 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| LBLSEG | LabelPolySegments.lsp | ポリライン各辺の長さ・方位記入 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| PNTCSV | PointImportCSV.lsp | CSVから座標点を読込 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| QSECTION | QuickSection.lsp | 標高点から断面線を作成 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| SLOPE | SlopeCalculator.lsp | 2点間の勾配を計算 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| grd | XY Grid | 座標値付きXYグリッド作図 | [JTB World](https://jtbworld.com/justlisp)（Mark Beggs） |
| FL | FL | 線の長さと方位角を記入 | [JefferyPSanders.com](https://jefferypsanders.com/FL.lsp)（Jeffery P. Sanders） |
| GA | GetAcre | 面積を平方フィート・エーカー記入 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_examp.html)（Jeffery P. Sanders） |
| IMPORTXYZ | IMPORT XYZ | ファイルの座標を点・ブロック化 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_IMPORTXYZ.html)（Jeffery P. Sanders） |
| - | Rolling_ball | 2本のポリラインの中心線を求める | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_Rollin.html)（Jeffery P. Sanders） |
| SAG | Sag | 電線のたるみを3D作図 | [JefferyPSanders.com](https://jefferypsanders.com/SAG.LSP)（Jeffery P. Sanders） |
| Surveyor | Surveyor | Excel・CSVから測点を挿入 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_Surveyor.html)（Jeffery P. Sanders） |
| PtManager / PtM | Point Manager | 点座標の読込み・書出し | [Lee Mac Programming](https://www.lee-mac.com/ptmanager.html) |
| - | DIMPL.ZIP | 境界線の方位・距離を記入 | [ManuSoft](https://www.manusoft.com/resources/freebies/lisp/)（Owen Wengerd (ManuSoft)） |
| - | Bearing and Distance Note (civil.zip) | 2点間の方位・距離を注記 | [draftsperson.net](https://draftsperson.net/lisproutines/civil.zip) |
| - | Boundary Line with Bearing (civili.zip) | 境界線を作図し方位距離を記入 | [draftsperson.net](https://draftsperson.net/lisproutines/civili.zip) |
| - | Distance and Bearing Label (distbear.zip) | 線分の距離・方位ラベル作成 | [draftsperson.net](https://draftsperson.net/lisproutines/distbear.zip) |
| - | Lot Number (LONTO.LSP) | 区画番号記入(説明なし) | [draftsperson.net](https://draftsperson.net/lisproutines/LONTO.LSP) |
| - | Slope Bank Symbol (BANK.LSP) | 法面記号を作図 | [draftsperson.net](https://draftsperson.net/lisproutines/BANK.LSP) |
| - | Traverse Note Reduction (traver.zip) | トラバース計算 | [draftsperson.net](https://draftsperson.net/lisproutines/traver.zip) |
| CHANGENT | CHAINAGE.LSP | 線形の接点マークを作図 | [gilesdarling.me.uk](http://www.gilesdarling.me.uk/lisproutines.shtml#chainagelsp)（Giles Darling） |
| CHEGMENT | CHAINAGE.LSP | 直線長・半径を注記 | [gilesdarling.me.uk](http://www.gilesdarling.me.uk/lisproutines.shtml#changent)（Giles Darling） |
| CHMARK | CHAINAGE.LSP | 指定点に測点マーク作図 | [gilesdarling.me.uk](http://www.gilesdarling.me.uk/lisproutines.shtml#chmark)（Giles Darling） |
| CHMARKS | CHAINAGE.LSP | 等間隔に測点マーク作図 | [gilesdarling.me.uk](http://www.gilesdarling.me.uk/lisproutines.shtml#chmark)（Giles Darling） |
| CHXSECT | CHAINAGE.LSP | 指定点に横断線を作図 | [gilesdarling.me.uk](http://www.gilesdarling.me.uk/lisproutines.shtml#chxsect)（Giles Darling） |
| CHXSECTS | CHAINAGE.LSP | 等間隔に横断線を作図 | [gilesdarling.me.uk](http://www.gilesdarling.me.uk/lisproutines.shtml#chxsect)（Giles Darling） |
| CHOFFSET | CHAINAGE.LSP | 点の測点・オフセット取得 | [gilesdarling.me.uk](http://www.gilesdarling.me.uk/lisproutines.shtml#choffset)（Giles Darling） |
| CHOFFSETS | CHAINAGE.LSP | 複数点の測点・オフセット取得 | [gilesdarling.me.uk](http://www.gilesdarling.me.uk/lisproutines.shtml#choffset)（Giles Darling） |
| CHSETOUT | CHAINAGE.LSP | 線形の設置情報を出力 | [gilesdarling.me.uk](http://www.gilesdarling.me.uk/lisproutines.shtml#chsetout)（Giles Darling） |
| COLOURBYX | COLOURBY.LSP | X座標で点を色分け | [gilesdarling.me.uk](http://www.gilesdarling.me.uk/lisproutines.shtml#colourbyx)（Giles Darling） |
| COLOURBYY | COLOURBY.LSP | Y座標で点を色分け | [gilesdarling.me.uk](http://www.gilesdarling.me.uk/lisproutines.shtml#colourbyy)（Giles Darling） |
| COLOURBYZ | COLOURBY.LSP | Z座標(標高)で色分け | [gilesdarling.me.uk](http://www.gilesdarling.me.uk/lisproutines.shtml#colourbyz)（Giles Darling） |
| COLOURBYCHART | COLOURBY.LSP | 色分け凡例を作図 | [gilesdarling.me.uk](http://www.gilesdarling.me.uk/lisproutines.shtml#colourbychart)（Giles Darling） |
| COLOURBYSET | COLOURBY.LSP | 色分け設定を変更 | [gilesdarling.me.uk](http://www.gilesdarling.me.uk/lisproutines.shtml#colourbychart)（Giles Darling） |
| COLOURBYRESET | COLOURBY.LSP | 色分け設定を初期化 | [gilesdarling.me.uk](http://www.gilesdarling.me.uk/lisproutines.shtml#colourbychart)（Giles Darling） |
| TPOPTRIA | TOPOPROCESS.LSP | 3D点からTIN三角網を作成 | [gilesdarling.me.uk](http://www.gilesdarling.me.uk/lisproutines.shtml#tpoptria)（Giles Darling） |
| TPOPSWAP | TOPOPROCESS.LSP | 隣接三角形の共有辺を入替 | [gilesdarling.me.uk](http://www.gilesdarling.me.uk/lisproutines.shtml#tpopswap)（Giles Darling） |
| TPOPGETTHIN | TOPOPROCESS.LSP | 三角形の扁平率範囲を取得 | [gilesdarling.me.uk](http://www.gilesdarling.me.uk/lisproutines.shtml#tpopthin)（Giles Darling） |
| TPOPDELTHIN | TOPOPROCESS.LSP | 扁平な三角形を削除 | [gilesdarling.me.uk](http://www.gilesdarling.me.uk/lisproutines.shtml#tpopthin)（Giles Darling） |
| TPOPSOLID | TOPOPROCESS.LSP | 三角網から段彩SOLID作成 | [gilesdarling.me.uk](http://www.gilesdarling.me.uk/lisproutines.shtml#tpopsolid)（Giles Darling） |
| TPOPCONT | TOPOPROCESS.LSP | 三角網から等高線を作成 | [gilesdarling.me.uk](http://www.gilesdarling.me.uk/lisproutines.shtml#tpopcont)（Giles Darling） |
| TPOPCONTLABEL | TOPOPROCESS.LSP | 等高線に標高ラベル記入 | [gilesdarling.me.uk](http://www.gilesdarling.me.uk/lisproutines.shtml#tpopcont)（Giles Darling） |
| TPOPSLOPEMAX | TOPOPROCESS.LSP | 最大勾配と方向を記入 | [gilesdarling.me.uk](http://www.gilesdarling.me.uk/lisproutines.shtml#tpopslope)（Giles Darling） |
| TPOPSLOPEDIR | TOPOPROCESS.LSP | 指定方向の勾配を記入 | [gilesdarling.me.uk](http://www.gilesdarling.me.uk/lisproutines.shtml#tpopslope)（Giles Darling） |
| TPOPLEVEL | TOPOPROCESS.LSP | 指定点のスポット標高記入 | [gilesdarling.me.uk](http://www.gilesdarling.me.uk/lisproutines.shtml#tpoplevel)（Giles Darling） |
| TPOPMULZ | TOPOPROCESS.LSP | 点のZ値を倍率変換 | [gilesdarling.me.uk](http://www.gilesdarling.me.uk/lisproutines.shtml#tpoplevel)（Giles Darling） |
| TPOPVOL | TOPOPROCESS.LSP | 三角網の体積を計算 | [gilesdarling.me.uk](http://www.gilesdarling.me.uk/lisproutines.shtml#tpopvol)（Giles Darling） |
| TPOPINTERS | TOPOPROCESS.LSP | 2つの三角網の交線を作図 | [gilesdarling.me.uk](http://www.gilesdarling.me.uk/lisproutines.shtml#tpopvol)（Giles Darling） |
| TPOPSETFUZZ | TOPOPROCESS.LSP | 計算の許容誤差を設定 | [gilesdarling.me.uk](http://www.gilesdarling.me.uk/lisproutines.shtml#tpopfuzz)（Giles Darling） |
| VCURV | VCURV.LSP | 縦断曲線を作図 | [gilesdarling.me.uk](http://www.gilesdarling.me.uk/lisproutines.shtml#vcurv)（Giles Darling） |

<a id="14建築"></a>
## 建築（27件）

| コマンド | 名前 | 何をするツールか | 作者・サイト |
|---|---|---|---|
| - | AecExportToAutoCAD.lsp | AEC書出し設定の読書き | [JTB World](https://jtbworld.com/autocad-aecexporttoautocad-lsp)（JTB World (Jimmy Bergmark)） |
| - | AECObjectsExplodeOptions.lsp | AEC分解設定の読書き | [JTB World](https://jtbworld.com/autocad-aecobjectsexplodeoptions-lsp)（JTB World (Jimmy Bergmark)） |
| em | Elevation Marker | レベル（標高）マーカーを配置 | [Lee Mac Programming](https://www.lee-mac.com/elevationmarker.html) |
| - | 2D Door (2DDOOR.LSP) | 2Dドアを平面図に作図 | [draftsperson.net](https://draftsperson.net/lisproutines/2DDOOR.LSP) |
| - | 2D Door (Door.rar) | 2Dドアを平面図に作図 | [draftsperson.net](https://draftsperson.net/lisproutines/Door.rar) |
| - | 2D Window (2DWIN.LSP) | 2D窓を平面図に作図 | [draftsperson.net](https://draftsperson.net/lisproutines/2DWIN.LSP) |
| - | Architectural LISP Set (archlisp.zip) | 建築用LISP集(ドア・天井等) | [draftsperson.net](https://draftsperson.net/lisproutines/archlisp.zip) |
| - | Batt Insulation (Batt.rar) | 断熱材(バット)記号を作図 | [draftsperson.net](https://draftsperson.net/lisproutines/Batt.rar) |
| - | Batt Insulation 3 (Batt3.rar) | 断熱材(バット)記号を作図 | [draftsperson.net](https://draftsperson.net/lisproutines/Batt3.rar) |
| - | Building Entities (Building.rar) | ドア・窓など建築要素を作図 | [draftsperson.net](https://draftsperson.net/lisproutines/Building.rar) |
| - | Cabinet Faces (cabine.zip) | キャビネット正面をパラメトリック作図 | [draftsperson.net](https://draftsperson.net/lisproutines/cabine.zip) |
| - | Casement Window (casement.zip) | 開き窓を作図 | [draftsperson.net](https://draftsperson.net/lisproutines/casement.zip) |
| - | Ceiling Grid (Ceiling.rar) | 天井グリッドを作図 | [draftsperson.net](https://draftsperson.net/lisproutines/Ceiling.rar) |
| - | Centered Ceiling Grid (cgrid.zip) | 部屋中心の天井グリッドを作図 | [draftsperson.net](https://draftsperson.net/lisproutines/cgrid.zip) |
| - | Cusson Windows (Cusson.rar) | 各種スタイルの窓を作図 | [draftsperson.net](https://draftsperson.net/lisproutines/Cusson.rar) |
| - | Door Swing with Wall Trim (doorac.zip) | ドア開きを作図し壁をトリム | [draftsperson.net](https://draftsperson.net/lisproutines/doorac.zip) |
| - | DT Wall (DTWall.rar) | 壁タイプ付きの壁を作図 | [draftsperson.net](https://draftsperson.net/lisproutines/DTWall.rar) |
| - | Interior Elevation Utilities (int.zip) | 展開図(内観立面)作図ツール | [draftsperson.net](https://draftsperson.net/lisproutines/int.zip) |
| - | Rafter and Roof Truss (rafter.zip) | 垂木・屋根トラスを作図 | [draftsperson.net](https://draftsperson.net/lisproutines/rafter.zip) |
| - | Roof Pitch (Roofpitch.rar) | 屋根勾配を作図 | [draftsperson.net](https://draftsperson.net/lisproutines/Roofpitch.rar) |
| - | Spiral Staircase (Spst.rar) | 螺旋階段を自動作図 | [draftsperson.net](https://draftsperson.net/lisproutines/Spst.rar) |
| - | Stair Calculator (staircal.zip) | 階段の蹴上・踏面を計算 | [draftsperson.net](https://draftsperson.net/lisproutines/staircal.zip) |
| - | Wall Section (wallsect.rar) | 壁断面を作図 | [draftsperson.net](https://draftsperson.net/lisproutines/wallsect.rar) |
| - | Wall Sections (WallDemo.zip) | 壁断面を作図 | [draftsperson.net](https://draftsperson.net/lisproutines/WallDemo.zip) |
| - | Walls in Plan (walls.zip) | 平面の壁を作図 | [draftsperson.net](https://draftsperson.net/lisproutines/walls.zip) |
| - | Window Elevations (windows.zip) | 上げ下げ窓の立面を作図 | [draftsperson.net](https://draftsperson.net/lisproutines/windows.zip) |
| - | Windows with Mullions (win12.rar) | 方立付き窓を平面に作図 | [draftsperson.net](https://draftsperson.net/lisproutines/win12.rar) |

<a id="15設備"></a>
## 設備（空調・衛生・電気・配管）（4件）

| コマンド | 名前 | 何をするツールか | 作者・サイト |
|---|---|---|---|
| - | LITIO | ダクト・板金の展開図作成 | [AutoLISP Exchange](http://www.litio3d.com.ar)（Juan Lavric） |
| L2PIPE | LineToPipe.lsp | 線を二重線の配管に変換 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| PIPELAY | PipeLay | 配管分岐の切断展開図作成 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_pipe.html)（Jeffery P. Sanders） |
| - | HVAC Suite (HVAC Suite.rar) | 空調設計LISP・ブロック集 | [draftsperson.net](https://draftsperson.net/lisproutines/HVAC%20Suite.rar) |

<a id="16構造鉄骨機械"></a>
## 構造・鉄骨・機械（22件）

| コマンド | 名前 | 何をするツールか | 作者・サイト |
|---|---|---|---|
| ch | Chain | チェーン形状を作図 | [JTB World](https://jtbworld.com/justlisp)（Mark Beggs） |
| CHAIN | CHAIN | 点指定でチェーンを作図 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_CHAIN.html)（Jeffery P. Sanders） |
| SLOT | Slot | 塗潰し長穴を作図 | [JefferyPSanders.com](https://jefferypsanders.com/SLOT.LSP)（Jeffery P. Sanders） |
| WEIGHT | Weight | 面積と厚さ・材質から重量計算 | [JefferyPSanders.com](https://jefferypsanders.com/WEIGHT.zip)（Jeffery P. Sanders） |
| - | BCAL.LSP (Bend Calculator) | 板金の曲げ代を計算 | [ManuSoft](https://www.manusoft.com/resources/freebies/lisp/)（Owen Wengerd (ManuSoft)） |
| - | BDEV.LSP (Bend Developer) | 板金の展開長を計算 | [ManuSoft](https://www.manusoft.com/resources/freebies/lisp/)（Owen Wengerd (ManuSoft)） |
| - | AISC Steel Shapes (steel2.zip) | AISC鋼材断面を作図 | [draftsperson.net](https://draftsperson.net/lisproutines/steel2.zip) |
| - | Autoweld (autoweld.zip) | 溶接記号を作図(メニュー付) | [draftsperson.net](https://draftsperson.net/lisproutines/autoweld.zip) |
| - | AWelds 4 (awelds4.zip) | 溶接記号を作図(メニュー付) | [draftsperson.net](https://draftsperson.net/lisproutines/awelds4.zip) |
| - | Bolt Head (bolthead.lsp) | ボルト頭(六角)を作図 | [draftsperson.net](https://draftsperson.net/lisproutines/bolthead.lsp) |
| - | Floor Joist and Steel Beam (flrjst.zip) | 床根太・鋼製梁を作図 | [draftsperson.net](https://draftsperson.net/lisproutines/flrjst.zip) |
| - | Floor Truss Elevations (truss.zip) | 床トラス立面をパラメトリック作図 | [draftsperson.net](https://draftsperson.net/lisproutines/truss.zip) |
| - | Mechanical Lisp Collection (Mech2lsp.zip) | 機械製図用(穴・ねじ穴)集 | [draftsperson.net](https://draftsperson.net/lisproutines/Mech2lsp.zip) |
| - | Sheet Metal Toolkit (smver7.zip) | 板金展開・加工計算ツール | [draftsperson.net](https://draftsperson.net/lisproutines/smver7.zip) |
| - | Slot in Circle (slot.zip) | 円に長穴を切る | [draftsperson.net](https://draftsperson.net/lisproutines/slot.zip) |
| - | Stair Stringers (Stair.rar) | 階段ささら桁を作図・寸法記入 | [draftsperson.net](https://draftsperson.net/lisproutines/Stair.rar) |
| - | Steel (STL) (stl.lsp) | 鋼材形状を作図 | [draftsperson.net](https://draftsperson.net/lisproutines/stl.lsp) |
| SS | Steel Shapes (SS) (Steel.rar) | 鋼材形状をダイアログで作図 | [draftsperson.net](https://draftsperson.net/lisproutines/Steel.rar) |
| - | Steel Shapes (Steelshapes.rar) | 鋼材形状を作図 | [draftsperson.net](https://draftsperson.net/lisproutines/Steelshapes.rar) |
| - | Steel Stair Pans (ssp_v25.zip) | 鋼製階段の段板を作図 | [draftsperson.net](https://draftsperson.net/lisproutines/ssp_v25.zip) |
| - | Truss (Truss.rar) | トラスを作図 | [draftsperson.net](https://draftsperson.net/lisproutines/Truss.rar) |
| - | Truss Types (truss2.zip) | 各種形式のトラスを作図 | [draftsperson.net](https://draftsperson.net/lisproutines/truss2.zip) |

<a id="17_3D"></a>
## 3D（7件）

| コマンド | 名前 | 何をするツールか | 作者・サイト |
|---|---|---|---|
| ZFIX | Z-BufferFix.lsp | Zファイティングのちらつき解消 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| CYL | CYL | 中空の3D円筒・角筒を作成 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_cyl.html)（Jeffery P. Sanders） |
| 2dpro | 2D Projection | 3D図形を2D平面に投影 | [Lee Mac Programming](https://www.lee-mac.com/2dprojection.html) |
| - | 3D Cabinet (3dcabn.zip) | 3Dキャビネットを作図 | [draftsperson.net](https://draftsperson.net/lisproutines/3dcabn.zip) |
| - | 3D LISP Set (3dlisp.rar) | 3D作図ルーチン集 | [draftsperson.net](https://draftsperson.net/lisproutines/3dlisp.rar) |
| - | Extrude with Profile Backup (extrude_p.lsp) | 断面を残して押し出し | [draftsperson.net](https://draftsperson.net/lisproutines/extrude_p.lsp) |
| - | Home Design 3D (Evaluation) (3dhome.zip) | 住宅3D設計ソフト評価版 | [draftsperson.net](https://draftsperson.net/lisproutines/3dhome.zip) |

<a id="18表示UCSビュー"></a>
## 表示・UCS・ビュー（5件）

| コマンド | 名前 | 何をするツールか | 作者・サイト |
|---|---|---|---|
| DOCOLOR | DrawOrderByColor.lsp | 色ごとに表示順を設定 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| ExportViews / ImportViews | viewsIO.LSP | ビューの書出し・読込み | [JTB World](https://jtbworld.com/autocad-viewsio-lsp)（JTB World (Jimmy Bergmark)） |
| zoome | zoome.lsp | 全ビューポートで範囲ズーム | [JTB World](https://jtbworld.com/autocad-zoome-lsp)（JTB World (Jimmy Bergmark)） |
| cr | Cursor Rotate | カーソル角度を図形に合わせる | [Lee Mac Programming](https://www.lee-mac.com/cursorrotate.html) |
| - | Periscope | カーソル下の図形情報を表示(ARX) | [ManuSoft](https://www.manusoft.com/resources/apps/)（Owen Wengerd (ManuSoft)） |

<a id="19設定環境"></a>
## 設定・環境（19件）

| コマンド | 名前 | 何をするツールか | 作者・サイト |
|---|---|---|---|
| - | acad.lsp | acad.lspの使い方解説 | [JTB World](https://jtbworld.com/acad-lsp)（JTB World (Jimmy Bergmark)） |
| - | acaddoc.lsp | acaddoc.lspの使い方解説 | [JTB World](https://jtbworld.com/acaddoc-lsp)（JTB World (Jimmy Bergmark)） |
| BGGrey / BGWhite / BGBlack / bgt | backgroundchanger.lsp | 背景色を切替え | [JTB World](https://jtbworld.com/autocad-backgroundchanger-lsp)（JTB World (Jimmy Bergmark)） |
| SetModelColor / SetLayoutColor | DisplayColorProperties.lsp | 表示色オプションを設定 | [JTB World](https://jtbworld.com/autocad-displaycolorproperties-lsp)（JTB World (Jimmy Bergmark)） |
| - | DisplayProperties.lsp | 表示タブ設定の操作 | [JTB World](https://jtbworld.com/autocad-displayproperties-lsp)（JTB World (Jimmy Bergmark)） |
| cmdhistlines | historylines.lsp | コマンド履歴行数を変更 | [JTB World](https://jtbworld.com/autocad-historylines-lsp)（JTB World (Jimmy Bergmark)） |
| JTB_SetTitleBarAutoCAD2005 他 | JTB_TitleBar.lsp | タイトルバー表示を変更 | [JTB World](https://jtbworld.com/autocad-jtb-titlebar-lsp)（JTB World (Jimmy Bergmark)） |
| - | osnapz | OSNAPZで画面色を切替え | [JTB World](http://blog.jtbworld.com/2009/03/change-autocad-screen-background-color.html)（JTB World (Jimmy Bergmark)） |
| listProfileNames | profiles.lsp | プロファイル操作 | [JTB World](https://jtbworld.com/autocad-profiles-lsp)（JTB World (Jimmy Bergmark)） |
| - | ProjectPaths.lsp | プロジェクトパスの操作 | [JTB World](https://jtbworld.com/autocad-projectpaths-lsp)（JTB World (Jimmy Bergmark)） |
| - | remicons.lsp | 開くダイアログのアイコン削除 | [JTB World](https://jtbworld.com/autocad-remicons-lsp)（JTB World (Jimmy Bergmark)） |
| saveSupportPaths / loadSupportPaths | supportPaths.lsp | サポートパスを保存・読込み | [JTB World](https://jtbworld.com/autocad-supportpaths-lsp)（JTB World (Jimmy Bergmark)） |
| ALIAS | ALIAS | コマンド短縮名をその場で定義 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_alias.html)（Jeffery P. Sanders） |
| LoadLSP | LoadLSP | 説明付きLISPローダー | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_LOADLSP.html)（Jeffery P. Sanders） |
| acaddoc | acaddoc.lsp Creator | acaddoc.lspを自動生成 | [Lee Mac Programming](https://www.lee-mac.com/acaddoccreator.html) |
| customcommands | Custom Commands | ロード済LISPコマンド一覧 | [Lee Mac Programming](https://www.lee-mac.com/customcommands.html) |
| - | Tip of the Day | 起動時に今日のヒント表示 | [Lee Mac Programming](https://www.lee-mac.com/tipoftheday.html) |
| - | QuikPik | ピックミス防止などUI改善(ARX) | [ManuSoft](https://www.manusoft.com/resources/apps/)（Owen Wengerd (ManuSoft)） |
| - | Units Precision Editor (epu.lsp) | 単位精度を変更 | [draftsperson.net](https://draftsperson.net/lisproutines/epu.lsp) |

<a id="20開発ライブラリ"></a>
## LISP開発用の部品（関数ライブラリ）（119件）

| コマンド | 名前 | 何をするツールか | 作者・サイト |
|---|---|---|---|
| Dcl_Tiles / DclT | Dcl_Tiles | DCLダイアログ制御関数集 | [AutoLISP Exchange](https://autolisp-exchange.com/LISP/Dcl_Tiles.lsp)（Terry Miller） |
| - | DclDemo06 | DCLダイアログのデモ | [AutoLISP Exchange](https://autolisp-exchange.com/Other/DclDemo06.zip)（Phillip Norman） |
| ShowIcons / GetIcon / GetButtons | GetIcon | アイコン付メッセージダイアログ | [AutoLISP Exchange](https://autolisp-exchange.com/LISP/GetIcon.lsp)（Terry Miller） |
| GV / VV / IA | GetVectors | 図形からDCL用画像を作成 | [AutoLISP Exchange](https://autolisp-exchange.com/LISP/GetVectors.lsp)（Terry Miller） |
| LspCom / DclCom | LspCom | LISP・DCLファイルを圧縮 | [AutoLISP Exchange](https://autolisp-exchange.com/LISP/LspCom.lsp)（Terry Miller） |
| - | MatInv | 連想リスト関数集 | [AutoLISP Exchange](https://autolisp-exchange.com/Other/MatInv.lsp)（Tihomir Bojanic） |
| My | MyDialogs (Dcl tutorial) | DCLダイアログ入門サンプル | [AutoLISP Exchange](https://autolisp-exchange.com/Tutorials/MyDialogs.htm)（Terry Miller） |
| PB-Demo | ProgressBar | プログレスバー表示関数 | [AutoLISP Exchange](https://autolisp-exchange.com/LISP/ProgressBar.lsp)（Terry Miller） |
| Search / Sea | Search | フォルダ内ファイルを文字検索 | [AutoLISP Exchange](https://autolisp-exchange.com/LISP/Search.lsp)（Terry Miller） |
| ViewDcl / Dcl | ViewDcl | DCLダイアログをプレビュー | [AutoLISP Exchange](https://autolisp-exchange.com/LISP/ViewDcl.lsp)（Terry Miller） |
| - | Win_Sort | Windows順ファイル名ソート関数 | [AutoLISP Exchange](https://autolisp-exchange.com/LISP/Win_Sort.lsp)（Terry Miller） |
| - | acetutil (Express acet functions doc) | Express acet関数の解説 | [JTB World](http://www.jtbworld.com/download/acetutil.zip)（JTB World (Jimmy Bergmark)） |
| - | axBlock.LSP | ブロック・属性操作関数集 | [JTB World](https://jtbworld.com/autocad-axblock-lsp)（JTB World (Jimmy Bergmark)） |
| - | axCreateVP.LSP | ビューポート作成関数 | [JTB World](https://jtbworld.com/autocad-axcreatevp-lsp)（JTB World (Jimmy Bergmark)） |
| - | axInsert.lsp | ActiveXでブロック挿入例 | [JTB World](https://jtbworld.com/autocad-axinsert-lsp)（JTB World (Jimmy Bergmark)） |
| - | linetype.LSP | 線種ロード・存在確認関数 | [JTB World](https://jtbworld.com/autocad-linetype-lsp)（JTB World (Jimmy Bergmark)） |
| - | wcmatch | wcmatch関数の解説 | [JTB World](https://jtbworld.com/autocad-autolisp-wcmatch)（JTB World (Jimmy Bergmark)） |
| - | AlgaCAD | 図面変数を埋めるLISPを生成 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_algacad.html)（Jeffery P. Sanders） |
| CREATOR | CREATOR | LISPプログラムを自動生成 | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_creator.html)（Jeffery P. Sanders） |
| - | Make_LSP | 対話式LISP生成（旧版） | [JefferyPSanders.com](https://jefferypsanders.com/autolisp.html)（Jeffery P. Sanders） |
| - | srtAN | 英数字ソート関数 | [JefferyPSanders.com](https://jefferypsanders.com/srtan.lsp)（Jeffery P. Sanders） |
| - | 3-Point Circle & Arc Functions | 3点円・円弧計算関数 | [Lee Mac Programming](https://www.lee-mac.com/3pointarccircle.html) |
| - | 5-Point Ellipse | 5点楕円計算関数 | [Lee Mac Programming](https://www.lee-mac.com/5pointellipse.html) |
| - | ActiveSpace | アクティブ空間取得関数 | [Lee Mac Programming](https://www.lee-mac.com/activespace.html) |
| - | Add & Remove Support File Search Paths | サポートパス追加・削除関数 | [Lee Mac Programming](https://www.lee-mac.com/addremovesupportpaths.html) |
| - | Apply to Block Objects | ブロック内図形へ関数適用 | [Lee Mac Programming](https://www.lee-mac.com/applytoblockobjects.html) |
| - | Assoc++ Functions | 連想リスト操作関数 | [Lee Mac Programming](https://www.lee-mac.com/assocplusplus.html) |
| - | Attribute Functions | 属性値の取得・設定関数 | [Lee Mac Programming](https://www.lee-mac.com/attributefunctions.html) |
| - | Base Conversion Functions | 基数変換関数 | [Lee Mac Programming](https://www.lee-mac.com/baseconversion.html) |
| - | Bounding Box | 外接矩形取得関数 | [Lee Mac Programming](https://www.lee-mac.com/boundingbox.html) |
| - | Browse for Folder | フォルダ選択ダイアログ関数 | [Lee Mac Programming](https://www.lee-mac.com/directorydialog.html) |
| - | Bulge Conversion Functions | バルジ変換関数 | [Lee Mac Programming](https://www.lee-mac.com/bulgeconversion.html) |
| - | Clockwise-p | 時計回り判定関数 | [Lee Mac Programming](https://www.lee-mac.com/clockwisep.html) |
| - | Collection Functions | コレクション操作関数 | [Lee Mac Programming](https://www.lee-mac.com/collectionfunctions.html) |
| - | Colour Conversion Functions | 色形式変換関数 | [Lee Mac Programming](https://www.lee-mac.com/colourconversion.html) |
| - | Column Reference Functions | Excel列番号変換関数 | [Lee Mac Programming](https://www.lee-mac.com/columnreference.html) |
| - | Consistent rtos | 実数文字列変換関数 | [Lee Mac Programming](https://www.lee-mac.com/consistentrtos.html) |
| - | Convex Hull | 凸包計算関数 | [Lee Mac Programming](https://www.lee-mac.com/convexhull.html) |
| - | Copy Block Definition | ブロック定義コピー関数 | [Lee Mac Programming](https://www.lee-mac.com/copyblockdefinition.html) |
| - | Copy Folder | フォルダコピー関数 | [Lee Mac Programming](https://www.lee-mac.com/copyfolder.html) |
| - | Create Directory | フォルダ作成関数 | [Lee Mac Programming](https://www.lee-mac.com/createdirectory.html) |
| - | DCL List Tile Dependency | DCLリスト連動関数 | [Lee Mac Programming](https://www.lee-mac.com/listtiledependency.html) |
| - | Directory Files | フォルダ内ファイル取得関数 | [Lee Mac Programming](https://www.lee-mac.com/getallfiles.html) |
| - | Draw Order Functions | 表示順序操作関数 | [Lee Mac Programming](https://www.lee-mac.com/draworderfunctions.html) |
| - | Drawing Version | 図面バージョン取得関数 | [Lee Mac Programming](https://www.lee-mac.com/drawingversion.html) |
| dump / dumpn | Dump Object | オブジェクトのプロパティ一覧 | [Lee Mac Programming](https://www.lee-mac.com/dumpobject.html) |
| - | Dynamic Block Functions | ダイナミックブロック操作関数 | [Lee Mac Programming](https://www.lee-mac.com/dynamicblockfunctions.html) |
| - | Edit Box | 入力ボックス関数 | [Lee Mac Programming](https://www.lee-mac.com/editbox.html) |
| - | Effective Block Name | 実効ブロック名取得関数 | [Lee Mac Programming](https://www.lee-mac.com/effectivename.html) |
| ee / eex | Entity List | 図形DXFデータを表示 | [Lee Mac Programming](https://www.lee-mac.com/entitylist.html) |
| - | Entity to Point List | 図形を点リスト化する関数 | [Lee Mac Programming](https://www.lee-mac.com/entitytopointlist.html) |
| - | Environment Variable Functions | 環境変数操作関数 | [Lee Mac Programming](https://www.lee-mac.com/envvarfunctions.html) |
| - | Escape Wildcards | ワイルドカードエスケープ関数 | [Lee Mac Programming](https://www.lee-mac.com/escapewildcards.html) |
| - | Evaluate Once on Startup | 起動時一度だけ実行する関数 | [Lee Mac Programming](https://www.lee-mac.com/evalonce.html) |
| - | Explore | エクスプローラでフォルダを開く | [Lee Mac Programming](https://www.lee-mac.com/explore.html) |
| - | Field Code | フィールドコード取得関数 | [Lee Mac Programming](https://www.lee-mac.com/fieldcode.html) |
| - | Field Objects | フィールド参照図形取得関数 | [Lee Mac Programming](https://www.lee-mac.com/getfieldobjects.html) |
| - | Find File | ファイル検索関数 | [Lee Mac Programming](https://www.lee-mac.com/findfile.html) |
| - | Flatten List | リスト平坦化関数 | [Lee Mac Programming](https://www.lee-mac.com/flatten.html) |
| FormatDCL | Format DCL | DCLコードを整形 | [Lee Mac Programming](https://www.lee-mac.com/formatdcl.html) |
| - | Get Anonymous References | 匿名ブロック参照取得関数 | [Lee Mac Programming](https://www.lee-mac.com/getanonymousreferences.html) |
| - | Get Custom Commands | カスタムコマンド取得関数 | [Lee Mac Programming](https://www.lee-mac.com/getcustomcommands.html) |
| - | Get Files Dialog | 複数ファイル選択ダイアログ関数 | [Lee Mac Programming](https://www.lee-mac.com/getfilesdialog.html) |
| - | Get True Content | 書式除去した文字取得関数 | [Lee Mac Programming](https://www.lee-mac.com/gettruecontent.html) |
| - | Group List by Number | リストをN個ずつ分割する関数 | [Lee Mac Programming](https://www.lee-mac.com/groupbynum.html) |
| - | GrSnap | grread用スナップ関数 | [Lee Mac Programming](https://www.lee-mac.com/grsnap.html) |
| - | GrText | grdraw文字表示関数 | [Lee Mac Programming](https://www.lee-mac.com/grtext.html) |
| - | Insert Nth | リストN番目挿入関数 | [Lee Mac Programming](https://www.lee-mac.com/insertnth.html) |
| - | Intersection Functions | 交点計算関数 | [Lee Mac Programming](https://www.lee-mac.com/intersectionfunctions.html) |
| LISPLogON / LISPLogOFF | LISP Command Logger | LISPコマンド使用履歴を記録 | [Lee Mac Programming](https://www.lee-mac.com/lisplog.html) |
| - | LISP Styler | LISPコードをHTML色付け | [Lee Mac Programming](https://www.lee-mac.com/lispstyler.html) |
| - | List Box | リストボックス関数 | [Lee Mac Programming](https://www.lee-mac.com/listbox.html) |
| - | List Box Functions | リストボックス操作関数 | [Lee Mac Programming](https://www.lee-mac.com/listboxfunctions.html) |
| - | List Box with Filter | フィルタ付リストボックス関数 | [Lee Mac Programming](https://www.lee-mac.com/filtlistbox.html) |
| - | List Difference | リスト差集合関数 | [Lee Mac Programming](https://www.lee-mac.com/listdifference.html) |
| - | List Intersection | リスト積集合関数 | [Lee Mac Programming](https://www.lee-mac.com/listintersection.html) |
| - | List Symmetric Difference | リスト対称差関数 | [Lee Mac Programming](https://www.lee-mac.com/listsymdifference.html) |
| - | List to String | リスト文字列変換関数 | [Lee Mac Programming](https://www.lee-mac.com/listtostring.html) |
| - | List Union | リスト和集合関数 | [Lee Mac Programming](https://www.lee-mac.com/listunion.html) |
| - | Load Linetypes | 線種ロード関数 | [Lee Mac Programming](https://www.lee-mac.com/loadlinetype.html) |
| - | Mathematical Functions | 数学関数集 | [Lee Mac Programming](https://www.lee-mac.com/mathematicalfunctions.html) |
| - | Matrix Transformation Functions | 行列変換関数 | [Lee Mac Programming](https://www.lee-mac.com/matrixtransformationfunctions.html) |
| - | MD5 Cryptographic Hash Function | MD5ハッシュ関数 | [Lee Mac Programming](https://www.lee-mac.com/md5.html) |
| - | Minimum Bounding Box | 最小外接矩形関数 | [Lee Mac Programming](https://www.lee-mac.com/minboundingbox.html) |
| - | Minimum Enclosing Circle | 最小外接円計算関数 | [Lee Mac Programming](https://www.lee-mac.com/mecfunction.html) |
| - | ObjectDBX Wrapper | ObjectDBX一括処理関数 | [Lee Mac Programming](https://www.lee-mac.com/odbxbase.html) |
| - | Open | ファイルを関連付けで開く関数 | [Lee Mac Programming](https://www.lee-mac.com/open.html) |
| - | Ortho Point | 直交点計算関数 | [Lee Mac Programming](https://www.lee-mac.com/orthopoint.html) |
| - | Pad Between Strings | 文字列パディング関数 | [Lee Mac Programming](https://www.lee-mac.com/padbetween.html) |
| - | Parse Numbers | 文字列から数値抽出関数 | [Lee Mac Programming](https://www.lee-mac.com/parsenumbers.html) |
| - | Permutations | 順列生成関数 | [Lee Mac Programming](https://www.lee-mac.com/permutations.html) |
| - | Polygon Centroid | 多角形重心計算関数 | [Lee Mac Programming](https://www.lee-mac.com/polygoncentroid.html) |
| - | Popup | メッセージボックス関数 | [Lee Mac Programming](https://www.lee-mac.com/popup.html) |
| - | Print List | リストを整形出力 | [Lee Mac Programming](https://www.lee-mac.com/printlist.html) |
| - | Random Number Functions | 乱数生成関数 | [Lee Mac Programming](https://www.lee-mac.com/random.html) |
| - | Read CSV | CSV読込み関数 | [Lee Mac Programming](https://www.lee-mac.com/readcsv.html) |
| - | Release Object | オブジェクト解放関数 | [Lee Mac Programming](https://www.lee-mac.com/releaseobject.html) |
| - | Remove Items | リスト要素削除関数 | [Lee Mac Programming](https://www.lee-mac.com/removeitems.html) |
| - | Remove Nth | リストN番目削除関数 | [Lee Mac Programming](https://www.lee-mac.com/removenth.html) |
| - | Remove Once | リスト要素一回削除関数 | [Lee Mac Programming](https://www.lee-mac.com/removeonce.html) |
| - | Rounding Functions | 数値丸め関数 | [Lee Mac Programming](https://www.lee-mac.com/round.html) |
| - | Select If | 条件付き図形選択関数 | [Lee Mac Programming](https://www.lee-mac.com/selectif.html) |
| - | Selection Set Bounding Box | 選択セット外接矩形関数 | [Lee Mac Programming](https://www.lee-mac.com/ssboundingbox.html) |
| - | Selection Set to List | 選択セットのリスト化関数 | [Lee Mac Programming](https://www.lee-mac.com/selectionsettolist.html) |
| - | String Subst | 文字列置換関数 | [Lee Mac Programming](https://www.lee-mac.com/stringsubst.html) |
| - | String to List | 区切り文字列分割関数 | [Lee Mac Programming](https://www.lee-mac.com/stringtolist.html) |
| - | String Wrap | 文字列折返し関数 | [Lee Mac Programming](https://www.lee-mac.com/stringwrap.html) |
| - | Sublist | 部分リスト取得関数 | [Lee Mac Programming](https://www.lee-mac.com/sublist.html) |
| - | Subst Nth | リストN番目置換関数 | [Lee Mac Programming](https://www.lee-mac.com/substn.html) |
| - | Subst Once | リスト一回置換関数 | [Lee Mac Programming](https://www.lee-mac.com/substonce.html) |
| - | Text Case Functions | 大文字小文字変換関数 | [Lee Mac Programming](https://www.lee-mac.com/textcasefunctions.html) |
| - | UnFormat String | MTEXT書式除去関数 | [Lee Mac Programming](https://www.lee-mac.com/unformatstring.html) |
| - | Unique & Duplicate List Functions | 重複要素判定関数 | [Lee Mac Programming](https://www.lee-mac.com/uniqueduplicate.html) |
| - | Write CSV | CSV書出し関数 | [Lee Mac Programming](https://www.lee-mac.com/writecsv.html) |
| - | XRef Path Conversion | 外部参照パス変換関数 | [Lee Mac Programming](https://www.lee-mac.com/xrefpathconversion.html) |
| (DWGVer) (DWGtoACAD) | DWGVER.LSP | DWGファイルのバージョン判定 | [ManuSoft](https://www.manusoft.com/resources/freebies/lisp/)（Owen Wengerd (ManuSoft)） |
| - | ISX64.LSP | 64bit版AutoCAD判定コード | [ManuSoft](https://www.manusoft.com/resources/freebies/lisp/)（Owen Wengerd (ManuSoft)） |
| - | AutoLISP File Encryption (protxlsp.zip) | LISPファイルを暗号化 | [draftsperson.net](https://draftsperson.net/lisproutines/protxlsp.zip) |
| - | Learn (LEARN.LSP) | 操作からLISPコードを生成 | [draftsperson.net](https://draftsperson.net/lisproutines/LEARN.LSP) |

<a id="21その他"></a>
## その他（ゲーム・計算・便利小物）（46件）

| コマンド | 名前 | 何をするツールか | 作者・サイト |
|---|---|---|---|
| - | 66-55 (grdraw examples) | grdrawアニメーション例 | [AutoLISP Exchange](https://autolisp-exchange.com/Other/66-55.zip)（Paul Silva） |
| Cartoons | Cartoons | GetIcon用キャラクタアイコン | [AutoLISP Exchange](https://autolisp-exchange.com/LISP/Cartoons.lsp)（Terry Miller） |
| MAT | Cartoons.zip (slides) | マッチスライドゲーム用スライド | [AutoLISP Exchange](https://autolisp-exchange.com/LISP/Cartoons.zip)（Terry Miller） |
| Fractal | Fractal | 線分をフラクタル化 | [AutoLISP Exchange](https://autolisp-exchange.com/Other/Fractal.lsp)（Paul Silva） |
| - | kitoX Toolset | 無料ツールセット（外部サイト） | [AutoLISP Exchange](http://www.kitox.com)（kitoX） |
| AM | Messenger | ネットワーク上でメッセージ送受信 | [AutoLISP Exchange](https://autolisp-exchange.com/LISP/Messenger.lsp)（Terry Miller） |
| - | Puzzle | パズルゲーム | [AutoLISP Exchange](https://autolisp-exchange.com/Other/Puzzle.zip)（Paul Silva） |
| - | Roulette | ルーレットゲーム | [AutoLISP Exchange](https://autolisp-exchange.com/Other/Roulette.zip)（Paul Silva） |
| SayIt | SayIt | AutoCADに音声で話させる | [AutoLISP Exchange](https://autolisp-exchange.com/LISP/SayIt.lsp)（Terry Miller） |
| Troy | Troy | アステロイド風ゲーム | [AutoLISP Exchange](https://autolisp-exchange.com/LISP/Troy.lsp)（Terry Miller） |
| Troy | Troy-I | アステロイド風ゲーム（多言語版） | [AutoLISP Exchange](https://autolisp-exchange.com/LISP/Troy-I.lsp)（Terry Miller / Vladimir Michl） |
| GREY | GreyScaleDraw.lsp | 図形をグレースケール化 | [CAD Authority](https://cadauthority.com/download-free-autolisp-scripts/)（CADAuthority） |
| - | Bridges (game) | ブリッジゲーム | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_games.html)（Jeffery P. Sanders） |
| ERASNODE | ErasNode | 全ての点を削除 | [JefferyPSanders.com](https://jefferypsanders.com/ERASNODE.LSP)（Jeffery P. Sanders） |
| - | Memory (game) | 神経衰弱ゲーム | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_games.html)（Jeffery P. Sanders） |
| - | Slider (game) | スライドパズルゲーム | [JefferyPSanders.com](https://jefferypsanders.com/autolisp_games.html)（Jeffery P. Sanders） |
| lorenz | Attractors | ストレンジアトラクタを作図 | [Lee Mac Programming](https://www.lee-mac.com/attractors.html) |
| clock / runclock | Clock | 図面上に時計を表示 | [Lee Mac Programming](https://www.lee-mac.com/clock.html) |
| DInfo | Dynamic Information Tool | カーソル下図形情報を表示 | [Lee Mac Programming](https://www.lee-mac.com/dinfo.html) |
| jfract | Fractals | フラクタル図形を作図 | [Lee Mac Programming](https://www.lee-mac.com/fractals.html) |
| IFS | Iterated Function Systems | 反復関数系フラクタル作図 | [Lee Mac Programming](https://www.lee-mac.com/iteratedfunctionsystems.html) |
| koch | Koch Snowflake | コッホ雪片を作図 | [Lee Mac Programming](https://www.lee-mac.com/koch.html) |
| Logistic | Logistic Map | ロジスティック写像を作図 | [Lee Mac Programming](https://www.lee-mac.com/logisticmap.html) |
| Lotto | Lottery Numbers | ロト番号を生成 | [Lee Mac Programming](https://www.lee-mac.com/lotto.html) |
| Mastermind | Mastermind | マスターマインドゲーム | [Lee Mac Programming](https://www.lee-mac.com/mastermind.html) |
| LockObjects / UnlockObjects / DisableLock | Object Lock | 図形を編集不可にロック | [Lee Mac Programming](https://www.lee-mac.com/objectlock.html) |
| password | Password Generator | パスワード生成 | [Lee Mac Programming](https://www.lee-mac.com/password.html) |
| sierpinski / sierpinski3D | Sierpinski Triangle | シェルピンスキー三角形作図 | [Lee Mac Programming](https://www.lee-mac.com/sierpinski.html) |
| - | 90 LISP Routines (90lsp.zip) | LISP90本の詰め合わせ | [draftsperson.net](https://draftsperson.net/lisproutines/90lsp.zip) |
| - | Add (Calculator) (add.lsp) | 計算機 | [draftsperson.net](https://draftsperson.net/lisproutines/add.lsp) |
| - | Analogue Clock (clock.zip) | アナログ時計を表示 | [draftsperson.net](https://draftsperson.net/lisproutines/clock.zip) |
| - | Architectural Calculator (archcalc.zip) | フィート・インチ計算機 | [draftsperson.net](https://draftsperson.net/lisproutines/archcalc.zip) |
| - | Best of Lisp (Best Of Lisp.rar) | 便利LISP13本集 | [draftsperson.net](https://draftsperson.net/lisproutines/Best%20Of%20Lisp.rar) |
| - | BR Tools X (Brtoolsx.lsp) | 文字・点・切断などのツール集 | [draftsperson.net](https://draftsperson.net/lisproutines/Brtoolsx.lsp) |
| - | CAD Tools (CAD Tools.rar) | ボーナスツール集(文字・画層) | [draftsperson.net](https://draftsperson.net/lisproutines/CAD%20Tools.rar) |
| - | Calculator (calc.zip) | 画面上の電卓 | [draftsperson.net](https://draftsperson.net/lisproutines/calc.zip) |
| - | Drafting Tools (tools.zip) | 寸法・文字等の作図ツール集 | [draftsperson.net](https://draftsperson.net/lisproutines/tools.zip) |
| - | Grab Bag (grabbag.zip) | 画層・文字・ブロック等ツール集 | [draftsperson.net](https://draftsperson.net/lisproutines/grabbag.zip) |
| - | Handy Lisp (handylsp.zip) | 便利ルーチン詰め合わせ | [draftsperson.net](https://draftsperson.net/lisproutines/handylsp.zip) |
| - | Lisp Library (library.zip) | 文字・ポリライン編集等ツール集 | [draftsperson.net](https://draftsperson.net/lisproutines/library.zip) |
| - | Lisput Utilities (lisput.zip) | 切断・画層・集計等ツール集 | [draftsperson.net](https://draftsperson.net/lisproutines/lisput.zip) |
| - | LLP Site Lisp Collection (llpsite.rar) | 画層・文字・属性ツール集 | [draftsperson.net](https://draftsperson.net/lisproutines/llpsite.rar) |
| - | Master Toolbar Collection (master.zip) | 文字・画層編集ツールバー集 | [draftsperson.net](https://draftsperson.net/lisproutines/master.zip) |
| - | MBA Toolbar Collection (MBA.rar) | 汎用LISPツールバー集 | [draftsperson.net](https://draftsperson.net/lisproutines/MBA.rar) |
| - | Power Lisp Collection (Power.rar) | LISP統合パッケージ | [draftsperson.net](https://draftsperson.net/lisproutines/Power.rar) |
| - | Rock Lisp Collection (rocklsp2.zip) | ユーティリティ詰め合わせ | [draftsperson.net](https://draftsperson.net/lisproutines/rocklsp2.zip) |
