# SaveVersion 動作確認用の DXF を作るスクリプト（ezdxf 使用）
# 使い方: python make_test_dxf.py  → 同じフォルダの「図面セット」に DXF を作る
import os
import ezdxf

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "図面セット")
os.makedirs(OUT, exist_ok=True)

CASES = [
    # (ファイル名, ezdxf の版, 形式の名前, バイナリ)
    ("01_DXF_R12.dxf", "R12", "R12", False),
    ("02_DXF_2000.dxf", "R2000", "2000", False),
    ("03_DXF_2004.dxf", "R2004", "2004", False),
    ("04_DXF_2007.dxf", "R2007", "2007", False),
    ("05_DXF_2010.dxf", "R2010", "2010", False),
    ("06_DXF_2013.dxf", "R2013", "2013", False),
    ("07_DXF_2018.dxf", "R2018", "2018", False),
    ("08_バイナリDXF_2010.dxf", "R2010", "2010（バイナリ）", True),
]


def make(fname, ver, label, binary):
    doc = ezdxf.new(ver)
    if ver in ("R12", "R2000", "R2004"):
        doc.header["$DWGCODEPAGE"] = "ANSI_932"   # 日本語の文字を Shift-JIS で書く
    doc.header["$INSUNITS"] = 4
    msp = doc.modelspace()
    doc.layers.add("SV_見出し", color=8).lock()
    doc.layers.add("SV_図形", color=4)
    if binary:
        exp = "SV を実行すると「バイナリ形式のDXFには対応していません。保存していません。」と出て、ファイルは変わらない。"
    else:
        exp = f"四角を少し動かしてから SV を実行すると「{label}形式のDXFのまま上書き保存しました。」と出る。閉じて開き直すと四角が動いたまま。"
    msp.add_text(f"SaveVersion テスト：{label}形式のDXF", height=5, dxfattribs={"layer": "SV_見出し"}).set_placement((0, 40))
    msp.add_text("期待：" + exp[:60], height=2.5, dxfattribs={"layer": "SV_見出し"}).set_placement((0, 32))
    if len(exp) > 60:
        msp.add_text(exp[60:], height=2.5, dxfattribs={"layer": "SV_見出し"}).set_placement((0, 28))
    msp.add_lwpolyline([(0, 0), (40, 0), (40, 20), (0, 20)], close=True, dxfattribs={"layer": "SV_図形"}) \
        if ver != "R12" else msp.add_polyline2d([(0, 0), (40, 0), (40, 20), (0, 20)], close=True, dxfattribs={"layer": "SV_図形"})
    path = os.path.join(OUT, fname)
    if binary:
        doc.saveas(path, fmt="bin")
    else:
        doc.saveas(path)
    print("saved:", path)


for c in CASES:
    make(*c)

# 09 形式が書かれていない DXF（図形の部分だけ。$ACADVER が無い）
p = os.path.join(OUT, "09_形式不明のDXF.dxf")
with open(p, "w", encoding="ascii", newline="\r\n") as f:
    f.write("  0\nSECTION\n  2\nENTITIES\n  0\nLINE\n  8\n0\n 10\n0.0\n 20\n0.0\n 30\n0.0\n 11\n40.0\n 21\n20.0\n 31\n0.0\n  0\nENDSEC\n  0\nEOF\n")
print("saved:", p)
