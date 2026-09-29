# FlattenFast

選んだ図形の Z 座標・高度・厚みを 0 にする（フィレットやトリムができない、を解消）。チコさんが note で公開している LISP です。

| ファイル | 内容 |
|---|---|
| [FlattenFast.lsp](FlattenFast.lsp) | ver1（公開中の版。そのまま保存） |
| [FlattenFast_ver2.lsp](FlattenFast_ver2.lsp) | ver2（2026-09-29 に直した版） |

コマンド：FLATTENFAST（FTF）

## ver2 で直したこと

- Undo グループを付けた（実行後の U 1回で実行前に戻る。ver1 は1図形ずつ戻っていた）
- Esc で中止したときに「Error: Function cancelled」と出ないようにした
- 読み込んだときにコマンド名を表示するようにした

**ver1 から変わらないこと**：コマンド名・ショートカット・質問の順番・処理の結果（今使っている人が困らないように）。

## 動作確認

- テスト図面：[test/FlattenFast_test.dxf](test/FlattenFast_test.dxf)（`test/make_test_dxf.py` で作り直せます）
- 手順：[test/確認手順.md](test/確認手順.md)
- lispcheck での比較：[test/lispcheck結果/検証結果.md](test/lispcheck結果/検証結果.md)
