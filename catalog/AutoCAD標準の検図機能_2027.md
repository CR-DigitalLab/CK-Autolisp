# AutoCAD標準の検図・品質チェック機能（2022〜2027）

調査日：2026-09-27。Autodesk公式ヘルプの原文を直接確認しました（公式ブログは取得できなかったため出典にしていません）。「未確認」と書いたものは推測で埋めていません。

**一番大きな変化**：AutoCAD 2027 の新機能 **Geometry Cleanup**（`GEOMETRYCLEANUPOPEN`）で、「わずかな傾き」と「端点の隙間・はみ出し・届いていない」を、許容差を指定して標準で検出・修正できるようになりました。LT 2027 でも使えます。

---

## 1. 傾き・わずかなずれ

| 機能・コマンド | 版 | できること | 限界 | LT |
|---|---|---|---|---|
| **Geometry Cleanup**（GEOMETRYCLEANUPOPEN／管理タブ > Cleanup） | **2027** | **絶対角度**：0°・90°など（任意に追加可）からわずかにずれた線を検出。**相対角度**：交わる2本が90°・45°などからわずかにずれたものを検出。許容差（度、0.0001より大）を指定、推奨値も表示。直し方の候補（回転・移動・ストレッチ）をプレビューして適用。「意図どおり」で除外可。設定は .gcs で保存 | 対象は線・XY平面上のポリライン・円弧・楕円弧のみ。ブロック、ハッチ、Z≠0、ペーパー空間、ロック／フリーズ画層は対象外。**座標値そのものの端数（例 X=1000.0003）は見ない**。許容差を大きくすると誤検出が増える | ○ |
| AUTOCONSTRAIN | 既存 | 角度の許容差内で水平・垂直・平行・直交の拘束を付ける（結果的にそろう） | 検出・一覧は無い。拘束が残る | × |
| FLATTEN（Express Tools） | 既存 | Zのずれを0にそろえる（Geometry Cleanup の前処理として推奨） | 検出はしない。大量の図形では遅い | × |

## 2. 隙間・端点

| 機能・コマンド | 版 | できること | 限界 | LT |
|---|---|---|---|---|
| **Geometry Cleanup** | **2027** | **隙間**（一致すべき端点が一致しない）、**はみ出し**、**届いていない**を検出。直し方はトリム・延長・移動・ストレッチ。座標付きの一覧で確認 | 対象図形の制限は上と同じ。重複・長さ0・円・スプライン・ブロック内部は見ない。FLATTEN・OVERKILL を先に実行したかで結果が変わる | ○ |
| Map 3D の Drawing Cleanup（MAPCLEAN） | 既存 | 重複削除・短い図形削除・交差で分割・届いていない線の延長・近い端点をまとめる・宙に浮いた線の削除・長さ0の削除 など。1件ずつ確認するモードあり | **Map 3D／Civil 3D ツールセット専用**。GIS向けの考え方 | × |

## 3. 重複・重なり・長さ0

| 機能・コマンド | 版 | できること | 限界 | LT |
|---|---|---|---|---|
| OVERKILL | 既存（Express から本体へ） | 重複の削除、同じ直線上の重なり・端と端が接する線の結合、ポリライン内の重複頂点の削除。許容差指定可 | **削除・結合するだけで報告は出ない**。わずかに傾いた重なりや、届いていない端点は対象外 | ○ |
| PURGE | 2020で作り直し | 長さ0の図形・空の文字・孤立データの削除 | 削除するだけで場所は分からない。ブロック内・ロック画層は対象外 | ○ |
| COUNT | 2022 | ブロックの数え間違い（重なり・分解・名前変更）を一覧化 | ブロックのみ | ○ |

## 4. 寸法の上書き・関連付けなし

| 機能・コマンド | 版 | できること | 限界 | LT |
|---|---|---|---|---|
| QSELECT（寸法の「文字の優先」を `?*` で検索） | 既存（使い方の工夫） | 上書きされた寸法を選ぶ | **「<> TYP」のように実測値を残して文字を足したものまで拾う**。分解された寸法は対象外。公式手順ではない | ○（動作未確認） |
| ANNOMONITOR（注釈モニター） | 2012頃 | 関連付けのない寸法・引出線に警告マークを表示 | 表示だけで、一覧や件数は出ない | ○ |
| DIMREASSOCIATE | 既存 | 寸法を1つずつ確認して関連付けし直す | 一括の検査には向かない | ○ |
| DIMREASSOC（Express Tools） | 既存 | 上書きされた寸法値を実測値に戻す | 検出だけはできない | × |
| AMCHECKDIM | 既存 | 上書きされた寸法を強調表示し、件数を出して選択 | **Mechanical ツールセット専用** | × |
| 寸法値と実際の形状の食い違いを比べる機能 | ― | **標準には見つからなかった** | ― | ― |

## 5. その他の検図支援

| 機能 | 版 | 内容 | LT |
|---|---|---|---|
| Autodesk Assistant | 2024〜（2027で標準ファイル照合・言葉での選択・問い合わせ） | 画層・スタイルなどの違いを報告するだけ（形状は見ない）。**試験提供**で「間違うことがある」と明記 | 一部 |
| CHECKSTANDARDS | 既存 | 画層・寸法スタイル・線種・文字スタイルだけを照合 | × |
| AUDIT | 既存 | 図面データの破損の検出・修復（作図ミスは見ない） | ○ |
| COMPARE／XCOMPARE | 2019〜 | 版の違いを色分け・雲マークで表示 | ○ |
| Activity Insights | 2024〜 | 変更履歴の確認 | ○ |

---

## 標準機能でまだできないこと（LISPの出番）

1. **2026以前の環境**では、傾き・隙間を許容差つきで検出する標準機能が無い。2025／2026 のユーザーには LISP が主な手段。
2. **Geometry Cleanup（2027）でも対象外**：ブロック内部、外部参照、ハッチ境界、円・スプライン、Z≠0、ペーパー空間、ロック／フリーズ画層、**座標値の端数（グリッドからの微小ずれ）**、重複・長さ0・短すぎる線、**結果のCSV出力**、**複数図面の一括検査**。
3. **寸法**：上書きを「<>付き」「完全な手入力」「値が実測と違う」に分けて判定する機能、手入力値と実測値の差を数値で出す機能、関連付けのない寸法の一覧・件数、分解された「偽の寸法」の検出は、Mechanical 以外の標準には無い。
4. **重なり**：わずかに傾いた2本の重なりの検出、削除せずに報告だけする機能は無い（Map 3D のみ近いことができる）。
5. **LT**：Express Tools・CHECKSTANDARDS・AUTOCONSTRAIN・Map 3D・AMCHECKDIM は使えない。LT 2024 以降は AutoLISP が動くので、自作の検査LISPがLTでも使える。

## 主な出典

- AutoCAD 2027 What's New：https://help.autodesk.com/cloudhelp/2027/ENU/AutoCAD-WhatsNew/files/GUID-D52A51CA-BDA1-4A78-9E67-87B340C55490.htm
- Geometry Cleanup（What's New）：https://help.autodesk.com/cloudhelp/2027/ENU/AutoCAD-WhatsNew/files/GUID-BAA6379F-68A6-4D56-BE22-307170488818.htm
- About Geometry Cleanup：https://help.autodesk.com/cloudhelp/2027/ENU/AutoCAD-Core/files/GUID-F8EC70C3-5873-4970-AADD-70F6B600A556.htm
- Geometry Cleanup Settings：https://help.autodesk.com/cloudhelp/2027/ENU/AutoCAD-Core/files/GUID-0ABC1E66-612C-4D0B-8052-3FB8A2A895FE.htm
- GEOMETRYCLEANUPOPEN（LT）：https://help.autodesk.com/cloudhelp/2027/ENU/AutoCAD-LT/files/GUID-B06B2940-48B4-4C57-8487-A74000F34E01.htm
- OVERKILL：https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-A9927B3C-7C30-43FB-B6A9-29843B35001C.htm
- PURGE：https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-C6B62BBD-C363-4DC7-AF43-036A7B287473.htm
- ANNOMONITOR：https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-EEF0796B-9C18-476A-A0E8-876BC5346C97.htm
- DIMREASSOC：https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Core/files/GUID-9D2D79DD-D8A9-4856-8459-4361B5A99655.htm
- AMCHECKDIM（Mechanical）：https://help.autodesk.com/cloudhelp/2026/ENU/AutoCAD-Mechanical/files/GUID-EC8CFD94-4DD6-4E9F-9A09-7D68F2326F7F.htm
- Map 3D Drawing Cleanup：https://help.autodesk.com/cloudhelp/2026/ENU/MAP3D-Use/files/GUID-4F6E7302-73F3-4C18-9EEE-CBC4E7BC8FF7.htm
- Autodesk Assistant 2027：https://help.autodesk.com/cloudhelp/2027/ENU/AutoCAD-WhatsNew/files/GUID-99E2D8F7-D4D9-4B3A-9E57-7B73D6BB12AD.htm
- QSELECT で上書き寸法を探す（ARKANCE）：https://ukcommunity.arkance.world/hc/en-us/articles/21550761199378-AutoCAD-Tip-Locating-Dimensions-that-have-been-overridden-as-text

新機能全般は [AutoCAD新機能まとめ_2019-2027.md](AutoCAD新機能まとめ_2019-2027.md) を参照。
