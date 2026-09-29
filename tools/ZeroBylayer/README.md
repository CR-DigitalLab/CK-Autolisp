# ZeroBylayer

現在の画層を 0 に、作成プロパティ（色・線種・線の太さ・透過性）を ByLayer にする。チコさんが note で公開している LISP です。

| ファイル | 内容 |
|---|---|
| [ZeroBylayer.lsp](ZeroBylayer.lsp) | ver1（公開中の版。そのまま保存） |
| [ZeroBylayer_ver2.lsp](ZeroBylayer_ver2.lsp) | ver2（2026-09-29 に直した版） |

コマンド：ZEROBYLAYER（ZB）

## ver2 で直したこと

- 終わったとき CMDECHO を「1」ではなく実行前の値に戻すようにした（CMDECHO を 0 にしている人の設定を変えない）
- 途中でエラーになったとき、Undo グループを閉じ、CMDECHO を元に戻すようにした
- 読み込んだときにコマンド名を表示するようにした

**ver1 から変わらないこと**：コマンド名・ショートカット・質問の順番・処理の結果（今使っている人が困らないように）。

## 動作確認

- テスト図面：[test/ZeroByLayer_test.dxf](test/ZeroByLayer_test.dxf)（`test/make_test_dxf.py` で作り直せます）
- 手順：[test/確認手順.md](test/確認手順.md)
- lispcheck での比較：[test/lispcheck結果/検証結果.md](test/lispcheck結果/検証結果.md)
