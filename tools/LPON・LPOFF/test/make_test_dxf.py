# LPON・LPOFF 動作確認用 DXF を作るスクリプト（ezdxf 使用）。python make_test_dxf.py で同じフォルダに DXF を作る
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

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "LPON・LPOFF_test.dxf")
doc = new_doc()
msp = doc.modelspace()
doc.layers.add("壁", color=1)
doc.layers.add("家具", color=3)
lay = doc.layers.add("補助線", color=6)
lay.dxf.plot = 0
doc.layers.add("ロック画層", color=2).lock()
x, y = header(doc, 0, "非印刷にする（LPOFF）", "LPOFF → 壁・家具の線を選ぶ →「壁」「家具」の2つが一覧に出て「合計 2 個の画層を非印刷に設定しました」。画層管理で印刷の列が「印刷しない」。")
msp.add_line((x + 10, y - 35), (x + 110, y - 35), dxfattribs={"layer": "壁"})
msp.add_line((x + 10, y - 55), (x + 110, y - 55), dxfattribs={"layer": "家具"})
x, y = header(doc, 1, "印刷可能にする（LPON）", "LPON → 補助線を選ぶ →「補助線」が印刷可能に。")
msp.add_line((x + 10, y - 45), (x + 110, y - 45), dxfattribs={"layer": "補助線"})
x, y = header(doc, 2, "Defpoints を含めて LPON", "Defpoints の線も選ぶ →「Defpoints…スキップしました」と出て、ほかの画層だけ印刷可能に。")
doc.layers.get("Defpoints").dxf.plot = 0
msp.add_line((x + 10, y - 45), (x + 110, y - 45), dxfattribs={"layer": "Defpoints"})
x, y = header(doc, 3, "ロック画層の図形", "ロック画層の図形も選べ、その画層の印刷設定が変わる。")
msp.add_line((x + 10, y - 45), (x + 110, y - 45), dxfattribs={"layer": "ロック画層"})
x, y = header(doc, 4, "何も選ばない／Esc／U", "何も選ばず Enter →「選択されませんでした」。Esc でエラーにならない。U を1回で印刷設定が元に戻る。")
finish(doc, OUT, 5)
