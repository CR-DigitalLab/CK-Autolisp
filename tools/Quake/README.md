# Quake

気象庁から直近の地震情報10件を取得して表示する。チコさんが note で公開している LISP です。

| ファイル | 内容 |
|---|---|
| [Quake.lsp](Quake.lsp) | ver1（公開中の版。そのまま保存） |
| [Quake_ver2.lsp](Quake_ver2.lsp) | ver2（2026-09-29 に直した版） |

コマンド：QUAKE（JISIN）

## ver2 で直したこと

- 通信やデータの取得に失敗したときも、最後に「正常に完了しました」と出ていたのを直した（取得できたときだけ表示）
- エラー処理が、まれに自分自身のエラーになる書き方を直した
- 読み込んだときにコマンド名を表示するようにした

**ver1 から変わらないこと**：コマンド名・ショートカット・処理の結果（今使っている人が困らないように）。

## 動作確認

- テスト図面：[test/Quake_test.dxf](test/Quake_test.dxf)（`test/make_test_dxf.py` で作り直せます）
- 手順：[test/確認手順.md](test/確認手順.md)
- lispcheck での比較：[test/lispcheck結果/検証結果.md](test/lispcheck結果/検証結果.md)
- 今後の改良候補：[改良メモ.md](改良メモ.md)
