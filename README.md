# CK-Autolisp

世界中の無料AutoLISP（AutoCAD用LISP）を調査・収集したリポジトリです。（調査日: 2026-09-26）

## 中身

| 場所 | 内容 |
|---|---|
| [catalog/01_世界の配布サイト.md](catalog/01_世界の配布サイト.md) | 海外の無料配布サイト 約70件（英・露・中・韓・越・仏・独・波・伊・西・葡）と有名ルーチン 約60本 |
| [catalog/02_日本語サイト.md](catalog/02_日本語サイト.md) | 日本語の配布・コード公開サイト 37件 |
| [catalog/03_建築・設備向け.md](catalog/03_建築・設備向け.md) | 建築・空調・衛生・電気向けルーチン 約70件 |
| [catalog/04_GitHub.md](catalog/04_GitHub.md) | GitHub上のAutoLISPリポジトリ 約70件（ライセンス別） |
| [catalog/05_再配布可否の確認結果.md](catalog/05_再配布可否の確認結果.md) | **各サイトの利用規約を直接読んで確認した、再配布OK／不可の判定**（01〜03より優先） |
| [collected/](collected/INDEX.md) | **再配布OKと確認できたファイル本体 1,936個**（GitHub 24リポジトリ＋Webサイト等 9か所） |

## 世界のAutoLISP一覧（採点付き Excel）

コマンドの説明文をもとに、4項目（非代替性・斬新さ・時短効果・汎用性、各25点）でAIが採点した一覧です。

| ファイル | 内容 | 件数 |
|---|---|---|
| [catalog/00_世界のAutoLISP総合一覧_採点.xlsx](catalog/00_世界のAutoLISP総合一覧_採点.xlsx) | **全地域の総合版**（重複をまとめ済み。アイデア集・分野別TOP10・地域別集計つき） | 6,942 |
| catalog/list_01_英語圏_前半_採点.xlsx | Lee Mac、draftsperson.net、JTB World ほか | 696 |
| catalog/list_02_英語圏_後半_採点.xlsx | CAD Forum、ParaCADD、Cadalyst、eSurveying ほか | 1,686 |
| catalog/list_03_日本_採点.xlsx | Vector、note、ブログ ほか | 380 |
| catalog/list_04_中国語圏_採点.xlsx | 明经CAD社区、@lisp、晓东CAD家园 ほか | 655 |
| catalog/list_05_ロシア語圏_採点.xlsx | dwg.ru、geodesist.ru、autolisp.ru ほか | 673 |
| catalog/list_06_ベトナム・東南アジア_採点.xlsx | kho-lisp-cad、lisp.vn、CADViet ほか | 631 |
| catalog/list_07_ヨーロッパ_採点.xlsx | 仏・独・波・伊ほか | 488 |
| catalog/list_08_その他の地域_採点.xlsx | 韓国・中東・中南米・ブラジル ほか | 1,292 |
| catalog/list_09_GitHub_採点.xlsx | GitHub の公開リポジトリ | 509 |

## 集め方のルール

- ファイル本体を保存したのは、**再配布の許可が明記されているものだけ**です（MIT・GPLなどのライセンス、サイトの規約、ファイル冒頭の許可文のいずれか）。
- Lee Mac、JTB World、MEP WORK などの有名サイトは、再配布が禁止されているか許可が書かれていないため、**一覧表にリンクを載せるだけ**にしています。使うときは各サイトから直接ダウンロードしてください。
- 他の作者のコードが混ざっているものや、暗号化されて中身を確認できないものは除外しました（[collected/INDEX.md](collected/INDEX.md) に記録）。
- 各フォルダの `SOURCE.txt` に取得元と許可の根拠を記録しています。

## ご注意

- 収録ファイルの**動作確認はしていません**。使う前にテスト用図面で試してください。
- 「改変しないこと」を条件に配布が許可されているファイルがあります。**collected 内のファイルは書き換えず**、改造するときはコピーを別の場所に作ってください。
- 01〜04の一覧表の「本数」などは Web 検索の結果をもとにしています。
- GitHub には AutoCAD の海賊版を装った危険なリポジトリがあります。一覧表に載っていないものはダウンロードしないでください。
