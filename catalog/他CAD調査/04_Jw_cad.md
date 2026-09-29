# Jw_cad にあって AutoCAD 2027（Express Tools 込み）にない／弱い機能

調査日：2026-09-29。対象：Jw_cad 8.x/9.x の汎用2D機能（建具・壁・階段の自動作図、日影・天空、2.5D は除外）。
「AutoCADとの差」は AutoCAD 2027 本体＋Express Tools と比べた、使う前の見立て。

| 製品 | コマンド／機能名（原語） | 何ができるか（やさしい日本語で1〜2文） | 分類 | AutoCADとの差 | LISPで再現 | 出典URL |
|---|---|---|---|---|---|---|
| Jw_cad | 包絡処理 | 四角で囲んだ範囲の中で、交わっている線の不要な部分を自動で消し、外側の輪郭だけを残す。同じ線色・線種どうしだけが対象。 | 作図・編集 | ない（AutoCAD Architecture にはあるが通常版にはない。TRIM を何度もくり返す必要がある） | 簡易なら可（直線のみ・範囲内の交点／端点で分割して内側の区間を削除） | https://jwcad.s-projects.net/envelope.html |
| Jw_cad | 包絡処理（中間線消去：Shift＋クリック） | 平行な2本の線の間にはさまれた線をまとめて消し、ふたをするように整える。 | 作図・編集 | ない | 簡易なら可 | https://cad.miscmemo.com/jw_cad-introduction/command-envelope/ |
| Jw_cad | 包絡処理（範囲内消去：右クリック） | 範囲の中に入っている線の部分だけを切り取って消す（はみ出た線は枠で切れて残る）。 | 作図・編集 | 一部ある＝EXTRIM は切り取り線を1本選ぶ方式。四角をドラッグするだけで内側を消す操作はない | 可 | https://jwcad.s-projects.net/envelope.html |
| Jw_cad | 消去［一括処理］（2本の基準線の間を部分消去） | 2本の基準線を選び、点線を引いて交わった線すべての「基準線の間」だけを消す。右クリックで同じ属性の線だけに絞れる。 | 作図・編集 | 一部ある＝TRIM＋フェンスでも近いことはできるが、切り取りエッジ選択と消す側の指定が必要で手数が多い | 可 | https://www.jwdojo.com/edit/1102.html |
| Jw_cad | 伸縮［一括処理］（基準線まで一括伸縮） | 基準線を1本決め、点線で交差させた多数の線を、伸びるものも縮むものもまとめて基準線にそろえる。基準線が斜めでもよい。 | 作図・編集 | 一部ある＝EXTEND と TRIM が別コマンドで、「伸ばす線と縮める線が混ざる」場合に1回で済まない | 可 | https://blog.caddare.com/jwcad/line/stretch-batch-processing |
| Jw_cad | 伸縮（基準線指定＋突出寸法） | 基準線まで伸ばす／縮めるとき、基準線から指定した長さだけ飛び出した位置で止める。 | 作図・編集 | ない（EXTEND 後に LENGTHEN が必要） | 可 | https://jwcad.s-projects.net/expansion-and-contraction.html |
| Jw_cad | 伸縮（指示点まで伸縮） | 線を選んで、画面上の任意の点・読取点をクリックすると、その点の位置（垂線の足）まで端を伸縮する。 | 作図・編集 | 一部ある＝LENGTHEN［動的］は近いが、端点を点に合わせる操作が直感的でない | 可 | https://jwcad.s-projects.net/expansion-and-contraction.html |
| Jw_cad | 複線［両側複線］［留線付両側複線］ | 1本の線の両側へ同時に平行線を引く。留線付きなら両端に直角の線も付いて長方形になる。 | 作図・編集 | ない（OFFSET は片側ずつ。両側・端のふたは手作業） | 可 | https://jwcad.s-projects.net/double-track.html |
| Jw_cad | 複線［端点指定］ | 平行線を引くとき、始点と終点をクリックして、元の線とは違う長さで引く。 | 作図・編集 | ない（OFFSET は元と同じ長さ） | 可 | https://jwcad.s-projects.net/double-track.html |
| Jw_cad | 複線［連続線選択］ | 端点がつながった線・円弧の連なりを一度に選び、まとめて平行線（角もつながる）を引く。 | 作図・編集 | 一部ある＝ポリラインなら OFFSET 可。バラバラの線は PEDIT/JOIN でつないでからでないとできない | 可 | https://cad.miscmemo.com/jw_cad/post-2860/ |
| Jw_cad | 複線［前回値］［連続］＋前の複線と角を連結 | 右クリックで前回の間隔のまま引ける。続けて引いた複線どうしの角を自動でつなぐ。［連続］で同じ間隔の線を次々と追加。 | 作図・編集 | 一部ある＝OFFSET の距離記憶・Multiple はあるが、角の自動連結はない | 可 | https://jwcad.s-projects.net/double-track.html |
| Jw_cad | 中心線 | 2本の線（平行でも斜めでも）、2つの円、2つの点のあいだに、クリックした始点〜終点の長さで中心線を1本引く。点どうしなら垂直二等分線になる。 | 作図・編集 | 一部ある＝CENTERLINE は2線の間のみ・長さは元の線に依存。点どうし・円どうし・長さ指定はできない | 可 | https://jwcad.s-projects.net/center-line.html |
| Jw_cad | 分割［等距離分割］（2線・2円・2点の間） | 2本の線（または線と点・点と点）の間を、指定数で均等に割る分割線を引く。逆分割・線長割合も選べる。 | 作図・編集 | ない（DIVIDE は1本の図形の上に点を置くだけ） | 可 | https://jwcad.s-projects.net/split.html |
| Jw_cad | 分割［等角度分割］ | 交わる2線（や円弧）の間を、同じ角度で割る線を引く。 | 作図・編集 | ない | 可 | https://jwcad.s-projects.net/split.html |
| Jw_cad | 分割［割付］［振分］［割付距離以下］ | 決まったピッチで割り付け、余りを両端に振り分けたり、指定ピッチ以下で最大の等間隔にしたりする。 | 作図・編集 | ない（MEASURE はピッチ固定で端に余りが出る） | 可 | https://jwcad.s-projects.net/split.html |
| Jw_cad | 分割［馬目地分割］ | 2線の間を、互い違い（レンガ積みのような）目地の線で埋める。 | 作図・編集 | ない（ハッチパターンで近いことはできるが実線にならない） | 可 | https://jwcad.s-projects.net/split.html |
| Jw_cad | 面取り［L面］［楕円面］ | 角をL字に切り欠く（例：10,5）、または楕円の弧で面取りする。 | 作図・編集 | ない（CHAMFER は斜め、FILLET は円弧のみ） | 可 | https://jwcad.s-projects.net/chamfering.html |
| Jw_cad | 矩形（寸法指定＋9点の基準位置） | 幅,高さを入力すると仮の四角が出て、左下・中央・右上など9か所のどこを基準にクリック位置へ置くかを選べる。 | 作図・編集 | 一部ある＝RECTANG［寸法］は角基準のみ。中心や辺の中点を基準に置くには手間がかかる | 可 | https://jwcad.s-projects.net/rectangle.html |
| Jw_cad | 矩形［多重］ | 四角の中を均等に分割する線、二重の四角（厚み指定）、角丸・角面を一度に描く。 | 作図・編集 | 一部ある＝角丸・面取りのみ。分割・二重はない | 可 | https://jwcad.s-projects.net/rectangle.html |
| Jw_cad | 曲線［サイン曲線］［2次曲線］ | 基準線・振幅・周期を指定して波形（サインカーブ）や放物線を描く。 | 作図・編集 | ない（SPLINE を手で打つしかない） | 可 | https://jwcad.s-projects.net/curve.html |
| Jw_cad | 線記号変形 | 既にある線を指示して、その線に沿った記号（破断線・折れ線など、自作・配布の記号ファイル）を倍率・角度つきで描く。 | 作図・編集 | 一部ある＝Express の BREAKLINE は破断線のみ。記号の種類を増やせる仕組みはない | 簡易なら可（記号をブロックで用意して線に合わせて配置） | https://jwcad.s-projects.net/line-deformation.html |
| Jw_cad | 線（端部に実点・矢印）／矢印追加 | 線を引くとき始点・終点・両端に●や矢印を付ける。既存の線に後から矢印を足すこともできる。 | 作図・編集 | 一部ある＝矢印は LEADER/QLEADER で別作図。既存の線への矢印付けはない | 可 | https://jwcad.s-projects.net/line.html |
| Jw_cad | 複写・移動［連続］ | 前回と同じ移動量で、さらにもう1つ複写（移動）を続ける。累積してずれていく。 | 作図・編集 | 一部ある＝COPY［配列］は事前に個数を決める方式。1回ずつ様子を見ながら足す操作はない | 可 | https://jwcad.s-projects.net/copy-and-move.html |
| Jw_cad | 貼付（倍率・回転・作図属性を指定して貼る） | クリップボードから貼るとき、倍率・回転角・線色やレイヤをその場で指定して置く。 | 作図・編集 | 一部ある＝PASTECLIP は位置だけ。貼った後に SCALE・ROTATE・プロパティ変更が要る | 可 | https://jwcad.s-projects.net/copy-and-paste.html |
| Jw_cad | 範囲選択（左＝文字を除く／右＝文字を含む） | 範囲を決める最後のクリックを左にするか右にするかで、文字を選択に含めるかどうかを切り替える。 | 選択 | ない（あとから QSELECT/FILTER で外す必要がある） | 可 | https://jwcad.s-projects.net/selection.html |
| Jw_cad | 範囲選択［切取り選択］ | 枠にまたがる図形を、枠の線で切り取って内側の部分だけを選ぶ（部分コピーなどに使う）。 | 選択 | ない | 簡易なら可（複写してから枠で EXTRIM 相当の切り取り） | https://jwcad.s-projects.net/selection.html |
| Jw_cad | 範囲選択［範囲外選択］ | 枠の外にある図形を選ぶ（範囲内選択の反対）。 | 選択 | ない | 可 | https://jwcad.s-projects.net/selection.html |
| Jw_cad | 範囲選択［連続線選択］ | 端点がつながった線・円弧を1クリックで芋づる式に全部選ぶ。 | 選択 | ない（ポリライン化していない線の連なりは1本ずつ選ぶ） | 可 | https://jwcad.s-projects.net/selection.html |
| Jw_cad | 選択範囲の記憶（最大8つ） | 選んだ図形の組を番号に記憶しておき、あとで呼び出して選び直す。 | 選択 | 一部ある＝SELECT［前回］は直前の1組だけ。GROUP は図形に属性が残る | 可 | https://jwcad.s-projects.net/selection.html |
| Jw_cad | 属性取得（TABキー） | 図形を1クリックすると、その図形のレイヤ・線色・線種（文字なら文字種）を「今の書込設定」にする。 | 画層 | 一部ある＝LAYMCUR はレイヤだけ、MATCHPROP は既存図形を変えるもの。ADDSELECTED は次のコマンドまで決めてしまう | 可 | https://jwcad.s-projects.net/attribute-acquisition.html |
| Jw_cad | 属性取得［右クリックでレイヤ表示反転］ | 表示中のレイヤと非表示のレイヤを一時的に入れ替えて、隠れている図形を確認する。もう一度で元に戻る。 | 画層 | 一部ある＝LAYISO/LAYOFF はあるが、「表示／非表示の反転」はない | 可 | https://jwcad.s-projects.net/attribute-acquisition.html |
| Jw_cad | 属性変更（書込レイヤに変更・線種変更をワンクリック） | 現在の書込レイヤ・線色・線種・文字種を決めておき、図形をクリックするたびにその属性へ変える。 | 画層 | 一部ある＝LAYMCH や MATCHPROP で近いが、「今の書込設定へ変える」専用操作はない | 可 | https://jwcad.s-projects.net/attribute-modification.html |
| Jw_cad | レイヤの3状態（書込／編集可能／表示のみ）＋プロテクトレイヤ | レイヤごとに「編集はできるが新しく描けない」「見えるだけで触れない」を切り替える。 | 画層 | 一部ある＝ロック（触れない）はある。「編集可・新規作図不可」の状態はない | 難しい | https://jwcad.s-projects.net/layer.html |
| Jw_cad | 縮尺の異なるレイヤグループ | 16のレイヤグループごとに縮尺を持たせ、1枚の図面に1/100と1/20の図などを実寸で同居させる。 | 画層 | 一部ある＝ペーパー空間のビューポートや異尺度対応で実現するが、考え方・手順が大きく違う | 難しい | https://jwcad.s-projects.net/layer.html |
| Jw_cad | 長さ取得［線長］［2点間長］［間隔］ | 入力中のコマンドの「寸法」欄に、既存の線の長さや2点間距離、2図形の間隔をクリックで入れる。 | 入力補助 | 一部ある＝距離入力で2点をクリックはできるが、「線を1本選んでその長さを値にする」ことはできない | 可（透過コマンドとして値を返す） | https://jwcad.s-projects.net/length-acquisition.html |
| Jw_cad | 角度取得［線角度］［線鉛直角度］［2点間角度］ | 既存の線の角度（またはそれに垂直な角度）をクリックで読み取り、入力中の角度欄に入れる。 | 入力補助 | 一部ある＝角度入力で2点指定は可。線を選んでその角度を取る方法はない | 可（透過コマンド） | https://jwcad.s-projects.net/angle-acquisition.html |
| Jw_cad | 長さ取得・角度取得［数値長］［数値角度］ | 図面に書いてある数値の文字をクリックして、その値を入力値として使う。 | 入力補助 | ない | 可（透過コマンド） | https://jwcad.s-projects.net/length-acquisition.html |
| Jw_cad | 軸角（線を指示して設定） | 既存の斜め線を指示して、その角度を水平・垂直の基準（直交・目盛）にする。 | 入力補助 | 一部ある＝UCS［オブジェクト］や SNAPANG で近いが、UCS を変えると他の操作に影響する | 簡易なら可（SNAPANG を線の角度にして、元に戻す機能付き） | https://jwcad.s-projects.net/angle-acquisition.html |
| Jw_cad | 距離指定点［連続］ | 線・円弧の上で、クリックした始点から指定距離の位置に点を打つ。連続で同じ間隔の点を次々と打つ。 | 入力補助 | 一部ある＝MEASURE は図形の端から全体に打つ。任意の始点から数個だけ打つことはできない | 可 | https://jwcad.s-projects.net/distance-point.html |
| Jw_cad | 点［仮点］［全仮点消去］ | 印刷されない目印の点を置き、あとで一括で消す。 | 入力補助 | 一部ある＝Defpoints 画層などで代用。専用の置く・一括消去はない | 可 | https://jwcad.s-projects.net/point.html |
| Jw_cad | 文字［連］（前付け・後付けで連結）・文字切断 | 2つの文字をクリック順に1つの文字列へつなぐ。逆に1つの文字を指定位置で2つに切る。 | 文字 | 一部ある＝TXT2MTXT で結合はできるがマルチテキストになる。1行文字を途中で切る機能はない | 可 | https://jwcad.s-projects.net/character.html |
| Jw_cad | 範囲選択［文字位置・集計］（行間・文字数で整列） | ばらばらの文字を選び「行間,1行の文字数」を指定して基準点に並べ直す。文字数で自動折り返しもできる。 | 文字 | 一部ある＝TEXTALIGN は整列のみ。行間をそろえた並べ直し・文字数での折り返しはない | 可 | https://setsubit.com/jwcad_moji-ichi/ |
| Jw_cad | 範囲選択［文字位置・集計］の集計／表計算［範囲内合計］ | 選んだ数値の文字の個数と合計を出し、合計値を図面に文字で書き込む。 | 表・書き出し | ない（フィールドは図形の値のみで、文字の数値を合計できない） | 可 | https://jwcad.s-projects.net/table-calculation.html |
| Jw_cad | 表計算［四則演算］ | A群・B群として選んだ数値の文字どうしを掛け・割り・足し・引きし、結果を図面に並べて書く（単価×数量など）。 | 表・書き出し | ない | 可 | https://jwcad.s-projects.net/table-calculation.html |
| Jw_cad | 文字［均等割付］［均等縮小］ | 「・」や「^数字」の指定で、決めた幅いっぱいに文字の間隔を広げたり縮めたりしてそろえる（表の項目名など）。 | 文字 | 一部ある＝TEXT の「フィット」は文字幅を変える。字間を広げてそろえる方法は1行文字にはない | 可 | https://setsubit.com/jwcad-character-25/ |
| Jw_cad | 文字［貼付］／［文読］（テキストの各行を行間指定で配置） | メモ帳などの複数行テキストを、1行ずつの文字として、決めた行間で整列して図面に置く。 | 文字 | 一部ある＝貼ると1つのマルチテキスト（またはOLE）になる | 可 | https://cad.miscmemo.com/jw_cad/letter-tips/ |
| Jw_cad | 寸法［一括処理］ | 寸法を入れる基準線を決め、始めと終わりの線を指示すると、その間で交わる線すべての位置に連続寸法を一度に入れる。 | 寸法・引出線 | 一部ある＝QDIM は図形の端点を拾う。「線と基準線の交点」で拾うことはできない | 可 | https://kantancad.com/Jw_cad9/Jw_cad11/Jw_cad-Entry44.html |
| Jw_cad | 寸法［累進］（基点円つき） | 1本の寸法線の上に、基点からの累計距離（0, 900, 2700…）を順に書く。 | 寸法・引出線 | 一部ある＝DIMBASELINE（段々に並ぶ）や座標寸法はあるが、1本の線上に累計値を並べる形式はない | 簡易なら可（線と文字で作図） | https://jwcad.s-projects.net/dimension.html |
| Jw_cad | 寸法［寸法値］（数値だけ記入） | 寸法線・引出線を描かずに、2点間の距離を数値の文字だけで書く。 | 寸法・引出線 | 一部ある＝寸法を分解するか、フィールドで長さ文字を作る手間がかかる | 可 | https://jwcad.s-projects.net/dimension.html |
| Jw_cad | 測定（距離の累積／測定結果書込） | 距離を次々とクリックして累計をステータスに出し、測った値（距離・面積・座標・角度）をそのまま文字で図面に書き込む。 | 図面管理・検図 | 一部ある＝MEASUREGEOM は表示のみ。累積と文字での書込はない | 可 | https://jwcad.s-projects.net/measurement.html |
| Jw_cad | 外部変形［三斜］（三斜求積） | 多角形を三角形に分け、底辺・高さと面積の表を図面に書き込む（敷地・区画の面積根拠）。 | 表・書き出し | ない | 簡易なら可 | https://jwcad.s-projects.net/external-deformation.html |
| Jw_cad | 座標ファイル（書出し・読込み） | 図形を座標のテキストファイルに書き出し、逆にテキストの座標から線・点・文字を作図する。XY入替え・m／mm切替あり。 | 表・書き出し | 一部ある＝データ書き出し（DATAEXTRACTION）やスクリプトで可能だが、簡単な座標テキストの読み書き専用機能はない | 可 | https://jwcad.s-projects.net/coordinate-file.html |
| Jw_cad | 外部変形「1.2.3 a.b.c 連番書出し」 | クリックするたびに 1,2,3… や a,b,c… の番号を順に置いていく。 | 文字 | 一部ある＝Express の TCOUNT は既存の文字に番号を付けるもの。クリックで順に置く機能はない | 可 | https://gaibu.yokohama-cad.co.jp/index.php?%E5%A4%96%E9%83%A8%E5%A4%89%E5%BD%A2%E4%B8%80%E8%A6%A7 |
| Jw_cad | 外部変形「文字 半角⇔全角変換」 | 選んだ文字の英数字・カナを、全角と半角のあいだで一括で変換する。 | 文字 | ない（FIND で1文字ずつ置換するしかない） | 可 | https://gaibu.yokohama-cad.co.jp/index.php?%E5%A4%96%E9%83%A8%E5%A4%89%E5%BD%A2%E4%B8%80%E8%A6%A7 |
| Jw_cad | 外部変形「線長集計」 | 選んだ線の長さを、線色・線種などの種類ごとに合計して書き出す（配管・配線の拾いなど）。 | 表・書き出し | 一部ある＝DATAEXTRACTION で可能だが手順が重い | 可 | https://gaibu.yokohama-cad.co.jp/index.php?%E5%A4%96%E9%83%A8%E5%A4%89%E5%BD%A2%E4%B8%80%E8%A6%A7 |
| Jw_cad | 外部変形「面積計算」系（JG_面積計算 など） | 閉じた範囲の面積を計算して中央に「○○㎡」と書き、一覧表にまとめる。 | 表・書き出し | 一部ある＝AREA／フィールドで1つずつはできるが、一括記入と表まとめはない | 可 | https://www.vector.co.jp/vpack/filearea/win/business/cad/jwcad/gaibu |
| Jw_cad | 外部変形「連続寸法入力」 | 「900,1800,900…」のように寸法値を並べて入力し、連続寸法を一気に作図する。 | 寸法・引出線 | ない | 可 | https://zumen.net/post-4459/ |
| Jw_cad | 外部変形「通り芯自動作図」 | X・Y方向の本数・間隔・番号を指定して、格子状の基準線と番号記号を一度に描く。 | 作図・編集 | ない（ARRAY と手作業） | 可 | https://zumen.net/post-4459/ |
| Jw_cad | クロックメニュー（左右ドラッグの時計方向メニュー）／AUTOモード | ボタンを押したまま12方向のどちらかへドラッグしてコマンドや読取点（中心点・線上点など）を呼び出す。 | 表示・操作 | ない（右クリックメニューやキー割当てで代用。マウスジェスチャはない） | 難しい（LISPではドラッグ方向を拾えない。ショートカット集で代替） | https://www.act.co.jp/haken/cadtech/cad-soft/2399/ |
| Jw_cad | レイヤ一覧（各レイヤの中身を縮小表示） | 16レイヤの中身を小さな絵で一覧表示し、クリックで書込レイヤや表示状態を切り替える。 | 画層 | ない（画層プロパティ管理は名前の一覧のみ） | 難しい（件数一覧程度なら可） | https://jwcad.s-projects.net/layer.html |
| Jw_cad | 数式入力（入力欄での計算） | 寸法や距離の入力欄に「1820*3+50」のような式をそのまま書いて使える。 | 入力補助 | 一部ある＝プロパティパレットや 'CAL・QuickCalc では可。コマンドの距離入力に式を直接は書けない | 簡易なら可（透過コマンドで式を計算して返す） | https://jwcad.s-projects.net/calculation.html |

## 確認できなかった・除外した理由

- **節間消し（消去）**：AutoCAD の TRIM クイックモード（2021以降）がほぼ同じ動き（クリックした区間を交点間で削除、交点がなければ全体削除）なので除外。
- **部分消去（2点で線の一部を消す）・線切断**：BREAK／BREAKATPOINT で足りるため除外。
- **コーナー、線の端点連結、データ整理（重複整理・連結整理）**：FILLET 半径0、JOIN、OVERKILL で同等のため除外。
- **特殊な読取点（中心点、2点間中心、線上点・交点、円周1/4点、オフセット読取）**：オブジェクトスナップ（中点、M2P、仮想交点、延長、四半円点、FROM）で同等のため除外。
- **パラメトリック変形**：STRETCH とほぼ同じ考え方なので除外（数値倍率指定などの細部の差は小さい）。
- **寸法図形化・寸法値の書換え・引出線角度・端部●**：AutoCAD の寸法は最初から連動・編集でき、DIMEDIT［傾斜］や矢印種類の設定もあるため除外。
- **表示順・ハッチ・接円・多角形・楕円・図形（部品登録）・画像同梱・文字の外部エディタ編集・文字の枠装飾・円弧沿い文字・Excel 表貼付**：DRAWORDER、HATCH、CIRCLE TTR、POLYGON、ELLIPSE、ブロック／ツールパレット、IMAGE／OLE、MTEXTED、TCIRCLE、ARCTEXT、TABLE で同等のため除外。
- **複写・移動の X/Y 方向固定、反転、複写先レイヤ指定、範囲選択の属性選択・基準点変更**：直交モード、MIRROR、COPYTOLAYER、QSELECT で同等のため除外。
- **2線・連続線・建具・線記号変形の建築用記号・図形の建築部品・捨コン砕石などの外部変形**：壁・建具など建築要素の自動作図にあたるため除外（範囲外）。
- **日影図・天空図・2.5D**：範囲外のため除外。
- **印刷の線色別線幅**：CTB（色従属印刷スタイル）で同等のため除外。
- **確認できなかった点**：Jw_cad の「補助線種（印刷されない線）」の一括消去メニューの正確な名前、「表示順」機能の有無（9.x での追加の有無）は一次情報で確かめられなかった。外部変形は Vector の一覧（人気順43本）と横浜CAD設計の一覧で名前は確認したが、個々の動作はダウンロードして確かめていない。

## Jw_cadから移った人が困ること（出典つき）

- **包絡処理がない**：「AutoCADに包絡が無いからJw_cadを使い続ける人もいる」と書かれている。タイル目地などの交差線整理を AutoCAD でやりたいという質問には「JWのように簡単にはできない」「LISPか互換CADで」と回答されている。
  - https://jwcad-q.com/jwcad-%E5%8C%85%E7%B5%A1-%E3%81%A7%E3%81%8D%E3%81%AA%E3%81%84/
  - https://detail.chiebukuro.yahoo.co.jp/qa/question_detail/q14287645184
- **クロックメニューがない**：時計の方向にドラッグしてコマンドを呼ぶ仕組みは他のCADにない、AutoCAD はキー割当てで代用する、と紹介されている。
  - https://www.act.co.jp/haken/cadtech/cad-soft/2399/
- **マウス中心からキーボード中心への切替え**：Jw はボタンを押してマウスで描くが、AutoCAD は「L→Enter→クリック→Enter」のようなコマンド入力が基本で戸惑う。画面の要素が多く「どこを見ればいいか分からない」、画層・テンプレートの運用ルールに慣れる必要がある。
  - https://note.com/wsm_bimope/n/nf1f6fe22b690
- **伸縮・トリムの考え方の違い**：Jw の伸縮は「残したい側」をクリックする。AutoCAD の TRIM は「消したい側」をクリックするため、逆の感覚になる。
  - https://www.pluscad.jp/howto/476/
- **データ変換の手間**：AutoCAD は JWW を直接開けず、DXF 経由や変換ツールが必要。文字化けや線種くずれが起きやすい。
  - https://blog.caddare.com/dare/2d/resolution-dare-converter
  - https://bizroad-svc.com/blog/jw_cad-autocad-ikou/
