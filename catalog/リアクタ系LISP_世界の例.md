# リアクタ系 LISP 世界の例（AutoIME の仲間）

調査日：2026-09-29　／　元データ：[00_世界のAutoLISP総合一覧_採点.xlsx](00_世界のAutoLISP総合一覧_採点.xlsx)（6,942件）から、リアクタを使うものを選び出し、ウェブ検索で少し補ったもの（約45本）。

**リアクタ**とは、「この操作が起きたら知らせて」と AutoCAD に頼んでおく見張り役です。コマンド名を打たなくても、読み込んでおけば裏で自動で働きます。チコさんの AutoIME（[note の記事](https://note.com/chiko_root/n/n97bcfe7b6606)）は、文字編集の開始・終了を見張って日本語入力を自動で切り替えるリアクタ系 LISP です。

仕組みの詳しい説明は [アイデア集 T01](アイデア集/T01_操作に反応して自動処理（リアクター）.md) にあります。

## 1. 日本語入力（IME）の自動切替 ― AutoIME の仲間

| 名前 | 地域 | 内容 | 作者・サイト |
|---|---|---|---|
| 自动输入法 | 中国語圏 | 編集の状況に合わせて、中国語入力と英数入力を自動で切り替え | moy838840554（明经CAD社区） |
| 易输入 | 中国語圏 | 文字編集のときだけ中国語入力にする（AutoIME とほぼ同じ発想） | 红黑墨水（明经CAD社区） |
| 键盘侠 | 中国語圏 | コマンドラインに打つときは英数、文字を書くときは中国語に切り替え | 阿甘（@lisp 应用云） |
| 输入法自动切换／鼠标双击管理器 | 中国語圏 | 入力の切替に加えて、ダブルクリックしたときの動作も管理 | xiaoyingzi（明经CAD社区） |
| Tự động bật - tắt chế độ gõ tiếng việt | ベトナム | コマンドのときはベトナム語入力を自動で OFF | CADViet |
| CONVERT_Auto Unikey control | ベトナム | ベトナム語入力ソフト（Unikey）を自動で制御 | Kho Lisp CAD |
| 日本語入力自動切替（AutoIME） | 日本 | 文字編集のときに日本語入力を自動で ON、終わると OFF | チコ（note） |

漢字圏やベトナムでは定番の悩みです。一方、日本語向けの無料のものは、AutoIME のほかに見当たりませんでした。

## 2. コマンドに合わせて画層を自動切替（いちばん多い）

| 名前 | 地域 | 内容 | 作者・サイト |
|---|---|---|---|
| Layer Director | 英語圏 | コマンドごとに画層を切り替え、終わると元に戻す。世界的な定番 | Lee Mac（[lee-mac.com](https://www.lee-mac.com/layerdirector.html)） |
| FLay | 英語圏 | 図形の種類ごとに、作図時に指定した画層へ振り分け | CAD Studio（CAD Forum） |
| AutoLay reactor | 英語圏 | 寸法・文字などを自動で指定の画層へ | CAD Studio |
| Command Reactor | その他 | コマンドごとに標準の画層へ自動切替 | Ahmed Abdelmotey（GitHub） |
| REACTOR で画層管理 | ベトナム | リアクタで作図画層を自動管理 | CADViet |
| DIMSTYLE reactor | ヨーロッパ | 寸法スタイルを切り替えると、文字・表・引出線のスタイルも連動 | kojacek |

AutoCAD でも最近、文字・寸法・ハッチ・引出線・表・ビューポートは、設定（`TEXTLAYER`・`DIMLAYER`・`HPLAYER`・`MLEADERLAYER`・`TABLELAYER`・`VIEWPORTLAYER` など）だけで決まった画層に入るようになりました。そのため、この種類は一部が標準に取り込まれています（[AutoCAD新機能まとめ](AutoCAD新機能まとめ_2019-2027.md)）。線やポリラインなどは、今も LISP が必要です。

## 3. 保存・印刷の前後に自動で処理

| 名前 | 地域 | 内容 | 作者・サイト |
|---|---|---|---|
| PreSave reactor | 英語圏 | 保存の直前に、好きな処理を実行 | CAD Studio |
| SureSave reactor | 英語圏 | 編集中の図面のコピーを、別の場所に自動保存 | CAD Studio |
| archive-on-save | GitHub | 上書き保存の前に、日付付きの控えを作る | Brian C.（GitHub） |
| stamp.lsp | その他 | 上書き保存時に、図枠へファイルの場所と日時を書き込む | Paulo Gil Soto |
| save.lsp／saveas.lsp／qsave.lsp | 英語圏 | 保存時に押印・記録（保存コマンドの置き換え） | Henry C. Francis（ParaCADD） |
| Standardize When You Save and Close | 英語圏 | 保存時に、図面を社内の標準設定にそろえる | Cadalyst CAD Tips |
| Reactor-Based Text Fill Mode Monitor | 英語圏 | 印刷時に文字の塗りつぶし設定（TEXTFILL）を自動で ON | Cadalyst CAD Tips |
| To Plot Stamp or Not To Plot Stamp | 英語圏 | 印刷スタンプの付け忘れを防ぐ | Cadalyst CAD Tips |
| publish-reactor.lsp | 英語圏 | PUBLISH（一括印刷）用のリアクタ | Henry C. Francis（ParaCADD） |
| TotalLayouts reactor | 英語圏 | 「ページ X / Y」の Y（レイアウトの総数）を自動で更新 | CAD Studio |
| kpblc-autostart-purge | ロシア語圏 | 図面を開くたびに、不要なものを自動で削除 | kpblc（autolisp.ru） |
| CommandSave | GitHub | コマンドを実行するたびに自動で保存 | Jonathan Handojo（GitHub） |

## 4. 図形の連動（片方を動かすと付いてくる）

| 名前 | 地域 | 内容 | 作者・サイト |
|---|---|---|---|
| Associative Textbox | 英語圏 | 文字を囲む枠が、文字に付いてくる | Lee Mac |
| Bounding Box Reactor | 英語圏 | 図形を囲む四角が、図形の変更に付いてくる | Lee Mac（[lee-mac.com](https://www.lee-mac.com/boundingboxreactor.html)） |
| Align Text to Curve | 英語圏 | 曲線を動かすと、沿わせた文字が並び直す | Lee Mac |
| Automatically Label Attributes | 英語圏 | 頂点の座標を属性に自動で書き込む | Lee Mac |
| LATT | ヨーロッパ | ブロックの属性どうしを連動（同じ値・連番・合計） | Patrick_35（CADxp） |
| TotalArea | ヨーロッパ | 図形群の合計面積を、属性に常に表示 | (gile)（gileCAD） |
| LISP Ánh xạ giá trị đối tượng | ベトナム | 元の数値を直すと、参照している文字も自動で直る | CADViet |
| MLEADER jak DIMENSION | ヨーロッパ | マルチ引出線を図形に連動させる | kojacek |
| 反应器示例：随标注变化的螺丝 | 中国語圏 | 寸法を変えるとボルトの図形が変わる例 | rongyifei（明经CAD社区） |

## 5. 編集を見張って自動で直す・守る

| 名前 | 地域 | 内容 | 作者・サイト |
|---|---|---|---|
| 修正文字自動赤化 | 日本 | 修正した文字を自動で赤にする（有料） | ほんだ（note） |
| Object Lock | 英語圏 | 図形を編集できないようにする（動かすと元に戻る） | Lee Mac |
| ROT_0 / ROT | ヨーロッパ | ブロックを回しても、属性の文字の角度を0度に保つ | Patrick_35（CADxp） |
| AsmiTools: ATRON.LSP | ロシア語圏 | 挿入後に属性の角度を0度にし、位置を整える | Александр Смирнов（dwg.ru） |
| Реактор атрибутов блока | ロシア語圏 | 属性編集用のリアクタ | Барабанщиков Николай（dwg.ru） |
| Automatic Block Break | 英語圏 | ブロックを置くと、下の線を自動で切る | Lee Mac |
| RenameLOA reactor | 英語圏 | 図枠の属性を書き換えると、レイアウト名も自動で変わる | CAD Studio |
| LayoutLF reactor | 英語圏 | レイアウトを切り替えると、画層の絞り込み表示も自動で切り替わる | CAD Studio |

## 6. 画面・操作の補助

| 名前 | 地域 | 内容 | 作者・サイト |
|---|---|---|---|
| Selection Counter | 英語圏 | 選んでいる図形の数を、画面下にいつも表示 | Lee Mac（[lee-mac.com](https://www.lee-mac.com/selectioncounter.html)） |
| Associative MText Selector | 英語圏 | マルチテキストをダブルクリックすると、全文が選ばれた状態になる | Lee Mac |
| UCSauto reactor | 英語圏 | 座標の向き（UCS）を、いつもビューに合わせる | CAD Studio |
| VSauto reactor | 英語圏 | ビューに合わせて、表示スタイルを切り替える | CAD Studio |

## 7. 作業の記録・計測

| 名前 | 地域 | 内容 | 作者・サイト |
|---|---|---|---|
| Job-Time | 英語圏 | 図面ごとの正味の作業時間を記録 | CAD Studio |
| CMDtimer | 英語圏 | コマンドにかかった時間を計る | CAD Studio（CAD Forum） |
| LISP Command Logger | 英語圏 | 使った LISP コマンドを記録し、保存時に CSV に書き出す | Lee Mac（[lee-mac.com](https://www.lee-mac.com/lisplog.html)） |
| recordCommands | GitHub | すべてのコマンドの使用を記録 | Christopher Brisco（GitHub） |

## 作るときの部品・参考（リアクタの共通関数など）

- lispru-reactors（kpblc、autolisp.ru）、utils-reactor（Alexei Spirit、GitHub）：リアクタを扱う共通関数集。
- reactstate.lsp（Eric Schneider、ParaCADD）：リアクタの状態を調べる。
- atlisp のサンプル（VitalGG、GitHub）：コマンドリアクタなどの例。
- 解説：[AfraLISP のリアクタ講座](https://www.afralisp.net/visual-lisp/tutorials/reactors-part-1.php)、[Autodesk のリアクタ関数リファレンス（日本語）](https://help.autodesk.com/cloudhelp/2027/JPN/AutoCAD-AutoLISP-Reference/files/GUID-B83B512E-CEF6-43C5-9099-398999E254AF.htm)。

## 見えてきたこと（新しく作るなら）

- **日本語向けが手薄**：IME 切替は中国・ベトナムには複数ありますが、日本は AutoIME だけです。コマンドラインに打つときに英数へ戻す（键盘侠のような）機能は、日本にはまだありません。AutoIME の次の一手になりそうです。
- **検図の見張り番**：保存や印刷の直前に、次のような点を見て知らせるだけのリアクタは、ほとんど見当たりません。
  - 図枠の日付が今日になっているか
  - 画層のルールを守っているか
  - 寸法値を手で書き換えていないか

  勝手に直さず、知らせるだけにすると安心して使えます。
- **修正箇所の自動記録**：直した場所と日時を覚えておき、あとで雲マークや改訂欄をまとめて作るものです。「修正文字自動赤化」を広げた考え方で、日本の赤字修正の習慣に合います。
- **作るときの注意**：リアクタはいつも動いているので、間違えると全部の操作が遅くなったり、エラーが繰り返し出たりします。一時停止・再開のコマンド（AutoIME の AutoIMEStop／AutoIMEStart のようなもの）を必ず付けます。また、リアクタの中ではコマンドを直接呼べないなどの制約があります。
