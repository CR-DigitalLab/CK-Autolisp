# RegionToPL 動作確認用 DXF を作るスクリプト（ezdxf 使用）。python make_test_dxf.py で同じフォルダに DXF を作る
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

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "RegionToPL_test.dxf")
doc = new_doc()
msp = doc.modelspace()
doc.layers.add("リージョン化する図形", color=4)
L = {"layer": "リージョン化する図形"}
x, y = header(doc, 0, "まず REGION で各区画の図形をリージョンにする", "REGION → 区画02〜05の図形をすべて選ぶ →「4 個のリージョンが作成されました」。（リージョンはこの図面では作れないため）")
x, y = header(doc, 1, "四角", "RTP → 1本の閉じたポリラインになる。")
msp.add_lwpolyline([(x + 30, y - 25), (x + 100, y - 25), (x + 100, y - 60), (x + 30, y - 60)], close=True, dxfattribs=L)
x, y = header(doc, 2, "円", "閉じたポリライン（円弧2つ）になる。")
msp.add_circle((x + 65, y - 43), 18, dxfattribs=L)
x, y = header(doc, 3, "直線と円弧が混ざった形", "1本の閉じたポリラインになる（円弧の部分は円弧のまま）。")
msp.add_lwpolyline([(x + 30, y - 60, 0), (x + 100, y - 60, 1), (x + 100, y - 25, 0), (x + 30, y - 25, 0)], format="xyb", close=True, dxfattribs=L)
x, y = header(doc, 4, "スプラインを含む形（楕円）", "ポリラインになる（スプライン由来の部分は細かい線分になることがある）。")
msp.add_ellipse((x + 65, y - 43), major_axis=(30, 0), ratio=0.5, dxfattribs=L)
x, y = header(doc, 5, "まとめて／Esc・何も選ばない", "区画02〜05を一度に選んで RTP →「4 個のリージョンをポリラインに変換しました。」。何も選ばず Enter →「リージョンが選択されませんでした」。Esc でも PEDITACCEPT は実行前の値のまま。")
finish(doc, OUT, 6)
