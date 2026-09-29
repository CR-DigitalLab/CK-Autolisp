# HPDRAWORDER1 動作確認用 DXF を作るスクリプト（ezdxf 使用）。python make_test_dxf.py で同じフォルダに DXF を作る
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

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "HPDRAWORDER1_test.dxf")
doc = new_doc()
msp = doc.modelspace()
x, y = header(doc, 0, "図面を開いたあとの設定", "HPDRAWORDER を 3 にしておく → スタートアップ登録してからこの図面を開く → HPDRAWORDER と打つと 1 になっている。")
x, y = header(doc, 1, "ハッチングが最背面に", "区画内の四角の中を HATCH（SOLID）で塗る → 線と文字の後ろに回り、線と文字が見える。")
msp.add_lwpolyline([(x + 20, y - 25), (x + 110, y - 25), (x + 110, y - 60), (x + 20, y - 60)], close=True)
msp.add_line((x + 20, y - 42), (x + 110, y - 42))
msp.add_text("文字が見える", height=3).set_placement((x + 50, y - 55))
finish(doc, OUT, 2)
