# lispcheck — AutoLISP 動作検証ツール

AutoCAD が無い環境（クラウド・Linux）で AutoLISP を実際に動かし、
**図面(DXF)がどう変わったか／何が表示されたか／どこでエラーになったか** を確認するツールです。
`lispcheck.py` 1ファイルだけで動きます（Python 3.8 以上。画像出力には matplotlib）。

## Claude（AI）に使わせるとき
リポジトリに `lispcheck.py` を置き、次のように伝えてください。

> `python lispcheck.py guide` を読んで、作った LISP を lispcheck で検証してから渡して

## よく使う形
```
python lispcheck.py lint foo.lsp                         # 実行せずにチェック
python lispcheck.py info test.dxf --entities             # 図面の中身（ハンドル一覧）
python lispcheck.py run foo.lsp --dxf test.dxf --cmd FOO --in "[0,0]" --png
```
結果は `lispcheck_out/` に出ます（report.txt / result.dxf / compare.png）。元の DXF は上書きしません。

## できること・できないこと（概要）
- ほぼ AutoCAD 通り：基本関数、entget/entmod/entmake、ssget＋フィルタ、テーブル、拡張データ、*error* 処理
- 近似：vla-/vlax- 系、vlax-curve 系、command（代表的なコマンドのみ）、窓選択
- 未対応：DCL ダイアログ、リアクター、画面操作、ダイナミックブロック、Express Tools、.fas/.vlx

最終確認は必ず AutoCAD 実機で行ってください。
