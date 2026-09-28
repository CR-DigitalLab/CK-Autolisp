# ProjectSet 動作確認用の図面セットを作るスクリプト（ezdxf 使用）
# 使い方: python make_test_dxf.py  → 同じフォルダの「図面セット」に 5 つの DXF を作る
import os
import ezdxf

OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "図面セット")

DRAWINGS = [
    ("01_平面図", "いつもどおり開く図面", "PJ で記録され、PJ の［開く］で開き直される。最後に前面になる（記録のとき前面にしておく）。"),
    ("02_立面図", "変更して保存しない図面", "保存していなくても記録される（図面そのものは保存されない）。"),
    ("03_配置図", "先に開いておく図面", "［開く］の前に開いておくと、二重には開かれず「※すでに開いています」と表示される。"),
    ("04_詳細図", "あとで名前を変える図面", "記録のあと名前を変えると、一覧で「※見つかりません」と表示され、開くときは飛ばされる。"),
    ("05_断面図", "ほかの人が使用中の図面", "別の AutoCAD で開いたまま［開く］と、読み取り専用で開かれ、その旨が表示される。"),
]

os.makedirs(OUT, exist_ok=True)
for name, role, expect in DRAWINGS:
    doc = ezdxf.new("R2018", setup=True)
    doc.header["$INSUNITS"] = 4
    doc.styles.add("PJ_JP", font="msgothic.ttc")
    lay = doc.layers.add("PJ_見出し", color=8)
    lay.lock()
    doc.layers.add("PJ_作図", color=4)
    msp = doc.modelspace()
    msp.add_lwpolyline([(0, 0), (297, 0), (297, 210), (0, 210)], close=True, dxfattribs={"layer": "PJ_見出し"})
    msp.add_text(name, height=20, dxfattribs={"layer": "PJ_見出し", "style": "PJ_JP"}).set_placement((20, 160))
    msp.add_text("役割：" + role, height=8, dxfattribs={"layer": "PJ_見出し", "style": "PJ_JP"}).set_placement((20, 130))
    m = msp.add_mtext("期待：" + expect, dxfattribs={"layer": "PJ_見出し", "style": "PJ_JP", "char_height": 6})
    m.dxf.insert = (20, 110)
    m.dxf.width = 250
    # 変更の確認用に、動かしてよい図形を1つ置く
    msp.add_circle((240, 40), 15, dxfattribs={"layer": "PJ_作図"})
    doc.set_modelspace_vport(height=230, center=(148.5, 105))
    doc.saveas(os.path.join(OUT, name + ".dxf"))
    print("saved:", name)
