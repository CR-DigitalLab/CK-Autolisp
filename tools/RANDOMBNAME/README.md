# RANDOMBNAME

選んだブロックの定義名を、ランダムな名前（A$C で始まる11文字）に一括で変える。チコさんが note で公開している LISP です。

| ファイル | 内容 |
|---|---|
| [RANDOMBNAME.lsp](RANDOMBNAME.lsp) | ver1（公開中の版。そのまま保存） |
| [RANDOMBNAME_ver2.lsp](RANDOMBNAME_ver2.lsp) | ver2（2026-09-29 に直した版） |

コマンド：RANDOMBNAME（RBN）

## ver2 で直したこと

- 途中で Esc・エラーになったとき、CMDECHO を元に戻し、Undo グループを閉じるようにした（ver1 は Esc で CMDECHO が 0 のまま残った）
- 英語版以外の AutoCAD でも動くよう、名前変更のオプションに「_」を付けた（"Block" → "_Block"）
- 読み込んだときにコマンド名を表示するようにした

**ver1 から変わらないこと**：コマンド名・ショートカット・質問の順番・処理の結果（今使っている人が困らないように）。

## 動作確認

- テスト図面：[test/RANDOMBNAME_test.dxf](test/RANDOMBNAME_test.dxf)（`test/make_test_dxf.py` で作り直せます）
- 手順：[test/確認手順.md](test/確認手順.md)
- lispcheck での比較：[test/lispcheck結果/検証結果.md](test/lispcheck結果/検証結果.md)
