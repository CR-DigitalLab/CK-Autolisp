# SetAllPSLT

全レイアウトの PSLTSCALE を一括で 0 または 1 にする。チコさんが note で公開している LISP です。

| ファイル | 内容 |
|---|---|
| [SetAllPSLT.lsp](SetAllPSLT.lsp) | ver1（公開中の版。そのまま保存） |
| [SetAllPSLT_ver2.lsp](SetAllPSLT_ver2.lsp) | ver2（2026-09-29 に直した版） |

コマンド：SETALLPSLT（SAP）

## ver2 で直したこと

- 途中で Esc・エラーになったとき、Undo グループを閉じ、元のレイアウトと CMDECHO に戻すようにした（ver1 は Esc で CMDECHO が 0 のまま残った）
- ショートカット SAP を追加した（SETALLPSLT もそのまま使える）
- 読み込んだときにコマンド名を表示するようにした

**ver1 から変わらないこと**：コマンド名・ショートカット・質問の順番・処理の結果（今使っている人が困らないように）。

## 動作確認

- テスト図面：[test/SetAllPSLT_test.dxf](test/SetAllPSLT_test.dxf)（`test/make_test_dxf.py` で作り直せます）
- 手順：[test/確認手順.md](test/確認手順.md)
- lispcheck での比較：[test/lispcheck結果/検証結果.md](test/lispcheck結果/検証結果.md)
