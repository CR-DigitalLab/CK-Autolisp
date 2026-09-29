# -*- coding: utf-8 -*-
"""
ChikoLispCheck  ―  AutoLISP を公開する前に、チコさんのルールが守れているかを点検するツール

使い方
  ・このファイルをダブルクリック → 窓が開く →［ファイルを選ぶ］→［チェック］
  ・LSP ファイルをこのファイルの上にドラッグ＆ドロップしても開けます
  ・コマンドで使う場合：python ChikoLispCheck.py --cli ファイル.lsp [ファイル2.lsp ...]

判定
  ○ 合格   △ 要確認（機械では判断しきれない。目で確かめる）   × 不合格（直してから公開）

Python 3.8 以上。標準機能だけで動きます（追加のインストール不要）。
"""
import os
import re
import sys

VERSION = "1.0.2"

OK, WARN, NG = "○", "△", "×"

# ------------------------------------------------------------------
#  AutoCAD LT 2024 以降で使えないもの
# ------------------------------------------------------------------
LT_NG_FUNCS = {
    # 外部の部品（Excel など）との連携
    "VLAX-CREATE-OBJECT": "外部の部品（Excel など）との連携",
    "VLAX-GET-OR-CREATE-OBJECT": "外部の部品（Excel など）との連携",
    "VLAX-GET-OBJECT": "外部の部品（Excel など）との連携",
    "VLA-GETINTERFACEOBJECT": "外部の部品との連携",
    "VLAX-IMPORT-TYPE-LIBRARY": "外部の部品との連携",
    # VBA・ARX
    "VL-VBALOAD": "VBA", "VL-VBARUN": "VBA", "ARXLOAD": "ARX（追加プログラム）",
    # 3D ソリッドなど AutoCAD だけのもの
    "VLA-ADD3DSOLID": "3D ソリッド", "VLA-ADDBOX": "3D ソリッド", "VLA-ADDCONE": "3D ソリッド",
    "VLA-ADDCYLINDER": "3D ソリッド", "VLA-ADDSPHERE": "3D ソリッド", "VLA-ADDTORUS": "3D ソリッド",
    "VLA-ADDWEDGE": "3D ソリッド", "VLA-ADDELLIPTICALCONE": "3D ソリッド",
    "VLA-ADDELLIPTICALCYLINDER": "3D ソリッド", "VLA-ADDEXTRUDEDSOLID": "3D ソリッド",
    "VLA-ADDEXTRUDEDSOLIDALONGPATH": "3D ソリッド", "VLA-ADDREVOLVEDSOLID": "3D ソリッド",
    "VLA-ADDMLINE": "マルチライン", "VLA-ADDHELIX": "らせん",
}
LT_NG_PREFIX = {"ACET-": "Express Tools", "DOS_": "DOSLib（追加プログラム）"}
LT_NG_COMMANDS = {
    "EXTRUDE", "REVOLVE", "SWEEP", "LOFT", "UNION", "SUBTRACT", "INTERSECT", "BOX", "SPHERE",
    "CYLINDER", "CONE", "WEDGE", "TORUS", "PYRAMID", "PRESSPULL", "SLICE", "THICKEN", "INTERFERE",
    "SOLIDEDIT", "RENDER", "ACTRECORD", "ACTSTOP", "ACTUSERINPUT", "ACTUSERMESSAGE",
    "VBARUN", "VBALOAD", "VBAMAN", "ARX", "NETLOAD", "HELIX", "SURFBLEND", "SURFPATCH",
    "SECTIONPLANE", "FLATSHOT", "VIEWBASE", "MLINE", "MLEDIT", "MLSTYLE", "DATAEXTRACTION",
}

# ------------------------------------------------------------------
#  AutoCAD の標準コマンド名と、標準の短縮名（acad.pgp）
#  ショートカットがこれと同じだと、標準の動きが使えなくなる
# ------------------------------------------------------------------
STD_ALIASES = """
3A 3DO 3F 3P A AA AC ADC AL AP APPLOAD AR ARR ATE ATI ATT B BC BE BH BO BR BS BVS C CAM CBAR CH CHA CHK
CLI COL COLOUR CO CP CPARAM CT CUBE CYL D DAL DAN DAR DBA DBC DC DCE DCO DDA DDI DED DI DIV DJL DJO DL DLI
DO DOR DOV DR DRA DRE DRM DS DST DT DV DX DXATTACH E ED EL ER EX EXIT EXP EXT F FI FSHOT G GD GEO GR H HE
HI I IAD IAT ICL ID IM IMP IN INF IO J JOG L LA LAS LE LEN LESS LI LINEWEIGHT LO LS LT LTS LTYPE LW M MA
MAT ME MEA MI ML MLA MLC MLD MLE MLS MO MS MSM MT MV NE NORTHDIR NSHOT NVIEW O OFFSETSRF OP ORBIT OS P PA
PAR PARAM PATCH PC PCATTACH PE PL PO POFF POL PON PR PRE PRINT PS PSOLID PTW PU PYR QC QCUI QP QSAVE QVD
QVDC QVL QVLC R RA RC RE REA REC REG REN REV RO RP RPR RR RW S SC SCR SE SEC SET SHA SL SN SO SP SPE SPL
SPLANE SSM ST STA STANDARDS SU T TA TB TEDIT TH THI TI TO TOL TOR TP TR TS UC UN UNHIDE UNI V VGO VP VPLAYER
VS VSM VSS W WE WHEEL X XA XB XC XL XR Z ZEBRA ZIP
"""
STD_COMMANDS = """
ALIGN ARC AREA ARRAY ATTDEF ATTEDIT ATTSYNC AUDIT BASE BEDIT BLOCK BOUNDARY BREAK CAL CHAMFER CHANGE
CHPROP CIRCLE CLOSE COLOR COPY COPYBASE COPYCLIP COUNT CUTCLIP DDEDIT DIM DIMALIGNED DIMANGULAR DIMBASELINE
DIMBREAK DIMCONTINUE DIMEDIT DIMLINEAR DIMRADIUS DIMSPACE DIMSTYLE DIST DIVIDE DONUT DRAWORDER DTEXT ELLIPSE
ERASE EXPLODE EXPORT EXTEND FIELD FILLET FILTER FIND GROUP HATCH HATCHEDIT HELP ID IMAGE IMPORT INSERT JOIN
LAYER LAYOUT LEADER LENGTHEN LIMITS LINE LINETYPE LIST LTSCALE MATCHPROP MEASURE MIRROR MLEADER MOVE MSPACE
MTEXT MVIEW NEW OFFSET OOPS OPEN OPTIONS OSNAP OVERKILL PAN PASTE PASTECLIP PEDIT PLINE PLOT POINT POLYGON
PROPERTIES PSPACE PUBLISH PURGE QDIM QLEADER QSAVE QSELECT QUIT RAY RECOVER RECTANG REDO REDRAW REGEN REGION
RENAME REVCLOUD ROTATE SAVE SAVEAS SCALE SCRIPT SELECT SETVAR SKETCH SNAP SOLID SPELL SPLINE STRETCH STYLE
TABLE TEXT TIME TRIM U UCS UNDO UNITS VIEW VPORTS WBLOCK WIPEOUT XATTACH XCLIP XLINE XREF ZOOM
"""
STD_NAMES = set(STD_ALIASES.split()) | set(STD_COMMANDS.split())

# 図面を変えないコマンド（Undo グループが無くてもよい）
NON_MODIFY_COMMANDS = {"UNDO", "REDRAW", "REGEN", "REGENALL", "ZOOM", "PAN", "SAVE", "QSAVE", "SAVEAS", "VIEW",
                       "LIST", "DIST", "ID", "AREA", "DELAY", "TEXTSCR", "GRAPHSCR", "PLOT", "-PLOT", "OPEN", "CLOSE",
                       "BROWSER", "SETVAR", "LOGFILEON", "LOGFILEOFF", "HELP", "SHELL", "START", "REDRAWALL",
                       "APPLOAD", "NETLOAD", "EXPORT", "PUBLISH", "PNGOUT", "JPGOUT", "PDFOUT"}
# 一時的に変えることが多いシステム変数（変えたら必ず元に戻すべきもの）
TEMP_SYSVARS = {"CMDECHO", "OSMODE", "QAFLAGS", "NOMUTT", "EXPERT", "FILEDIA", "CMDDIA", "ATTREQ", "ATTDIA",
                "PICKADD", "PICKFIRST", "PICKSTYLE", "HIGHLIGHT", "ORTHOMODE", "SNAPMODE", "AUTOSNAP", "PEDITACCEPT",
                "DELOBJ", "UCSFOLLOW", "LOGFILEMODE", "LOGFILEPATH", "CTAB", "TILEMODE", "CLAYER_TEMP", "DIMZIN",
                "PLINEWID", "TEXTEVAL", "REGENMODE", "MIRRTEXT", "BLIPMODE", "OSNAPCOORD", "3DOSMODE", "SELECTIONPREVIEW"}
# 点を指定するコマンド（スナップの影響を受ける）
POINT_COMMANDS = {"LINE", "PLINE", "CIRCLE", "ARC", "MOVE", "COPY", "ROTATE", "SCALE", "INSERT", "-INSERT", "TEXT",
                  "MTEXT", "RECTANG", "STRETCH", "MIRROR", "BREAK", "TRIM", "EXTEND", "FILLET", "CHAMFER", "POINT",
                  "DIMLINEAR", "DIMALIGNED", "DIMCONTINUE", "DIMBASELINE", "XLINE", "RAY", "SPLINE", "ELLIPSE",
                  "DONUT", "POLYGON", "LEADER", "QLEADER", "MLEADER", "HATCH", "-HATCH", "BOUNDARY", "-BOUNDARY"}
# 図面を変える関数
MODIFY_FUNCS = {"ENTMOD", "ENTMAKE", "ENTMAKEX", "ENTDEL", "VLAX-PUT", "VLAX-PUT-PROPERTY", "VLA-DELETE",
                "VLA-MOVE", "VLA-COPY", "VLA-ROTATE", "VLA-SCALEENTITY", "VLA-MIRROR", "VLA-OFFSET", "VLA-EXPLODE",
                "VLA-INSERTBLOCK", "VLA-UPDATE", "VLAX-INVOKE"}
USER_PATH_OK = {"USER", "USERNAME", "PUBLIC", "DEFAULT", "ALL USERS", "%USERNAME%", "YOURNAME", "NAME", "ユーザー名"}


# ------------------------------------------------------------------
#  LISP の読み取り
# ------------------------------------------------------------------
class Sym(str):
    line = 0


class Str(str):
    line = 0


class Node(list):
    line = 0


def read_file(path):
    raw = open(path, "rb").read()
    enc = "ascii"
    if raw.startswith(b"\xef\xbb\xbf"):
        enc = "utf-8-bom"
    else:
        try:
            raw.decode("ascii")
        except UnicodeDecodeError:
            try:
                raw.decode("utf-8")
                enc = "utf-8"
            except UnicodeDecodeError:
                enc = "cp932"
    if enc in ("utf-8", "utf-8-bom"):
        text = raw.decode("utf-8-sig")
    else:
        text = raw.decode("cp932", errors="replace")
    return text, enc


def tokenize(text):
    """(種類, 値, 行) の並び。コメントも別に集める"""
    toks, comments = [], []
    i, n, line = 0, len(text), 1
    while i < n:
        c = text[i]
        if c == "\n":
            line += 1
            i += 1
        elif c in " \t\r\f":
            i += 1
        elif c == ";":
            if text.startswith(";|", i):
                j = text.find("|;", i + 2)
                j = n if j < 0 else j + 2
                comments.append((line, text[i:j]))
                line += text.count("\n", i, j)
                i = j
            else:
                j = text.find("\n", i)
                j = n if j < 0 else j
                comments.append((line, text[i:j]))
                i = j
        elif c == '"':
            j, buf = i + 1, []
            while j < n and text[j] != '"':
                if text[j] == "\\" and j + 1 < n:
                    buf.append(text[j:j + 2])
                    j += 2
                    continue
                if text[j] == "\n":
                    line += 1
                buf.append(text[j])
                j += 1
            s = "".join(buf)
            s = s.replace("\\\\", "\x00").replace('\\"', '"').replace("\\n", "\n").replace("\\t", "\t").replace("\x00", "\\")
            toks.append(("str", s, line))
            i = j + 1
        elif c in "()'":
            toks.append((c, c, line))
            i += 1
        else:
            j = i
            while j < n and text[j] not in " \t\r\n\f()';\"":
                j += 1
            toks.append(("atom", text[i:j], line))
            i = j
    return toks, comments


def parse(toks):
    pos = 0
    top = []

    def form():
        nonlocal pos
        kind, val, line = toks[pos]
        pos += 1
        if kind == "(":
            nd = Node()
            nd.line = line
            while pos < len(toks) and toks[pos][0] != ")":
                nd.append(form())
            pos += 1
            return nd
        if kind == "'":
            nd = Node()
            nd.line = line
            q = Sym("QUOTE")
            q.line = line
            nd.append(q)
            if pos < len(toks):
                nd.append(form())
            return nd
        if kind == ")":
            return None
        if kind == "str":
            s = Str(val)
            s.line = line
            return s
        s = Sym(val.upper())
        s.line = line
        return s

    while pos < len(toks):
        f = form()
        if f is not None:
            top.append(f)
    return top


def head(nd):
    return nd[0] if isinstance(nd, Node) and nd and isinstance(nd[0], Sym) else None


def walk(nd):
    """nd の中のすべての Node（入れ子含む）"""
    if isinstance(nd, Node):
        yield nd
        for x in nd:
            yield from walk(x)


def atoms(nd):
    if isinstance(nd, Node):
        for x in nd:
            yield from atoms(x)
    else:
        yield nd


class Defun:
    def __init__(self, nd):
        self.node = nd
        self.name = nd[1] if len(nd) > 1 and isinstance(nd[1], Sym) else ""
        self.line = nd.line
        args, locs = [], []
        if len(nd) > 2 and isinstance(nd[2], Node):
            tgt = args
            for a in nd[2]:
                if a == "/":
                    tgt = locs
                elif isinstance(a, Sym):
                    tgt.append(a)
        self.args, self.locals = args, locs
        self.body = list(nd[3:])
        # 中で定義した *error*
        self.errfun = None
        for x in walk(Node(self.body)):
            if head(x) == "DEFUN" and len(x) > 1 and x[1] == "*ERROR*":
                self.errfun = x
                break

    @property
    def is_cmd(self):
        return self.name.startswith("C:")

    @property
    def cmd(self):
        return self.name[2:]

    def shortcut_target(self):
        """(defun c:SV () (c:SAVEVERSION)) なら SAVEVERSION。後ろに (princ) が付いていてもよい"""
        body = list(self.body)
        if len(body) == 2 and head(body[1]) in ("PRINC", "PRIN1") and len(body[1]) == 1:
            body = body[:1]
        if self.is_cmd and len(body) == 1 and isinstance(body[0], Node) and len(body[0]) == 1:
            h = head(body[0])
            if h and h.startswith("C:"):
                return h[2:]
        return None


# ------------------------------------------------------------------
#  チェック本体
# ------------------------------------------------------------------
class Result:
    def __init__(self, path):
        self.path = path
        self.items = []          # (印, 番号, 項目名, 説明)
        self.info = {}

    def add(self, mark, code, title, msg=""):
        self.items.append((mark, code, title, msg))

    @property
    def verdict(self):
        marks = [m for m, *_ in self.items]
        if NG in marks:
            return "直してから"
        if WARN in marks:
            return "確認してから"
        return "公開OK"

    def counts(self):
        marks = [m for m, *_ in self.items]
        return marks.count(OK), marks.count(WARN), marks.count(NG)


def lines_of(nodes, limit=5):
    ls = sorted({getattr(n, "line", 0) for n in nodes if getattr(n, "line", 0)})
    s = "・".join(str(x) for x in ls[:limit])
    if len(ls) > limit:
        s += " ほか"
    return (s + "行目") if s else ""


def cmd_name_of(call):
    """(command "_.LINE" ...) のコマンド名（大文字、印なし）。文字で書かれていなければ None"""
    if len(call) < 2 or not isinstance(call[1], Str):
        return None, None
    raw = str(call[1])
    return raw, raw.lstrip("_.").upper().lstrip("_.")


def check_file(path):
    R = Result(path)
    text, enc = read_file(path)
    toks, comments = tokenize(text)
    top = parse(toks)
    defs = [Defun(x) for x in top if head(x) == "DEFUN" and len(x) > 2]
    nested = [Defun(x) for d in defs for x in walk(Node(d.body)) if head(x) == "DEFUN" and len(x) > 2]
    byname = {d.name: d for d in defs}
    all_nodes = [x for t in top for x in walk(t)]
    all_strs = [a for t in top for a in atoms(t) if isinstance(a, Str)]

    cmds = [d for d in defs if d.is_cmd]
    shortcuts = {d.cmd: d.shortcut_target() for d in cmds if d.shortcut_target()}
    mains = [d for d in cmds if not d.shortcut_target()]

    # 関数ごとの「呼んでいるユーザー関数」をたどって、コマンドごとの中身を集める
    def calls(nodes):
        out = set()
        for n in nodes:
            for x in walk(n):
                h = head(x)
                if h and h in byname:
                    out.add(h)
                for a in x:
                    if isinstance(a, Sym) and a in byname and a != h:
                        out.add(a)          # 'func の形で渡している場合
        return out

    def closure(nodes, skip_err=False):
        """nodes と、そこから呼ばれるユーザー関数の本体をすべて集める"""
        seen, stack, out = set(), list(calls(nodes)), list(nodes)
        while stack:
            f = stack.pop()
            if f in seen or f not in byname:
                continue
            seen.add(f)
            out.extend(byname[f].body)
            stack.extend(calls(byname[f].body))
        return out

    def body_without_err(d):
        return [x for x in d.body if not (head(x) == "DEFUN" and len(x) > 1 and x[1] == "*ERROR*")]

    def nodes_in(nodes):
        return [x for n in nodes for x in walk(n)]

    # ---------------- A1 LT 2024 ----------------
    bad = []
    for x in all_nodes:
        h = head(x)
        if not h:
            continue
        if h in LT_NG_FUNCS:
            bad.append((x, f"{h.lower()}（{LT_NG_FUNCS[h]}）"))
        for p, why in LT_NG_PREFIX.items():
            if h.startswith(p):
                bad.append((x, f"{h.lower()}（{why}）"))
        if h in ("COMMAND", "COMMAND-S", "VL-CMDF"):
            raw, nm = cmd_name_of(x)
            if nm and nm.lstrip("-") in LT_NG_COMMANDS:
                bad.append((x, f"コマンド {raw}"))
    if bad:
        R.add(NG, "A1", "AutoCAD LT 2024 以降で使えるか",
              "LT で使えないものがあります：" + "、".join(sorted({b for _, b in bad})) + "（" + lines_of([n for n, _ in bad]) +
              "）。LT でも使いたい場合は別の方法に置き換えてください。")
    else:
        R.add(OK, "A1", "AutoCAD LT 2024 以降で使えるか", "LT で使えない関数・コマンドは見つかりませんでした。")
    R.info["lt"] = not bad

    # ---------------- A2 環境に左右されないか ----------------
    cmd_calls = [x for x in all_nodes if head(x) in ("COMMAND", "COMMAND-S", "VL-CMDF")]
    no_us, opt_no_us = [], []
    for x in cmd_calls:
        raw, nm = cmd_name_of(x)
        if raw and "_" not in raw and raw.strip():
            no_us.append(x)
        for a in x[2:]:
            if isinstance(a, Str) and re.fullmatch(r"[A-Za-z]+", a) and a.upper() not in ("", ):
                opt_no_us.append(a)
    msgs = []
    if no_us:
        msgs.append("コマンド名に英語名の印「_」がありません（" + lines_of(no_us) + "）。例：\"LINE\" → \"_.LINE\"。英語版以外の AutoCAD でも動くように。")
    if opt_no_us:
        msgs.append("コマンドのオプションに「_」がありません：" + "、".join(sorted({str(a) for a in opt_no_us}))[:80] +
                    "（" + lines_of(opt_no_us) + "）。例：\"Y\" → \"_Y\"。")
    # スナップ
    snap_risk = []
    for d in mains:
        cl = nodes_in(closure(body_without_err(d)))
        pcmds = [x for x in cl if head(x) in ("COMMAND", "COMMAND-S", "VL-CMDF") and (cmd_name_of(x)[1] or "") in POINT_COMMANDS]
        if pcmds:
            strs = {str(a).upper() for x in cl for a in atoms(x) if isinstance(a, Str)}
            if "OSMODE" not in strs and not ({"_NON", "_NONE", "NON", "NONE"} & strs):
                snap_risk += pcmds
    if snap_risk:
        msgs.append("点を指定するコマンドで、スナップ（OSMODE）の影響を受ける可能性があります（" + lines_of(snap_risk) +
                    "）。点の前に \"_non\" を入れるか、OSMODE を一時的に 0 にしてください。")
    paths = [a for a in all_strs if re.match(r"^([A-Za-z]:[\\/]|\\\\)", a)]
    if paths:
        msgs.append("決め打ちのフォルダの場所があります（" + lines_of(paths) + "）。ほかの人のパソコンには無いかもしれません。")
    sendcmd = [x for x in all_nodes if head(x) == "VLA-SENDCOMMAND"]
    if sendcmd:
        msgs.append("vla-SendCommand は後から実行されるため、順番がずれることがあります（" + lines_of(sendcmd) + "）。")
    if msgs:
        R.add(WARN, "A2", "環境に左右されないか", " ／ ".join(msgs))
    else:
        R.add(OK, "A2", "環境に左右されないか", "コマンドの書き方・スナップ・フォルダの場所に問題は見つかりませんでした。")

    # ---------------- B1 文字コード ----------------
    has_jp = any(ord(ch) > 127 for ch in text)
    utf_open = [x for x in all_nodes if head(x) == "OPEN" and len(x) > 3 and isinstance(x[3], Str) and "UTF" in x[3].upper()]
    if enc == "utf-8-bom" or (enc == "utf-8" and has_jp):
        R.add(NG, "B1", "文字コードが ANSI か",
              "UTF-8 で保存されています。AutoCAD のバージョンによって日本語が化けます。ANSI（Shift-JIS）で保存し直してください。")
    elif utf_open:
        R.add(NG, "B1", "文字コードが ANSI か",
              "ファイルを UTF-8 で書き出しています（" + lines_of(utf_open) + "）。ダイアログの定義などは ANSI で書き出してください（open にエンコードを指定しない）。")
    else:
        R.add(OK, "B1", "文字コードが ANSI か", "ANSI（Shift-JIS）です。" if has_jp else "日本語を含まないため問題ありません。")
    R.info["enc"] = enc

    # ---------------- B2 先頭の説明 ----------------
    first_code = top[0].line if top else 10 ** 9
    header = [c for ln, c in comments if ln < first_code]
    htxt = "\n".join(header)
    R.info["header"] = header
    miss = []
    if not re.search(r"\d+\.\d+", htxt) and not any(re.fullmatch(r"\d+\.\d+(\.\d+)?", str(s)) for s in all_strs):
        miss.append("バージョン")
    if len([h for h in header if re.sub(r"[;=\-\s]", "", h)]) < 2:
        miss.append("名前・使い方の説明")
    if miss:
        R.add(WARN, "B2", "ファイルの先頭の説明", "先頭のコメントに " + "・".join(miss) + " が見当たりません。")
    else:
        R.add(OK, "B2", "ファイルの先頭の説明", "名前・バージョン・説明があります。")

    # ---------------- B3 読み込んだときのメッセージ ----------------
    top_msgs = [a for t in top if head(t) in ("PRINC", "PROMPT", "PRINT", "PRIN1") or (head(t) not in ("DEFUN",) and head(t))
                for a in atoms(t) if isinstance(a, Str)]
    names = {d.cmd.upper() for d in cmds}
    shown = [n for n in names if any(n in s.upper() for s in top_msgs)]
    if not cmds:
        R.add(WARN, "B3", "読み込んだときのメッセージ", "コマンド（c: で始まる関数）が見つかりません。")
    elif shown:
        R.add(OK, "B3", "読み込んだときのメッセージ", "読み込み時にコマンド名を表示しています。")
    else:
        R.add(WARN, "B3", "読み込んだときのメッセージ", "読み込んだときに、コマンド名（とショートカット）を表示していません。")

    # ---------------- C1 ショートカット ----------------
    pairs = []
    nosc = []
    for d in mains:
        scs = [k for k, v in shortcuts.items() if v == d.cmd]
        pairs.append((d.cmd, scs))
        if not scs and len(d.cmd) > 3:
            nosc.append(d.cmd)
    R.info["pairs"] = pairs
    if not mains:
        pass
    elif nosc:
        R.add(NG, "C1", "ショートカットがあるか", "ショートカットがありません：" + "、".join(nosc) + "。短く覚えやすい別名を作ってください。")
    else:
        R.add(OK, "C1", "ショートカットがあるか", "、".join(f"{m}（{'・'.join(s) or '短い名前'}）" for m, s in pairs))

    # ---------------- C2 標準と重なっていないか ----------------
    clash = sorted({d.cmd for d in cmds if d.cmd in STD_NAMES})
    if clash:
        R.add(NG, "C2", "AutoCAD 標準と重なっていないか",
              "標準のコマンド名・短縮名と同じ名前があります：" + "、".join(clash) + "。標準の動きが使えなくなるので、別の名前にしてください。")
    elif cmds:
        R.add(OK, "C2", "AutoCAD 標準と重なっていないか", "標準のコマンド名・短縮名とは重なっていません（主な標準のもので確認）。")

    # ---------------- C3 結果の通知 / C4 静かに終わる ----------------
    nomsg, noquiet = [], []
    for d in mains:
        cl = nodes_in(closure(body_without_err(d)))
        # 結果の通知：件数（itoa・rtos）や「〜しました」「〜個」などの結果を表示しているか
        def is_result(x):
            if head(x) not in ("PRINC", "PROMPT", "ALERT"):
                return False
            if any(head(y) in ("ITOA", "RTOS") for y in walk(x)):
                return True
            return any(isinstance(a, Str) and re.search(r"しました|完了|終了|件|個|本|枚|箇所|か所", a) for a in atoms(x))
        if not any(is_result(x) for x in cl):
            nomsg.append(d.cmd)
        last = d.body[-1] if d.body else None
        if not (head(last) in ("PRINC", "PRIN1") and len(last) == 1):
            noquiet.append(d)
    if mains:
        if nomsg:
            R.add(WARN, "C3", "結果の通知", "処理の結果（件数や「〜しました」）を表示していないように見えるコマンド：" + "、".join(nomsg) + "。処理した件数などを表示してください。")
        else:
            R.add(OK, "C3", "結果の通知", "各コマンドで結果を表示しています。")
        if noquiet:
            R.add(WARN, "C4", "静かに終わる（最後が (princ)）",
                  "最後が (princ) でないコマンド：" + "、".join(d.cmd for d in noquiet) +
                  "（" + lines_of([d.node for d in noquiet]) + "）。最後の値がコマンドラインに「nil」などと出ることがあります。")
        else:
            R.add(OK, "C4", "静かに終わる（最後が (princ)）", "すべてのコマンドが (princ) で終わっています。")

    # ---------------- D 安全性 ----------------
    global_err = [d for d in defs if d.name == "*ERROR*"]
    sysvars_all, modifies_any, undo_ok_all = set(), False, True
    d1, d2, d3, d4 = [], [], [], []
    for d in mains:
        main_nodes = nodes_in(closure(body_without_err(d)))
        err_nodes = nodes_in(closure(list(d.errfun[3:]))) if d.errfun is not None else []
        # 変えるシステム変数
        setvars, unknown_sv = set(), []
        for x in main_nodes:
            h = head(x)
            if h == "SETVAR" and len(x) > 1:
                (setvars.add(x[1].upper()) if isinstance(x[1], Str) else unknown_sv.append(x))
            if h == "VLA-SETVARIABLE" and len(x) > 2:
                (setvars.add(x[2].upper()) if isinstance(x[2], Str) else unknown_sv.append(x))
        # 図面を変えるか
        modifies = any(head(x) in MODIFY_FUNCS or (head(x) or "").startswith("VLA-PUT-") or
                       (head(x) or "").startswith("VLA-ADD") for x in main_nodes)
        for x in main_nodes:
            if head(x) in ("COMMAND", "COMMAND-S", "VL-CMDF"):
                nm = cmd_name_of(x)[1]
                if nm is None or nm.lstrip("-") not in NON_MODIFY_COMMANDS:
                    modifies = True
        modifies_any = modifies_any or modifies
        sysvars_all |= setvars
        # D1 *error*
        if d.errfun is None:
            if modifies or setvars or unknown_sv:
                d1.append((NG, d.cmd + "：*error* がありません"))
            # 図面もシステム変数も変えないコマンドは、*error* が無くても困らない
        else:
            if "*ERROR*" not in d.locals:
                keeps_old = any(head(x) == "SETQ" and any(a == "*ERROR*" for a in x[1:]) for x in main_nodes)
                if keeps_old:
                    d1.append((WARN, d.cmd + "：元の *error* を覚えて戻す古い書き方です。動きますが、*error* をローカル変数にする方が確実です"))
                else:
                    d1.append((NG, d.cmd + "：*error* をローカル変数に入れていません（ほかの LISP の *error* を上書きしたままになります）"))
            bad_cmd = [x for x in err_nodes if head(x) in ("COMMAND", "VL-CMDF")]
            if bad_cmd:
                d1.append((WARN, d.cmd + "：*error* の中で command を使っています（" + lines_of(bad_cmd) + "）。command-s にしてください"))
        # D2 システム変数
        if setvars or unknown_sv:
            got = {x[1].upper() for x in main_nodes if head(x) == "GETVAR" and len(x) > 1 and isinstance(x[1], Str)}
            got |= {x[2].upper() for x in main_nodes if head(x) == "VLA-GETVARIABLE" and len(x) > 2 and isinstance(x[2], Str)}
            quoted = {str(a).upper() for x in main_nodes if head(x) == "QUOTE" for a in atoms(x) if isinstance(a, Str)}
            err_restore = any(head(x) in ("SETVAR", "VLA-SETVARIABLE") for x in err_nodes) or \
                any(isinstance(a, Sym) and a == "SETVAR" for x in err_nodes for a in x)
            saved = {v for v in setvars if v in got or v in quoted}
            temp = sorted(v for v in setvars if v in saved or v in TEMP_SYSVARS)      # 一時的に変えているもの
            purpose = sorted(v for v in setvars if v not in temp)                     # 変えること自体が目的らしいもの
            if temp and (d.errfun is None or not err_restore):
                d2.append((NG, d.cmd + "：一時的に変えているシステム変数（" + "・".join(temp) + "）を、エラーのときに元に戻す処理が見当たりません"))
            elif temp:
                notsaved = sorted(v for v in temp if v not in saved)
                if notsaved:
                    d2.append((WARN, d.cmd + "：変える前の値を覚えずに戻しているように見えます：" + "・".join(notsaved) + "（元の値ではなく決まった値に戻すと、使う人の設定が変わります）"))
            if purpose:
                d2.append((WARN, d.cmd + "：システム変数（" + "・".join(purpose) + "）を変えています。コマンドの目的として変える設定なら問題ありません。一時的に変えているなら元に戻してください"))
            if unknown_sv:
                d2.append((WARN, d.cmd + "：名前を変数で指定しているシステム変数があります（" + lines_of(unknown_sv) + "）。元に戻しているか目で確認してください"))
        # D3 Undo
        def undo_cmd(nodes, words):
            for x in nodes:
                if head(x) in ("COMMAND", "COMMAND-S", "VL-CMDF") and (cmd_name_of(x)[1] or "") == "UNDO":
                    if any(isinstance(a, Str) and a.upper().lstrip("_") in words for a in x[2:]):
                        return True
            return False
        u_start = any(head(x) == "VLA-STARTUNDOMARK" for x in main_nodes) or undo_cmd(main_nodes, ("BE", "BEGIN"))
        u_end = any(head(x) == "VLA-ENDUNDOMARK" for x in main_nodes) or undo_cmd(main_nodes, ("E", "END"))
        u_end_err = any(head(x) == "VLA-ENDUNDOMARK" for x in err_nodes) or undo_cmd(err_nodes, ("E", "END"))
        if modifies:
            if not u_start:
                d3.append((NG, d.cmd + "：図面を変えていますが、Undo グループがありません"))
                undo_ok_all = False
            elif not u_end:
                d3.append((NG, d.cmd + "：Undo グループを閉じる処理が見当たりません"))
                undo_ok_all = False
            elif not u_end_err:
                d3.append((NG, d.cmd + "：エラーのときに Undo グループを閉じていません"))
                undo_ok_all = False
        # D4 Esc・選択なし
        getfuncs = ("SSGET", "ENTSEL", "NENTSEL", "GETPOINT", "GETCORNER", "GETDIST", "GETANGLE", "GETREAL",
                    "GETINT", "GETKWORD", "GETSTRING", "GETFILED")
        tested = set()
        for x in main_nodes:
            if head(x) in ("IF", "COND", "AND", "OR", "WHILE", "NOT", "NULL", "REPEAT", "=", "EQ", "EQUAL", "/=", "MEMBER", "WCMATCH"):
                for a in atoms(x):
                    if isinstance(a, Sym):
                        tested.add(a)
        risky = []
        for x in main_nodes:
            if head(x) == "SETQ":
                for i in range(1, len(x) - 1, 2):
                    v, e = x[i], x[i + 1]
                    if isinstance(e, Node) and head(e) in getfuncs and isinstance(v, Sym) and v not in tested:
                        risky.append(e)
            h = head(x)
            if h in ("SSLENGTH", "SSNAME", "CAR", "CADR", "ENTGET") and len(x) > 1 and head(x[1]) in ("SSGET", "ENTSEL", "NENTSEL"):
                risky.append(x)
        if risky:
            d4.append((WARN, d.cmd + "：入力・選択の結果を、空かどうか確かめずに使っているように見えます（" + lines_of(risky) + "）"))

    def put(code, title, lst, okmsg):
        if not lst:
            R.add(OK, code, title, okmsg)
        else:
            mark = NG if any(m == NG for m, _ in lst) else WARN
            R.add(mark, code, title, " ／ ".join(t for _, t in lst) + "。")

    if global_err:
        d1.insert(0, (NG, "*error* をファイル全体で定義しています（" + lines_of([g.node for g in global_err]) + "）。ほかの LISP の *error* を上書きしてしまいます"))
    if mains:
        put("D1", "エラー時の後始末（*error*）", d1, "各コマンドに *error* があり、ローカル変数にしています。")
        put("D2", "システム変数を元に戻すか", d2,
            "システム変数を変えていません。" if not sysvars_all else "変えたシステム変数（" + "・".join(sorted(sysvars_all)) + "）を元に戻す作りです。")
        put("D3", "Undo グループ", d3, "図面を変えるコマンドは Undo グループを正しく使っています。" if modifies_any else "図面を変える処理が見当たらないため対象外です。")
        put("D4", "Esc・選択なしで落ちないか", d4, "入力・選択の結果を確かめてから使っています。")
    R.info["sysvars"] = sorted(sysvars_all)
    R.info["modifies"] = modifies_any
    R.info["undo_ok"] = undo_ok_all and modifies_any

    # ---------------- D5 ほかの LISP とぶつからないか ----------------
    all_locals = {v for d in defs + nested for v in d.args + d.locals}
    leaks = {}
    for d in defs + nested:
        own = set(d.args + d.locals)
        for x in walk(Node(d.body)):
            if head(x) == "SETQ":
                for i in range(1, len(x), 2):
                    v = x[i]
                    if isinstance(v, Sym) and v not in own and v not in all_locals and not (v.startswith("*") and v.endswith("*")):
                        leaks.setdefault(v, x)
    plain = [d.name for d in defs if not d.is_cmd and d.name != "*ERROR*" and not re.search(r"[:\-_.]", d.name)]
    msgs = []
    if leaks:
        msgs.append("ローカル宣言されていない変数：" + "、".join(sorted(v.lower() for v in leaks))[:120] + "（" + lines_of(list(leaks.values())) +
                    "）。わざと残すなら *名前* の形にすると分かりやすいです")
    if plain:
        msgs.append("ほかの LISP と名前がぶつかりやすい関数：" + "、".join(p.lower() for p in plain)[:120] +
                    "。「ツール名:」のような印を頭に付けると安全です")
    if msgs:
        R.add(WARN, "D5", "ほかの LISP とぶつからないか", " ／ ".join(msgs) + "。")
    else:
        R.add(OK, "D5", "ほかの LISP とぶつからないか", "変数・関数の名前に問題は見つかりませんでした。")

    # ---------------- E1 個人情報・社内情報 ----------------
    found_ng, found_warn = [], []
    for i, ln in enumerate(text.splitlines(), 1):
        for m in re.finditer(r"[\w.+-]+@[\w-]+\.[\w.-]+", ln):
            found_ng.append((i, "メールアドレス " + m.group(0)))
        for m in re.finditer(r"(?i)(?:users|documents and settings)\\{1,2}([^\\\"/]+)", ln):
            if m.group(1).strip().upper() not in USER_PATH_OK and m.group(1).strip().upper().lstrip("%") != "USERNAME%":
                found_ng.append((i, "ユーザー名入りのフォルダ " + re.sub(r"\\+", r"\\", m.group(0))))
        for m in re.finditer(r"(?<![A-Za-z0-9])\\{2,4}[A-Za-z0-9_\-]+\\{1,2}", ln):
            found_warn.append((i, "ネットワークの場所 " + m.group(0)))
    if found_ng:
        R.add(NG, "E1", "個人情報・社内情報", "、".join(f"{s}（{i}行目）" for i, s in found_ng[:5]) + "。公開前に消すか、一般的な書き方に変えてください。")
    elif found_warn:
        R.add(WARN, "E1", "個人情報・社内情報", "、".join(f"{s}（{i}行目）" for i, s in found_warn[:5]) + "。社内のサーバー名なら消してください。")
    else:
        R.add(OK, "E1", "個人情報・社内情報", "メールアドレス・ユーザー名入りのフォルダ・ネットワークの場所は見つかりませんでした。")

    # ---------------- E2 試し書きの残り ----------------
    dbg = [(ln, c.strip()) for ln, c in comments if re.search(r"(?i)debug|デバッグ|TODO|FIXME|XXX|仮置き|あとで消す|テスト用", c)]
    dbg += [(s.line, s) for s in all_strs if re.search(r"(?i)^\s*(debug|デバッグ|test|テスト)\b", s)]
    called = set()
    for t in top:
        for x in walk(t):
            if head(x) == "DEFUN":
                continue
            for a in x:
                if isinstance(a, Sym):
                    called.add(a)
    # ダイアログのボタンなど、文字の中から呼んでいる関数も「使われている」とみなす
    in_strs = {w.upper() for st in all_strs for w in re.findall(r"[A-Za-z0-9_:\-*]+", st)}
    unused = [d.name.lower() for d in defs if not d.is_cmd and d.name != "*ERROR*" and d.name not in called
              and d.name not in in_strs]
    msgs = []
    if dbg:
        msgs.append("試し書きらしい所：" + "、".join(f"{ln}行目" for ln, _ in dbg[:5]))
    if unused:
        msgs.append("どこからも使われていない関数：" + "、".join(unused)[:120])
    if msgs:
        R.add(WARN, "E2", "試し書きの残り", " ／ ".join(msgs) + "。不要なら消してください。")
    else:
        R.add(OK, "E2", "試し書きの残り", "試し書き・使われていない関数は見つかりませんでした。")

    # ---------------- E3 作者・利用条件 ----------------
    has_author = re.search(r"(?i)作者|作成|制作|開発者|著作権|author|copyright|©|\(c\)", htxt)
    has_terms = re.search(r"(?i)利用条件|ライセンス|license|再配布|転載|免責|自己責任|商用", htxt)
    miss = ([] if has_author else ["作者"]) + ([] if has_terms else ["利用条件（再配布の可否・免責など）"])
    if miss:
        R.add(WARN, "E3", "作者・利用条件の表記", "ファイルの先頭に " + "・".join(miss) + " が見当たりません。配布するなら書いておくと安心です。")
    else:
        R.add(OK, "E3", "作者・利用条件の表記", "作者と利用条件が書いてあります。")

    R.info["title"] = os.path.splitext(os.path.basename(path))[0]
    return R


# ------------------------------------------------------------------
#  出力
# ------------------------------------------------------------------
def split_msg(msg):
    """「 ／ 」でつないだ説明を、1つずつの行に分ける"""
    parts = [p.strip() for p in msg.split(" ／ ") if p.strip()]
    return parts if len(parts) > 1 else [msg]


def report_text(results):
    out = [f"ChikoLispCheck {VERSION} チェック結果", ""]
    for R in results:
        ok, warn, ng = R.counts()
        out.append(f"■ {os.path.basename(R.path)}：{R.verdict}（{OK}{ok} {WARN}{warn} {NG}{ng}）")
        for mark in (NG, WARN, OK):
            for m, code, title, msg in R.items:
                if m == mark:
                    out.append(f"  {m} {code} {title}")
                    parts = split_msg(msg) if msg else []
                    for p in parts:
                        out.append(("      ・" if len(parts) > 1 else "      ") + p)
        out.append("")
    return "\n".join(out)


def article_text(R):
    """note などの記事に貼る紹介文のひな形"""
    L = [f"【{R.info.get('title', '')}】"]
    desc = []
    for h in R.info.get("header", []):
        s = re.sub(r"^[;\s|]+", "", h).strip()
        if s and not re.fullmatch(r"[=\-─_*]+", s):
            desc.append(s)
    if desc:
        L += ["", "■ 概要"] + ["・" + s for s in desc[:4]]
    pairs = R.info.get("pairs", [])
    if pairs:
        L += ["", "■ コマンド"]
        for m, scs in pairs:
            L.append(f"・{m}" + (f"（ショートカット：{'・'.join(scs)}）" if scs else ""))
    L += ["", "■ 動作環境", "・AutoCAD（AutoLISP が使えるもの）"]
    if R.info.get("lt"):
        L.append("・AutoCAD LT 2024 以降でも使えます（LT で使えない機能は使っていません）")
    else:
        L.append("・AutoCAD LT では使えません（LT で使えない機能を使っています）")
    L += ["", "■ 安心して使うために"]
    sv = R.info.get("sysvars", [])
    L.append("・システム変数は変更しません" if not sv else f"・一時的に変えるシステム変数（{'・'.join(sv)}）は、終了時・エラー時に元に戻します")
    if R.info.get("undo_ok"):
        L.append("・実行後、元に戻す（U）1回で実行前の状態に戻せます")
    L.append("・Esc で中止しても安全に終了します")
    if R.info.get("enc") in ("cp932", "ascii"):
        L.append("・文字コード：ANSI（Shift-JIS）。AutoCAD のバージョンによる日本語の文字化けがありません")
    L += ["", "■ 読み込み方", "・APPLOAD で読み込むか、スタートアップ登録に入れてください"]
    return "\n".join(L)


# ------------------------------------------------------------------
#  画面（GUI）
# ------------------------------------------------------------------
def run_gui(initial):
    import tkinter as tk
    from tkinter import ttk, filedialog, messagebox

    root = tk.Tk()
    root.title(f"ChikoLispCheck {VERSION}  ― LISP 公開前チェック")
    root.geometry("980x720")
    font = ("Yu Gothic UI", 10) if sys.platform.startswith("win") else ("TkDefaultFont", 10)
    big = (font[0], 13, "bold")
    files = list(initial)
    results = []

    top = tk.Frame(root, padx=10, pady=8)
    top.pack(fill="x")
    tk.Button(top, text="ファイルを選ぶ", font=font, width=14, command=lambda: pick()).pack(side="left")
    tk.Button(top, text="チェック", font=big, width=10, bg="#2f6fdf", fg="white", command=lambda: run()).pack(side="left", padx=8)
    tk.Button(top, text="記事用の文章をコピー", font=font, command=lambda: copy_article()).pack(side="left")
    tk.Button(top, text="結果を保存", font=font, command=lambda: save()).pack(side="left", padx=8)
    tk.Label(top, text="○ 合格　△ 要確認　× 不合格", font=font, fg="#555").pack(side="right")

    flist = tk.Label(root, text="", font=font, anchor="w", justify="left", padx=12, fg="#333")
    flist.pack(fill="x")
    verdict = tk.Label(root, text="LSP ファイルを選んで［チェック］を押してください。", font=big, anchor="w", padx=12, pady=6)
    verdict.pack(fill="x")

    nb = ttk.Notebook(root)
    nb.pack(fill="both", expand=True, padx=10, pady=(0, 10))
    f1, f2 = tk.Frame(nb), tk.Frame(nb)
    nb.add(f1, text="  チェック結果  ")
    nb.add(f2, text="  記事用の文章  ")
    out = tk.Text(f1, font=font, wrap="word", padx=10, pady=8)
    sb = tk.Scrollbar(f1, command=out.yview)
    out.configure(yscrollcommand=sb.set)
    sb.pack(side="right", fill="y")
    out.pack(fill="both", expand=True)
    art = tk.Text(f2, font=font, wrap="word", padx=10, pady=8)
    art.pack(fill="both", expand=True)
    out.tag_configure("ng", foreground="#c62828")
    out.tag_configure("warn", foreground="#b26a00")
    out.tag_configure("ok", foreground="#2e7d32")
    out.tag_configure("file", font=big)
    out.tag_configure("msg", lmargin1=36, lmargin2=36, foreground="#333")

    def show_files():
        flist.config(text="選んだファイル：" + ("、".join(os.path.basename(f) for f in files) if files else "（なし）"))

    def pick():
        sel = filedialog.askopenfilenames(title="チェックする LSP ファイル", filetypes=[("AutoLISP", "*.lsp"), ("すべて", "*.*")])
        if sel:
            files[:] = list(sel)
            show_files()
            run()

    def run():
        if not files:
            messagebox.showinfo("ChikoLispCheck", "先に［ファイルを選ぶ］で LSP ファイルを選んでください。")
            return
        results.clear()
        out.delete("1.0", "end")
        art.delete("1.0", "end")
        for p in files:
            try:
                results.append(check_file(p))
            except Exception as e:          # 読めないファイルでも止まらない
                out.insert("end", f"{os.path.basename(p)}：読み取れませんでした（{e}）\n\n", "ng")
        for R in results:
            ok, warn, ng = R.counts()
            out.insert("end", f"{os.path.basename(R.path)}：{R.verdict}（○{ok} △{warn} ×{ng}）\n", "file")
            for mark, tag in ((NG, "ng"), (WARN, "warn"), (OK, "ok")):
                for m, code, title, msg in R.items:
                    if m == mark:
                        out.insert("end", f"  {m} {code} {title}\n", tag)
                        parts = split_msg(msg) if msg else []
                        for p in parts:
                            out.insert("end", ("・" if len(parts) > 1 else "") + p + "\n", "msg")
            out.insert("end", "\n")
            art.insert("end", article_text(R) + "\n\n")
        worst = "公開OK"
        for R in results:
            if R.verdict == "直してから" or (R.verdict == "確認してから" and worst == "公開OK"):
                worst = R.verdict
        color = {"公開OK": "#2e7d32", "確認してから": "#b26a00", "直してから": "#c62828"}[worst] if results else "#333"
        verdict.config(text=f"判定：{worst}" if results else "チェックできませんでした", fg=color)

    def copy_article():
        s = art.get("1.0", "end").strip()
        if not s:
            messagebox.showinfo("ChikoLispCheck", "先に［チェック］を押してください。")
            return
        root.clipboard_clear()
        root.clipboard_append(s)
        messagebox.showinfo("ChikoLispCheck", "記事用の文章をコピーしました。note などに貼り付けて、必要なところを直してください。")

    def save():
        if not results:
            messagebox.showinfo("ChikoLispCheck", "先に［チェック］を押してください。")
            return
        p = filedialog.asksaveasfilename(title="結果を保存", defaultextension=".txt", initialfile="チェック結果.txt",
                                         filetypes=[("テキスト", "*.txt")])
        if p:
            with open(p, "w", encoding="utf-8-sig") as f:
                f.write(report_text(results) + "\n\n――― 記事用の文章 ―――\n\n" + "\n\n".join(article_text(R) for R in results))
            messagebox.showinfo("ChikoLispCheck", "保存しました。")

    show_files()
    if files:
        root.after(100, run)
    root.mainloop()


def main():
    args = sys.argv[1:]
    if args and args[0] == "--cli":
        paths = args[1:]
        if not paths:
            print("使い方: python ChikoLispCheck.py --cli ファイル.lsp [...]")
            return 1
        results = [check_file(p) for p in paths]
        print(report_text(results))
        if "--article" in os.environ.get("CLC_OPTS", ""):
            for R in results:
                print(article_text(R) + "\n")
        return 2 if any(R.verdict == "直してから" for R in results) else 0
    try:
        run_gui([a for a in args if os.path.isfile(a)])
    except Exception as e:           # 画面が使えない環境では文字で出す
        if not args:
            print("画面を表示できませんでした：", e)
            return 1
        print(report_text([check_file(p) for p in args if os.path.isfile(p)]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
