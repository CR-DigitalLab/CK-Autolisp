# RegionToPL

リージョンを一括でポリラインに変換する。チコさんが note で公開している LISP です。

| ファイル | 内容 |
|---|---|
| [RegionToPL.lsp](RegionToPL.lsp) | ver1（公開中の版。そのまま保存） |
| [RegionToPL_ver2.lsp](RegionToPL_ver2.lsp) | ver2（2026-09-29 に直した版） |

コマンド：REGIONTOPL（RTP）

## ver2 で直したこと

- 途中で Esc・エラーになったとき、Undo グループを閉じ、PEDITACCEPT を元に戻すようにした
- 英語版以外の AutoCAD でも動くよう、Undo のオプションに「_」を付けた
- 終わったときに、変換した個数を表示するようにした
- 読み込んだときにコマンド名を表示するようにした

**ver1 から変わらないこと**：コマンド名・ショートカット・質問の順番・処理の結果（今使っている人が困らないように）。

## 動作確認

- テスト図面：[test/RegionToPL_test.dxf](test/RegionToPL_test.dxf)（`test/make_test_dxf.py` で作り直せます）
- 手順：[test/確認手順.md](test/確認手順.md)
- lispcheck での比較：[test/lispcheck結果/検証結果.md](test/lispcheck結果/検証結果.md)
