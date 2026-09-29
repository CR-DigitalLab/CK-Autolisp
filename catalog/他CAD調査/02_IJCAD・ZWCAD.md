# IJCAD・ZWCAD にあって AutoCAD 2027（本体＋Express Tools）に無い／弱い 2D 機能

調査日：2026-09-29。IJCAD は公式カタログ（2026）、「PLUS ツール・拡張ツール 使い方一覧」（公式PDF、2022年版）、公式ヘルプセンター、バージョンアップ概要（2024〜2026）をもとにした。ZWCAD は ZWSOFT 公式の新機能ページ・リリースノート（2025）・機能紹介ページをもとにした。説明は言い換えで、原文のコピーではない。

- 略記：PLUS-PDF ＝ https://ijcad-subscription.s3.ap-northeast-1.amazonaws.com/IJCAD_PLUS%E3%83%BB%E6%8B%A1%E5%BC%B5%E3%83%84%E3%83%BC%E3%83%AB_%E4%BD%BF%E3%81%84%E6%96%B9%E4%B8%80%E8%A6%A7_2022-09-20_00-21-19_496.pdf （p.は資料内ページ）
- IJCAD の PLUS／拡張ツールは STD・PRO グレード限定。資料内で「独自機能」と書かれているものを主に拾い、「互換機能」（Express Tools 相当）は原則として除いた。

| 製品 | コマンド／機能名（原語） | 何ができるか（やさしい日本語で1〜2文） | 分類 | AutoCADとの差（ない／一部ある＝どう違うか） | LISPで再現 | 出典URL |
|---|---|---|---|---|---|---|
| IJCAD | TRIMDLINE（包絡） | 交わっている線をまとめて選ぶと、1回の操作で Jw_cad の「包絡」のように角や T 字の余分をきれいに整える。対象は線分だけ。 | 作図・編集 | ない（TRIM／FILLET を何度も繰り返す必要がある） | 可 | https://support.ijcad.jp/hc/ja/articles/900006156263 ／ IJCAD2026カタログ p.13 https://ijcad.jp/wp/wp-content/uploads/2026/07/IJCAD2026.pdf |
| IJCAD | IJTANCIR3ENT／TANCIR3ENT（3図形接円） | 3つの図形に接する円を描く。答えが複数あるときは候補を順に仮表示して選べる。 | 作図・編集 | 一部ある（CIRCLE 3P＋接線スナップで可能だが、候補を切り替えながら選ぶ仕組みはない） | 簡易なら可 | PLUS-PDF p.117 ／ https://support.ijcad.jp/hc/ja/articles/900005211426 |
| IJCAD | IJTANCIR2ENT（2図形接円） | 2つの図形に接する半径指定の円を描く。線を延長した先でできる円も候補に含められる。 | 作図・編集 | 一部ある（CIRCLE の接点・接点・半径はあるが、延長先の候補を出す機能はない） | 簡易なら可 | PLUS-PDF p.115 |
| IJCAD | OUTLINE（外形線） | 選んだ図形の外まわりをなぞった外形線を作る。触れ合っている図形はひとかたまりとして1本の外形にする。 | 作図・編集 | ない（BOUNDARY は内側をクリックする方式で、図形の外形を直接は作れない） | 簡易なら可 | https://support.ijcad.jp/hc/ja/articles/36390004181273 ／ IJCAD2026カタログ p.16「外形作成」 |
| IJCAD | GC_BOOLOP（ポリラインのブール演算） | 閉じたポリライン同士を「足す・引く・重なり部分だけ残す」ができ、結果もポリラインで返る。 | 作図・編集 | 一部ある（REGION→UNION 等で可能だが、手順が多く結果がリージョンになる） | 簡易なら可 | PLUS-PDF p.179 |
| IJCAD | BREAKOBJECT（オブジェクト分割） | 選んだ図形同士を交点ですべて切り分ける。切れ目に隙間をあけることもできる。 | 作図・編集 | ない（BREAKATPOINT は1か所ずつ） | 可 | PLUS-PDF p.98 |
| IJCAD | CBK（交差切断） | 基準線を1本選び、それと交わる複数の線を交点で切り離す。 | 作図・編集 | ない（BREAKATPOINT を交点ごとに繰り返す必要がある） | 可 | PLUS-PDF p.130 |
| IJCAD | GXFSS（伸縮接続） | 線を選び、基準線を選ぶと、基準線まで自動で延長または切り詰める（Jw_cad の「伸縮」に近い）。 | 作図・編集 | 一部ある（TRIM／EXTEND を使い分ける必要がある。1コマンドで両方はしない） | 可 | PLUS-PDF p.106 |
| IJCAD | DYJT（部分拡大／縮小） | 範囲を囲んだ部分を、倍率を変えて別の場所に複写する（詳細図づくり）。 | 作図・編集 | ない（COPY→SCALE の2段階。2D の範囲切り出し拡大はない） | 可 | PLUS-PDF p.109 |
| IJCAD | FREESCALE（自由スケーリング） | X と Y で別々の倍率をかけたり、指定した枠に収まるように拡大縮小したりできる。 | 作図・編集 | ない（SCALE は縦横同じ倍率のみ。非等倍はブロック化の裏技が必要） | 簡易なら可 | PLUS-PDF p.110 |
| IJCAD | DLINE（二重線） | 線や円弧の二重線を描く。結果はマルチラインではなく、角ごとにばらばらの線分になる。 | 作図・編集 | 一部ある（MLINE はあるが、後で編集しにくい専用図形になる） | 可 | PLUS-PDF p.113 |
| IJCAD | SPLINE2LINE（スプラインを線分に変換） | スプラインを細かい線分に置き換える。 | 作図・編集 | 一部ある（PEDIT でポリライン化→分解の2段階が必要） | 可 | PLUS-PDF p.101 |
| IJCAD | IJLEAD1／IJLEAD2（片矢印・両矢印） | 折れ線の始点だけ、または両端に矢印が付いた線を描く。 | 寸法・引出線 | 一部ある（引出線で片矢印は描けるが、両端矢印の折れ線はない） | 可 | PLUS-PDF p.121, p.123 |
| IJCAD | IJWDIST（距離記入） | 2点をクリックすると、その距離の数値を文字として図面に置く。 | 寸法・引出線 | ない（寸法線なしで距離の数値だけ置く機能はない） | 可 | PLUS-PDF p.119 |
| IJCAD | DIMUPDATE（寸法スタイル更新） | 見本の寸法のスタイルを別の寸法に写し、同じスタイルの寸法もまとめて更新する。 | 寸法・引出線 | 一部ある（MATCHPROP は写した先だけ。スタイル定義ごと合わせる動きはない） | 簡易なら可 | PLUS-PDF p.79 |
| IJCAD | GC_DZTEXT（連続文字） | 選んだ文字の数字や英字を1つずつ増やしながら、クリックで次々に複写していく（No.1→No.2→…）。 | 文字 | ない（TCOUNT は既存の文字に番号を振るだけで、置きながら増やす機能はない） | 可 | PLUS-PDF p.33 |
| IJCAD | TEXTONLINE（線上文字） | 線・円弧・スプラインの上に文字を置く。クリック位置、等分割、一定間隔、中点などの置き方を選べる。 | 文字 | ない（ARCTEXT は円弧専用。線に沿って等間隔に文字を並べる機能はない） | 可 | PLUS-PDF p.35 |
| IJCAD | TEXTMATCH（文字マッチング） | 見本の文字から「内容・色・高さ・角度・位置」などを選んで、ほかの文字に写す。 | 文字 | 一部ある（MATCHPROP は文字の内容や位置を写せない） | 可 | PLUS-PDF p.39 |
| IJCAD | CHANGETEXT（文字変更） | 文字の高さ・位置合わせ・位置・回転・スタイル・内容・幅を、まとめて、または1つずつ続けて変える。 | 文字 | 一部ある（CHANGE やプロパティでできるが、項目を順に続けて直す流れはない） | 可 | PLUS-PDF p.28 |
| IJCAD | EDTXT（文字の高さ・幅係数・傾斜角度を一括変更） | 選んだ文字の高さ・幅係数・傾き・回転を、続けて入力して一度に変える。 | 文字 | 一部ある（プロパティで可能。コマンドライン1本で済む点が速い） | 可 | PLUS-PDF p.43 |
| IJCAD | CHGSTY（文字スタイル変更） | クリックした文字を、今の文字スタイルに次々と切り替える。 | 文字 | 一部ある（プロパティで可能だが、クリックだけで次々には変えられない） | 可 | PLUS-PDF p.44 |
| IJCAD | WZDD（文字列切断） | 1つの文字（TEXT）を、指定した位置で2つの文字に切り分ける。 | 文字 | ない | 可 | PLUS-PDF p.46 |
| IJCAD | WJSR（ファイルから読み込み） | テキストファイルの各行を、高さと行間を指定して1行ずつの文字として図面に置く。 | 文字 | 一部ある（MTEXT の読み込みはマルチテキスト1個になる。1行ずつの TEXT にはならない） | 可 | PLUS-PDF p.45 |
| IJCAD | KLL01（集計処理） | 選んだ文字の中の数値を合計して、結果を文字として書き込む。 | 文字 | ない（表の外の文字を足し算する機能はない） | 可 | PLUS-PDF p.159 |
| IJCAD | MMTEXT（拡張テキストエディタ） | 特殊記号の入力や、テキストファイルの読み書きができる専用の文字入力画面。 | 文字 | 一部ある（MTEXT エディタでも記号は入るが、ファイル書き出しはない） | 簡易なら可 | PLUS-PDF p.41 |
| IJCAD | ATTINC（属性値の増分） | 属性付きブロックの番号などを、選んだ順や同名ブロック全部に対して自動で1つずつ増やす。 | ブロック・属性 | ない | 可 | PLUS-PDF p.65 |
| IJCAD | BLOCKBREAK（部分削除ブロック） | ブロックを置くと、その下にある線を自動で切り取るか隠す（記号の下の線を抜く）。 | ブロック・属性 | ない（ワイプアウトを仕込んだブロックで似せるのが限界。線自体は切れない） | 簡易なら可 | PLUS-PDF p.63 |
| IJCAD | BCHGCOL（ブロック色変更） | ブロック定義の中身の色を、ブロックエディタを開かずに一括で変える（同名ブロック全部に反映）。 | ブロック・属性 | ない（SETBYLAYER は ByLayer 化のみ。任意色へは BEDIT が必要） | 可 | PLUS-PDF p.69 |
| IJCAD | BCHGLAY（ブロック画層変更） | ブロックとその中身の図形の画層を、一緒に指定の画層へ変える。 | ブロック・属性 | ない（中身の画層は BEDIT で直すしかない） | 可 | PLUS-PDF p.73 |
| IJCAD | BCHGHEI／BCHGANG（ブロック文字高さ・角度変更） | ブロックの中にある文字だけ、高さや角度を一括で変える。 | ブロック・属性 | ない | 可 | PLUS-PDF p.71, p.72 |
| IJCAD | BCHGWID（ブロック線の太さ変更） | ブロックの中のポリラインの幅を一括で変える。 | ブロック・属性 | ない | 可 | PLUS-PDF p.70 |
| IJCAD | BLKNUM（拡張ブロック数集計） | 集計したいブロックを選び、条件で絞り込んで数を数える。 | ブロック・属性 | 一部ある（COUNT はあるが、画面の絞り込み条件は少ない） | 可 | PLUS-PDF p.67 |
| IJCAD | AUTOLAYER（オートレイヤー） | 「寸法コマンドなら寸法画層」のように、コマンドごとの画層を登録しておくと、実行時に自動でその画層に描かれる。 | 画層 | ない（LAYEREVAL は新しい画層の通知だけ） | 簡易なら可 | PLUS-PDF p.176 |
| IJCAD | IJLAYLIST（画層一覧表示） | 画層ごとに中身の図形を小さく見せる一覧画面で、表示・フリーズ・ロックを切り替えたり、ダブルクリックでその画層だけ表示したりできる。 | 画層 | 一部ある（LAYWALK は名前一覧で、図形のサムネイルは出ない） | 簡易なら可 | PLUS-PDF p.153 ／ https://support.ijcad.jp/hc/ja/articles/900006153043 |
| IJCAD | ARRANGETOOL（オブジェクト配置） | 選んだ図形を、寸法を測らずに横・縦・範囲内で等間隔に並べ直す。 | 作図・編集 | ない | 可 | https://support.ijcad.jp/hc/ja/articles/36389792201241 |
| IJCAD | ALIGNTOOL（位置合わせツール） | 複数の図形の X や Y、任意の位置をそろえる（パワポの「左揃え」のような機能）。 | 作図・編集 | ない（ALIGN は1組ずつの点合わせで、そろえる機能ではない） | 可 | https://support.ijcad.jp/hc/ja/articles/36389808342681 |
| IJCAD | OCMP（図形比較） | 同じ図面内の2つの図形グループ（またはファイル）を基点を合わせて比べ、違いを色分けして図面に入れるか別ファイルに出す。 | 図面管理・検図 | 一部ある（DWG比較は図面ファイル同士だけ。図面内の2か所の比較はできない） | 簡易なら可 | PLUS-PDF p.162 ／ IJCAD2026カタログ p.12 |
| IJCAD | AREATABLE（面積表） | 閉じた範囲を選ぶと各面積と番号を記入し、面積表を作る。図形を変えると面積も追従。テキスト出力もできる。 | 表・書き出し | ない（面積はフィールドで個別に入れるしかなく、番号付けと表作成はない） | 可 | PLUS-PDF p.132 |
| IJCAD | BGE／FORMTXT／BGX ほか（線で作る表ツール） | 線分で表を作り、セルに文字を入れ、行・列の追加削除、セル結合、セルに斜線を引くなどができる。 | 表・書き出し | 一部ある（TABLE はあるが、線分だけの表の編集やセル斜線はない） | 簡易なら可 | PLUS-PDF p.125〜147 |
| IJCAD | GC_CTE（表を Excel 表に変換） | 線と文字で描かれた表を読み取って Excel で開く。 | 表・書き出し | ない（TABLEEXPORT は表オブジェクトのみ） | 簡易なら可 | PLUS-PDF p.135 |
| IJCAD | M2LVPORT（レイアウトビューポートを定義して作成） | モデル空間で範囲と尺度を決めておき、それに合うビューポートをレイアウトに作る。 | レイアウト・印刷 | ない（MVIEW はレイアウト側で枠を描いてから尺度を合わせる） | 可 | PLUS-PDF p.181 |
| IJCAD | SCRIPTGENERATOR（スクリプトジェネレータ） | 画面で処理内容と対象図面を選び、複数図面に同じ処理を一括でかける。テンプレート保存もできる。 | 図面管理・検図 | ない（本体に一括スクリプト実行の画面はない。ScriptPro は別配布） | 難しい | PLUS-PDF p.149 |
| IJCAD | LOCKUP（図面変更防止） | 選んだ図形を分解できない塊にして、相手に編集されないようにする。 | 図面管理・検図 | ない | 簡易なら可 | PLUS-PDF p.167 |
| IJCAD | RTCUR（リアルタイム回転） | 15度・1度きざみでカーソル（直交方向）を回し、今の角度をコマンドラインで確かめられる。 | 入力補助 | 一部ある（SNAPANG や UCS で可能だが、キー1つで少しずつ回す操作はない） | 可 | PLUS-PDF p.170 |
| IJCAD | SALPL（コード線） | 直交の傾きを好きな角度に回しながら、幅付きのポリラインを描く（投影図向け）。 | 入力補助 | 一部ある（SNAPANG を変えてから PLINE で代用） | 可 | PLUS-PDF p.172 |
| IJCAD | JWW 読み込み・書き出し | Jw_cad の JWW／JWC ファイルを開いたり、JWW 形式で保存したりできる。 | 表・書き出し | ない | 難しい | IJCAD2026カタログ p.11, p.16 |
| ZWCAD | Chain Select（チェーン選択） | つながっているばらばらの線を、1回のクリックでまとめて選ぶ。 | 選択 | ない（JOIN しないとつながりで選べない） | 可 | https://www.zwsoft.com/product/zwcad/whats-new |
| ZWCAD | SMARTSEL（Smart Select パネル） | 色・画層・種類・属性など複数の条件を画面で組み合わせ、その場で選択結果を確かめながら選ぶ。 | 選択 | 一部ある（QSELECT／FILTER はあるが、条件を複数組んで即時に見る使い勝手ではない） | 簡易なら可 | https://www.zwsoft.com/support/zwcad-instruction-command/smart-features |
| ZWCAD | Select Menu（選択メニュー） | 図形をクリックして出るメニューから「同じ色」「同じ画層」「同じ種類」などを選び、すぐ選択する。 | 選択 | 一部ある（SELECTSIMILAR は設定画面で条件を決めてから使う） | 可 | https://www.tbm.co.il/products/zwcad/2026/2026full.html |
| ZWCAD | Smart Match（スマートマッチ） | 同じ形の図形（回転・拡大したものを含む）を自動で見つけ、まとめて編集できるようにする。 | 選択 | 一部ある（スマートブロックの検出・変換はブロック化が目的。同形状を選んで一括編集する流れとは違う） | 難しい | https://www.zwsoft.com/news/products/zwcad-2026-design-with-speed-innovate-with-ease |
| ZWCAD | Similar Search（類似検索） | 手元の図形を見本にして、PC内の別の図面から似たブロックを探して再利用する。 | ブロック・属性 | 一部ある（スマートブロックの検索・置換は今の図面が中心。フォルダ横断の図形検索はない） | 難しい | https://www.zwsoft.com/product/zwcad/whats-new |
| ZWCAD | Dimension Merge（寸法の結合） | 一直線に並んだ複数の寸法（直列寸法など）を、1本の寸法にまとめる。 | 寸法・引出線 | ない | 可 | https://www.tbm.co.il/products/zwcad/2026/2026full.html |
| ZWCAD | Text Dodge（寸法文字の回避） | 寸法の文字が重なっているとき、自動で位置をずらして読みやすくする。 | 寸法・引出線 | ない（DIMSPACE は寸法線の間隔だけ。文字の重なりは手で直す） | 簡易なら可 | https://www.tbm.co.il/products/zwcad/2026/2026full.html |
| ZWCAD | MEASUREGEOM の合計長さ・合計面積 | 選んだ複数の図形の長さの合計や面積の合計をすぐに出す。 | その他 | 一部ある（面積は「加算」モードで足せるが、長さの合計は出ない） | 可 | https://www.zwsoft.com/product/zwcad/whats-new |
| ZWCAD | Find パネル化 | 検索・置換をパネルにして、開いたまま図面の編集もできる。 | 文字 | 一部ある（FIND はダイアログで、開いたまま作業できない） | 簡易なら可 | https://www.zwsoft.com/product/zwcad/whats-new |
| ZWCAD | ZWPLOT（Smart Plot） | モデル空間の図枠を自動で見つけ、用紙サイズを合わせて、複数図枠・複数ファイルを一括で印刷や PDF にする。 | レイアウト・印刷 | ない（PUBLISH はレイアウト単位。モデル空間の図枠を探す機能はない） | 簡易なら可 | https://zwcad.gr/en/zwcad-innovations/ ／ https://www.zwsoft.com/news/products/zwcad-2026-design-with-speed-innovate-with-ease |
| ZWCAD | Automatic Layout Drawings（図面の自動割付） | 大きさの違う複数の図面を、指定した用紙の中に隙間を決めて自動で並べ、大判用紙を無駄なく使う。 | レイアウト・印刷 | ない | 簡易なら可 | ZWCAD 2025 リリースノート 4.1.9 https://www.eiseko.it/public/mat/file/ZWCAD_2025_Official_Release_Notes.pdf |
| ZWCAD | Barcode／QR Code（バーコード・QRコード） | 図名・設計者・日付などを入れたバーコードや QR コードを図面に作る。読み取りで図面管理に使える。 | 図面管理・検図 | ない | 簡易なら可 | https://zwcad.gr/en/zwcad-innovations/ |
| ZWCAD | LOCKUP／UNLOCK（図面ロック） | 選んだ図形をパスワード付きでロックし、見えるけれど編集できない状態にする。パスワードで解除できる。 | 図面管理・検図 | ない | 簡易なら可 | https://www.zwsoft.com/product/autocad-comparison/kol ／ https://www.linkedin.com/pulse/zwcad-highlights-advantages-rasesh-palav |
| ZWCAD | Area Table（面積表） | 閉じた範囲の面積を自動で計算し、番号付きの面積表にする。 | 表・書き出し | ない | 可 | https://www.zwsoft.com/product/autocad-comparison/kol |
| ZWCAD | Undo Snapshot（元に戻すのプレビュー） | 元に戻す一覧にマウスを乗せると、その時点の図面の様子を先に見られ、1クリックで戻れる。 | 表示・操作 | 一部ある（UNDO の一覧はあるが、戻す前のプレビューはない） | 難しい | https://zwcad.gr/en/zwcad-innovations/ |
| ZWCAD | SMARTMOUSE（マウスジェスチャー） | 右ボタンを押しながら決まった方向や形になぞると、登録したコマンドが動く。 | 入力補助 | ない | 難しい | https://www.zwsoft.com/support/zwcad-instruction-command/smart-features |
| ZWCAD | SMARTVOICE／VOICEMAN（音声メモ） | 図形や位置に音声のメモを付けて図面に残し、一覧で聞いたり文字にしたりできる。 | その他 | ない | 難しい | https://www.zwsoft.com/support/zwcad-instruction-command/smart-features |
| ZWCAD | Sizedrive（寸法で形を変える） | 図形の寸法の数値を書き換えると、それに合わせて形が変わる。簡単な部品の寸法変更向け。 | 寸法・引出線 | 一部ある（パラメトリック拘束を付ければ可能だが、事前の拘束づけが必要） | 簡易なら可 | ZWCAD 2025 リリースノート 4.1.8 https://www.eiseko.it/public/mat/file/ZWCAD_2025_Official_Release_Notes.pdf |
| ZWCAD | JWW 読み込み | Jw_cad の JWW ファイルを直接読み込んで見たり編集したりできる。 | 表・書き出し | ない | 難しい | ZWCAD 2025 リリースノート 4.1.7 https://www.eiseko.it/public/mat/file/ZWCAD_2025_Official_Release_Notes.pdf |
| ZWCAD | REVCLOUD の円・楕円（雲マーク） | 円形や楕円形の雲マークを直接描き、あとから形も直せる。 | 作図・編集 | 一部ある（REVCLOUD は矩形・ポリゴン・フリーハンド。円は既存の円を「オブジェクト」で変換する） | 可 | ZWCAD 2025 リリースノート 4.1.5 https://www.eiseko.it/public/mat/file/ZWCAD_2025_Official_Release_Notes.pdf |

（行数：IJCAD 46 行、ZWCAD 20 行、計 66 行）

## 確認できなかった・除外した理由

- **AutoCAD（本体・Express Tools）に同じものがあるので除外**：IJCAD の TEXTALIGN・ARCTEXT・RTEXT・TEXTFIT・TXT2MTXT・TEXTMASK・TCIRCLE・TCOUNT・TORIENT・TCASE・EXPLODETEXT（≒TXTEXP）・BCOUNT・BLOCKREPLACE・NCOPY・BURST・ATTOUT/ATTIN・XLIST・BLOCKTOXREF・DIMEX/DIMIM・DIMREASSOC・SUPERHATCH・FLATTEN・OVERKILL・BREAKLINE・MOCORO・EXOFFSET・EXTRIM・MKLTYPE・SPTPL・MPEDIT・SFILLET・LCW・GXFILT（FILLET 半径0と同じ）・ETT（グリップ編集と同じ）・CMP（DWG比較）・BATPURGE（DWGCONVERT に削除オプションあり）・LAYOUTMERGE・CLIPIT・CHGDIMTXT（プロパティ・TEXTEDIT で可）。IJCAD 2024〜2026 の新機能（選択の循環、投げ縄選択、DIM の自動判別、BREAKATPOINT、DWGUNITS、VPSYNC、SYSVARMONITOR、デジタル署名、一括変換 IJ コンバーター 等）は AutoCAD に追いつくための機能で、AutoCAD には既にある。
- **ZWCAD で AutoCAD にもあるもの**：File Compare（DWG比較）、Smart Dimension（DIM）、Dimension Grip Menu（寸法のグリップメニュー）、Center Line/Center Mark、Add Select（ADDSELECTED）、クリックできるコマンドライン、コマンドのあいまい検索、MTEXP（EXPLODE で可）、HATCHSETBOUNDARY/HATCHSETORIGIN/HATCHTOBACK/TEXTTOFRONT、GROUPEDIT、Layer Browser（LAYWALK）、Data Extraction、Flexiblock（ダイナミックブロック）、マルチテキストの段落番号・段組み、Toolbox（ツールパレット相当）、Parametric Design（拘束）。
- **範囲外として除外**：3D・点群・GIS・ラスター→ベクター変換・STEP/IGES/IFC/Revit 読み込み・Section View／Drawing View（機械・3D 系）、SXF・CALS（電子納品・土木寄り）、ライセンス・ハードウェアアクセラレーション・.NET 8 など開発環境、IJ リーダー（ガイドブック閲覧）。
- **効果が小さい・LISP の題材として弱いので除外**：DWFIN（DWF を図形に変換。AutoCAD では下敷き表示のみだが、ファイル変換で LISP 向きでない）、PRINTPLT（PLT ファイルの印刷）、SASCL（コード線の幅比率設定だけ）、ZWCAD の Smart Peek（内容を公式資料で確認できず）、ZWCAD の Memory Optimization・軽量インストール（性能面の話）。
- **確認できなかった点**：IJCAD ヘルプセンター（support.ijcad.jp）の個別記事は自動取得が拒否され（403）、検索結果の要約と公式 PDF で内容を確認した。IJCAD の PLUS 資料は 2022 年版のため、その後に追加・削除されたコマンドがありうる（例：OBJSETPT は ALIGNTOOL に置き換え予定と記載）。ZWCAD の 2026 新機能（Chain Select・Dimension Merge・Text Dodge・Smart Match など）は公式の紹介文のみで、コマンド名や細かい動きは未確認。ZWCAD の日本語公式ブログ（zwcad.co.jp）は接続できなかった。
