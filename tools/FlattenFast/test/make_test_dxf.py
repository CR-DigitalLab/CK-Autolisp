# FlattenFast 動作確認用 DXF を作るスクリプト（ezdxf 使用）。python make_test_dxf.py で同じフォルダに DXF を作る
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

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "FlattenFast_test.dxf")
doc = new_doc()
msp = doc.modelspace()
doc.layers.add("図形", color=4)
doc.layers.add("ロック", color=1).lock()
L = {"layer": "図形"}
b = doc.blocks.new("記号")
b.add_circle((0, 0), 4)
x, y = header(doc, 0, "Z がずれた線・円・文字", "FTF → 全部選ぶ →「○個のオブジェクトのZ座標を0にしました！」。プロパティで Z（始点・終点・中心・挿入点）が全部 0。")
msp.add_line((x + 10, y - 30, 5), (x + 110, y - 30, -3), dxfattribs=L)
msp.add_circle((x + 40, y - 50, 12.5), 8, dxfattribs=L)
msp.add_text("Z=7", height=3, dxfattribs=L).set_placement((x + 80, y - 55, 7))
x, y = header(doc, 1, "高度・厚みのあるポリライン・円", "ポリラインの高度が 0、円の厚みが 0 になる。")
pl = msp.add_lwpolyline([(x + 10, y - 25), (x + 60, y - 25), (x + 60, y - 60)], dxfattribs=L)
pl.dxf.elevation = 20
c = msp.add_circle((x + 95, y - 45), 10, dxfattribs=L)
c.dxf.thickness = 15
x, y = header(doc, 2, "3D ポリラインとブロック", "3D ポリラインの各頂点の Z が 0、ブロックの挿入点の Z が 0。")
msp.add_polyline3d([(x + 10, y - 60, 0), (x + 50, y - 25, 10), (x + 90, y - 60, -5)], dxfattribs=L)
msp.add_blockref("記号", (x + 110, y - 45, 30), dxfattribs=L)
x, y = header(doc, 3, "ロック画層の図形", "ロック画層の線は選べず、Z はそのまま（Z=9）。")
msp.add_line((x + 10, y - 45, 9), (x + 110, y - 45, 9), dxfattribs={"layer": "ロック"})
x, y = header(doc, 4, "何も選ばない／Esc／U", "何も選ばず Enter →「選択されませんでした」。選択中に Esc で「Error: …」と出ない。実行後に U を1回で全部元の Z に戻る（ver1 は1図形ずつ戻っていた）。")
finish(doc, OUT, 5)
