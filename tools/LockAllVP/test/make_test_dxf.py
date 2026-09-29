# LockAllVP 動作確認用 DXF を作るスクリプト（ezdxf 使用）。python make_test_dxf.py で同じフォルダに DXF を作る
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

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "LockAllVP_test.dxf")
doc = new_doc()
msp = doc.modelspace()
doc.layers.add("VP", color=7)
doc.layers.add("VP_ロック", color=1)
x, y = header(doc, 0, "全レイアウトのビューポートをロック", "モデルで LOCKALLVP →「すべてのビューポートをロックしました。（4 個）」と「1 個は変更できませんでした」。終わったらモデルに戻っている。")
msp.add_circle((x + 65, y - 45), 20)
x, y = header(doc, 1, "レイアウト2 から実行", "レイアウト2 のタブで実行 → 終わったらレイアウト2 に戻っている（ver1 は最後のレイアウトのまま）。")
x, y = header(doc, 2, "U（元に戻す）", "実行後に U を1回 → すべてのビューポートのロックが外れる。")
lays = []
for name in ("レイアウト2", "レイアウト3"):
    doc.layouts.new(name)
for lay in doc.layouts:
    if lay.name == "Model":
        continue
    vp = lay.add_viewport(center=(90, 100), size=(150, 120), view_center_point=(200, -80), view_height=260, dxfattribs={"layer": "VP"})
    lays.append(lay)
# レイアウト3 に2つ目、Layout1 にロック画層のビューポート
lays[-1].add_viewport(center=(230, 100), size=(80, 80), view_center_point=(65, -45), view_height=60, dxfattribs={"layer": "VP"})
lays[0].add_viewport(center=(230, 100), size=(80, 80), view_center_point=(65, -45), view_height=60, dxfattribs={"layer": "VP_ロック"})
doc.layers.get("VP_ロック").lock()
finish(doc, OUT, 3)
