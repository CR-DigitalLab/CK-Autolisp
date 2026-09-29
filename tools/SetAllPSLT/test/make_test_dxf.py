# SetAllPSLT 動作確認用 DXF を作るスクリプト（ezdxf 使用）。python make_test_dxf.py で同じフォルダに DXF を作る
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

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "SetAllPSLT_test.dxf")
doc = new_doc()
msp = doc.modelspace()
doc.linetypes.add("DASHED2", pattern=[10, 6, -4], description="破線")
x, y = header(doc, 0, "全レイアウトの PSLTSCALE", "SETALLPSLT → 0 または 1 → レイアウト1〜3 すべての PSLTSCALE がその値になり、元のレイアウトに戻る。")
msp.add_line((x + 10, y - 40), (x + 120, y - 40), dxfattribs={"linetype": "DASHED2"})
x, y = header(doc, 1, "入力で Esc", "値の入力で Esc → 「処理を中止」。今のレイアウトと CMDECHO は実行前のまま（ver1 は CMDECHO が 0 のまま残った）。")
x, y = header(doc, 2, "0・1 以外の値", "5 などを入力 → 「入力値が不正です」。何も変わらない。")
for name in ("レイアウト2", "レイアウト3"):
    doc.layouts.new(name)
for lay in doc.layouts:
    if lay.name != "Model":
        lay.add_viewport(center=(140, 100), size=(250, 170), view_center_point=(200, -80), view_height=260)
finish(doc, OUT, 3)
