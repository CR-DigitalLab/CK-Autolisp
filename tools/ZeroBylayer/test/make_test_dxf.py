# ZeroBylayer 動作確認用 DXF を作るスクリプト（ezdxf 使用）。python make_test_dxf.py で同じフォルダに DXF を作る
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

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "ZeroByLayer_test.dxf")
doc = new_doc()
msp = doc.modelspace()
doc.layers.add("壁", color=1)
doc.linetypes.add("DASHED2", pattern=[10, 6, -4], description="破線")
doc.header["$CLAYER"] = "壁"
doc.header["$CECOLOR"] = 5
doc.header["$CELTYPE"] = "DASHED2"
doc.header["$CELWEIGHT"] = 30
x, y = header(doc, 0, "作成プロパティのリセット", "開いた時点で現在の画層は「壁」・色は青・線種は DASHED2・線の太さ 0.30。ZB → 画層 0・色/線種/線の太さ/透過性が ByLayer に。")
msp.add_line((x + 10, y - 40), (x + 120, y - 40), dxfattribs={"layer": "壁"})
x, y = header(doc, 1, "CMDECHO を 0 にしている場合", "CMDECHO を 0 にしてから ZB → 終わったあとも CMDECHO は 0 のまま（ver1 は 1 に変わった）。")
x, y = header(doc, 2, "U（元に戻す）", "ZB のあと U を1回 → 画層・色などが実行前に戻る。")
finish(doc, OUT, 3)
