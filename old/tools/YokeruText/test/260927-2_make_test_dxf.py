# YokeruText 動作確認用DXFを作るスクリプト（ezdxf 使用）
# 使い方: python make_test_dxf.py  → 同じフォルダに YokeruText_test.dxf を作る
import math
import os
import ezdxf
from ezdxf.enums import TextEntityAlignment

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "YokeruText_test.dxf")
H = 2.5            # テスト文字の高さ
CW, CH = 140, 80   # 区画の幅・高さ
COLS = 4

doc = ezdxf.new("R2018", setup=True)
doc.header["$INSUNITS"] = 4  # mm
msp = doc.modelspace()

# 文字スタイル（見出し用に日本語が出るTrueType）
doc.styles.add("YK_JP", font="msgothic.ttc")

# 画層
layers = {
    "YK_見出し": dict(color=8, lock=True),     # 見出し・期待結果（ロックして動かないように）
    "YK_区画": dict(color=9, lock=True),       # 区画の枠
    "TEXT": dict(color=7),                    # テスト用の文字
    "OBJ": dict(color=4),                     # 障害物（線など）
    "DIM": dict(color=3),
    "HATCH": dict(color=252),
    "LOCKED": dict(color=1, lock=True),       # ロック画層の文字
    "FIX": dict(color=5),                     # 固定画層テスト用
    "HIDDEN_OFF": dict(color=6, off=True),    # 非表示画層の線
    "HIDDEN_FRZ": dict(color=6, freeze=True), # フリーズ画層の線
}
for name, a in layers.items():
    lay = doc.layers.add(name, color=a["color"])
    if a.get("lock"):
        lay.lock()
    if a.get("off"):
        lay.off()
    if a.get("freeze"):
        lay.freeze()


def cell_origin(i):
    r, c = divmod(i, COLS)
    return (c * CW, -r * CH)


def header(i, title, expect):
    x0, y0 = cell_origin(i)
    msp.add_lwpolyline([(x0, y0), (x0 + CW - 10, y0), (x0 + CW - 10, y0 - CH + 10), (x0, y0 - CH + 10)],
                       close=True, dxfattribs={"layer": "YK_区画"})
    msp.add_text(f"{i + 1:02d}. {title}", height=3.5,
                 dxfattribs={"layer": "YK_見出し", "style": "YK_JP"}).set_placement((x0 + 3, y0 - 6))
    m = msp.add_mtext("期待：" + expect, dxfattribs={"layer": "YK_見出し", "style": "YK_JP", "char_height": 2.0})
    m.dxf.insert = (x0 + 3, y0 - 9)
    m.dxf.width = CW - 20
    return x0, y0


def txt(s, x, y, rot=0.0, align=None, layer="TEXT", h=H):
    t = msp.add_text(s, height=h, rotation=rot, dxfattribs={"layer": layer})
    if align:
        t.set_placement((x, y), align=align)
    else:
        t.set_placement((x, y))
    return t


cases = []

# 01 線と重なった文字
x, y = header(0, "線と重なった文字", "3つの文字が線から離れる。短い移動なら引出線なし。")
msp.add_line((x + 10, y - 35), (x + 120, y - 35), dxfattribs={"layer": "OBJ"})
txt("TEXT-A on line", x + 20, y - 36)
msp.add_line((x + 90, y - 20), (x + 90, y - 65), dxfattribs={"layer": "OBJ"})
txt("TEXT-B cross", x + 82, y - 50)
msp.add_line((x + 15, y - 65), (x + 60, y - 45), dxfattribs={"layer": "OBJ"})
txt("TEXT-C diag", x + 25, y - 58)

# 02 文字どうしの重なり
x, y = header(1, "文字どうしの重なり", "3つの文字が互いに重ならない位置へ散らばる（どれか1つは元の位置のまま）。")
txt("OVERLAP-1", x + 40, y - 40)
txt("OVERLAP-2", x + 43, y - 41)
txt("OVERLAP-3", x + 46, y - 39)

# 03 回転した文字
x, y = header(2, "回転した文字（30度・90度）", "回転したまま、線から離れる。回転角は変わらない。")
msp.add_line((x + 10, y - 40), (x + 120, y - 40), dxfattribs={"layer": "OBJ"})
txt("ROTATED-30", x + 30, y - 45, rot=30)
msp.add_line((x + 100, y - 20), (x + 60, y - 68), dxfattribs={"layer": "OBJ"})
txt("ROTATED-90", x + 85, y - 60, rot=90)

# 04 マルチテキスト
x, y = header(3, "マルチテキスト（複数行・中央基点）", "複数行の文字全体が円と線から離れる。")
msp.add_circle((x + 60, y - 45), 10, dxfattribs={"layer": "OBJ"})
mt = msp.add_mtext("MTEXT LINE1\\PMTEXT LINE2\\PMTEXT LINE3", dxfattribs={"layer": "TEXT", "char_height": H})
mt.dxf.insert = (x + 60, y - 45)
mt.dxf.attachment_point = 5  # 中央中心
mt.dxf.width = 30
msp.add_line((x + 95, y - 25), (x + 95, y - 68), dxfattribs={"layer": "OBJ"})
mt2 = msp.add_mtext("RIGHT-TOP MTEXT", dxfattribs={"layer": "TEXT", "char_height": H})
mt2.dxf.insert = (x + 115, y - 50)
mt2.dxf.attachment_point = 3  # 右上
mt2.dxf.width = 40

# 05 位置合わせ（右寄せ・中央・フィット）
x, y = header(4, "位置合わせのある文字（右・中央・中下）", "位置合わせの種類に関係なく、正しく線から離れる。")
msp.add_line((x + 10, y - 30), (x + 125, y - 30), dxfattribs={"layer": "OBJ"})
txt("RIGHT-ALIGN", x + 50, y - 30, align=TextEntityAlignment.RIGHT)
msp.add_line((x + 10, y - 48), (x + 125, y - 48), dxfattribs={"layer": "OBJ"})
txt("CENTER", x + 70, y - 48, align=TextEntityAlignment.CENTER)
msp.add_line((x + 10, y - 63), (x + 125, y - 63), dxfattribs={"layer": "OBJ"})
txt("MIDDLE-CENTER", x + 100, y - 63, align=TextEntityAlignment.MIDDLE_CENTER)

# 06 寸法の近く
x, y = header(5, "寸法の近くの文字", "寸法線・寸法値・補助線と重ならない位置へ。寸法の間の空白には入ってよい。")
dim = msp.add_linear_dim(base=(x + 20, y - 40), p1=(x + 20, y - 60), p2=(x + 110, y - 60),
                         dxfattribs={"layer": "DIM"})
dim.render()
txt("NEAR-DIM", x + 55, y - 41)
txt("ON-DIM-VALUE", x + 60, y - 38.5)

# 07 図枠ブロックの中
frame = doc.blocks.new(name="YK_FRAME")
frame.add_lwpolyline([(0, 0), (120, 0), (120, 55), (0, 55)], close=True)
frame.add_lwpolyline([(80, 0), (120, 0), (120, 12), (80, 12)], close=True)
x, y = header(6, "大きな図枠ブロックの中", "図枠全体を障害物と見なさない。枠内の文字は線からだけ離れる（大きく飛ばない）。")
msp.add_blockref("YK_FRAME", (x + 5, y - 68), dxfattribs={"layer": "OBJ"})
msp.add_line((x + 20, y - 40), (x + 70, y - 40), dxfattribs={"layer": "OBJ"})
txt("IN-FRAME", x + 30, y - 41)
txt("IN-TITLE-AREA", x + 88, y - 62)

# 08 小さな記号ブロック
sym = doc.blocks.new(name="YK_SYMBOL")
sym.add_circle((0, 0), 3)
sym.add_line((-3, 0), (3, 0))
sym.add_line((0, -3), (0, 3))
x, y = header(7, "小さな記号ブロック", "記号（丸に十字）の上から文字がどく。")
for k in range(4):
    msp.add_blockref("YK_SYMBOL", (x + 25 + k * 25, y - 40), dxfattribs={"layer": "OBJ"})
    txt(f"SYM-{k + 1}", x + 20 + k * 25, y - 41)

# 09 ロック画層の文字
x, y = header(8, "ロック画層の文字", "動かない。結果に「ロック画層 1」と表示される。")
msp.add_line((x + 10, y - 40), (x + 120, y - 40), dxfattribs={"layer": "OBJ"})
txt("LOCKED-TEXT", x + 40, y - 41, layer="LOCKED")

# 10 固定画層
x, y = header(9, "固定画層（設定で FIX を指定した場合）", "YKS→固定画層(F)に FIX を入れて実行すると動かない。未設定なら動く。")
msp.add_line((x + 10, y - 40), (x + 120, y - 40), dxfattribs={"layer": "OBJ"})
txt("FIX-LAYER-TEXT", x + 40, y - 41, layer="FIX")

# 11 非表示画層の線
x, y = header(10, "非表示・フリーズ画層の線", "見えない線は障害物にしない＝文字は動かない（重なり 0）。")
msp.add_line((x + 10, y - 35), (x + 120, y - 35), dxfattribs={"layer": "HIDDEN_OFF"})
txt("OVER-OFF-LINE", x + 40, y - 36)
msp.add_line((x + 10, y - 55), (x + 120, y - 55), dxfattribs={"layer": "HIDDEN_FRZ"})
txt("OVER-FROZEN-LINE", x + 40, y - 56)

# 12 逃げ場なし
x, y = header(11, "逃げ場なし（細かい格子の中）", "赤枠で表示され、終了後に選択状態。マスク(K)ON で MTEXT なら背景マスク。")
for k in range(0, 41, 2):
    msp.add_line((x + 20, y - 20 - k), (x + 110, y - 20 - k), dxfattribs={"layer": "OBJ"})
    msp.add_line((x + 20 + k * 2.25, y - 20), (x + 20 + k * 2.25, y - 60), dxfattribs={"layer": "OBJ"})
txt("NO-ESCAPE", x + 55, y - 41)
mt3 = msp.add_mtext("NO-ESCAPE MTEXT", dxfattribs={"layer": "TEXT", "char_height": H})
mt3.dxf.insert = (x + 60, y - 50)
mt3.dxf.attachment_point = 5
mt3.dxf.width = 30

# 13 密集した注記
x, y = header(12, "密集した注記（10個が1点に集中）", "放射状に散らばり、大きく動いたものには引出線が付く。引出線どうしは交差することがある。")
cx, cy = x + 65, y - 45
msp.add_circle((cx, cy), 1.5, dxfattribs={"layer": "OBJ"})
for k in range(10):
    txt(f"LABEL-{k + 1:02d}", cx - 8 + (k % 3) * 1.2, cy - 1 + (k % 4) * 0.8)

# 14 円弧を含むポリライン
x, y = header(13, "円弧を含むポリライン・スプライン", "曲線の形に沿って正しく判定し、文字が曲線から離れる。")
pl = msp.add_lwpolyline([(x + 10, y - 50, 0, 0, -1), (x + 60, y - 50, 0, 0, 0), (x + 120, y - 50)],
                        format="xyseb", dxfattribs={"layer": "OBJ"})
txt("ON-ARC-SEGMENT", x + 25, y - 28)
txt("ON-STRAIGHT", x + 80, y - 51)
msp.add_spline([(x + 10, y - 65), (x + 40, y - 58), (x + 70, y - 68), (x + 120, y - 60)],
               dxfattribs={"layer": "OBJ"})
txt("ON-SPLINE", x + 55, y - 65)

# 15 ハッチの上
x, y = header(14, "ハッチの上の文字", "初期設定（ハッチ＝障害物にしない）では動かない。ハッチ(H)ON にするとハッチの外へ出る（引出線付き）。")
hatch = msp.add_hatch(color=252, dxfattribs={"layer": "HATCH"})
hatch.set_pattern_fill("ANSI31", scale=1.0)
hatch.paths.add_polyline_path([(x + 30, y - 35), (x + 100, y - 35), (x + 100, y - 50), (x + 30, y - 50)], is_closed=True)
txt("ON-HATCH", x + 55, y - 43)

# 16 重なっていない文字（対照）
x, y = header(15, "重なっていない文字（対照）", "動かない（移動 0）。")
msp.add_line((x + 10, y - 30), (x + 120, y - 30), dxfattribs={"layer": "OBJ"})
txt("FREE-TEXT-1", x + 30, y - 45)
txt("FREE-TEXT-2", x + 30, y - 60)

# 17 長い文字
x, y = header(16, "長い文字", "長い文字全体として判定し、線から離れる。")
msp.add_line((x + 60, y - 20), (x + 60, y - 68), dxfattribs={"layer": "OBJ"})
txt("THIS-IS-A-VERY-LONG-TEXT-STRING", x + 12, y - 45)

# 18 3Dに傾いた文字
x, y = header(17, "3Dに傾いた文字", "動かない。結果の「非表示/3D/その他」に数えられる。")
msp.add_line((x + 10, y - 40), (x + 120, y - 40), dxfattribs={"layer": "OBJ"})
t3 = msp.add_text("TILTED-3D", height=H, dxfattribs={"layer": "TEXT", "extrusion": (0, 1, 1)})
t3.set_placement((x + 40, y - 41))

# 19 UCS・画面ズームの確認用（01と同じ配置）
x, y = header(18, "UCS回転・ズーム確認用（01と同じ）", "UCSを回転させたり、この区画だけ拡大した状態でも、01と同じ結果になる。")
msp.add_line((x + 10, y - 35), (x + 120, y - 35), dxfattribs={"layer": "OBJ"})
txt("UCS-TEST-A", x + 20, y - 36)
msp.add_line((x + 90, y - 20), (x + 90, y - 65), dxfattribs={"layer": "OBJ"})
txt("UCS-TEST-B", x + 82, y - 50)

# 20 引出線の距離しきい値
x, y = header(19, "少しだけ重なった文字（引出線なしの確認）", "わずかに動くだけで、引出線は付かない。")
msp.add_line((x + 10, y - 40), (x + 120, y - 40), dxfattribs={"layer": "OBJ"})
txt("SLIGHT-TOUCH", x + 40, y - 39.6)

doc.set_modelspace_vport(height=CH * 5.5, center=(CW * COLS / 2, -CH * 2.2))
doc.saveas(OUT)
print("saved:", OUT)
