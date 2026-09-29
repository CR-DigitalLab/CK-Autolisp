# GstarCAD／DraftSight／ARES Commander にあって AutoCAD 2027（本体＋Express Tools）に無い・弱い 2D 機能

調査日：2026-09-29。公式ヘルプ・公式機能ガイド（PDF）を優先。説明は要約・言い換え。
「AutoCADとの差」の比較先は AutoCAD 2027 本体＋Express Tools（業種別ツールセットは含めない）。

| 製品 | コマンド／機能名（原語） | 何ができるか（やさしい日本語で1〜2文） | 分類 | AutoCADとの差 | LISPで再現 | 出典URL |
|---|---|---|---|---|---|---|
| GstarCAD | BREAKOBJECT（Break Object） | 交差している線どうしを、指定したすき間（ギャップ）付きで一括で切る。「選んだもの同士」「A群をB群で切る」「選んだ線に触れるものを切る」など4つのモードがある。 | 作図・編集 | ない（BREAK／BREAKATPOINT は1本ずつ。交点で一括・ギャップ付きは無い） | 可 | https://www.gstarcad.gr/wp-content/uploads/2025/08/GstarCAD_2026_Express_Tools.pdf |
| GstarCAD | CBK／CBKWID（Cross to Break／Control Break Width） | 十字に交差する線の片方を、交点で決まった幅だけ切り欠く（配管・配線の「またぎ」表現）。切り欠き幅は別コマンドで設定。 | 作図・編集 | ない | 可 | 同上（GstarCAD 2026 Express Tools PDF） |
| GstarCAD | BLOCKBREAK（Block Break） | ブロック（記号）を線の上に配置すると、下の線を自動で切るか、ワイプアウトで隠す。 | ブロック・属性 | ない（手でTRIM／ワイプアウトを作る必要あり） | 可 | 同上 |
| GstarCAD | _REGSCALE（Region Scale） | 窓で囲んだ範囲だけを切り取って別の場所にコピーし、はみ出た部分は枠で切り、必要なら倍率をかける（部分拡大図づくり）。 | 作図・編集 | ない（COPY→TRIM→SCALE を手作業） | 簡易なら可 | 同上／https://gstarcadaustralia.com/wp-content/uploads/2024/04/GstarCAD-Innovative-Features.pdf |
| GstarCAD | FREESCALE（Free Scale） | X・Yで別倍率の拡大縮小、指定した四角に合わせて縮尺、四角形から任意の四角形への変形（ゆがませてコピー）ができる。 | 作図・編集 | 一部ある（非一様な尺度はブロック化しないとできない。四角に合わせる機能は無い） | 簡易なら可（非一様・矩形合わせ） | https://gstarcadaustralia.com/wp-content/uploads/2024/04/GstarCAD-Innovative-Features.pdf |
| GstarCAD | Align Tool／Arrange Tool | 選んだ図形を左・右・上・下・中央そろえにしたり、縦横に等間隔で並べたりする（オフィスソフトの「整列」と同じ感覚）。 | 作図・編集 | ない（ALIGN は2点合わせで別物） | 可 | https://cdn-sg-gw.gstarcad.net/gstarsoft_pdf/GstarCAD_2026_Complete_Features_Guide.pdf |
| GstarCAD | Symmetric Draw（対称作図） | ステータスバーでONにすると、描いた図形の対称形がX軸・Y軸・指定線を軸に自動でできる。 | 作図・編集 | ない（MIRRORを後から実行） | 簡易なら可（描画後に自動ミラーするコマンド型） | https://gstarcadaustralia.com/wp-content/uploads/2024/04/GstarCAD-Innovative-Features.pdf |
| GstarCAD | OUTLINE（Outline Objects） | 窓で囲んだ閉じた図形群の「外形線」だけをポリラインで取り出す。 | 作図・編集 | ない（BOUNDARY は内側の点指定で、外形一括は無い） | 可（リージョン和→ポリライン化） | 同上 |
| GstarCAD | Pline Boolean | 閉じたポリライン同士を「合体・共通部分・差し引き」して、結果をポリラインで得る。 | 作図・編集 | 一部ある（REGION→UNION等→分解が必要。ポリラインのままでは不可） | 可 | https://cdn-sg-gw.gstarcad.net/gstarsoft_pdf/GstarCAD_2026_Complete_Features_Guide.pdf |
| GstarCAD | LINE／PLINE の Angle オプション | 線を引くとき「角度」を直接入力、または基準線からの角度・直前の線からの角度・なす角で指定できる。 | 入力補助 | 一部ある（< で絶対角度の固定はできるが、直前の線や参照線を基準にした角度は無い） | 可 | https://gstarcadaustralia.com/wp-content/uploads/2024/04/GstarCAD-Innovative-Features.pdf |
| GstarCAD | RECTANG の Oblique、CIRCLE の Concentric | 参照線に対する角度で傾いた長方形を描く。円は中心1回の指定で半径を続けて入れて同心円を何個も描く。 | 作図・編集 | 一部ある（RECTANGの回転はあるが参照線基準は無い。同心円の連続作図は無い） | 可 | 同上 |
| GstarCAD | COPY の Measure／Divide／Path、ROTATE の Multiple（Between／Fill） | コピーで「間隔指定で連続」「区間を等分割」「経路に沿って」を直接指定。回転コピーで角度を複数回入れる／範囲を等分して個数指定できる。 | 作図・編集 | 一部ある（COPYの配列オプションは直線等間隔のみ。回転の複数コピーは無い） | 可 | 同上 |
| GstarCAD | AUTOLAYER（Autolayer） | 「このコマンドで描いたものはこの画層」と決めておくと、描くときに自動で画層を切り替える（無ければ作る）。設定は保存・読込できる。 | 画層 | 一部ある（寸法・ハッチ・中心線など一部のみ DIMLAYER／HPLAYER 等で指定可。全コマンド共通の仕組みは無い） | 簡易なら可（コマンドリアクタ） | https://blog.gstarcad.net/introduction-to-gstarcad-express-tool-autolayer/ |
| GstarCAD | LAYDRAWORDER（Layer Draworder） | 画層の順番を並べ替えて、その順に図形の表示順（前後）を一括で整える。 | 画層 | ない（DRAWORDERは図形を選んで個別指定） | 可 | https://www.gstarcad.gr/wp-content/uploads/2025/08/GstarCAD_2026_Express_Tools.pdf |
| GstarCAD | GETBLKSEL／GETLAYSEL／GETCOLSEL／GETENTLAYSEL ほか | 見本を1つ選び、指定した範囲の中だけで「同じブロック名／画層／色／種類×画層…」のものをまとめて選ぶ。 | 選択 | 一部ある（SELECTSIMILAR は図面全体が対象で範囲を限定できない。QSELECTは手順が多い） | 可 | 同上 |
| GstarCAD | HZCF／WZDD（Chinese Characters Split／Character Break） | 1行文字を1文字ずつ別の文字に分ける。または指定した位置で1つの文字を2つに分ける。 | 文字 | ない（TXTEXPは線分化してしまい文字として残らない） | 可 | 同上 |
| GstarCAD | chkck（Glossary Storeroom） | よく使う文言（注記・仕様文）を辞書として登録しておき、選んで図面に入れる。 | 文字 | ない（ツールパレットで代用は可能） | 可（DCL＋テキストファイル） | 同上 |
| GstarCAD | FORMTXT／BGE／BGH／BGFG／BGX／BGMT／BGST／BGJT／BGZH／BGZL／BGSH／BGSL／BGJS（Table Tools） | 線と文字で描いた「線の表」を、表オブジェクトにせずにそのまま編集する。セル結合・分割・斜線・罫線のドラッグ・行列の追加削除・セル内文字の位置そろえ等。 | 表・書き出し | ない（AutoCADの表ツールは TABLE オブジェクト専用） | 簡易なら可（罫線と文字の解析が必要） | 同上 |
| GstarCAD | GC_CTE（CAD Table to Excel） | 線（または線分）と文字で描かれた表を読み取り、Excelの表に変換して開く。 | 表・書き出し | ない（TABLEEXPORT は TABLE オブジェクトのみ・CSV） | 簡易なら可（罫線からセルを推定しCSV出力） | 同上 |
| GstarCAD | AREATABLE（Area Table） | 閉じた図形の面積を測って番号や面積の注記を付け、一覧表を図面に作る。番号や面積が変わると表も追従。外部ファイルにも出せる。 | 表・書き出し | ない（MEASUREGEOM やフィールドで個別に作るのみ） | 簡易なら可（追従はフィールド利用） | 同上 |
| GstarCAD | COEXPORT（Export Coordinate） | クリックした点の座標を次々に拾い、テキストやExcel形式で書き出す。 | 表・書き出し | ない（DATAEXTRACTION は点を拾う用途に向かない） | 可 | 同上 |
| GstarCAD | DIMCORD（Coordinate Point） | 点の X・Y 座標を引出線付きの注記で書く（2026 から引出線と文字が一体で動く）。 | 寸法・引出線 | 一部ある（座標寸法 DIMORDINATE は X か Y の片方だけ） | 可 | 同上／https://cdn-sg-gw.gstarcad.net/gstarsoft_pdf/GstarCAD_2026_Complete_Features_Guide.pdf |
| GstarCAD | bChgCol／bChgWid／bChgAng／bChgHei／bChgLay | ブロックを開かずに、ブロック内部の図形の色・線幅・文字角度・文字高さ・画層を一括で変える。 | ブロック・属性 | 一部ある（SETBYLAYER でByLayer化はできるが、任意の色・文字高さは BEDIT が必要） | 可 | https://www.gstarcad.gr/wp-content/uploads/2025/08/GstarCAD_2026_Express_Tools.pdf |
| GstarCAD | CHANGEBASE（Change Base） | ブロックの基点を移す。「図形はその場に残す」か「基点位置を残して図形が動く」かを選べる。 | ブロック・属性 | 一部ある（BEDIT内でBASEPOINTを変えると全参照が動いて見える。位置を保つ補正は手作業） | 可 | 同上 |
| GstarCAD | ATTINC（Attribute Increment） | ブロック属性に連番を振る。ON にしておくと、コピー・挿入・削除のたびに番号を自動で振り直す。並び順も指定できる。 | ブロック・属性 | 一部ある（Express の TCOUNT は文字用で、属性の自動振り直しは無い） | 簡易なら可（振り直しはコマンド実行型に） | 同上／https://gstarcadaustralia.com/wp-content/uploads/2024/04/GstarCAD-Innovative-Features.pdf |
| GstarCAD | M2LVPORT（Define Layout Viewport from Model Space） | モデル空間で範囲を囲み、縮尺を指定すると、その範囲がぴったり入るビューポートをレイアウトに自動で作る。 | レイアウト・印刷 | ない（MVIEWで作ってから縮尺・位置を合わせる） | 可 | https://cdn-sg-gw.gstarcad.net/gstarsoft_pdf/GstarCAD_2026_Complete_Features_Guide.pdf |
| GstarCAD | BP（Batch Print） | モデル空間に並んだ複数の図枠（ブロック／画層／ポリラインで識別）を自動で探し、まとめて印刷する。 | レイアウト・印刷 | ない（PUBLISH はレイアウト単位。1つのモデルに並んだ図枠の一括印刷は無い） | 可 | https://www.gstarcad.gr/wp-content/uploads/2025/08/GstarCAD_2026_Express_Tools.pdf |
| GstarCAD | FRAMEAR（Arrange Frame Automatically） | 複数の図面ファイルの図枠を探し、大きさを計算して1枚の図面に並べて配置する。 | 図面管理・検図 | ない | 簡易なら可（ODBX／挿入で配置） | 同上 |
| GstarCAD | AUTOMERGE（Drawing Merge） | 複数図面を解析・分割し、外部参照として1つの図面に並べてまとめる。列数・間隔・揃え方を指定できる。 | 図面管理・検図 | ない | 簡易なら可 | 同上／https://cdn-sg-gw.gstarcad.net/gstarsoft_pdf/GstarCAD_2026_Complete_Features_Guide.pdf |
| GstarCAD | BATPURGE（Batch Purge） | 図面を開かずに、複数DWGの不要な画層・ブロック・スタイル等をまとめて削除し、ログを残す。2026 から長さ0の図形・空の文字・登録アプリも対象。 | 図面管理・検図 | ない（PURGE は開いている図面のみ。一括はスクリプトが必要） | 簡易なら可（ODBXで開かずに処理。一部はスクリプト併用） | 同上 |
| GstarCAD | LOCKUP（Drawing Lock） | 図形や図面全体を編集できない状態にし、パスワードで保護する（表示・印刷は可）。 | 図面管理・検図 | ない | 簡易なら可（ブロック化＋ロック画層程度。パスワード保護は不可） | https://www.gstarcad.gr/wp-content/uploads/2025/08/GstarCAD_2026_Express_Tools.pdf |
| GstarCAD | DWGUNITS | 図面の単位を変え、図形や文字・寸法をそれに合わせて換算する（例：インチ⇔mm）。 | 図面管理・検図 | 一部ある（本体には無く、業種別ツールセットにのみ -DWGUNITS あり） | 可 | 同上／https://cdn-sg-gw.gstarcad.net/gstarsoft_pdf/GstarCAD2025_Complete_Features_Guide.pdf |
| GstarCAD | MAGNIFIER（Magnifier） | ズームせずに、カーソルの周りだけを虫めがねのように拡大表示し、その中でスナップも作図もできる。 | 表示・操作 | ない | 難しい | https://gstarcadaustralia.com/wp-content/uploads/2024/04/GstarCAD-Innovative-Features.pdf |
| GstarCAD | RTCUR／RTCUR1（Rotate Cursor／Side Line） | カーソルの十字を45°に回したり、選んだ線の向きに合わせて回したりする。 | 入力補助 | 一部ある（SNAPANG や UCS で可能だが、線を選ぶだけで合わせる操作は無い） | 可 | https://www.gstarcad.gr/wp-content/uploads/2025/08/GstarCAD_2026_Express_Tools.pdf |
| GstarCAD | ZC／SALPL（Super Axonometric／Draw Axonometric Line） | 平面図を等角投影（アイソメ）図にまとめて変換する。アイソメ方向の線も簡単に描ける。 | 作図・編集 | 一部ある（ISODRAFTで描くことはできるが、既存平面図の変換は無い） | 可（ブロック化＋変形 or 座標変換） | 同上 |
| GstarCAD | Barcode／QR Code | 入力した文字や図面から拾った文字でバーコード・QRコードを作り、ブロックとして入れる（2026でCode39対応）。 | その他 | ない | 簡易なら可（Code39などは可。QRは難しい） | https://cdn-sg-gw.gstarcad.net/gstarsoft_pdf/GstarCAD_2026_Complete_Features_Guide.pdf |
| GstarCAD | VOICEMANAGER（Voice Annotation） | 点・図形・範囲に音声メモを録音して貼り付け、あとで再生・管理する。 | その他 | ない | 難しい | https://cdn-sg-gw.gstarcad.net/gstarsoft_pdf/GstarCAD2025_Complete_Features_Guide.pdf |
| DraftSight | PowerTrim | 画面上をドラッグでなぞるだけで、触れた線を次々トリム（切り取り境界は全図形が自動対象）。Shiftを押しながらなら延長、2本を仮想の交点まで伸ばす／切ることもできる。 | 作図・編集 | 一部ある（TRIM／EXTEND のクイックモードはあるが、トリムと延長の切替・角の処理を1コマンドで連続にはできない） | 簡易なら可（grread でなぞり判定） | https://help.solidworks.com/2023/English/DraftSight/DraftSightSW/HLPID_EDIT_POWERTRIM.htm |
| DraftSight | AutoDimension | 範囲枠（Dimension Bounding Box）の中の図形を選ぶと、並列・直列・座標寸法、円弧の半径、円の直径を自動で一括作成する。 | 寸法・引出線 | 一部ある（QDIM は選んだ図形に一方向の寸法を付けるだけで、半径・直径までの一括は無い） | 簡易なら可 | https://help.solidworks.com/2025/english/DraftSight/DraftSightSW/c_auto_dimensioning.htm |
| DraftSight | ArrangeDimensions | 範囲枠の中の寸法（長さ・半径・直径・角度・弧長）を、重ならないよう自動で並べ直す。 | 寸法・引出線 | 一部ある（DIMSPACE は選んだ平行寸法の間隔をそろえるだけ） | 簡易なら可 | https://help.solidworks.com/2026/english/DraftSight/DraftSightSW/t_auto_arrange_dimensions.htm |
| DraftSight | ImageTracer | 取り込んだ画像（BMP・PNG・JPG等）の指定範囲を、線・ポリライン・スプラインの図形に自動変換する（ラスタ→ベクタ）。 | 作図・編集 | ない | 難しい | https://help.solidworks.com/2022/english/DraftSight/DraftSightSW/c_image_tracer.htm |
| DraftSight | Mouse Gestures（Gesture） | 右ボタンを押したまま上下左右（最大8方向）に動かすと、割り当てたコマンドが起動する。 | 表示・操作 | ない | 難しい | https://www.draftsight.com/sites/draftsight/files/2021-06/DRT-0352_Power_of_DraftSight_v7a.pdf |
| DraftSight | Toolbox Layer Settings（Enable Predefined Layering） | 図形の種類ごとに置く画層（と色・線種・線の太さ）を決めておき、描いたとき自動でその画層に載せる。 | 画層 | 一部ある（寸法・ハッチ等の一部のみ個別変数で可能） | 簡易なら可（リアクタ） | 同上 |
| DraftSight | Paste to Active Layer | コピーした図形を、元の画層ではなく「いまの画層」に載せて貼り付ける。 | その他（クリップボード） | ない（PASTECLIP は元の画層のまま。COPYTOLAYER は図面内のみ） | 可 | https://blog.draftsight.com/2017/11/07/draftsight-2018-new-features-2/ |
| DraftSight | HATCHPATTERN | 図面に描いた図形やブロックから、ハッチパターン（.pat）を作って登録・挿入する。 | ハッチ | ない（Express の MKLTYPE／MKSHAPE はあるがハッチ用は無い） | 可（線分から .pat を書き出し） | https://www.draftsight.com/product/2d-cad/whats-new |
| DraftSight | ExportTable | 表を .xlsx／.xls／.csv で書き出す。 | 表・書き出し | 一部ある（TABLEEXPORT は CSV のみ） | 簡易なら可（Excel連携はCOM経由） | https://www.draftsight.com/sites/draftsight/files/2021-06/Commands_Quick_Reference_v3.pdf |
| DraftSight | Block Structure Palette | 入れ子のブロック構成をツリーで表示し、プレビューや単独表示ができる。 | ブロック・属性 | ない（XLIST は1つの入れ子要素の情報のみ） | 簡易なら可（一覧・ツリー出力。パレット化は不可） | https://develop3d.com/cad/draftsight-2025/ |
| DraftSight | Dimension Palette | 寸法を選ぶ・作ると小さなパレットが出て、公差・精度・書式をその場で変え、別の寸法にも使い回せる。 | 寸法・引出線 | ない（プロパティパレットで変更） | 難しい（DCLで簡易版なら可） | https://www.draftsight.com/sites/draftsight/files/2025-11/DraftSight_Product_Matrix.pdf |
| ARES Commander | PowerTrim（ハッチ対応） | なぞってトリム／延長・仮想交点処理に加え、ハッチもトリムでき、トリム後もハッチの関連付けが保たれる。 | 作図・編集 | 一部ある（上の DraftSight 行と同じ差） | 簡易なら可 | https://onlinehelp.graebert.com/EN/ARESMECH/27/help_files/english/additional/hlpid_edit_powertrim.html |
| ARES Commander | AlignX | 最初に選んだ図形を基準に、他の図形（線・円・文字・ハッチ・ブロック・寸法など）を整列させる。 | 作図・編集 | ない | 可 | https://onlinehelp.graebert.com/EN/ARESMECH/27/help_files/english/html/hlpid_edit_alignx.html |
| ARES Commander | Split@Multiple | 複数の図形を、別に選んだ図形を「刃」にして交点で一括分割する。 | 作図・編集 | ない（BREAKATPOINT は1点ずつ） | 可 | https://onlinehelp.graebert.com/EN/ARESMECH/27/help_files/english/html/hlpid_edit_breakmultiple.html |
| ARES Commander | ScaleBlock | 複数ブロックをそれぞれの挿入点を基準に、「絶対値（最終尺度）」または「今の尺度に対する倍率」で一括スケールする。 | ブロック・属性 | 一部ある（SCALE は共通の基点1つ。プロパティで尺度は入れられるが基準点・相対指定の使い分けは無い） | 可 | https://onlinehelp.graebert.com/EN/ARESMECH/27/help_files/english/xtratools/t_scaleblock.html |
| ARES Commander | RedefineBasePoint | ブロックを選んで右クリックから、そのブロック全参照の基点を変える（ブロック編集に入らない）。 | ブロック・属性 | 一部ある（BEDIT に入って BASEPOINT を変える必要あり） | 可 | https://onlinehelp.graebert.com/EN/ARESMECH/27/help_files/english/html/hlpid_block_editbasepoint.html |
| ARES Commander | ReferenceToBack | 外部参照（DWG）・画像・PDF・DGN の参照を、まとめて他の図形の後ろに回す（ロック・非表示画層の参照も含む）。 | 表示・操作 | 一部ある（TEXTTOFRONT は文字・寸法・ハッチ用。参照の一括最背面は DRAWORDER で個別選択） | 可 | https://onlinehelp.graebert.com/EN/ARESMECH/27/help_files/english/html/hlpid_view_referencetoback.html |
| ARES Commander | FlipArrows | 選んだ複数の寸法の矢印（または斜線）の向きを一括で反転する。 | 寸法・引出線 | 一部ある（右クリック／グリップの「矢印を反転」は1つずつ） | 可 | https://onlinehelp.graebert.com/EN/ARESMECH/27/help_files/english/html/hlpid_dim_fliparrows.html |
| ARES Commander | Dimension Location Snap | 寸法線を置くとき、前の寸法から決まった間隔・角度の位置にスナップして並べやすくする。 | 寸法・引出線 | 一部ある（DIM の並列配置や DIMSPACE で後から揃える形） | 難しい | https://www.graebert.com/cad-software/ares-commander/past-features/ |
| ARES Commander | Callout（マーカー文字） | 矢印付きの枠文字（赤色）を置いて、図面上に一時的な指摘メモを書く。大きさは画面の見え方に合わせて決まる。 | その他（検図） | 一部ある（マークアップ機能はあるが、図面内に簡単な赤枠メモを置くコマンドは無い） | 可 | https://onlinehelp.graebert.com/EN/ARESMECH/27/help_files/english/additional/hlpid_other_callout.html |
| ARES Commander | AREANOTE（Area Note） | 領域の面積を自動計算し、色付きの（透過できる）塗りと、面積・説明のラベルを一度に付ける。 | 図面管理・検図 | ない（面積の測定と注記・塗りは別作業） | 可 | https://www.graebert.com/cad-software/ares-commander/new-features/ |
| ARES Commander | Paste（Active Layer オプション） | 貼り付け時にオプションで「いまの画層」に強制して載せる。 | その他（クリップボード） | ない | 可 | https://onlinehelp.graebert.com/EN/ARESMECH/27/help_files/english/html/hlpid_other_paste.html |
| ARES Commander | Move with Arrow Keys | 選んだ図形を Shift＋矢印キーで、決めた距離ずつ動かす。 | 作図・編集 | 一部ある（Ctrl＋矢印の「ナッジ」は画面の画素単位で、距離指定できない） | 簡易なら可（キーを割り当てたコマンドで距離移動） | https://www.graebert.com/cad-software/ares-commander/past-features/ |
| ARES Commander | Head-up Display Toolbar（Heads-up） | カーソル近くに、実行中のコマンドのオプションや編集ボタンが並ぶ小さなツールバーが出る。 | 表示・操作 | 一部ある（ダイナミック入力でオプション一覧は出るが、ボタン形式のツールバーは無い） | 難しい | https://graebert.com/us/blog/tutorial/headsup-floating-palette-ares |
| ARES Commander | Mouse Gestures | 右ドラッグの方向（4または8方向）で割り当てたコマンドを起動。方向ごとのガイドが表示される。 | 表示・操作 | ない | 難しい | https://onlinehelp.graebert.com/EN/ARESMECH/27/help_files/english/mg/mg_Mouse_Gestures.html |
| ARES Commander | EnterPoint | 点を聞かれたとき、テンキー付きのダイアログで座標を入力する。別の点からの相対指定や極座標の確認もできる。 | 入力補助 | ない（コマンドラインやダイナミック入力のみ） | 簡易なら可（DCL） | https://onlinehelp.graebert.com/EN/ARESMECH/27/help_files/english/additional/hlpid_other_enterpoint.html |
| ARES Commander | LispExplorer | 読み込まれているLISPのコマンド・関数・変数を一覧表示し、コードの表示や検索、一覧の書き出しができる。 | その他 | 一部ある（VLIDE の Apropos で名前検索はできるが、コマンド一覧や書き出しは無い） | 簡易なら可（atoms-family で一覧） | https://onlinehelp.graebert.com/EN/ARESMECH/27/help_files/english/xtratools/t_lispexplorer.html |
| ARES Commander | Dynamic Print Preview | 印刷ダイアログの中で、設定を変えるとすぐ全体プレビューに反映される。 | レイアウト・印刷 | 一部ある（PLOT ダイアログは小さな部分プレビューのみ。全体は「プレビュー」ボタンで別画面） | 難しい | https://www.graebert.com/cad-software/ares-commander/past-features/ |

## 確認できなかった・除外した理由

- **AutoCAD にすでにあるため除外**：DWG Compare・Draw Compare、Count／BCOUNT／GetBlockInfo、QuickModify・MOCORO、SmartDimension（AutoCAD の DIM）、Pattern（連想配列）、Flatten、BreakAtPoint、Lasso 選択、SelectMatching（SELECTSIMILAR）、Merge Layers（LAYMRG）、LayerPreview（LAYWALK）、Annotation Monitor、Cycling Selection、Centerline／Center Mark、表の自動入力・分割・数式、Data Link、ExplodeBlockX（BURST）、ReplaceBlock（BLOCKREPLACE）、NumberText（TCOUNT）、TextFrame（TCIRCLE）、FitText（TEXTFIT）、CurvedText（ARCTEXT）、MergeSheets（LAYOUTMERGE）、SplitDimension（DIMBREAK）、SetByLayer、ChangeSpace（CHSPACE）、Undelete（OOPS）、Copy to Current Layer（COPYTOLAYER）、ImportBlockAttributes（ATTIN）、RapidDist（クイック計測 MEASUREGEOM）、PatternHatch／Superhatch（SUPERHATCH）、GstarCAD Express の大半（BTRIM・EXTRIM・EXOFFSET・OVERKILL・COPYM・CLIPIT・DIMEX・QLATTACH・MKLTYPE・SYSVDLG など AutoCAD Express と同名同機能）。
- **AutoCAD 2027 で追加済みのため除外**：GstarCAD の CLOSELINE（すき間チェック）は AutoCAD 2027 の Geometry Cleanup（すき間・重なり・はみ出しの検出修正）とほぼ重なる。
- **AutoCAD Express にもあると判断して除外**：CDORDER（色による表示順＝DRAWORDERBYCOLOR）、RENAME のワイルドカード（AutoCAD の RENAME ダイアログも対応）。
- **範囲外として除外**：3D（Engineering Projection、STEP、Visual Style）、BIM（BIMAUTO系）、機械（DraftSight Toolbox の BOM・穴・溶接記号、G-Code、Power Dimension）、クラウド・共同作業（Trinity、ARES Kudo、GstarCAD Collaboration、View-only Link）、AI（ARES AI Assist／コマンド推薦）、ライセンス、UI の見た目（ダークモード、スタートページ、浮動ウィンドウ）、パラメトリック拘束・カスタムブロック（AutoCAD にも拘束・ダイナミックブロックあり）。
- **中国語特有で除外**：GstarCAD の TTL2（漢字・英数字の高さそろえ）。
- **小さすぎる・重複で除外**：GstarCAD の TXT40〜TXT51・CHGSTY・CHGTXT・WZOFF（プロパティ・FIND で足りる）、GXFILT／GXFSS（半径0フィレットと同じ）、LCW（PEDIT 複数・幅でほぼ同じ）、SFILLET、PrintPlt（PLT 送信）、ARES の Trapezoid・SimplePolygon・ClearLwPolyline・SmartBMP。
- **情報不足**：GstarCAD 2026 の「View Mode Switch」、DraftSight 2026 の Powertools タブの全コマンド一覧、DraftSight の「Quick Input Methods」の中身は公式資料で詳細を確認できなかった。
- **出典の注意**：ARES Commander 2027 の個別ヘルプは公開サイトの ARES Mechanical 2027 版（ARES Commander を土台にした同じ本体機能）で確認した。SOLIDWORKS 公式の What's New PDF は取得できなかったため、DraftSight は help.solidworks.com の個別ページ・DraftSight 公式PDF・公式サイトで確認した。
