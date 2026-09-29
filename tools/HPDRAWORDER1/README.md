# HPDRAWORDER1

図面を開くたびに、ハッチングを最背面に作る設定（HPDRAWORDER=1）にする。チコさんが note で公開している LISP です。

| ファイル | 内容 |
|---|---|
| [HPDRAWORDER1.lsp](HPDRAWORDER1.lsp) | ver1（公開中の版。そのまま保存） |
| [HPDRAWORDER1_ver2.lsp](HPDRAWORDER1_ver2.lsp) | ver2（2026-09-29 に直した版） |

コマンド：（コマンドなし。読み込むと HPDRAWORDER を 1 にする）

## ver2 で直したこと

- 文字コードを ANSI（Shift-JIS）にした（UTF-8 では AutoCAD のバージョンによって日本語が文字化けするため。この LISP は中の説明が全部日本語）

**ver1 から変わらないこと**：コマンド名・ショートカット・処理の結果（今使っている人が困らないように）。

## 動作確認

- テスト図面：[test/HPDRAWORDER1_test.dxf](test/HPDRAWORDER1_test.dxf)（`test/make_test_dxf.py` で作り直せます）
- 手順：[test/確認手順.md](test/確認手順.md)
- lispcheck での比較：[test/lispcheck結果/検証結果.md](test/lispcheck結果/検証結果.md)
