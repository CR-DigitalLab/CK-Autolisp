# RANDOMBNAME 動作確認用 DXF を作るスクリプト（ezdxf 使用）。python make_test_dxf.py で同じフォルダに DXF を作る
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

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "RANDOMBNAME_test.dxf")
doc = new_doc()
msp = doc.modelspace()
doc.layers.add("ブロック", color=3)
doc.layers.add("ロック", color=1).lock()

b = doc.blocks.new("机")
b.add_lwpolyline([(0, 0), (12, 0), (12, 6), (0, 6)], close=True)
b = doc.blocks.new("椅子")
b.add_circle((0, 0), 2.5)
b = doc.blocks.new("記号_属性付き")
b.add_circle((0, 0), 4)
b.add_attdef("NO", (-2, -1), dxfattribs={"height": 2.0})
b = doc.blocks.new("外側")
b.add_lwpolyline([(0, 0), (20, 0), (20, 12), (0, 12)], close=True)
b.add_blockref("椅子", (5, 6))
b = doc.blocks.new("ロック画層のブロック")
b.add_lwpolyline([(0, 0), (10, 0), (5, 8)], close=True)

x, y = header(doc, 0, "同じブロック3個＋別のブロック1個", "4個を選んで RBN → 定義名2つ（机・椅子）が A$C で始まるランダムな名前に変わり「完了: 2 個」。見た目は変わらない。")
for k in range(3):
    msp.add_blockref("机", (x + 10 + k * 25, y - 40), dxfattribs={"layer": "ブロック"})
msp.add_blockref("椅子", (x + 100, y - 37), dxfattribs={"layer": "ブロック"})

x, y = header(doc, 1, "回転・尺度違いのブロック", "定義名だけ変わり、回転・大きさはそのまま。")
msp.add_blockref("机", (x + 20, y - 45), dxfattribs={"layer": "ブロック", "rotation": 30})
msp.add_blockref("机", (x + 70, y - 50), dxfattribs={"layer": "ブロック", "xscale": 2, "yscale": 0.5})

x, y = header(doc, 2, "属性付きブロック", "定義名が変わり、属性の値（No.1・No.2）はそのまま。")
for k in range(2):
    r = msp.add_blockref("記号_属性付き", (x + 30 + k * 40, y - 45), dxfattribs={"layer": "ブロック"})
    r.add_auto_attribs({"NO": f"No.{k + 1}"})

x, y = header(doc, 3, "入れ子のブロック（外側だけを選ぶ）", "外側のブロックの定義名だけ変わる（中の「椅子」は選んでいないので変わらない。ただし区画01で椅子を選んだ場合は変わっている）。")
msp.add_blockref("外側", (x + 40, y - 50), dxfattribs={"layer": "ブロック"})

x, y = header(doc, 4, "ロック画層のブロック", "ロック画層のブロックは選べないため、何も変わらない（選択できない）。")
msp.add_blockref("ロック画層のブロック", (x + 50, y - 50), dxfattribs={"layer": "ロック"})

x, y = header(doc, 5, "何も選ばない／Esc", "RBN → 何も選ばず Enter で「ブロックが選択されませんでした。」。選択中に Esc でも、そのあと CMDECHO が実行前の値のまま（ver1 は 0 のまま残った）。")

finish(doc, OUT, 6)
