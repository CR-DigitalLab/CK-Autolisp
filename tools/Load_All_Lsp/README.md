# Load_All_Lsp

同じフォルダにある LISP をまとめて自動で読み込む（スタートアップ登録が1つで済む）。チコさんが note で公開している LISP です。

| ファイル | 内容 |
|---|---|
| [Load_All_Lsp.lsp](Load_All_Lsp.lsp) | ver1（公開中の版。そのまま保存） |
| [ver2/Load_All_Lsp.lsp](ver2/Load_All_Lsp.lsp) | ver2（2026-09-30 に直した版）。ファイル名は元のまま |

コマンド：（コマンドなし。読み込むと同じフォルダの LISP をすべて読み込む）

## ファイル名について

この LISP は、自分のファイル名（Load_all_lsp.lsp）で自分の場所を探します。ファイル名に `_ver2` を付けると動かないため、ver2 も元のファイル名のまま `ver2` フォルダに置いています（2026-09-30、AutoCAD で「パスが取得できませんでした」となったため）。記事には ver2 だけを上げます（旧版と同じ名前になるため）。

## ver2 で直したこと

- フォルダの中の LISP が1つでもエラーになると、残りの LISP が読み込まれなかったのを直した（失敗したものは「読み込み失敗: ファイル名（理由）」と表示して、続きを読み込む）

**ver1 から変わらないこと**：コマンド名・ショートカット・処理の結果（今使っている人が困らないように）。

## 動作確認

- テスト図面：[test/Load_All_Lsp_test.dxf](test/Load_All_Lsp_test.dxf)（`test/make_test_dxf.py` で作り直せます）
- 手順：[test/確認手順.md](test/確認手順.md)
- lispcheck での比較：[test/lispcheck結果/検証結果.md](test/lispcheck結果/検証結果.md)
- 今後の改良候補：[改良メモ.md](改良メモ.md)
