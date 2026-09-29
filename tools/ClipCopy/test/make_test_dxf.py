# ClipCopy 動作確認用 DXF を作るスクリプト（ezdxf 使用）。python make_test_dxf.py で同じフォルダに DXF を作る
# ---- 共通：区画・見出し（ロック画層）・期待結果 ----
import os
import ezdxf

CW, CH, COLS = 140, 80, 3


def new_doc():
    doc = ezdxf.new("R2018", setup=True)
    doc.header["$INSUNITS"] = 4
    doc.styles.add("TEST_JP", font="msgothic.ttc")
    doc.layers.add("TEST_見出し", color=8).lock()
    doc.layers.add("TEST_区画", color=9).lock()
    return doc


def header(doc, i, title, expect):
    msp = doc.modelspace()
    r, c = divmod(i, COLS)
    x0, y0 = c * CW, -r * CH
    msp.add_lwpolyline([(x0, y0), (x0 + CW - 10, y0), (x0 + CW - 10, y0 - CH + 10), (x0, y0 - CH + 10)],
                       close=True, dxfattribs={"layer": "TEST_区画"})
    msp.add_text(f"{i + 1:02d}. {title}", height=3.5,
                 dxfattribs={"layer": "TEST_見出し", "style": "TEST_JP"}).set_placement((x0 + 3, y0 - 6))
    m = msp.add_mtext("期待：" + expect, dxfattribs={"layer": "TEST_見出し", "style": "TEST_JP", "char_height": 2.0})
    m.dxf.insert = (x0 + 3, y0 - 9)
    m.dxf.width = CW - 20
    return x0, y0


def finish(doc, path, n):
    rows = (n + COLS - 1) // COLS
    doc.set_modelspace_vport(height=CH * rows + 20, center=(CW * COLS / 2, -CH * rows / 2 + 10))
    doc.saveas(path)
    print("saved:", path)

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "ClipCopy_test.dxf")
doc = new_doc()
msp = doc.modelspace()
doc.layers.add("図形", color=4)
doc.layers.add("ロック", color=1).lock()
b = doc.blocks.new("記号")
b.add_circle((0, 0), 4)
b.add_line((-4, 0), (4, 0))
L = {"layer": "図形"}

def sample(x, y):
    msp.add_lwpolyline([(x + 10, y - 20), (x + 110, y - 20), (x + 110, y - 65), (x + 10, y - 65)], close=True, dxfattribs=L)
    msp.add_line((x + 10, y - 42), (x + 110, y - 42), dxfattribs=L)
    msp.add_circle((x + 40, y - 42), 12, dxfattribs=L)
    msp.add_text("CLIP-TEXT", height=3, dxfattribs=L).set_placement((x + 70, y - 35))

x, y = header(doc, 0, "線・円・文字の一部を切り取ってコピー", "CLC → 円の中心付近と右下を対角に指定 →「基点コピー完了」。PASTECLIP で貼ると、枠で切り取られた形が貼れる。元の図形は1本も消えていない。")
sample(x, y)
x, y = header(doc, 1, "ブロックとハッチを含む範囲", "ブロック・ハッチも枠で切り取られて貼れる。元の図形はそのまま。")
sample(x, y)
msp.add_blockref("記号", (x + 90, y - 55), dxfattribs=L)
h = msp.add_hatch(color=8, dxfattribs=L)
h.set_pattern_fill("ANSI31", scale=0.5)
h.paths.add_polyline_path([(x + 15, y - 60), (x + 35, y - 60), (x + 35, y - 48), (x + 15, y - 48)], is_closed=True)
x, y = header(doc, 2, "ロック画層の図形を含む範囲", "エラーで止まらないか。止まった場合も「実行前の状態に戻しました」と出て、図形が消えたままにならないか（ver1 では消えたままになる恐れがあった）。")
sample(x, y)
msp.add_line((x + 20, y - 30), (x + 100, y - 55), dxfattribs={"layer": "ロック"})
x, y = header(doc, 3, "何もない範囲／Esc", "何もない所を囲む →「範囲内にオブジェクトがありませんでした」。1点目で Esc → エラーにならず、OSMODE・CMDECHO が実行前の値。")
x, y = header(doc, 4, "U（元に戻す）", "CLC のあと U を1回 → 実行前の状態（作られたブロック定義 CLIP_… も消える）。")
sample(x, y)
finish(doc, OUT, 5)
