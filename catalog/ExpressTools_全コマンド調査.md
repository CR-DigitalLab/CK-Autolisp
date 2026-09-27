# AutoCAD Express Tools 全コマンド調査（公式・隠し・本体移動・廃止）

調査日：2026-09-27　／　対象：AutoCAD 2027・2026（Windows 版）。点数は付けない（一覧のみ）。

> 注意：Express Tools の中身（.lsp/.fas/.arx）は Autodesk の著作物。今回、GitHub などで Express Tools のソースの公開コピーは**見つからなかった**（GitHub コード検索で `c:tspaceinvaders`・`acetmain.mnl`・`acetauto.lsp`・`tscale.lsp` などを検索しても該当なし。唯一、`acetauto.lsp` を置いていた個人サーバー（atmstl.com）の検索結果は出たが、サーバーはもう無く、Web Archive にも保存されていなかった）。そのため「隠しコマンド」の根拠は、(1) Autodesk ヘルプ本文、(2) Autodesk ヘルプの各ページにある「File」欄、(3) ドイツ語版 Express Tools 2007 ヘルプ（ET2GP 翻訳チーム版。各コマンドの定義ファイル名が書いてある）、(4) CAD Forum（cadforum.cz）のコマンド辞典、(5) AutoCAD と IntelliCAD のコマンド比較表（Carlson 社、AutoCAD 2020 前後のコマンド一覧）、(6) BricsCAD の Express Tools 互換実装のヘルプ、の組み合わせ。コードは一切転載していない。

## 1. 概要

| 項目 | 内容 |
|---|---|
| 公式リファレンスの件数 | **85 項目**（AutoCAD 2027 / 2026 / 2025 / 2020 / 2015 の「Express Tools Reference」で**同じ 85 項目**。2015 年以降、公式一覧は増えも減りもしていない）。内訳：AutoCAD のコマンド 83 ＋ LISP 関数集 JULIAN（DATE コマンドを含む）＋ Windows 用ツール DUMPSHX。このほか、ページ内で説明されているハイフン付きのコマンドライン版が 7 つ（-BLOCKREPLACE, -BLOCKTOXREF, -CDORDER, -LAYOUTMERGE, -REDIRMODE, -TCASE, -XLIST） |
| うち旧式（Obsolete）扱い | 6（BTRIM, BEXTEND, TREX, QLATTACH, QLATTACHSET, QLDETACHSET）。ヘルプに “Obsolete” と書かれているが、コマンドとしてはまだ入っている |
| 非公開・隠しコマンド（今の版にあると確認できたもの） | **14**（TSPACEINVADERS, FASTSEL, FSMODE, DATE, RTEXTAPP, VARS2SCR, ADDVARS2SCR, IMAGEOVERLAP, ACETUCS-TOP/-BOTTOM/-FRONT/-BACK/-LEFT/-RIGHT）＋ 未確認候補 2（ETBUG, LSPDUMP） |
| 本体へ移動したもの | **22**（画層ツール 16・CHSPACE の 2007 年分、OVERKILL・NCOPY の 2012 年分、TXT2MTXT の 2017.1 分、REVCLOUD・WIPEOUT の初期分）。ほかに LT だけ ARCTEXT が 2023 で入った |
| 廃止されたもの | **18**（LMAN 系、PACK、FULLSCREEN 系、DCPROPS、PLJOIN 系、EXC 等の範囲外選択 6 種、CHT、TEDIT、LAYVPMODE） |
| AutoCAD LT | **Express Tools は使えない**（Autodesk サポート記事「Are Express Tools available in AutoCAD LT?」）。LT 2024 から AutoLISP は動くが Express Tools は入らない。例外として **ARCTEXT（LT 2023〜）と TXT2MTXT** は LT 2026 のヘルプに「(Command)」として載っている（どちらも LT では本体コマンド）。本体に移った画層ツール・OVERKILL・NCOPY 等も LT で使える |
| 読み込み | 通常インストールで入る。EXPRESSTOOLS で読み込み、EXPRESSMENU でメニュー表示。リボンの「Express Tools」タブ。各ツールは最初の実行時に autoload される（acetauto.lsp → acet-autoload2） |
| サポート | Autodesk の正式サポート対象外の「おまけ」扱い（Express Tools ヘルプの FAQ に明記） |

**歴史の要点**

- R14 の「Bonus Tools」が始まり → AutoCAD 2000 で「Express Tools」に改名（2000 用は Vol.1〜9 まで配布）。R14 最後の Bonus Tools は v6。
- AutoCAD 2000i では同梱されなかった。2002 以降は再び AutoCAD と一緒にインストールできるようになり、2004 では旧版の Express Tools が使えなくなったため、新しい版が製品 CD に同梱された（Eng-Tips / Archinect のやり取りより。細かい提供形態は版により違う）。
- 役目を終えたツールは本体へ移された：REVCLOUD（2000i〜2002 頃）、WIPEOUT（2004 頃）、**2007 年に画層ツール一式と CHSPACE**、**2012 年に OVERKILL と NCOPY**、**2017.1 で TXT2MTXT**、**LT 2023 で ARCTEXT**。
- 2008 で LMAN（画層マネージャ）は本体の「画層状態管理」に置き換えられ、LMAN の画層状態は自動変換されるようになった。
- 2008 のマルチ引出線で QLATTACH 系が旧式化した。TREX は「TRIM・EXTEND で同じことができる」として旧式扱いになり、BTRIM・BEXTEND もヘルプで Obsolete 表示になった（時期は 2021 の TRIM/EXTEND 刷新前後と推定）。
- 公式一覧は 2015 年から 2027 年まで 85 項目のまま（新しいツールの追加は無い）。

## 2. 公式コマンド一覧（カテゴリ別）

カテゴリはリボン「Express Tools」タブのパネル（ブロック／文字／修正／レイアウト／作成／寸法／ツール／Web）を目安に分けた。コマンドラインだけのツールも近いパネルに入れている。
「定義ファイル」は 2026 ヘルプの File 欄、無い場合はドイツ語版 ET2007 ヘルプの記載（「旧版」と付記）。LT 列：○＝LT で使える、×＝使えない。
状態の既定値は「公式」。テーマ列は `list/themes.md` の T01〜T30（関係が薄いものは T00）。

### ブロック（14）

| コマンド | 何をするか | 定義ファイル | 状態 | LT | テーマ | 出典 |
|---|---|---|---|---|---|---|
| BCOUNT | 選択範囲または図面全体のブロック挿入数をブロック名ごとに数えて一覧表示する。 | count.lsp | 公式 | × | T16 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-2C2991B4-779F-4FEE-9E55-8B0D6B62DEF8.htm) |
| BEXTEND | ブロック（内部の図形）を境界にして図形を延長する。（ヘルプに Obsolete とだけ記載（代わりのコマンドの説明は無い）） | — | 公式（ヘルプ上 Obsolete＝旧式） | × | T19, T00 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-ADFAA9DC-B6E9-456C-B5C7-984639963A06.htm) |
| BLOCK? | ブロック定義の中身（図形の一覧）を種類を指定して一覧表示する。 | blockq.lsp | 公式 | × | T19, T17 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-5DAE4FA4-808E-4E1F-8565-3D115B406226.htm) |
| BLOCKREPLACE | 指定したブロックの全挿入を別のブロックに置き換える（-BLOCKREPLACE はコマンドライン版）。 | blocktoxref.lsp | 公式 | × | T19 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-C2E32C55-28E4-4FC5-BCCA-F141D5AAA614.htm) |
| BLOCKTOXREF | 指定したブロックの全挿入を外部参照に置き換える（-BLOCKTOXREF あり）。 | blocktoxref.lsp | 公式 | × | T19, T29 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-C951209B-2844-4618-A4B3-EEBFEBB57868.htm) |
| BSCALE | ブロック参照を挿入点基準で X/Y/Z 個別に尺度変更する。 | bscale.lsp | 公式 | × | T19 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-63398207-C02F-480B-BB91-F7AB4C24011C.htm) |
| BTRIM | ブロック（内部の図形）を切り取りエッジにしてトリムする。（ヘルプに Obsolete とだけ記載（代わりのコマンドの説明は無い）） | — | 公式（ヘルプ上 Obsolete＝旧式） | × | T19, T20 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-4F925A89-6163-43F4-BB51-B0527E5E9983.htm) |
| BURST | ブロックを分解し、属性値を文字（TEXT）に変換して残す。 | burst.lsp | 公式 | × | T19, T14 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-8B576DFE-377C-408C-B6BE-672EE46AEED2.htm) |
| GATTE | 指定ブロックの全挿入について、ある属性の値を一括で書き換える。 | gatte.lsp | 公式 | × | T14 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-EABA451D-1351-416A-88CE-2E5C12C14B44.htm) |
| ATTIN | タブ区切りテキストから属性値を読み込んでブロックへ反映する（ATTOUT の逆）。 | attin.lsp | 公式 | × | T14, T23 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-2B54F825-CD42-4707-883A-8EFA97F4AB3F.htm) |
| ATTOUT | ブロック属性値をタブ区切りテキストに書き出す（Excel で編集→ATTIN で戻す運用）。 | attout.lsp | 公式 | × | T14, T23 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-899B195A-EFF0-4AEC-B0F8-7444EC75D649.htm) |
| XLIST | ブロック／外部参照の中の入れ子図形の種類・画層・色・線種を表示する（-XLIST あり）。 | xlist.lsp | 公式 | × | T19, T29 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-CDEF1C56-AFA4-4DE3-B01E-1662B8C33FBD.htm) |
| SHP2BLK | シェイプ図形を同等のブロックに置き換える。 | shp2blk.lsp | 公式 | × | T19 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-882CCB78-CF99-4E4F-945A-0E46FEC25946.htm) |
| PSBSCALE | ブロックの大きさをペーパー空間基準（ビューポート尺度連動）で設定・更新する。 | bscale.lsp | 公式 | × | T19, T05 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-20C3AD1E-34CC-471C-9842-2C8A3F622907.htm) |

### 文字（15）

| コマンド | 何をするか | 定義ファイル | 状態 | LT | テーマ | 出典 |
|---|---|---|---|---|---|---|
| ARCTEXT | 円弧に沿って文字（円弧整列文字オブジェクト）を配置・編集する。（LT には ARCTEXT だけ本体コマンドとして入った） | ctextapp.arx（旧版） | 公式 | ○（LT 2023〜） | T22 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-A1031C92-383E-41E7-80E0-9673D987EF2F.htm) |
| RTEXT | 外部テキストファイルや DIESEL 式の内容を表示するリモート文字を作る。 | rtext.arx / rtext.lsp（旧版） | 公式 | × | T13, T12 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-28585C1C-65B8-41E0-90A3-7C043123EF7A.htm) |
| RTEDIT | 既存のリモート文字（RTEXT）を編集する。 | rtext.arx / rtext.lsp（旧版） | 公式 | × | T13 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-4133A11F-C914-43F4-8ADB-B4F0E01AEA73.htm) |
| TCASE | 文字・マルチテキスト・属性・寸法文字の大文字／小文字を一括変換する（-TCASE あり）。 | tcase.lsp | 公式 | × | T12 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-085CF0C0-639C-4A4C-A2FC-CD885A7FDA38.htm) |
| TCIRCLE | 各文字の周りに円・長円・四角形の枠を描く。 | acettxt.lsp | 公式 | × | T12, T11 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-DEB79D5D-671A-437E-9C0F-3DE44F9C92A5.htm) |
| TCOUNT | 文字・マルチテキストに連番を接頭辞／接尾辞／置換として付ける。 | acettxt.lsp | 公式 | × | T15 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-4B92219C-DA94-4D71-B308-D3818D3C6B8F.htm) |
| TEXTFIT | 文字の始点・終点を指定して幅を伸縮させる。 | textfit.lsp | 公式 | × | T11, T12 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-9F512EAB-FB32-471F-84F2-5A402FEEE3A5.htm) |
| TEXTMASK | 文字の背後にワイプアウト等のマスクを作り、下の図形を隠す。 | textmask.lsp | 公式 | × | T11 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-C16E8C64-1DB8-4706-A44D-3C5E0655540D.htm) |
| TEXTUNMASK | TEXTMASK で付けたマスクを外す。 | textmask.lsp | 公式 | × | T11 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-C59A6D3D-C666-42A2-98A4-F856BB2D4A1F.htm) |
| TJUST | 文字の位置を動かさずに位置合わせ（基点）を変える。 | acettxt.lsp | 公式 | × | T11 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-41833749-A62B-4696-BF9C-80538DC25485.htm) |
| TORIENT | 文字・属性を読みやすい向きにそろえて回転する。 | acettxt.lsp | 公式 | × | T11 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-3A9CCCD9-7B1D-4C83-944C-2D66F5FF32DF.htm) |
| TSCALE | 文字・属性をそれぞれの基点で高さ指定または倍率で拡大縮小する。 | tscale.lsp | 公式 | × | T12, T11 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-D0836C0C-FC99-4521-8220-06D42D9F46FE.htm) |
| PSTSCALE | 文字高をペーパー空間基準（ビューポート尺度連動）で設定・更新する。 | tscale.lsp | 公式 | × | T12, T05 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-7385C843-BA65-4E9D-9FF6-61753E539416.htm) |
| TXT2MTXT | 複数の1行文字をマルチテキストに変換・結合する。（2026 ヘルプでもページ題名は “(Command)”。LT 2026 にも収録） | leaderex.arx（旧版） | 公式（2017.1以降は本体コマンド扱い） | ○ | T12 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-1E68C8B2-520F-4084-BD20-51DC4A32A7E5.htm) |
| TXTEXP | 文字を線分・ポリライン（図形）に分解する。 | txtexp.lsp | 公式 | × | T12, T00 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-80BE94B9-2ECE-438E-AEF8-984F7D27E0F9.htm) |

### 修正（10）

| コマンド | 何をするか | 定義ファイル | 状態 | LT | テーマ | 出典 |
|---|---|---|---|---|---|---|
| COPYM | 繰り返し・配列・等分割・計測の各オプション付きで複数コピーする。 | copym.lsp | 公式 | × | T21, T22 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-B850134A-4669-4FCC-8CE6-A233B5337F63.htm) |
| EXOFFSET | 画層指定・元図形削除・UNDO などを追加した拡張オフセット。 | exoffset.lsp | 公式 | × | T00, T21 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-1D9AD685-C0BC-48D8-A978-3BAAFA2E8138.htm) |
| EXTRIM | 選んだ閉図形などを切り取りエッジにして、片側をまとめてトリムする。 | extrim.lsp | 公式 | × | T20 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-06651AD3-F159-430E-81E5-AEB8E775C19E.htm) |
| MOCORO | 移動・複写・回転・尺度変更を1コマンドで行う。 | mocoro.arx | 公式 | × | T21 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-385D1161-6A07-432E-B69B-71C7D19409F5.htm) |
| MPEDIT | 複数ポリラインを一括編集し、線分・円弧をまとめてポリライン化する。 | mpedit.lsp | 公式 | × | T00 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-01661FA3-466E-47C6-B6FF-CBF0F29D1CD2.htm) |
| MSTRETCH | 複数の交差窓・交差ポリゴンでまとめてストレッチする。 | mstretch.lsp | 公式 | × | T00, T21 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-F91739FD-8944-40FD-A243-4BFFA12577CF.htm) |
| FLATTEN | 3D 図形を現在の視点で投影した 2D 図形に変換する。（Mac 版では本体コマンド） | flatten.lsp | 公式 | × | T10, T00 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-84039380-7A83-4969-9465-73C6C8784C1E.htm) |
| CDORDER | 色番号の順に表示順序（DRAWORDER）を並べ替える（-CDORDER あり）。 | cdorder.lsp | 公式 | × | T00 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-06C097F8-0482-4675-8910-664BC87B4AC3.htm) |
| TREX | TRIM と EXTEND を1つにしたコマンド（Shift で延長）。（ヘルプに「同じ操作は TRIM・EXTEND でできる」と記載） | trex.lsp | 公式（ヘルプ上 Obsolete＝旧式） | × | T20 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-02FCA8B9-55C5-402C-AEA2-D1A6D0FE29B1.htm) |
| CLIPIT | ブロック・外部参照・イメージ・ワイプアウトを円・円弧・ポリライン等の形で切り抜く。 | clipit.lsp | 公式 | × | T29, T19 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-1200C4A7-53EC-43C3-8667-749E83FCDD35.htm) |

### レイアウト（4）

| コマンド | 何をするか | 定義ファイル | 状態 | LT | テーマ | 出典 |
|---|---|---|---|---|---|---|
| ALIGNSPACE | モデル空間とペーパー空間の対応点を指定してビューポートの尺度・位置を合わせる。 | aspace.lsp | 公式 | × | T05 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-D5F8E293-F8A9-4E45-9441-87A21487A68C.htm) |
| LAYOUTMERGE | 複数のレイアウトを1つのレイアウトにまとめる（-LAYOUTMERGE あり）。 | layoutmerge.lsp | 公式 | × | T05 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-72D755E1-D065-403F-86CA-7730E539BB82.htm) |
| VPSCALE | 選んだビューポートの尺度を表示する。 | vpscale.lsp | 公式 | × | T05 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-D8D8E81C-A6B0-4337-97AA-2CB060DA7659.htm) |
| VPSYNC | 基準ビューポートに合わせて他のビューポートの表示位置・尺度をそろえる。 | vpsync.lsp | 公式 | × | T05 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-1D273873-9F33-422A-95CD-45CD52623A7E.htm) |

### 作成（2）

| コマンド | 何をするか | 定義ファイル | 状態 | LT | テーマ | 出典 |
|---|---|---|---|---|---|---|
| BREAKLINE | 破断記号付きのポリライン（破断線）を作図する。 | breakline.lsp | 公式 | × | T00, T24 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-88667D3B-C98B-4C02-85F4-232DD4950841.htm) |
| SUPERHATCH | イメージ・ブロック・外部参照・ワイプアウトを模様にしてハッチングする。 | sprhatch.lsp | 公式 | × | T00 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-89FB15FE-28B9-4A51-BACA-A393469EE1A6.htm) |

### 寸法（6）

| コマンド | 何をするか | 定義ファイル | 状態 | LT | テーマ | 出典 |
|---|---|---|---|---|---|---|
| DIMEX | 寸法スタイルを外部ファイル（.dim）に書き出す。 | dimsio.arx | 公式 | × | T10, T28 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-9DD96CAB-D7FE-4018-AA60-6309A2D4F6D3.htm) |
| DIMIM | 外部ファイルから寸法スタイルを読み込む。 | dimsio.arx | 公式 | × | T10, T28 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-8B5EDCC6-0985-4461-860B-E38F7E2C5098.htm) |
| DIMREASSOC | 上書き・変更された寸法文字を実測値（<>）に戻す。 | dimassoc.lsp | 公式 | × | T07 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-9D2D79DD-D8A9-4856-8459-4361B5A99655.htm) |
| QLATTACH | 旧式の引出線（LEADER）をマルチテキスト等に関連付ける。（マルチ引出線（MLEADER, 2008）で旧式化） | leaderex.arx | 公式（ヘルプ上 Obsolete＝旧式） | × | T11 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-9DBD0CA9-187F-41BB-955C-C6F89A837930.htm) |
| QLATTACHSET | 複数の引出線をまとめて注釈に関連付ける。 | leaderex.arx | 公式（ヘルプ上 Obsolete＝旧式） | × | T11 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-50B5F962-00A6-4D84-A472-A397A801B5BE.htm) |
| QLDETACHSET | 引出線と注釈の関連付けを解除する。 | leaderex.arx | 公式（ヘルプ上 Obsolete＝旧式） | × | T11 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-E33A1FCA-3B6D-4FD5-BE6E-FBB0BD7A6A26.htm) |

### ツール（選択）（3）

| コマンド | 何をするか | 定義ファイル | 状態 | LT | テーマ | 出典 |
|---|---|---|---|---|---|---|
| FS | 選んだ図形に接している図形を（連鎖的に）選択する。FSMODE で連鎖の有無を切替。（別名 FASTSEL（下記「非公開」）） | fastsel.lsp | 公式 | × | T00, T08 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-A4FBF4EC-DE23-46A2-A576-AEED0E9847D4.htm) |
| GETSEL | 画層と図形の種類で絞り込んだ一時選択セットを作る。 | getsel.lsp | 公式 | × | T18, T00 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-C5227693-40C1-4AB8-A84A-BD53AA6B7963.htm) |
| SSX | 見本図形と同じ性質（画層・色・種類など）の図形を選択する。 | ssx.lsp | 公式 | × | T00, T18 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-386ADF5E-C709-4940-8DB4-909C2760A23F.htm) |

### ツール（ファイル・設定）（24）

| コマンド | 何をするか | 定義ファイル | 状態 | LT | テーマ | 出典 |
|---|---|---|---|---|---|---|
| ACADINFO | AutoCAD の環境・設定情報を acadinfo.txt に書き出す。 | acadinfo.lsp | 公式 | × | T28, T10 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-6921516E-3158-43AF-9612-CA7A8BBD6FAC.htm) |
| ALIASEDIT | コマンドの短縮名（acad.pgp）を画面で作成・変更・削除する。 | （ダイアログ） | 公式 | × | T28 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-34DAD04D-7CA2-43B6-9287-885E61B7C918.htm) |
| DWGLOG | 図面ごとにアクセス履歴のログファイルを作る。 | dwglog.arx | 公式 | × | T01, T28 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-B63A635F-DA7D-4D84-8DE6-52861F03A180.htm) |
| EDITTIME | 図面を実際に編集していた時間を計測する。 | edittime.arx | 公式 | × | T01 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-7C2311B0-808D-4605-BE73-0A1500EE28D8.htm) |
| EXPLAN | ズーム倍率を変えずに指定 UCS の平面図表示にする（拡張 PLAN）。 | explan.lsp | 公式 | × | T00 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-3FD011D0-2AB5-4C46-8302-19F91DD2EC87.htm) |
| IMAGEAPP | IMAGEEDIT で使う画像編集ソフトを指定する。 | — | 公式 | × | T29 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-025B47FE-3A59-4BA4-8853-F9D34B80AE36.htm) |
| IMAGEEDIT | 選んだラスターイメージを外部の画像編集ソフトで開く。 | ix_edit.lsp（旧版） | 公式 | × | T29 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-D57BD5D4-FA6E-483E-BB72-6747964CC5B5.htm) |
| MKLTYPE | 選んだ図形から線種定義を作って .lin に保存・読込する。 | mkltype.lsp（旧版） | 公式 | × | T00 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-7C094008-385C-459D-818A-05A2169D13DF.htm) |
| MKSHAPE | 選んだ図形からシェイプ定義を作る。 | mkshape.lsp（旧版） | 公式 | × | T00 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-829B0626-36AB-443A-B53C-D7227297C6CE.htm) |
| MOVEBAK | バックアップ（.bak）の保存先フォルダを変更する。 | acetmbak.arx | 公式 | × | T28 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-7AE17A04-8D2D-4BCE-9FE9-175F5BFEA0B9.htm) |
| PLT2DWG | 旧 HPGL 形式の .plt を色を保ったまま図面に取り込む。 | plt2dwg.lsp（旧版） | 公式 | × | T30, T00 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-2D2ECCF3-1CD4-4115-A823-E4B7EC165A0F.htm) |
| PROPULATE | 図面プロパティ（DWGPROPS）の値を一括で更新・一覧・消去する（複数図面も可）。 | propulate.arx（旧版） | 公式 | × | T06, T02 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-BD03320F-3430-4C2F-80A3-AAC1167AF019.htm) |
| QQUIT | 開いている全図面を閉じて AutoCAD を終了する。 | qquit.lsp | 公式 | × | T28 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-1B0C65A9-F5F3-455E-B700-EA4912E3B2A5.htm) |
| REDIR | 外部参照・イメージ・シェイプ・文字スタイル・RTEXT の固定パスを一括で書き換える。 | redir.lsp | 公式 | × | T29 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-DA60459B-378F-4A27-BD1F-6290ACA7083D.htm) |
| REDIRMODE | REDIR の対象とする種類を設定する（-REDIRMODE あり）。 | redir.lsp | 公式 | × | T29 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-0E4D49B7-E701-428D-A279-A32797C2811C.htm) |
| REVERT | 現在の図面を保存せずに閉じて開き直す。 | revert.lsp | 公式 | × | T28 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-0F2A37BE-752F-4812-825D-FAF595192B7A.htm) |
| RTUCS | ポインタ操作で UCS を動的に回転させる。 | rtucs.lsp | 公式 | × | T21 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-2750036B-5E46-4D54-8023-8CB263294FE8.htm) |
| SAVEALL | 開いている全図面を保存する。 | saveall.arx | 公式 | × | T03, T28 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-C3E8083E-6C0D-4975-B05F-BCA5E9AE1FA7.htm) |
| SYSVDLG | システム変数を一覧・編集・保存・復元する。 | sysvdlg.arx | 公式 | × | T28 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-E79F7A56-E373-48EC-AEB7-652CEDBE26D7.htm) |
| TFRAMES | ワイプアウトとイメージの枠の表示を一括で切り替える。 | sprhatch.lsp | 公式 | × | T29, T11 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-088EFB42-AA6C-4C0F-8AD7-34C7615D10C4.htm) |
| XDATA | 図形に拡張データ（XDATA）を付ける。 | xdata.lsp | 公式 | × | T00, T13 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-F0299B36-232F-446E-9F81-98F300B36991.htm) |
| XDLIST | 図形に付いた拡張データを一覧表示する。 | xdata.lsp | 公式 | × | T00 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-B3926E8E-1477-4086-8244-C813EB05FF04.htm) |
| EXPRESSTOOLS | Express Tools のライブラリを読み込み、検索パスとメニューを設定する。 | acettest.fas | 公式 | × | T28 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-87BF0045-6446-48C6-8413-DE025596396E.htm) |
| EXPRESSMENU | Express メニューを読み込み・再構築して表示する。 | acettest.fas | 公式 | × | T28 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-217A106D-7D26-4960-BDD9-E17EFE427FDD.htm) |

### 開発者向け（4）

| コマンド | 何をするか | 定義ファイル | 状態 | LT | テーマ | 出典 |
|---|---|---|---|---|---|---|
| LSP | 読み込まれている AutoLISP のコマンド・関数・変数を一覧表示する。 | acetutil.fas | 公式 | × | T00 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-5B95C736-E2C4-4FC7-B623-C259A0D2F608.htm) |
| LSPSURF | LISP ファイルの中身を関数ごとに一覧表示する（LISP Surfer）。 | lspsurf.exe（旧版） | 公式 | × | T00 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-6AE44949-5301-424A-A91E-9FD1A824DC3D.htm) |
| JULIAN | DATE コマンドとユリウス日⇔暦日変換の LISP 関数群（CTOJ/DTOJ/JTOC/JTOD/JTOW）を含む。コマンドとしては入力しない。 | julian.lsp | 公式 | × | T00 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-65FBB1A0-F94D-4F75-A56D-3E5BD055ADF8.htm) |
| DUMPSHX | コンパイル済み SHX を SHP ソースに戻す（Windows のコマンドプロンプト用 .exe）。（AutoCAD のコマンドではない） | dumpshx.exe | 公式 | × | T00 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-CF541EED-CFBA-47EA-9A1A-CDE17D14FB20.htm) |

### Web（3）

| コマンド | 何をするか | 定義ファイル | 状態 | LT | テーマ | 出典 |
|---|---|---|---|---|---|---|
| SHOWURLS | 図面内のハイパーリンク（URL）を一覧表示・編集する。 | aceturl.lsp（旧版） | 公式 | × | T12, T30 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-3AEBE6CA-E53D-4857-81A6-4FABD9423A02.htm) |
| CHURLS | 選んだ図形の URL を変更する。 | aceturl.lsp（旧版） | 公式 | × | T12, T30 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-A12668EB-396F-4637-AC24-9975642E48F5.htm) |
| REPURLS | URL の文字列を検索・置換する。 | avip_url.lsp（旧版） | 公式 | × | T12, T30 | [help 2026](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-0F9B7467-74F3-4884-8DFA-747F0D6952E2.htm) |

## 3. 本体へ移動したコマンド

| コマンド | 本体に入った版 | 今の状態 | LT | テーマ | 出典 |
|---|---|---|---|---|---|
| LAYCUR（選んだ図形を現在の画層へ移す） | AutoCAD 2007（Express の画層ツールから移動） | 本体コマンド | ○ | T18 | [JTB World 2006](https://blog.jtbworld.com/2006/03/are-you-missing-some-express-tools.html), [cadforum](https://www.cadforum.cz/en/command.asp?cmd=LAYCUR) |
| LAYDEL / -LAYDEL（画層を中の図形ごと削除） | AutoCAD 2007（Express の画層ツールから移動） | 本体コマンド | ○ | T18 | [JTB World 2006](https://blog.jtbworld.com/2006/03/are-you-missing-some-express-tools.html), [cadforum](https://www.cadforum.cz/en/command.asp?cmd=LAYDEL) |
| LAYFRZ（選んだ図形の画層をフリーズ） | AutoCAD 2007（Express の画層ツールから移動） | 本体コマンド | ○ | T18 | [JTB World 2006](https://blog.jtbworld.com/2006/03/are-you-missing-some-express-tools.html), [cadforum](https://www.cadforum.cz/en/command.asp?cmd=LAYFRZ) |
| LAYISO（選んだ図形の画層だけを表示（他を非表示/ロック）） | AutoCAD 2007（Express の画層ツールから移動） | 本体コマンド | ○ | T18 | [JTB World 2006](https://blog.jtbworld.com/2006/03/are-you-missing-some-express-tools.html), [cadforum](https://www.cadforum.cz/en/command.asp?cmd=LAYISO) |
| LAYUNISO（LAYISO を元に戻す） | AutoCAD 2007（Express の画層ツールから移動） | 本体コマンド | ○ | T18 | [JTB World 2006](https://blog.jtbworld.com/2006/03/are-you-missing-some-express-tools.html), [cadforum](https://www.cadforum.cz/en/command.asp?cmd=LAYUNISO) |
| LAYLCK（選んだ図形の画層をロック） | AutoCAD 2007（Express の画層ツールから移動） | 本体コマンド | ○ | T18 | [JTB World 2006](https://blog.jtbworld.com/2006/03/are-you-missing-some-express-tools.html), [cadforum](https://www.cadforum.cz/en/command.asp?cmd=LAYLCK) |
| LAYULK（選んだ図形の画層のロック解除） | AutoCAD 2007（Express の画層ツールから移動） | 本体コマンド | ○ | T18 | [JTB World 2006](https://blog.jtbworld.com/2006/03/are-you-missing-some-express-tools.html), [cadforum](https://www.cadforum.cz/en/command.asp?cmd=LAYULK) |
| LAYMCH / -LAYMCH（図形を別の図形の画層へ合わせる） | AutoCAD 2007（Express の画層ツールから移動） | 本体コマンド | ○ | T18 | [JTB World 2006](https://blog.jtbworld.com/2006/03/are-you-missing-some-express-tools.html), [cadforum](https://www.cadforum.cz/en/command.asp?cmd=LAYMCH) |
| LAYMCUR（選んだ図形の画層を現在画層にする） | AutoCAD 2007（Express の画層ツールから移動） | 本体コマンド | ○ | T18 | [JTB World 2006](https://blog.jtbworld.com/2006/03/are-you-missing-some-express-tools.html), [cadforum](https://www.cadforum.cz/en/command.asp?cmd=LAYMCUR) |
| LAYMRG / -LAYMRG（画層を統合（図形を移して元画層を削除）） | AutoCAD 2007（Express の画層ツールから移動） | 本体コマンド | ○ | T18 | [JTB World 2006](https://blog.jtbworld.com/2006/03/are-you-missing-some-express-tools.html), [cadforum](https://www.cadforum.cz/en/command.asp?cmd=LAYMRG) |
| LAYOFF（選んだ図形の画層を非表示） | AutoCAD 2007（Express の画層ツールから移動） | 本体コマンド | ○ | T18 | [JTB World 2006](https://blog.jtbworld.com/2006/03/are-you-missing-some-express-tools.html), [cadforum](https://www.cadforum.cz/en/command.asp?cmd=LAYOFF) |
| LAYON（全画層を表示） | AutoCAD 2007（Express の画層ツールから移動） | 本体コマンド | ○ | T18 | [JTB World 2006](https://blog.jtbworld.com/2006/03/are-you-missing-some-express-tools.html), [cadforum](https://www.cadforum.cz/en/command.asp?cmd=LAYON) |
| LAYTHW（全画層をフリーズ解除） | AutoCAD 2007（Express の画層ツールから移動） | 本体コマンド | ○ | T18 | [JTB World 2006](https://blog.jtbworld.com/2006/03/are-you-missing-some-express-tools.html), [cadforum](https://www.cadforum.cz/en/command.asp?cmd=LAYTHW) |
| LAYVPI（選んだ図形の画層を他のビューポートでフリーズ） | AutoCAD 2007（Express の画層ツールから移動） | 本体コマンド | ○ | T18 | [JTB World 2006](https://blog.jtbworld.com/2006/03/are-you-missing-some-express-tools.html), [cadforum](https://www.cadforum.cz/en/command.asp?cmd=LAYVPI) |
| LAYWALK（画層を1つずつ表示して確認するダイアログ） | AutoCAD 2007（Express の画層ツールから移動） | 本体コマンド | ○ | T18 | [JTB World 2006](https://blog.jtbworld.com/2006/03/are-you-missing-some-express-tools.html), [cadforum](https://www.cadforum.cz/en/command.asp?cmd=LAYWALK) |
| COPYTOLAYER / -COPYTOLAYER（図形を別画層へ複写） | AutoCAD 2007（Express の画層ツールから移動） | 本体コマンド | ○ | T18 | [JTB World 2006](https://blog.jtbworld.com/2006/03/are-you-missing-some-express-tools.html), [cadforum](https://www.cadforum.cz/en/command.asp?cmd=COPYTOLAYER) |
| CHSPACE（図形をモデル／ペーパー空間の間で見た目を保って移す） | AutoCAD 2007 | 本体コマンド | ○ | T05 | [JTB World 2006](https://blog.jtbworld.com/2006/03/are-you-missing-some-express-tools.html), [AUGI](https://forums.augi.com/archive/index.php/t-44525.html) |
| OVERKILL / -OVERKILL（重なった図形・重複線を削除） | AutoCAD 2012 | 本体コマンド（Express リファレンスからも消えた） | ○ | T08, T10 | [cadforum](https://www.cadforum.cz/en/command.asp?cmd=OVERKILL) |
| NCOPY（ブロック／外部参照の入れ子図形を複写） | AutoCAD 2012 | 本体コマンド | ○ | T19, T29 | [cadforum](https://www.cadforum.cz/en/command.asp?cmd=NCOPY) |
| TXT2MTXT（1行文字→マルチテキスト） | AutoCAD 2017.1 | 本体コマンド（ただし Express リファレンスにも残っている） | ○ | T12 | [cadforum](https://www.cadforum.cz/en/command.asp?cmd=TXT2MTXT), [LT 2026 help](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-LT/files/GUID-1E68C8B2-520F-4084-BD20-51DC4A32A7E5.htm) |
| REVCLOUD（雲マーク） | R14 Bonus → 2000 Express → 2000i〜2002 頃に本体 | 本体コマンド | ○ | T09 | [cadforum](https://www.cadforum.cz/en/command.asp?cmd=REVCLOUD), [Scan2CAD](https://www.scan2cad.com/blog/cad/autocad-revision-cloud/) |
| WIPEOUT（ワイプアウト） | 2004 頃（ドイツ語版 FAQ は「2005 では本体の WIPEOUT で作る」と記載） | 本体コマンド | ○ | T11 | [cadforum](https://www.cadforum.cz/en/command.asp?cmd=WIPEOUT), [ET2007 独語 FAQ](http://www.cadensaege.de/ET2K7/html/faq.htm) |

**参考（部分的な移動・置き換え）**

- ARCTEXT：AutoCAD（フル版）では今も Express Tool 扱いだが、**LT 2023 から LT 本体のコマンド**として入った（[ARKANCE](https://ukcommunity.arkance.world/hc/en-us/articles/21550793827218-AutoCAD-LT-2023-now-has-the-ARCTEXT-Express-Tool-command), [LT 2026 help](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-LT/files/GUID-A1031C92-383E-41E7-80E0-9673D987EF2F.htm)）。
- FLATTEN：Mac 版 AutoCAD では本体コマンド（cadforum）。
- 本体の新機能で役目が重なったもの（Express 側は残っている）：BCOUNT ↔ COUNT（2022）、TEXTMASK ↔ マルチテキストの背景マスク、TJUST ↔ JUSTIFYTEXT（2002）、TSCALE ↔ SCALETEXT（2002）、MPEDIT ↔ PEDIT の「複数」、TREX ↔ TRIM/EXTEND、QLATTACH 系 ↔ MLEADER（2008）。
- BATTMAN・ATTSYNC・LAYTRANS・CLOSEALL も「Express Tools から AutoCAD 2002 に入った」と書く古い資料（oocities の移行メモ）があるが、裏付けが弱いので数に入れていない（要確認）。

## 4. 非公開・隠しコマンド（根拠つき）

「非公開」＝Express Tools の中に定義されていて入力すれば動くが、公式リファレンスに**独立したページが無い**もの。確度：◎＝複数の独立した資料で確認、○＝1〜2資料＋状況証拠、△＝コマンド一覧に名前があるだけ。

| コマンド | 何をするか | 定義場所（根拠） | 確度 | LT | テーマ | 出典 |
|---|---|---|---|---|---|---|
| **TSPACEINVADERS** | 選んだ文字（TEXT/MTEXT/RTEXT/属性定義/属性付きブロック）のうち、**他の図形が重なって“侵入”しているものだけを選択セットにする**。1件ずつズームして確認するオプションあり。そのあと TEXTMASK などで処理する使い方。 | **tscale.lsp**（ドイツ語版 ET2007 ヘルプの末尾に定義ファイル名 “tscale.lsp”、「英語版ヘルプに無かったため翻訳チームが新しく書いた」と注記）。acetauto.lsp で acet-autoload2 により autoload 登録（検索結果の抜粋より）。CADTutor の不具合スレッドでは実行中に `ACET-SS-FILTER` が見つからないエラー＝acet 関数に依存 | ◎ | × | T08, T11 | [cadforum 辞典](https://www.cadforum.cz/en/command.asp?cmd=TSPACEINVADERS), [cadforum tip](https://www.cadforum.cz/en/do-you-know-the-autocad-command-space-invaders-tip8121), [HowToAutoCAD](https://www.howtoautocad.com/posts/the-tspaceinvaders-command), [ET2007 独語](http://www.cadensaege.de/ET2K7/html/tspaceinvaders.htm), [CADTutor](https://www.cadtutor.net/forum/topic/61796-tspaceinvaders-command-error-message/), [autocadtips1](https://autocadtips1.com/2010/12/03/tspaceinvaders/), [Carlson 比較表](https://web.carlsonsw.com/files/knowledgebase/kbase_attach/1315/AutoCAD%20Vs%20IntelliCAD%20Comparison%20Spreadsheet.pdf) |
| FASTSEL | FS の別名（接している図形を選択）。 | fastsel.lsp（2026 ヘルプの FS ページの File 欄、独語版にも「'FS / FASTSEL」） | ◎ | × | T00, T08 | [cadforum](https://www.cadforum.cz/en/command.asp?cmd=FASTSEL), [ET2007 独語](http://www.cadensaege.de/ET2K7/html/fastselect.htm), Carlson 比較表 |
| FSMODE | FS/FASTSEL で「接している図形の、さらに接している図形」まで連鎖して選ぶかを切り替える。 | fastsel.lsp。FS のページ本文に名前だけ出る（独立ページ無し） | ◎ | × | T00 | [help 2026 FS](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-A4FBF4EC-DE23-46A2-A576-AEED0E9847D4.htm), cadforum, Carlson 比較表 |
| DATE | 現在の日時を「曜日 YYYY/M/D HH:MM:SS.msec」形式で表示する。 | julian.lsp（JULIAN ページの中でだけ説明） | ◎ | × | T00 | [help 2026 JULIAN](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-65FBB1A0-F94D-4F75-A56D-3E5BD055ADF8.htm), cadforum |
| RTEXTAPP | RTEXT/RTEDIT で使うテキストエディタを指定する。 | rtext.arx 系（RTEDIT ページの本文に名前だけ出る） | ◎ | × | T13 | [help 2026 RTEDIT](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-4133A11F-C914-43F4-8ADB-B4F0E01AEA73.htm), cadforum, Carlson 比較表 |
| VARS2SCR | 現在のシステム変数の値を、再現用のスクリプト（.scr）に書き出す。 | acadinfo.lsp（(load "acadinfo") の後に使う、と AUGI などで紹介） | ○ | × | T28 | [cadforum](https://www.cadforum.cz/en/command.asp?cmd=VARS2SCR), [AUGI](https://forums.augi.com/archive/index.php/t-59922.html), Carlson 比較表 |
| ADDVARS2SCR | VARS2SCR の書き出し対象にシステム変数を追加する。 | acadinfo.lsp（推定。VARS2SCR と対） | ○ | × | T28 | [cadforum](https://www.cadforum.cz/en/command.asp?cmd=ADDVARS2SCR), Carlson 比較表 |
| IMAGEOVERLAP | SUPERHATCH でイメージを敷き詰めるときの重なり幅を設定する。 | superhatch 系（sprhatch.lsp と推定） | ○ | × | T00 | [cadforum](https://www.cadforum.cz/en/command.asp?cmd=IMAGEOVERLAP), Carlson 比較表, BricsCAD 互換ヘルプ |
| ACETUCS-TOP / -BOTTOM / -FRONT / -BACK / -LEFT / -RIGHT（6） | UCS を上・下・前・後・左・右の面に平行に切り替える（Express の UCS ボタン用の内部コマンド）。 | 定義ファイルは未確認（UCS 関係なので rtucs.lsp 付近と推定）。AutoCAD 側のコマンド一覧（Carlson 比較表で “acad only”）に 6 つとも載り、BricsCAD の Express 互換実装も同名で再現している | ○ | × | T00 | Carlson 比較表, [BricsCAD 一覧](https://help.bricsys.com/en-us/document/bricscad/express-tools/express-tools-command-overview) |
| ETBUG（未確認） | 名前から Express Tools の不具合報告・診断用と思われるが、説明の資料は見つからない。 | Carlson 比較表の AutoCAD コマンド一覧にだけ名前がある | △ | ？ | T00 | Carlson 比較表 |
| LSPDUMP（未確認） | 名前から LISP の情報を書き出す開発用と思われるが、説明の資料は見つからない（Express の LSP コマンドとの関係も不明）。 | Carlson 比較表の AutoCAD コマンド一覧にだけ名前がある | △ | ？ | T00 | Carlson 比較表 |

**BricsCAD の互換版にだけあるもの（AutoCAD 側では確認できず・数に入れない）**：SAVE-CLOSEALL、USAVE-CLOSEALL、XDEDIT。BricsCAD の Express Tools は cadwiesel 社との協力で作られた独自の再実装なので、AutoCAD にない追加コマンドがある。

### 「SPACEINVADER」について（調べた結果）

- **「SPACEINVADER」「SPACEINVADERS」という名前のコマンドは見つからなかった。** 実在するのは **`TSPACEINVADERS`**（頭に T が付く。T＝Text の意味で、TSCALE・TJUST・TCASE などと同じ命名）。
- **ゲーム（イースターエッグ）ではない。** 名前はゲームの「スペースインベーダー」のもじりで、「文字の領域（space）に侵入（invade）している図形」を探す、という意味。やることは **他の図形と重なっている文字を探して選択セットにするだけ**（移動や修正はしない）。
- 公式の Express Tools リファレンス（2015〜2027）には**一度も載っていない**隠しコマンド。ドイツ語版 ET2007 ヘルプの翻訳チームが「英語版ヘルプに無かったので新しく書いた」と注記している。
- 定義は **tscale.lsp**（TSCALE・PSTSCALE と同じファイル）。導入は AutoCAD 2004 の Express Tools から（cadforum）。LT 不可。コアコンソールでも使えない。
- 流れ：`TSPACEINVADERS` → 文字を含めて選択 → 「重なりのある文字が n 件」→「1 件ずつ確認しますか [Y/N] <N>」→ 見つかった文字が選択された状態で終了 → `TEXTMASK` で「前回（P）」を選べばまとめてマスクできる。
- 周りの話：AutoCAD の本当のイースターエッグとしては、ADN DevBlog の「AutoCAD 2014 のすごいイースターエッグ」（2013 年 4 月の記事。検索結果の要約では「Call of Duty をエミュレーションで遊べる」という内容で、冗談記事と見られる。現在ブログは閉鎖され本文は確認できず）が話題になった程度で、Express Tools の中にゲームがあるという資料は無い。

## 5. 廃止されたもの

今の Express Tools リファレンスにも、AutoCAD 2020 前後のコマンド一覧（Carlson 比較表）にも無いもの。廃止の版がはっきりしないものは「推定」と書いた。

| コマンド | 何をしていたか | 登場 | 廃止・置き換え | テーマ | 出典 |
|---|---|---|---|---|---|
| LMAN / -LMAN | 画層の状態を名前を付けて保存・復元・.lay に書き出す画層マネージャ。 | R14 Bonus | **2008** で本体の画層状態管理（LAYERSTATE）に置き換え（LMAN の状態は自動変換） | T18, T28 | [Autodesk サポート](https://www.autodesk.com/support/technical/article/caas/sfdcarticles/sfdcarticles/english-has-detected-LMAN-Express-Tools-layer-states-and-has-automatically-converted-them-to-AutoCAD-layer-states-in-AutoCAD-and-verticals.html), [ET2007 独語](http://www.cadensaege.de/ET2K7/html/lman.htm) |
| LMANMODE | LMAN の復元オプション設定。 | 2000 | LMAN と一緒に廃止（2008） | T18 | [cadforum](https://www.cadforum.cz/en/command.asp?cmd=LMANMODE) |
| PACK | 図面と関連ファイルをまとめる「Pack'n Go」。 | R14 | 本体の ETRANSMIT（2000i）に置き換え（推定） | T29 | [cadforum](https://www.cadforum.cz/en/command.asp?cmd=PACK) |
| FULLSCREENON / FULLSCREENOFF / FULLSCREENOPTIONS | 作図領域を全画面にする。 | 2000 | 本体の CLEANSCREENON/OFF（2004）に置き換え（推定） | T28 | [cadforum](https://www.cadforum.cz/en/command.asp?cmd=FULLSCREENON) |
| DCPROPS | ダブルクリック時の動作を設定する。 | 2000 | 本体の DBLCLKEDIT（2002）と CUI のダブルクリック動作に置き換え（推定） | T28 | [cadforum](https://www.cadforum.cz/en/command.asp?cmd=DCPROPS) |
| PLJOIN / PLJOINMODE | 離れたポリラインをすき間許容で結合する。 | 2000 | PEDIT の結合（許容距離）と JOIN（2006）に置き換え（推定） | T00, T08 | [cadforum](https://www.cadforum.cz/en/command.asp?cmd=PLJOIN) |
| EXC / EXCP / EXF / EXP / EXW / EXWP | 「〜以外」を選ぶ選択ツール（窓の外・ポリゴンの外・フェンスに触れない・前回以外・窓内以外・ポリゴン内以外）。 | 2000 | 廃止（時期は推定で 2004 前後）。BricsCAD 互換版には今もある | T00 | [cadforum](https://www.cadforum.cz/en/command.asp?cmd=EXWP), [BricsCAD EXCP](https://help.bricsys.com/en-us/document/command-reference/e/excp-command-express-tools) |
| CHT | 文字の一括変更（高さ・内容など）。 | R14 Bonus | 廃止（プロパティパレット等で代替、推定） | T12 | [cadforum](https://www.cadforum.cz/en/command.asp?cmd=CHT) |
| TEDIT | 注釈（文字）の編集。 | 2000 | 廃止（本体の TEXTEDIT/DDEDIT で代替、推定） | T12 | [cadforum](https://www.cadforum.cz/en/command.asp?cmd=TEDIT) |
| LAYVPMODE | 画層ツールのビューポート用の設定（詳しい資料なし）。 | 2004 | 画層ツールが本体へ移った 2007 で消えたと推定 | T18 | [cadforum](https://www.cadforum.cz/en/command.asp?cmd=LAYVPMODE) |

件数：LMAN, -LMAN はまとめて 1、LMANMODE 1、PACK 1、FULLSCREEN 系 3、DCPROPS 1、PLJOIN 系 2、EX 系 6、CHT 1、TEDIT 1、LAYVPMODE 1 ＝ **18**。

**旧式（Obsolete）だがまだ入っているもの**：BTRIM、BEXTEND、TREX、QLATTACH、QLATTACHSET、QLDETACHSET（2026 ヘルプに “Obsolete” の記載）。CDORDER のページにも “Handles (Obsolete)” というオプション名の記載がある。

## 6. LISP 開発の観点での注目点

### 6-1. 中身が参考になる関数群（acet-*）

- **acetutil.arx 系（ヘルプあり・約 50 関数）**：acet-file-*（ファイルのコピー・移動・フォルダ作成・検索）、acet-reg-*（レジストリ）、acet-ini-*（INI）、acet-str-*（正規表現つき検索・置換・書式）、acet-sys-*（外部プログラム起動・待機・スリープ・キー状態）、acet-ui-*（メッセージボックス・フォルダ選択・進捗バー・複数行エディタ）、acet-ss-drag-*（選択セットの移動・回転・尺度のドラッグプレビュー）。Autodesk の VS Code 拡張（AutoLispExt）のキーワード一覧にも acet 関数・定数が 82 個入っている。
- **acetutil.fas / acetutil2〜4.fas 系（ヘルプなし・非常に多い）**：acet-error-init / acet-error-restore（エラー処理とシステム変数の保存・復元の定番）、acet-ss-*（選択セット、例：TSPACEINVADERS が使う acet-ss-filter）、acet-geom-*（幾何計算）、acet-layer-*、acet-pline-*、acet-ucs-*、acet-block-*、acet-list-*、acet-dict-*、acet-xdata 系、acet-ui-progress など。BricsCAD は V14 からこれらを本体の関数として実装している（＝よく使われている証拠）。
- 読み方の注意：Express フォルダの .lsp はテキストで読めるので**考え方の勉強**にはなるが、Autodesk の著作物なので**そのまま配布・転載しない**。
- 依存のリスク：acet-* を使った LISP は **LT（2024 以降の LISP 対応 LT も）では動かない**、Express Tools を入れていない PC や読み込み前だと `no function definition: ACET-...` になる（JTB World・CADTutor に多数の事例）。配る LISP では acet-* に頼らず自前の関数にするのが安全。

### 6-2. Express にあるので新しく作る意味が薄いもの

| やりたいこと | Express で足りる | テーマ |
|---|---|---|
| ブロック数を数える | BCOUNT（本体 COUNT も） | T16 |
| 文字に連番 | TCOUNT | T15 |
| 大文字/小文字・位置合わせ・向き・高さの一括変更 | TCASE / TJUST / TORIENT / TSCALE / PSTSCALE | T11, T12 |
| 1行文字→マルチテキスト | TXT2MTXT（本体） | T12 |
| 属性の一括変更・Excel 往復の基本 | GATTE / ATTOUT / ATTIN | T14 |
| 属性を文字に残して分解 | BURST | T19 |
| ブロックの差し替え | BLOCKREPLACE | T19 |
| 重複図形の削除 | OVERKILL（本体） | T08, T10 |
| 固定パスの書き換え | REDIR | T29 |
| 全図面保存・全部閉じる | SAVEALL / QQUIT | T28 |
| ビューポートをそろえる・レイアウト統合 | VPSYNC / LAYOUTMERGE / ALIGNSPACE | T05 |
| 円弧に沿った文字 | ARCTEXT | T22 |
| 文字と重なる図形の検出 | TSPACEINVADERS | T08, T11 |

### 6-3. Express の弱点（＝LISP を作る余地があるところ）

- **ほぼ全部「今開いている 1 図面だけ」**：ATTOUT/ATTIN、BCOUNT、REDIR、TCOUNT などは複数図面・フォルダ一括ができない（PROPULATE だけ例外的に複数図面に対応）。→ T02（図面を開かずに一括）・T03（複数図面にスクリプト）の余地が大きい。
- **TSPACEINVADERS は見つけるだけ**：重なった文字を選ぶだけで、ずらす・引出線を付けるなどの自動回避はしない。→ T11（文字の重なりを自動で避ける）の余地。
- **ARCTEXT は円弧だけ**：ポリライン・スプラインに沿わせることはできない。→ T22。
- **ATTOUT はタブ区切りテキスト**：Excel 直接・複数図面・複数ブロックの一覧表にはならない。→ T14 / T23。
- **BCOUNT は表を作らない**：結果はコマンド行の一覧だけで、表（TABLE）や画層別・属性別の集計にならない。→ T16。
- **DIMREASSOC は直すだけ**：上書き寸法を元に戻すが、「どこが上書きか」を一覧や印で知らせる機能はない。→ T07（検図）。
- **OVERKILL は完全な重なりだけ**：わずかなすき間・端点の不一致・角度のずれは見つけない。→ T08。
- **リアクター（自動処理）が無い**：DWGLOG/EDITTIME 以外は手で実行するツールだけ。→ T01。
- **LT では使えない・正式サポート外・2015 年以降機能追加なし**：LT ユーザー向けに同じ機能を LISP で作る意味はある（LT 2024 以降は LISP が動くため）。

## 7. 出典

- [Autodesk AutoCAD 2026 Help — Express Tools Reference](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-CC626232-DC3A-45E1-B3C8-DF3F79186DE2.htm)
- [同 2027 / 2025 / 2020 / 2015 版（同じ GUID、85 項目で同一）](https://help.autodesk.com/cloudhelp/2027/ENU/AutoCAD-Core/files/GUID-CC626232-DC3A-45E1-B3C8-DF3F79186DE2.htm)
- [Autodesk AutoCAD 2026 Help — To Work With Express Tools](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-F2608E41-85A8-49F5-ACD3-811FAB18C868.htm)
- [AutoCAD LT 2026 Help — TXT2MTXT (Command)](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-LT/files/GUID-1E68C8B2-520F-4084-BD20-51DC4A32A7E5.htm)
- [AutoCAD LT 2026 Help — ARCTEXT (Command)](https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-LT/files/GUID-A1031C92-383E-41E7-80E0-9673D987EF2F.htm)
- [Autodesk サポート — Are Express Tools available in AutoCAD LT?](https://www.autodesk.com/support/technical/article/caas/sfdcarticles/sfdcarticles/Express-Tools-and-AutoCAD-LT.html)
- [Autodesk サポート — LMAN の画層状態の自動変換](https://www.autodesk.com/support/technical/article/caas/sfdcarticles/sfdcarticles/english-has-detected-LMAN-Express-Tools-layer-states-and-has-automatically-converted-them-to-AutoCAD-layer-states-in-AutoCAD-and-verticals.html)
- [ARKANCE UK — AutoCAD LT 2023 now has the ARCTEXT Express Tool command](https://ukcommunity.arkance.world/hc/en-us/articles/21550793827218-AutoCAD-LT-2023-now-has-the-ARCTEXT-Express-Tool-command)
- [CAD Forum — AutoCAD Express Tools commands（118 件の一覧・導入版・LT 可否）](https://www.cadforum.cz/en/command.asp?ET=)
- [CAD Forum — Do you know the AutoCAD command "space invaders"?](https://www.cadforum.cz/en/do-you-know-the-autocad-command-space-invaders-tip8121)
- [HowToAutoCAD — The TSPACEINVADERS Command](https://www.howtoautocad.com/posts/the-tspaceinvaders-command)
- [AutoCAD Tips — TSPACEINVADERS](https://autocadtips1.com/2010/12/03/tspaceinvaders/)
- [CADTutor — TSPACEINVADERS command error message](https://www.cadtutor.net/forum/topic/61796-tspaceinvaders-command-error-message/)
- [Express Tools 2007 ドイツ語版ヘルプ（ET2GP）— 目次（各ページ末尾に定義ファイル名）](http://www.cadensaege.de/ET2K7/html/)
- [同 — TSPACEINVADERS / TEXTKONTAKT](http://www.cadensaege.de/ET2K7/html/tspaceinvaders.htm)
- [同 — FAQ（画層ツール・CHSPACE の本体移動、WIPEOUT）](http://www.cadensaege.de/ET2K7/html/faq.htm)
- [JTB World — Are you missing some Express Tools commands in AutoCAD 2007?](https://blog.jtbworld.com/2006/03/are-you-missing-some-express-tools.html)
- [AUGI — Express Tools Change Space command in AutoCAD 2007](https://forums.augi.com/archive/index.php/t-44525.html)
- [Carlson — AutoCAD vs IntelliCAD Comparison Spreadsheet（AutoCAD 側コマンド一覧）](https://web.carlsonsw.com/files/knowledgebase/kbase_attach/1315/AutoCAD%20Vs%20IntelliCAD%20Comparison%20Spreadsheet.pdf)
- [BricsCAD — Express tools command overview](https://help.bricsys.com/en-us/document/bricscad/express-tools/express-tools-command-overview)
- [BricsCAD Developer Reference — ExpressTools API Support](https://developer.bricsys.com/bricscad/help/en_US/V23/DevRef/source/ExpressToolsAPISupport.htm)
- [AfraLISP — An Introduction to AcetUtil Functions](https://www.afralisp.net/archive/lisp/acet-utils.htm)
- [Autodesk AutoLispExt — alllispkeys.txt（acet 関数名）](https://github.com/Autodesk-AutoCAD/AutoLispExt/blob/main/extension/data/alllispkeys.txt)
- [JTB World — no function definition: ACET-LOAD-EXPRESSTOOLS](https://blog.jtbworld.com/2024/11/solution-to-error-no-function.html)
- [Jefferson Lab — AutoCAD 2000 Series Level III Express Tools（2000 版の構成）](https://www.jlab.org/accel/eecad/acad/advanced_exp_tools.pdf)
- [CAD nauseam / Eng-Tips / Archinect（Bonus→Express の歴史、2000i・2004 の同梱状況）](https://www.eng-tips.com/threads/express-tools.3706/)
- [Oocities — Migrating Bonus and Express Tools（古い移行メモ・要確認扱い）](https://www.oocities.org/wpsmoke/acadmdt/bfane/3dtextobjects/bonus_express_tools.html)
- [ADN DevBlog — AutoCAD 2014's Incredible Easter Egg Surprise](https://adndevblog.typepad.com/autocad/2013/04/autocad-2014s-incredible-easter-egg-surprise.html)

各コマンドの cadforum ページは `https://www.cadforum.cz/en/command.asp?cmd=<コマンド名>`。
