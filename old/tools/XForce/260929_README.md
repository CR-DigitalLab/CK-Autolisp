# XForce

分解できないブロックも強制的に分解する。チコさんが note で公開している LISP です。

| ファイル | 内容 |
|---|---|
| [XForce.lsp](XForce.lsp) | ver1（公開中の版。そのまま保存） |
| [XForce_ver2.lsp](XForce_ver2.lsp) | ver2（2026-09-29 に直した版） |

コマンド：XFORCE（XF）

## ver2 で直したこと

- 分解の途中でエラーになったとき、Undo グループを閉じるようにした
- 分解後の確認に使う関数を、AutoCAD の正式な名前（vlax-safearray-get-u-bound）に直した（ver1 の safearray-get-u-bound は BricsCAD にはあるが AutoCAD の資料に無く、AutoCAD では分解の直後に止まる可能性があった）
- 読み込んだときにコマンド名を表示するようにした

**ver1 から変わらないこと**：コマンド名・ショートカット・質問の順番・処理の結果（今使っている人が困らないように）。

## 動作確認

- テスト図面：[test/XForce_test.dxf](test/XForce_test.dxf)（`test/make_test_dxf.py` で作り直せます）
- 手順：[test/確認手順.md](test/確認手順.md)
- lispcheck での比較：[test/lispcheck結果/検証結果.md](test/lispcheck結果/検証結果.md)
