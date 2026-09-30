# XForce

分解できないブロックも強制的に分解する。チコさんが note で公開している LISP です。

| ファイル | 内容 |
|---|---|
| [XForce.lsp](XForce.lsp) | ver1（公開中の版。そのまま保存） |
| [XForce_ver2.lsp](XForce_ver2.lsp) | ver2（2026-09-29 に直した版） |

コマンド：XFORCE（XF）

**IJCAD には非対応**（2026-09-30 チコさんが IJCAD で確認：ver1・ver2 とも「関数定義がありません:SAFEARRAY-GET-U-BOUND」で止まる。チコさんの判断で IJCAD 非対応とし、記事の「IJCAD 動作確認済み」の表記を直す）

## ver2 で直したこと

- 分解の途中でエラーになったとき、Undo グループを閉じるようにした
- 読み込んだときにコマンド名を表示するようにした

**ver1 から変わらないこと**：コマンド名・ショートカット・質問の順番・処理の結果（今使っている人が困らないように）。

## 動作確認

- テスト図面：[test/XForce_test.dxf](test/XForce_test.dxf)（`test/make_test_dxf.py` で作り直せます）
- 手順：[test/確認手順.md](test/確認手順.md)
- lispcheck での比較：[test/lispcheck結果/検証結果.md](test/lispcheck結果/検証結果.md)

## メモ：分解後の確認に使う関数について（2026-09-29）

- 一度は、AutoCAD の説明書に載っている名前（vlax-safearray-get-u-bound）に変えたが、元の名前（safearray-get-u-bound）に戻した。
- 元の名前は説明書には載っていないが、ver1 は AutoCAD で動いている。IJCAD にはこの名前が無く止まるが、IJCAD は非対応とすることにしたため、AutoCAD で実績のある元の名前のままにした。
- lispcheck はこの名前を知らないため「未定義の関数」と警告を出すが、ver1 と同じなので問題ない（lispcheck では分解そのものを再現できず、この行は実行されない）。
