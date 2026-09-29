# LPON・LPOFF

選んだ図形の画層を、非印刷／印刷可能にする。チコさんが note で公開している LISP です。

| ファイル | 内容 |
|---|---|
| [LPON・LPOFF.lsp](LPON・LPOFF.lsp) | ver1（公開中の版。そのまま保存） |
| [LPON・LPOFF_ver2.lsp](LPON・LPOFF_ver2.lsp) | ver2（2026-09-29 に直した版） |

コマンド：LAYERPLOTOFF（LPOFF）／LAYERPLOTON（LPON）

## ver2 で直したこと

- 画層に「印刷する／しない」の情報が書かれていないとき、変わっていないのに「設定しました」と出ていたのを直した
- エラー処理が、まれに自分自身のエラーになる書き方を直した
- 読み込んだときにコマンド名を表示するようにした

**ver1 から変わらないこと**：コマンド名・ショートカット・質問の順番・処理の結果（今使っている人が困らないように）。

## 動作確認

- テスト図面：[test/LPON・LPOFF_test.dxf](test/LPON・LPOFF_test.dxf)（`test/make_test_dxf.py` で作り直せます）
- 手順：[test/確認手順.md](test/確認手順.md)
- lispcheck での比較：[test/lispcheck結果/検証結果.md](test/lispcheck結果/検証結果.md)
