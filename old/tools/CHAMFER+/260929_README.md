# CHAMFER+

面幅（斜めの長さ）を指定して面取りする。チコさんが note で公開している LISP です。

| ファイル | 内容 |
|---|---|
| [CHAMFER+.lsp](CHAMFER+.lsp) | ver1（公開中の版。そのまま保存） |
| [CHAMFER+_ver2.lsp](CHAMFER+_ver2.lsp) | ver2（2026-09-29 に直した版） |

コマンド：CHAMFER+（CF）

## ver2 で直したこと

- 面取りの途中で Esc・エラーになったとき、Undo グループが閉じないことがあった不具合を直した（判定の書き方の誤り）
- 読み込んだときにコマンド名を表示するようにした

**ver1 から変わらないこと**：コマンド名・ショートカット・質問の順番・処理の結果（今使っている人が困らないように）。

## 動作確認

- テスト図面：[test/CHAMFER+_test.dxf](test/CHAMFER+_test.dxf)（`test/make_test_dxf.py` で作り直せます）
- 手順：[test/確認手順.md](test/確認手順.md)
- lispcheck での比較：[test/lispcheck結果/検証結果.md](test/lispcheck結果/検証結果.md)
