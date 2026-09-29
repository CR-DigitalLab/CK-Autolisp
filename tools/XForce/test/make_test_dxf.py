# XForce 動作確認用 DXF を作るスクリプト（ezdxf 使用）。python make_test_dxf.py で同じフォルダに DXF を作る
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

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "XForce_test.dxf")
doc = new_doc()
msp = doc.modelspace()
doc.layers.add("ブロック", color=3)
doc.layers.add("ロック", color=1).lock()

def blk(name, explodable=True):
    b = doc.blocks.new(name)
    b.add_lwpolyline([(0, 0), (20, 0), (20, 12), (0, 12)], close=True)
    b.add_line((0, 0), (20, 12))
    if not explodable:
        doc.block_records.get(name).dxf.explode = 0
    return b

blk("分解できないブロック", explodable=False)
blk("普通のブロック")
blk("ロック画層のブロック", explodable=False)
b = blk("属性付き_分解不可", explodable=False)
b.add_attdef("NO", (2, 2), dxfattribs={"height": 2.5})
b = doc.blocks.new("入れ子_外側")
b.add_circle((10, 6), 8)
b.add_blockref("分解できないブロック", (0, 0))
doc.block_records.get("入れ子_外側").dxf.explode = 0

x, y = header(doc, 0, "分解できないブロック", "XF → 選ぶ → 分解され、線とポリラインになり選択状態。「2 個の要素に分解・選択しました」。")
msp.add_blockref("分解できないブロック", (x + 50, y - 50), dxfattribs={"layer": "ブロック"})
x, y = header(doc, 1, "普通のブロック（分解できる）", "同じく分解される。")
msp.add_blockref("普通のブロック", (x + 50, y - 50), dxfattribs={"layer": "ブロック"})
x, y = header(doc, 2, "ロック画層のブロック", "分解されない。「ロックされた画層にあります（スキップ: 1 個）」。")
msp.add_blockref("ロック画層のブロック", (x + 50, y - 50), dxfattribs={"layer": "ロック"})
x, y = header(doc, 3, "属性付き・分解不可", "分解される（属性は属性定義の文字になる＝AutoCAD の分解と同じ）。")
r = msp.add_blockref("属性付き_分解不可", (x + 50, y - 50), dxfattribs={"layer": "ブロック"})
r.add_auto_attribs({"NO": "A-1"})
x, y = header(doc, 4, "入れ子（外側も内側も分解不可）", "外側だけ分解され、内側の「分解できないブロック」はブロックのまま残る。")
msp.add_blockref("入れ子_外側", (x + 50, y - 55), dxfattribs={"layer": "ブロック"})
x, y = header(doc, 5, "縦横の尺度が違うブロック", "分解される（または AutoCAD の分解の制限で分解されない場合は「分解できませんでした」でエラーにならない）。")
msp.add_blockref("普通のブロック", (x + 40, y - 55), dxfattribs={"layer": "ブロック", "xscale": 2, "yscale": 1})
finish(doc, OUT, 6)
