# CopyBlock

既存のブロックを、名前の違う別のブロックとして複製する。チコさんが note で公開している LISP です。

| ファイル | 内容 |
|---|---|
| [CopyBlock.lsp](CopyBlock.lsp) | ver1（公開中の版。そのまま保存） |
| [CopyBlock_ver2.lsp](CopyBlock_ver2.lsp) | ver2（2026-09-29 に直した版） |

コマンド：COPYBLOCK（CB）

## ver2 で直したこと

- エラー処理が、まれに自分自身のエラーになる書き方を直した
- 読み込み時の表示に「ver2」を付けた

**ver1 から変わらないこと**：コマンド名・ショートカット・質問の順番・処理の結果（今使っている人が困らないように）。

## 動作確認

- テスト図面：[test/CopyBlock_test.dxf](test/CopyBlock_test.dxf)（`test/make_test_dxf.py` で作り直せます）
- 手順：[test/確認手順.md](test/確認手順.md)
- lispcheck での比較：[test/lispcheck結果/検証結果.md](test/lispcheck結果/検証結果.md)
