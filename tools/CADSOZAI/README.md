# CADSOZAI

CAD素材.com のサイトマップをブラウザで開く。チコさんが note で公開している LISP です。

| ファイル | 内容 |
|---|---|
| [CADSOZAI.lsp](CADSOZAI.lsp) | ver1（公開中の版。そのまま保存） |
| [CADSOZAI_ver2.lsp](CADSOZAI_ver2.lsp) | ver2（2026-09-29 に直した版） |

コマンド：CADSOZAI（TANUKISAN）

## ver2 で直したこと

- 文字コードを ANSI（Shift-JIS）にした（UTF-8 では AutoCAD のバージョンによって日本語が文字化けするため）
- 読み込み時の表示に「ver2」を付けた

**ver1 から変わらないこと**：コマンド名・ショートカット・処理の結果（今使っている人が困らないように）。

## 動作確認

- テスト図面：[test/CADSOZAI_test.dxf](test/CADSOZAI_test.dxf)（`test/make_test_dxf.py` で作り直せます）
- 手順：[test/確認手順.md](test/確認手順.md)
- lispcheck での比較：[test/lispcheck結果/検証結果.md](test/lispcheck結果/検証結果.md)
