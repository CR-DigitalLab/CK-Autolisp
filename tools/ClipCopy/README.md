# ClipCopy

指定した範囲をクリップ（切り取り）した形で、基点付きでコピーする。チコさんが note で公開している LISP です。

| ファイル | 内容 |
|---|---|
| [ClipCopy.lsp](ClipCopy.lsp) | ver1（公開中の版。そのまま保存） |
| [ClipCopy_ver2.lsp](ClipCopy_ver2.lsp) | ver2（2026-09-29 に直した版） |

コマンド：CLIPCOPY（CLC）

## ver2 で直したこと

- Undo グループを付けた（実行後の U 1回で実行前に戻る）
- 途中でエラーになったとき、選んだ図形が消えたままにならないよう、自動で実行前の状態に戻すようにした（一時的にブロックにして図面から外す作りのため、ver1 では消えたままになる恐れがあった）
- 選択の書き方を「_C」にした（英語版以外の AutoCAD でも確実に動くように）
- 読み込んだときにコマンド名を表示するようにした

**ver1 から変わらないこと**：コマンド名・ショートカット・質問の順番・処理の結果（今使っている人が困らないように）。

## 動作確認

- テスト図面：[test/ClipCopy_test.dxf](test/ClipCopy_test.dxf)（`test/make_test_dxf.py` で作り直せます）
- 手順：[test/確認手順.md](test/確認手順.md)
- lispcheck での比較：[test/lispcheck結果/検証結果.md](test/lispcheck結果/検証結果.md)
