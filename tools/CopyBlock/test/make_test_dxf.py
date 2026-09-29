# CopyBlock 動作確認用 DXF を作るスクリプト（ezdxf 使用）。python make_test_dxf.py で同じフォルダに DXF を作る
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

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "CopyBlock_test.dxf")
doc = new_doc()
msp = doc.modelspace()
doc.layers.add("家具", color=3)
b = doc.blocks.new("机")
b.add_lwpolyline([(0, 0), (20, 0), (20, 10), (0, 10)], close=True)
b.add_attdef("品番", (2, 3), dxfattribs={"height": 2.5})
doc.blocks.new("机_1").add_circle((0, 0), 3)   # 既にある名前（次は 机_2 になるはず）
b2 = doc.blocks.new("棚")
b2.add_lwpolyline([(0, 0), (30, 0), (30, 8), (0, 8)], close=True)
x, y = header(doc, 0, "属性付きブロックを複製", "CB → 机を選ぶ → Enter（初期値「机_2」。机_1 は既にあるため）→ 配置 → 新しいブロック「机_2」が同じ画層・回転・尺度で置かれ、属性「D-001」も引き継がれる。")
r = msp.add_blockref("机", (x + 40, y - 50), dxfattribs={"layer": "家具", "rotation": 15, "xscale": 1.5, "yscale": 1.5})
r.add_auto_attribs({"品番": "D-001"})
x, y = header(doc, 1, "名前を指定して複製", "CB → 棚を選ぶ → 「棚_新」と入力 → 配置 → 「棚_新」ができる。")
msp.add_blockref("棚", (x + 40, y - 50), dxfattribs={"layer": "家具", "color": 1})
x, y = header(doc, 2, "既にある名前を入力", "「机」と入力 →「ブロック名 '机' は既に存在します」。何も作られない。")
x, y = header(doc, 3, "ブロック以外を選ぶ／Esc", "線を選ぶ →「選択されたオブジェクトはブロックではありません」。選ぶときに Esc → エラーにならない。配置で Esc →「配置がキャンセルされました」。")
msp.add_line((x + 20, y - 45), (x + 110, y - 45))
finish(doc, OUT, 4)
