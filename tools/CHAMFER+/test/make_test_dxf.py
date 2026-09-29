# CHAMFER+ 動作確認用 DXF を作るスクリプト（ezdxf 使用）。python make_test_dxf.py で同じフォルダに DXF を作る
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

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "CHAMFER+_test.dxf")
doc = new_doc()
msp = doc.modelspace()
doc.layers.add("ロック", color=1).lock()
doc.header["$CHAMFERA"] = 0.0
doc.header["$CHAMFERB"] = 0.0
x, y = header(doc, 0, "直交する2本の線", "CF → 1本目・2本目を選ぶ → 面幅（斜めの長さ）が表示の値（最初は15）で面取りされる。")
msp.add_line((x + 20, y - 60), (x + 100, y - 60))
msp.add_line((x + 100, y - 60), (x + 100, y - 20))
x, y = header(doc, 1, "斜めに交わる2本の線", "面幅が指定どおりの面取り（斜め距離が同じ長さ）。")
msp.add_line((x + 15, y - 60), (x + 110, y - 60))
msp.add_line((x + 110, y - 60), (x + 70, y - 20))
x, y = header(doc, 2, "ポリラインの角", "ポリラインの角も面取りできる。")
msp.add_lwpolyline([(x + 20, y - 20), (x + 20, y - 60), (x + 110, y - 60)])
x, y = header(doc, 3, "面幅を変える（F）", "CF → F → 20 → 以後の面取りが面幅20に。次回も20が残る。")
msp.add_line((x + 20, y - 60), (x + 100, y - 60))
msp.add_line((x + 100, y - 60), (x + 100, y - 20))
x, y = header(doc, 4, "面取りの途中で Esc", "1本目を選んだあと Esc → 中止。U を1回で、それまでの面取りが1つずつ戻る（Undo グループが閉じている）。CMDECHO は実行前のまま。")
msp.add_line((x + 20, y - 60), (x + 100, y - 60))
msp.add_line((x + 100, y - 60), (x + 100, y - 20))
x, y = header(doc, 5, "ロック画層の線", "ロック画層の線は面取りできない（AutoCAD の面取りと同じメッセージ）。エラーで止まらない。")
msp.add_line((x + 20, y - 60), (x + 100, y - 60), dxfattribs={"layer": "ロック"})
msp.add_line((x + 100, y - 60), (x + 100, y - 20), dxfattribs={"layer": "ロック"})
finish(doc, OUT, 6)
