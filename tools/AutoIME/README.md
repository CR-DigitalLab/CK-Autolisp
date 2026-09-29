# AutoIME

文字を編集するときだけ、日本語入力を自動で ON にし、終わると OFF に戻す LISP です。チコさんが note で公開しています（[記事](https://note.com/chiko_root/n/n97bcfe7b6606)）。

| ファイル | 対応 | 補助プログラム |
|---|---|---|
| [AutoIME_ver2.lsp](AutoIME_ver2.lsp) | AutoCAD（レギュラー版）・IJCAD | `%APPDATA%\AutoIME\AutoIME.exe` |
| [AutoIME_ver2.1(LT対応版).lsp](AutoIME_ver2.1(LT対応版).lsp) | AutoCAD・AutoCAD LT 2024 以降 | `%APPDATA%\AutoIME\AutoIME2.exe` |

コマンド：AUTOIMESTART（開始）／AUTOIMESTOP（停止）。読み込むと自動で開始します。

## 2026-09-29 の見直しで決めたこと

- **2つのファイルのまま**にする（チコさんの判断）。記事に次の説明を足す。
- ver2 は LT で使えない部品（WScript.Shell）を使うため、LT では動かない。記事の手順1は「AutoIME_ver2.lsp をダウンロード」となっているので、LT の人が ver2 を入れてしまわないよう、説明を足す。
- 今後、1つにまとめるときは、ver2.1 をもとにする。補助プログラムの名前（AutoIME.exe と AutoIME2.exe）は、渡し方が違うので混ぜない（混ぜると、今使っている人の日本語入力が知らないうちに切り替わらなくなる）。

## 記事に足す説明（案）

> ●ダウンロードするファイルについて
> ・AutoCAD（レギュラー版）・IJCAD の方：**AutoIME_ver2.lsp**
> ・AutoCAD LT 2024 以降の方：**AutoIME_ver2.1(LT対応版).lsp**（レギュラー版でも使えます）
> ※LT で AutoIME_ver2.lsp を読み込むと動きません。

## 点検結果

ChikoLispCheck・lispcheck で点検し、直す必要のある不具合は無かった（△ はショートカットが無いことと、読み込み時にコマンド名を表示しないことだけ）。
