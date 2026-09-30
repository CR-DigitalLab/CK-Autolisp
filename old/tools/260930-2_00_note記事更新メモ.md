# note 記事更新メモ（ver2 を上げるとき）

2026-09-30 更新。細かい修正内容は [00_noteのLISP_ver2修正一覧.md](00_noteのLISP_ver2修正一覧.md) に記録（記事には書かない）。

## 書き方の方針

- 記事は簡潔に短く。
- 修正内容は、ダウンロード欄の下に一言だけ。代表的なものを体言止めで書き、「等」でざっくりまとめる。
- 仕様が変わった所がなければ「安定性強化 等」。
- 以前に不備があったように読める書き方は避ける。
- ver2 と旧版の両方を上げ、最新版を上に置く。

## ダウンロード欄（共通）

> ●ダウンロード
> ・〇〇_ver2.lsp（最新版）
> ・〇〇.lsp（旧版）
> ※最新版をお使いください。うまく動かない場合は旧版をどうぞ。
> ver2：（下の表の一言）

## 記事ごとの一言

| LISP | 記事 | ダウンロード欄の下の一言 | 上げるファイル |
|---|---|---|---|
| LockAllVP | [記事](https://note.com/chiko_root/n/n9da8de17e5c7) | ver2：実行後に元のレイアウトへ戻るように変更、安定性強化 等 | ver2＋旧版 |
| RegionToPL | [記事](https://note.com/chiko_root/n/n9e44178bba5a) | ver2：変換した個数の表示、安定性強化 等 | ver2＋旧版 |
| ClipCopy | [記事](https://note.com/chiko_root/n/nb7b81943260e) | ver2：U（元に戻す）1回で実行前に戻るように変更、安定性強化 等 | ver2＋旧版 |
| FlattenFast | [記事](https://note.com/chiko_root/n/n1ad9ae65d475) | ver2：U（元に戻す）1回で実行前に戻るように変更、安定性強化 等 | ver2＋旧版 |
| CHAMFER+ | [記事](https://note.com/chiko_root/n/n83cbc3c9bbe7) | ver2：安定性強化 等 | ver2＋旧版 |
| XForce | [記事](https://note.com/chiko_root/n/n45771f89b676) | ver2：安定性強化 等 | ver2＋旧版（下の「IJCAD の表記」も直す） |
| RANDOMBNAME | [記事](https://note.com/chiko_root/n/ncd02b98b2115) | ver2：安定性強化 等 | ver2＋旧版 |
| SetAllPSLT | [記事](https://note.com/chiko_root/n/n301861b743dd) | ver2：安定性強化 等 | ver2＋旧版 |
| ZeroBylayer | [記事](https://note.com/chiko_root/n/n4c45c7028891) | ver2：安定性強化 等 | ver2＋旧版 |
| Quake | [記事](https://note.com/chiko_root/n/n1ebb99c42566) | ver2：安定性強化 等 | ver2＋旧版 |
| LPON・LPOFF | [記事](https://note.com/chiko_root/n/ncd60554d9d92) | ver2：安定性強化 等 | ver2＋旧版 |
| CopyBlock | [記事](https://note.com/chiko_root/n/n65a353633ab0) | ver2：安定性強化 等 | ver2＋旧版 |
| Load_All_Lsp | [記事](https://note.com/chiko_root/n/n9014ed25009f) | ver2：読み込めない LISP があっても、残りを続けて読み込むように変更 等 | ver2 だけに差し替え（下の注意を参照） |
| CADSOZAI | [記事](https://note.com/chiko_root/n/n13ba2acb6527) | ver2：対応バージョンの拡大 等 | ver2 だけに差し替え |
| HPDRAWORDER1 | [記事](https://note.com/chiko_root/n/ndcb9e206f7f6) | ver2：対応バージョンの拡大 等 | ver2 だけに差し替え |

### ver2 だけに差し替えるもの（3本）

- ダウンロード欄は1行だけ。「※最新版をお使いください〜」の行は不要。
- Load_All_Lsp は、ver2 もファイル名が `Load_All_Lsp.lsp` のまま（自分のファイル名で場所を探すため、名前を変えると動かない）。GitHub では `tools/Load_All_Lsp/ver2/Load_All_Lsp.lsp`。旧版と同じ名前になるので、旧版は上げない。

> ●ダウンロード
> ・Load_All_Lsp.lsp（ver2）
> ver2：読み込めない LISP があっても、残りを続けて読み込むように変更 等

### XForce の IJCAD の表記

IJCAD では ver1・ver2 とも動かないため（2026-09-30 チコさんが確認）、IJCAD 非対応にする。

- 「・IJCAD2025(STD)でも動作確認済み！」→「・IJCAD には非対応です。」
- その下の「・その他互換CADでも〜」の行は削除

## LSP ファイルの中の書き方

- 先頭の修正メモは残す。体言止めで短く（例：「〜を直した」→「〜を修正」「〜を追加」）。

## AutoIME（ver2 は作っていない。記事に説明だけ足す）

[記事](https://note.com/chiko_root/n/n97bcfe7b6606)

> ●ダウンロード
> ・AutoCAD（レギュラー版）・IJCAD：AutoIME_ver2.lsp
> ・AutoCAD LT 2024 以降：AutoIME_ver2.1(LT対応版).lsp（レギュラー版でも可）
> ※LT では AutoIME_ver2.lsp は動きません。

## 記事を直さないもの

BakClean・REVCLAUTO・SolidToHatch・ExportSysVars・Web（今回 ver2 を作っていない）
