# note 記事更新メモ（ver2 を上げるとき）

2026-09-29 作成。細かい修正内容は [00_noteのLISP_ver2修正一覧.md](00_noteのLISP_ver2修正一覧.md) に記録（記事には書かない）。

## 書き方の方針

- 記事は簡潔に短く。
- 書くのは、使う人から見て仕様が変わった所だけ。それ以外は「安定性を強化しました。」の一言。
- 以前に不備があったように読める書き方は避ける。
- ver2 と旧版の両方を上げ、最新版を上に置く。

## ダウンロード欄（共通）

> ●ダウンロード
> ・〇〇_ver2.lsp（最新版）
> ・〇〇.lsp（旧版）
> ※最新版をお使いください。うまく動かない場合は旧版をどうぞ。

## 記事ごとに足す1行

| LISP | 記事 | 足す1行 | 上げるファイル |
|---|---|---|---|
| LockAllVP | [記事](https://note.com/chiko_root/n/n9da8de17e5c7) | ver2：実行後、元のレイアウトに戻るようにしました。ロックした数を表示します。 | ver2＋旧版 |
| Load_All_Lsp | [記事](https://note.com/chiko_root/n/n9014ed25009f) | ver2：読み込めない LISP があっても、残りを続けて読み込むようにしました。 | ver2＋旧版 |
| RegionToPL | [記事](https://note.com/chiko_root/n/n9e44178bba5a) | ver2：変換した個数を表示するようにしました。 | ver2＋旧版 |
| ClipCopy | [記事](https://note.com/chiko_root/n/nb7b81943260e) | ver2：U（元に戻す）1回で実行前に戻せるようにしました。 | ver2＋旧版 |
| FlattenFast | [記事](https://note.com/chiko_root/n/n1ad9ae65d475) | ver2：U（元に戻す）1回で実行前に戻せるようにしました。 | ver2＋旧版 |
| CHAMFER+ | [記事](https://note.com/chiko_root/n/n83cbc3c9bbe7) | ver2：安定性を強化しました。 | ver2＋旧版 |
| XForce | [記事](https://note.com/chiko_root/n/n45771f89b676) | ver2：安定性を強化しました。 | ver2＋旧版 |
| RANDOMBNAME | [記事](https://note.com/chiko_root/n/ncd02b98b2115) | ver2：安定性を強化しました。 | ver2＋旧版 |
| SetAllPSLT | [記事](https://note.com/chiko_root/n/n301861b743dd) | ver2：安定性を強化しました。 | ver2＋旧版 |
| ZeroBylayer | [記事](https://note.com/chiko_root/n/n4c45c7028891) | ver2：安定性を強化しました。 | ver2＋旧版 |
| Quake | [記事](https://note.com/chiko_root/n/n1ebb99c42566) | ver2：安定性を強化しました。 | ver2＋旧版 |
| LPON・LPOFF | [記事](https://note.com/chiko_root/n/ncd60554d9d92) | ver2：安定性を強化しました。 | ver2＋旧版 |
| CopyBlock | [記事](https://note.com/chiko_root/n/n65a353633ab0) | ver2：安定性を強化しました。 | ver2＋旧版 |
| CADSOZAI | [記事](https://note.com/chiko_root/n/n13ba2acb6527) | ver2：より幅広い AutoCAD のバージョンで使えるようにしました。 | ver2 だけに差し替え（旧版は文字化けすることがあるため） |
| HPDRAWORDER1 | [記事](https://note.com/chiko_root/n/ndcb9e206f7f6) | ver2：より幅広い AutoCAD のバージョンで使えるようにしました。 | ver2 だけに差し替え（同上） |

- CADSOZAI・HPDRAWORDER1 のダウンロード欄は、「〇〇_ver2.lsp」の1行だけでよい。
- LSP ファイルの添付・差し替えは、チコさんが手で行う。Chrome の Claude に頼むのは文章の修正と下書き保存まで。公開ボタンはチコさんが押す。

## AutoIME（ver2 は作っていない。記事に説明だけ足す）

[記事](https://note.com/chiko_root/n/n97bcfe7b6606)

> ●ダウンロード
> ・AutoCAD（レギュラー版）・IJCAD：AutoIME_ver2.lsp
> ・AutoCAD LT 2024 以降：AutoIME_ver2.1(LT対応版).lsp（レギュラー版でも可）
> ※LT では AutoIME_ver2.lsp は動きません。

## 記事を直さないもの

BakClean・REVCLAUTO・SolidToHatch・ExportSysVars・Web（今回 ver2 を作っていない）
