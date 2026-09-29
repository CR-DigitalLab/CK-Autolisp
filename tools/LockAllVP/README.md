# LockAllVP

すべてのレイアウトのビューポートを一括でロックする。チコさんが note で公開している LISP です。

| ファイル | 内容 |
|---|---|
| [LockAllVP.lsp](LockAllVP.lsp) | ver1（公開中の版。そのまま保存） |
| [LockAllVP_ver2.lsp](LockAllVP_ver2.lsp) | ver2（2026-09-29 に直した版） |

コマンド：LOCKALLVP

## ver2 で直したこと

- ロックされた画層にあるビューポートがあると、途中でエラーで止まっていたのを直した（飛ばして、その数を知らせる）
- 終わったあと、実行前のレイアウトに戻るようにした（ver1 は最後のレイアウトに切り替わったままだった）
- Undo グループを付けた（実行後の U 1回で実行前に戻る）。エラー・Esc のときも元のレイアウトに戻す
- ロックしたビューポートの数を表示するようにした。変数をほかの LISP とぶつからないようにした
- 読み込んだときにコマンド名を表示するようにした

**ver1 から変わらないこと**：コマンド名・ショートカット・質問の順番・処理の結果（今使っている人が困らないように）。

## 動作確認

- テスト図面：[test/LockAllVP_test.dxf](test/LockAllVP_test.dxf)（`test/make_test_dxf.py` で作り直せます）
- 手順：[test/確認手順.md](test/確認手順.md)
- lispcheck での比較：[test/lispcheck結果/検証結果.md](test/lispcheck結果/検証結果.md)
