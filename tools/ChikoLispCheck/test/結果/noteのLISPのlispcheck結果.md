# note の無料 LISP 22本を lispcheck で動かした結果（2026-09-29）

テスト図面：`tools/YokeruText/test/YokeruText_test.dxf`（文字・線・寸法・ブロック・ハッチなど）。各コマンドで「最初の質問で Esc」「何も選ばず Enter」の2場面を実行。

## 本当の問題（AutoCAD でも起きる）

| LISP | 場面 | 内容 |
|---|---|---|
| RANDOMBNAME | 選択中に Esc | CMDECHO が 0 のまま残る（*error* が無いため） |
| SetAllPSLT | 値の入力で Esc | CMDECHO が 0 のまま残る（*error* が無いため） |
| CHAMFER+ | 最初の選択で Esc | 何もしなくても、図面の面取り距離（CHAMFERA・CHAMFERB）が変わる（0 のとき面幅15の初期値を入れる作り。意図どおりなら問題なし） |
| CHAMFER+ | 面取りの途中で Esc（コード目視） | *error* の Undo 終了の判定が `(= (getvar "UNDOCTL") 8)` のため、ほかのビットが立っていると Undo グループが閉じない。`(= 8 (logand (getvar "UNDOCTL") 8))` が正しい。また *error* の中は command-s が安全 |

上記以外（XForce、RegionToPL、FlattenFast、ClipCopy、CopyBlock、LPON・LPOFF、REVCLAUTO、SolidToHatch、BakClean、Web、CADSOZAI、Quake、ZeroByLayer など）は、Esc・選択なしでエラーにならず、システム変数も残らなかった（ZeroByLayer の CETRANSPARENCY などはコマンドの目的どおりの変更）。

## lispcheck の限界によるもの（AutoCAD では起きない）

| LISP | lispcheck での表示 | 理由 |
|---|---|---|
| AutoIME ver2・ver2.1 | 読み込みで stringp nil | lispcheck に環境変数 APPDATA が無い |
| ExportSysVars | stringp nil | lispcheck が `menucmd` の日時書式（edtime）を再現していない |
| LockAllVP | unknown name: layouts | lispcheck が Layouts（レイアウトの一覧）を再現していない |

## 普段の動き（正しく処理できるか）について

- lispcheck が再現できない AutoCAD のコマンド（CHAMFER・REVCLOUD・EXPLODE・PEDIT・HATCH・XCLIP・BROWSER など）や、リアクタ・インターネット・外部プログラムを使うものは、普段の動きを確かめられない。
- 公開済みで実際に使われているため、普段の動きの確認は優先度が低い。直すとき（互換性ルールに沿って、直す前と後を比べるとき）に、そのツール用のテスト図面を作って確かめる。
