#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
lispcheck.py — AutoLISP 動作検証ツール
AutoCAD がない環境（Linux / クラウド / CI）で AutoLISP (.lsp) を実行し、
図面(DXF)への変更・画面出力・エラーを確認するための簡易シミュレータ。

  python lispcheck.py guide                 … AI向けの詳しい使い方（最初に読む）
  python lispcheck.py run foo.lsp --dxf in.dxf --cmd FOO --in "[0,0]" --png
  python lispcheck.py lint foo.lsp          … 実行せずに静的チェック
  python lispcheck.py info in.dxf           … 図面の中身を一覧
  python lispcheck.py render in.dxf out.png … 図面を画像化
  python lispcheck.py repl --dxf in.dxf     … 対話実行
依存: Python 3.8+ のみ（PNG出力は matplotlib があれば使用）
"""
VERSION = '0.1.2'

import sys, os, re, math, json, time, argparse, threading, datetime, zlib, base64, io, functools

TWO_PI = 2.0 * math.pi
EPS = 1e-9


# =====================================================================
#  基本データ型
# =====================================================================
class Sym:
    __slots__ = ('name',)
    _tab = {}

    def __new__(cls, name):
        key = name.lower()
        s = cls._tab.get(key)
        if s is None:
            s = object.__new__(cls)
            s.name = key
            cls._tab[key] = s
        return s

    def __repr__(self):
        return self.name.upper()


S = Sym
T = S('t')
VTRUE = S(':vlax-true')
VFALSE = S(':vlax-false')
VNULL = S(':vlax-null')


class Dotted:
    """ドット対 / 不完全リスト  (a b . c)"""
    __slots__ = ('items', 'tail')

    def __init__(self, items, tail):
        self.items = list(items)
        self.tail = tail


class SrcList(list):
    """ソース位置(ファイル名, 行)付きのリスト"""
    __slots__ = ('pos',)


class Ename:
    __slots__ = ('h',)

    def __init__(self, h):
        self.h = h

    def __eq__(self, o):
        return type(o) is Ename and o.h == self.h

    def __hash__(self):
        return hash(('E', self.h))


class PickSet:
    _n = 0

    def __init__(self, hs=None):
        PickSet._n += 1
        self.id = PickSet._n
        self.hs = list(hs or [])


class LFile:
    def __init__(self, path, mode, fobj, shown):
        self.path = path
        self.mode = mode
        self.f = fobj
        self.shown = shown
        self.closed = False


class Subr:
    __slots__ = ('name', 'f', 'level', 'note')

    def __init__(self, name, f, level='full', note=''):
        self.name = name
        self.f = f
        self.level = level
        self.note = note


class Special:
    __slots__ = ('name', 'f', 'level')

    def __init__(self, name, f, level='full'):
        self.name = name
        self.f = f
        self.level = level


class UFunc:
    __slots__ = ('name', 'params', 'locals', 'body', 'pos', 'bind')

    def __init__(self, name, params, locals_, body, pos=None):
        self.name = name
        self.params = params
        self.locals = locals_
        self.body = body
        self.pos = pos
        self.bind = list(params) + list(locals_)


class VlaObj:
    __slots__ = ('kind', 'ref')

    def __init__(self, kind, ref=None):
        self.kind = kind
        self.ref = ref

    def __eq__(self, o):
        return type(o) is VlaObj and o.kind == self.kind and o.ref == self.ref

    def __hash__(self):
        return hash((self.kind, str(self.ref)))


class Variant:
    __slots__ = ('vt', 'val')

    def __init__(self, vt, val):
        self.vt = vt
        self.val = val


class SafeArray:
    __slots__ = ('vt', 'dims', 'data')

    def __init__(self, vt, dims, data=None):
        self.vt = vt
        self.dims = dims  # [(lo, hi), ...]
        n = 1
        for lo, hi in dims:
            n *= (hi - lo + 1)
        if data is None:
            dflt = '' if vt == 8 else (None if vt in (9, 12) else (0.0 if vt in (4, 5) else 0))
            data = [dflt] * n
        self.data = list(data)


class CatchErr:
    __slots__ = ('msg',)

    def __init__(self, msg):
        self.msg = msg


# =====================================================================
#  例外
# =====================================================================
class LispError(Exception):
    def __init__(self, msg):
        Exception.__init__(self, msg)
        self.msg = msg
        self.form = None
        self.inner = None
        self.trace = None
        self.seen = False


class StepLimit(Exception):
    pass


class ParseError(Exception):
    def __init__(self, msg, fname, line):
        Exception.__init__(self, '%s (%s:%s)' % (msg, fname, line))
        self.msg = msg
        self.fname = fname
        self.line = line


# =====================================================================
#  リーダー（字句解析・構文解析）
# =====================================================================
_RE_INT = re.compile(r'[+-]?\d+\Z')
_RE_REAL = re.compile(r'[+-]?(\d+\.\d*|\.\d+|\d+)([eE][+-]?\d+)?\Z')
_DELIM = set(' \t\r\n\f\v()\'";')
_ESC = {'n': '\n', 'r': '\r', 't': '\t', 'e': '\x1b', '\\': '\\', '"': '"'}


def tokenize(text, fname='<string>'):
    toks = []
    i = 0
    n = len(text)
    line = 1
    linestart = 0
    while i < n:
        c = text[i]
        if c == '\n':
            line += 1
            i += 1
            linestart = i
            continue
        if c in ' \t\r\f\v\x1a﻿':
            i += 1
            continue
        if c == ';':
            if i + 1 < n and text[i + 1] == '|':
                j = text.find('|;', i + 2)
                if j < 0:
                    raise ParseError('ブロックコメント ;| が閉じられていません', fname, line)
                k = text.count('\n', i, j)
                if k:
                    line += k
                    linestart = text.rfind('\n', i, j) + 1
                i = j + 2
                continue
            j = text.find('\n', i)
            i = n if j < 0 else j
            continue
        if c in "()'":
            toks.append((c, None, line, i - linestart))
            i += 1
            continue
        if c == '"':
            buf = []
            i += 1
            start = line
            while True:
                if i >= n:
                    raise ParseError('文字列の " が閉じられていません', fname, start)
                c = text[i]
                if c == '"':
                    i += 1
                    break
                if c == '\\' and i + 1 < n:
                    d = text[i + 1]
                    if d in '01234567':
                        m = re.match(r'[0-7]{1,3}', text[i + 1:i + 4])
                        buf.append(chr(int(m.group(), 8)))
                        i += 1 + len(m.group())
                        continue
                    if d == '\n':
                        line += 1
                        linestart = i + 2
                    buf.append(_ESC.get(d, d))
                    i += 2
                    continue
                if c == '\n':
                    line += 1
                    linestart = i + 1
                buf.append(c)
                i += 1
            toks.append(('str', ''.join(buf), start, 0))
            continue
        j = i
        while j < n and text[j] not in _DELIM:
            j += 1
        toks.append(('atom', text[i:j], line, i - linestart))
        i = j
    return toks


def parse_atom(s):
    if _RE_INT.match(s):
        v = int(s)
        if -2147483648 <= v <= 2147483647:
            return v
        return float(v)
    if _RE_REAL.match(s):
        return float(s)
    if s.lower() == 'nil':
        return None
    return S(s)


_NOTAIL = object()


def read_all(text, fname='<string>'):
    """テキストを読み、トップレベルの式のリスト [(式, 行), ...] を返す"""
    toks = tokenize(text, fname)
    nt = len(toks)

    def rd(k):
        tok = toks[k]
        typ = tok[0]
        if typ == '(':
            lst = SrcList()
            lst.pos = (fname, tok[2])
            k += 1
            tail = _NOTAIL
            while True:
                if k >= nt:
                    raise ParseError('開き括弧 ( が閉じられていません（この行で開いた括弧）', fname, tok[2])
                t = toks[k]
                if t[0] == ')':
                    k += 1
                    break
                if t[0] == 'atom' and t[1] == '.' and lst:
                    if k + 1 >= nt:
                        raise ParseError('ドット対の後に式がありません', fname, t[2])
                    v, k = rd(k + 1)
                    tail = v
                    if k >= nt or toks[k][0] != ')':
                        raise ParseError('ドット対の後に ) がありません', fname, t[2])
                    k += 1
                    break
                v, k = rd(k)
                lst.append(v)
            if tail is not _NOTAIL:
                if tail is None:
                    return lst, k
                if isinstance(tail, list):
                    nl = SrcList(list(lst) + list(tail))
                    nl.pos = lst.pos
                    return nl, k
                if type(tail) is Dotted:
                    return Dotted(list(lst) + tail.items, tail.tail), k
                return Dotted(list(lst), tail), k
            return (lst if lst else None), k
        if typ == ')':
            raise ParseError('余分な閉じ括弧 ) があります', fname, tok[2])
        if typ == "'":
            if k + 1 >= nt:
                raise ParseError("' の後に式がありません", fname, tok[2])
            v, k2 = rd(k + 1)
            q = SrcList([S('quote'), v])
            q.pos = (fname, tok[2])
            return q, k2
        if typ == 'str':
            return tok[1], k + 1
        return parse_atom(tok[1]), k + 1

    out = []
    k = 0
    while k < nt:
        line = toks[k][2]
        v, k = rd(k)
        out.append((v, line))
    return out


# =====================================================================
#  プリンタ
# =====================================================================
def fmt_real(v):
    if v != v:
        return '1.#QNAN'
    if v in (float('inf'), float('-inf')):
        return '1.#INF' if v > 0 else '-1.#INF'
    s = '%.6g' % v
    if 'e' in s:
        m, e = s.split('e')
        if '.' not in m:
            m += '.0'
        s = m + 'e' + e
    elif '.' not in s:
        s += '.0'
    return s


def quote_str(s):
    out = ['"']
    for ch in s:
        if ch == '\\':
            out.append('\\\\')
        elif ch == '"':
            out.append('\\"')
        elif ch == '\n':
            out.append('\\n')
        elif ch == '\r':
            out.append('\\r')
        elif ch == '\t':
            out.append('\\t')
        elif ch == '\x1b':
            out.append('\\e')
        elif ord(ch) < 32:
            out.append('\\%03o' % ord(ch))
        else:
            out.append(ch)
    out.append('"')
    return ''.join(out)


VLA_IFACE = {
    'app': 'IAcadApplication', 'doc': 'IAcadDocument', 'util': 'IAcadUtility', 'pref': 'IAcadPreferences',
}


def lstr(x, pr=True):
    """AutoLISP 形式の文字列化。pr=True で prin1 形式、False で princ 形式"""
    if x is None:
        return 'nil'
    t = type(x)
    if t is int:
        return str(x)
    if t is float:
        return fmt_real(x)
    if t is str:
        return quote_str(x) if pr else x
    if t is Sym:
        return x.name.upper()
    if isinstance(x, list):
        return '(' + ' '.join(lstr(e, pr) for e in x) + ')'
    if t is Dotted:
        return '(' + ' '.join(lstr(e, pr) for e in x.items) + ' . ' + lstr(x.tail, pr) + ')'
    if t is Ename:
        return '<Entity name: %s>' % x.h
    if t is PickSet:
        return '<Selection set: %d>' % x.id
    if t is UFunc:
        return '#<USUBR @%08x %s>' % (id(x) & 0xFFFFFFFF, x.name)
    if t is Subr or t is Special:
        return '#<SUBR @%08x %s>' % (id(x) & 0xFFFFFFFF, x.name.upper())
    if t is LFile:
        return '#<file "%s">' % x.shown
    if t is VlaObj:
        return '#<VLA-OBJECT %s %s>' % (vla_iface_name(x), str(x.ref if x.ref is not None else '')[:40])
    if t is Variant:
        return '#<variant %d %s>' % (x.vt, lstr(x.val, pr) if not isinstance(x.val, SafeArray) else '...')
    if t is SafeArray:
        return '#<safearray...>'
    if t is CatchErr:
        return '#<%catch-all-apply-error%>'
    return str(x)


def short(x, n=160, pr=True):
    s = x if type(x) is str and not pr else lstr(x, pr)
    s = s.replace('\n', '\\n')
    return s if len(s) <= n else s[:n - 3] + '...'


def vla_iface_name(o):
    if o.kind in VLA_IFACE:
        return VLA_IFACE[o.kind]
    if o.kind == 'coll':
        return 'IAcad' + {'modelspace': 'ModelSpace', 'paperspace': 'PaperSpace', 'layers': 'Layers',
                          'blocks': 'Blocks', 'textstyles': 'TextStyles', 'linetypes': 'Linetypes',
                          'documents': 'Documents', 'dimstyles': 'DimStyles',
                          'registeredapplications': 'RegisteredApplications'}.get(o.ref, 'Collection')
    if o.kind == 'blk':
        return 'IAcadBlock'
    if o.kind == 'rec':
        return 'IAcad' + {'LAYER': 'Layer', 'STYLE': 'TextStyle', 'LTYPE': 'Linetype', 'DIMSTYLE': 'DimStyle',
                          'APPID': 'RegisteredApplication'}.get(o.ref[0], 'Object')
    if o.kind == 'ent':
        return 'IAcad' + o.ref[1] if isinstance(o.ref, tuple) else 'IAcadEntity'
    return 'IAcadObject'


# =====================================================================
#  共通ヘルパー
# =====================================================================
def wrap32(v):
    v &= 0xFFFFFFFF
    return v - 0x100000000 if v >= 0x80000000 else v


def isnum(x):
    t = type(x)
    return t is int or t is float


def argn(a, lo, hi=None):
    n = len(a)
    if n < lo:
        raise LispError('too few arguments')
    if hi is not None and n > hi:
        raise LispError('too many arguments')


def num(x):
    t = type(x)
    if t is int or t is float:
        return x
    raise LispError('bad argument type: numberp: ' + short(x))


def fixn(x):
    if type(x) is int:
        return x
    raise LispError('bad argument type: fixnump: ' + short(x))


def strp(x):
    if type(x) is str:
        return x
    raise LispError('bad argument type: stringp ' + short(x))


def symp(x):
    if type(x) is Sym:
        return x
    raise LispError('bad argument type: symbolp ' + short(x))


def seq(x):
    """AutoLISP のリストを Python リストに（nil→[]）"""
    if x is None:
        return []
    if isinstance(x, list):
        return x
    raise LispError('bad argument type: listp ' + short(x))


def ptp(x):
    if isinstance(x, list) and 2 <= len(x) <= 3 and all(isnum(v) for v in x):
        return [float(v) for v in x]
    raise LispError('bad argument type: 2D/3D point: ' + short(x))


def L(it):
    lst = list(it)
    return lst if lst else None


def truth(b):
    return T if b else None


def lequal(a, b, fz=0.0):
    if isnum(a) and isnum(b):
        return abs(a - b) <= fz if fz else a == b
    if isinstance(a, list):
        if not isinstance(b, list) or len(a) != len(b):
            return False
        return all(lequal(x, y, fz) for x, y in zip(a, b))
    ta, tb = type(a), type(b)
    if ta is Dotted:
        if tb is not Dotted or len(a.items) != len(b.items):
            return False
        return all(lequal(x, y, fz) for x, y in zip(a.items, b.items)) and lequal(a.tail, b.tail, fz)
    if ta is Variant and tb is Variant:
        return a.vt == b.vt and lequal(a.val, b.val, fz)
    if ta is SafeArray and tb is SafeArray:
        return a.dims == b.dims and all(lequal(x, y, fz) for x, y in zip(a.data, b.data))
    if isinstance(b, list):
        return False
    return a == b


def leq(a, b):
    if a is b:
        return True
    if isnum(a) and isnum(b):
        return type(a) is type(b) and a == b
    if type(a) is Ename or type(a) is VlaObj:
        return a == b
    return False


def to_pt3(p):
    p = list(p)
    if len(p) == 2:
        p.append(0.0)
    return (float(p[0]), float(p[1]), float(p[2]))


def fmt_pt(p):
    return '(' + ' '.join(fmt_real(float(v)) for v in p) + ')'


def ang_norm(a):
    a = math.fmod(a, TWO_PI)
    if a < 0:
        a += TWO_PI
    return a


# --------------------------------------------------------------- wcmatch
_WC_CACHE = {}


def _wc_compile(pat, icase):
    key = (pat, icase)
    r = _WC_CACHE.get(key)
    if r is not None:
        return r
    alts = []
    cur = []
    i = 0
    while i < len(pat):
        c = pat[i]
        if c == '`' and i + 1 < len(pat):
            cur.append(c + pat[i + 1])
            i += 2
            continue
        if c == ',':
            alts.append(''.join(cur))
            cur = []
            i += 1
            continue
        if c == '[':
            j = pat.find(']', i + 1)
            if j > 0:
                cur.append(pat[i:j + 1])
                i = j + 1
                continue
        cur.append(c)
        i += 1
    alts.append(''.join(cur))
    comp = []
    for a in alts:
        neg = a.startswith('~')
        if neg:
            a = a[1:]
        rx = []
        i = 0
        while i < len(a):
            c = a[i]
            if c == '`' and i + 1 < len(a):
                rx.append(re.escape(a[i + 1]))
                i += 2
                continue
            if c == '#':
                rx.append('[0-9]')
            elif c == '@':
                rx.append('[^\\W\\d_]')
            elif c == '.':
                rx.append('[\\W_]')
            elif c == '*':
                rx.append('.*')
            elif c == '?':
                rx.append('.')
            elif c == '[':
                j = a.find(']', i + 1)
                if j < 0:
                    rx.append(re.escape(c))
                else:
                    body = a[i + 1:j]
                    negc = body.startswith('~')
                    if negc:
                        body = body[1:]
                    parts = []
                    k = 0
                    while k < len(body):
                        if k + 2 < len(body) and body[k + 1] == '-':
                            parts.append(re.escape(body[k]) + '-' + re.escape(body[k + 2]))
                            k += 3
                        else:
                            parts.append(re.escape(body[k]))
                            k += 1
                    rx.append('[' + ('^' if negc else '') + ''.join(parts) + ']')
                    i = j + 1
                    continue
            else:
                rx.append(re.escape(c))
            i += 1
        comp.append((neg, re.compile(''.join(rx) + r'\Z', re.S | (re.I if icase else 0))))
    _WC_CACHE[key] = comp
    return comp


def wcmatch(s, pat, icase=False):
    for neg, rx in _wc_compile(pat, icase):
        m = rx.match(s) is not None
        if m != neg:
            return True
    return False


# =====================================================================
#  インタプリタ本体
# =====================================================================
BUILTINS = {}
SPECIALS = {}
CONSTANTS = {}
_UNB = object()
MAX_DEPTH = 20000


def bi(names, level='full', note=''):
    def deco(f):
        for n in names.split():
            BUILTINS[n] = Subr(n, f, level, note)
        return f
    return deco


def sp(names, level='full'):
    def deco(f):
        for n in names.split():
            SPECIALS[n] = Special(n, f, level)
        return f
    return deco


class Interp:
    def __init__(self, dwg, opts=None):
        opts = opts or {}
        self.opts = opts
        self.dwg = dwg
        self.g = {}
        for n, f in BUILTINS.items():
            self.g[S(n)] = f
        for n, f in SPECIALS.items():
            self.g[S(n)] = f
        for n, v in CONSTANTS.items():
            self.g[S(n)] = v
        self.g[T] = T
        self.g[S('pi')] = math.pi
        self.g[S('pause')] = '\\'
        self.g[VTRUE] = VTRUE
        self.g[VFALSE] = VFALSE
        self.g[VNULL] = VNULL
        self.out = []
        self.live = opts.get('live', False)
        self.warns = {}
        self.errors = []
        self.asserts = []
        self.stack = []
        self.steps = 0
        self.max_steps = opts.get('max_steps', 30000000)
        self.timeout = opts.get('timeout', 120)
        self.deadline = time.time() + self.timeout
        self.catch_depth = 0
        self.in_handler = False
        self.inputs = list(opts.get('inputs', []))
        self.auto_input = opts.get('auto', False)
        self.initget = (0, [], [])
        self.callcount = {}
        self.trace_names = set(n.upper() for n in opts.get('trace', []))
        self.trace_all = opts.get('trace_all', False)
        self.trace_depth = 0
        self.env = {}
        self.outdir = opts.get('outdir', '.')
        self.search = list(opts.get('search', []))
        self.prev_ss = None
        self.pickfirst = None
        self.ldata = {}
        self.bb = {}
        self.added_cmds = {}
        self.loaded = []
        self.vl_com = False
        self.defined = {}
        self.pending_block = None
        self.tblnext_pos = {}
        self.written_files = []
        self.sysvars = default_sysvars(dwg)
        self.sysvars0 = dict((k, copy_val(v)) for k, v in self.sysvars.items())
        self.cmd_log = []
        self.last_point = None
        self.uid = 0

    # ---------------------------------------------------------------- 出力
    def echo(self, s):
        self.out.append(s)
        if self.live:
            sys.stdout.write(s)
            sys.stdout.flush()

    def warn(self, msg):
        self.warns[msg] = self.warns.get(msg, 0) + 1

    def check_limits(self):
        if self.steps > self.max_steps:
            raise StepLimit('評価ステップ数の上限(%d)を超えました（無限ループの可能性）' % self.max_steps)
        if time.time() > self.deadline:
            raise StepLimit('実行時間の上限(%d秒)を超えました（無限ループの可能性）' % self.timeout)

    # ---------------------------------------------------------------- 評価
    def ev(self, x):
        if type(x) is Sym:
            return self.g.get(x)
        if not isinstance(x, list):
            return x
        if not x:
            return None
        self.steps += 1
        if not (self.steps & 0x1FFF):
            self.check_limits()
        try:
            h = x[0]
            if type(h) is Sym:
                f = self.g.get(h)
                if f is None:
                    f = self.dyn_fn(h)
                    if f is None:
                        raise LispError('no function definition: ' + h.name.upper())
            else:
                f = self.ev(h)
            if type(f) is Special:
                return f.f(self, x)
            args = [self.ev(a) for a in x[1:]]
            if type(f) is Subr:
                return f.f(self, args)
            return self.call(f, args, x, h)
        except LispError as e:
            if not e.seen:
                e.seen = True
                e.trace = self.snapshot()
                e.inner = x
                if type(x) is SrcList:
                    e.form = x
                if self.catch_depth == 0 and not self.in_handler:
                    self.invoke_error_handler(e)
            elif e.form is None and type(x) is SrcList:
                e.form = x
            raise
        except RecursionError:
            raise LispError('stack overflow（再帰が深すぎます）')

    def snapshot(self):
        return [(n, p, a) for (n, p, a) in self.stack[-40:]]

    def fn_of(self, f):
        if type(f) is Sym:
            v = self.g.get(f)
            if v is None:
                v = self.dyn_fn(f)
            if v is None:
                raise LispError('no function definition: ' + f.name.upper())
            return v
        return f

    def call(self, f, args, form=None, name=None):
        tf = type(f)
        if tf is Subr:
            return f.f(self, args)
        if tf is UFunc:
            return self.call_user(f, args, form)
        if tf is Sym:
            return self.call(self.fn_of(f), args, form, f)
        if isinstance(f, list) and f and f[0] is S('lambda') and len(f) >= 2:
            ps, ls = parse_params(f[1])
            return self.call_user(UFunc('LAMBDA', ps, ls, f[2:]), args, form)
        if isinstance(f, list) and f and (f[0] is None or isinstance(f[0], list)):
            ps, ls = parse_params(f[0])
            return self.call_user(UFunc('LAMBDA', ps, ls, f[1:]), args, form)
        if f is None and name is not None:
            raise LispError('no function definition: ' + name.name.upper())
        raise LispError('bad function: ' + short(f))

    def call_user(self, f, args, form=None):
        ps = f.params
        if len(args) != len(ps):
            raise LispError('too few arguments' if len(args) < len(ps) else 'too many arguments')
        g = self.g
        names = f.bind
        saved = [g.get(s, _UNB) for s in names]
        i = 0
        for s in ps:
            g[s] = args[i]
            i += 1
        for s in f.locals:
            g[s] = None
        st = self.stack
        if len(st) > MAX_DEPTH:
            raise LispError('stack overflow（再帰が深すぎます）')
        st.append((f.name, form.pos if type(form) is SrcList else None, args))
        cc = self.callcount
        cc[f.name] = cc.get(f.name, 0) + 1
        tr = self.trace_all or (f.name in self.trace_names)
        if tr:
            self.echo('%s→ (%s%s)\n' % ('  ' * self.trace_depth, f.name,
                                         ''.join(' ' + short(a, 60) for a in args)))
            self.trace_depth += 1
        try:
            r = None
            for b in f.body:
                r = self.ev(b)
        finally:
            st.pop()
            for s, v in zip(names, saved):
                if v is _UNB:
                    g.pop(s, None)
                else:
                    g[s] = v
            if tr:
                self.trace_depth -= 1
        if tr:
            self.echo('%s← %s = %s\n' % ('  ' * self.trace_depth, f.name, short(r, 100)))
        return r

    def dyn_fn(self, h):
        n = h.name
        if n.startswith('vla-') or n.startswith('vlax-'):
            if not self.vl_com:
                self.warn('(vl-load-com) を呼ぶ前に %s が使われました（AutoCADでは失敗する場合があります）' % n.upper())
        if n.startswith('vla-get-'):
            prop = n[8:]
            f = Subr(n, lambda I, a, p=prop: vla_get_fn(I, a, p), 'approx')
        elif n.startswith('vla-put-'):
            prop = n[8:]
            f = Subr(n, lambda I, a, p=prop: vla_put_fn(I, a, p), 'approx')
        elif n.startswith('vla-'):
            meth = n[4:]
            f = Subr(n, lambda I, a, m=meth: vla_invoke_fn(I, a, m), 'approx')
        else:
            return None
        self.g[h] = f
        return f

    def invoke_error_handler(self, e):
        h = self.g.get(S('*error*'))
        if h is None or not isinstance(h, (UFunc, Subr, list)):
            self.echo('\n; error: %s\n' % e.msg)
            return
        self.in_handler = True
        try:
            self.call(h, [e.msg], None, S('*error*'))
        except LispError as e2:
            if e2.msg != 'quit / exit abort':
                self.errors.append(self.err_info(e2, '*error* 関数の中でエラー'))
                self.echo('\n; error: %s\n' % e2.msg)
        except StepLimit:
            raise
        finally:
            self.in_handler = False

    def err_info(self, e, where=''):
        form = e.form
        pos = getattr(form, 'pos', None) if form is not None else None
        return {
            'msg': e.msg,
            'where': where,
            'pos': pos,
            'form': short(e.inner if e.inner is not None else form, 200),
            'trace': [(n, p, [short(a, 50) for a in args]) for (n, p, args) in (e.trace or [])],
        }

    # ---------------------------------------------------------------- 実行
    def load_text(self, text, fname):
        forms = read_all(text, fname)
        r = None
        for f, line in forms:
            r = self.ev(f)
        return r

    def load_file(self, path):
        text = read_text_file(path)
        self.loaded.append(path)
        old = self.g.get(S('*lc-current-file*'))
        self.g[S('*lc-current-file*')] = path
        try:
            return self.load_text(text, os.path.basename(path))
        finally:
            self.g[S('*lc-current-file*')] = old

    def toplevel(self, thunk, label):
        """AutoCAD のコマンドラインから1回実行するのと同等（エラー時は *error* を呼び中断）"""
        self.initget = (0, [], [])
        try:
            return True, thunk()
        except LispError as e:
            self.errors.append(self.err_info(e, label))
            return False, None
        except StepLimit as e:
            self.errors.append({'msg': str(e), 'where': label, 'pos': None, 'form': '', 'trace': [
                (n, p, []) for (n, p, a) in self.stack[-10:]]})
            self.stack = []
            self.echo('\n; error: %s\n' % e)
            return False, None
        except ParseError as e:
            self.errors.append({'msg': '構文エラー: ' + e.msg, 'where': label, 'pos': (e.fname, e.line),
                                'form': '', 'trace': []})
            self.echo('\n; error: malformed list on input (%s)\n' % e)
            return False, None

    def run_command(self, name):
        cname = name.upper()
        if cname.startswith('C:'):
            cname = cname[2:]
        f = self.g.get(S('c:' + cname))
        if f is None and cname.lower() in self.added_cmds:
            f = self.added_cmds[cname.lower()]
        if f is None:
            self.echo('\nコマンド: %s\n不明なコマンド "%s"。F1 キーを押してヘルプを参照してください。\n' % (cname, cname))
            self.errors.append({'msg': 'コマンド C:%s が定義されていません' % cname, 'where': 'コマンド ' + cname,
                                'pos': None, 'form': '', 'trace': []})
            return False, None
        self.echo('\nコマンド: %s\n' % cname)
        self.deadline = time.time() + self.timeout

        def th():
            fn = self.fn_of(f) if type(f) is Sym else f
            if type(fn) is UFunc and fn.params:
                raise LispError('too few arguments')
            return self.call(fn, [], None, S('c:' + cname))

        # 関数そのものの呼び出しエラーでも *error* が呼ばれるようにする
        def th2():
            try:
                return th()
            except LispError as e:
                if not e.seen:
                    e.seen = True
                    e.trace = self.snapshot()
                    if self.catch_depth == 0:
                        self.invoke_error_handler(e)
                raise
        return self.toplevel(th2, 'コマンド ' + cname)

    def run_eval(self, text):
        self.deadline = time.time() + self.timeout

        def th():
            r = None
            for f, line in read_all(text, '<eval>'):
                r = self.ev(f)
            return r
        return self.toplevel(th, '式 ' + text[:60])

    # ---------------------------------------------------------------- 入力台本
    def pop_input(self, kind):
        if self.inputs:
            v = self.inputs.pop(0)
            src = '入力'
        elif self.auto_input:
            v = auto_value(kind)
            src = '自動入力'
            self.warn('入力が足りないため自動入力を使用しました（%s）' % kind)
        else:
            self.warn('入力の台本が不足しています（%s で入力待ち）→ ESCキャンセル扱いにしました。--in で値を追加してください' % kind)
            self.echo('*キャンセル*\n')
            raise LispError('Function cancelled')
        self.echo('<%s: %s>\n' % (src, show_input(v)))
        return v


def copy_val(v):
    return list(v) if isinstance(v, list) else v


def parse_params(pl):
    params = []
    locs = []
    cur = params
    for p in seq(pl):
        if type(p) is Sym and p.name == '/':
            cur = locs
            continue
        if type(p) is not Sym:
            raise LispError('bad argument type: symbolp ' + short(p))
        cur.append(p)
    return params, locs


def read_text_file(path):
    raw = open(path, 'rb').read()
    if raw.startswith(b'\xef\xbb\xbf'):
        return raw[3:].decode('utf-8', errors='replace')
    for enc in ('utf-8', 'cp932'):
        try:
            return raw.decode(enc)
        except UnicodeDecodeError:
            pass
    return raw.decode('latin-1')


def show_input(v):
    if isinstance(v, (dict,)):
        return json.dumps(v, ensure_ascii=False)
    if v is None:
        return 'Enter(空)'
    if type(v) in (int, float, str, list, Ename, PickSet, Sym, Dotted):
        if isinstance(v, list) and v and all(isnum(e) for e in v):
            return fmt_pt(v)
        return short(v, 120)
    return str(v)


def auto_value(kind):
    k = kind.lower()
    if 'point' in k or 'corner' in k:
        return [0.0, 0.0, 0.0]
    if 'ssget' in k:
        return 'all'
    if 'int' in k:
        return 1
    if 'real' in k or 'dist' in k or 'angle' in k:
        return 1.0
    if 'entsel' in k:
        return 'last'
    return ''


# =====================================================================
#  特殊形式
# =====================================================================
@sp('quote')
def _quote(I, x):
    argn(x, 2, 2)
    return x[1]


@sp('function')
def _function(I, x):
    argn(x, 2, 2)
    v = x[1]
    if isinstance(v, list):
        return I.ev(v)
    return v


@sp('setq')
def _setq(I, x):
    n = len(x) - 1
    if n == 0 or n % 2:
        raise LispError('too few arguments')
    v = None
    g = I.g
    for i in range(1, n, 2):
        s = x[i]
        if type(s) is not Sym:
            raise LispError('bad argument type: symbolp ' + short(s))
        if s is T:
            raise LispError('attempt to set constant: T')
        v = I.ev(x[i + 1])
        old = g.get(s)
        if type(old) in (Subr, Special) and s.name not in I.defined:
            I.warn('組み込み関数 %s を setq で上書きしています（AutoCADでは保護シンボル警告が出ます）' % s.name.upper())
        g[s] = v
    return v


@sp('defun defun-q')
def _defun(I, x):
    argn(x, 3)
    name = x[1]
    if type(name) is not Sym:
        raise LispError('bad argument type: symbolp ' + short(name))
    pl = x[2]
    if pl is not None and not isinstance(pl, list):
        raise LispError('bad argument type: listp ' + short(pl))
    ps, ls = parse_params(pl)
    f = UFunc(name.name.upper(), ps, ls, list(x[3:]), getattr(x, 'pos', None))
    if type(I.g.get(name)) in (Subr, Special) and name.name not in I.defined:
        I.warn('組み込み関数 %s を defun で再定義しています' % name.name.upper())
    I.g[name] = f
    I.defined[name.name] = f
    return name


@sp('lambda')
def _lambda(I, x):
    argn(x, 2)
    ps, ls = parse_params(x[1])
    return UFunc('LAMBDA', ps, ls, list(x[2:]), getattr(x, 'pos', None))


@sp('if')
def _if(I, x):
    n = len(x)
    if n < 3:
        raise LispError('too few arguments')
    if n > 4:
        raise LispError('too many arguments')
    if I.ev(x[1]) is not None:
        return I.ev(x[2])
    return I.ev(x[3]) if n == 4 else None


@sp('cond')
def _cond(I, x):
    for cl in x[1:]:
        if cl is None:
            continue
        if not isinstance(cl, list):
            raise LispError('bad argument type: consp ' + short(cl))
        v = I.ev(cl[0])
        if v is not None:
            for b in cl[1:]:
                v = I.ev(b)
            return v
    return None


@sp('while')
def _while(I, x):
    argn(x, 2)
    r = None
    body = x[2:]
    while I.ev(x[1]) is not None:
        for b in body:
            r = I.ev(b)
    return r


@sp('repeat')
def _repeat(I, x):
    argn(x, 2)
    n = I.ev(x[1])
    if type(n) is not int:
        raise LispError('bad argument type: fixnump: ' + short(n))
    r = None
    body = x[2:]
    for _ in range(n):
        for b in body:
            r = I.ev(b)
    return r


@sp('foreach')
def _foreach(I, x):
    argn(x, 3)
    v = x[1]
    if type(v) is not Sym:
        raise LispError('bad argument type: symbolp ' + short(v))
    lst = I.ev(x[2])
    if type(lst) is Dotted:
        items = lst.items
    else:
        items = seq(lst)
    old = I.g.get(v, _UNB)
    r = None
    body = x[3:]
    try:
        for it in list(items):
            I.g[v] = it
            for b in body:
                r = I.ev(b)
    finally:
        if old is _UNB:
            I.g.pop(v, None)
        else:
            I.g[v] = old
    return r


@sp('progn')
def _progn(I, x):
    r = None
    for b in x[1:]:
        r = I.ev(b)
    return r


@sp('and')
def _and(I, x):
    for b in x[1:]:
        if I.ev(b) is None:
            return None
    return T


@sp('or')
def _or(I, x):
    for b in x[1:]:
        if I.ev(b) is not None:
            return T
    return None


@sp('trace')
def _trace(I, x):
    r = None
    for s in x[1:]:
        if type(s) is Sym:
            I.trace_names.add(s.name.upper())
            r = s
    return r


@sp('untrace')
def _untrace(I, x):
    r = None
    for s in x[1:]:
        if type(s) is Sym:
            I.trace_names.discard(s.name.upper())
            r = s
    return r


@sp('vlax-for', 'approx')
def _vlax_for(I, x):
    argn(x, 3)
    v = x[1]
    coll = I.ev(x[2])
    items = vla_collection_items(I, coll)
    old = I.g.get(v, _UNB)
    r = None
    try:
        for it in items:
            I.g[v] = it
            for b in x[3:]:
                r = I.ev(b)
    finally:
        if old is _UNB:
            I.g.pop(v, None)
        else:
            I.g[v] = old
    return r


def _assert_pos(x):
    p = getattr(x, 'pos', None)
    return '%s:%s' % p if p else ''


@sp('lc:assert')
def _lc_assert(I, x):
    argn(x, 2, 3)
    v = I.ev(x[1])
    msg = I.ev(x[2]) if len(x) > 2 else ''
    ok = v is not None
    I.asserts.append({'ok': ok, 'pos': _assert_pos(x), 'expr': short(x[1], 120), 'msg': msg or '',
                      'detail': '' if ok else '結果が nil'})
    I.echo('[assert %s] %s %s\n' % ('OK' if ok else 'NG', short(x[1], 80), msg or ''))
    return truth(ok)


@sp('lc:assert-equal')
def _lc_assert_equal(I, x):
    argn(x, 3, 4)
    a = I.ev(x[1])
    b = I.ev(x[2])
    msg = I.ev(x[3]) if len(x) > 3 else ''
    if isnum(msg):
        fz = float(msg)
        msg = ''
    else:
        fz = 1e-8
    ok = lequal(a, b, fz)
    I.asserts.append({'ok': ok, 'pos': _assert_pos(x), 'expr': short(x[1], 120), 'msg': msg or '',
                      'detail': '' if ok else '実際 %s / 期待 %s' % (short(a, 100), short(b, 100))})
    I.echo('[assert %s] %s %s\n' % ('OK' if ok else 'NG', short(x[1], 80),
                                    '' if ok else '→ 実際 %s / 期待 %s' % (short(a, 80), short(b, 80))))
    return truth(ok)


@sp('lc:expect-error')
def _lc_expect_error(I, x):
    """(lc:expect-error 式 ["メッセージの一部"]) 式がエラーになることを確認"""
    argn(x, 2, 3)
    want = I.ev(x[2]) if len(x) > 2 else None
    I.catch_depth += 1
    msg = None
    try:
        I.ev(x[1])
    except LispError as e:
        msg = e.msg
    finally:
        I.catch_depth -= 1
    ok = msg is not None and (not want or want.lower() in msg.lower())
    I.asserts.append({'ok': ok, 'pos': _assert_pos(x), 'expr': short(x[1], 120), 'msg': '',
                      'detail': '' if ok else ('エラーにならなかった' if msg is None else 'エラー内容が違う: ' + msg)})
    I.echo('[assert %s] (エラー期待) %s\n' % ('OK' if ok else 'NG', short(x[1], 80)))
    return truth(ok)


# =====================================================================
#  組み込み関数：数値
# =====================================================================
@bi('+')
def _add(I, a):
    r = 0
    fl = False
    for x in a:
        x = num(x)
        if type(x) is float:
            fl = True
        r += x
    return float(r) if fl else wrap32(r)


@bi('-')
def _sub(I, a):
    if not a:
        return 0
    r = num(a[0])
    fl = type(r) is float
    if len(a) == 1:
        return -r if fl else wrap32(-r)
    for x in a[1:]:
        x = num(x)
        if type(x) is float:
            fl = True
        r -= x
    return float(r) if fl else wrap32(r)


@bi('*')
def _mul(I, a):
    if not a:
        return 0
    r = 1
    fl = False
    for x in a:
        x = num(x)
        if type(x) is float:
            fl = True
        r *= x
        if not fl:
            r = wrap32(r)
    return float(r) if fl else wrap32(r)


@bi('/')
def _div(I, a):
    if not a:
        return 0
    r = num(a[0])
    for y in a[1:]:
        y = num(y)
        if y == 0:
            raise LispError('divide by zero')
        if type(r) is int and type(y) is int:
            q = abs(r) // abs(y)
            r = wrap32(q if (r >= 0) == (y >= 0) else -q)
        else:
            r = float(r) / y
    return r


@bi('rem')
def _rem(I, a):
    argn(a, 1)
    r = num(a[0])
    for y in a[1:]:
        y = num(y)
        if y == 0:
            raise LispError('divide by zero')
        if type(r) is int and type(y) is int:
            r = int(math.fmod(r, y))
        else:
            r = math.fmod(r, y)
    return r


@bi('1+')
def _inc(I, a):
    argn(a, 1, 1)
    x = num(a[0])
    return x + 1.0 if type(x) is float else wrap32(x + 1)


@bi('1-')
def _dec(I, a):
    argn(a, 1, 1)
    x = num(a[0])
    return x - 1.0 if type(x) is float else wrap32(x - 1)


@bi('abs')
def _abs(I, a):
    argn(a, 1, 1)
    x = num(a[0])
    return abs(x) if type(x) is float else wrap32(abs(x))


@bi('max')
def _max(I, a):
    argn(a, 1)
    vs = [num(x) for x in a]
    r = max(vs)
    return float(r) if any(type(v) is float for v in vs) else r


@bi('min')
def _min(I, a):
    argn(a, 1)
    vs = [num(x) for x in a]
    r = min(vs)
    return float(r) if any(type(v) is float for v in vs) else r


@bi('gcd')
def _gcd(I, a):
    argn(a, 2)
    r = fixn(a[0])
    for x in a[1:]:
        r = math.gcd(r, fixn(x))
    return r


@bi('lcm')
def _lcm(I, a):
    argn(a, 2)
    r = fixn(a[0])
    for x in a[1:]:
        x = fixn(x)
        r = abs(r * x) // math.gcd(r, x) if r and x else 0
    return wrap32(r)


@bi('expt')
def _expt(I, a):
    argn(a, 2, 2)
    b, e = num(a[0]), num(a[1])
    if type(b) is int and type(e) is int and e >= 0:
        return wrap32(b ** e)
    try:
        return float(b) ** float(e)
    except (ZeroDivisionError, OverflowError, ValueError):
        raise LispError('function undefined for argument: ' + short(b))


@bi('sqrt')
def _sqrt(I, a):
    argn(a, 1, 1)
    x = num(a[0])
    if x < 0:
        raise LispError('function undefined for argument: ' + short(x))
    return math.sqrt(x)


@bi('exp')
def _exp(I, a):
    argn(a, 1, 1)
    return math.exp(num(a[0]))


@bi('log')
def _log(I, a):
    argn(a, 1, 1)
    x = num(a[0])
    if x <= 0:
        raise LispError('function undefined for argument: ' + short(x))
    return math.log(x)


@bi('sin')
def _sin(I, a):
    argn(a, 1, 1)
    return math.sin(num(a[0]))


@bi('cos')
def _cos(I, a):
    argn(a, 1, 1)
    return math.cos(num(a[0]))


@bi('atan')
def _atan(I, a):
    argn(a, 1, 2)
    if len(a) == 1:
        return math.atan(num(a[0]))
    return math.atan2(num(a[0]), num(a[1]))


@bi('fix')
def _fix(I, a):
    argn(a, 1, 1)
    x = num(a[0])
    return int(x) if abs(x) < 2 ** 31 else float(math.trunc(x))


@bi('float')
def _float(I, a):
    argn(a, 1, 1)
    return float(num(a[0]))


@bi('~')
def _bnot(I, a):
    argn(a, 1, 1)
    return wrap32(~fixn(a[0]))


@bi('logand')
def _logand(I, a):
    if not a:
        return 0
    r = -1
    for x in a:
        r &= fixn(x)
    return wrap32(r)


@bi('logior')
def _logior(I, a):
    r = 0
    for x in a:
        r |= fixn(x)
    return wrap32(r)


@bi('lsh')
def _lsh(I, a):
    argn(a, 1, 2)
    n = fixn(a[0])
    b = fixn(a[1]) if len(a) > 1 else 0
    if b >= 0:
        return wrap32(n << b)
    return wrap32((n & 0xFFFFFFFF) >> (-b))


@bi('boole')
def _boole(I, a):
    argn(a, 2)
    op = fixn(a[0])
    r = fixn(a[1])
    for x in a[2:]:
        x = fixn(x)
        res = 0
        for bit in range(32):
            i1 = (r >> bit) & 1
            i2 = (x >> bit) & 1
            if (op >> (3 - (i1 * 2 + i2))) & 1:
                res |= (1 << bit)
        r = wrap32(res)
    return r


def _cmp(a, op, name):
    argn(a, 1)
    for i in range(len(a) - 1):
        x, y = a[i], a[i + 1]
        if isnum(x) and isnum(y):
            ok = op(x, y)
        elif type(x) is str and type(y) is str:
            ok = op(x, y)
        elif name in ('=', '/='):
            e = leq(x, y) or (x is None and y is None)
            ok = e if name == '=' else not e
        else:
            raise LispError('bad argument type: numberp: ' + short(x if not isnum(x) and type(x) is not str else y))
        if not ok:
            return None
    return T


@bi('=')
def _eqn(I, a):
    return _cmp(a, lambda x, y: x == y, '=')


@bi('/=')
def _neqn(I, a):
    return _cmp(a, lambda x, y: x != y, '/=')


@bi('<')
def _lt(I, a):
    return _cmp(a, lambda x, y: x < y, '<')


@bi('<=')
def _le(I, a):
    return _cmp(a, lambda x, y: x <= y, '<=')


@bi('>')
def _gt(I, a):
    return _cmp(a, lambda x, y: x > y, '>')


@bi('>=')
def _ge(I, a):
    return _cmp(a, lambda x, y: x >= y, '>=')


@bi('zerop')
def _zerop(I, a):
    argn(a, 1, 1)
    return truth(num(a[0]) == 0)


@bi('minusp')
def _minusp(I, a):
    argn(a, 1, 1)
    return truth(num(a[0]) < 0)


@bi('numberp')
def _numberp(I, a):
    argn(a, 1, 1)
    return truth(isnum(a[0]))


@bi('eq')
def _eq(I, a):
    argn(a, 2, 2)
    return truth(leq(a[0], a[1]))


@bi('equal')
def _equal(I, a):
    argn(a, 2, 3)
    fz = float(num(a[2])) if len(a) > 2 else 0.0
    return truth(lequal(a[0], a[1], fz))


# =====================================================================
#  組み込み関数：リスト
# =====================================================================
def _car(x):
    if x is None:
        return None
    if isinstance(x, list):
        return x[0]
    if type(x) is Dotted:
        return x.items[0]
    raise LispError('bad argument type: consp ' + short(x))


def _cdr(x):
    if x is None:
        return None
    if isinstance(x, list):
        return x[1:] or None
    if type(x) is Dotted:
        return x.tail if len(x.items) == 1 else Dotted(x.items[1:], x.tail)
    raise LispError('bad argument type: consp ' + short(x))


def _mk_cxr(path):
    def f(I, a):
        argn(a, 1, 1)
        v = a[0]
        for ch in reversed(path):
            v = _car(v) if ch == 'a' else _cdr(v)
        return v
    return f


for _ln in range(1, 5):
    import itertools as _it
    for _p in _it.product('ad', repeat=_ln):
        _nm = 'c' + ''.join(_p) + 'r'
        BUILTINS[_nm] = Subr(_nm, _mk_cxr(''.join(_p)))


@bi('cons')
def _cons(I, a):
    argn(a, 2, 2)
    x, y = a
    if y is None:
        return [x]
    if isinstance(y, list):
        return [x] + y
    if type(y) is Dotted:
        return Dotted([x] + y.items, y.tail)
    return Dotted([x], y)


@bi('list')
def _list(I, a):
    return L(a)


@bi('vl-list*')
def _list_star(I, a):
    argn(a, 1)
    if len(a) == 1:
        return a[0]
    return _cons(I, [a[0], _list_star(I, a[1:])]) if len(a) > 2 else _cons(I, a)


@bi('append')
def _append(I, a):
    out = []
    for x in a:
        out.extend(seq(x))
    return L(out)


@bi('length')
def _length(I, a):
    argn(a, 1, 1)
    if type(a[0]) is Dotted:
        raise LispError('bad list: ' + short(a[0]))
    return len(seq(a[0]))


@bi('vl-list-length')
def _vl_list_length(I, a):
    argn(a, 1, 1)
    if type(a[0]) is Dotted:
        return None
    return len(seq(a[0]))


@bi('reverse')
def _reverse(I, a):
    argn(a, 1, 1)
    return L(reversed(seq(a[0])))


@bi('nth')
def _nth(I, a):
    argn(a, 2, 2)
    n = fixn(a[0])
    lst = a[1]
    if type(lst) is Dotted:
        items = lst.items
    else:
        items = seq(lst)
    if n < 0 or n >= len(items):
        return None
    return items[n]


@bi('last')
def _last(I, a):
    argn(a, 1, 1)
    lst = seq(a[0])
    return lst[-1] if lst else None


@bi('member')
def _member(I, a):
    argn(a, 2, 2)
    lst = seq(a[1])
    for i, e in enumerate(lst):
        if lequal(e, a[0]):
            return lst[i:]
    return None


@bi('assoc')
def _assoc(I, a):
    argn(a, 2, 2)
    k = a[0]
    for e in seq(a[1]):
        if isinstance(e, list) and e:
            if lequal(e[0], k):
                return e
        elif type(e) is Dotted:
            if lequal(e.items[0], k):
                return e
    return None


@bi('subst')
def _subst(I, a):
    argn(a, 3, 3)
    new, old, lst = a
    return L(new if lequal(e, old) else e for e in seq(lst))


@bi('vl-position')
def _vl_position(I, a):
    argn(a, 2, 2)
    for i, e in enumerate(seq(a[1])):
        if lequal(e, a[0]):
            return i
    return None


@bi('vl-remove')
def _vl_remove(I, a):
    argn(a, 2, 2)
    return L(e for e in seq(a[1]) if not lequal(e, a[0]))


@bi('vl-remove-if')
def _vl_remove_if(I, a):
    argn(a, 2, 2)
    f = I.fn_of(a[0])
    return L(e for e in seq(a[1]) if I.call(f, [e]) is None)


@bi('vl-remove-if-not')
def _vl_remove_if_not(I, a):
    argn(a, 2, 2)
    f = I.fn_of(a[0])
    return L(e for e in seq(a[1]) if I.call(f, [e]) is not None)


@bi('vl-member-if')
def _vl_member_if(I, a):
    argn(a, 2, 2)
    f = I.fn_of(a[0])
    lst = seq(a[1])
    for i, e in enumerate(lst):
        if I.call(f, [e]) is not None:
            return lst[i:]
    return None


@bi('vl-member-if-not')
def _vl_member_if_not(I, a):
    argn(a, 2, 2)
    f = I.fn_of(a[0])
    lst = seq(a[1])
    for i, e in enumerate(lst):
        if I.call(f, [e]) is None:
            return lst[i:]
    return None


def _zip_lists(a):
    ls = [seq(x) for x in a]
    n = min(len(x) for x in ls) if ls else 0
    return [[x[i] for x in ls] for i in range(n)]


@bi('vl-some')
def _vl_some(I, a):
    argn(a, 2)
    f = I.fn_of(a[0])
    for args in _zip_lists(a[1:]):
        r = I.call(f, args)
        if r is not None:
            return r
    return None


@bi('vl-every')
def _vl_every(I, a):
    argn(a, 2)
    f = I.fn_of(a[0])
    for args in _zip_lists(a[1:]):
        if I.call(f, args) is None:
            return None
    return T


@bi('mapcar')
def _mapcar(I, a):
    argn(a, 2)
    f = I.fn_of(a[0])
    return L(I.call(f, args) for args in _zip_lists(a[1:]))


@bi('apply')
def _apply(I, a):
    argn(a, 2, 2)
    return I.call(I.fn_of(a[0]), list(seq(a[1])))


def _sorter(I, f):
    def cmpf(x, y):
        if I.call(f, [x, y]) is not None:
            return -1
        if I.call(f, [y, x]) is not None:
            return 1
        return 0
    return functools.cmp_to_key(cmpf)


@bi('vl-sort')
def _vl_sort(I, a):
    argn(a, 2, 2)
    f = I.fn_of(a[1])
    lst = sorted(seq(a[0]), key=_sorter(I, f))
    out = []
    for e in lst:
        if out and type(e) is int and type(out[-1]) is int and e == out[-1]:
            I.warn('vl-sort で重複する整数が削除されました（AutoCAD と同じ挙動。重複を残すなら vl-sort-i を使う）')
            continue
        out.append(e)
    return L(out)


@bi('vl-sort-i')
def _vl_sort_i(I, a):
    argn(a, 2, 2)
    f = I.fn_of(a[1])
    lst = seq(a[0])
    k = _sorter(I, f)
    idx = sorted(range(len(lst)), key=lambda i: k(lst[i]))
    return L(idx)


@bi('acad_strlsort')
def _acad_strlsort(I, a):
    argn(a, 1, 1)
    lst = seq(a[0])
    if not all(type(s) is str for s in lst):
        return None
    return L(sorted(lst, key=lambda s: s.upper()))


@bi('listp')
def _listp(I, a):
    argn(a, 1, 1)
    return truth(a[0] is None or isinstance(a[0], list) or type(a[0]) is Dotted)


@bi('vl-consp')
def _vl_consp(I, a):
    argn(a, 1, 1)
    return truth(isinstance(a[0], list) or type(a[0]) is Dotted)


@bi('atom')
def _atom(I, a):
    argn(a, 1, 1)
    return truth(not (isinstance(a[0], list) or type(a[0]) is Dotted))


@bi('null not')
def _null(I, a):
    argn(a, 1, 1)
    return truth(a[0] is None)


@bi('type')
def _type(I, a):
    argn(a, 1, 1)
    x = a[0]
    if x is None:
        return None
    t = type(x)
    nm = {int: 'INT', float: 'REAL', str: 'STR', Sym: 'SYM', Subr: 'SUBR', Special: 'SUBR', UFunc: 'USUBR',
          Ename: 'ENAME', PickSet: 'PICKSET', LFile: 'FILE', VlaObj: 'VLA-OBJECT', Variant: 'VARIANT',
          SafeArray: 'SAFEARRAY', Dotted: 'LIST', CatchErr: 'VL-CATCH-ALL-APPLY-ERROR'}.get(t)
    if nm is None and isinstance(x, list):
        nm = 'LIST'
    return S(nm or 'UNKNOWN')


@bi('boundp')
def _boundp(I, a):
    argn(a, 1, 1)
    return truth(I.g.get(symp(a[0])) is not None)


@bi('vl-symbolp')
def _vl_symbolp(I, a):
    argn(a, 1, 1)
    return truth(type(a[0]) is Sym)


@bi('vl-symbol-name')
def _vl_symbol_name(I, a):
    argn(a, 1, 1)
    return symp(a[0]).name.upper()


@bi('vl-symbol-value')
def _vl_symbol_value(I, a):
    argn(a, 1, 1)
    return I.g.get(symp(a[0]))


@bi('set')
def _set(I, a):
    argn(a, 2, 2)
    s = symp(a[0])
    if s is T:
        raise LispError('attempt to set constant: T')
    I.g[s] = a[1]
    return a[1]


@bi('eval')
def _eval(I, a):
    argn(a, 1, 1)
    return I.ev(a[0])


@bi('read')
def _read(I, a):
    argn(a, 0, 1)
    if not a or a[0] is None:
        return None
    s = strp(a[0])
    try:
        fs = read_all(s, '<read>')
    except ParseError as e:
        raise LispError('malformed list on input')
    return fs[0][0] if fs else None


@bi('atoms-family')
def _atoms_family(I, a):
    argn(a, 1, 2)
    fmt = fixn(a[0])
    names = [s for s, v in I.g.items() if v is not None]
    if len(a) > 1 and a[1] is not None:
        want = [strp(x).lower() for x in seq(a[1])]
        res = [(S(w) if fmt == 0 else w.upper()) if I.g.get(S(w)) is not None else None for w in want]
        return L(res)
    return L((s if fmt == 0 else s.name.upper()) for s in names)


@bi('vl-catch-all-apply')
def _vl_catch_all_apply(I, a):
    argn(a, 1, 2)
    f = I.fn_of(a[0])
    args = list(seq(a[1])) if len(a) > 1 else []
    I.catch_depth += 1
    try:
        return I.call(f, args)
    except LispError as e:
        return CatchErr(e.msg)
    finally:
        I.catch_depth -= 1


@bi('vl-catch-all-error-p')
def _vl_catch_all_error_p(I, a):
    argn(a, 1, 1)
    return truth(type(a[0]) is CatchErr)


@bi('vl-catch-all-error-message')
def _vl_catch_all_error_message(I, a):
    argn(a, 1, 1)
    if type(a[0]) is not CatchErr:
        raise LispError('bad argument type: vl-catch-all-apply-error: ' + short(a[0]))
    return a[0].msg


@bi('exit quit')
def _exit(I, a):
    raise LispError('quit / exit abort')


@bi('vl-exit-with-error')
def _vl_exit_with_error(I, a):
    raise LispError(strp(a[0]) if a else 'quit / exit abort')


@bi('vl-exit-with-value')
def _vl_exit_with_value(I, a):
    raise LispError('quit / exit abort')


@bi('defun-q-list-ref')
def _defun_q_list_ref(I, a):
    argn(a, 1, 1)
    f = I.g.get(symp(a[0]))
    if type(f) is UFunc:
        pl = f.params + ([S('/')] + f.locals if f.locals else [])
        return [L(pl)] + list(f.body)
    return f if isinstance(f, list) else None


@bi('defun-q-list-set')
def _defun_q_list_set(I, a):
    argn(a, 2, 2)
    s = symp(a[0])
    lst = seq(a[1])
    ps, ls = parse_params(lst[0] if lst else None)
    I.g[s] = UFunc(s.name.upper(), ps, ls, lst[1:])
    return s


# =====================================================================
#  組み込み関数：文字列
# =====================================================================
@bi('strcat')
def _strcat(I, a):
    return ''.join(strp(x) for x in a)


@bi('strlen')
def _strlen(I, a):
    return sum(len(strp(x)) for x in a)


@bi('substr')
def _substr(I, a):
    argn(a, 2, 3)
    s = strp(a[0])
    st = fixn(a[1])
    if st < 1:
        raise LispError('bad argument value: positive: ' + str(st))
    if len(a) > 2 and a[2] is not None:
        n = fixn(a[2])
        if n < 0:
            raise LispError('bad argument value: non-negative: ' + str(n))
        return s[st - 1:st - 1 + n]
    return s[st - 1:]


@bi('strcase')
def _strcase(I, a):
    argn(a, 1, 2)
    s = strp(a[0])
    return s.lower() if len(a) > 1 and a[1] is not None else s.upper()


@bi('ascii')
def _ascii(I, a):
    argn(a, 1, 1)
    s = strp(a[0])
    return ord(s[0]) if s else 0


@bi('chr')
def _chr(I, a):
    argn(a, 1, 1)
    n = fixn(a[0])
    try:
        return chr(n) if n > 0 else ''
    except (ValueError, OverflowError):
        return ''


@bi('atoi')
def _atoi(I, a):
    argn(a, 1, 1)
    m = re.match(r'\s*([+-]?\d+)', strp(a[0]))
    return wrap32(int(m.group(1))) if m else 0


@bi('atof')
def _atof(I, a):
    argn(a, 1, 1)
    m = re.match(r'\s*([+-]?(\d+\.?\d*|\.\d+)([eE][+-]?\d+)?)', strp(a[0]))
    return float(m.group(1)) if m else 0.0


@bi('itoa')
def _itoa(I, a):
    argn(a, 1, 1)
    return str(fixn(a[0]))


def _sv(I, name, dflt):
    v = I.sysvars.get(name.upper(), dflt)
    return v if v is not None else dflt


def fmt_fixed(v, prec):
    """小数 prec 桁（四捨五入。Python の偶数丸めではなく AutoCAD と同じ切り上げ）"""
    from decimal import Decimal, ROUND_HALF_UP
    if v != v or v in (float('inf'), float('-inf')):
        return fmt_real(v)
    q = Decimal(1).scaleb(-prec)
    return str(Decimal(v).quantize(q, rounding=ROUND_HALF_UP))


def fmt_sci(v, prec):
    from decimal import Decimal, ROUND_HALF_UP
    if v == 0:
        return '%.*fE+00' % (prec, 0.0)
    d = Decimal(v)
    e = d.adjusted()
    m = (d.scaleb(-e)).quantize(Decimal(1).scaleb(-prec), rounding=ROUND_HALF_UP)
    if abs(m) >= 10:
        e += 1
        m = (d.scaleb(-e)).quantize(Decimal(1).scaleb(-prec), rounding=ROUND_HALF_UP)
    return '%sE%s%02d' % (m, '+' if e >= 0 else '-', abs(e))


def zero_suppress(s, dz):
    if dz & 8 and '.' in s and 'E' not in s:
        s = s.rstrip('0').rstrip('.')
        if s in ('', '-'):
            s = '0'
    if dz & 4:
        if s.startswith('0.'):
            s = s[1:]
        elif s.startswith('-0.'):
            s = '-' + s[2:]
    return s


def _frac(v, prec):
    den = 2 ** max(0, min(prec, 8))
    whole = int(math.floor(v))
    n = int(round((v - whole) * den))
    if n == den:
        whole += 1
        n = 0
    if n == 0:
        return '%d' % whole
    g = math.gcd(n, den)
    return '%d %d/%d' % (whole, n // g, den // g) if whole else '%d/%d' % (n // g, den // g)


@bi('rtos')
def _rtos(I, a):
    argn(a, 1, 3)
    v = float(num(a[0]))
    mode = fixn(a[1]) if len(a) > 1 and a[1] is not None else int(_sv(I, 'LUNITS', 2))
    prec = fixn(a[2]) if len(a) > 2 and a[2] is not None else int(_sv(I, 'LUPREC', 4))
    prec = max(0, min(prec, 8))
    dz = int(_sv(I, 'DIMZIN', 0))
    neg = v < 0
    if mode == 1:
        s = fmt_sci(v, prec)
    elif mode == 2:
        s = zero_suppress(fmt_fixed(v, prec), dz)
    elif mode in (3, 4):
        av = abs(v)
        ft = int(av // 12)
        inch = av - ft * 12
        if mode == 3:
            s = "%d'-%s\"" % (ft, zero_suppress(fmt_fixed(inch, prec), dz))
        else:
            s = "%d'-%s\"" % (ft, _frac(inch, prec))
        if neg:
            s = '-' + s
    elif mode == 5:
        s = ('-' if neg else '') + _frac(abs(v), prec)
    else:
        raise LispError('bad argument value: ' + str(mode))
    if s.startswith('-') and re.fullmatch(r'-[0.]*', s):
        s = s[1:]
    return s


@bi('angtos')
def _angtos(I, a):
    argn(a, 1, 3)
    ang = float(num(a[0]))
    mode = fixn(a[1]) if len(a) > 1 and a[1] is not None else int(_sv(I, 'AUNITS', 0))
    prec = fixn(a[2]) if len(a) > 2 and a[2] is not None else int(_sv(I, 'AUPREC', 0))
    deg = math.degrees(ang_norm(ang))
    if deg >= 360 - 1e-10:
        deg = 0.0
    if mode == 0:
        return zero_suppress(fmt_fixed(deg, prec), int(_sv(I, 'DIMAZIN', 0)))
    if mode == 1:
        d = int(deg)
        mf = (deg - d) * 60
        m = int(mf)
        sec = (mf - m) * 60
        if prec <= 0:
            return '%dd' % int(round(deg))
        if prec <= 2:
            return "%dd%d'" % (d, int(round(mf)))
        return "%dd%d'%s\"" % (d, m, ('%.*f' % (max(0, prec - 4), sec)))
    if mode == 2:
        return '%.*fg' % (prec, deg / 0.9)
    if mode == 3:
        return '%.*fr' % (prec, math.radians(deg))
    if mode == 4:
        return 'N %.*fd E' % (prec, deg)
    raise LispError('bad argument value: ' + str(mode))


@bi('distof')
def _distof(I, a):
    argn(a, 1, 2)
    s = strp(a[0]).strip()
    m = re.fullmatch(r"([+-]?\d+(?:\.\d*)?)'\s*-?\s*(\d+(?:\.\d*)?)?\s*(?:(\d+)/(\d+))?\"?", s)
    if m and "'" in s:
        v = float(m.group(1)) * 12 + float(m.group(2) or 0)
        if m.group(3):
            v += float(m.group(3)) / float(m.group(4))
        return v
    m = re.fullmatch(r'([+-]?\d+)\s+(\d+)/(\d+)', s)
    if m:
        return float(m.group(1)) + float(m.group(2)) / float(m.group(3))
    try:
        return float(s)
    except ValueError:
        return None


@bi('angtof')
def _angtof(I, a):
    argn(a, 1, 2)
    s = strp(a[0]).strip().lower()
    mode = fixn(a[1]) if len(a) > 1 and a[1] is not None else int(_sv(I, 'AUNITS', 0))
    m = re.fullmatch(r"([+-]?\d+(?:\.\d*)?)d(?:(\d+(?:\.\d*)?)')?(?:(\d+(?:\.\d*)?)\")?", s)
    if m:
        return math.radians(float(m.group(1)) + float(m.group(2) or 0) / 60 + float(m.group(3) or 0) / 3600)
    try:
        if s.endswith('r'):
            return float(s[:-1])
        if s.endswith('g'):
            return math.radians(float(s[:-1]) * 0.9)
        v = float(s)
    except ValueError:
        return None
    if mode == 3:
        return v
    if mode == 2:
        return math.radians(v * 0.9)
    return math.radians(v)


@bi('wcmatch')
def _wcmatch(I, a):
    argn(a, 2, 2)
    return truth(wcmatch(strp(a[0]), strp(a[1])))


@bi('vl-string-search')
def _vl_string_search(I, a):
    argn(a, 2, 3)
    p, s = strp(a[0]), strp(a[1])
    st = fixn(a[2]) if len(a) > 2 and a[2] is not None else 0
    i = s.find(p, st)
    return i if i >= 0 else None


@bi('vl-string-subst')
def _vl_string_subst(I, a):
    argn(a, 3, 4)
    new, pat, s = strp(a[0]), strp(a[1]), strp(a[2])
    st = fixn(a[3]) if len(a) > 3 and a[3] is not None else 0
    i = s.find(pat, st)
    if i < 0:
        return s
    return s[:i] + new + s[i + len(pat):]


@bi('vl-string-translate')
def _vl_string_translate(I, a):
    argn(a, 3, 3)
    src, dst, s = strp(a[0]), strp(a[1]), strp(a[2])
    out = []
    for ch in s:
        i = src.find(ch)
        if i >= 0:
            out.append(dst[i] if i < len(dst) else (dst[-1] if dst else ch))
        else:
            out.append(ch)
    return ''.join(out)


@bi('vl-string-trim')
def _vl_string_trim(I, a):
    argn(a, 2, 2)
    return strp(a[1]).strip(strp(a[0]))


@bi('vl-string-left-trim')
def _vl_string_left_trim(I, a):
    argn(a, 2, 2)
    return strp(a[1]).lstrip(strp(a[0]))


@bi('vl-string-right-trim')
def _vl_string_right_trim(I, a):
    argn(a, 2, 2)
    return strp(a[1]).rstrip(strp(a[0]))


@bi('vl-string-position')
def _vl_string_position(I, a):
    argn(a, 2, 4)
    ch = chr(fixn(a[0]))
    s = strp(a[1])
    st = fixn(a[2]) if len(a) > 2 and a[2] is not None else None
    fromend = len(a) > 3 and a[3] is not None
    if fromend:
        i = s.rfind(ch, 0, (st + 1) if st is not None else len(s))
    else:
        i = s.find(ch, st or 0)
    return i if i >= 0 else None


@bi('vl-string-elt')
def _vl_string_elt(I, a):
    argn(a, 2, 2)
    s = strp(a[0])
    i = fixn(a[1])
    if i < 0 or i >= len(s):
        raise LispError('bad argument value: string position out of range ' + str(i))
    return ord(s[i])


@bi('vl-string->list')
def _vl_string_to_list(I, a):
    argn(a, 1, 1)
    return L(ord(c) for c in strp(a[0]))


@bi('vl-list->string')
def _vl_list_to_string(I, a):
    argn(a, 1, 1)
    return ''.join(chr(fixn(c)) for c in seq(a[0]))


@bi('vl-string-mismatch')
def _vl_string_mismatch(I, a):
    argn(a, 2, 5)
    s1, s2 = strp(a[0]), strp(a[1])
    p1 = fixn(a[2]) if len(a) > 2 and a[2] is not None else 0
    p2 = fixn(a[3]) if len(a) > 3 and a[3] is not None else 0
    ic = len(a) > 4 and a[4] is not None
    s1, s2 = s1[p1:], s2[p2:]
    if ic:
        s1, s2 = s1.lower(), s2.lower()
    n = 0
    while n < len(s1) and n < len(s2) and s1[n] == s2[n]:
        n += 1
    return n


@bi('vl-prin1-to-string')
def _vl_prin1_to_string(I, a):
    argn(a, 1, 1)
    return lstr(a[0], True)


@bi('vl-princ-to-string')
def _vl_princ_to_string(I, a):
    argn(a, 1, 1)
    return lstr(a[0], False)


@bi('snvalid')
def _snvalid(I, a):
    argn(a, 1, 2)
    s = strp(a[0])
    if not s or re.search(r'[<>/\\":;?*|,=`]', s) or s != s.strip():
        return None
    return T


@bi('xstrcase')
def _xstrcase(I, a):
    argn(a, 1, 1)
    return strp(a[0]).upper()




# =====================================================================
#  DXF 読み書き
# =====================================================================
POINT_CODES = set(range(10, 19)) | {110, 111, 112, 210} | set(range(1010, 1014))
PTR_CODES = set(range(330, 370)) | set(range(390, 400)) | {480, 481}
PAD3_TYPES = {'LINE', 'POINT', 'CIRCLE', 'ARC', 'TEXT', 'ATTRIB', 'ATTDEF', 'INSERT', 'MTEXT', 'SOLID', 'TRACE',
              '3DFACE', 'ELLIPSE', 'VERTEX', 'POLYLINE', 'XLINE', 'RAY', 'SPLINE', 'DIMENSION', 'LEADER', 'BLOCK'}
SUB_ENT_TYPES = {'ATTRIB', 'VERTEX', 'SEQEND'}
TABLE_TYPES = {'LAYER', 'LTYPE', 'STYLE', 'DIMSTYLE', 'APPID', 'UCS', 'VIEW', 'VPORT', 'BLOCK_RECORD'}
CODEPAGES = {'ANSI_932': 'cp932', 'ANSI_1252': 'cp1252', 'ANSI_936': 'gbk', 'ANSI_949': 'cp949',
             'ANSI_950': 'cp950', 'ANSI_1250': 'cp1250', 'ANSI_1251': 'cp1251', 'ANSI_1253': 'cp1253',
             'ANSI_1254': 'cp1254', 'ANSI_1255': 'cp1255', 'ANSI_1256': 'cp1256', 'ANSI_1257': 'cp1257',
             'ANSI_874': 'cp874', 'DOS932': 'cp932', 'UTF8': 'utf-8'}


def gc_type(c):
    if 10 <= c <= 59 or 110 <= c <= 149 or 210 <= c <= 239 or 460 <= c <= 469 or 1010 <= c <= 1059:
        return 'f'
    if 60 <= c <= 99 or 160 <= c <= 179 or 270 <= c <= 299 or 370 <= c <= 389 or 400 <= c <= 409 \
            or 420 <= c <= 429 or 440 <= c <= 459 or 1060 <= c <= 1071 or c in (-4,):
        return 'i'
    return 's'


def conv_val(c, v):
    t = gc_type(c)
    if t == 'f':
        try:
            return float(v.strip())
        except ValueError:
            return 0.0
    if t == 'i':
        try:
            return int(v.strip())
        except ValueError:
            try:
                return int(float(v.strip()))
            except ValueError:
                return 0
    return v


def merge_points(pairs):
    out = []
    i = 0
    n = len(pairs)
    while i < n:
        c, v = pairs[i]
        if c in POINT_CODES and type(v) is float and i + 1 < n and pairs[i + 1][0] == c + 10:
            y = pairs[i + 1][1]
            if i + 2 < n and pairs[i + 2][0] == c + 20:
                out.append((c, (v, float(y), float(pairs[i + 2][1]))))
                i += 3
            else:
                out.append((c, (v, float(y))))
                i += 2
            continue
        out.append((c, v))
        i += 1
    return out


class DObj:
    __slots__ = ('p', 'deleted', 'h', 'sec')

    def __init__(self, pairs, sec):
        self.p = pairs
        self.deleted = False
        self.h = None
        self.sec = sec

    @property
    def typ(self):
        return str(self.p[0][1]).upper() if self.p else ''

    def get(self, code, dflt=None):
        for c, v in self.p:
            if c == code:
                return v
        return dflt

    def getall(self, code):
        return [v for c, v in self.p if c == code]

    def set(self, code, val):
        for i, (c, v) in enumerate(self.p):
            if c == code:
                self.p[i] = (code, val)
                return
        self.p.append((code, val))

    def main(self):
        k = xdata_start(self.p)
        return self.p[:k]


def xdata_start(p):
    for i, (c, v) in enumerate(p):
        if c == 1001:
            return i
    return len(p)


class Drawing:
    def __init__(self):
        self.path = None
        self.name = 'Drawing1.dwg'
        self.enc = 'utf-8'
        self.version = 'AC1024'
        self.modern = True
        self.header = []          # [(code, value)] 点は結合済み
        self.sections = []        # [[name, content]]
        self.by_h = {}
        self.syn = 0
        self.handseed = 1
        self._blocks = None
        self.warnings = []
        self.force_enc = None

    # ------------------------------------------------------------ 読込
    @classmethod
    def load(cls, path, enc=None):
        raw = open(path, 'rb').read()
        d = cls()
        d.force_enc = enc
        d.path = path
        d.name = os.path.splitext(os.path.basename(path))[0] + '.dwg'
        d._parse(raw)
        return d

    @classmethod
    def blank(cls):
        d = cls()
        d._parse(zlib.decompress(base64.b64decode(BLANK_DXF)))
        return d

    def _parse(self, raw):
        if raw.startswith(b'AutoCAD Binary DXF'):
            raise ValueError('バイナリDXFには対応していません。ASCII形式のDXFで保存してください')
        head = raw[:400000].decode('latin-1')
        m = re.search(r'\$ACADVER\s*\r?\n\s*1\s*\r?\n\s*(\S+)', head)
        self.version = m.group(1).strip() if m else 'AC1009'
        m2 = re.search(r'\$DWGCODEPAGE\s*\r?\n\s*3\s*\r?\n\s*(\S+)', head)
        if raw.startswith(b'\xef\xbb\xbf'):
            raw = raw[3:]
            self.enc = 'utf-8'
        elif self.version >= 'AC1021':
            self.enc = 'utf-8'
        else:
            self.enc = CODEPAGES.get(m2.group(1).strip().upper(), 'cp1252') if m2 else 'cp1252'
        if self.force_enc:
            self.enc = self.force_enc
        elif self.enc != 'utf-8' and re.search(rb'[\x80-\xff]', raw):
            # 宣言と実際の文字コードが違うファイル対策（UTF-8 / Shift_JIS を推定）
            for cand in ('utf-8', 'cp932'):
                if cand == self.enc:
                    break
                try:
                    t = raw.decode(cand)
                except UnicodeDecodeError:
                    continue
                hi = [ch for ch in t if ord(ch) > 127]
                cjk = [ch for ch in hi if ord(ch) >= 0x3000]
                if cand == 'utf-8' or (hi and len(cjk) >= len(hi) * 0.6):
                    self.warnings.append('DXFの文字コード宣言(%s)と中身が違うため %s として読みました' % (self.enc, cand))
                    self.enc = cand
                    break
        self.modern = self.version >= 'AC1012'
        text = raw.decode(self.enc, errors='replace')
        lines = text.replace('\r\n', '\n').replace('\r', '\n').split('\n')
        pairs = []
        for i in range(0, len(lines) - 1, 2):
            cs = lines[i].strip()
            if not cs:
                continue
            try:
                c = int(cs)
            except ValueError:
                raise ValueError('DXFの解析に失敗しました（%d行目: グループコードが数値ではない %r）' % (i + 1, cs[:20]))
            pairs.append((c, lines[i + 1]))
        i = 0
        n = len(pairs)
        while i < n:
            c, v = pairs[i]
            if c == 0 and v.strip() == 'SECTION' and i + 1 < n:
                name = pairs[i + 1][1].strip()
                j = i + 2
                body = []
                while j < n and not (pairs[j][0] == 0 and pairs[j][1].strip() == 'ENDSEC'):
                    body.append(pairs[j])
                    j += 1
                self._add_section(name, body)
                i = j + 1
            elif c == 0 and v.strip() == 'EOF':
                break
            else:
                i += 1
        if not any(s[0] == 'ENTITIES' for s in self.sections):
            self.sections.append(['ENTITIES', []])
        mx = 0
        for h in self.by_h:
            try:
                mx = max(mx, int(h, 16))
            except ValueError:
                pass
        self.handseed = mx + 1

    def _add_section(self, name, body):
        conv = []
        for c, v in body:
            t = gc_type(c)
            if t == 's':
                v = v.rstrip('\r')
                if c not in (1, 3, 1000, 2, 7, 4, 6, 8, 300, 301, 302, 303, 304, 305, 306, 307, 308, 309):
                    v = v.strip()
            conv.append((c, conv_val(c, v) if t != 's' else v))
        if name == 'HEADER':
            self.header = merge_points(conv)
            self.sections.append([name, 'HEADER'])
            return
        if name not in ('CLASSES', 'TABLES', 'BLOCKS', 'ENTITIES', 'OBJECTS'):
            self.sections.append([name, ('RAW', conv)])
            return
        objs = []
        cur = None
        for c, v in conv:
            if c == 0:
                cur = []
                objs.append(cur)
            if cur is None:
                continue
            cur.append((c, v))
        lst = []
        for p in objs:
            o = DObj(merge_points(p), name)
            self.register(o)
            lst.append(o)
        self.sections.append([name, lst])

    def register(self, o):
        h = o.get(105) if o.typ == 'DIMSTYLE' else o.get(5)
        if not h:
            self.syn += 1
            h = '~%d' % self.syn
        h = str(h).strip().upper()
        o.h = h
        self.by_h[h] = o

    def new_handle(self):
        h = '%X' % self.handseed
        self.handseed += 1
        return h

    # ------------------------------------------------------------ アクセス
    def sec(self, name, create=True):
        for s in self.sections:
            if s[0] == name:
                return s[1]
        if not create:
            return None
        lst = []
        # ENTITIES は OBJECTS の前に置く
        idx = len(self.sections)
        order = ['HEADER', 'CLASSES', 'TABLES', 'BLOCKS', 'ENTITIES', 'OBJECTS']
        if name in order:
            for i, s in enumerate(self.sections):
                if s[0] in order and order.index(s[0]) > order.index(name):
                    idx = i
                    break
        self.sections.insert(idx, [name, lst])
        return lst

    def ents(self):
        return self.sec('ENTITIES')

    def get(self, h):
        if h is None:
            return None
        return self.by_h.get(str(h).upper())

    def hvar(self, name, dflt=None):
        name = name.upper()
        for i, (c, v) in enumerate(self.header):
            if c == 9 and str(v).upper() == name:
                vals = []
                for c2, v2 in self.header[i + 1:]:
                    if c2 == 9:
                        break
                    vals.append((c2, v2))
                if len(vals) == 1:
                    return vals[0][1]
                return vals or dflt
        return dflt

    def hvar_set(self, name, val):
        name = name.upper()
        for i, (c, v) in enumerate(self.header):
            if c == 9 and str(v).upper() == name and i + 1 < len(self.header):
                c2, v2 = self.header[i + 1]
                if type(v2) is tuple and isinstance(val, (list, tuple)):
                    val = tuple(float(x) for x in val)[:len(v2)] if len(val) >= len(v2) else to_pt3(val)
                elif type(v2) is float and isnum(val):
                    val = float(val)
                elif type(v2) is int and isnum(val):
                    val = int(val)
                elif type(v2) is str and type(val) is not str:
                    return False
                self.header[i + 1] = (c2, val)
                return True
        return False

    def all_header_vars(self):
        out = {}
        for i, (c, v) in enumerate(self.header):
            if c == 9 and str(v).startswith('$'):
                if i + 1 < len(self.header) and self.header[i + 1][0] != 9:
                    out[str(v)[1:].upper()] = self.header[i + 1][1]
        return out

    # ------------------------------------------------------------ テーブル
    def table(self, tname):
        tname = tname.upper()
        lst = self.sec('TABLES', create=False) or []
        tobj = None
        recs = []
        inside = False
        for o in lst:
            t = o.typ
            if t == 'TABLE':
                inside = str(o.get(2, '')).upper() == tname
                if inside:
                    tobj = o
                continue
            if t == 'ENDTAB':
                if inside:
                    break
                continue
            if inside and not o.deleted:
                recs.append(o)
        return tobj, recs

    def records(self, tname):
        return self.table(tname)[1]

    def find_rec(self, tname, name):
        name = str(name).upper()
        for o in self.records(tname):
            if str(o.get(2, '')).upper() == name:
                return o
        return None

    def add_record(self, tname, pairs):
        tname = tname.upper()
        lst = self.sec('TABLES')
        tobj, recs = self.table(tname)
        if tobj is None:
            tobj = DObj([(0, 'TABLE'), (2, tname), (70, 0)], 'TABLES')
            if self.modern:
                tobj.p = [(0, 'TABLE'), (2, tname), (5, self.new_handle()), (330, '0'),
                          (100, 'AcDbSymbolTable'), (70, 0)]
            self.register(tobj)
            lst.append(tobj)
            end = DObj([(0, 'ENDTAB')], 'TABLES')
            self.register(end)
            lst.append(end)
        o = DObj(pairs, 'TABLES')
        self.register(o)
        i = lst.index(tobj) + 1
        while i < len(lst) and lst[i].typ != 'ENDTAB':
            i += 1
        lst.insert(i, o)
        cnt = tobj.get(70, 0)
        tobj.set(70, (cnt or 0) + 1)
        self._blocks = None
        return o

    def make_layer(self, name, color=7, ltype='Continuous'):
        if self.find_rec('LAYER', name):
            return self.find_rec('LAYER', name)
        base = self.find_rec('LAYER', '0')
        if self.modern:
            tobj, _ = self.table('LAYER')
            pairs = [(0, 'LAYER'), (5, self.new_handle()), (330, tobj.h if tobj else '0'),
                     (100, 'AcDbSymbolTableRecord'), (100, 'AcDbLayerTableRecord'),
                     (2, name), (70, 0), (62, color), (6, ltype), (370, -3)]
            if base is not None and base.get(390) is not None:
                pairs.append((390, base.get(390)))
            if base is not None and base.get(347) is not None:
                pairs.append((347, base.get(347)))
        else:
            pairs = [(0, 'LAYER'), (2, name), (70, 0), (62, color), (6, ltype)]
        return self.add_record('LAYER', pairs)

    def space_owner(self, paper=False):
        want = '*PAPER_SPACE' if paper else '*MODEL_SPACE'
        r = self.find_rec('BLOCK_RECORD', want)
        return r.h if r is not None else '0'

    # ------------------------------------------------------------ ブロック
    def blocks(self):
        """{名前(大文字): {'name','block','ents','end','rec'}}"""
        if self._blocks is not None:
            return self._blocks
        res = {}
        cur = None
        for o in (self.sec('BLOCKS', create=False) or []):
            t = o.typ
            if t == 'BLOCK':
                nm = str(o.get(2, ''))
                cur = {'name': nm, 'block': o, 'ents': [], 'end': None, 'rec': self.find_rec('BLOCK_RECORD', nm)}
                if not o.deleted:
                    res[nm.upper()] = cur
            elif t == 'ENDBLK':
                if cur is not None:
                    cur['end'] = o
                cur = None
            elif cur is not None:
                cur['ents'].append(o)
        self._blocks = res
        return res

    def container_of(self, o):
        if o.sec == 'ENTITIES':
            return self.ents()
        if o.sec == 'BLOCKS':
            for b in self.blocks().values():
                if o in b['ents']:
                    return b['ents']
        return None

    # ------------------------------------------------------------ 書出し
    def snapshot(self):
        return {h: (o.deleted, list(o.p), o.sec) for h, o in self.by_h.items()}

    def write(self, path):
        lines = []
        ap = lines.append

        def enc_val(c, v):
            if type(v) is float:
                if v == int(v) and abs(v) < 1e15:
                    return '%.1f' % v
                return repr(v)
            if type(v) is int:
                return str(v)
            if type(v) is bool:
                return '1' if v else '0'
            return str(v)

        def put(c, v):
            if type(v) is tuple and c in POINT_CODES:
                put(c, v[0])
                put(c + 10, v[1])
                if len(v) > 2:
                    put(c + 20, v[2])
                return
            ap('%3d' % c)
            ap(enc_val(c, v))

        mx = 0
        for h in self.by_h:
            try:
                mx = max(mx, int(h, 16))
            except ValueError:
                pass
        self.handseed = max(self.handseed, mx + 1)
        self.hvar_set('$HANDSEED', '%X' % self.handseed)
        if self.enc.lower().replace('-', '') != 'utf8' and self.version < 'AC1021':
            inv = dict((v, k) for k, v in CODEPAGES.items() if k.startswith('ANSI'))
            if self.enc in inv:
                self.hvar_set('$DWGCODEPAGE', inv[self.enc])
        for name, content in self.sections:
            put(0, 'SECTION')
            put(2, name)
            if content == 'HEADER':
                for c, v in self.header:
                    put(c, v)
            elif isinstance(content, tuple):
                for c, v in content[1]:
                    put(c, v)
            else:
                for o in content:
                    if o.deleted:
                        continue
                    if not self.modern and o.typ == 'LWPOLYLINE':
                        for pairs in lwpoly_to_r12(o):
                            for c, v in pairs:
                                put(c, v)
                        continue
                    for c, v in o.p:
                        put(c, v)
            put(0, 'ENDSEC')
        put(0, 'EOF')
        text = '\r\n'.join(lines) + '\r\n'
        if self.enc.lower().replace('-', '') == 'utf8':
            data = text.encode('utf-8')
        else:
            data = text.encode(self.enc, errors='dxfescape')
        with open(path, 'wb') as f:
            f.write(data)


def lwpoly_to_r12(o):
    """R12 形式の図面では LWPOLYLINE を POLYLINE+VERTEX+SEQEND に変換して書く"""
    common = [(c, v) for c, v in o.main() if c in (8, 6, 62, 39, 67)]
    elev = o.get(38, 0.0)
    out = [[(0, 'POLYLINE')] + common + [(66, 1), (10, (0.0, 0.0, elev)), (70, o.get(70, 0) & 1)]]
    if o.get(43):
        out[0] += [(40, o.get(43)), (41, o.get(43))]
    for v in lwpoly_verts(o):
        vp = [(0, 'VERTEX')] + [(c, val) for c, val in common if c == 8] + [(10, (v['pt'][0], v['pt'][1], elev))]
        if v['sw'] or v['ew']:
            vp += [(40, v['sw']), (41, v['ew'])]
        if v['b']:
            vp.append((42, v['b']))
        out.append(vp)
    out.append([(0, 'SEQEND')] + [(c, val) for c, val in common if c == 8])
    return out


def _dxf_escape(err):
    s = err.object[err.start:err.end]
    return (''.join('\\U+%04X' % ord(ch) for ch in s), err.end)


import codecs as _codecs
_codecs.register_error('dxfescape', _dxf_escape)


# --------------------------------------------------------------- システム変数
DEFAULT_SYSVARS = {
    'OSMODE': 4133, 'CMDECHO': 1, 'CLAYER': '0', 'CECOLOR': 'BYLAYER', 'CELTYPE': 'ByLayer', 'CELWEIGHT': -1,
    'TEXTSIZE': 2.5, 'TEXTSTYLE': 'Standard', 'DIMSCALE': 1.0, 'LTSCALE': 1.0, 'INSUNITS': 4, 'LUNITS': 2,
    'LUPREC': 4, 'AUNITS': 0, 'AUPREC': 0, 'DIMZIN': 8, 'DIMAZIN': 0, 'ANGBASE': 0.0, 'ANGDIR': 0,
    'PICKFIRST': 1, 'ATTREQ': 1, 'ATTDIA': 0, 'FILEDIA': 1, 'EXPERT': 0, 'ERRNO': 0, 'CTAB': 'Model',
    'TILEMODE': 1, 'CVPORT': 2, 'PDMODE': 0, 'PDSIZE': 0.0, 'ORTHOMODE': 0, 'SNAPMODE': 0, 'GRIDMODE': 0,
    'NOMUTT': 0, 'QAFLAGS': 0, 'HIGHLIGHT': 1, 'BLIPMODE': 0, 'MIRRTEXT': 0, 'PLINEWID': 0.0,
    'PLINETYPE': 2, 'FILLETRAD': 0.0, 'CHAMFERA': 0.0, 'CHAMFERB': 0.0, 'OFFSETDIST': -1.0,
    'CIRCLERAD': 0.0, 'DELOBJ': 3, 'PEDITACCEPT': 0, 'DYNMODE': 3, 'DYNPROMPT': 1, 'SELECTIONPREVIEW': 3,
    'PICKADD': 2, 'PICKAUTO': 5, 'PICKBOX': 3, 'APERTURE': 10, 'UCSFOLLOW': 0, 'WORLDUCS': 1,
    'UCSORG': [0.0, 0.0, 0.0], 'UCSXDIR': [1.0, 0.0, 0.0], 'UCSYDIR': [0.0, 1.0, 0.0], 'ELEVATION': 0.0,
    'THICKNESS': 0.0, 'LASTPOINT': [0.0, 0.0, 0.0], 'VIEWCTR': [0.0, 0.0, 0.0], 'VIEWSIZE': 100.0,
    'SCREENSIZE': [1600.0, 900.0], 'EXTMIN': [0.0, 0.0, 0.0], 'EXTMAX': [100.0, 100.0, 0.0],
    'LIMMIN': [0.0, 0.0], 'LIMMAX': [420.0, 297.0], 'MEASUREMENT': 1, 'MEASUREINIT': 1,
    'ACADVER': '24.1s (LMS Tech)', 'ACADPREFIX': '', 'PRODUCT': 'AutoCAD', 'PLATFORM': 'Microsoft Windows NT',
    'PROGRAM': 'acad', 'LOCALE': 'JPN', 'SYSCODEPAGE': 'ANSI_932', 'DWGCODEPAGE': 'ANSI_932',
    'SDI': 0, 'LISPINIT': 1, 'SECURELOAD': 1, 'MAXACTVP': 64, 'TRUSTEDPATHS': '', 'CMDACTIVE': 0,
    'CMDNAMES': '', 'UNDOCTL': 5, 'DBMOD': 0, 'SAVETIME': 10, 'TEXTEVAL': 0, 'TEXTFILL': 1,
    'HPNAME': 'ANSI31', 'HPSCALE': 1.0, 'HPANG': 0.0, 'INSNAME': '', 'USERI1': 0, 'USERI2': 0,
    'USERI3': 0, 'USERI4': 0, 'USERI5': 0, 'USERR1': 0.0, 'USERR2': 0.0, 'USERR3': 0.0, 'USERR4': 0.0,
    'USERR5': 0.0, 'USERS1': '', 'USERS2': '', 'USERS3': '', 'USERS4': '', 'USERS5': '',
    'LWDISPLAY': 0, 'LWUNITS': 1, 'CANNOSCALE': '1:1', 'CANNOSCALEVALUE': 1.0, 'MSLTSCALE': 1,
    'PSLTSCALE': 1, 'CLAYOUT': 'Model', 'VISRETAIN': 1, 'XREFCTL': 0, 'REGENMODE': 1,
    'OSNAPCOORD': 2, 'AUTOSNAP': 63, 'POLARMODE': 0, 'TRIMEXTENDMODE': 1, 'EDGEMODE': 0,
    'PROJMODE': 1, 'DIMSTYLE': 'Standard', 'DIMTXT': 2.5, 'DIMASZ': 2.5, 'DIMDEC': 2, 'DIMLFAC': 1.0,
    'CMLSTYLE': 'Standard', 'CMLSCALE': 1.0, 'CMLJUST': 0, 'SPLFRAME': 0, 'SURFTAB1': 6, 'SURFTAB2': 6,
    'OFFSETGAPTYPE': 0, 'TSTACKALIGN': 1, 'MTEXTED': 'Internal', 'FONTALT': 'simplex.shx',
    'LOGINNAME': 'user', 'ROAMABLEROOTPREFIX': '', 'MYDOCUMENTSPREFIX': 'C:\\Users\\user\\Documents',
    'TEMPPREFIX': 'C:\\Temp\\', 'VIEWTWIST': 0.0, 'VIEWDIR': [0.0, 0.0, 1.0], 'WORLDVIEW': 1,
    'HANDSEED': '0', 'MENUNAME': 'ACAD', 'SNAPANG': 0.0, 'SNAPUNIT': [10.0, 10.0], 'GRIDUNIT': [10.0, 10.0],
}
READONLY_SYSVARS = {'ACADVER', 'DWGNAME', 'DWGPREFIX', 'CDATE', 'DATE', 'MILLISECS', 'PRODUCT', 'PLATFORM',
                    'LOGINNAME', 'CMDACTIVE', 'CMDNAMES', 'DBMOD', 'EXTMIN', 'EXTMAX', 'ACADPREFIX',
                    'LOCALE', 'SYSCODEPAGE', 'DWGCODEPAGE', 'SCREENSIZE', 'VIEWCTR', 'VIEWSIZE', 'VIEWDIR',
                    'PROGRAM', 'TEMPPREFIX', 'HANDSEED', 'DWGTITLED'}


def default_sysvars(dwg):
    sv = dict(DEFAULT_SYSVARS)
    for k, v in dwg.all_header_vars().items():
        if k in ('ACADVER', 'HANDSEED'):
            continue
        if type(v) is tuple:
            v = list(v)
        if k == 'CECOLOR' and type(v) is int:
            v = {256: 'BYLAYER', 0: 'BYBLOCK'}.get(v, str(v))
        sv[k] = v
    sv['DWGNAME'] = dwg.name
    sv['DWGPREFIX'] = (os.path.dirname(os.path.abspath(dwg.path)) + '\\') if dwg.path else 'C:\\Users\\user\\Documents\\'
    sv['DWGTITLED'] = 1 if dwg.path else 0
    if dwg.version:
        sv['DWGVERSION'] = dwg.version
    return sv


def sysvar_get(I, name):
    n = name.upper()
    if n == 'CDATE':
        d = datetime.datetime.now()
        return float(d.strftime('%Y%m%d.%H%M%S') + '%02d' % (d.microsecond // 10000))
    if n == 'DATE':
        d = datetime.datetime.now()
        return 2440587.5 + time.time() / 86400.0
    if n == 'MILLISECS':
        return int(time.time() * 1000) & 0x7FFFFFFF
    if n == 'DBMOD':
        return 1 if I.dwg_changed() else 0
    if n == 'EXTMIN' or n == 'EXTMAX':
        bb = drawing_extents(I.dwg)
        if bb:
            return [bb[0], bb[1], 0.0] if n == 'EXTMIN' else [bb[2], bb[3], 0.0]
    if n == 'HANDSEED':
        return '%X' % I.dwg.handseed
    v = I.sysvars.get(n, _UNB)
    if v is _UNB:
        I.warn('未対応/不明なシステム変数 %s を getvar しました（nil を返しました）' % n)
        return None
    return copy_val(v)


# =====================================================================
#  図形データ ⇔ LISP 変換
# =====================================================================
def store_to_lisp(dwg, o, apps=None):
    out = [Dotted([-1], Ename(o.h))]
    t = o.typ
    pad = t in PAD3_TYPES
    k = xdata_start(o.p)
    for c, v in o.p[:k]:
        if type(v) is tuple:
            vv = list(v)
            if pad and len(vv) == 2 and 10 <= c <= 18:
                vv.append(0.0)
            out.append([c] + vv)
        elif c in PTR_CODES and type(v) is str:
            out.append(Dotted([c], Ename(v.upper())))
        else:
            out.append(Dotted([c], v))
    if apps is not None:
        xd = parse_xdata(o.p[k:])
        sel = []
        for app, items in xd:
            if any(wcmatch(app, p, True) for p in apps):
                sel.append([app] + items)
        if sel:
            out.append([-3] + sel)
    return out


def parse_xdata(pairs):
    res = []
    cur = None
    for c, v in pairs:
        if c == 1001:
            cur = []
            res.append((v, cur))
            continue
        if cur is None:
            continue
        if type(v) is tuple:
            cur.append([c] + list(v))
        else:
            cur.append(Dotted([c], v))
    return res


def pair_of(e):
    """LISP の要素 → (code, value)。点は list のまま返す"""
    if type(e) is Dotted and len(e.items) == 1 and type(e.items[0]) is int:
        return e.items[0], e.tail
    if isinstance(e, list) and e and type(e[0]) is int:
        return e[0], e[1:]
    raise LispError('bad DXF group: ' + short(e))


def lisp_val_to_store(c, v, typ=''):
    if type(v) is Ename:
        return v.h
    if isinstance(v, list):
        if c == -3:
            return v
        if all(isnum(x) for x in v) and v:
            vals = tuple(float(x) for x in v)
            if typ == 'LWPOLYLINE' and c == 10:
                vals = vals[:2]
            return vals
        if len(v) == 1:
            v = v[0]
        else:
            raise LispError('bad DXF group: (%d %s)' % (c, short(v)))
    t = gc_type(c)
    if t == 'f' and isnum(v):
        return float(v)
    if t == 'i' and isnum(v):
        return int(v)
    return v


def lisp_to_store(I, lst):
    pairs = []
    xdata = None
    typ = ''
    for e in seq(lst):
        c, v = pair_of(e)
        if c == 0 and type(v) is str:
            typ = v.upper()
        if c == -1 or c == -2:
            continue
        if c == -3:
            xdata = []
            for appl in seq(v):
                appl = seq(appl)
                if not appl or type(appl[0]) is not str:
                    raise LispError('bad xdata: ' + short(appl))
                xdata.append((1001, appl[0]))
                for it in appl[1:]:
                    c2, v2 = pair_of(it)
                    xdata.append((c2, lisp_val_to_store(c2, v2)))
            continue
        pairs.append((c, lisp_val_to_store(c, v, typ)))
    return pairs, xdata


def ename_of(I, x, fn='lentityp'):
    if type(x) is Ename:
        return x
    raise LispError('bad argument type: %s %s' % (fn, short(x)))


def obj_of(I, x):
    e = ename_of(I, x)
    o = I.dwg.get(e.h)
    return o


def xdata_apps_ok(I, xdata):
    ok = True
    for c, v in xdata or []:
        if c == 1001 and not I.dwg.find_rec('APPID', v):
            I.warn('regapp されていないアプリ名 "%s" の拡張データ → AutoCAD では entmod/entmake が失敗します' % v)
            ok = False
    return ok


def ensure_layer(I, name):
    if name is None:
        return
    if not I.dwg.find_rec('LAYER', name):
        I.dwg.make_layer(str(name))
        I.echo('')
        I.warn('存在しない画層 "%s" が指定されたため自動作成しました（AutoCAD と同じ挙動）' % name)


# --------------------------------------------------------------- entmake 用 サブクラス定義
TEXT1 = {39, 10, 40, 1, 50, 41, 51, 7, 71, 72, 11, 210}
SUBCLASS = {
    'LINE': [('AcDbLine', None)],
    'POINT': [('AcDbPoint', None)],
    'CIRCLE': [('AcDbCircle', None)],
    'ARC': [('AcDbCircle', {39, 10, 40, 210}), ('AcDbArc', None)],
    'TEXT': [('AcDbText', TEXT1), ('AcDbText', None)],
    'ATTRIB': [('AcDbText', TEXT1), ('AcDbAttribute', None)],
    'ATTDEF': [('AcDbText', TEXT1), ('AcDbAttributeDefinition', None)],
    'MTEXT': [('AcDbMText', None)],
    'LWPOLYLINE': [('AcDbPolyline', None)],
    'INSERT': [('AcDbBlockReference', None)],
    'ELLIPSE': [('AcDbEllipse', None)],
    'SOLID': [('AcDbTrace', None)],
    'TRACE': [('AcDbTrace', None)],
    '3DFACE': [('AcDbFace', None)],
    'SPLINE': [('AcDbSpline', None)],
    'XLINE': [('AcDbXline', None)],
    'RAY': [('AcDbRay', None)],
    'HATCH': [('AcDbHatch', None)],
    'POLYLINE': [('AcDb2dPolyline', None)],
    'VERTEX': [('AcDbVertex', set()), ('AcDb2dVertex', None)],
    'SEQEND': [],
    'LEADER': [('AcDbLeader', None)],
}
ENT_COMMON = {8, 6, 62, 370, 48, 60, 420, 430, 440, 67, 410, 347, 284, 390, 380}
REQUIRED = {'LINE': (10, 11), 'CIRCLE': (10, 40), 'ARC': (10, 40, 50, 51), 'POINT': (10,), 'TEXT': (10, 1),
            'MTEXT': (10,), 'LWPOLYLINE': (10,), 'INSERT': (2, 10), 'ELLIPSE': (10, 11, 40),
            'ATTRIB': (10, 1, 2), 'ATTDEF': (10, 1, 2, 3), 'SOLID': (10, 11, 12), '3DFACE': (10, 11, 12)}


def build_entity(I, pairs, owner):
    """entmake 用：ハンドル・所有者・サブクラスマーカーを補ってDXF保存形式にする"""
    dwg = I.dwg
    typ = str(pairs[0][1]).upper()
    body = [(c, v) for c, v in pairs[1:] if c not in (5, 330, 100, -1)]
    has_markers = any(c == 100 for c, v in pairs)
    if not dwg.modern:
        return [(0, typ)] + body
    if has_markers:
        rest = [(c, v) for c, v in pairs[1:] if c not in (5, 330)]
        return [(0, typ), (5, dwg.new_handle()), (330, owner)] + rest
    out = [(0, typ), (5, dwg.new_handle()), (330, owner), (100, 'AcDbEntity')]
    common = [(c, v) for c, v in body if c in ENT_COMMON]
    other = [(c, v) for c, v in body if c not in ENT_COMMON]
    if not any(c == 8 for c, v in common):
        common.insert(0, (8, I.sysvars.get('CLAYER', '0')))
    out += common
    spec = SUBCLASS.get(typ)
    if spec is None:
        I.warn('%s の entmake はサブクラス情報が不明のため、出力DXFが AutoCAD で読めない可能性があります' % typ)
        return out + other
    if typ == 'LWPOLYLINE':
        if not any(c == 90 for c, v in other):
            n = sum(1 for c, v in other if c == 10)
            other.insert(0, (90, n))
        if not any(c == 70 for c, v in other):
            i = [c for c, v in other].index(90) + 1
            other.insert(i, (70, 0))
    remaining = list(other)
    for marker, codes in spec:
        out.append((100, marker))
        if codes is None:
            out += remaining
            remaining = []
        else:
            take = [(c, v) for c, v in remaining if c in codes]
            remaining = [(c, v) for c, v in remaining if c not in codes]
            out += take
    out += remaining
    return out


def entmake_core(I, lst):
    dwg = I.dwg
    pairs, xdata = lisp_to_store(I, lst)
    if not pairs or pairs[0][0] != 0:
        I.warn('entmake: 先頭に (0 . "図形タイプ") がありません → nil')
        return None
    typ = str(pairs[0][1]).upper()
    codes = set(c for c, v in pairs)
    if xdata and not xdata_apps_ok(I, xdata):
        return None
    # --- テーブル
    if typ in TABLE_TYPES:
        name = next((v for c, v in pairs if c == 2), None)
        if not name or dwg.find_rec(typ, name):
            I.warn('entmake %s: 名前が無い/既に存在する "%s" → nil' % (typ, name))
            return None
        tobj, _ = dwg.table(typ)
        if dwg.modern:
            sub = {'LAYER': 'AcDbLayerTableRecord', 'LTYPE': 'AcDbLinetypeTableRecord',
                   'STYLE': 'AcDbTextStyleTableRecord', 'APPID': 'AcDbRegAppTableRecord',
                   'DIMSTYLE': 'AcDbDimStyleTableRecord'}.get(typ, 'AcDbSymbolTableRecord')
            body = [(c, v) for c, v in pairs[1:] if c not in (5, 330, 100, 105)]
            hc = 105 if typ == 'DIMSTYLE' else 5
            rec = [(0, typ), (hc, dwg.new_handle()), (330, tobj.h if tobj else '0'),
                   (100, 'AcDbSymbolTableRecord'), (100, sub)] + body
            if typ == 'LAYER':
                base = dwg.find_rec('LAYER', '0')
                if not any(c == 70 for c, v in body):
                    rec.insert(6, (70, 0))
                if base is not None and base.get(390) and 390 not in codes:
                    rec.append((390, base.get(390)))
        else:
            rec = pairs
        dwg.add_record(typ, rec + (xdata or []))
        return lst
    # --- ブロック定義
    if typ == 'BLOCK':
        name = next((v for c, v in pairs if c == 2), None)
        if not name:
            return None
        if name.upper() in dwg.blocks() and not name.startswith('*'):
            I.warn('entmake BLOCK: 既存のブロック "%s" を再定義しようとしています' % name)
        I.pending_block = {'name': name, 'pairs': pairs, 'ents': []}
        return lst
    if typ == 'ENDBLK':
        pb = I.pending_block
        if not pb:
            I.warn('entmake ENDBLK: 対応する BLOCK がありません → nil')
            return None
        I.pending_block = None
        return commit_block(I, pb)
    if typ in ('DICTIONARY', 'XRECORD', 'GROUP', 'LAYOUT', 'MLINESTYLE', 'DICTIONARYVAR', 'SCALE'):
        I.warn('entmake %s（非図形オブジェクト）は簡易対応です（entmakex も含む）' % typ)
        o = DObj([(0, typ), (5, dwg.new_handle()), (330, '0')] +
                 [(c, v) for c, v in pairs[1:] if c not in (5, 330)] + (xdata or []), 'OBJECTS')
        dwg.register(o)
        dwg.sec('OBJECTS').append(o)
        I.last_made = o.h
        return lst
    # --- 図形
    req = REQUIRED.get(typ, ())
    miss = [c for c in req if c not in codes]
    if typ == 'TEXT' and 40 not in codes:
        pairs.append((40, float(I.sysvars.get('TEXTSIZE', 2.5))))
    if miss:
        I.warn('entmake %s: 必須グループコード %s が無いため失敗（nil）' % (typ, miss))
        return None
    if typ == 'INSERT':
        bn = next((v for c, v in pairs if c == 2), '')
        if str(bn).upper() not in dwg.blocks():
            I.warn('entmake INSERT: ブロック "%s" が定義されていないため失敗（nil）' % bn)
            return None
    layer = next((v for c, v in pairs if c == 8), None)
    ensure_layer(I, layer)
    for c, v in pairs:
        if c == 6 and str(v).upper() not in ('BYLAYER', 'BYBLOCK') and not dwg.find_rec('LTYPE', v):
            I.warn('entmake: 線種 "%s" がロードされていません（AutoCAD では nil になります）' % v)
            return None
        if c == 7 and not dwg.find_rec('STYLE', v):
            I.warn('entmake: 文字スタイル "%s" が存在しません（AutoCAD では nil になります）' % v)
            return None
    if I.pending_block is not None:
        I.pending_block['ents'].append((pairs, xdata))
        return lst
    paper = any(c == 67 and v == 1 for c, v in pairs)
    owner = dwg.space_owner(paper)
    if typ in SUB_ENT_TYPES:
        # 直前の INSERT / POLYLINE を所有者に
        for prev in reversed(dwg.ents()):
            if prev.typ in ('INSERT', 'POLYLINE'):
                owner = prev.h
                break
    if not dwg.modern and typ in ('MTEXT', 'ELLIPSE', 'SPLINE', 'HATCH', 'LEADER', 'XLINE', 'RAY'):
        I.warn('R12 形式の図面に %s を作成しました（R12 には存在しない図形のため出力DXFで失われる可能性）' % typ)
    full = build_entity(I, pairs, owner) + (xdata or [])
    o = DObj(full, 'ENTITIES')
    dwg.register(o)
    dwg.ents().append(o)
    I.last_made = o.h
    return lst


def commit_block(I, pb):
    dwg = I.dwg
    name = pb['name']
    bpairs = pb['pairs']
    flags = next((v for c, v in bpairs if c == 70), 0)
    base = next((v for c, v in bpairs if c == 10), (0.0, 0.0, 0.0))
    if name == '*U' or name.upper().startswith('*U') and len(name) <= 2:
        name = '*U%d' % (len([b for b in dwg.blocks() if b.startswith('*U')]) + 1)
    old = dwg.blocks().get(name.upper())
    if old:
        for o in [old['block'], old['end']] + old['ents']:
            if o is not None:
                o.deleted = True
        rec = old['rec']
    else:
        rec = None
    if dwg.modern:
        if rec is None:
            tobj, _ = dwg.table('BLOCK_RECORD')
            rec = dwg.add_record('BLOCK_RECORD', [(0, 'BLOCK_RECORD'), (5, dwg.new_handle()),
                                                  (330, tobj.h if tobj else '0'),
                                                  (100, 'AcDbSymbolTableRecord'),
                                                  (100, 'AcDbBlockTableRecord'), (2, name), (340, '0')])
        owner = rec.h
        blk = [(0, 'BLOCK'), (5, dwg.new_handle()), (330, owner), (100, 'AcDbEntity'), (8, '0'),
               (100, 'AcDbBlockBegin'), (2, name), (70, flags), (10, to_pt3(base)), (3, name), (1, '')]
        end = [(0, 'ENDBLK'), (5, dwg.new_handle()), (330, owner), (100, 'AcDbEntity'), (8, '0'),
               (100, 'AcDbBlockEnd')]
    else:
        owner = '0'
        blk = [(0, 'BLOCK'), (8, '0'), (2, name), (70, flags), (10, to_pt3(base)), (3, name)]
        end = [(0, 'ENDBLK'), (8, '0')]
    lst = dwg.sec('BLOCKS')
    objs = [DObj(blk, 'BLOCKS')]
    for pairs, xdata in pb['ents']:
        objs.append(DObj(build_entity(I, pairs, owner) + (xdata or []), 'BLOCKS'))
    objs.append(DObj(end, 'BLOCKS'))
    for o in objs:
        dwg.register(o)
        lst.append(o)
    dwg._blocks = None
    return name


def dwg_changed(self):
    snap = getattr(self, 'snap0', None)
    if snap is None:
        return False
    cur = self.dwg.by_h
    if len(cur) != len(snap):
        return True
    for h, o in cur.items():
        s = snap.get(h)
        if s is None or s[0] != o.deleted or s[1] != o.p:
            return True
    return False


Interp.dwg_changed = dwg_changed


# =====================================================================
#  組み込み関数：図形データベース
# =====================================================================
@bi('entget')
def _entget(I, a):
    argn(a, 1, 2)
    e = ename_of(I, a[0])
    o = I.dwg.get(e.h)
    if o is None or o.deleted:
        return None
    apps = [strp(x) for x in seq(a[1])] if len(a) > 1 and a[1] is not None else None
    r = store_to_lisp(I.dwg, o, apps)
    if o.typ == 'MTEXT' and (o.get(42) is None or o.get(43) is None):
        # AutoCAD の entget は MTEXT の実際の幅(42)・高さ(43)を必ず返す → 概算で補う
        w, hh = mtext_extent(o)
        k = next((i for i, x in enumerate(r) if type(x) is list and x and x[0] == -3), len(r))
        r[k:k] = [Dotted([42], w), Dotted([43], hh)]
        I.warn('MTEXT の実際の幅・高さ(42/43)は概算です')
    return r


def mtext_extent(o):
    h = float(o.get(40, 2.5) or 2.5)
    lines = mtext_plain(o).split('\n') or ['']
    ws = [text_width(x, h) for x in lines]
    defw = float(o.get(41, 0.0) or 0.0)
    n = 0
    for w in ws:
        n += max(1, int(math.ceil(w / defw - 1e-9))) if defw > 0 and w > defw else 1
    w = min(max(ws + [0.0]), defw) if defw > 0 else max(ws + [0.0])
    sp = float(o.get(44, 1.0) or 1.0)
    return max(w, h * 0.1), h + (n - 1) * h * 1.6667 * sp


@bi('entmod')
def _entmod(I, a):
    argn(a, 1, 1)
    lst = seq(a[0])
    en = None
    for e in lst:
        if type(e) is Dotted and e.items == [-1]:
            en = e.tail
    if type(en) is not Ename:
        raise LispError('bad argument type: lentityp ' + short(en))
    o = I.dwg.get(en.h)
    if o is None or o.deleted:
        return None
    pairs, xdata = lisp_to_store(I, lst)
    if not pairs or pairs[0][0] != 0:
        pairs.insert(0, (0, o.typ))
    if str(pairs[0][1]).upper() != o.typ:
        I.warn('entmod: 図形タイプ(0)は変更できません → nil')
        return None
    for c, v in pairs:
        if c == 8:
            ensure_layer(I, v)
        if c == 6 and str(v).upper() not in ('BYLAYER', 'BYBLOCK') and not I.dwg.find_rec('LTYPE', v):
            I.warn('entmod: 線種 "%s" がロードされていません（AutoCAD では失敗します）' % v)
            return None
        if c == 7 and not I.dwg.find_rec('STYLE', v):
            I.warn('entmod: 文字スタイル "%s" が存在しません（AutoCAD では失敗します）' % v)
            return None
    k = xdata_start(o.p)
    old_x = o.p[k:]
    if xdata is not None:
        if not xdata_apps_ok(I, xdata):
            return None
        newapps = set(v for c, v in xdata if c == 1001)
        keep = []
        skip = False
        for c, v in old_x:
            if c == 1001:
                skip = v in newapps
            if not skip:
                keep.append((c, v))
        old_x = keep + xdata
    # 保存形式ではポインタは文字列。5/330 などは元の値を保持
    if I.dwg.modern and not any(c == 5 for c, v in pairs) and o.get(5):
        pairs.insert(1, (5, o.get(5)))
    o.p = pairs + old_x
    if o.sec == 'TABLES' or o.typ == 'BLOCK':
        I.dwg._blocks = None
    return a[0]


@bi('entmake')
def _entmake(I, a):
    argn(a, 0, 1)
    if not a or a[0] is None:
        I.pending_block = None
        return None
    r = entmake_core(I, a[0])
    return r


@bi('entmakex')
def _entmakex(I, a):
    # AutoCAD の entmakex は作った図形の「図形名」を返す（entmake はデータのリストを返す）
    argn(a, 0, 1)
    if not a or a[0] is None:
        I.pending_block = None
        return None
    I.last_made = None
    r = entmake_core(I, a[0])
    if r is not None and I.last_made is not None:
        return Ename(I.last_made)
    return r


@bi('entdel')
def _entdel(I, a):
    argn(a, 1, 1)
    e = ename_of(I, a[0])
    o = I.dwg.get(e.h)
    if o is None:
        return None
    if o.sec not in ('ENTITIES', 'BLOCKS', 'OBJECTS'):
        I.warn('entdel: テーブル項目は entdel できません')
        return None
    newstate = not o.deleted
    o.deleted = newstate
    if o.typ in ('INSERT', 'POLYLINE') and o.sec == 'ENTITIES':
        cont = I.dwg.ents()
        i = cont.index(o) + 1
        while i < len(cont) and cont[i].typ in SUB_ENT_TYPES:
            cont[i].deleted = newstate
            if cont[i].typ == 'SEQEND':
                break
            i += 1
    return e


@bi('entnext')
def _entnext(I, a):
    argn(a, 0, 1)
    ents = I.dwg.ents()
    if not a or a[0] is None:
        for o in ents:
            if not o.deleted:
                return Ename(o.h)
        return None
    e = ename_of(I, a[0])
    o = I.dwg.get(e.h)
    if o is None:
        return None
    cont = I.dwg.container_of(o)
    if cont is None:
        if o.typ == 'BLOCK':
            b = I.dwg.blocks().get(str(o.get(2, '')).upper())
            if b:
                for x in b['ents']:
                    if not x.deleted:
                        return Ename(x.h)
        return None
    i = cont.index(o) + 1
    while i < len(cont):
        x = cont[i]
        if not x.deleted and x.typ not in ('ENDBLK', 'BLOCK'):
            return Ename(x.h)
        i += 1
    return None


@bi('entlast')
def _entlast(I, a):
    argn(a, 0, 0)
    for o in reversed(I.dwg.ents()):
        if not o.deleted and o.typ not in SUB_ENT_TYPES:
            return Ename(o.h)
    return None


@bi('handent')
def _handent(I, a):
    argn(a, 1, 1)
    o = I.dwg.get(strp(a[0]).upper())
    if o is None or o.deleted:
        return None
    return Ename(o.h)


@bi('entupd redraw')
def _entupd(I, a):
    return a[0] if a else None


@bi('entsel nentsel nentselp', 'full', '入力台本から図形を選ぶ')
def _entsel(I, a):
    msg = None
    for x in a:
        if type(x) is str:
            msg = x
    I.echo(msg if msg is not None else '\nオブジェクトを選択: ')
    flags, kws, gkws = I.initget
    I.initget = (0, [], [])
    for _ in range(20):
        v = I.pop_input('entsel（図形の選択）')
        if v is None:
            return None
        if type(v) is str and kws:
            k = match_keyword(v, kws, gkws)
            if k is not None:
                return k
        o, pt = resolve_pick(I, v)
        if o is not None:
            I.last_point = pt
            return [Ename(o.h), list(pt)]
        I.warn('entsel の入力 %s に該当する図形がありません（選択なし=nil）' % show_input(v))
        return None
    return None


def resolve_pick(I, v):
    dwg = I.dwg
    if type(v) is Ename:
        o = dwg.get(v.h)
        return (o, ent_pick_point(dwg, o)) if o is not None and not o.deleted else (None, None)
    if isinstance(v, dict):
        if 'handle' in v:
            o = dwg.get(str(v['handle']))
            if o is not None and not o.deleted:
                pt = to_pt3(v['point']) if 'point' in v else ent_pick_point(dwg, o)
                return o, pt
            return None, None
        if 'pick' in v or 'point' in v:
            return pick_nearest(I, to_pt3(v.get('pick', v.get('point'))))
    if type(v) is str:
        s = v.strip()
        if s.lower() == 'last':
            for o in reversed(dwg.ents()):
                if not o.deleted and o.typ not in SUB_ENT_TYPES:
                    return o, ent_pick_point(dwg, o)
            return None, None
        if s.lower().startswith('h:') or s.startswith('#'):
            s = s.split(':', 1)[1] if ':' in s else s[1:]
        o = dwg.get(s)
        if o is not None and not o.deleted:
            return o, ent_pick_point(dwg, o)
        return None, None
    if isinstance(v, list) and v and all(isnum(x) for x in v):
        return pick_nearest(I, to_pt3(v))
    return None, None


def pick_nearest(I, pt):
    best = None
    bd = None
    for o in I.dwg.ents():
        if o.deleted or o.typ in SUB_ENT_TYPES:
            continue
        d = ent_distance(I.dwg, o, pt)
        if d is not None and (bd is None or d < bd):
            best, bd = o, d
    if best is None:
        return None, None
    tol = max(1e-6, float(I.opts.get('pick_tol', 0)) or pick_tolerance(I.dwg))
    if bd > tol:
        I.warn('クリック点 %s の近く(許容 %.3g)に図形がありません（最寄りは距離 %.3g）' % (fmt_pt(pt), tol, bd))
        return None, None
    return best, pt


def pick_tolerance(dwg):
    bb = drawing_extents(dwg)
    if not bb:
        return 1.0
    return max(bb[2] - bb[0], bb[3] - bb[1], 1e-6) * 0.02


# --------------------------------------------------------------- 選択セット
def main_ents(dwg):
    return [o for o in dwg.ents() if not o.deleted and o.typ not in SUB_ENT_TYPES]


def is_filter_list(x):
    if not isinstance(x, list) or not x:
        return False
    for e in x:
        if type(e) is Dotted and len(e.items) == 1 and type(e.items[0]) is int:
            continue
        if isinstance(e, list) and e and type(e[0]) is int:
            continue
        return False
    return True


def parse_filter(items):
    pos = [0]

    def parse_seq(end_tok):
        nodes = []
        relop = None
        while pos[0] < len(items):
            c, v = pair_of(items[pos[0]])
            pos[0] += 1
            if c == -4:
                tok = str(v).strip().upper()
                if tok in ('<AND', '<OR', '<XOR', '<NOT'):
                    sub = parse_seq(tok[1:] + '>')
                    nodes.append((tok[1:].lower(), sub))
                elif end_tok and tok == end_tok:
                    return nodes
                elif tok in ('AND>', 'OR>', 'XOR>', 'NOT>'):
                    raise LispError('bad ssget list: 閉じ演算子 %s が対応していません' % tok)
                else:
                    relop = tok
                continue
            nodes.append(('pair', c, v, relop))
            relop = None
        if end_tok:
            raise LispError('bad ssget list: %s が閉じられていません' % end_tok)
        return nodes
    return parse_seq(None)


FILTER_DEFAULT = {62: 256, 6: 'BYLAYER', 67: 0, 410: 'Model', 39: 0.0, 48: 1.0, 370: -1, 60: 0}


def _ent_vals(I, o, c):
    if c == 0:
        return [o.typ]
    vals = [v for cc, v in o.main() if cc == c]
    if not vals and c in FILTER_DEFAULT:
        vals = [FILTER_DEFAULT[c]]
    if c in PTR_CODES:
        vals = [Ename(v) for v in vals]
    return vals


def _num_cmp(a, b, op):
    if op in (None, '='):
        return a == b
    if op in ('!=', '/=', '<>'):
        return a != b
    if op == '<':
        return a < b
    if op == '<=':
        return a <= b
    if op == '>':
        return a > b
    if op == '>=':
        return a >= b
    if op == '*':
        return True
    if op == '&':
        return (int(a) & int(b)) != 0
    if op == '&=':
        return (int(a) & int(b)) == int(b)
    return a == b


def match_node(I, o, node):
    k = node[0]
    if k == 'pair':
        _, c, v, op = node
        if c == -3:
            apps = set(str(x).upper() for x, _ in parse_xdata(o.p[xdata_start(o.p):]))
            for appl in seq(v):
                name = seq(appl)[0] if isinstance(appl, list) else appl
                if not any(wcmatch(a2, str(name), True) for a2 in apps):
                    return False
            return True
        for ev in _ent_vals(I, o, c):
            if type(v) is str and type(ev) is str:
                r = wcmatch(ev, v, True)
                if op in ('!=', '/=', '<>'):
                    r = not r
                if r:
                    return True
            elif isnum(v) and isnum(ev):
                if _num_cmp(ev, v, op):
                    return True
            elif isinstance(v, list) and isinstance(ev, tuple):
                ops = [s.strip() for s in (op or '=').split(',')]
                if len(ops) == 1:
                    ops = ops * 3
                ok = True
                for i, cv in enumerate(v):
                    if i >= len(ev):
                        break
                    if not _num_cmp(ev[i], cv, ops[i] if i < len(ops) else '='):
                        ok = False
                        break
                if ok:
                    return True
            elif type(v) is Ename and type(ev) is Ename:
                if v == ev:
                    return True
        return False
    sub = node[1]
    if k == 'and':
        return all(match_node(I, o, n) for n in sub)
    if k == 'or':
        return any(match_node(I, o, n) for n in sub)
    if k == 'xor':
        return sum(1 for n in sub if match_node(I, o, n)) == 1
    if k == 'not':
        return not all(match_node(I, o, n) for n in sub)
    return False


def filter_ents(I, ents, flt):
    nodes = parse_filter(seq(flt))
    return [o for o in ents if all(match_node(I, o, n) for n in nodes)]


def sel_from_input(I, v):
    dwg = I.dwg
    allm = main_ents(dwg)
    if v is None:
        return []
    if type(v) is PickSet:
        return [dwg.get(h) for h in v.hs if dwg.get(h) is not None and not dwg.get(h).deleted]
    if type(v) is Ename:
        o = dwg.get(v.h)
        return [o] if o is not None and not o.deleted else []
    if type(v) is str:
        s = v.strip().lower()
        if s in ('all', 'x', '*'):
            return allm
        if s == 'last':
            return allm[-1:]
        if s in ('previous', 'p') and I.prev_ss is not None:
            return sel_from_input(I, I.prev_ss)
        o, _ = resolve_pick(I, v)
        return [o] if o is not None else []
    if isinstance(v, dict):
        if 'window' in v or 'crossing' in v:
            cross = 'crossing' in v
            p1, p2 = v.get('window') or v.get('crossing')
            return window_select(dwg, p1, p2, cross)
        if 'handles' in v:
            return sel_from_input(I, v['handles'])
        if 'layer' in v:
            return [o for o in allm if wcmatch(str(o.get(8, '0')), str(v['layer']), True)]
        if 'type' in v:
            return [o for o in allm if wcmatch(o.typ, str(v['type']), True)]
        o, _ = resolve_pick(I, v)
        return [o] if o is not None else []
    if isinstance(v, list):
        if v and all(isnum(x) for x in v):
            o, _ = resolve_pick(I, v)
            return [o] if o is not None else []
        res = []
        for x in v:
            for o in sel_from_input(I, x):
                if o not in res:
                    res.append(o)
        return res
    return []


def window_select(dwg, p1, p2, cross):
    x1, x2 = sorted([float(p1[0]), float(p2[0])])
    y1, y2 = sorted([float(p1[1]), float(p2[1])])
    res = []
    for o in main_ents(dwg):
        bb = ent_bbox(dwg, o)
        if not bb:
            continue
        if cross:
            if bb[0] <= x2 and bb[2] >= x1 and bb[1] <= y2 and bb[3] >= y1:
                res.append(o)
        else:
            if bb[0] >= x1 and bb[2] <= x2 and bb[1] >= y1 and bb[3] <= y2:
                res.append(o)
    return res


def poly_select(dwg, pts, cross):
    poly = [(float(p[0]), float(p[1])) for p in pts]

    def inside(x, y):
        c = False
        n = len(poly)
        for i in range(n):
            xa, ya = poly[i]
            xb, yb = poly[(i + 1) % n]
            if (ya > y) != (yb > y) and x < (xb - xa) * (y - ya) / ((yb - ya) or 1e-300) + xa:
                c = not c
        return c
    res = []
    for o in main_ents(dwg):
        pts2 = ent_sample_points(dwg, o)
        if not pts2:
            continue
        flags = [inside(x, y) for x, y in pts2]
        if (cross and any(flags)) or (not cross and all(flags)):
            res.append(o)
    return res


@bi('ssget', 'full', '窓/交差選択は外形枠による近似')
def _ssget(I, a):
    dwg = I.dwg
    args = list(a)
    mode = None
    flt = None
    if args and type(args[0]) is str:
        mode = args.pop(0)
    m0 = (mode or '').upper().replace('_', '').split(':')[0]
    need = {'W': 2, 'C': 2, 'WP': 1, 'CP': 1, 'F': 1}.get(m0, 0)
    if args and len(args) > need and is_filter_list(args[-1]):
        flt = args.pop()
    m = (mode or '').upper().replace('_', '')
    tokens = set(t for t in m.split(':') if t)
    base = m.split(':')[0] if m else ''
    extras = tokens - {base}
    if base == 'X':
        cand = main_ents(dwg)
    elif base in ('W', 'C') and len(args) >= 2:
        cand = window_select(dwg, ptp(args[0]), ptp(args[1]), base == 'C')
    elif base in ('WP', 'CP') and args:
        cand = poly_select(dwg, seq(args[0]), base == 'CP')
    elif base == 'F' and args:
        cand = fence_select(dwg, [ptp(p) for p in seq(args[0])])
    elif base == 'L':
        cand = main_ents(dwg)[-1:]
    elif base == 'P':
        cand = sel_from_input(I, I.prev_ss) if I.prev_ss else []
    elif base == 'I':
        cand = sel_from_input(I, I.pickfirst) if I.pickfirst else []
    elif base == '' and args and isinstance(args[0], list):
        o, _ = pick_nearest(I, to_pt3(ptp(args[0])))
        cand = [o] if o else []
    else:
        I.echo('\nオブジェクトを選択: ')
        v = I.pop_input('ssget（オブジェクト選択）')
        cand = sel_from_input(I, v)
        if 'S' in extras or 'E' in extras:
            cand = cand[:1] if 'S' in extras else cand
    if 'L' in extras:
        cand = [o for o in cand if not layer_locked(dwg, o.get(8, '0'))]
    if flt is not None:
        cand = filter_ents(I, cand, flt)
    if not cand:
        return None
    ss = PickSet([o.h for o in cand])
    I.prev_ss = ss
    return ss


def fence_select(dwg, pts):
    fence = []
    for i in range(len(pts) - 1):
        fence.append(('L', pts[i][0], pts[i][1], pts[i + 1][0], pts[i + 1][1]))
    res = []
    for o in main_ents(dwg):
        prims = ent_prims(dwg, o)
        hit = False
        for p in prims:
            for f in fence:
                if prim_intersections(p, f, False, False):
                    hit = True
                    break
            if hit:
                break
        if hit:
            res.append(o)
    return res


def layer_locked(dwg, name):
    r = dwg.find_rec('LAYER', name)
    return bool(r is not None and (r.get(70, 0) & 4))


def ss_of(x):
    if type(x) is PickSet:
        return x
    raise LispError('bad argument type: lselsetp ' + short(x))


@bi('sslength')
def _sslength(I, a):
    argn(a, 1, 1)
    return len(ss_of(a[0]).hs)


@bi('ssname')
def _ssname(I, a):
    argn(a, 2, 2)
    ss = ss_of(a[0])
    i = a[1]
    if type(i) is float:
        i = int(i)
    i = fixn(i)
    if i < 0 or i >= len(ss.hs):
        return None
    return Ename(ss.hs[i])


@bi('ssadd')
def _ssadd(I, a):
    argn(a, 0, 2)
    if not a:
        return PickSet()
    e = ename_of(I, a[0])
    if len(a) == 1 or a[1] is None:
        return PickSet([e.h])
    ss = ss_of(a[1])
    if e.h not in ss.hs:
        ss.hs.append(e.h)
    return ss


@bi('ssdel')
def _ssdel(I, a):
    argn(a, 2, 2)
    e = ename_of(I, a[0])
    ss = ss_of(a[1])
    if e.h in ss.hs:
        ss.hs.remove(e.h)
        return ss
    return None


@bi('ssmemb')
def _ssmemb(I, a):
    argn(a, 2, 2)
    e = ename_of(I, a[0])
    return e if e.h in ss_of(a[1]).hs else None


@bi('ssnamex', 'approx')
def _ssnamex(I, a):
    argn(a, 1, 2)
    ss = ss_of(a[0])
    hs = ss.hs if len(a) == 1 else ss.hs[fixn(a[1]):fixn(a[1]) + 1]
    return L([0, Ename(h), 0] for h in hs)


@bi('sssetfirst')
def _sssetfirst(I, a):
    I.pickfirst = a[1] if len(a) > 1 else None
    return L(a)


@bi('ssgetfirst')
def _ssgetfirst(I, a):
    return [None, I.pickfirst]


# --------------------------------------------------------------- テーブル
def rec_to_lisp(dwg, o, tname):
    if tname == 'BLOCK':
        return block_tbl_entry(dwg, o)
    out = [Dotted([0], tname)]
    for c, v in o.main():
        if c in (0, 5, 105, 330, 100, 102, 360, 390, 347, 348, 340) or c in PTR_CODES:
            continue
        if type(v) is tuple:
            out.append([c] + list(v))
        else:
            out.append(Dotted([c], v))
    return out


def block_tbl_entry(dwg, b):
    bo = b['block']
    out = [Dotted([0], 'BLOCK'), Dotted([2], b['name']), Dotted([70], bo.get(70, 0)),
           Dotted([4], bo.get(4, '')), [10] + list(to_pt3(bo.get(10, (0.0, 0.0, 0.0))))]
    first = next((x for x in b['ents'] if not x.deleted), None)
    if first is not None:
        out.append(Dotted([-2], Ename(first.h)))
    return out


def table_items(dwg, tname):
    if tname == 'BLOCK':
        return list(dwg.blocks().values())
    return dwg.records(tname)


@bi('tblsearch')
def _tblsearch(I, a):
    argn(a, 2, 3)
    tname = strp(a[0]).upper()
    name = strp(a[1])
    items = table_items(I.dwg, tname)
    for i, it in enumerate(items):
        nm = it['name'] if tname == 'BLOCK' else str(it.get(2, ''))
        if nm.upper() == name.upper():
            if len(a) > 2 and a[2] is not None:
                I.tblnext_pos[tname] = i + 1
            return rec_to_lisp(I.dwg, it, tname)
    return None


@bi('tblnext')
def _tblnext(I, a):
    argn(a, 1, 2)
    tname = strp(a[0]).upper()
    if len(a) > 1 and a[1] is not None:
        I.tblnext_pos[tname] = 0
    i = I.tblnext_pos.get(tname, 0)
    items = table_items(I.dwg, tname)
    if i >= len(items):
        return None
    I.tblnext_pos[tname] = i + 1
    return rec_to_lisp(I.dwg, items[i], tname)


@bi('tblobjname')
def _tblobjname(I, a):
    argn(a, 2, 2)
    tname = strp(a[0]).upper()
    name = strp(a[1])
    if tname == 'BLOCK':
        b = I.dwg.blocks().get(name.upper())
        if b is None:
            return None
        # AutoCAD はブロック定義の先頭（BLOCK）を返す → entnext で中身をたどれる
        return Ename((b['block'] or b['rec']).h)
    r = I.dwg.find_rec(tname, name)
    return Ename(r.h) if r is not None else None


@bi('regapp')
def _regapp(I, a):
    argn(a, 1, 1)
    name = strp(a[0])
    if I.dwg.find_rec('APPID', name):
        return None
    dwg = I.dwg
    if dwg.modern:
        tobj, _ = dwg.table('APPID')
        dwg.add_record('APPID', [(0, 'APPID'), (5, dwg.new_handle()), (330, tobj.h if tobj else '0'),
                                 (100, 'AcDbSymbolTableRecord'), (100, 'AcDbRegAppTableRecord'),
                                 (2, name), (70, 0)])
    else:
        dwg.add_record('APPID', [(0, 'APPID'), (2, name), (70, 0)])
    return name


@bi('xdroom')
def _xdroom(I, a):
    return 16383


@bi('xdsize')
def _xdsize(I, a):
    return 100


# --------------------------------------------------------------- 辞書（簡易）
def root_dict(dwg):
    for o in dwg.sec('OBJECTS'):
        if o.typ == 'DICTIONARY' and not o.deleted:
            return o
    return None


def dict_entries(o):
    res = []
    name = None
    for c, v in o.p:
        if c == 3:
            name = v
        elif c in (350, 360) and name is not None:
            res.append((name, v))
            name = None
    return res


@bi('namedobjdict', 'approx')
def _namedobjdict(I, a):
    r = root_dict(I.dwg)
    return Ename(r.h) if r else None


@bi('dictsearch', 'approx')
def _dictsearch(I, a):
    argn(a, 2, 3)
    d = obj_of(I, a[0])
    if d is None:
        return None
    for nm, h in dict_entries(d):
        if nm.upper() == strp(a[1]).upper():
            o = I.dwg.get(h)
            return store_to_lisp(I.dwg, o) if o is not None and not o.deleted else None
    return None


@bi('dictnext', 'approx')
def _dictnext(I, a):
    argn(a, 1, 2)
    d = obj_of(I, a[0])
    if d is None:
        return None
    key = ('dict', d.h)
    if len(a) > 1 and a[1] is not None:
        I.tblnext_pos[key] = 0
    i = I.tblnext_pos.get(key, 0)
    ents = dict_entries(d)
    while i < len(ents):
        I.tblnext_pos[key] = i + 1
        o = I.dwg.get(ents[i][1])
        if o is not None and not o.deleted:
            return store_to_lisp(I.dwg, o)
        i += 1
    return None


@bi('dictadd', 'approx')
def _dictadd(I, a):
    argn(a, 3, 3)
    d = obj_of(I, a[0])
    o = obj_of(I, a[2])
    if d is None or o is None:
        return None
    for nm, h in dict_entries(d):
        if nm.upper() == strp(a[1]).upper():
            return None
    d.p.append((3, strp(a[1])))
    d.p.append((350, o.h))
    o.set(330, d.h)
    return a[2]


@bi('dictremove', 'approx')
def _dictremove(I, a):
    argn(a, 2, 2)
    d = obj_of(I, a[0])
    if d is None:
        return None
    key = strp(a[1]).upper()
    p = d.p
    for i in range(len(p) - 1):
        if p[i][0] == 3 and str(p[i][1]).upper() == key and p[i + 1][0] in (350, 360):
            h = p[i + 1][1]
            del p[i:i + 2]
            return Ename(h)
    return None


@bi('dictrename', 'approx')
def _dictrename(I, a):
    argn(a, 3, 3)
    d = obj_of(I, a[0])
    for i, (c, v) in enumerate(d.p if d else []):
        if c == 3 and str(v).upper() == strp(a[1]).upper():
            d.p[i] = (3, strp(a[2]))
            return a[2]
    return None


# =====================================================================
#  組み込み関数：ユーザー入力（台本から）
# =====================================================================
@bi('initget')
def _initget(I, a):
    argn(a, 0, 2)
    bits = 0
    kw = ''
    for x in a:
        if type(x) is int:
            bits = x
        elif type(x) is str:
            kw = x
    toks = kw.split()
    locs, globs = toks, []
    for i, t in enumerate(toks):
        if t.startswith('_'):
            locs = toks[:i]
            globs = [toks[i][1:]] + toks[i + 1:]
            break
    I.initget = (bits, locs, globs)
    return None


def match_keyword(s, kws, gkws):
    s = str(s).strip()
    if not s:
        return None
    su = s.upper().lstrip('_')
    for i, k in enumerate(kws):
        ku = k.upper()
        caps = ''.join(ch for ch in k if ch.isupper() or ch.isdigit())
        if su == ku or (caps and su == caps.upper()) or (len(su) >= max(1, len(caps)) and ku.startswith(su)):
            return gkws[i] if i < len(gkws) else k
    for k in gkws:
        if k.upper() == su:
            return k
    return None


def parse_point_str(s, base=None):
    s = s.strip()
    rel = s.startswith('@')
    if rel:
        s = s[1:]
    m = re.fullmatch(r'\s*([-+.\deE]+)\s*<\s*([-+.\deE]+)\s*', s)
    if m:
        d = float(m.group(1))
        ang = math.radians(float(m.group(2)))
        b = base or (0.0, 0.0, 0.0)
        return (b[0] + d * math.cos(ang), b[1] + d * math.sin(ang), b[2] if len(b) > 2 else 0.0)
    parts = s.split(',')
    try:
        vals = [float(p) for p in parts]
    except ValueError:
        return None
    if len(vals) not in (2, 3):
        return None
    if len(vals) == 2:
        vals.append(0.0)
    if rel:
        b = base or (0.0, 0.0, 0.0)
        vals = [vals[0] + b[0], vals[1] + b[1], vals[2] + (b[2] if len(b) > 2 else 0.0)]
    return tuple(vals)


def input_point(v, base=None):
    if isinstance(v, list) and 2 <= len(v) <= 3 and all(isnum(x) for x in v):
        return to_pt3(v)
    if isinstance(v, dict) and ('point' in v or 'pick' in v):
        return to_pt3(v.get('point', v.get('pick')))
    if type(v) is str:
        return parse_point_str(v, base)
    return None


def _getbase(a):
    base = None
    msg = None
    for x in a:
        if isinstance(x, list):
            base = ptp(x)
        elif type(x) is str:
            msg = x
    return base, msg


def get_input(I, kind, a, conv, default_msg=''):
    base, msg = _getbase(a)
    I.echo(msg if msg is not None else default_msg)
    flags, kws, gkws = I.initget
    I.initget = (0, [], [])
    for _ in range(30):
        v = I.pop_input(kind)
        if v is None or v == '':
            if flags & 1:
                I.warn('initget 1（空入力禁止）中に空入力 → AutoCAD は再入力を求めます（次の入力を使用）')
                continue
            return None
        if type(v) is str and (kws or gkws):
            k = match_keyword(v, kws, gkws)
            if k is not None:
                return k
        r = conv(v, base)
        if r is _UNB:
            if flags & 128 and type(v) is str:
                return v
            I.warn('%s への入力 %s は無効 → AutoCAD は再入力を求めます（次の入力を使用）' % (kind, show_input(v)))
            continue
        if isnum(r):
            if flags & 2 and r == 0:
                I.warn('initget 2（ゼロ禁止）中に 0 が入力されました → 再入力')
                continue
            if flags & 4 and r < 0:
                I.warn('initget 4（負数禁止）中に負数が入力されました → 再入力')
                continue
        return r
    raise LispError('Function cancelled')


def _cv_point(v, base):
    p = input_point(v, base)
    return list(p) if p else _UNB


def _cv_int(v, base):
    if type(v) is int:
        return v if -32768 <= v <= 32767 else _UNB
    if type(v) is float and v == int(v):
        return int(v)
    if type(v) is str and re.fullmatch(r'\s*[+-]?\d+\s*', v):
        return int(v)
    return _UNB


def _cv_real(v, base):
    if isnum(v):
        return float(v)
    if type(v) is str:
        try:
            return float(v)
        except ValueError:
            return _UNB
    return _UNB


@bi('getpoint', 'full', '入力台本から')
def _getpoint(I, a):
    r = get_input(I, 'getpoint（点）', a, _cv_point, '\n点を指定: ')
    if isinstance(r, list):
        I.sysvars['LASTPOINT'] = list(r)
    return r


@bi('getcorner', 'full', '入力台本から')
def _getcorner(I, a):
    return get_input(I, 'getcorner（もう一方のコーナー）', a, _cv_point, '\nもう一方のコーナーを指定: ')


@bi('getint', 'full', '入力台本から')
def _getint(I, a):
    return get_input(I, 'getint（整数）', a, _cv_int, '\n整数を入力: ')


@bi('getreal', 'full', '入力台本から')
def _getreal(I, a):
    return get_input(I, 'getreal（実数）', a, _cv_real, '\n実数を入力: ')


@bi('getdist', 'full', '入力台本から')
def _getdist(I, a):
    base, msg = _getbase(a)

    def cv(v, b):
        if isnum(v):
            return float(v)
        p = input_point(v, b) if not isnum(v) else None
        if p is None:
            r = _cv_real(v, b)
            return r
        if b is None:
            q = input_point(I.pop_input('getdist（2点目）'), p)
            if q is None:
                return _UNB
            return math.dist(p[:2], q[:2])
        return math.dist(to_pt3(b), p)
    return get_input(I, 'getdist（距離）', a, cv, '\n距離を指定: ')


def _getangle_common(I, a, kind):
    def cv(v, b):
        if isnum(v):
            return math.radians(float(v))
        if type(v) is str:
            try:
                return math.radians(float(v))
            except ValueError:
                pass
        p = input_point(v, b)
        if p is None:
            return _UNB
        if b is None:
            q = input_point(I.pop_input(kind + '（2点目）'), p)
            if q is None:
                return _UNB
            return ang_norm(math.atan2(q[1] - p[1], q[0] - p[0]))
        return ang_norm(math.atan2(p[1] - b[1], p[0] - b[0]))
    return get_input(I, kind + '（角度・度で入力）', a, cv, '\n角度を指定: ')


@bi('getangle getorient', 'full', '数値入力は「度」として扱う')
def _getangle(I, a):
    return _getangle_common(I, a, 'getangle')


@bi('getstring', 'full', '入力台本から')
def _getstring(I, a):
    msg = None
    for x in a:
        if type(x) is str:
            msg = x
    I.echo(msg if msg is not None else '\n文字列を入力: ')
    I.initget = (0, [], [])
    v = I.pop_input('getstring（文字列）')
    if v is None:
        return ''
    if type(v) is not str:
        v = lstr(v, False) if not isinstance(v, (dict, list)) else json.dumps(v)
    return v


@bi('getkword', 'full', '入力台本から')
def _getkword(I, a):
    msg = a[0] if a and type(a[0]) is str else None
    I.echo(msg if msg is not None else '\nキーワードを入力: ')
    flags, kws, gkws = I.initget
    I.initget = (0, [], [])
    if not kws and not gkws:
        I.warn('getkword の前に initget でキーワードが設定されていません')
    for _ in range(30):
        v = I.pop_input('getkword（キーワード %s）' % '/'.join(kws))
        if v is None or v == '':
            if flags & 1:
                I.warn('initget 1 中に空入力 → 再入力')
                continue
            return None
        k = match_keyword(str(v), kws, gkws)
        if k is not None:
            return k
        I.warn('getkword: "%s" はキーワード %s に一致しません → 再入力' % (v, kws))
    raise LispError('Function cancelled')


@bi('getfiled', 'full', '入力台本から')
def _getfiled(I, a):
    I.echo('\n[ファイル選択ダイアログ] %s\n' % (a[0] if a else ''))
    v = I.pop_input('getfiled（ファイルパス）')
    return v if type(v) is str and v else None


@bi('grread', 'approx', '入力台本から（点→(3 点)、文字→(2 コード)）')
def _grread(I, a):
    v = I.pop_input('grread（マウス/キー）')
    p = input_point(v)
    if p:
        return [3, list(p)]
    if type(v) is str and v:
        return [2, ord(v[0])]
    if type(v) is int:
        return [2, v]
    return [2, 13]


@bi('getcname', 'approx')
def _getcname(I, a):
    return strp(a[0]).lstrip('_.') if a else None


# =====================================================================
#  組み込み関数：システム変数・環境
# =====================================================================
@bi('getvar')
def _getvar(I, a):
    argn(a, 1, 1)
    return sysvar_get(I, strp(a[0]))


@bi('setvar')
def _setvar(I, a):
    argn(a, 2, 2)
    n = strp(a[0]).upper()
    v = a[1]
    if n in READONLY_SYSVARS:
        raise LispError('AutoCAD variable setting rejected: %s %s' % (n, short(v)))
    if n not in I.sysvars:
        I.warn('不明なシステム変数 %s を setvar しました（そのまま記録）' % n)
    old = I.sysvars.get(n)
    if old is not None and v is not None:
        if isnum(old) and not isnum(v):
            raise LispError('AutoCAD variable setting rejected: %s %s' % (n, short(v)))
        if type(old) is str and type(v) is not str:
            raise LispError('AutoCAD variable setting rejected: %s %s' % (n, short(v)))
        if type(old) is int and type(v) is float:
            v = int(v)
        if type(old) is float and type(v) is int:
            v = float(v)
    if n == 'CLAYER':
        r = I.dwg.find_rec('LAYER', v)
        if r is None:
            raise LispError('AutoCAD variable setting rejected: CLAYER %s' % short(v))
        if r.get(70, 0) & 1:
            raise LispError('AutoCAD variable setting rejected: CLAYER %s（フリーズ画層）' % short(v))
        v = r.get(2)
    if n == 'TEXTSTYLE' and not I.dwg.find_rec('STYLE', v):
        raise LispError('AutoCAD variable setting rejected: TEXTSTYLE %s' % short(v))
    I.sysvars[n] = copy_val(v)
    if n in ('CLAYER', 'TEXTSIZE', 'TEXTSTYLE', 'LTSCALE', 'CECOLOR', 'CELTYPE', 'DIMSCALE', 'INSUNITS',
             'LUNITS', 'LUPREC', 'PDMODE', 'PDSIZE'):
        hv = v
        if n == 'CECOLOR':
            hv = 256 if str(v).upper() == 'BYLAYER' else (0 if str(v).upper() == 'BYBLOCK' else int(v) if str(v).isdigit() else 256)
        I.dwg.hvar_set('$' + n, hv)
    return v


@bi('getenv')
def _getenv(I, a):
    argn(a, 1, 1)
    n = strp(a[0])
    if n in I.env:
        return I.env[n]
    return os.environ.get(n)


@bi('setenv')
def _setenv(I, a):
    argn(a, 2, 2)
    I.env[strp(a[0])] = strp(a[1])
    return a[1]


@bi('ver')
def _ver(I, a):
    return 'Visual LISP 2.0 (ja)'


@bi('vl-registry-read vl-registry-write vl-registry-delete vl-registry-descendents', 'stub')
def _vl_registry(I, a):
    I.warn('レジストリ関数は再現していません（nil を返しました）')
    return None


@bi('vl-bb-set')
def _vl_bb_set(I, a):
    argn(a, 2, 2)
    I.bb[symp(a[0])] = a[1]
    return a[1]


@bi('vl-bb-ref')
def _vl_bb_ref(I, a):
    argn(a, 1, 1)
    return I.bb.get(symp(a[0]))


@bi('vl-doc-set vl-doc-export vl-doc-import vl-propagate', 'approx')
def _vl_doc_set(I, a):
    if len(a) >= 2 and type(a[0]) is Sym:
        I.g[a[0]] = a[1]
        return a[1]
    return None


@bi('vl-doc-ref')
def _vl_doc_ref(I, a):
    argn(a, 1, 1)
    return I.g.get(symp(a[0]))


@bi('vl-load-com vl-load-all vl-load-reactors vl-arx-import vl-acad-defun vl-acad-undefun')
def _vl_load_com(I, a):
    I.vl_com = True
    return None


@bi('acad-push-dbmod acad-pop-dbmod')
def _dbmod(I, a):
    return T


@bi('help menucmd menugroup startapp textscr graphscr textpage grclear grdraw grvecs grtext setview '
    'vports acad_colordlg acad_truecolordlg acad_helpdlg arxload arxunload autoarxload autoload '
    'setfunhelp showhtmlmodalwindow', 'stub')
def _ui_stub(I, a):
    I.warn('画面/UI系の関数は再現していません（ログのみ）')
    I.echo('[UI呼び出し] %s\n' % ' '.join(short(x, 40) for x in a))
    return None


@bi('arx')
def _arx(I, a):
    return None


@bi('alert')
def _alert(I, a):
    argn(a, 1, 1)
    I.echo('\n[ALERT] %s\n' % strp(a[0]))
    return None


@bi('trans', 'approx', 'UCS=WCS 前提')
def _trans(I, a):
    argn(a, 3, 4)
    p = ptp(a[0])
    if I.sysvars.get('WORLDUCS', 1) != 1:
        I.warn('trans: UCS は WCS と同じとして扱っています')
    if len(p) == 2:
        p.append(0.0)
    return p


@bi('osnap', 'approx', '点をそのまま返す')
def _osnap(I, a):
    argn(a, 2, 2)
    I.warn('osnap は再現していません（入力点をそのまま返しました）')
    return ptp(a[0])


@bi('distance')
def _distance(I, a):
    argn(a, 2, 2)
    p, q = ptp(a[0]), ptp(a[1])
    if len(p) == 2 or len(q) == 2:
        return math.hypot(p[0] - q[0], p[1] - q[1])
    return math.sqrt(sum((x - y) ** 2 for x, y in zip(p, q)))


@bi('angle')
def _angle(I, a):
    argn(a, 2, 2)
    p, q = ptp(a[0]), ptp(a[1])
    return ang_norm(math.atan2(q[1] - p[1], q[0] - p[0]))


@bi('polar')
def _polar(I, a):
    argn(a, 3, 3)
    p = ptp(a[0])
    ang = float(num(a[1]))
    d = float(num(a[2]))
    r = [p[0] + d * math.cos(ang), p[1] + d * math.sin(ang)]
    if len(p) > 2:
        r.append(p[2])
    return r


@bi('inters')
def _inters(I, a):
    argn(a, 4, 5)
    p1, p2, p3, p4 = [ptp(x) for x in a[:4]]
    onseg = not (len(a) > 4 and a[4] is None)
    x1, y1, x2, y2 = p1[0], p1[1], p2[0], p2[1]
    x3, y3, x4, y4 = p3[0], p3[1], p4[0], p4[1]
    den = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
    if abs(den) < 1e-12:
        return None
    t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / den
    u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / den
    if onseg and not (-1e-10 <= t <= 1 + 1e-10 and -1e-10 <= u <= 1 + 1e-10):
        return None
    r = [x1 + t * (x2 - x1), y1 + t * (y2 - y1)]
    if len(p1) > 2 and len(p2) > 2:
        r.append(p1[2] + t * (p2[2] - p1[2]))
    return r


@bi('textbox', 'approx', '文字幅は概算')
def _textbox(I, a):
    argn(a, 1, 1)
    lst = seq(a[0])
    s = ''
    h = float(I.sysvars.get('TEXTSIZE', 2.5))
    wf = 1.0
    for e in lst:
        c, v = pair_of(e)
        if c == 1:
            s = v
        elif c == 40:
            h = float(v)
        elif c == 41:
            wf = float(v)
    w = text_width(s, h, wf)
    return [[0.0, -0.2 * h if re.search(r'[gjpqy]', s) else 0.0, 0.0], [w, h, 0.0]]


def text_width(s, h, wf=1.0):
    w = 0.0
    for ch in s:
        w += (1.0 if ord(ch) > 0x2E80 else 0.7) * h
    return w * wf


# =====================================================================
#  組み込み関数：画面出力・ファイル
# =====================================================================
def _out(I, s, f=None):
    if f is None:
        I.echo(s)
    else:
        if type(f) is not LFile:
            raise LispError('bad argument type: filep ' + short(f))
        if f.closed or f.mode == 'r':
            raise LispError('bad argument type: filep ' + short(f))
        f.f.write(s)


@bi('princ')
def _princ(I, a):
    argn(a, 0, 2)
    if not a:
        return S('')  # 何も表示しない
    _out(I, lstr(a[0], False), a[1] if len(a) > 1 else None)
    return a[0]


@bi('prin1')
def _prin1(I, a):
    argn(a, 0, 2)
    if not a:
        return S('')
    _out(I, lstr(a[0], True), a[1] if len(a) > 1 else None)
    return a[0]


@bi('print')
def _print(I, a):
    argn(a, 0, 2)
    if not a:
        return S('')
    _out(I, '\n' + lstr(a[0], True) + ' ', a[1] if len(a) > 1 else None)
    return a[0]


@bi('prompt')
def _prompt(I, a):
    argn(a, 1, 1)
    I.echo(strp(a[0]))
    return None


@bi('terpri')
def _terpri(I, a):
    I.echo('\n')
    return None


@bi('write-line')
def _write_line(I, a):
    argn(a, 1, 2)
    s = strp(a[0])
    _out(I, s + '\n', a[1] if len(a) > 1 else None)
    return s


@bi('write-char')
def _write_char(I, a):
    argn(a, 1, 2)
    _out(I, chr(fixn(a[0])), a[1] if len(a) > 1 else None)
    return a[0]


def resolve_path(I, name, must_exist=True):
    name = name.replace('\\', '/')
    cands = [name]
    if not os.path.isabs(name):
        base = os.path.basename(name)
        for d in [os.getcwd()] + [os.path.dirname(p) for p in I.loaded] + I.search:
            cands.append(os.path.join(d, name))
            cands.append(os.path.join(d, base))
    if re.match(r'^[A-Za-z]:/', name):
        base = name.split('/')[-1]
        for d in [os.getcwd()] + [os.path.dirname(p) for p in I.loaded] + I.search:
            cands.append(os.path.join(d, base))
    for c in cands:
        if os.path.exists(c):
            return c
    return None


@bi('open', 'approx', '書込みは出力フォルダ内に作成')
def _open(I, a):
    argn(a, 2, 3)
    name = strp(a[0])
    mode = strp(a[1]).lower()
    enc = 'utf-8'
    if len(a) > 2 and type(a[2]) is str and 'ansi' in a[2].lower():
        enc = 'cp932'
    if mode.startswith('r'):
        p = resolve_path(I, name)
        if p is None:
            return None
        data = read_text_file(p)
        return LFile(p, 'r', io.StringIO(data), name)
    if mode[:1] in ('w', 'a'):
        d = os.path.join(I.outdir, 'lisp_files')
        os.makedirs(d, exist_ok=True)
        base = re.split(r'[\\/]', name)[-1] or 'noname.txt'
        p = os.path.join(d, base)
        f = open(p, 'a' if mode[:1] == 'a' else 'w', encoding=enc, newline='')
        if p not in I.written_files:
            I.written_files.append(p)
        I.warn('書込み用ファイル "%s" は出力フォルダ %s に作成しました（実ファイルは変更しません）' % (name, p))
        return LFile(p, mode[:1], f, name)
    raise LispError('bad argument value: ' + mode)


@bi('close')
def _close(I, a):
    argn(a, 1, 1)
    f = a[0]
    if type(f) is not LFile:
        raise LispError('bad argument type: filep ' + short(f))
    if not f.closed:
        f.f.close()
        f.closed = True
    return None


@bi('read-line')
def _read_line(I, a):
    argn(a, 0, 1)
    if not a or a[0] is None:
        v = I.pop_input('read-line（キーボード）')
        return v if type(v) is str else (lstr(v, False) if v is not None else '')
    f = a[0]
    if type(f) is not LFile or f.closed or f.mode != 'r':
        raise LispError('bad argument type: filep ' + short(f))
    line = f.f.readline()
    if line == '':
        return None
    return line.rstrip('\n').rstrip('\r')


@bi('read-char')
def _read_char(I, a):
    argn(a, 0, 1)
    if not a or a[0] is None:
        v = I.pop_input('read-char（キーボード）')
        return ord(str(v)[0]) if v else 10
    f = a[0]
    if type(f) is not LFile or f.closed:
        raise LispError('bad argument type: filep ' + short(f))
    ch = f.f.read(1)
    if ch == '':
        return None
    return 10 if ch == '\n' else ord(ch)


@bi('findfile')
def _findfile(I, a):
    argn(a, 1, 1)
    p = resolve_path(I, strp(a[0]))
    return p.replace('/', '\\') if p else None


@bi('findtrustedfile')
def _findtrustedfile(I, a):
    return _findfile(I, a)


@bi('vl-file-size')
def _vl_file_size(I, a):
    p = resolve_path(I, strp(a[0]))
    if p is None:
        return None
    return 0 if os.path.isdir(p) else os.path.getsize(p)


@bi('vl-file-directory-p')
def _vl_file_directory_p(I, a):
    p = resolve_path(I, strp(a[0]))
    return truth(p is not None and os.path.isdir(p))


@bi('vl-file-systime')
def _vl_file_systime(I, a):
    p = resolve_path(I, strp(a[0]))
    if p is None:
        return None
    t = datetime.datetime.fromtimestamp(os.path.getmtime(p))
    return [t.year, t.month, t.isoweekday() % 7, t.day, t.hour, t.minute, t.second, 0]


@bi('vl-file-copy vl-file-delete vl-file-rename vl-mkdir', 'stub', '実際には何もしない')
def _vl_file_ops(I, a):
    I.warn('ファイル操作（コピー/削除/名前変更/フォルダ作成）は実行せずログのみ（T を返しました）')
    I.echo('[ファイル操作(未実行)] %s\n' % ' '.join(short(x, 60) for x in a))
    return T


@bi('vl-directory-files')
def _vl_directory_files(I, a):
    d = strp(a[0]) if a and a[0] is not None else '.'
    pat = strp(a[1]) if len(a) > 1 and a[1] is not None else '*.*'
    mode = a[2] if len(a) > 2 and a[2] is not None else 0
    p = resolve_path(I, d)
    if p is None or not os.path.isdir(p):
        return None
    res = []
    for f in sorted(os.listdir(p)):
        full = os.path.join(p, f)
        isd = os.path.isdir(full)
        if mode == -1 and not isd or mode == 1 and isd:
            continue
        if wcmatch(f.upper(), pat.upper().replace('*.*', '*')):
            res.append(f)
    return L(res)


@bi('vl-filename-base')
def _vl_filename_base(I, a):
    s = strp(a[0]).replace('/', '\\').split('\\')[-1]
    return s.rsplit('.', 1)[0] if '.' in s else s


@bi('vl-filename-extension')
def _vl_filename_extension(I, a):
    s = strp(a[0]).replace('/', '\\').split('\\')[-1]
    return '.' + s.rsplit('.', 1)[1] if '.' in s else None


@bi('vl-filename-directory')
def _vl_filename_directory(I, a):
    s = strp(a[0])
    i = max(s.rfind('\\'), s.rfind('/'))
    return s[:i] if i >= 0 else ''


@bi('vl-filename-mktemp')
def _vl_filename_mktemp(I, a):
    I.uid += 1
    base = strp(a[0]) if a and a[0] else '$VL~~'
    return os.path.join(I.outdir, 'lisp_files', '%s%03d' % (base.split('.')[0], I.uid)).replace('/', '\\')


@bi('load', 'full')
def _load(I, a):
    argn(a, 1, 2)
    name = strp(a[0])
    p = resolve_path(I, name)
    if p is None and not name.lower().endswith(('.lsp', '.fas', '.vlx', '.mnl')):
        p = resolve_path(I, name + '.lsp')
    if p is None or not p.lower().endswith(('.lsp', '.mnl')):
        if p is not None:
            I.warn('%s（コンパイル済みファイル）は読み込めません' % name)
        if len(a) > 1:
            fb = a[1]
            if isinstance(fb, (UFunc, Subr)) or (isinstance(fb, list) and fb and fb[0] is S('lambda')):
                return I.call(I.fn_of(fb), [])
            return fb
        raise LispError('LOAD failed: "%s"' % name)
    I.echo('')
    return I.load_file(p)




# =====================================================================
#  幾何計算
# =====================================================================
def lwpoly_verts(o):
    verts = []
    for c, v in o.main():
        if c == 10:
            verts.append({'pt': (v[0], v[1]), 'sw': 0.0, 'ew': 0.0, 'b': 0.0})
        elif verts and c == 40:
            verts[-1]['sw'] = v
        elif verts and c == 41:
            verts[-1]['ew'] = v
        elif verts and c == 42:
            verts[-1]['b'] = v
    return verts


def set_lwpoly_verts(o, verts):
    p = o.p
    k = xdata_start(p)
    main, xd = p[:k], p[k:]
    idx = [i for i, (c, v) in enumerate(main) if c in (10, 40, 41, 42, 91)]
    first = idx[0] if idx else len(main)
    last = idx[-1] if idx else len(main) - 1
    head = [pr for pr in main[:first] if pr[0] != 90]
    tail = main[last + 1:]
    vp = []
    for vx in verts:
        vp.append((10, (float(vx['pt'][0]), float(vx['pt'][1]))))
        if vx.get('sw') or vx.get('ew'):
            vp.append((40, float(vx.get('sw', 0.0))))
            vp.append((41, float(vx.get('ew', 0.0))))
        if vx.get('b'):
            vp.append((42, float(vx['b'])))
    # 90 は AcDbPolyline マーカーの直後
    ins = len(head)
    for i, (c, v) in enumerate(head):
        if c == 100 and v == 'AcDbPolyline':
            ins = i + 1
            break
    else:
        for i, (c, v) in enumerate(head):
            if c == 70:
                ins = i
                break
    head.insert(ins, (90, len(verts)))
    o.p = head + vp + tail + xd


def heavy_verts(dwg, o):
    cont = dwg.container_of(o)
    if cont is None:
        return []
    i = cont.index(o) + 1
    verts = []
    while i < len(cont) and cont[i].typ == 'VERTEX':
        v = cont[i]
        if not v.deleted and not (v.get(70, 0) & 16):
            pt = v.get(10, (0.0, 0.0, 0.0))
            verts.append({'pt': (pt[0], pt[1]), 'b': v.get(42, 0.0), 'z': pt[2] if len(pt) > 2 else 0.0})
        i += 1
    return verts


def bulge_arc(p1, p2, b):
    sweep = 4.0 * math.atan(b)
    dx, dy = p2[0] - p1[0], p2[1] - p1[1]
    c = math.hypot(dx, dy)
    if c < 1e-14:
        return None
    r = c / (2.0 * math.sin(abs(sweep) / 2.0))
    h = (c / 2.0) / math.tan(sweep / 2.0)
    ux, uy = dx / c, dy / c
    mx, my = (p1[0] + p2[0]) / 2.0, (p1[1] + p2[1]) / 2.0
    cx, cy = mx - uy * h, my + ux * h
    a0 = math.atan2(p1[1] - cy, p1[0] - cx)
    return ('A', cx, cy, abs(r), a0, sweep)


def verts_prims(verts, closed):
    prims = []
    n = len(verts)
    m = n if closed else n - 1
    for i in range(max(0, m)):
        v1 = verts[i]
        v2 = verts[(i + 1) % n]
        b = v1.get('b', 0.0) or 0.0
        if abs(b) > 1e-12:
            a = bulge_arc(v1['pt'], v2['pt'], b)
            if a:
                prims.append(a)
                continue
        prims.append(('L', v1['pt'][0], v1['pt'][1], v2['pt'][0], v2['pt'][1]))
    return prims


def ellipse_points(o, n=64):
    c = o.get(10, (0.0, 0.0, 0.0))
    m = o.get(11, (1.0, 0.0, 0.0))
    r = o.get(40, 1.0)
    t0 = o.get(41, 0.0)
    t1 = o.get(42, TWO_PI)
    if t1 <= t0:
        t1 += TWO_PI
    mn = (-m[1] * r, m[0] * r)
    pts = []
    for i in range(n + 1):
        t = t0 + (t1 - t0) * i / n
        pts.append((c[0] + m[0] * math.cos(t) + mn[0] * math.sin(t), c[1] + m[1] * math.cos(t) + mn[1] * math.sin(t)))
    return pts


def spline_points(o, n=80):
    deg = o.get(71, 3)
    knots = o.getall(40)
    ctrl = [v for v in o.getall(10)]
    fit = [v for v in o.getall(11)]
    if ctrl and knots and len(knots) == len(ctrl) + deg + 1:
        pts = []
        lo, hi = knots[deg], knots[len(ctrl)]
        for i in range(n + 1):
            u = lo + (hi - lo) * i / n
            pts.append(_deboor(deg, knots, ctrl, u))
        return pts
    src = fit or ctrl
    return [(v[0], v[1]) for v in src]


def _deboor(p, U, P, u):
    n = len(P) - 1
    if u >= U[n + 1]:
        k = n
    else:
        k = p
        while k < n and not (U[k] <= u < U[k + 1]):
            k += 1
    d = [[P[j + k - p][0], P[j + k - p][1]] for j in range(p + 1)]
    for r in range(1, p + 1):
        for j in range(p, r - 1, -1):
            den = U[j + 1 + k - r] - U[j + k - p]
            alpha = 0.0 if den == 0 else (u - U[j + k - p]) / den
            d[j] = [(1 - alpha) * d[j - 1][0] + alpha * d[j][0], (1 - alpha) * d[j - 1][1] + alpha * d[j][1]]
    return (d[p][0], d[p][1])


def pts_to_prims(pts, closed=False):
    prims = []
    for i in range(len(pts) - 1):
        prims.append(('L', pts[i][0], pts[i][1], pts[i + 1][0], pts[i + 1][1]))
    if closed and len(pts) > 2:
        prims.append(('L', pts[-1][0], pts[-1][1], pts[0][0], pts[0][1]))
    return prims


def ent_prims(dwg, o):
    t = o.typ
    g = o.get
    if t == 'LINE':
        a, b = g(10, (0, 0, 0)), g(11, (0, 0, 0))
        return [('L', a[0], a[1], b[0], b[1])]
    if t == 'CIRCLE':
        c = g(10, (0, 0, 0))
        return [('A', c[0], c[1], g(40, 0.0), 0.0, TWO_PI)]
    if t == 'ARC':
        c = g(10, (0, 0, 0))
        a0 = math.radians(g(50, 0.0))
        a1 = math.radians(g(51, 0.0))
        sw = ang_norm(a1 - a0)
        if sw < 1e-12:
            sw = TWO_PI
        return [('A', c[0], c[1], g(40, 0.0), a0, sw)]
    if t == 'LWPOLYLINE':
        return verts_prims(lwpoly_verts(o), bool(g(70, 0) & 1))
    if t == 'POLYLINE':
        if g(70, 0) & (16 | 64):
            return []
        return verts_prims(heavy_verts(dwg, o), bool(g(70, 0) & 1))
    if t == 'ELLIPSE':
        return pts_to_prims(ellipse_points(o))
    if t == 'SPLINE':
        return pts_to_prims(spline_points(o), bool(g(70, 0) & 1))
    if t in ('SOLID', 'TRACE', '3DFACE'):
        pts = [g(c) for c in (10, 11, 13, 12) if g(c) is not None] if t != '3DFACE' else \
            [g(c) for c in (10, 11, 12, 13) if g(c) is not None]
        return pts_to_prims([(p[0], p[1]) for p in pts], True)
    if t == 'LEADER':
        return pts_to_prims([(p[0], p[1]) for p in o.getall(10)])
    return []


def arc_extent_pts(pr):
    _, cx, cy, r, a0, sw = pr
    pts = [(cx + r * math.cos(a0), cy + r * math.sin(a0)), (cx + r * math.cos(a0 + sw), cy + r * math.sin(a0 + sw))]
    for k in range(4):
        ang = k * math.pi / 2
        if ang_in_arc(ang, a0, sw):
            pts.append((cx + r * math.cos(ang), cy + r * math.sin(ang)))
    return pts


def ang_in_arc(a, a0, sw, eps=1e-9):
    if abs(sw) >= TWO_PI - 1e-12:
        return True
    if sw >= 0:
        return ang_norm(a - a0) <= sw + eps
    return ang_norm(a0 - a) <= -sw + eps


def prim_pts(pr):
    if pr[0] == 'L':
        return [(pr[1], pr[2]), (pr[3], pr[4])]
    return arc_extent_pts(pr)


def text_corners(o):
    t = o.typ
    ins = o.get(10, (0.0, 0.0, 0.0))
    h = o.get(40, 2.5) or 2.5
    s = str(o.get(1, ''))
    if t == 'MTEXT':
        s = mtext_plain(o)
        lines = s.split('\n')
        w = o.get(41, 0.0) or max(text_width(l, h) for l in lines)
        hh = h * 1.6 * len(lines)
        ap = o.get(71, 1)
        col = (ap - 1) % 3
        row = (ap - 1) // 3
        x0 = -w * col / 2.0
        y0 = -hh * (2 - row) / 2.0 if row else -hh + 0.0
        y0 = {0: -hh, 1: -hh / 2.0, 2: 0.0}[row]
        rot = o.get(50, None)
        if rot is None:
            d = o.get(11)
            rot = math.atan2(d[1], d[0]) if d else 0.0
        corners = [(x0, y0), (x0 + w, y0), (x0 + w, y0 + hh), (x0, y0 + hh)]
        base = ins
    else:
        wf = o.get(41, 1.0) or 1.0
        w = text_width(s, h, wf)
        h72, v73 = o.get(72, 0), o.get(73 if t != 'ATTRIB' and t != 'ATTDEF' else 74, 0)
        base = ins
        dx = 0.0
        dy = 0.0
        if h72 or v73:
            base = o.get(11, ins)
            dx = {0: 0.0, 1: -w / 2, 2: -w, 3: 0.0, 4: -w / 2, 5: 0.0}.get(h72, 0.0)
            dy = {0: 0.0, 1: -0.0, 2: -h / 2, 3: -h}.get(v73, 0.0)
            if h72 == 4:
                dy = -h / 2
            if h72 in (3, 5):
                base = ins
        rot = math.radians(o.get(50, 0.0))
        corners = [(dx, dy), (dx + w, dy), (dx + w, dy + h), (dx, dy + h)]
    cr, sr = math.cos(rot), math.sin(rot)
    return [(base[0] + x * cr - y * sr, base[1] + x * sr + y * cr) for x, y in corners]


def mtext_plain(o):
    s = ''.join(str(v) for c, v in o.main() if c == 3) + str(o.get(1, ''))
    s = re.sub(r'\\P', '\n', s)
    s = re.sub(r'\\[ACFfHQTWLlOoKk][^;\\]*;?', '', s)
    s = re.sub(r'\\S([^;]*)\^([^;]*);', r'\1/\2', s)
    s = s.replace('{', '').replace('}', '').replace('\\~', ' ').replace('\\\\', '\\')
    return s


def insert_xf(dwg, o):
    b = dwg.blocks().get(str(o.get(2, '')).upper())
    base = b['block'].get(10, (0.0, 0.0, 0.0)) if b else (0.0, 0.0, 0.0)
    ins = o.get(10, (0.0, 0.0, 0.0))
    sx, sy = o.get(41, 1.0), o.get(42, 1.0)
    rot = math.radians(o.get(50, 0.0))
    cr, sr = math.cos(rot), math.sin(rot)

    def f(p):
        x = (p[0] - base[0]) * sx
        y = (p[1] - base[1]) * sy
        return (ins[0] + x * cr - y * sr, ins[1] + x * sr + y * cr)
    return b, f


def ent_sample_points(dwg, o, depth=0):
    t = o.typ
    if t in ('TEXT', 'MTEXT', 'ATTRIB', 'ATTDEF'):
        return text_corners(o)
    if t == 'INSERT' or t == 'DIMENSION':
        b, f = insert_xf(dwg, o) if t == 'INSERT' else (dwg.blocks().get(str(o.get(2, '')).upper()), lambda p: (p[0], p[1]))
        pts = []
        if b and depth < 4:
            for e in b['ents']:
                if not e.deleted and e.typ != 'ATTDEF':
                    pts += [f(p) for p in ent_sample_points(dwg, e, depth + 1)]
        if t == 'INSERT':
            cont = dwg.container_of(o)
            if cont is not None and o.get(66, 0):
                i = cont.index(o) + 1
                while i < len(cont) and cont[i].typ == 'ATTRIB':
                    if not cont[i].deleted:
                        pts += text_corners(cont[i])
                    i += 1
        if not pts:
            p = o.get(10, (0.0, 0.0, 0.0))
            pts = [(p[0], p[1])]
        return pts
    prims = ent_prims(dwg, o)
    if prims:
        pts = []
        for pr in prims:
            pts += prim_pts(pr)
        return pts
    if t == 'HATCH':
        return [(v[0], v[1]) for c, v in o.main() if c in (10, 11) and type(v) is tuple]
    if t == 'MULTILEADER':
        # 引出線の点＋文字の四角（概算。文字は左上基準とみなす）
        secs = mld_scan(o)
        pts = [(x[2][0], x[2][1]) for x in secs if type(x[2]) is tuple and x[1] == 10
               and x[3] in ('ctx', 'leader', 'line')]
        ins = [x[2] for x in secs if x[3] == 'ctx' and x[1] == 12 and type(x[2]) is tuple]
        hs = [x[2] for x in secs if x[3] == 'ctx' and x[1] == 41]
        ts = [x[2] for x in secs if x[3] == 'ctx' and x[1] == 304]
        if ins and hs and ts:
            h = float(hs[0])
            w = text_width(str(ts[0]).replace('\\P', ''), h)
            x0, y0 = ins[0][0], ins[0][1]
            pts += [(x0, y0), (x0 + w, y0), (x0 + w, y0 - h), (x0, y0 - h)]
        return pts
    pts = [(v[0], v[1]) for c, v in o.main() if 10 <= c <= 18 and type(v) is tuple]
    return pts


def ent_bbox(dwg, o):
    pts = ent_sample_points(dwg, o)
    if not pts:
        return None
    xs = [p[0] for p in pts]
    ys = [p[1] for p in pts]
    return (min(xs), min(ys), max(xs), max(ys))


def drawing_extents(dwg):
    bb = None
    for o in main_ents(dwg):
        b = ent_bbox(dwg, o)
        if not b:
            continue
        bb = b if bb is None else (min(bb[0], b[0]), min(bb[1], b[1]), max(bb[2], b[2]), max(bb[3], b[3]))
    return bb


def closest_on_prim(pr, pt):
    if pr[0] == 'L':
        x1, y1, x2, y2 = pr[1:]
        dx, dy = x2 - x1, y2 - y1
        L2 = dx * dx + dy * dy
        t = 0.0 if L2 == 0 else max(0.0, min(1.0, ((pt[0] - x1) * dx + (pt[1] - y1) * dy) / L2))
        return (x1 + t * dx, y1 + t * dy), t
    _, cx, cy, r, a0, sw = pr
    a = math.atan2(pt[1] - cy, pt[0] - cx)
    if ang_in_arc(a, a0, sw):
        t = (ang_norm(a - a0) if sw >= 0 else ang_norm(a0 - a)) / abs(sw)
        if abs(sw) >= TWO_PI - 1e-12:
            t = ang_norm(a - a0) / TWO_PI
        return (cx + r * math.cos(a), cy + r * math.sin(a)), t
    p1 = (cx + r * math.cos(a0), cy + r * math.sin(a0))
    p2 = (cx + r * math.cos(a0 + sw), cy + r * math.sin(a0 + sw))
    if math.dist(p1, pt[:2]) <= math.dist(p2, pt[:2]):
        return p1, 0.0
    return p2, 1.0


def ent_distance(dwg, o, pt):
    prims = ent_prims(dwg, o)
    if prims:
        return min(math.dist(closest_on_prim(pr, pt)[0], pt[:2]) for pr in prims)
    bb = ent_bbox(dwg, o)
    if not bb:
        return None
    dx = max(bb[0] - pt[0], 0, pt[0] - bb[2])
    dy = max(bb[1] - pt[1], 0, pt[1] - bb[3])
    return math.hypot(dx, dy)


def ent_pick_point(dwg, o):
    prims = ent_prims(dwg, o)
    z = 0.0
    if prims:
        pr = prims[0]
        if pr[0] == 'L':
            return ((pr[1] + pr[3]) / 2, (pr[2] + pr[4]) / 2, z)
        _, cx, cy, r, a0, sw = pr
        a = a0 + sw / 2
        return (cx + r * math.cos(a), cy + r * math.sin(a), z)
    p = o.get(10)
    if p:
        return to_pt3(p)
    return (0.0, 0.0, 0.0)


# --------------------------------------------------------------- 交点
def _seg_seg(a, b, ea, eb):
    x1, y1, x2, y2 = a[1:]
    x3, y3, x4, y4 = b[1:]
    den = (x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4)
    if abs(den) < 1e-14:
        return []
    t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / den
    u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / den
    e = 1e-9
    if (ea or -e <= t <= 1 + e) and (eb or -e <= u <= 1 + e):
        return [(x1 + t * (x2 - x1), y1 + t * (y2 - y1))]
    return []


def _seg_arc(s, c, es, ec):
    x1, y1, x2, y2 = s[1:]
    _, cx, cy, r, a0, sw = c
    dx, dy = x2 - x1, y2 - y1
    fx, fy = x1 - cx, y1 - cy
    A = dx * dx + dy * dy
    B = 2 * (fx * dx + fy * dy)
    C = fx * fx + fy * fy - r * r
    if A < 1e-20:
        return []
    disc = B * B - 4 * A * C
    if disc < -1e-12:
        return []
    disc = max(disc, 0.0)
    res = []
    for t in set([(-B - math.sqrt(disc)) / (2 * A), (-B + math.sqrt(disc)) / (2 * A)]):
        if not es and not (-1e-9 <= t <= 1 + 1e-9):
            continue
        px, py = x1 + t * dx, y1 + t * dy
        if not ec and not ang_in_arc(math.atan2(py - cy, px - cx), a0, sw):
            continue
        res.append((px, py))
    return res


def _arc_arc(a, b, ea, eb):
    _, x0, y0, r0, a0, s0 = a
    _, x1, y1, r1, a1, s1 = b
    d = math.hypot(x1 - x0, y1 - y0)
    if d < 1e-14 or d > r0 + r1 + 1e-9 or d < abs(r0 - r1) - 1e-9:
        return []
    aa = (r0 * r0 - r1 * r1 + d * d) / (2 * d)
    h = math.sqrt(max(r0 * r0 - aa * aa, 0.0))
    xm = x0 + aa * (x1 - x0) / d
    ym = y0 + aa * (y1 - y0) / d
    pts = [(xm + h * (y1 - y0) / d, ym - h * (x1 - x0) / d)]
    if h > 1e-12:
        pts.append((xm - h * (y1 - y0) / d, ym + h * (x1 - x0) / d))
    res = []
    for px, py in pts:
        if not ea and not ang_in_arc(math.atan2(py - y0, px - x0), a0, s0):
            continue
        if not eb and not ang_in_arc(math.atan2(py - y1, px - x1), a1, s1):
            continue
        res.append((px, py))
    return res


def prim_intersections(a, b, ea=False, eb=False):
    if a[0] == 'L' and b[0] == 'L':
        return _seg_seg(a, b, ea, eb)
    if a[0] == 'L':
        return _seg_arc(a, b, ea, eb)
    if b[0] == 'L':
        return _seg_arc(b, a, eb, ea)
    return _arc_arc(a, b, ea, eb)


def ent_intersections(dwg, o1, o2, mode=0):
    ea = mode in (1, 3)
    eb = mode in (2, 3)
    res = []
    for p in ent_prims(dwg, o1):
        for q in ent_prims(dwg, o2):
            for pt in prim_intersections(p, q, ea and o1.typ == 'LINE', eb and o2.typ == 'LINE'):
                if not any(math.dist(pt, r) < 1e-8 for r in res):
                    res.append(pt)
    return res


# --------------------------------------------------------------- 曲線 (vlax-curve)
class Curve:
    def __init__(self, dwg, o):
        self.o = o
        t = o.typ
        self.approx = False
        self.z = 0.0
        prims = ent_prims(dwg, o)
        if not prims:
            raise LispError('bad argument type: curve (曲線ではない図形 %s)' % t)
        if t == 'LINE':
            L_ = self.plen(prims[0])
            self.ranges = [(0.0, L_, prims[0])]
            self.z = o.get(10, (0, 0, 0))[2] if len(o.get(10, (0, 0, 0))) > 2 else 0.0
        elif t in ('ARC', 'CIRCLE'):
            pr = prims[0]
            a0 = pr[4] if t == 'ARC' else 0.0
            if t == 'ARC':
                a0 = math.radians(o.get(50, 0.0))
                a0 = ang_norm(a0)
                pr = ('A', pr[1], pr[2], pr[3], a0, pr[5])
            self.ranges = [(a0, a0 + pr[5], pr)]
            c = o.get(10, (0, 0, 0))
            self.z = c[2] if len(c) > 2 else 0.0
        elif t in ('LWPOLYLINE', 'POLYLINE'):
            self.ranges = [(float(i), float(i + 1), pr) for i, pr in enumerate(prims)]
            self.z = o.get(38, 0.0) if t == 'LWPOLYLINE' else 0.0
        else:
            self.approx = True
            n = len(prims)
            if t == 'ELLIPSE':
                t0, t1 = o.get(41, 0.0), o.get(42, TWO_PI)
                if t1 <= t0:
                    t1 += TWO_PI
            else:
                t0, t1 = 0.0, 1.0
            self.ranges = [(t0 + (t1 - t0) * i / n, t0 + (t1 - t0) * (i + 1) / n, pr) for i, pr in enumerate(prims)]
        self.closed = self._closed()

    def _closed(self):
        t = self.o.typ
        if t == 'CIRCLE':
            return True
        if t in ('LWPOLYLINE', 'POLYLINE', 'SPLINE'):
            return bool(self.o.get(70, 0) & 1)
        if t == 'ELLIPSE':
            return abs(self.end_param() - self.start_param() - TWO_PI) < 1e-9
        return False

    @staticmethod
    def plen(pr):
        if pr[0] == 'L':
            return math.hypot(pr[3] - pr[1], pr[4] - pr[2])
        return abs(pr[5]) * pr[3]

    @staticmethod
    def ppoint(pr, t):
        if pr[0] == 'L':
            return (pr[1] + (pr[3] - pr[1]) * t, pr[2] + (pr[4] - pr[2]) * t)
        a = pr[4] + pr[5] * t
        return (pr[1] + pr[3] * math.cos(a), pr[2] + pr[3] * math.sin(a))

    @staticmethod
    def pderiv(pr):
        if pr[0] == 'L':
            return lambda t: (pr[3] - pr[1], pr[4] - pr[2])
        return lambda t: (-pr[5] * pr[3] * math.sin(pr[4] + pr[5] * t), pr[5] * pr[3] * math.cos(pr[4] + pr[5] * t))

    def start_param(self):
        return self.ranges[0][0]

    def end_param(self):
        return self.ranges[-1][1]

    def locate(self, p):
        sp, ep = self.start_param(), self.end_param()
        if p < sp - 1e-9 or p > ep + 1e-9:
            return None
        for p0, p1, pr in self.ranges:
            if p <= p1 + 1e-12:
                t = 0.0 if p1 == p0 else (p - p0) / (p1 - p0)
                return pr, max(0.0, min(1.0, t)), p0, p1
        p0, p1, pr = self.ranges[-1]
        return pr, 1.0, p0, p1

    def point(self, p):
        r = self.locate(p)
        if r is None:
            return None
        x, y = self.ppoint(r[0], r[1])
        return [x, y, self.z]

    def dist_at_param(self, p):
        d = 0.0
        for p0, p1, pr in self.ranges:
            if p >= p1:
                d += self.plen(pr)
            else:
                t = 0.0 if p1 == p0 else (p - p0) / (p1 - p0)
                d += self.plen(pr) * max(0.0, t)
                break
        return d

    def length(self):
        return sum(self.plen(pr) for _, _, pr in self.ranges)

    def param_at_dist(self, d):
        if d < -1e-9 or d > self.length() + 1e-9:
            return None
        acc = 0.0
        for p0, p1, pr in self.ranges:
            L_ = self.plen(pr)
            if d <= acc + L_ + 1e-12:
                t = 0.0 if L_ == 0 else (d - acc) / L_
                return p0 + (p1 - p0) * max(0.0, min(1.0, t))
            acc += L_
        return self.end_param()

    def closest(self, pt):
        best = None
        for p0, p1, pr in self.ranges:
            q, t = closest_on_prim(pr, pt)
            d = math.dist(q, pt[:2])
            if best is None or d < best[0]:
                best = (d, p0 + (p1 - p0) * t, q)
        return best

    def deriv(self, p):
        r = self.locate(p)
        if r is None:
            return None
        pr, t, p0, p1 = r
        dx, dy = self.pderiv(pr)(t)
        k = 1.0 / (p1 - p0) if p1 != p0 else 1.0
        return [dx * k, dy * k, 0.0]

    def area(self):
        t = self.o.typ
        if t == 'CIRCLE':
            r = self.ranges[0][2][3]
            return math.pi * r * r
        a = 0.0
        pts = []
        for _, _, pr in self.ranges:
            p1 = self.ppoint(pr, 0.0)
            p2 = self.ppoint(pr, 1.0)
            a += p1[0] * p2[1] - p2[0] * p1[1]
            if pr[0] == 'A':
                s = pr[5]
                a += pr[3] ** 2 * (s - math.sin(s)) * (1 if s >= 0 else 1)
            pts.append(p1)
        # 閉じていない場合は終点→始点を結ぶ
        e = self.ppoint(self.ranges[-1][2], 1.0)
        s0 = self.ppoint(self.ranges[0][2], 0.0)
        a += e[0] * s0[1] - s0[0] * e[1]
        return abs(a) / 2.0


def curve_of(I, x):
    if type(x) is VlaObj and x.kind == 'ent':
        o = I.dwg.get(x.ref[0])
    elif type(x) is Ename:
        o = I.dwg.get(x.h)
    else:
        raise LispError('bad argument type: lentityp ' + short(x))
    if o is None or o.deleted:
        raise LispError('bad argument type: lentityp ' + short(x))
    c = Curve(I.dwg, o)
    if c.approx:
        I.warn('%s の vlax-curve 計算は折れ線近似です' % o.typ)
    if o.get(210) and tuple(o.get(210))[:3] != (0.0, 0.0, 1.0):
        I.warn('押し出し方向(210)が Z 軸以外の図形は座標が正しく計算されません')
    return c


def _pt_arg(x):
    if type(x) is Variant or type(x) is SafeArray:
        x = pyval(x)
    return to_pt3(ptp(x))


@bi('vlax-curve-getstartparam')
def _vc_sp(I, a):
    argn(a, 1, 1)
    return curve_of(I, a[0]).start_param()


@bi('vlax-curve-getendparam')
def _vc_ep(I, a):
    argn(a, 1, 1)
    return curve_of(I, a[0]).end_param()


@bi('vlax-curve-getstartpoint')
def _vc_spt(I, a):
    argn(a, 1, 1)
    c = curve_of(I, a[0])
    return c.point(c.start_param())


@bi('vlax-curve-getendpoint')
def _vc_ept(I, a):
    argn(a, 1, 1)
    c = curve_of(I, a[0])
    return c.point(c.end_param())


@bi('vlax-curve-getpointatparam')
def _vc_pap(I, a):
    argn(a, 2, 2)
    return curve_of(I, a[0]).point(float(num(a[1])))


@bi('vlax-curve-getdistatparam')
def _vc_dap(I, a):
    argn(a, 2, 2)
    c = curve_of(I, a[0])
    p = float(num(a[1]))
    if p < c.start_param() - 1e-9 or p > c.end_param() + 1e-9:
        return None
    return c.dist_at_param(p)


@bi('vlax-curve-getparamatdist')
def _vc_pad(I, a):
    argn(a, 2, 2)
    return curve_of(I, a[0]).param_at_dist(float(num(a[1])))


@bi('vlax-curve-getpointatdist')
def _vc_ptad(I, a):
    argn(a, 2, 2)
    c = curve_of(I, a[0])
    p = c.param_at_dist(float(num(a[1])))
    return None if p is None else c.point(p)


@bi('vlax-curve-getdistatpoint')
def _vc_dapt(I, a):
    argn(a, 2, 2)
    c = curve_of(I, a[0])
    pt = _pt_arg(a[1])
    d, p, q = c.closest(pt)
    if d > 1e-6:
        return None
    return c.dist_at_param(p)


@bi('vlax-curve-getparamatpoint')
def _vc_papt(I, a):
    argn(a, 2, 2)
    c = curve_of(I, a[0])
    pt = _pt_arg(a[1])
    d, p, q = c.closest(pt)
    if d > 1e-6:
        return None
    return p


@bi('vlax-curve-getclosestpointto vlax-curve-getclosestpointtoprojection')
def _vc_closest(I, a):
    argn(a, 2, 4)
    c = curve_of(I, a[0])
    pt = _pt_arg(a[1])
    if len(a) > 2 and a[2] is not None and c.o.typ == 'LINE' and isinstance(a[2], list) is False:
        pass
    d, p, q = c.closest(pt)
    if len(a) > 2 and a[2] is not None and c.o.typ == 'LINE':
        pr = c.ranges[0][2]
        x1, y1, x2, y2 = pr[1:]
        dx, dy = x2 - x1, y2 - y1
        L2 = dx * dx + dy * dy
        if L2 > 0:
            t = ((pt[0] - x1) * dx + (pt[1] - y1) * dy) / L2
            q = (x1 + t * dx, y1 + t * dy)
    return [q[0], q[1], c.z]


@bi('vlax-curve-getfirstderiv')
def _vc_d1(I, a):
    argn(a, 2, 2)
    return curve_of(I, a[0]).deriv(float(num(a[1])))


@bi('vlax-curve-getsecondderiv', 'approx')
def _vc_d2(I, a):
    argn(a, 2, 2)
    c = curve_of(I, a[0])
    p = float(num(a[1]))
    h = 1e-6
    d1 = c.deriv(max(c.start_param(), p - h))
    d2 = c.deriv(min(c.end_param(), p + h))
    if d1 is None or d2 is None:
        return None
    return [(y - x) / (2 * h) for x, y in zip(d1, d2)]


@bi('vlax-curve-getarea')
def _vc_area(I, a):
    argn(a, 1, 1)
    return curve_of(I, a[0]).area()


@bi('vlax-curve-isclosed')
def _vc_closed(I, a):
    argn(a, 1, 1)
    return truth(curve_of(I, a[0]).closed)


@bi('vlax-curve-isperiodic')
def _vc_periodic(I, a):
    argn(a, 1, 1)
    c = curve_of(I, a[0])
    return truth(c.o.typ in ('CIRCLE',) or (c.o.typ == 'ELLIPSE' and c.closed))


@bi('vlax-curve-isplanar')
def _vc_planar(I, a):
    argn(a, 1, 1)
    curve_of(I, a[0])
    return T


# =====================================================================
#  ActiveX (vla / vlax) 簡易再現
# =====================================================================
ENT_IFACE = {'LINE': 'Line', 'CIRCLE': 'Circle', 'ARC': 'Arc', 'LWPOLYLINE': 'LWPolyline', 'POLYLINE': 'Polyline',
             'TEXT': 'Text', 'MTEXT': 'MText', 'INSERT': 'BlockReference', 'ATTRIB': 'AttributeReference',
             'ATTDEF': 'Attribute', 'POINT': 'Point', 'ELLIPSE': 'Ellipse', 'SPLINE': 'Spline', 'HATCH': 'Hatch',
             'DIMENSION': 'DimRotated', 'SOLID': 'Solid', '3DFACE': '3DFace', 'LEADER': 'Leader',
             'MULTILEADER': 'MLeader', 'XLINE': 'XLine', 'RAY': 'Ray', 'VIEWPORT': 'PViewport',
             'REGION': 'Region', '3DSOLID': '3DSolid', 'TABLE': 'Table', 'WIPEOUT': 'Wipeout', 'IMAGE': 'RasterImage'}
OBJNAME = {'LINE': 'AcDbLine', 'CIRCLE': 'AcDbCircle', 'ARC': 'AcDbArc', 'LWPOLYLINE': 'AcDbPolyline',
           'POLYLINE': 'AcDb2dPolyline', 'TEXT': 'AcDbText', 'MTEXT': 'AcDbMText', 'INSERT': 'AcDbBlockReference',
           'ATTRIB': 'AcDbAttribute', 'ATTDEF': 'AcDbAttributeDefinition', 'POINT': 'AcDbPoint',
           'ELLIPSE': 'AcDbEllipse', 'SPLINE': 'AcDbSpline', 'HATCH': 'AcDbHatch', 'DIMENSION': 'AcDbRotatedDimension',
           'SOLID': 'AcDbTrace', '3DFACE': 'AcDbFace', 'LEADER': 'AcDbLeader', 'MULTILEADER': 'AcDbMLeader',
           'XLINE': 'AcDbXline', 'RAY': 'AcDbRay', 'VIEWPORT': 'AcDbViewport', 'REGION': 'AcDbRegion',
           '3DSOLID': 'AcDb3dSolid', 'TABLE': 'AcDbTable', 'WIPEOUT': 'AcDbWipeout', 'IMAGE': 'AcDbRasterImage'}
ALIGN_MAP = {(0, 0): 0, (1, 0): 1, (2, 0): 2, (3, 0): 3, (4, 0): 4, (5, 0): 5, (0, 3): 6, (1, 3): 7, (2, 3): 8,
             (0, 2): 9, (1, 2): 10, (2, 2): 11, (0, 1): 12, (1, 1): 13, (2, 1): 14}
ALIGN_INV = dict((v, k) for k, v in ALIGN_MAP.items())

CONSTANTS.update({
    'acByLayer': 256, 'acByBlock': 0, 'acRed': 1, 'acYellow': 2, 'acGreen': 3, 'acCyan': 4, 'acBlue': 5,
    'acMagenta': 6, 'acWhite': 7, 'acExtendNone': 0, 'acExtendThisEntity': 1, 'acExtendOtherEntity': 2,
    'acExtendBoth': 3, 'acModelSpace': 1, 'acPaperSpace': 0, 'acAlignmentLeft': 0, 'acAlignmentCenter': 1,
    'acAlignmentRight': 2, 'acAlignmentAligned': 3, 'acAlignmentMiddle': 4, 'acAlignmentFit': 5,
    'acAlignmentTopLeft': 6, 'acAlignmentTopCenter': 7, 'acAlignmentTopRight': 8, 'acAlignmentMiddleLeft': 9,
    'acAlignmentMiddleCenter': 10, 'acAlignmentMiddleRight': 11, 'acAlignmentBottomLeft': 12,
    'acAlignmentBottomCenter': 13, 'acAlignmentBottomRight': 14, 'acAttachmentPointTopLeft': 1,
    'acAttachmentPointTopCenter': 2, 'acAttachmentPointTopRight': 3, 'acAttachmentPointMiddleLeft': 4,
    'acAttachmentPointMiddleCenter': 5, 'acAttachmentPointMiddleRight': 6, 'acAttachmentPointBottomLeft': 7,
    'acAttachmentPointBottomCenter': 8, 'acAttachmentPointBottomRight': 9, 'acLnWtByLayer': -1,
    'acLnWtByBlock': -2, 'acLnWtByLwDefault': -3, 'acActiveViewport': 0, 'acAllViewports': 1,
    'vlax-vbEmpty': 0, 'vlax-vbNull': 1, 'vlax-vbInteger': 2, 'vlax-vbLong': 3, 'vlax-vbSingle': 4,
    'vlax-vbDouble': 5, 'vlax-vbCurrency': 6, 'vlax-vbDate': 7, 'vlax-vbString': 8, 'vlax-vbObject': 9,
    'vlax-vbBoolean': 11, 'vlax-vbVariant': 12, 'vlax-vbArray': 8192, 'acUCS': 1, 'acWorld': 0,
    'acDisplay': 2, 'acOn': -1, 'acOff': 0, 'acTrue': -1, 'acFalse': 0, 'acSelectionSetAll': 5,
})


def vb(b, raw=False):
    if raw:
        return -1 if b else 0
    return VTRUE if b else VFALSE


def truthy_vb(v):
    v = pyval(v)
    if v is VTRUE or v is T or v is True:
        return True
    if v is VFALSE or v is None or v is False:
        return False
    if isnum(v):
        return v != 0
    return bool(v)


def vpt(p, raw=False):
    vals = [float(x) for x in p]
    if raw:
        return vals
    return Variant(8197, SafeArray(5, [(0, len(vals) - 1)], vals))


def varr(vals, vt=5, raw=False):
    vals = list(vals)
    if raw:
        return L(vals)
    return Variant(8192 + vt, SafeArray(vt, [(0, len(vals) - 1)], vals))


def pyval(v):
    if type(v) is Variant:
        return pyval(v.val)
    if type(v) is SafeArray:
        return [pyval(x) for x in v.data]
    if isinstance(v, list):
        return [pyval(x) for x in v]
    return v


def vobj_ent(o):
    return VlaObj('ent', (o.h, ENT_IFACE.get(o.typ, 'Entity')))


def vobj_any(dwg, o):
    if o.sec in ('ENTITIES', 'BLOCKS') and o.typ not in ('BLOCK', 'ENDBLK'):
        return vobj_ent(o)
    if o.typ == 'BLOCK_RECORD':
        return VlaObj('blk', str(o.get(2, '')).upper())
    if o.typ == 'BLOCK':
        return VlaObj('blk', str(o.get(2, '')).upper())
    if o.sec == 'TABLES':
        return VlaObj('rec', (o.typ, o.h))
    return VlaObj('obj', o.h)


def need_vla(x):
    if type(x) is not VlaObj:
        raise LispError('bad argument type: VLA-OBJECT ' + short(x))
    return x


def ent_of_vla(I, x):
    need_vla(x)
    if x.kind != 'ent':
        return None
    o = I.dwg.get(x.ref[0])
    if o is None or o.deleted:
        raise LispError('Automation Error. Object was erased')
    return o


def unknown_name(name):
    return LispError('ActiveX Server returned the error: unknown name: %s' % name)


def _deg_prop(o, code, raw):
    return math.radians(o.get(code, 0.0))


def ent_get_prop(I, o, p, raw):
    t = o.typ
    g = o.get
    dwg = I.dwg
    if p == 'layer':
        return g(8, '0')
    if p == 'color':
        return g(62, 256)
    if p == 'linetype':
        return g(6, 'ByLayer')
    if p == 'linetypescale':
        return g(48, 1.0)
    if p == 'lineweight':
        return g(370, -1)
    if p == 'visible':
        return vb(g(60, 0) == 0, raw)
    if p == 'handle':
        return o.h
    if p == 'objectname':
        return OBJNAME.get(t, 'AcDb' + t.title())
    if p in ('entityname', 'entitytype'):
        return OBJNAME.get(t, t) if p == 'entityname' else 1
    if p in ('objectid', 'objectid32'):
        try:
            return int(o.h, 16)
        except ValueError:
            return 0
    if p in ('ownerid', 'ownerid32'):
        try:
            return int(str(g(330, '0')), 16)
        except ValueError:
            return 0
    if p == 'thickness':
        return g(39, 0.0)
    if p == 'document':
        return VlaObj('doc')
    if p == 'application':
        return VlaObj('app')
    if p == 'plotstylename':
        return 'ByLayer'
    if p == 'normal':
        return vpt(g(210, (0.0, 0.0, 1.0)), raw)
    if p == 'hasextensiondictionary':
        return vb(any(c == 102 and v == '{ACAD_XDICTIONARY' for c, v in o.p), raw)
    if p == 'truecolor':
        raise LispError('TrueColor プロパティは未対応です（Color を使ってください）')
    # --- 種類別
    if t == 'DIMENSION':
        if p == 'textposition':
            return vpt(to_pt3(g(11, (0, 0, 0))), raw)
        if p == 'textmovement':
            return 0
    if t == 'MULTILEADER':
        secs = mld_scan(o)
        if p == 'contenttype':
            v = [x[2] for x in secs if x[1] == 172 and x[3] == 'top']
            return int(v[-1]) if v else 2
        if p == 'leadercount':
            return len(set(x[4] for x in secs if x[3] in ('leader', 'line')))
        if p == 'textstring':
            v = [x[2] for x in secs if x[1] == 304 and x[3] == 'ctx']
            return str(v[0]) if v else ''
    if t == 'LINE':
        a, b = to_pt3(g(10, (0, 0, 0))), to_pt3(g(11, (0, 0, 0)))
        if p == 'startpoint':
            return vpt(a, raw)
        if p == 'endpoint':
            return vpt(b, raw)
        if p == 'length':
            return math.dist(a, b)
        if p == 'angle':
            return ang_norm(math.atan2(b[1] - a[1], b[0] - a[0]))
        if p == 'delta':
            return vpt([b[i] - a[i] for i in range(3)], raw)
    if t in ('CIRCLE', 'ARC'):
        r = g(40, 0.0)
        if p == 'center':
            return vpt(to_pt3(g(10, (0, 0, 0))), raw)
        if p == 'radius':
            return r
        if t == 'CIRCLE':
            if p == 'diameter':
                return 2 * r
            if p == 'circumference':
                return TWO_PI * r
            if p == 'area':
                return math.pi * r * r
        else:
            pr = ent_prims(dwg, o)[0]
            if p == 'startangle':
                return math.radians(g(50, 0.0))
            if p == 'endangle':
                return math.radians(g(51, 0.0))
            if p == 'startpoint':
                return vpt(list(Curve.ppoint(pr, 0.0)) + [0.0], raw)
            if p == 'endpoint':
                return vpt(list(Curve.ppoint(pr, 1.0)) + [0.0], raw)
            if p == 'arclength':
                return r * pr[5]
            if p == 'totalangle':
                return pr[5]
            if p == 'area':
                return r * r * (pr[5] - math.sin(pr[5])) / 2
    if t in ('TEXT', 'ATTRIB', 'ATTDEF'):
        if p == 'textstring':
            return g(1, '')
        if p == 'insertionpoint':
            return vpt(to_pt3(g(10, (0, 0, 0))), raw)
        if p == 'textalignmentpoint':
            return vpt(to_pt3(g(11, g(10, (0, 0, 0)))), raw)
        if p == 'height':
            return g(40, 2.5)
        if p == 'rotation':
            return math.radians(g(50, 0.0))
        if p == 'stylename':
            return g(7, 'Standard')
        if p == 'scalefactor':
            return g(41, 1.0)
        if p == 'obliqueangle':
            return math.radians(g(51, 0.0))
        if p == 'alignment':
            return ALIGN_MAP.get((g(72, 0), g(74 if t != 'TEXT' else 73, 0)), 0)
        if p == 'upsidedown':
            return vb(g(71, 0) & 4, raw)
        if p == 'backward':
            return vb(g(71, 0) & 2, raw)
        if t != 'TEXT':
            if p == 'tagstring':
                return g(2, '')
            if p == 'promptstring' and t == 'ATTDEF':
                return g(3, '')
            if p == 'invisible':
                return vb(g(70, 0) & 1, raw)
            if p == 'constant':
                return vb(g(70, 0) & 2, raw)
            if p == 'lockposition':
                return vb(g(280, 0), raw)
            if p == 'mtextattribute':
                return vb(False, raw)
    if t == 'MTEXT':
        if p == 'textstring':
            return ''.join(str(v) for c, v in o.main() if c == 3) + str(g(1, ''))
        if p == 'insertionpoint':
            return vpt(to_pt3(g(10, (0, 0, 0))), raw)
        if p == 'height':
            return g(40, 2.5)
        if p == 'width':
            return g(41, 0.0)
        if p == 'rotation':
            if g(50) is not None:
                return g(50)
            d = g(11)
            return ang_norm(math.atan2(d[1], d[0])) if d else 0.0
        if p == 'attachmentpoint':
            return g(71, 1)
        if p == 'stylename':
            return g(7, 'Standard')
        if p == 'linespacingfactor':
            return g(44, 1.0)
    if t == 'LWPOLYLINE':
        vs = lwpoly_verts(o)
        if p == 'coordinates':
            flat = []
            for v in vs:
                flat += [v['pt'][0], v['pt'][1]]
            return varr(flat, 5, raw)
        if p == 'closed':
            return vb(g(70, 0) & 1, raw)
        if p == 'constantwidth':
            return g(43, 0.0)
        if p == 'elevation':
            return g(38, 0.0)
        if p == 'length':
            return Curve(dwg, o).length()
        if p == 'area':
            return Curve(dwg, o).area() if vs else 0.0
        if p == 'linetypegeneration':
            return vb(g(70, 0) & 128, raw)
    if t == 'POLYLINE':
        if p == 'coordinates':
            flat = []
            for v in heavy_verts(dwg, o):
                flat += [v['pt'][0], v['pt'][1], v.get('z', 0.0)]
            return varr(flat, 5, raw)
        if p == 'closed':
            return vb(g(70, 0) & 1, raw)
        if p == 'length':
            return Curve(dwg, o).length()
        if p == 'area':
            return Curve(dwg, o).area()
    if t == 'INSERT':
        if p == 'insertionpoint':
            return vpt(to_pt3(g(10, (0, 0, 0))), raw)
        if p in ('name', 'effectivename'):
            nm = g(2, '')
            if p == 'effectivename' and nm.startswith('*U'):
                I.warn('ダイナミックブロック(匿名 %s)の EffectiveName は再現できません（名前をそのまま返しました）' % nm)
            return nm
        if p == 'xscalefactor' or p == 'xeffectivescalefactor':
            return g(41, 1.0)
        if p == 'yscalefactor' or p == 'yeffectivescalefactor':
            return g(42, 1.0)
        if p == 'zscalefactor' or p == 'zeffectivescalefactor':
            return g(43, 1.0)
        if p == 'rotation':
            return math.radians(g(50, 0.0))
        if p == 'hasattributes':
            return vb(g(66, 0) == 1, raw)
        if p == 'isdynamicblock':
            return vb(False, raw)
    if t == 'POINT':
        if p == 'coordinates':
            return vpt(to_pt3(g(10, (0, 0, 0))), raw)
    if t == 'ELLIPSE':
        c = to_pt3(g(10, (0, 0, 0)))
        m = to_pt3(g(11, (1, 0, 0)))
        r = g(40, 1.0)
        if p == 'center':
            return vpt(c, raw)
        if p == 'majoraxis':
            return vpt(m, raw)
        if p == 'minoraxis':
            return vpt([-m[1] * r, m[0] * r, 0.0], raw)
        if p == 'radiusratio':
            return r
        if p == 'majorradius':
            return math.hypot(m[0], m[1])
        if p == 'minorradius':
            return math.hypot(m[0], m[1]) * r
        if p == 'startparameter':
            return g(41, 0.0)
        if p == 'endparameter':
            return g(42, TWO_PI)
    if t == 'HATCH':
        if p == 'patternname':
            return g(2, '')
        if p == 'patternscale':
            return g(41, 1.0)
        if p == 'patternangle':
            return math.radians(g(52, 0.0))
    if t == 'DIMENSION':
        if p == 'measurement':
            return g(42, 0.0)
        if p == 'textoverride':
            return g(1, '')
        if p == 'stylename':
            return g(3, 'Standard')
    raise unknown_name(p)


def ent_put_prop(I, o, p, v):
    t = o.typ
    dwg = I.dwg
    val = pyval(v)
    if p == 'layer':
        if not dwg.find_rec('LAYER', strp(val)):
            raise LispError('Automation Error. Key not found (画層 "%s" がありません)' % val)
        o.set(8, dwg.find_rec('LAYER', val).get(2))
        return
    if p == 'color':
        o.set(62, int(num(val)))
        return
    if p == 'linetype':
        if str(val).upper() not in ('BYLAYER', 'BYBLOCK') and not dwg.find_rec('LTYPE', val):
            raise LispError('Automation Error. Key not found (線種 "%s" がありません)' % val)
        o.set(6, val)
        return
    if p == 'linetypescale':
        o.set(48, float(num(val)))
        return
    if p == 'lineweight':
        o.set(370, int(num(val)))
        return
    if p == 'visible':
        o.set(60, 0 if truthy_vb(v) else 1)
        return
    if p == 'thickness':
        o.set(39, float(num(val)))
        return
    if t == 'LINE':
        if p == 'startpoint':
            o.set(10, _pt_arg(val))
            return
        if p == 'endpoint':
            o.set(11, _pt_arg(val))
            return
    if t in ('CIRCLE', 'ARC'):
        if p == 'center':
            o.set(10, _pt_arg(val))
            return
        if p == 'radius':
            o.set(40, float(num(val)))
            return
        if p == 'diameter' and t == 'CIRCLE':
            o.set(40, float(num(val)) / 2)
            return
        if p == 'startangle' and t == 'ARC':
            o.set(50, math.degrees(ang_norm(float(num(val)))))
            return
        if p == 'endangle' and t == 'ARC':
            o.set(51, math.degrees(ang_norm(float(num(val)))))
            return
    if t in ('TEXT', 'ATTRIB', 'ATTDEF'):
        if p == 'textstring':
            o.set(1, strp(val))
            return
        if p == 'insertionpoint':
            np_ = _pt_arg(val)
            if o.get(72, 0) or o.get(73 if t == 'TEXT' else 74, 0):
                old = to_pt3(o.get(10, (0, 0, 0)))
                al = to_pt3(o.get(11, old))
                o.set(11, tuple(al[i] + np_[i] - old[i] for i in range(3)))
            o.set(10, np_)
            return
        if p == 'textalignmentpoint':
            o.set(11, _pt_arg(val))
            return
        if p == 'height':
            o.set(40, float(num(val)))
            return
        if p == 'rotation':
            o.set(50, math.degrees(float(num(val))))
            return
        if p == 'stylename':
            if not dwg.find_rec('STYLE', val):
                raise LispError('Automation Error. Key not found (文字スタイル "%s")' % val)
            o.set(7, val)
            return
        if p == 'scalefactor':
            o.set(41, float(num(val)))
            return
        if p == 'obliqueangle':
            o.set(51, math.degrees(float(num(val))))
            return
        if p == 'alignment':
            h, vv = ALIGN_INV.get(int(num(val)), (0, 0))
            if (h or vv) and o.get(11) is None:
                o.set(11, to_pt3(o.get(10, (0, 0, 0))))
            o.set(72, h)
            o.set(73 if t == 'TEXT' else 74, vv)
            return
        if p == 'tagstring' and t != 'TEXT':
            o.set(2, strp(val))
            return
        if p == 'promptstring' and t == 'ATTDEF':
            o.set(3, strp(val))
            return
        if p == 'invisible' and t != 'TEXT':
            f = o.get(70, 0)
            o.set(70, (f | 1) if truthy_vb(v) else (f & ~1))
            return
    if t == 'MTEXT':
        if p == 'textstring':
            s = strp(val)
            o.p = [pr for pr in o.p if pr[0] != 3]
            chunks = [s[i:i + 250] for i in range(0, len(s), 250)] or ['']
            k = [c for c, _ in o.p].index(1) if any(c == 1 for c, _ in o.p) else len(o.p)
            o.p[k:k + 1] = [(3, c) for c in chunks[:-1]] + [(1, chunks[-1])]
            return
        if p == 'insertionpoint':
            o.set(10, _pt_arg(val))
            return
        if p == 'height':
            o.set(40, float(num(val)))
            return
        if p == 'width':
            o.set(41, float(num(val)))
            return
        if p == 'rotation':
            a = float(num(val))
            if o.get(11) is not None:
                o.set(11, (math.cos(a), math.sin(a), 0.0))
            o.set(50, a)
            return
        if p == 'attachmentpoint':
            o.set(71, int(num(val)))
            return
        if p == 'stylename':
            o.set(7, strp(val))
            return
    if t == 'LWPOLYLINE':
        if p == 'coordinates':
            flat = [float(x) for x in val]
            old = lwpoly_verts(o)
            nv = []
            for i in range(0, len(flat) - 1, 2):
                v0 = dict(old[i // 2]) if i // 2 < len(old) else {'sw': 0.0, 'ew': 0.0, 'b': 0.0}
                v0['pt'] = (flat[i], flat[i + 1])
                nv.append(v0)
            set_lwpoly_verts(o, nv)
            return
        if p == 'closed':
            f = o.get(70, 0)
            o.set(70, (f | 1) if truthy_vb(v) else (f & ~1))
            return
        if p == 'constantwidth':
            o.set(43, float(num(val)))
            return
        if p == 'elevation':
            o.set(38, float(num(val)))
            return
    if t == 'INSERT':
        if p == 'insertionpoint':
            newp = _pt_arg(val)
            old = to_pt3(o.get(10, (0, 0, 0)))
            d = [newp[i] - old[i] for i in range(3)]
            xform_ent(I, o, XF.move(d))
            return
        if p in ('xscalefactor', 'yscalefactor', 'zscalefactor'):
            o.set({'x': 41, 'y': 42, 'z': 43}[p[0]], float(num(val)))
            return
        if p == 'rotation':
            o.set(50, math.degrees(float(num(val))))
            return
    if t == 'DIMENSION' and p == 'textposition':
        # 文字の位置を動かす（寸法ブロック内の文字も同じだけ動かす＝「文字だけ自由に移動」の近似）
        newp = to_pt3([float(x) for x in val])
        old = to_pt3(o.get(11, (0.0, 0.0, 0.0)))
        dv = [newp[i] - old[i] for i in range(3)]
        o.set(11, tuple(newp))
        o.set(70, int(o.get(70, 0)) | 128)
        b = dwg.blocks().get(str(o.get(2, '')).upper())
        if b:
            for e in b['ents']:
                if e.typ in ('MTEXT', 'TEXT') and not e.deleted:
                    xform_ent(I, e, XF.move(dv))
        I.warn('寸法の TextPosition の変更は近似です（寸法線・補助線は再計算されません）')
        return
    if t == 'POINT' and p == 'coordinates':
        o.set(10, _pt_arg(val))
        return
    raise unknown_name(p)


def rec_get_prop(I, obj, p, raw):
    tname, h = obj.ref
    o = I.dwg.get(h)
    if o is None or o.deleted:
        raise LispError('Automation Error. Object was erased')
    g = o.get
    if p == 'name':
        return g(2, '')
    if p == 'handle':
        return o.h
    if p == 'objectname':
        return {'LAYER': 'AcDbLayerTableRecord', 'STYLE': 'AcDbTextStyleTableRecord',
                'LTYPE': 'AcDbLinetypeTableRecord', 'DIMSTYLE': 'AcDbDimStyleTableRecord',
                'APPID': 'AcDbRegAppTableRecord'}.get(tname, 'AcDbSymbolTableRecord')
    if p == 'document':
        return VlaObj('doc')
    if tname == 'LAYER':
        if p == 'color':
            return abs(g(62, 7))
        if p == 'layeron':
            return vb(g(62, 7) >= 0, raw)
        if p == 'freeze':
            return vb(g(70, 0) & 1, raw)
        if p == 'lock':
            return vb(g(70, 0) & 4, raw)
        if p == 'linetype':
            return g(6, 'Continuous')
        if p == 'lineweight':
            return g(370, -3)
        if p == 'plottable':
            return vb(g(290, 1) != 0, raw)
        if p == 'description':
            return ''
        if p == 'used':
            return vb(any(str(e.get(8, '')).upper() == str(g(2)).upper() for e in main_ents(I.dwg)), raw)
    if tname == 'STYLE':
        if p == 'height':
            return g(40, 0.0)
        if p == 'width':
            return g(41, 1.0)
        if p == 'fontfile':
            return g(3, '')
        if p == 'bigfontfile':
            return g(4, '')
        if p == 'obliqueangle':
            return math.radians(g(50, 0.0))
    if tname == 'LTYPE' and p == 'description':
        return g(3, '')
    raise unknown_name(p)


def rec_put_prop(I, obj, p, v):
    tname, h = obj.ref
    o = I.dwg.get(h)
    if o is None or o.deleted:
        raise LispError('Automation Error. Object was erased')
    val = pyval(v)
    if tname == 'LAYER':
        c = o.get(62, 7)
        if p == 'color':
            n = int(num(val))
            o.set(62, n if c >= 0 else -n)
            return
        if p == 'layeron':
            on = truthy_vb(v)
            if not on and str(o.get(2, '')).upper() == str(I.sysvars.get('CLAYER', '0')).upper():
                I.warn('現在画層を非表示にしました')
            o.set(62, abs(c) if on else -abs(c))
            return
        if p in ('freeze', 'lock'):
            bit = 1 if p == 'freeze' else 4
            if p == 'freeze' and truthy_vb(v) and str(o.get(2, '')).upper() == str(I.sysvars.get('CLAYER', '0')).upper():
                raise LispError('Automation Error. Invalid layer (現在画層はフリーズできません)')
            f = o.get(70, 0)
            o.set(70, (f | bit) if truthy_vb(v) else (f & ~bit))
            return
        if p == 'linetype':
            if not I.dwg.find_rec('LTYPE', val):
                raise LispError('Automation Error. Key not found (線種 "%s")' % val)
            o.set(6, val)
            return
        if p == 'lineweight':
            o.set(370, int(num(val)))
            return
        if p == 'plottable':
            o.set(290, 1 if truthy_vb(v) else 0)
            return
        if p == 'name':
            o.set(2, strp(val))
            return
        if p == 'description':
            I.warn('画層の説明(Description)は保存されません')
            return
    if tname == 'STYLE':
        m = {'height': 40, 'width': 41, 'fontfile': 3, 'bigfontfile': 4}
        if p in m:
            o.set(m[p], val if m[p] in (3, 4) else float(num(val)))
            return
    raise unknown_name(p)


def vla_get(I, obj, prop, raw=False):
    need_vla(obj)
    p = prop.lower()
    k = obj.kind
    dwg = I.dwg
    if p == 'application':
        return VlaObj('app')
    if k == 'app':
        if p == 'activedocument':
            return VlaObj('doc')
        if p == 'documents':
            return VlaObj('coll', 'documents')
        if p == 'name':
            return 'AutoCAD'
        if p == 'version':
            return '24.1s (LMS Tech)'
        if p == 'fullname':
            return 'C:\\Program Files\\Autodesk\\AutoCAD\\acad.exe'
        if p == 'preferences':
            return VlaObj('pref')
        if p == 'visible':
            return vb(True, raw)
        if p == 'caption':
            return 'AutoCAD - [%s]' % dwg.name
    if k == 'doc':
        if p in ('modelspace', 'paperspace', 'layers', 'blocks', 'textstyles', 'linetypes', 'dimstyles',
                 'registeredapplications'):
            return VlaObj('coll', p)
        if p == 'activelayer':
            r = dwg.find_rec('LAYER', I.sysvars.get('CLAYER', '0'))
            return VlaObj('rec', ('LAYER', r.h)) if r is not None else None
        if p == 'activetextstyle':
            r = dwg.find_rec('STYLE', I.sysvars.get('TEXTSTYLE', 'Standard'))
            return VlaObj('rec', ('STYLE', r.h)) if r is not None else None
        if p == 'activelinetype':
            r = dwg.find_rec('LTYPE', I.sysvars.get('CELTYPE', 'ByLayer'))
            return VlaObj('rec', ('LTYPE', r.h)) if r is not None else None
        if p == 'activespace':
            return 1
        if p == 'name':
            return dwg.name
        if p == 'fullname':
            return I.sysvars.get('DWGPREFIX', '') + dwg.name
        if p == 'path':
            return I.sysvars.get('DWGPREFIX', '').rstrip('\\')
        if p == 'utility':
            return VlaObj('util')
        if p == 'database':
            return VlaObj('doc')
        if p == 'saved':
            return vb(not I.dwg_changed(), raw)
        if p == 'readonly':
            return vb(False, raw)
        if p == 'activeselectionset':
            return VlaObj('ss', I.prev_ss.id if I.prev_ss else 0)
    if k == 'coll':
        if p == 'count':
            return len(vla_collection_items(I, obj))
        if p == 'name':
            return {'modelspace': '*Model_Space', 'paperspace': '*Paper_Space'}.get(obj.ref, obj.ref)
    if k == 'blk':
        b = dwg.blocks().get(obj.ref)
        if b is None:
            raise LispError('Automation Error. Object was erased')
        if p == 'name':
            return b['name']
        if p == 'count':
            return len([e for e in b['ents'] if not e.deleted])
        if p == 'origin':
            return vpt(to_pt3(b['block'].get(10, (0, 0, 0))), raw)
        if p in ('isxref', 'isdynamicblock', 'islayout'):
            return vb(p == 'islayout' and b['name'].upper().startswith(('*MODEL', '*PAPER')), raw)
        if p == 'objectname':
            return 'AcDbBlockTableRecord'
        if p == 'handle':
            return (b['rec'] or b['block']).h
        if p == 'comments':
            return b['block'].get(4, '')
    if k == 'rec':
        return rec_get_prop(I, obj, p, raw)
    if k == 'ent':
        return ent_get_prop(I, ent_of_vla(I, obj), p, raw)
    if k == 'ss':
        if p == 'count':
            return len(I.prev_ss.hs) if I.prev_ss else 0
    raise unknown_name(prop)


def vla_put(I, obj, prop, v):
    need_vla(obj)
    p = prop.lower()
    if obj.kind == 'ent':
        ent_put_prop(I, ent_of_vla(I, obj), p, v)
        return
    if obj.kind == 'rec':
        rec_put_prop(I, obj, p, v)
        return
    if obj.kind == 'doc':
        if p == 'activelayer':
            need_vla(v)
            _setvar(I, ['CLAYER', rec_get_prop(I, v, 'name', False)])
            return
        if p == 'activetextstyle':
            _setvar(I, ['TEXTSTYLE', rec_get_prop(I, v, 'name', False)])
            return
    if obj.kind == 'blk' and p == 'origin':
        b = I.dwg.blocks().get(obj.ref)
        b['block'].set(10, _pt_arg(pyval(v)))
        return
    raise unknown_name(prop)


def vla_collection_items(I, coll):
    need_vla(coll)
    dwg = I.dwg
    if coll.kind == 'coll':
        r = coll.ref
        if r == 'modelspace':
            return [vobj_ent(o) for o in main_ents(dwg) if o.get(67, 0) != 1]
        if r == 'paperspace':
            return [vobj_ent(o) for o in main_ents(dwg) if o.get(67, 0) == 1]
        if r == 'layers':
            return [VlaObj('rec', ('LAYER', o.h)) for o in dwg.records('LAYER')]
        if r == 'textstyles':
            return [VlaObj('rec', ('STYLE', o.h)) for o in dwg.records('STYLE') if o.get(2)]
        if r == 'linetypes':
            return [VlaObj('rec', ('LTYPE', o.h)) for o in dwg.records('LTYPE')]
        if r == 'dimstyles':
            return [VlaObj('rec', ('DIMSTYLE', o.h)) for o in dwg.records('DIMSTYLE')]
        if r == 'registeredapplications':
            return [VlaObj('rec', ('APPID', o.h)) for o in dwg.records('APPID')]
        if r == 'blocks':
            return [VlaObj('blk', n) for n in dwg.blocks()]
        if r == 'documents':
            return [VlaObj('doc')]
    if coll.kind == 'blk':
        b = dwg.blocks().get(coll.ref)
        if b is None:
            return []
        if coll.ref == '*MODEL_SPACE':
            return [vobj_ent(o) for o in main_ents(dwg) if o.get(67, 0) != 1]
        return [vobj_ent(o) for o in b['ents'] if not o.deleted]
    if coll.kind == 'ss':
        return [vobj_ent(dwg.get(h)) for h in (I.prev_ss.hs if I.prev_ss else []) if dwg.get(h)]
    raise LispError('bad argument type: コレクションではありません ' + short(coll))


def add_ent_to(I, coll, pairs):
    """モデル空間/ブロックに図形を追加して DObj を返す"""
    dwg = I.dwg
    layer = next((v for c, v in pairs if c == 8), None)
    if layer is None:
        pairs.insert(1, (8, I.sysvars.get('CLAYER', '0')))
    ensure_layer(I, next(v for c, v in pairs if c == 8))
    if coll.kind == 'blk' and coll.ref not in ('*MODEL_SPACE',):
        b = dwg.blocks().get(coll.ref)
        if b is None:
            raise LispError('Automation Error. Object was erased')
        owner = b['rec'].h if b['rec'] is not None else '0'
        o = DObj(build_entity(I, pairs, owner), 'BLOCKS')
        dwg.register(o)
        lst = dwg.sec('BLOCKS')
        i = lst.index(b['end']) if b['end'] in lst else len(lst)
        lst.insert(i, o)
        dwg._blocks = None
        return o
    paper = coll.kind == 'coll' and coll.ref == 'paperspace'
    if paper:
        pairs.append((67, 1))
    o = DObj(build_entity(I, pairs, dwg.space_owner(paper)), 'ENTITIES')
    dwg.register(o)
    dwg.ents().append(o)
    return o


def cur_props():
    return []


def insert_block(I, coll, pt, name, sx=1.0, sy=1.0, sz=1.0, rot=0.0, attvals=None):
    dwg = I.dwg
    b = dwg.blocks().get(str(name).upper())
    if b is None:
        raise LispError('Automation Error. Key not found (ブロック "%s" がありません)' % name)
    attdefs = [e for e in b['ents'] if e.typ == 'ATTDEF' and not e.deleted and not (e.get(70, 0) & 2)]
    pairs = [(0, 'INSERT')]
    if attdefs:
        pairs.append((66, 1))
    pairs += [(2, b['name']), (10, to_pt3(pt)), (41, float(sx)), (42, float(sy)), (43, float(sz)),
              (50, math.degrees(rot))]
    ins = add_ent_to(I, coll, pairs)
    if attdefs:
        if coll.kind == 'blk' and coll.ref != '*MODEL_SPACE':
            I.warn('ブロック定義内への属性付きブロック挿入は属性を作成しません')
            return ins
        _, f = insert_xf(dwg, ins)
        for i, ad in enumerate(attdefs):
            val = ad.get(1, '')
            if attvals is not None and i < len(attvals):
                val = attvals[i]
            p10 = f(ad.get(10, (0, 0, 0)))
            ap = [(0, 'ATTRIB'), (8, ad.get(8, '0')), (10, (p10[0], p10[1], 0.0)), (40, ad.get(40, 2.5) * sy),
                  (1, val), (50, ad.get(50, 0.0) + math.degrees(rot)), (7, ad.get(7, 'Standard')),
                  (72, ad.get(72, 0))]
            if ad.get(11) is not None:
                p11 = f(ad.get(11))
                ap.append((11, (p11[0], p11[1], 0.0)))
            ap += [(2, ad.get(2, '')), (70, ad.get(70, 0) & ~8), (74, ad.get(74, 0))]
            o = DObj(build_entity(I, ap, ins.h), 'ENTITIES')
            dwg.register(o)
            dwg.ents().append(o)
        se = DObj(build_entity(I, [(0, 'SEQEND'), (8, ins.get(8, '0'))], ins.h), 'ENTITIES')
        dwg.register(se)
        dwg.ents().append(se)
    return ins


def attribs_of(dwg, o):
    cont = dwg.container_of(o)
    res = []
    if cont is None or not o.get(66, 0):
        return res
    i = cont.index(o) + 1
    while i < len(cont) and cont[i].typ == 'ATTRIB':
        if not cont[i].deleted:
            res.append(cont[i])
        i += 1
    return res


def _sym_set(I, s, val):
    if type(s) is Sym:
        I.g[s] = val


def vla_invoke(I, obj, meth, args, raw=False):
    need_vla(obj)
    m = meth.lower()
    k = obj.kind
    dwg = I.dwg
    A = args
    # --- アプリケーション・文書
    if k == 'app':
        if m in ('zoomextents', 'zoomall', 'zoomwindow', 'zoomscaled', 'zoomcenter', 'zoomprevious', 'update'):
            return None
        if m == 'getinterfaceobject':
            I.warn('GetInterfaceObject は再現できません')
            return None
    if k == 'doc':
        if m in ('startundomark', 'endundomark', 'regen', 'activate', 'purgeall', 'auditinfo'):
            return None
        if m == 'sendcommand':
            I.warn('SendCommand は非同期のため再現していません（ログのみ）: %s' % short(A[0] if A else '', 60))
            I.echo('[SendCommand(未実行)] %s\n' % (A[0] if A else ''))
            return None
        if m in ('save', 'saveas', 'close'):
            I.warn('図面の保存/閉じる(%s)は実行しません' % meth)
            return None
        if m == 'getvariable':
            return sysvar_get(I, strp(A[0]))
        if m == 'setvariable':
            _setvar(I, [strp(A[0]), pyval(A[1])])
            return None
        if m == 'handletoobject':
            o = dwg.get(strp(A[0]))
            if o is None or o.deleted:
                raise LispError('Automation Error. Object was erased')
            return vobj_any(dwg, o)
        if m == 'objectidtoobject':
            h = '%X' % int(num(A[0]))
            o = dwg.get(h)
            if o is None:
                raise LispError('Automation Error. Invalid object id')
            return vobj_any(dwg, o)
    if k == 'util':
        if m == 'prompt':
            I.echo(strp(A[0]))
            return None
        if m == 'getpoint':
            return _getpoint(I, [x for x in [pyval(A[0]) if A and A[0] is not None else None,
                                             A[1] if len(A) > 1 else None] if x is not None])
        if m == 'getstring':
            return _getstring(I, [A[1]] if len(A) > 1 else [])
        if m in ('getinteger', 'getreal'):
            return (_getint if m == 'getinteger' else _getreal)(I, [A[0]] if A else [])
        if m == 'getentity':
            r = _entsel(I, [A[2]] if len(A) > 2 else [])
            if r:
                _sym_set(I, A[0], vobj_any(dwg, dwg.get(r[0].h)))
                _sym_set(I, A[1], vpt(r[1]))
            return None
        if m == 'angletoreal':
            return _angtof(I, [A[0], A[1]])
        if m == 'distancetoreal':
            return _distof(I, [A[0]])
        if m == 'polarpoint':
            return vpt(_polar(I, [pyval(A[0]), num(A[1]), num(A[2])]), raw)
        if m == 'translatecoordinates':
            return A[0]
    # --- コレクション
    if k in ('coll', 'blk'):
        items_fn = lambda: vla_collection_items(I, obj)
        if m == 'item':
            key = pyval(A[0])
            items = items_fn()
            if isnum(key):
                i = int(key)
                if i < 0 or i >= len(items):
                    raise LispError('Automation Error. Invalid index')
                return items[i]
            for it in items:
                nm = vla_get(I, it, 'name') if it.kind in ('rec', 'blk') else None
                if nm is not None and str(nm).upper() == str(key).upper():
                    return it
            raise LispError('Automation Error. Key not found')
        if m == 'count':
            return len(items_fn())
        if k == 'coll' and obj.ref == 'layers' and m == 'add':
            name = strp(pyval(A[0]))
            r = dwg.find_rec('LAYER', name) or dwg.make_layer(name)
            return VlaObj('rec', ('LAYER', r.h))
        if k == 'coll' and obj.ref == 'textstyles' and m == 'add':
            name = strp(pyval(A[0]))
            r = dwg.find_rec('STYLE', name)
            if r is None:
                entmake_core(I, [Dotted([0], 'STYLE'), Dotted([2], name), Dotted([70], 0), Dotted([40], 0.0),
                                 Dotted([41], 1.0), Dotted([50], 0.0), Dotted([71], 0), Dotted([42], 2.5),
                                 Dotted([3], 'txt'), Dotted([4], '')])
                r = dwg.find_rec('STYLE', name)
            return VlaObj('rec', ('STYLE', r.h))
        if k == 'coll' and obj.ref == 'linetypes' and m == 'load':
            if not dwg.find_rec('LTYPE', pyval(A[0])):
                I.warn('線種 "%s" のロードは再現していません（線種表にありません）' % pyval(A[0]))
                raise LispError('Automation Error. Filer error (線種 %s)' % pyval(A[0]))
            raise LispError('Automation Error. Duplicate record name')
        if k == 'coll' and obj.ref == 'blocks' and m == 'add':
            pt, name = _pt_arg(pyval(A[0])), strp(pyval(A[1]))
            if name.upper() in dwg.blocks():
                return VlaObj('blk', name.upper())
            nm = commit_block(I, {'name': name, 'pairs': [(0, 'BLOCK'), (2, name), (70, 0), (10, pt)], 'ents': []})
            return VlaObj('blk', nm.upper())
        if k == 'coll' and obj.ref == 'documents':
            if m in ('add', 'open'):
                I.warn('図面を新規作成/開く(%s)は再現できません' % meth)
                return VlaObj('doc')
        if (k == 'coll' and obj.ref in ('modelspace', 'paperspace')) or k == 'blk':
            coll = obj
            if m == 'addline':
                return vobj_ent(add_ent_to(I, coll, [(0, 'LINE'), (10, _pt_arg(A[0])), (11, _pt_arg(A[1]))]))
            if m == 'addcircle':
                return vobj_ent(add_ent_to(I, coll, [(0, 'CIRCLE'), (10, _pt_arg(A[0])), (40, float(num(pyval(A[1]))))]))
            if m == 'addarc':
                return vobj_ent(add_ent_to(I, coll, [(0, 'ARC'), (10, _pt_arg(A[0])), (40, float(num(pyval(A[1])))),
                                                     (50, math.degrees(ang_norm(float(num(pyval(A[2])))))),
                                                     (51, math.degrees(ang_norm(float(num(pyval(A[3]))))))]))
            if m == 'addpoint':
                return vobj_ent(add_ent_to(I, coll, [(0, 'POINT'), (10, _pt_arg(A[0]))]))
            if m == 'addtext':
                return vobj_ent(add_ent_to(I, coll, [(0, 'TEXT'), (10, _pt_arg(A[1])), (40, float(num(pyval(A[2])))),
                                                     (1, strp(pyval(A[0]))), (7, I.sysvars.get('TEXTSTYLE', 'Standard'))]))
            if m == 'addmtext':
                return vobj_ent(add_ent_to(I, coll, [(0, 'MTEXT'), (10, _pt_arg(A[0])),
                                                     (40, float(I.sysvars.get('TEXTSIZE', 2.5))),
                                                     (41, float(num(pyval(A[1])))), (71, 1), (72, 5),
                                                     (1, strp(pyval(A[2]))),
                                                     (7, I.sysvars.get('TEXTSTYLE', 'Standard'))]))
            if m in ('addlightweightpolyline', 'addpolyline', 'add3dpoly'):
                flat = [float(x) for x in pyval(A[0])]
                step = 2 if m == 'addlightweightpolyline' else 3
                if m != 'addlightweightpolyline':
                    I.warn('%s は LWPOLYLINE として作成しました（Z座標は無視）' % meth)
                pairs = [(0, 'LWPOLYLINE'), (90, len(flat) // step), (70, 0)]
                for i in range(0, len(flat) - step + 1, step):
                    pairs.append((10, (flat[i], flat[i + 1])))
                return vobj_ent(add_ent_to(I, coll, pairs))
            if m == 'addellipse':
                return vobj_ent(add_ent_to(I, coll, [(0, 'ELLIPSE'), (10, _pt_arg(A[0])), (11, _pt_arg(A[1])),
                                                     (40, float(num(pyval(A[2])))), (41, 0.0), (42, TWO_PI)]))
            if m == 'insertblock':
                return vobj_ent(insert_block(I, coll, _pt_arg(A[0]), pyval(A[1]), num(pyval(A[2])),
                                             num(pyval(A[3])), num(pyval(A[4])), float(num(pyval(A[5])))))
            if m in ('addhatch', 'adddimaligned', 'adddimrotated', 'addregion', 'addspline', 'addtable',
                     'addleader', 'addmleader', 'addraster', 'addxline', 'addray', 'add3dface', 'addsolid'):
                I.warn('%s は再現していません' % meth)
                raise LispError('ActiveX Server returned an error: %s は lispcheck では未対応' % meth)
    if k == 'rec' and m == 'delete':
        o = dwg.get(obj.ref[1])
        if obj.ref[0] == 'LAYER':
            nm = str(o.get(2, '')).upper()
            if nm in ('0', 'DEFPOINTS') or nm == str(I.sysvars.get('CLAYER', '')).upper():
                raise LispError('Automation Error. Object is referenced')
            if any(str(e.get(8, '')).upper() == nm for e in main_ents(dwg)):
                raise LispError('Automation Error. Object is referenced')
        o.deleted = True
        return None
    if k == 'blk' and m == 'delete':
        b = dwg.blocks().get(obj.ref)
        if any(str(e.get(2, '')).upper() == obj.ref for e in main_ents(dwg) if e.typ == 'INSERT'):
            raise LispError('Automation Error. Object is referenced')
        for o in [b['block'], b['end'], b['rec']] + b['ents']:
            if o is not None:
                o.deleted = True
        dwg._blocks = None
        return None
    # --- 図形
    if k == 'ent':
        o = ent_of_vla(I, obj)
        t = o.typ
        if m == 'delete':
            _entdel(I, [Ename(o.h)])
            return None
        if m in ('update', 'highlight'):
            return None
        if m == 'copy':
            return vobj_ent(copy_ent(I, o))
        if t == 'MULTILEADER' and m == 'getleaderlineindexes':
            li = int(num(pyval(A[0])))
            ns = []
            for x in mld_scan(o):
                if x[3] == 'line' and x[4] == li and x[5] is not None and x[5] not in ns:
                    ns.append(x[5])
            return varr(ns, 3, raw)
        if t == 'MULTILEADER' and m == 'getleaderlinevertices':
            pts, land = mld_line_vertices(o, int(num(pyval(A[0]))))
            if not pts:
                raise LispError('Automation Error. Invalid index')
            flat = []
            for q in pts + ([land] if land else []):
                flat += list(q)
            return varr(flat, 5, raw)
        if t == 'MULTILEADER' and m == 'setleaderlinevertices':
            n = int(num(pyval(A[0])))
            vals = [float(x) for x in pyval(A[1])]
            new = [tuple(vals[i:i + 3]) for i in range(0, len(vals) - 2, 3)]
            pts, land = mld_line_vertices(o, n)
            if not pts:
                raise LispError('Automation Error. Invalid index')
            if land is not None and len(new) == len(pts) + 1:
                new = new[:-1]      # 最後の点（着地点）は複数の線で共有 → 変更しない（近似）
            idxs = [x[0] for x in mld_scan(o) if x[3] == 'line' and x[5] == n and x[1] == 10]
            p2 = [cv for i, cv in enumerate(o.p) if i not in idxs[len(new):]] if len(new) < len(idxs) else list(o.p)
            if len(new) <= len(idxs):
                for j, q in enumerate(new):
                    p2[idxs[j]] = (10, q)
                o.p = p2
            else:
                for j in range(len(idxs)):
                    p2[idxs[j]] = (10, new[j])
                at = idxs[-1] + 1
                o.p = p2[:at] + [(10, q) for q in new[len(idxs):]] + p2[at:]
            I.warn('SetLeaderLineVertices は近似です（着地点・折れ線は再計算されません）')
            return None
        if m == 'move':
            p1, p2 = _pt_arg(A[0]), _pt_arg(A[1])
            xform_ent(I, o, XF.move([p2[i] - p1[i] for i in range(3)]))
            return None
        if m == 'rotate':
            xform_ent(I, o, XF.rotate(_pt_arg(A[0]), float(num(pyval(A[1])))))
            return None
        if m == 'scaleentity':
            xform_ent(I, o, XF.scale(_pt_arg(A[0]), float(num(pyval(A[1])))))
            return None
        if m == 'mirror':
            c = copy_ent(I, o)
            xform_ent(I, c, XF.mirror(_pt_arg(A[0]), _pt_arg(A[1])))
            return vobj_ent(c)
        if m == 'getboundingbox':
            bb = ent_bbox(dwg, o)
            if not bb:
                raise LispError('Automation Error. Null extents')
            _sym_set(I, A[0], SafeArray(5, [(0, 2)], [bb[0], bb[1], 0.0]))
            _sym_set(I, A[1], SafeArray(5, [(0, 2)], [bb[2], bb[3], 0.0]))
            if raw:
                _sym_set(I, A[0], [bb[0], bb[1], 0.0])
                _sym_set(I, A[1], [bb[2], bb[3], 0.0])
            return None
        if m == 'intersectwith':
            o2 = ent_of_vla(I, A[0])
            mode = int(num(pyval(A[1]))) if len(A) > 1 else 0
            pts = ent_intersections(dwg, o, o2, mode)
            flat = []
            for p in pts:
                flat += [p[0], p[1], 0.0]
            if raw:
                return L(flat)
            return Variant(8197, SafeArray(5, [(0, len(flat) - 1)], flat))
        if m == 'offset':
            return varr([vobj_ent(x) for x in offset_ent(I, o, float(num(pyval(A[0]))))], 9, raw)
        if m == 'getattributes':
            return varr([vobj_ent(x) for x in attribs_of(dwg, o)], 9, raw)
        if m == 'getconstantattributes':
            return varr([], 9, raw)
        if m == 'coordinate' and t == 'LWPOLYLINE':
            vs = lwpoly_verts(o)
            i = int(num(pyval(A[0])))
            if i < 0 or i >= len(vs):
                raise LispError('Automation Error. Invalid index')
            return vpt(vs[i]['pt'], raw)
        if m == 'addvertex' and t == 'LWPOLYLINE':
            vs = lwpoly_verts(o)
            i = int(num(pyval(A[0])))
            p = pyval(A[1])
            vs.insert(i, {'pt': (float(p[0]), float(p[1])), 'sw': 0.0, 'ew': 0.0, 'b': 0.0})
            set_lwpoly_verts(o, vs)
            return None
        if m in ('getbulge', 'setbulge') and t == 'LWPOLYLINE':
            vs = lwpoly_verts(o)
            i = int(num(pyval(A[0])))
            if i < 0 or i >= len(vs):
                raise LispError('Automation Error. Invalid index')
            if m == 'getbulge':
                return vs[i]['b']
            vs[i]['b'] = float(num(pyval(A[1])))
            set_lwpoly_verts(o, vs)
            return None
        if m in ('getwidth', 'setwidth') and t == 'LWPOLYLINE':
            vs = lwpoly_verts(o)
            i = int(num(pyval(A[0])))
            if m == 'getwidth':
                _sym_set(I, A[1], vs[i]['sw'])
                _sym_set(I, A[2], vs[i]['ew'])
                return None
            vs[i]['sw'] = float(num(pyval(A[1])))
            vs[i]['ew'] = float(num(pyval(A[2])))
            set_lwpoly_verts(o, vs)
            return None
        if m == 'setxdata':
            codes = pyval(A[0])
            vals = pyval(A[1])
            lst = [[c] + list(v) if isinstance(v, list) else Dotted([c], v) for c, v in zip(codes, vals)]
            app = vals[0]
            items = lst[1:]
            e = store_to_lisp(dwg, o)
            e.append([-3, [app] + items])
            _entmod(I, [e])
            return None
        if m == 'getxdata':
            app = strp(pyval(A[0]))
            xd = parse_xdata(o.p[xdata_start(o.p):])
            codes, vals = [], []
            for nm, items in xd:
                if not app or wcmatch(nm, app, True):
                    codes.append(1001)
                    vals.append(nm)
                    for it in items:
                        c, v = pair_of(it)
                        codes.append(c)
                        vals.append(v if not isinstance(v, list) else vpt(v))
            _sym_set(I, A[1], SafeArray(2, [(0, len(codes) - 1)], codes) if codes else None)
            _sym_set(I, A[2], SafeArray(12, [(0, len(vals) - 1)], vals) if vals else None)
            return None
        if m == 'explode':
            I.warn('Explode は再現していません')
            raise LispError('ActiveX Server returned an error: Explode は lispcheck では未対応')
        if m == 'getextensiondictionary':
            raise LispError('Automation Error. No extension dictionary (未対応)')
    raise unknown_name(meth)


def copy_ent(I, o):
    dwg = I.dwg
    pairs = [(c, v) for c, v in o.p if c not in (5,)]
    pairs = [pr for pr in pairs if not (pr[0] == 102 or pr[0] in (360,))]
    # 102 グループ内の 330 を除去
    out = []
    skip = False
    for c, v in o.p:
        if c == 102:
            skip = str(v).startswith('{')
            continue
        if skip:
            continue
        if c == 5:
            continue
        out.append((c, v))
    new = DObj(out, o.sec)
    new.p.insert(1, (5, dwg.new_handle())) if dwg.modern else None
    dwg.register(new)
    cont = dwg.container_of(o)
    if o.sec == 'ENTITIES':
        cont.append(new)
        if o.typ in ('INSERT', 'POLYLINE'):
            subs = []
            i = cont.index(o) + 1
            while i < len(cont) and cont[i].typ in SUB_ENT_TYPES:
                subs.append(cont[i])
                if cont[i].typ == 'SEQEND':
                    break
                i += 1
            for s in subs:
                sp_ = [(c, (new.h if c == 330 else v)) for c, v in s.p if c != 5]
                ns = DObj(sp_, 'ENTITIES')
                if dwg.modern:
                    ns.p.insert(1, (5, dwg.new_handle()))
                dwg.register(ns)
                cont.append(ns)
    else:
        i = cont.index(o)
        lst = dwg.sec('BLOCKS')
        lst.insert(lst.index(o) + 1, new)
        dwg._blocks = None
    return new


def offset_ent(I, o, d):
    t = o.typ
    if t == 'CIRCLE' or t == 'ARC':
        r = o.get(40, 0.0) + d
        if r <= 0:
            raise LispError('Automation Error. Invalid offset (半径が0以下)')
        n = copy_ent(I, o)
        n.set(40, r)
        return [n]
    if t == 'LINE':
        a, b = o.get(10), o.get(11)
        dx, dy = b[0] - a[0], b[1] - a[1]
        ln = math.hypot(dx, dy)
        nx, ny = -dy / ln * d, dx / ln * d
        n = copy_ent(I, o)
        n.set(10, (a[0] + nx, a[1] + ny, a[2] if len(a) > 2 else 0.0))
        n.set(11, (b[0] + nx, b[1] + ny, b[2] if len(b) > 2 else 0.0))
        return [n]
    if t == 'LWPOLYLINE':
        vs = lwpoly_verts(o)
        if any(v['b'] for v in vs):
            raise LispError('ActiveX Server returned an error: 円弧を含むポリラインの Offset は未対応')
        closed = bool(o.get(70, 0) & 1)
        pts = [v['pt'] for v in vs]
        n = len(pts)
        lines = []
        for i in range(n if closed else n - 1):
            p, q = pts[i], pts[(i + 1) % n]
            dx, dy = q[0] - p[0], q[1] - p[1]
            ln = math.hypot(dx, dy) or 1.0
            nx, ny = dy / ln * d, -dx / ln * d
            lines.append(((p[0] + nx, p[1] + ny), (q[0] + nx, q[1] + ny)))
        newpts = []
        for i in range(n):
            if not closed and i == 0:
                newpts.append(lines[0][0])
                continue
            if not closed and i == n - 1:
                newpts.append(lines[-1][1])
                continue
            l1 = lines[(i - 1) % len(lines)]
            l2 = lines[i % len(lines)]
            r = _seg_seg(('L',) + l1[0] + l1[1], ('L',) + l2[0] + l2[1], True, True)
            newpts.append(r[0] if r else l2[0])
        c = copy_ent(I, o)
        nv = [dict(v, pt=p) for v, p in zip(vs, newpts)]
        set_lwpoly_verts(c, nv)
        I.warn('LWPOLYLINE の Offset は角の単純延長による近似です（向きは AutoCAD と逆になる場合あり）')
        return [c]
    raise LispError('ActiveX Server returned an error: %s の Offset は未対応' % t)


# --------------------------------------------------------------- 変換（移動・回転・尺度・鏡像）
class XF:
    def __init__(self, a, b, c, d, e, f):
        self.m = (a, b, c, d, e, f)
        det = a * d - b * c
        self.mirror = det < 0
        self.s = math.sqrt(abs(det))
        self.rot = math.atan2(c, a)
        self.phi = None

    def pt(self, p):
        a, b, c, d, e, f = self.m
        x, y = p[0], p[1]
        r = (a * x + b * y + e, c * x + d * y + f)
        return r + tuple(p[2:3]) if len(p) > 2 else r

    def vec(self, v):
        a, b, c, d, e, f = self.m
        r = (a * v[0] + b * v[1], c * v[0] + d * v[1])
        return r + tuple(v[2:3]) if len(v) > 2 else r

    @staticmethod
    def move(dv):
        return XF(1, 0, 0, 1, dv[0], dv[1])

    @staticmethod
    def rotate(base, ang):
        c, s = math.cos(ang), math.sin(ang)
        bx, by = base[0], base[1]
        return XF(c, -s, s, c, bx - c * bx + s * by, by - s * bx - c * by)

    @staticmethod
    def scale(base, k):
        bx, by = base[0], base[1]
        return XF(k, 0, 0, k, bx - k * bx, by - k * by)

    @staticmethod
    def mirror_line(p1, p2):
        phi = math.atan2(p2[1] - p1[1], p2[0] - p1[0])
        c2, s2 = math.cos(2 * phi), math.sin(2 * phi)
        bx, by = p1[0], p1[1]
        x = XF(c2, s2, s2, -c2, bx - c2 * bx - s2 * by, by - s2 * bx + c2 * by)
        x.phi = phi
        return x

    mirror = mirror_line


def mld_scan(o):
    """MULTILEADER のグループコードを区間ごとに分類：
    (位置, コード, 値, 区間 'top'/'ctx'/'leader'/'line', 引出線番号, 線番号)"""
    res = []
    st = 'top'
    li = -1
    ln = None
    k = xdata_start(o.p)
    for i, (c, v) in enumerate(o.p[:k]):
        if c == 300 and str(v).startswith('CONTEXT_DATA'):
            st = 'ctx'
            continue
        if c == 302 and str(v).startswith('LEADER{'):
            st = 'leader'
            li += 1
            continue
        if c == 304 and str(v).startswith('LEADER_LINE{'):
            st = 'line'
            ln = None
            continue
        if c == 305 and st == 'line':
            st = 'leader'
            continue
        if c == 303 and st == 'leader':
            st = 'ctx'
            continue
        if c == 301 and st == 'ctx':
            st = 'top'
            continue
        if st == 'line' and c == 91:
            ln = int(v)
        res.append((i, c, v, st, li, ln))
    # 線番号は区間の後ろ(91)にあるので、線ごとにまとめ直す
    out = []
    cur = []
    for x in res:
        if x[3] == 'line':
            cur.append(x)
            if x[1] == 91:
                out += [(y[0], y[1], y[2], y[3], y[4], int(x[2])) for y in cur]
                cur = []
        else:
            out += cur
            cur = []
            out.append(x)
    return out + cur


def mld_line_vertices(o, n):
    secs = mld_scan(o)
    pts = [to_pt3(x[2]) for x in secs if x[3] == 'line' and x[5] == n and x[1] == 10]
    li = next((x[4] for x in secs if x[3] == 'line' and x[5] == n), None)
    land = [to_pt3(x[2]) for x in secs if x[3] == 'leader' and x[4] == li and x[1] == 10]
    return pts, (land[0] if land else None)


def xform_ent(I, o, xf, with_subs=True):
    t = o.typ
    if t == 'MULTILEADER':
        secs = {x[0]: x for x in mld_scan(o)}
        newp = list(o.p)
        for i, (c, v) in enumerate(o.p):
            x = secs.get(i)
            if x is None or type(v) is not tuple:
                continue
            st = x[3]
            if (st == 'ctx' and c in (10, 12, 15, 110)) or (st in ('leader', 'line') and c == 10):
                newp[i] = (c, xf.pt(v))
            elif (st == 'ctx' and c == 13) or (st == 'leader' and c == 11):
                newp[i] = (c, xf.vec(v))
        o.p = newp
        if xf.m[:4] != (1, 0, 0, 1):
            I.warn('MULTILEADER の回転・尺度変更は近似です')
        return
    ptcodes = {'LINE': (10, 11), 'POINT': (10,), 'CIRCLE': (10,), 'ARC': (10,), 'TEXT': (10, 11),
               'ATTRIB': (10, 11), 'ATTDEF': (10, 11), 'MTEXT': (10,), 'INSERT': (10,), 'LWPOLYLINE': (10,),
               'ELLIPSE': (10,), 'SOLID': (10, 11, 12, 13), 'TRACE': (10, 11, 12, 13), '3DFACE': (10, 11, 12, 13),
               'SPLINE': (10, 11), 'LEADER': (10,), 'XLINE': (10,), 'RAY': (10,), 'VERTEX': (10,),
               'DIMENSION': (10, 11, 13, 14, 15, 16), 'POLYLINE': ()}.get(t)
    if t == 'HATCH' and xf.m[:4] == (1, 0, 0, 1):
        o.p = [(c, xf.pt(v)) if c in (10, 11) and type(v) is tuple and len(v) == 2 else (c, v) for c, v in o.p]
        return
    if ptcodes is None:
        I.warn('%s の移動/回転/尺度変更は再現していません（変更されません）' % t)
        return
    if t in ('DIMENSION', 'HATCH'):
        I.warn('%s の変形は近似です（寸法値や関連ブロックは更新されません）' % t)
    vec_codes = {'MTEXT': (11,), 'ELLIPSE': (11,), 'XLINE': (11,), 'RAY': (11,)}.get(t, ())
    newp = []
    for c, v in o.p:
        if c in ptcodes and type(v) is tuple:
            v = xf.pt(v)
        elif c in vec_codes and type(v) is tuple:
            v = xf.vec(v)
        newp.append((c, v))
    o.p = newp
    s = xf.s
    rot_deg = math.degrees(xf.rot)

    def scale_code(code):
        if o.get(code) is not None:
            o.set(code, o.get(code) * s)
    if t in ('CIRCLE', 'ARC'):
        scale_code(40)
    if t in ('TEXT', 'ATTRIB', 'ATTDEF', 'MTEXT'):
        scale_code(40)
        if t == 'MTEXT':
            scale_code(41)
    if t == 'LWPOLYLINE':
        for code in (43,):
            scale_code(code)
        o.p = [(c, v * s) if c in (40, 41) else (c, v) for c, v in o.p]
        if xf.mirror:
            o.p = [(c, -v) if c == 42 else (c, v) for c, v in o.p]
    if t == 'ARC':
        if xf.mirror:
            a0, a1 = o.get(50, 0.0), o.get(51, 0.0)
            ph = math.degrees(xf.phi if xf.phi is not None else 0.0)
            o.set(50, (2 * ph - a1) % 360)
            o.set(51, (2 * ph - a0) % 360)
        else:
            o.set(50, (o.get(50, 0.0) + rot_deg) % 360)
            o.set(51, (o.get(51, 0.0) + rot_deg) % 360)
    if t in ('TEXT', 'ATTRIB', 'ATTDEF'):
        if not xf.mirror:
            o.set(50, (o.get(50, 0.0) + rot_deg) % 360)
        elif I.sysvars.get('MIRRTEXT', 0):
            I.warn('MIRRTEXT=1 の文字の鏡像は近似です')
    if t == 'MTEXT' and o.get(50) is not None and not xf.mirror:
        o.set(50, ang_norm(o.get(50) + xf.rot))
    if t == 'INSERT':
        for code in (41, 42, 43):
            o.set(code, o.get(code, 1.0) * s)
        if xf.mirror:
            ph = math.degrees(xf.phi or 0.0)
            o.set(50, (2 * ph - o.get(50, 0.0)) % 360)
            o.set(42, -o.get(42, 1.0))
        else:
            o.set(50, (o.get(50, 0.0) + rot_deg) % 360)
    if with_subs and t in ('INSERT', 'POLYLINE') and o.sec == 'ENTITIES':
        cont = I.dwg.ents()
        i = cont.index(o) + 1
        while i < len(cont) and cont[i].typ in ('ATTRIB', 'VERTEX'):
            xform_ent(I, cont[i], xf, False)
            i += 1


# --------------------------------------------------------------- vla-/vlax- 関数
def vla_get_fn(I, a, prop):
    argn(a, 1, 1)
    return vla_get(I, a[0], prop)


def vla_put_fn(I, a, prop):
    argn(a, 2, 2)
    vla_put(I, a[0], prop, a[1])
    return None


def vla_invoke_fn(I, a, meth):
    argn(a, 1)
    return vla_invoke(I, need_vla(a[0]), meth, a[1:])


def _pname(x):
    if type(x) is Sym:
        return x.name
    return strp(x)


@bi('vlax-get-acad-object')
def _vlax_get_acad_object(I, a):
    return VlaObj('app')


@bi('vlax-ename->vla-object')
def _vlax_ename_to_vla(I, a):
    argn(a, 1, 1)
    e = ename_of(I, a[0])
    o = I.dwg.get(e.h)
    if o is None or o.deleted:
        raise LispError('Automation Error. Object was erased')
    return vobj_any(I.dwg, o)


@bi('vlax-vla-object->ename')
def _vlax_vla_to_ename(I, a):
    argn(a, 1, 1)
    x = need_vla(a[0])
    if x.kind == 'ent':
        return Ename(x.ref[0])
    if x.kind == 'rec':
        return Ename(x.ref[1])
    if x.kind == 'blk':
        b = I.dwg.blocks().get(x.ref)
        return Ename((b['rec'] or b['block']).h) if b else None
    raise LispError('bad argument type: ename 変換できない VLA-OBJECT')


@bi('vlax-get-property')
def _vlax_get_property(I, a):
    argn(a, 2)
    return vla_get(I, a[0], _pname(a[1]))


@bi('vlax-put-property')
def _vlax_put_property(I, a):
    argn(a, 3)
    vla_put(I, a[0], _pname(a[1]), a[2])
    return None


@bi('vlax-invoke-method')
def _vlax_invoke_method(I, a):
    argn(a, 2)
    return vla_invoke(I, need_vla(a[0]), _pname(a[1]), a[2:])


def _to_raw(v):
    if type(v) is Variant:
        return _to_raw(v.val)
    if type(v) is SafeArray:
        return L(_to_raw(x) for x in v.data)
    if v is VTRUE:
        return -1
    if v is VFALSE:
        return 0
    return v


@bi('vlax-get')
def _vlax_get(I, a):
    argn(a, 2, 2)
    return _to_raw(vla_get(I, a[0], _pname(a[1]), raw=True))


@bi('vlax-put')
def _vlax_put(I, a):
    argn(a, 3, 3)
    vla_put(I, a[0], _pname(a[1]), a[2])
    return None


@bi('vlax-invoke')
def _vlax_invoke(I, a):
    argn(a, 2)
    return _to_raw(vla_invoke(I, need_vla(a[0]), _pname(a[1]), a[2:], raw=True))


@bi('vlax-property-available-p')
def _vlax_property_available_p(I, a):
    argn(a, 2, 3)
    try:
        v = vla_get(I, a[0], _pname(a[1]))
    except LispError:
        return None
    if len(a) > 2 and a[2] is not None:
        try:
            vla_put(I, _probe_copy(a[0]), _pname(a[1]), v)
        except LispError:
            return None
        except Exception:
            return T
    return T


def _probe_copy(x):
    return x


@bi('vlax-method-applicable-p', 'approx')
def _vlax_method_applicable_p(I, a):
    argn(a, 2, 2)
    x = need_vla(a[0])
    m = _pname(a[1]).lower()
    common = {'delete', 'copy', 'move', 'rotate', 'scaleentity', 'mirror', 'getboundingbox', 'intersectwith',
              'update', 'highlight', 'setxdata', 'getxdata'}
    if x.kind == 'ent':
        o = ent_of_vla(I, x)
        extra = {'LWPOLYLINE': {'coordinate', 'addvertex', 'getbulge', 'setbulge', 'getwidth', 'setwidth', 'offset'},
                 'INSERT': {'getattributes', 'getconstantattributes'}, 'LINE': {'offset'}, 'CIRCLE': {'offset'},
                 'ARC': {'offset'}}.get(o.typ, set())
        return truth(m in common or m in extra)
    if x.kind in ('coll', 'blk'):
        return truth(m in ('item', 'add', 'addline', 'addcircle', 'addarc', 'addtext', 'addmtext', 'addpoint',
                           'addlightweightpolyline', 'insertblock', 'addellipse', 'delete'))
    return None


@bi('vlax-release-object')
def _vlax_release_object(I, a):
    return None


@bi('vlax-object-released-p')
def _vlax_object_released_p(I, a):
    return None


@bi('vlax-erased-p')
def _vlax_erased_p(I, a):
    argn(a, 1, 1)
    x = need_vla(a[0])
    if x.kind == 'ent':
        o = I.dwg.get(x.ref[0])
        return truth(o is None or o.deleted)
    return None


@bi('vlax-read-enabled-p vlax-write-enabled-p vlax-typeinfo-available-p')
def _vlax_enabled(I, a):
    return T


@bi('vlax-dump-object', 'approx')
def _vlax_dump_object(I, a):
    argn(a, 1, 2)
    x = need_vla(a[0])
    I.echo('\n; %s: (lispcheck簡易表示)\n; プロパティ値:\n' % vla_iface_name(x))
    names = ['Application', 'Document', 'Handle', 'Layer', 'Linetype', 'LinetypeScale', 'Lineweight',
             'ObjectName', 'Color', 'Visible', 'StartPoint', 'EndPoint', 'Center', 'Radius', 'Length',
             'Coordinates', 'Closed', 'TextString', 'InsertionPoint', 'Height', 'Rotation', 'Name', 'Count',
             'LayerOn', 'Freeze', 'Lock', 'Area', 'StyleName', 'Width', 'XScaleFactor', 'HasAttributes',
             'TagString', 'ActiveLayer']
    for n in names:
        try:
            v = vla_get(I, x, n)
        except LispError:
            continue
        I.echo(';   %s = %s\n' % (n, short(_to_raw(v) if type(v) is Variant else v, 80)))
    return T


@bi('vlax-3d-point')
def _vlax_3d_point(I, a):
    argn(a, 1, 3)
    if len(a) == 1:
        p = ptp(a[0])
    else:
        p = [float(num(x)) for x in a]
    if len(p) == 2:
        p.append(0.0)
    return vpt(p)


@bi('vlax-make-safearray')
def _vlax_make_safearray(I, a):
    argn(a, 2)
    vt = fixn(a[0])
    dims = []
    for d in a[1:]:
        if type(d) is Dotted:
            dims.append((fixn(d.items[0]), fixn(d.tail)))
        elif isinstance(d, list) and len(d) == 2:
            dims.append((fixn(d[0]), fixn(d[1])))
        else:
            raise LispError('bad argument type: 次元指定 ' + short(d))
    return SafeArray(vt, dims)


def _flat(v):
    out = []
    for x in seq(v):
        if isinstance(x, list):
            out += _flat(x)
        else:
            out.append(x)
    return out


@bi('vlax-safearray-fill')
def _vlax_safearray_fill(I, a):
    argn(a, 2, 2)
    sa = a[0]
    if type(sa) is not SafeArray:
        raise LispError('bad argument type: safearrayp ' + short(sa))
    vals = _flat(a[1])
    if len(vals) > len(sa.data):
        raise LispError('Too many elements for safearray')
    for i, v in enumerate(vals):
        sa.data[i] = float(v) if sa.vt in (4, 5) and isnum(v) else v
    return sa


def _sa(x):
    if type(x) is Variant:
        x = x.val
    if type(x) is not SafeArray:
        raise LispError('bad argument type: safearrayp ' + short(x))
    return x


@bi('vlax-safearray->list')
def _vlax_safearray_to_list(I, a):
    argn(a, 1, 1)
    sa = _sa(a[0])
    if not sa.data:
        I.warn('空の safearray を vlax-safearray->list しました（AutoCAD ではエラーになります）')
        raise LispError('Automation Error. 空の配列 (upper bound = -1)')
    if len(sa.dims) == 2:
        n2 = sa.dims[1][1] - sa.dims[1][0] + 1
        return L(L(sa.data[i:i + n2]) for i in range(0, len(sa.data), n2))
    return L(sa.data)


@bi('vlax-safearray-get-element')
def _vlax_sa_get(I, a):
    argn(a, 2, 3)
    sa = _sa(a[0])
    idx = _sa_index(sa, [fixn(x) for x in a[1:]])
    return sa.data[idx]


@bi('vlax-safearray-put-element')
def _vlax_sa_put(I, a):
    argn(a, 3, 4)
    sa = _sa(a[0])
    idx = _sa_index(sa, [fixn(x) for x in a[1:-1]])
    sa.data[idx] = a[-1]
    return a[-1]


def _sa_index(sa, ids):
    if len(ids) != len(sa.dims):
        raise LispError('Automation Error. Invalid number of dimensions')
    idx = 0
    for (lo, hi), i in zip(sa.dims, ids):
        if i < lo or i > hi:
            raise LispError('Automation Error. Invalid index')
        idx = idx * (hi - lo + 1) + (i - lo)
    return idx


@bi('vlax-safearray-get-dim')
def _vlax_sa_dim(I, a):
    return len(_sa(a[0]).dims)


@bi('vlax-safearray-get-l-bound')
def _vlax_sa_l(I, a):
    argn(a, 2, 2)
    return _sa(a[0]).dims[fixn(a[1]) - 1][0]


@bi('vlax-safearray-get-u-bound')
def _vlax_sa_u(I, a):
    argn(a, 2, 2)
    return _sa(a[0]).dims[fixn(a[1]) - 1][1]


@bi('vlax-safearray-type')
def _vlax_sa_type(I, a):
    return _sa(a[0]).vt


@bi('vlax-make-variant')
def _vlax_make_variant(I, a):
    argn(a, 0, 2)
    if not a:
        return Variant(0, None)
    v = a[0]
    if len(a) > 1 and a[1] is not None:
        vt = fixn(a[1])
    elif type(v) is SafeArray:
        vt = 8192 + v.vt
    elif type(v) is int:
        vt = 3
    elif type(v) is float:
        vt = 5
    elif type(v) is str:
        vt = 8
    elif type(v) is VlaObj:
        vt = 9
    elif v is None:
        vt = 0
    else:
        vt = 12
    return Variant(vt, v)


@bi('vlax-variant-value')
def _vlax_variant_value(I, a):
    argn(a, 1, 1)
    v = a[0]
    if type(v) is not Variant:
        raise LispError('bad argument type: variantp ' + short(v))
    return v.val


@bi('vlax-variant-type')
def _vlax_variant_type(I, a):
    argn(a, 1, 1)
    v = a[0]
    if type(v) is not Variant:
        raise LispError('bad argument type: variantp ' + short(v))
    return v.vt


@bi('vlax-variant-change-type')
def _vlax_variant_change_type(I, a):
    argn(a, 2, 2)
    v = a[0]
    vt = fixn(a[1])
    val = v.val if type(v) is Variant else v
    try:
        if vt in (2, 3):
            val = int(float(val))
        elif vt in (4, 5):
            val = float(val)
        elif vt == 8:
            val = lstr(val, False)
        elif vt == 11:
            val = -1 if truthy_vb(val) else 0
    except (TypeError, ValueError):
        return None
    return Variant(vt, val)


@bi('vlax-ldata-put')
def _vlax_ldata_put(I, a):
    argn(a, 3, 4)
    I.ldata[(short(a[0]), lstr(a[1], False))] = a[2]
    return a[2]


@bi('vlax-ldata-get')
def _vlax_ldata_get(I, a):
    argn(a, 2, 4)
    return I.ldata.get((short(a[0]), lstr(a[1], False)), a[2] if len(a) > 2 else None)


@bi('vlax-ldata-delete')
def _vlax_ldata_delete(I, a):
    return truth(I.ldata.pop((short(a[0]), lstr(a[1], False)), None) is not None)


@bi('vlax-ldata-list')
def _vlax_ldata_list(I, a):
    k0 = short(a[0])
    return L(Dotted([k[1]], v) for k, v in I.ldata.items() if k[0] == k0)


@bi('vlax-ldata-test')
def _vlax_ldata_test(I, a):
    return T


@bi('vlax-map-collection')
def _vlax_map_collection(I, a):
    argn(a, 2, 2)
    f = I.fn_of(a[1])
    for it in vla_collection_items(I, a[0]):
        I.call(f, [it])
    return a[0]


@bi('vlax-count')
def _vlax_count(I, a):
    return len(vla_collection_items(I, a[0]))


@bi('vlax-add-cmd')
def _vlax_add_cmd(I, a):
    argn(a, 2, 4)
    name = strp(a[0])
    f = a[1]
    I.added_cmds[name.lower()] = f
    return name


@bi('vlax-remove-cmd')
def _vlax_remove_cmd(I, a):
    return truth(I.added_cmds.pop(strp(a[0]).lower(), None) is not None)


@bi('vlax-get-object vlax-create-object vlax-get-or-create-object vlax-import-type-library', 'stub')
def _vlax_ext_objects(I, a):
    I.warn('外部アプリ連携(%s)は再現できません（nil を返しました）' % (short(a[0]) if a else ''))
    return None


@bi('vlax-product-key vlax-machine-product-key vlax-user-product-key')
def _vlax_product_key(I, a):
    return 'Software\\Autodesk\\AutoCAD\\R24.1\\ACAD-5101:411'


@bi('vlax-tmatrix')
def _vlax_tmatrix(I, a):
    rows = [ [float(num(x)) for x in seq(r)] for r in seq(a[0])]
    return Variant(8197, SafeArray(5, [(0, 3), (0, 3)], [x for r in rows for x in r]))


# =====================================================================
#  command / command-s の簡易再現
# =====================================================================
class CmdEnd(Exception):
    pass


class CArgs:
    def __init__(self, I, args):
        self.I = I
        self.a = list(args)
        self.i = 0

    def more(self):
        return self.i < len(self.a)

    def peek(self):
        return self.a[self.i] if self.i < len(self.a) else None

    def raw(self, kind='値'):
        if self.i >= len(self.a):
            raise CmdEnd()
        v = self.a[self.i]
        self.i += 1
        if v == '\\':
            v = self.I.pop_input('command の pause（%s）' % kind)
            if isinstance(v, list) and all(isnum(x) for x in v):
                v = [float(x) for x in v]
        return v

    def is_enter(self, v):
        return v is None or v == '' or v is T

    def point(self, base=None):
        v = self.raw('点')
        if self.is_enter(v):
            return None
        p = input_point(v, base) if not isinstance(v, (Ename,)) else None
        if p is None:
            raise LispError('command: 点が必要な所に %s が渡されました' % short(v))
        return p

    def number(self, base=None):
        v = self.raw('数値')
        if self.is_enter(v):
            return None
        if isnum(v):
            return float(v)
        if type(v) is str:
            try:
                return float(v)
            except ValueError:
                p = input_point(v, base)
                if p is not None and base is not None:
                    return math.dist(p[:2], base[:2])
                return v
        if isinstance(v, list) and base is not None:
            return math.dist(to_pt3(v)[:2], base[:2])
        return v

    def string(self):
        v = self.raw('文字列')
        if v is None or v is T:
            return ''
        return v if type(v) is str else lstr(v, False)

    def selection(self):
        """オブジェクト選択：空文字 "" で終了"""
        I = self.I
        res = []
        while self.more():
            v = self.raw('オブジェクト選択')
            if self.is_enter(v):
                break
            if type(v) is str:
                u = v.upper().lstrip('_')
                if u in ('L', 'LAST'):
                    res += main_ents(I.dwg)[-1:]
                    continue
                if u in ('P', 'PREVIOUS'):
                    res += sel_from_input(I, I.prev_ss) if I.prev_ss else []
                    continue
                if u == 'ALL':
                    res += main_ents(I.dwg)
                    continue
                if u in ('W', 'C'):
                    p1, p2 = self.point(), self.point()
                    res += window_select(I.dwg, p1, p2, u == 'C')
                    continue
            if isinstance(v, list) and len(v) == 2 and type(v[0]) is Ename:
                v = v[0]
            res += sel_from_input(I, v)
        out = []
        for o in res:
            if o is not None and o not in out:
                out.append(o)
        if out:
            I.prev_ss = PickSet([o.h for o in out])
        return out


def norm_cmd(s):
    return str(s).upper().lstrip('_.-+').lstrip('_.')


def new_ent(I, typ, pairs):
    """現在の画層・色・線種で図形を作成"""
    dwg = I.dwg
    full = [(0, typ), (8, I.sysvars.get('CLAYER', '0'))]
    ce = str(I.sysvars.get('CECOLOR', 'BYLAYER')).upper()
    if ce not in ('BYLAYER', '256'):
        try:
            full.append((62, 0 if ce == 'BYBLOCK' else int(ce)))
        except ValueError:
            pass
    lt = str(I.sysvars.get('CELTYPE', 'ByLayer'))
    if lt.upper() != 'BYLAYER':
        full.append((6, lt))
    full += pairs
    o = DObj(build_entity(I, full, dwg.space_owner(False)), 'ENTITIES')
    dwg.register(o)
    dwg.ents().append(o)
    return o


def cmd_line(I, c):
    p1 = c.point()
    if p1 is None:
        return
    start = p1
    made = []
    while c.more():
        v = c.peek()
        if type(v) is str and norm_cmd(v) in ('C', 'CLOSE') and made:
            c.raw()
            made.append(new_ent(I, 'LINE', [(10, p1), (11, start)]))
            return
        if type(v) is str and norm_cmd(v) in ('U', 'UNDO') and made:
            c.raw()
            o = made.pop()
            o.deleted = True
            p1 = o.get(10)
            continue
        p2 = c.point(p1)
        if p2 is None:
            return
        made.append(new_ent(I, 'LINE', [(10, p1), (11, p2)]))
        p1 = p2


def cmd_pline(I, c):
    p1 = c.point()
    if p1 is None:
        return
    verts = [{'pt': p1[:2], 'b': 0.0}]
    closed = False
    width = float(I.sysvars.get('PLINEWID', 0.0))
    while c.more():
        v = c.peek()
        if type(v) is str and v != '':
            u = norm_cmd(v)
            if u in ('C', 'CLOSE', 'CL'):
                c.raw()
                closed = True
                break
            if u in ('W', 'WIDTH', 'H', 'HALFWIDTH'):
                c.raw()
                w1 = c.number()
                w2 = c.number()
                width = float(w1 if isnum(w1) else 0)
                continue
            if u in ('A', 'ARC'):
                c.raw()
                I.warn('PLINE の円弧モードは再現していません（直線で作成）')
                continue
            if u in ('L', 'LINE'):
                c.raw()
                continue
            if input_point(v, verts[-1]['pt']) is None:
                c.raw()
                I.warn('PLINE のオプション "%s" は未対応' % v)
                continue
        p = c.point(tuple(verts[-1]['pt']) + (0.0,))
        if p is None:
            break
        verts.append({'pt': p[:2], 'b': 0.0})
    pairs = [(90, len(verts)), (70, 1 if closed else 0)]
    if width:
        pairs.append((43, width))
    for vx in verts:
        pairs.append((10, (vx['pt'][0], vx['pt'][1])))
    new_ent(I, 'LWPOLYLINE', pairs)


def cmd_circle(I, c):
    v = c.peek()
    if type(v) is str and norm_cmd(v) in ('3P', '2P', 'TTR', 'T'):
        opt = norm_cmd(c.raw())
        if opt == '2P':
            a, b = c.point(), c.point()
            cen = ((a[0] + b[0]) / 2, (a[1] + b[1]) / 2, 0.0)
            new_ent(I, 'CIRCLE', [(10, cen), (40, math.dist(a[:2], b[:2]) / 2)])
            return
        if opt == '3P':
            a, b, d = c.point(), c.point(), c.point()
            cc = circle3(a, b, d)
            if cc:
                new_ent(I, 'CIRCLE', [(10, (cc[0], cc[1], 0.0)), (40, cc[2])])
            return
        I.warn('CIRCLE の %s オプションは未対応' % opt)
        raise CmdEnd()
    cen = c.point()
    if cen is None:
        return
    r = c.number(cen)
    if type(r) is str and norm_cmd(r) in ('D', 'DIAMETER'):
        d = c.number(cen)
        r = float(d) / 2
    if r is None:
        r = float(I.sysvars.get('CIRCLERAD', 0.0)) or 1.0
    I.sysvars['CIRCLERAD'] = float(r)
    new_ent(I, 'CIRCLE', [(10, cen), (40, float(r))])


def circle3(a, b, c):
    ax, ay, bx, by, cx, cy = a[0], a[1], b[0], b[1], c[0], c[1]
    d = 2 * (ax * (by - cy) + bx * (cy - ay) + cx * (ay - by))
    if abs(d) < 1e-14:
        return None
    ux = ((ax * ax + ay * ay) * (by - cy) + (bx * bx + by * by) * (cy - ay) + (cx * cx + cy * cy) * (ay - by)) / d
    uy = ((ax * ax + ay * ay) * (cx - bx) + (bx * bx + by * by) * (ax - cx) + (cx * cx + cy * cy) * (bx - ax)) / d
    return ux, uy, math.hypot(ax - ux, ay - uy)


def cmd_arc(I, c):
    v = c.peek()
    if type(v) is str and norm_cmd(v) in ('C', 'CE', 'CENTER'):
        c.raw()
        cen = c.point()
        sp_ = c.point(cen)
        ep = c.point(cen)
        r = math.dist(cen[:2], sp_[:2])
        a0 = math.degrees(math.atan2(sp_[1] - cen[1], sp_[0] - cen[0])) % 360
        a1 = math.degrees(math.atan2(ep[1] - cen[1], ep[0] - cen[0])) % 360
        new_ent(I, 'ARC', [(10, cen), (40, r), (50, a0), (51, a1)])
        return
    a = c.point()
    b = c.point(a)
    if type(b) is str:
        I.warn('ARC のオプションは 3点指定と "C"(中心) のみ対応')
        raise CmdEnd()
    d = c.point(b)
    cc = circle3(a, b, d)
    if not cc:
        return
    ux, uy, r = cc
    t = lambda p: math.degrees(math.atan2(p[1] - uy, p[0] - ux)) % 360
    cross = (b[0] - a[0]) * (d[1] - a[1]) - (b[1] - a[1]) * (d[0] - a[0])
    a0, a1 = (t(a), t(d)) if cross > 0 else (t(d), t(a))
    new_ent(I, 'ARC', [(10, (ux, uy, 0.0)), (40, r), (50, a0), (51, a1)])


def cmd_point(I, c):
    p = c.point()
    if p:
        new_ent(I, 'POINT', [(10, p)])


def cmd_text(I, c):
    just = None
    style = I.sysvars.get('TEXTSTYLE', 'Standard')
    while True:
        v = c.peek()
        if type(v) is str and norm_cmd(v) in ('J', 'JUSTIFY', 'S', 'STYLE'):
            opt = norm_cmd(c.raw())
            if opt in ('J', 'JUSTIFY'):
                just = norm_cmd(c.raw())
            else:
                style = c.string()
            continue
        if type(v) is str and norm_cmd(v) in ('TL', 'TC', 'TR', 'ML', 'MC', 'MR', 'BL', 'BC', 'BR', 'C', 'M', 'R',
                                               'L', 'A', 'F'):
            just = norm_cmd(c.raw())
            continue
        break
    p = c.point()
    st = I.dwg.find_rec('STYLE', style)
    fixed_h = st.get(40, 0.0) if st is not None else 0.0
    if fixed_h:
        h = fixed_h
    else:
        h = c.number(p)
        if h is None:
            h = float(I.sysvars.get('TEXTSIZE', 2.5))
        I.sysvars['TEXTSIZE'] = float(h)
    rot = c.number(p)
    if rot is None:
        rot = 0.0
    s = c.string()
    jm = {'L': (0, 0), 'C': (1, 0), 'R': (2, 0), 'A': (3, 0), 'M': (4, 0), 'F': (5, 0), 'TL': (0, 3),
          'TC': (1, 3), 'TR': (2, 3), 'ML': (0, 2), 'MC': (1, 2), 'MR': (2, 2), 'BL': (0, 1), 'BC': (1, 1),
          'BR': (2, 1)}
    h72, v73 = jm.get(just or 'L', (0, 0))
    pairs = [(10, p), (40, float(h)), (1, s), (50, float(rot)), (7, style)]
    if h72 or v73:
        pairs += [(72, h72), (11, p), (73, v73)]
    new_ent(I, 'TEXT', pairs)


def cmd_erase(I, c):
    for o in c.selection():
        _entdel(I, [Ename(o.h)]) if not o.deleted else None


def _xf_cmd(I, c, kind):
    sel = c.selection()
    base = c.point()
    if base is None:
        return
    if kind in ('MOVE', 'COPY'):
        while True:
            p2 = c.point(base) if c.more() else None
            if p2 is None:
                if kind == 'MOVE' and not c.more():
                    pass
                return
            d = [p2[i] - base[i] for i in range(3)]
            for o in sel:
                tgt = copy_ent(I, o) if kind == 'COPY' else o
                xform_ent(I, tgt, XF.move(d))
            if kind == 'MOVE':
                return
    elif kind == 'ROTATE':
        ang = c.number(base)
        if type(ang) is str:
            I.warn('ROTATE のオプション "%s" は未対応' % ang)
            raise CmdEnd()
        xf = XF.rotate(base, math.radians(float(ang)))
        for o in sel:
            xform_ent(I, o, xf)
    elif kind == 'SCALE':
        k = c.number(base)
        if type(k) is str:
            I.warn('SCALE のオプション "%s" は未対応' % k)
            raise CmdEnd()
        xf = XF.scale(base, float(k))
        for o in sel:
            xform_ent(I, o, xf)


def cmd_mirror(I, c):
    sel = c.selection()
    p1 = c.point()
    p2 = c.point(p1)
    yn = c.string() if c.more() else 'N'
    xf = XF.mirror(p1, p2)
    for o in sel:
        tgt = o if norm_cmd(yn).startswith('Y') else copy_ent(I, o)
        xform_ent(I, tgt, xf)


def _color_val(s):
    if isnum(s):
        return int(s)
    u = str(s).upper()
    names = {'RED': 1, 'YELLOW': 2, 'GREEN': 3, 'CYAN': 4, 'BLUE': 5, 'MAGENTA': 6, 'WHITE': 7, 'BYLAYER': 256,
             'BYBLOCK': 0, '赤': 1, '黄': 2, '緑': 3, 'シアン': 4, '青': 5, 'マゼンタ': 6, '白': 7}
    if u in names:
        return names[u]
    try:
        return int(u)
    except ValueError:
        return None


def cmd_chprop(I, c, change=False):
    sel = c.selection()
    if change:
        v = c.string()
        if not norm_cmd(v).startswith('P'):
            I.warn('CHANGE コマンドは "P"(プロパティ) のみ対応')
            raise CmdEnd()
    while c.more():
        opt = norm_cmd(c.string())
        if opt == '':
            break
        if opt in ('LA', 'LAYER'):
            ln = c.string()
            ensure_layer(I, ln)
            for o in sel:
                o.set(8, I.dwg.find_rec('LAYER', ln).get(2))
        elif opt in ('C', 'COLOR'):
            col = _color_val(c.raw())
            for o in sel:
                if col == 256:
                    o.p = [pr for pr in o.p if pr[0] != 62]
                else:
                    o.set(62, col)
        elif opt in ('LT', 'LTYPE'):
            lt = c.string()
            for o in sel:
                o.set(6, lt)
        elif opt in ('S', 'LTSCALE', 'LTS'):
            k = c.number()
            for o in sel:
                o.set(48, float(k))
        elif opt in ('LW', 'LWEIGHT'):
            w = c.raw()
            for o in sel:
                o.set(370, -1 if str(w).upper() == 'BYLAYER' else int(round(float(w) * 100)))
        elif opt in ('T', 'THICKNESS'):
            k = c.number()
            for o in sel:
                o.set(39, float(k))
        else:
            I.warn('CHPROP のオプション "%s" は未対応' % opt)
            raise CmdEnd()


def cmd_layer(I, c):
    dwg = I.dwg

    def names(s):
        if s == '' or s is None:
            return [I.sysvars.get('CLAYER', '0')]
        res = []
        for n in str(s).split(','):
            n = n.strip()
            if any(ch in n for ch in '*?#@'):
                res += [r.get(2) for r in dwg.records('LAYER') if wcmatch(str(r.get(2)), n, True)]
            elif n:
                res.append(n)
        return res
    while c.more():
        opt = norm_cmd(c.string())
        if opt == '':
            break
        if opt in ('M', 'MAKE'):
            n = c.string()
            if dwg.find_rec('LAYER', n) is None:
                dwg.make_layer(n)
            I.sysvars['CLAYER'] = dwg.find_rec('LAYER', n).get(2)
            dwg.hvar_set('$CLAYER', I.sysvars['CLAYER'])
        elif opt in ('N', 'NEW'):
            for n in c.string().split(','):
                if n.strip():
                    dwg.make_layer(n.strip())
        elif opt in ('S', 'SET'):
            n = c.string()
            if dwg.find_rec('LAYER', n) is None:
                I.echo('画層 "%s" が見つかりません。\n' % n)
                continue
            I.sysvars['CLAYER'] = dwg.find_rec('LAYER', n).get(2)
            dwg.hvar_set('$CLAYER', I.sysvars['CLAYER'])
        elif opt in ('C', 'COLOR'):
            v = c.raw()
            if type(v) is str and norm_cmd(v) in ('T', 'TRUECOLOR', 'CO', 'COLORBOOK'):
                c.raw()
                v = 7
                I.warn('LAYER の TrueColor/カラーブックは未対応（7 にしました）')
            col = _color_val(v)
            for n in names(c.string()):
                r = dwg.find_rec('LAYER', n)
                if r is not None and col is not None:
                    r.set(62, abs(col) if r.get(62, 7) >= 0 else -abs(col))
        elif opt in ('L', 'LT', 'LTYPE'):
            lt = c.string()
            if not dwg.find_rec('LTYPE', lt):
                I.warn('LAYER: 線種 "%s" がロードされていません' % lt)
            for n in names(c.string()):
                r = dwg.find_rec('LAYER', n)
                if r is not None and dwg.find_rec('LTYPE', lt):
                    r.set(6, dwg.find_rec('LTYPE', lt).get(2))
        elif opt in ('ON', 'OFF'):
            for n in names(c.string()):
                r = dwg.find_rec('LAYER', n)
                if r is not None:
                    col = abs(r.get(62, 7))
                    r.set(62, col if opt == 'ON' else -col)
        elif opt in ('F', 'FREEZE', 'T', 'THAW', 'LO', 'LOCK', 'U', 'UNLOCK'):
            bit = 1 if opt in ('F', 'FREEZE', 'T', 'THAW') else 4
            on = opt in ('F', 'FREEZE', 'LO', 'LOCK')
            for n in names(c.string()):
                r = dwg.find_rec('LAYER', n)
                if r is None:
                    continue
                if bit == 1 and on and str(n).upper() == str(I.sysvars.get('CLAYER')).upper():
                    I.echo('現在画層はフリーズできません。\n')
                    continue
                f = r.get(70, 0)
                r.set(70, (f | bit) if on else (f & ~bit))
        elif opt in ('LW', 'LWEIGHT'):
            w = c.raw()
            for n in names(c.string()):
                r = dwg.find_rec('LAYER', n)
                if r is not None:
                    r.set(370, int(round(float(w) * 100)) if isnum(w) or str(w).replace('.', '').isdigit() else -3)
        elif opt in ('P', 'PLOT'):
            v = c.string()
            for n in names(c.string()):
                r = dwg.find_rec('LAYER', n)
                if r is not None:
                    r.set(290, 0 if norm_cmd(v).startswith('N') else 1)
        elif opt in ('?',):
            c.string()
        else:
            I.warn('LAYER のオプション "%s" は未対応' % opt)
            raise CmdEnd()


def cmd_insert(I, c):
    name = c.string()
    b = I.dwg.blocks().get(name.upper().lstrip('*'))
    if b is None:
        I.warn('INSERT: ブロック "%s" が定義されていません（外部ファイルからの挿入は未対応）' % name)
        raise CmdEnd()
    while type(c.peek()) is str and norm_cmd(c.peek()) in ('S', 'SCALE', 'X', 'Y', 'Z', 'R', 'ROTATE', 'B', 'BASEPOINT'):
        opt = norm_cmd(c.raw())
        c.raw()
        I.warn('INSERT の事前オプション %s は無視しました' % opt)
    p = c.point()
    sx = c.number(p) if c.more() else 1.0
    sx = 1.0 if sx is None else float(sx) if isnum(sx) else 1.0
    sy = c.number(p) if c.more() else sx
    sy = sx if sy is None else float(sy) if isnum(sy) else sx
    rot = c.number(p) if c.more() else 0.0
    rot = 0.0 if rot is None else float(rot) if isnum(rot) else 0.0
    attdefs = [e for e in b['ents'] if e.typ == 'ATTDEF' and not e.deleted and not (e.get(70, 0) & 2)]
    vals = None
    if attdefs and int(I.sysvars.get('ATTREQ', 1)):
        vals = []
        for ad in attdefs:
            if c.more():
                vals.append(c.string())
            else:
                vals.append(ad.get(1, ''))
    insert_block(I, VlaObj('coll', 'modelspace'), p, b['name'], sx, sy, sx, math.radians(rot), vals)


def cmd_block(I, c):
    name = c.string()
    base = c.point()
    sel = c.selection()
    ents = []
    for o in sel:
        pairs = [(cc, v) for cc, v in o.p if cc not in (5, 330, 100, 102, 360)]
        pairs = [pr for pr in pairs if not (type(pr[1]) is str and pr[1].startswith(('{', '}')) and pr[0] == 102)]
        ents.append((pairs, None))
        _entdel(I, [Ename(o.h)])
    commit_block(I, {'name': name, 'pairs': [(0, 'BLOCK'), (2, name), (70, 0), (10, base)], 'ents': ents})


def cmd_setvar(I, c, name=None):
    if name is None:
        name = c.string()
    v = c.raw()
    if v == '' or v is None:
        return
    old = I.sysvars.get(name.upper())
    if isnum(old) and type(v) is str:
        try:
            v = int(v) if type(old) is int else float(v)
        except ValueError:
            pass
    try:
        _setvar(I, [name, v])
    except LispError as e:
        I.echo('%s\n' % e.msg)


def cmd_consume_all(I, c):
    while c.more():
        c.raw()


COMMANDS = {
    'LINE': cmd_line, 'L': cmd_line, 'PLINE': cmd_pline, 'PL': cmd_pline, 'CIRCLE': cmd_circle, 'C': cmd_circle,
    'ARC': cmd_arc, 'A': cmd_arc, 'POINT': cmd_point, 'PO': cmd_point, 'TEXT': cmd_text, 'DTEXT': cmd_text,
    'DT': cmd_text, 'ERASE': cmd_erase, 'E': cmd_erase,
    'MOVE': lambda I, c: _xf_cmd(I, c, 'MOVE'), 'M': lambda I, c: _xf_cmd(I, c, 'MOVE'),
    'COPY': lambda I, c: _xf_cmd(I, c, 'COPY'), 'CO': lambda I, c: _xf_cmd(I, c, 'COPY'),
    'CP': lambda I, c: _xf_cmd(I, c, 'COPY'),
    'ROTATE': lambda I, c: _xf_cmd(I, c, 'ROTATE'), 'RO': lambda I, c: _xf_cmd(I, c, 'ROTATE'),
    'SCALE': lambda I, c: _xf_cmd(I, c, 'SCALE'), 'SC': lambda I, c: _xf_cmd(I, c, 'SCALE'),
    'MIRROR': cmd_mirror, 'MI': cmd_mirror, 'CHPROP': cmd_chprop,
    'CHANGE': lambda I, c: cmd_chprop(I, c, True), 'LAYER': cmd_layer, 'LA': cmd_layer,
    'INSERT': cmd_insert, 'I': cmd_insert, 'BLOCK': cmd_block, 'B': cmd_block,
    'SETVAR': cmd_setvar,
}
NOOP_CMDS = {'REGEN', 'REGENALL', 'RE', 'REDRAW', 'REDRAWALL', 'R', 'ZOOM', 'Z', 'PAN', 'P', 'UNDO', 'U',
             'OSNAP', 'OS', 'ORTHO', 'SNAP', 'GRID', 'VIEW', 'UCS', 'PLAN', 'DELAY', 'CANCEL', 'VSCURRENT',
             'SHADEMODE', 'TEXTSCR', 'GRAPHSCR', 'QSAVE', 'SAVE', 'SAVEAS', 'PURGE', 'AUDIT', 'LAYERP',
             'SELECT', 'ATTSYNC', 'REGENAUTO', 'CLOSE', 'QUIT', 'EXIT', 'LTSCALE'}


def run_command_call(I, args, fname='command'):
    I.cmd_log.append(' '.join(short(x, 40) for x in args))
    I.echo('[%s] %s\n' % (fname, ' '.join(short(x, 40) for x in args)))
    if not args:
        return None
    c = CArgs(I, args)
    while c.more():
        v = c.raw('コマンド名')
        if v is None or v == '':
            continue
        if type(v) is not str:
            I.warn('command: コマンド名の位置に文字列以外 %s が渡されました' % short(v))
            continue
        name = norm_cmd(v)
        h = COMMANDS.get(name)
        try:
            if h is not None:
                h(I, c)
            elif name in NOOP_CMDS:
                if name in ('QSAVE', 'SAVE', 'SAVEAS', 'CLOSE', 'QUIT'):
                    I.warn('command "%s" は実行しません（図面は保存されません）' % name)
                if name == 'LTSCALE':
                    cmd_setvar(I, c, 'LTSCALE')
                    continue
                cmd_consume_all(I, c)
            elif name in I.sysvars:
                cmd_setvar(I, c, name)
            else:
                I.warn('command "%s" は lispcheck では再現していません（引数は読み飛ばしました）' % name)
                cmd_consume_all(I, c)
        except CmdEnd:
            pass
    return None


@bi('command vl-cmdf', 'approx', '代表的なコマンドのみ再現')
def _command(I, a):
    return run_command_call(I, a, 'command')


@bi('command-s', 'approx', '代表的なコマンドのみ再現')
def _command_s(I, a):
    run_command_call(I, a, 'command-s')
    return T


# =====================================================================
#  画像出力（matplotlib があれば）
# =====================================================================
ACI_BASE = {1: (255, 0, 0), 2: (255, 255, 0), 3: (0, 255, 0), 4: (0, 255, 255), 5: (0, 0, 255),
            6: (255, 0, 255), 7: (255, 255, 255), 8: (128, 128, 128), 9: (192, 192, 192)}


def aci_rgb(n):
    import colorsys
    n = abs(int(n))
    if n in ACI_BASE:
        r = ACI_BASE[n]
    elif 250 <= n <= 255:
        g = int(51 + (n - 250) * 40.8)
        r = (g, g, g)
    elif 10 <= n <= 249:
        hue = ((n // 10) - 1) * 15
        k = n % 10
        val = [1.0, 0.65, 0.5, 0.3, 0.15][k // 2]
        sat = 1.0 if k % 2 == 0 else 0.5
        rr, gg, bb = colorsys.hsv_to_rgb(hue / 360.0, sat, val)
        r = (int(rr * 255), int(gg * 255), int(bb * 255))
    else:
        r = (255, 255, 255)
    return tuple(x / 255.0 for x in r)


def _mat_mul(m1, m2):
    a1, b1, c1, d1, e1, f1 = m1
    a2, b2, c2, d2, e2, f2 = m2
    return (a1 * a2 + b1 * c2, a1 * b2 + b1 * d2, c1 * a2 + d1 * c2, c1 * b2 + d1 * d2,
            a1 * e2 + b1 * f2 + e1, c1 * e2 + d1 * f2 + f1)


def _mat_pt(m, p):
    a, b, c, d, e, f = m
    return (a * p[0] + b * p[1] + e, c * p[0] + d * p[1] + f)


IDENT = (1.0, 0.0, 0.0, 1.0, 0.0, 0.0)


def _insert_mat(dwg, o):
    b = dwg.blocks().get(str(o.get(2, '')).upper())
    base = b['block'].get(10, (0.0, 0.0, 0.0)) if b else (0.0, 0.0, 0.0)
    ins = o.get(10, (0.0, 0.0, 0.0))
    sx, sy = o.get(41, 1.0), o.get(42, 1.0)
    rot = math.radians(o.get(50, 0.0))
    cr, sr = math.cos(rot), math.sin(rot)
    m = (cr * sx, -sr * sy, sr * sx, cr * sy, ins[0], ins[1])
    return b, _mat_mul(m, (1, 0, 0, 1, -base[0], -base[1]))


def _prim_samples(pr):
    if pr[0] == 'L':
        return [(pr[1], pr[2]), (pr[3], pr[4])]
    _, cx, cy, r, a0, sw = pr
    n = max(8, int(abs(sw) / TWO_PI * 72))
    return [(cx + r * math.cos(a0 + sw * i / n), cy + r * math.sin(a0 + sw * i / n)) for i in range(n + 1)]


def collect_drawables(dwg, objs, m=IDENT, inh_color=7, depth=0, hl=None, out=None, deleted_ok=False):
    if out is None:
        out = {'lines': [], 'texts': [], 'fills': [], 'points': [], 'under': [], 'labels': []}
    for o in objs:
        if o.deleted and not deleted_ok:
            continue
        t = o.typ
        if t in ('SEQEND', 'VERTEX', 'ATTDEF', 'VIEWPORT', 'BLOCK', 'ENDBLK'):
            if t != 'ATTDEF' or depth == 0:
                continue
        lay = dwg.find_rec('LAYER', o.get(8, '0'))
        lcol = lay.get(62, 7) if lay is not None else 7
        if lay is not None and (lcol < 0 or lay.get(70, 0) & 1) and not (hl and o.h in hl):
            continue
        col = o.get(62, 256)
        if col == 256:
            col = abs(lcol)
        elif col == 0:
            col = inh_color
        rgb = aci_rgb(col)
        mark = hl.get(o.h) if hl else None
        segs = []
        if t in ('INSERT', 'DIMENSION'):
            if t == 'INSERT':
                b, im = _insert_mat(dwg, o)
            else:
                b, im = dwg.blocks().get(str(o.get(2, '')).upper()), IDENT
            if b and depth < 6:
                sub = collect_drawables(dwg, [e for e in b['ents'] if e.typ != 'ATTDEF'], _mat_mul(m, im), col,
                                        depth + 1, None, None)
                for k in out:
                    out[k] += sub[k]
                if mark:
                    for pts, _, _ in sub['lines']:
                        out['under'].append((pts, mark, 6))
            else:
                p = _mat_pt(m, o.get(10, (0, 0, 0)))
                out['points'].append((p, rgb))
            if t == 'INSERT':
                for a in attribs_of(dwg, o) if o.sec == 'ENTITIES' else []:
                    if not (a.get(70, 0) & 1):
                        collect_drawables(dwg, [a], m, col, depth, hl, out)
            if depth == 0:
                out['labels'].append((_mat_pt(m, o.get(10, (0, 0, 0))), o.h))
            continue
        if t in ('TEXT', 'ATTRIB', 'MTEXT', 'ATTDEF'):
            corners = [_mat_pt(m, p) for p in text_corners(o)]
            s = mtext_plain(o) if t == 'MTEXT' else str(o.get(1, '') if t != 'ATTDEF' else o.get(2, ''))
            out['texts'].append((corners, s, rgb, o.deleted))
            if mark:
                out['under'].append((corners + corners[:1], mark, 2.5))
            if depth == 0:
                out['labels'].append((corners[0], o.h))
            continue
        if t == 'POINT':
            p = _mat_pt(m, o.get(10, (0, 0, 0)))
            out['points'].append((p, rgb))
            if mark:
                out['under'].append(([p, (p[0] + 1e-9, p[1])], mark, 8))
            if depth == 0:
                out['labels'].append((p, o.h))
            continue
        if t == 'HATCH':
            pts = [(v[0], v[1]) for c, v in o.main() if c in (10, 11) and type(v) is tuple and len(v) == 2]
            if len(pts) > 2:
                out['fills'].append(([_mat_pt(m, p) for p in pts], rgb))
            continue
        prims = ent_prims(dwg, o)
        for pr in prims:
            pts = [_mat_pt(m, p) for p in _prim_samples(pr)]
            segs.append(pts)
        lw = 1.0
        if t == 'LWPOLYLINE' and (o.get(43, 0.0) or 0) > 0:
            lw = 2.0
        for pts in segs:
            out['lines'].append((pts, rgb, lw if not o.deleted else -1))
            if mark:
                out['under'].append((pts, mark, 6))
        if segs and depth == 0:
            sg = segs[0]
            k = len(sg) // 2
            lp = sg[k] if len(sg) > 2 else ((sg[0][0] + sg[-1][0]) / 2, (sg[0][1] + sg[-1][1]) / 2)
            out['labels'].append((lp, o.h))
    return out


_FONT = None


def _font():
    global _FONT
    if _FONT is not None:
        return _FONT
    from matplotlib.font_manager import FontProperties, findSystemFonts
    path = None
    for f in findSystemFonts():
        fl = f.lower()
        if ('notosanscjk' in fl.replace('-', '').replace('_', '') or 'ipag' in fl or 'ipaex' in fl
                or 'meiryo' in fl or 'msgothic' in fl or 'yugoth' in fl) and 'bold' not in fl:
            path = f
            break
    _FONT = FontProperties(fname=path) if path else FontProperties()
    return _FONT


def draw_panel(ax, dwg, hl=None, labels=False, title='', show_deleted=False):
    from matplotlib.collections import LineCollection
    from matplotlib.textpath import TextPath
    from matplotlib.patches import PathPatch, Polygon
    from matplotlib.transforms import Affine2D
    ax.set_facecolor('black')
    objs = [o for o in dwg.ents() if (not o.deleted) or (show_deleted and hl and hl.get(o.h) == 'del')]
    d = collect_drawables(dwg, objs, hl=hl, deleted_ok=show_deleted)
    under_col = {'add': (0.2, 1.0, 0.2, 0.45), 'mod': (1.0, 0.6, 0.0, 0.5), 'del': (1.0, 0.1, 0.1, 0.5)}
    if d['under']:
        ax.add_collection(LineCollection([p for p, _, _ in d['under']], colors=[under_col[k] for _, k, _ in d['under']],
                                         linewidths=[w for _, _, w in d['under']], capstyle='round', zorder=1))
    for pts, rgb in d['fills']:
        ax.add_patch(Polygon(pts, closed=True, facecolor=rgb + (0.25,), edgecolor=rgb, lw=0.5, zorder=2))
    normal = [(p, c, w) for p, c, w in d['lines'] if w >= 0]
    dele = [(p, c, w) for p, c, w in d['lines'] if w < 0]
    if normal:
        ax.add_collection(LineCollection([p for p, _, _ in normal], colors=[c for _, c, _ in normal],
                                         linewidths=[w for _, _, w in normal], zorder=3))
    if dele:
        ax.add_collection(LineCollection([p for p, _, _ in dele], colors='red', linestyles='dashed',
                                         linewidths=1.0, zorder=3))
    xs, ys = [], []
    for p, _, _ in d['lines']:
        xs += [q[0] for q in p]
        ys += [q[1] for q in p]
    fp = _font()
    for corners, s, rgb, deleted in d['texts']:
        xs += [q[0] for q in corners]
        ys += [q[1] for q in corners]
        (x0, y0), (x1, y1), (x2, y2), (x3, y3) = corners
        h = math.hypot(x3 - x0, y3 - y0)
        w = math.hypot(x1 - x0, y1 - y0)
        rot = math.atan2(y1 - y0, x1 - x0)
        first = s.split('\n')[0] if s else ''
        if not first.strip() or h <= 0:
            continue
        nlines = max(1, len(s.split('\n')))
        lh = h / nlines if nlines > 1 else h
        for li, line in enumerate(s.split('\n')):
            if not line.strip():
                continue
            try:
                tp = TextPath((0, 0), line, size=1.0, prop=fp)
            except Exception:
                continue
            ext = tp.get_extents()
            sc = lh / 1.0 if nlines > 1 else h
            tw = ext.width * sc
            sxf = (w / tw) if (tw > 0 and nlines == 1 and w > 0) else 1.0
            sxf = min(max(sxf, 0.3), 3.0)
            tr = Affine2D().scale(sc * sxf, sc).translate(0, -(li + 1) * lh * 1.0 + h if nlines > 1 else 0) \
                .rotate(rot).translate(x0, y0)
            ax.add_patch(PathPatch(tr.transform_path(tp), facecolor=('red' if deleted else rgb), edgecolor='none',
                                   zorder=4))
    for p, rgb in d['points']:
        ax.plot([p[0]], [p[1]], marker='x', color=rgb, ms=5, zorder=4)
        xs.append(p[0])
        ys.append(p[1])
    if labels:
        for p, h in d['labels']:
            ax.annotate(h, p, color='#9ecbff', fontsize=7, zorder=6,
                        bbox=dict(boxstyle='round,pad=0.1', fc='#102030', ec='none', alpha=0.8))
    ax.set_aspect('equal', adjustable='box')
    ax.set_title(title, color='black', fontproperties=fp)
    ax.tick_params(colors='#555555', labelsize=7)
    return (min(xs), min(ys), max(xs), max(ys)) if xs else None


def save_png(path, panels, labels=False, view=None):
    try:
        import matplotlib
        matplotlib.use('Agg')
        import matplotlib.pyplot as plt
    except ImportError:
        return 'matplotlib が無いため PNG を作成できませんでした（pip install matplotlib）'
    n = len(panels)
    fig, axs = plt.subplots(1, n, figsize=(8 * n, 7.5), dpi=100, squeeze=False)
    bbs = []
    for ax, (dwg, title, hl, show_del) in zip(axs[0], panels):
        bb = draw_panel(ax, dwg, hl, labels, title, show_del)
        if bb:
            bbs.append(bb)
    if view:
        x1, y1, x2, y2 = view
    elif bbs:
        x1 = min(b[0] for b in bbs)
        y1 = min(b[1] for b in bbs)
        x2 = max(b[2] for b in bbs)
        y2 = max(b[3] for b in bbs)
    else:
        x1, y1, x2, y2 = 0, 0, 100, 100
    mx = max(x2 - x1, y2 - y1, 1e-6) * 0.05
    for ax in axs[0]:
        ax.set_xlim(x1 - mx, x2 + mx)
        ax.set_ylim(y1 - mx, y2 + mx)
    fig.tight_layout()
    fig.savefig(path, facecolor='white')
    plt.close(fig)
    return None


# =====================================================================
#  差分・レポート
# =====================================================================
def describe(dwg, o, pairs=None):
    p = pairs if pairs is not None else o.p
    tmp = DObj(p, o.sec)
    t = tmp.typ
    g = tmp.get
    lay = g(8)
    s = '%s h=%s' % (t, o.h)
    if lay is not None and o.sec in ('ENTITIES', 'BLOCKS'):
        s += ' 画層=%s' % lay
    if t == 'LINE':
        s += ' %s→%s' % (fmt_pt(g(10, ())), fmt_pt(g(11, ())))
    elif t in ('CIRCLE', 'ARC'):
        s += ' 中心%s R=%s' % (fmt_pt(g(10, ())), fmt_real(g(40, 0.0)))
        if t == 'ARC':
            s += ' %s°→%s°' % (fmt_real(g(50, 0.0)), fmt_real(g(51, 0.0)))
    elif t in ('TEXT', 'MTEXT', 'ATTRIB', 'ATTDEF'):
        s += ' %s "%s"' % (fmt_pt(g(10, ())), short(str(g(1, '')), 40, False))
        if t in ('ATTRIB', 'ATTDEF'):
            s += ' タグ=%s' % g(2, '')
    elif t == 'LWPOLYLINE':
        vs = [v for c, v in p if c == 10]
        s += ' 頂点%d%s' % (len(vs), ' 閉' if g(70, 0) & 1 else '')
        if vs:
            s += ' %s…' % fmt_pt(vs[0])
    elif t == 'INSERT':
        s += ' ブロック=%s %s' % (g(2, ''), fmt_pt(g(10, ())))
    elif t in ('LAYER', 'STYLE', 'LTYPE', 'APPID', 'BLOCK_RECORD', 'DIMSTYLE'):
        s += ' 名前=%s' % g(2, '')
        if t == 'LAYER':
            s += ' 色=%s 線種=%s' % (g(62, ''), g(6, ''))
    elif t == 'POINT':
        s += ' %s' % fmt_pt(g(10, ()))
    return s


def _vstr(v):
    if type(v) is tuple:
        return fmt_pt(v)
    if type(v) is float:
        return fmt_real(v)
    if type(v) is str:
        return quote_str(v)
    return str(v)


def pair_diff(old, new):
    def occ(p):
        cnt = {}
        res = {}
        order = []
        for c, v in p:
            k = cnt.get(c, 0)
            cnt[c] = k + 1
            res[(c, k)] = v
            order.append((c, k))
        return res, order
    a, oa = occ(old)
    b, ob = occ(new)
    lines = []
    keys = list(oa) + [k for k in ob if k not in a]
    for k in keys:
        va, vb_ = a.get(k, _UNB), b.get(k, _UNB)
        if va == vb_:
            continue
        nm = '%d' % k[0] + ('[%d]' % k[1] if k[1] else '')
        if va is _UNB:
            lines.append('%s: (追加) %s' % (nm, _vstr(vb_)))
        elif vb_ is _UNB:
            lines.append('%s: %s → (削除)' % (nm, _vstr(va)))
        else:
            lines.append('%s: %s → %s' % (nm, _vstr(va), _vstr(vb_)))
    return lines


def compute_diff(snap, dwg):
    added, modified, deleted = [], [], []
    for h, o in dwg.by_h.items():
        s = snap.get(h)
        if s is None:
            if not o.deleted:
                added.append(o)
            continue
        was_del, old_p, _ = s
        if o.deleted and not was_del:
            deleted.append(o)
        elif not o.deleted and was_del:
            added.append(o)
        elif not o.deleted and old_p != o.p:
            if o.typ == 'TABLE' and [pr for pr in old_p if pr[0] != 70] == [pr for pr in o.p if pr[0] != 70]:
                continue
            modified.append((o, old_p))
    return added, modified, deleted


SEC_JA = {'ENTITIES': '図形', 'BLOCKS': 'ブロック定義内', 'TABLES': 'テーブル(画層等)', 'OBJECTS': 'オブジェクト'}


def build_report(I, ctx):
    L_ = []
    ap = L_.append
    ap('=' * 70)
    ap('lispcheck %s 実行レポート' % VERSION)
    ap('=' * 70)
    ap('図面: %s  (%s, 文字コード %s)' % (ctx.get('dxf') or '(空の新規図面)', I.dwg.version, I.dwg.enc))
    for f, ok in ctx.get('loads', []):
        ap('読込: %s  %s' % (f, 'OK' if ok else '失敗'))
    for kind, val, ok, res in ctx.get('steps', []):
        ap('%s: %s  → %s%s' % ('コマンド' if kind == 'cmd' else '式', val, '成功' if ok else 'エラー',
                               ('  戻り値 ' + short(res, 120)) if ok and kind == 'eval' else ''))
    if ctx.get('cmds_defined'):
        ap('定義されたコマンド: %s' % ', '.join(ctx['cmds_defined']))
    ap('')
    ap('--- コマンドライン出力 ' + '-' * 46)
    text = ''.join(I.out)
    if len(text) > 12000:
        text = text[:6000] + '\n...（中略 %d 文字）...\n' % (len(text) - 12000) + text[-6000:]
    ap(text.strip('\n') or '(なし)')
    ap('')
    ap('--- エラー ' + '-' * 58)
    if not I.errors:
        ap('なし')
    for e in I.errors:
        ap('● %s  [%s]' % (e['msg'], e['where']))
        if e.get('pos'):
            ap('   場所: %s:%s' % e['pos'])
        if e.get('form'):
            ap('   評価中の式: %s' % e['form'])
        if e.get('trace'):
            ap('   呼び出し履歴（外→内）:')
            for n, p, args in e['trace'][-12:]:
                ap('     %s%s  引数 (%s)' % (n, ('  ←%s:%s' % p) if p else '', ' '.join(args)))
    ap('')
    ap('--- 警告（シミュレーションの限界・AutoCADとの差の可能性）' + '-' * 10)
    if not I.warns:
        ap('なし')
    for w, n in I.warns.items():
        ap('△ %s%s' % (w, ('  ×%d' % n) if n > 1 else ''))
    ap('')
    added, modified, deleted = compute_diff(ctx['snap0'], I.dwg)
    ap('--- 図面の変更: 追加 %d / 変更 %d / 削除 %d ' % (len(added), len(modified), len(deleted)) + '-' * 20)
    lim = ctx.get('diff_limit', 60)
    shown = 0
    for o in added:
        if shown >= lim:
            break
        ap('[追加][%s] %s' % (SEC_JA.get(o.sec, o.sec), describe(I.dwg, o)))
        shown += 1
    for o, old in modified:
        if shown >= lim:
            break
        ap('[変更][%s] %s' % (SEC_JA.get(o.sec, o.sec), describe(I.dwg, o)))
        for ln in pair_diff(old, o.p)[:15]:
            ap('      ' + ln)
        shown += 1
    for o in deleted:
        if shown >= lim:
            break
        ap('[削除][%s] %s' % (SEC_JA.get(o.sec, o.sec), describe(I.dwg, o)))
        shown += 1
    total = len(added) + len(modified) + len(deleted)
    if total > shown:
        ap('... 他 %d 件（--diff-limit で表示数を増やせます）' % (total - shown))
    ap('')
    ch = []
    for k, v in I.sysvars.items():
        v0 = I.sysvars0.get(k, _UNB)
        if v0 is _UNB or not lequal(v0, v):
            ch.append('%s: %s → %s' % (k, short(v0, 40) if v0 is not _UNB else '(なし)', short(v, 40)))
    ap('--- システム変数の変更（実行後に元へ戻っていないもの）' + '-' * 12)
    ap('\n'.join(ch) if ch else 'なし')
    if I.asserts:
        ap('')
        ok = sum(1 for a in I.asserts if a['ok'])
        ap('--- アサーション: %d/%d 成功 ' % (ok, len(I.asserts)) + '-' * 40)
        for a in I.asserts:
            if not a['ok']:
                ap('✗ %s %s %s %s' % (a['pos'], a['expr'], a['msg'], a['detail']))
        if ok == len(I.asserts):
            ap('すべて成功')
    if I.callcount:
        ap('')
        ap('--- ユーザー関数の呼び出し回数 ' + '-' * 37)
        items = sorted([kv for kv in I.callcount.items() if kv[0] != 'LAMBDA'], key=lambda x: -x[1])[:25]
        ap(', '.join('%s×%d' % (n, c) for n, c in items))
        never = [n.upper() for n in I.defined if n.upper() not in I.callcount]
        if never:
            ap('一度も呼ばれなかった関数: ' + ', '.join(sorted(never)[:40]))
    if I.inputs:
        ap('')
        ap('△ 使われずに残った入力 %d 個: %s' % (len(I.inputs), ', '.join(show_input(v) for v in I.inputs[:10])))
    if ctx.get('files'):
        ap('')
        ap('--- 出力ファイル ' + '-' * 52)
        for f in ctx['files']:
            ap(f)
    ap('=' * 70)
    return '\n'.join(L_)


def report_json(I, ctx):
    added, modified, deleted = compute_diff(ctx['snap0'], I.dwg)
    return {
        'version': VERSION,
        'dxf': ctx.get('dxf'),
        'steps': [{'kind': k, 'value': v, 'ok': ok, 'result': short(r, 300)} for k, v, ok, r in ctx.get('steps', [])],
        'output': ''.join(I.out),
        'errors': [dict(e, pos=('%s:%s' % e['pos']) if e.get('pos') else None,
                        trace=[{'func': n, 'pos': ('%s:%s' % p) if p else None, 'args': a} for n, p, a in e['trace']])
                   for e in I.errors],
        'warnings': [{'msg': w, 'count': n} for w, n in I.warns.items()],
        'added': [describe(I.dwg, o) for o in added],
        'modified': [{'what': describe(I.dwg, o), 'changes': pair_diff(old, o.p)} for o, old in modified],
        'deleted': [describe(I.dwg, o) for o in deleted],
        'asserts': I.asserts,
        'sysvar_changes': {k: [short(I.sysvars0.get(k), 60), short(v, 60)] for k, v in I.sysvars.items()
                           if not lequal(I.sysvars0.get(k, _UNB), v)},
        'files': ctx.get('files', []),
    }


# =====================================================================
#  静的チェック (lint)
# =====================================================================
KNOWN_VARS = {'t', 'pi', 'pause', 'nil', '*error*', ':vlax-true', ':vlax-false', ':vlax-null'}


class LintCtx:
    def __init__(self):
        self.defuns = []
        self.calls = []
        self.all_sets = set()
        self.issues = []


def lint_walk(x, R, fn, scope):
    if type(x) is Sym:
        if fn is not None:
            fn['refs'].add(x.name)
            if x.name not in scope:
                fn['free'].add(x.name)
        return
    if type(x) is Dotted:
        return
    if not isinstance(x, list) or not x:
        return
    pos = getattr(x, 'pos', None)
    h = x[0]
    if type(h) is Sym:
        n = h.name
        if n == 'quote':
            if len(x) > 1 and type(x[1]) is Sym:
                R.all_sets.add(x[1].name)
            return
        if n == 'function':
            if len(x) > 1 and isinstance(x[1], list):
                lint_walk(x[1], R, fn, scope)
            return
        if n in ('defun', 'defun-q'):
            lint_defun(x, R, fn, scope)
            return
        if n == 'lambda':
            if len(x) >= 2:
                try:
                    ps, ls = parse_params(x[1])
                except LispError:
                    ps, ls = [], []
                sc = set(scope) | set(s.name for s in ps + ls)
                for b in x[2:]:
                    lint_walk(b, R, fn, sc)
            return
        R.calls.append((n, len(x) - 1, pos, fn['name'] if fn else None))
        if n == 'setq':
            if (len(x) - 1) % 2:
                R.issues.append(('エラー', pos, 'setq の引数が奇数個です（値の無い変数があります）'))
            for i in range(1, len(x), 2):
                s = x[i]
                if type(s) is Sym:
                    R.all_sets.add(s.name)
                    if fn is not None:
                        fn['sets'].setdefault(s.name, pos)
                        fn['refs'].add(s.name)
                elif s is not None:
                    R.issues.append(('エラー', pos, 'setq の変数名の位置に %s があります' % short(s, 30)))
                if i + 1 < len(x):
                    lint_walk(x[i + 1], R, fn, scope)
            return
        if n in ('foreach', 'vlax-for'):
            if len(x) >= 3 and type(x[1]) is Sym:
                sc = set(scope) | {x[1].name}
                lint_walk(x[2], R, fn, scope)
                for b in x[3:]:
                    lint_walk(b, R, fn, sc)
                if fn is not None:
                    fn['refs'].add(x[1].name)
            return
        if n == 'cond':
            for cl in x[1:]:
                if isinstance(cl, list):
                    for e in cl:
                        lint_walk(e, R, fn, scope)
                elif cl is not None:
                    R.issues.append(('エラー', pos, 'cond の節がリストではありません: %s' % short(cl, 30)))
            return
        if n == 'if' and len(x) > 4:
            R.issues.append(('エラー', pos, 'if の引数が多すぎます（%d個）。複数の処理は progn でまとめてください' % (len(x) - 1)))
        if n == 'if' and len(x) < 3:
            R.issues.append(('エラー', pos, 'if の引数が足りません'))
        if n in ('trace', 'untrace'):
            return
        for a in x[1:]:
            lint_walk(a, R, fn, scope)
    else:
        for a in x:
            lint_walk(a, R, fn, scope)


def lint_defun(x, R, outer, scope):
    pos = getattr(x, 'pos', None)
    if len(x) < 3 or type(x[1]) is not Sym:
        R.issues.append(('エラー', pos, 'defun の形式が正しくありません'))
        return
    try:
        ps, ls = parse_params(x[2])
    except LispError as e:
        R.issues.append(('エラー', pos, 'defun %s の引数リストが不正: %s' % (x[1].name.upper(), e.msg)))
        return
    fn = {'name': x[1].name.upper(), 'params': [s.name for s in ps], 'locals': [s.name for s in ls], 'pos': pos,
          'sets': {}, 'refs': set(), 'free': set(), 'outer': outer, 'body': x[3:]}
    dup = [n for n in set(fn['params'] + fn['locals']) if (fn['params'] + fn['locals']).count(n) > 1]
    if dup:
        R.issues.append(('注意', pos, '%s: 引数/ローカル変数が重複: %s' % (fn['name'], ', '.join(d.upper() for d in dup))))
    R.defuns.append(fn)
    if outer is not None:
        outer['refs'].add(x[1].name)
        outer['sets'].setdefault(x[1].name, pos) if x[1].name not in scope else None
    sc = set(scope) | set(fn['params']) | set(fn['locals'])
    for b in x[3:]:
        lint_walk(b, R, fn, sc)
    if outer is not None:
        outer['refs'] |= fn['refs']
    if not fn['body']:
        R.issues.append(('注意', pos, '%s の本体が空です' % fn['name']))


def lint_text(text, fname):
    R = LintCtx()
    try:
        forms = read_all(text, fname)
    except ParseError as e:
        R.issues.append(('エラー', (e.fname, e.line), '構文エラー: ' + e.msg))
        # 括弧の対応ヒント
        try:
            toks = tokenize(text, fname)
            depth = 0
            for t in toks:
                if t[0] == '(':
                    if depth > 0 and t[3] == 0:
                        R.issues.append(('ヒント', (fname, t[2]),
                                         '行頭の ( の時点で括弧が %d 個閉じていません。この行より前で ) が不足している可能性' % depth))
                        break
                    depth += 1
                elif t[0] == ')':
                    depth -= 1
                    if depth < 0:
                        R.issues.append(('ヒント', (fname, t[2]), 'この行で ) が余っています'))
                        depth = 0
        except ParseError:
            pass
        return R, []
    for f, line in forms:
        if isinstance(f, list):
            lint_walk(f, R, None, set())
    user = {}
    for fn in R.defuns:
        if fn['outer'] is not None:
            continue
        if fn['name'] in user:
            R.issues.append(('注意', fn['pos'], '%s が複数回 defun されています（後の定義が有効）' % fn['name']))
        user[fn['name']] = fn
    # 呼び出しチェック
    unknown = {}
    for n, argc, pos, inside in R.calls:
        nu = n.upper()
        if nu in user:
            f = user[nu]
            if argc != len(f['params']):
                R.issues.append(('エラー', pos, '%s は引数 %d 個ですが %d 個で呼ばれています' % (nu, len(f['params']), argc)))
            continue
        if n in BUILTINS or n in SPECIALS:
            b = BUILTINS.get(n) or SPECIALS.get(n)
            if b.level != 'full':
                R.issues.append(('再現度', pos, '%s は lispcheck では%s（%s）' % (
                    nu, '近似' if b.level == 'approx' else '未実行/スタブ', getattr(b, 'note', '') or '結果はAutoCADと異なる場合あり')))
            continue
        if n.startswith('vla-') or n.startswith('vlax-'):
            continue
        if n in R.all_sets:
            continue
        unknown.setdefault(nu, pos)
    for nu, pos in unknown.items():
        extra = '（Express Tools の関数。AutoCAD に Express Tools が必要）' if nu.startswith('ACET-') else \
            '（別ファイルで定義されているなら --load で一緒に読み込んでください）'
        R.issues.append(('警告', pos, '未定義の関数 %s %s' % (nu, extra)))
    # command の対応状況
    for n, argc, pos, inside in R.calls:
        pass
    # 変数チェック
    fnames = set(k.lower() for k in user)
    CONST_LOWER = set(c.lower() for c in CONSTANTS)
    for fn in R.defuns:
        declared = set(fn['params']) | set(fn['locals'])
        o = fn['outer']
        while o is not None:
            declared |= set(o['params']) | set(o['locals'])
            o = o['outer']
        leaks = [s for s in fn['sets'] if s not in declared and not s.startswith('*')]
        if leaks:
            R.issues.append(('注意', fn['pos'], '%s: ローカル宣言されていない変数に setq しています（グローバル変数になります）: %s'
                             % (fn['name'], ', '.join(s.upper() for s in sorted(leaks)))))
        unused = [s for s in fn['locals'] if s not in fn['refs']]
        if unused:
            R.issues.append(('注意', fn['pos'], '%s: 使われていないローカル変数: %s' % (
                fn['name'], ', '.join(s.upper() for s in unused))))
        if '*error*' in fn['sets']:
            if '*error*' not in fn['locals'] and fn['name'].startswith('C:'):
                R.issues.append(('注意', fn['pos'], '%s: *error* をローカル宣言せずに再定義しています（グローバルの *error* を上書き）'
                                 % fn['name']))
        maybe = [s for s in fn['free'] if s not in declared and s not in R.all_sets and s not in KNOWN_VARS
                 and s not in fnames and s not in BUILTINS and s not in SPECIALS and s not in CONSTANTS
                 and s not in CONST_LOWER and not s.startswith(':')
                 and s != '/']
        if maybe:
            R.issues.append(('注意', fn['pos'], '%s: どこでも値を設定していない変数を参照しています（タイプミス？/別ファイルのグローバル？）: %s'
                             % (fn['name'], ', '.join(s.upper() for s in sorted(maybe)[:15]))))
    # command 名
    for n, argc, pos, inside in R.calls:
        pass
    cmds = [fn['name'] for fn in R.defuns if fn['name'].startswith('C:')]
    return R, cmds


def lint_commands_used(text, fname):
    res = []
    try:
        forms = read_all(text, fname)
    except ParseError:
        return res

    def walk(x):
        if isinstance(x, list) and x:
            if type(x[0]) is Sym and x[0].name in ('command', 'command-s', 'vl-cmdf') and len(x) > 1 \
                    and type(x[1]) is str:
                res.append((norm_cmd(x[1]), getattr(x, 'pos', None)))
            if type(x[0]) is Sym and x[0].name == 'quote':
                return
            for e in x:
                walk(e)
    for f, _ in forms:
        walk(f)
    return res


def run_lint(paths):
    out = []
    n_err = 0
    for p in paths:
        text = read_text_file(p)
        R, cmds = lint_text(text, os.path.basename(p))
        for name, pos in lint_commands_used(text, os.path.basename(p)):
            if name and name not in COMMANDS and name not in NOOP_CMDS and name not in DEFAULT_SYSVARS:
                R.issues.append(('再現度', pos, 'command "%s" は lispcheck では再現されません（実行時は読み飛ばし）' % name))
        out.append('=== %s ===' % p)
        if cmds:
            out.append('定義コマンド: ' + ', '.join(c[2:] for c in cmds))
        order = {'エラー': 0, '警告': 1, 'ヒント': 2, '注意': 3, '再現度': 4}
        seen = set()
        for lv, pos, msg in sorted(R.issues, key=lambda x: (order.get(x[0], 9), (x[1] or ('', 0))[1])):
            key = (lv, msg)
            if key in seen and lv == '再現度':
                continue
            seen.add(key)
            if lv == 'エラー':
                n_err += 1
            out.append('[%s] %s %s' % (lv, ('%s:%s' % pos) if pos else '', msg))
        if not R.issues:
            out.append('問題は見つかりませんでした')
    return '\n'.join(out), n_err


# =====================================================================
#  図面情報
# =====================================================================
def dxf_info(dwg, list_ents=False, handle=None, limit=200):
    out = []
    ap = out.append
    ap('図面: %s  バージョン %s  文字コード %s' % (dwg.path or '(新規)', dwg.version, dwg.enc))
    if handle:
        o = dwg.get(handle)
        if o is None:
            ap('ハンドル %s は存在しません' % handle)
        else:
            ap('entget 相当 (%s):' % handle)
            ap('(' + '\n '.join(lstr(x) for x in store_to_lisp(dwg, o, ['*'])) + ')')
        return '\n'.join(out)
    ents = main_ents(dwg)
    cnt = {}
    for o in ents:
        cnt[o.typ] = cnt.get(o.typ, 0) + 1
    ap('図形数 %d: %s' % (len(ents), ', '.join('%s×%d' % kv for kv in sorted(cnt.items()))))
    bb = drawing_extents(dwg)
    if bb:
        ap('範囲: (%s %s) - (%s %s)' % tuple(fmt_real(v) for v in bb))
    ap('画層:')
    lc = {}
    for o in ents:
        k = str(o.get(8, '0')).upper()
        lc[k] = lc.get(k, 0) + 1
    for r in dwg.records('LAYER'):
        f = r.get(70, 0)
        st = []
        if r.get(62, 7) < 0:
            st.append('非表示')
        if f & 1:
            st.append('フリーズ')
        if f & 4:
            st.append('ロック')
        ap('  %-20s 色%-4s 線種 %-12s 図形%-5d %s' % (r.get(2), abs(r.get(62, 7)), r.get(6, ''),
                                                   lc.get(str(r.get(2)).upper(), 0), ' '.join(st)))
    ap('文字スタイル: ' + ', '.join(str(r.get(2)) + ('(%s)' % r.get(3, '') if r.get(3) else '')
                               for r in dwg.records('STYLE') if r.get(2)))
    ap('線種: ' + ', '.join(str(r.get(2)) for r in dwg.records('LTYPE')))
    bl = [b for n, b in dwg.blocks().items() if not n.startswith('*')]
    if bl:
        ap('ブロック:')
        for b in bl:
            ads = [str(e.get(2)) for e in b['ents'] if e.typ == 'ATTDEF' and not e.deleted]
            ap('  %-20s 図形%d%s' % (b['name'], len([e for e in b['ents'] if not e.deleted]),
                                   ('  属性: ' + ','.join(ads)) if ads else ''))
    if list_ents:
        ap('図形一覧（ハンドル・内容）:')
        for o in ents[:limit]:
            ap('  ' + describe(dwg, o))
            if o.typ == 'INSERT':
                for a in attribs_of(dwg, o):
                    ap('      └ ATTRIB h=%s %s="%s"' % (a.h, a.get(2, ''), a.get(1, '')))
        if len(ents) > limit:
            ap('  ... 他 %d 件' % (len(ents) - limit))
    return '\n'.join(out)


# =====================================================================
#  使い方ガイド（AI向け）
# =====================================================================
GUIDE = r'''
lispcheck — AutoLISP 動作検証ツール（AI 向けガイド）
=====================================================
AutoCAD の無い環境で .lsp を実際に実行し、図面(DXF)がどう変わったか・何が表示されたか・
どこでエラーになったかを確認するための「簡易 AutoCAD シミュレータ」です。Python 3.8+ だけで動きます
（画像出力に matplotlib を使用。無ければ pip install matplotlib）。

■ 基本の流れ
  1) 静的チェック:   python lispcheck.py lint foo.lsp
       括弧の対応・if の引数過多・ローカル宣言漏れ・未定義関数・呼び出し引数の数などを検出。
  2) 図面の確認:     python lispcheck.py info test.dxf --entities
       画層・ブロック・図形のハンドル一覧。ハンドルは入力台本(entsel など)で使う。
  3) 実行:           python lispcheck.py run foo.lsp --dxf test.dxf --cmd FOO --in '[0,0]' --in '"abc"' --png
       - --cmd FOO   … コマンドラインで FOO と打つのと同じ（C:FOO を実行、エラー時は *error* が呼ばれる）
       - --eval "(式)" … 任意の式を実行（--cmd と混ぜて指定した順に実行）
       - --dxf 省略時は空の新規図面（mm単位テンプレート）で実行
       - 出力は ./lispcheck_out/（--out で変更）: report.txt, result.dxf, compare.png(実行前/後の比較画像)
       - 元の DXF は絶対に上書きしません
  4) 結果の読み方: レポートの「エラー」「警告」「図面の変更」「システム変数の変更」を確認。
       compare.png は Read ツールで画像として見られます（追加=緑, 変更=橙, 削除=赤点線の下敷き）。
       --labels を付けると図形にハンドルが表示されます。

■ ユーザー入力の台本（getpoint / entsel / ssget など）
  実行中の入力は、あらかじめ並べた値を先頭から順に消費します。足りないと ESC(キャンセル)扱いになります。
  --in は JSON で 1 個ずつ（複数可）。--input FILE で JSON 配列ファイルも可。--auto で不足分を自動入力。
    点           [10,20] / [10,20,0] / "10,20" / "@5,0"(直前基点からの相対) / "@10<45"
    数値         12.5 （getangle/getorient は「度」で入力 → ラジアンに変換されます）
    文字列/キーワード  "abc"  "Yes"
    Enter(空入力) null
    図形選択 entsel  {"handle":"2A"} / "h:2A" / {"pick":[x,y]}(最寄りの図形) / "last"
    ssget(対話)   "all" / ["2A","2B"](ハンドル列) / {"window":[[x1,y1],[x2,y2]]} / {"crossing":...}
                 / {"layer":"壁*"} / {"type":"LINE,ARC"} / null(選択なし)
    command の pause も同じ台本から取ります。
  LISP 側から台本を積むことも可能:  (lc:input '(0 0) "abc" nil)  … テスト用 .lsp で便利

■ テスト用の関数（lispcheck 独自）
  (lc:assert 式 ["説明"])                 式が nil なら失敗
  (lc:assert-equal 実際 期待 [許容誤差|"説明"])  equal で比較（数値は既定 1e-8 の誤差許容）
  (lc:expect-error 式 ["メッセージの一部"])  式がエラーになることを確認
  (lc:input 値 ...)                         入力台本の末尾に追加
  (lc:count [フィルタ])                     ssget "X" 相当の件数（フィルタ省略で全図形数）
  (lc:dump 図形名)                          entget をきれいに表示
  (lc:reset-inputs)                         台本を空にする
  テストファイル例:
     (load "foo.lsp")
     (lc:input '(0 0) '(100 0) "")
     (c:mycmd)
     (lc:assert-equal (lc:count '((0 . "LINE"))) 1 "線が1本できる")
  → python lispcheck.py run test_foo.lsp --dxf base.dxf  （アサーション失敗時は終了コード 2）

■ 再現範囲（重要）
  ◎ ほぼ AutoCAD 通り: 算術/リスト/文字列/wcmatch/rtos/動的スコープ/defun/lambda/mapcar/vl-sort 等、
    *error* の呼び出し（ローカル変数が生きた状態で呼ばれる）、vl-catch-all-apply、
    entget/entmod/entmake(x)/entdel/entnext/entlast/handent、拡張データ(-3)、regapp、
    ssget "X"＋フィルタ(-4 演算子含む)、ssadd/ssdel/ssname 等、tblsearch/tblnext/tblobjname、
    getvar/setvar（元に戻したかレポートで確認できる）、ファイル読込、load
  ○ 近似: vla-*/vlax-*（主要プロパティとメソッド: Layer/Color/StartPoint/Coordinates/TextString/
    InsertionPoint/AddLine/AddCircle/AddText/InsertBlock/GetAttributes/IntersectWith/GetBoundingBox/
    Move/Rotate/Copy/Offset など）、vlax-curve-*（線/円/円弧/LWポリライン(バルジ対応)は正確、
    楕円/スプラインは折れ線近似）、command（LINE PLINE CIRCLE ARC POINT TEXT ERASE MOVE COPY ROTATE SCALE
    MIRROR CHPROP CHANGE LAYER INSERT BLOCK と システム変数名。その他は読み飛ばして警告）、
    ssget の窓/交差選択（外形枠で判定）、文字の大きさ（画像・外形枠は概算）
  × 未対応: DCL ダイアログ(load_dialog 等はエラー)、リアクター、画面操作(grdraw等)、UCS/OCS変換、
    ダイナミックブロック、寸法・ハッチングの作成、Express Tools(acet-*)、外部COM(Excel連携)、
    コンパイル済み .fas/.vlx
  書込みファイル(open "w")は出力フォルダ内の lisp_files/ に作られます（実ファイルは変更しない）。

■ よく使うオプション
  --trace FUNC / --trace-all   関数の呼び出しと戻り値を表示
  --json                       report.json も出力（機械処理用）
  --labels                     画像にハンドル番号
  --view x1,y1,x2,y2           画像の表示範囲
  --timeout 秒 / --max-steps N  無限ループ対策（既定 120 秒 / 3000万ステップ）
  --load other.lsp             依存ファイルを先に読む（run の位置引数に並べても同じ）
  --save-dxf                   変更が無くても result.dxf を出力
  --pick-tol 距離              {"pick":[x,y]} で図形を探す許容距離

■ その他のサブコマンド
  lint FILE...                 静的チェック（終了コード: エラー有=1）
  info DXF [--entities] [--handle H]   図面の概要 / 図形一覧 / entget 相当の中身
  render DXF OUT.png [--labels]        図面を画像化
  blank OUT.dxf                空の図面(AutoCAD 2010形式)を作る → テスト図面作りの土台に
  funcs [--level approx|stub]  対応している関数の一覧
  repl [--dxf F] [--load X]    対話モード（:save パス / :png パス / :diff / :quit）

■ 終了コード: 0=正常, 1=LISP エラーあり, 2=アサーション失敗, 3=ツール自体の問題（ファイル無し等）

■ AI へのヒント
  - まず lint、次に run。エラーは「場所」と「呼び出し履歴」を見て原因の行を特定する。
  - 警告の「再現していません」「近似」は AutoCAD 実機での再確認ポイントとして人間に伝える。
  - テスト用の DXF は、LISP の entmake で作って --save-dxf するか、`blank` で作った図面を土台に
    ezdxf 等で作ってもよい。
  - 実行結果の図面は result.dxf。続けて別の LISP を試すときは --dxf lispcheck_out/result.dxf。
'''


# =====================================================================
#  テスト補助の組み込み
# =====================================================================
@bi('lc:input')
def _lc_input(I, a):
    I.inputs.extend(a)
    return T


@bi('lc:reset-inputs')
def _lc_reset_inputs(I, a):
    I.inputs = []
    return T


@bi('lc:count')
def _lc_count(I, a):
    ents = main_ents(I.dwg)
    if a and a[0] is not None:
        ents = filter_ents(I, ents, a[0])
    return len(ents)


@bi('lc:dump')
def _lc_dump(I, a):
    argn(a, 1, 1)
    e = ename_of(I, a[0])
    o = I.dwg.get(e.h)
    if o is None:
        I.echo('（図形なし）\n')
        return None
    I.echo('(' + '\n '.join(lstr(x) for x in store_to_lisp(I.dwg, o, ['*'])) + ')\n')
    return T


@bi('lc:log')
def _lc_log(I, a):
    I.echo('[log] ' + ' '.join(lstr(x, False) for x in a) + '\n')
    return a[-1] if a else None


@bi('load_dialog new_dialog start_dialog done_dialog action_tile set_tile get_tile get_attr mode_tile '
    'start_list add_list end_list unload_dialog start_image fill_image vector_image slide_image end_image '
    'client_data_tile dimx_tile dimy_tile term_dialog', 'stub', 'DCL ダイアログは未対応')
def _dcl(I, a):
    I.warn('DCL ダイアログ関数は再現できません（ダイアログ部分は AutoCAD で確認してください）')
    raise LispError('DCL ダイアログは lispcheck では未対応です')


@bi('vlr-object-reactor vlr-editor-reactor vlr-command-reactor vlr-dwg-reactor vlr-acdb-reactor '
    'vlr-lisp-reactor vlr-sysvar-reactor vlr-remove vlr-remove-all vlr-reactors vlr-add vlr-data-set '
    'vlr-pers vlr-owner-add vlr-owners vlr-set-notification vlr-docmanager-reactor vlr-mouse-reactor '
    'vlr-miscellaneous-reactor vlr-toolbar-reactor vlr-xref-reactor vlr-linker-reactor vlr-insert-reactor '
    'vlr-undo-reactor vlr-wblock-reactor vlr-window-reactor vlr-deepclone-reactor', 'stub', 'リアクターは未実行')
def _vlr(I, a):
    I.warn('リアクター(vlr-*)は登録のみ記録し、イベントは発生しません')
    return VlaObj('reactor', id(a))


# =====================================================================
#  コマンドライン
# =====================================================================
class _StepAction(argparse.Action):
    def __call__(self, parser, ns, values, option_string=None):
        lst = getattr(ns, 'steps', None) or []
        lst.append(('cmd' if option_string == '--cmd' else 'eval', values))
        ns.steps = lst


def parse_input_value(s):
    try:
        v = json.loads(s)
    except (ValueError, TypeError):
        return s
    return json_to_input(v)


def json_to_input(v):
    if isinstance(v, list):
        if v and all(isinstance(x, (int, float)) and not isinstance(x, bool) for x in v):
            return [float(x) for x in v]
        return [json_to_input(x) for x in v]
    if isinstance(v, bool):
        return T if v else None
    return v


def make_interp(args, dwg):
    inputs = []
    if getattr(args, 'input', None):
        with open(args.input, encoding='utf-8') as f:
            data = json.load(f)
        inputs += [json_to_input(x) for x in (data if isinstance(data, list) else [data])]
    for s in getattr(args, 'inp', None) or []:
        inputs.append(parse_input_value(s))
    opts = {'inputs': inputs, 'auto': getattr(args, 'auto', False), 'outdir': args.out,
            'trace': getattr(args, 'trace', None) or [], 'trace_all': getattr(args, 'trace_all', False),
            'max_steps': getattr(args, 'max_steps', 30000000), 'timeout': getattr(args, 'timeout', 120),
            'search': [os.path.dirname(os.path.abspath(p)) for p in (getattr(args, 'files', None) or [])],
            'pick_tol': getattr(args, 'pick_tol', 0) or 0}
    return Interp(dwg, opts)


def open_drawing(path, enc=None):
    if path:
        return Drawing.load(path, enc)
    return Drawing.blank()


def cmd_run(args):
    os.makedirs(args.out, exist_ok=True)
    dwg = open_drawing(args.dxf, args.encoding)
    I = make_interp(args, dwg)
    for w in dwg.warnings:
        I.warn(w)
    snap0 = dwg.snapshot()
    I.snap0 = snap0
    ctx = {'dxf': args.dxf, 'loads': [], 'steps': [], 'snap0': snap0, 'files': [],
           'diff_limit': args.diff_limit}
    files = list(args.load or []) + list(args.files or [])
    for f in files:
        if not os.path.exists(f):
            print('ファイルが見つかりません: %s' % f, file=sys.stderr)
            return 3
        ok, _ = I.toplevel(lambda f=f: I.load_file(f), '読込 ' + os.path.basename(f))
        ctx['loads'].append((f, ok))
    for kind, val in (args.steps or []):
        if kind == 'cmd':
            ok, res = I.run_command(val)
        else:
            ok, res = I.run_eval(val)
            if ok:
                I.echo('\n=> %s\n' % short(res, 300))
        ctx['steps'].append((kind, val, ok, res))
    ctx['cmds_defined'] = sorted(n[2:].upper() for n in I.defined if n.startswith('c:'))
    changed = I.dwg_changed()
    if changed or args.save_dxf:
        p = os.path.join(args.out, 'result.dxf')
        dwg.write(p)
        ctx['files'].append(p + ('（実行後の図面）' if changed else '（変更なし）'))
    if args.png:
        before = open_drawing(args.dxf, args.encoding)
        added, modified, deleted = compute_diff(snap0, dwg)
        hl = {}
        for o in added:
            hl[o.h] = 'add'
        for o, _ in modified:
            hl[o.h] = 'mod'
        for o in deleted:
            hl[o.h] = 'del'
        p = os.path.join(args.out, 'compare.png')
        view = [float(v) for v in args.view.split(',')] if args.view else None
        err = save_png(p, [(before, '実行前', None, False), (dwg, '実行後（緑=追加 橙=変更 赤=削除）', hl, True)],
                       args.labels, view)
        if err:
            I.warn(err)
        else:
            ctx['files'].append(p + '（実行前/後の比較画像）')
    for f in I.written_files:
        ctx['files'].append(f + '（LISPが書き込んだファイル）')
    rep = build_report(I, ctx)
    rp = os.path.join(args.out, 'report.txt')
    ctx['files'].append(rp)
    rep = build_report(I, ctx)
    with open(rp, 'w', encoding='utf-8') as f:
        f.write(rep)
    if args.json:
        jp = os.path.join(args.out, 'report.json')
        with open(jp, 'w', encoding='utf-8') as f:
            json.dump(report_json(I, ctx), f, ensure_ascii=False, indent=1, default=str)
    if not args.quiet:
        print(rep)
    if I.errors:
        return 1
    if any(not a['ok'] for a in I.asserts):
        return 2
    return 0


def cmd_lint(args):
    text, n = run_lint(args.files)
    print(text)
    return 1 if n else 0


def cmd_info(args):
    dwg = Drawing.load(args.dxf, args.encoding)
    for w in dwg.warnings:
        print('△ ' + w)
    print(dxf_info(dwg, args.entities, args.handle, args.limit))
    return 0


def cmd_render(args):
    dwg = Drawing.load(args.dxf)
    view = [float(v) for v in args.view.split(',')] if args.view else None
    err = save_png(args.png, [(dwg, os.path.basename(args.dxf), None, False)], args.labels, view)
    if err:
        print(err, file=sys.stderr)
        return 3
    print('保存しました: %s' % args.png)
    return 0


def cmd_blank(args):
    if os.path.exists(args.dxf) and not args.force:
        print('既に存在します（上書きしません）: %s   上書きするなら --force' % args.dxf, file=sys.stderr)
        return 3
    with open(args.dxf, 'wb') as f:
        f.write(zlib.decompress(base64.b64decode(BLANK_DXF)))
    print('空の図面を作成しました: %s' % args.dxf)
    return 0


def cmd_funcs(args):
    rows = []
    for n, b in sorted(list(BUILTINS.items()) + list(SPECIALS.items())):
        if args.level and b.level != args.level:
            continue
        rows.append('%-34s %-6s %s' % (n, b.level, getattr(b, 'note', '') or ''))
    print('\n'.join(rows))
    print('\n合計 %d 個（full=通常どおり, approx=近似, stub=実行しない）。vla-get-*/vla-put-*/vla-* は動的に解決。' % len(rows))
    return 0


def cmd_repl(args):
    dwg = open_drawing(args.dxf)
    os.makedirs(args.out, exist_ok=True)
    I = make_interp(args, dwg)
    I.live = True
    snap0 = dwg.snapshot()
    I.snap0 = snap0
    for f in args.load or []:
        I.toplevel(lambda f=f: I.load_file(f), '読込 ' + f)
    print('lispcheck REPL  (:quit で終了, :save パス, :png パス, :diff, :in JSON)')
    buf = ''
    while True:
        try:
            line = input('... ' if buf else '_$ ')
        except EOFError:
            break
        if not buf and line.startswith(':'):
            cmd, _, rest = line.partition(' ')
            if cmd == ':quit':
                break
            if cmd == ':save':
                dwg.write(rest.strip() or os.path.join(args.out, 'result.dxf'))
                print('保存しました')
            elif cmd == ':png':
                print(save_png(rest.strip() or os.path.join(args.out, 'repl.png'), [(dwg, '', None, False)]) or '保存しました')
            elif cmd == ':diff':
                a, m, d = compute_diff(snap0, dwg)
                for o in a:
                    print('[追加]', describe(dwg, o))
                for o, old in m:
                    print('[変更]', describe(dwg, o), '; '.join(pair_diff(old, o.p)[:6]))
                for o in d:
                    print('[削除]', describe(dwg, o))
            elif cmd == ':in':
                I.inputs.append(parse_input_value(rest))
            continue
        buf += line + '\n'
        try:
            read_all(buf, '<repl>')
        except ParseError as e:
            if '閉じられていません' in e.msg:
                continue
            print('; 構文エラー:', e)
            buf = ''
            continue
        text = buf
        buf = ''
        if text.strip().upper().startswith(('C:',)) or re.fullmatch(r'\s*[A-Za-z_][\w\-]*\s*', text) and \
                I.g.get(S('c:' + text.strip())) is not None:
            I.run_command(text.strip())
            continue
        ok, r = I.run_eval(text)
        if ok:
            print('\n' + lstr(r))
        for w, n in list(I.warns.items()):
            print('  △', w)
        I.warns.clear()
    return 0


def main(argv=None):
    ap = argparse.ArgumentParser(prog='lispcheck', description='AutoLISP 動作検証ツール（詳しくは guide サブコマンド）')
    sub = ap.add_subparsers(dest='sub')

    r = sub.add_parser('run', help='LISP を実行して結果をレポート')
    r.add_argument('files', nargs='*', help='読み込む .lsp（順番に load）')
    r.add_argument('--dxf', help='対象図面 (ASCII DXF)。省略時は空図面')
    r.add_argument('--load', action='append', help='先に読み込む .lsp')
    r.add_argument('--cmd', action=_StepAction, dest='steps', help='実行するコマンド名（C: は不要）')
    r.add_argument('--eval', action=_StepAction, dest='steps', help='実行する LISP 式')
    r.add_argument('--in', dest='inp', action='append', help='入力台本の値(JSON)。複数回指定可')
    r.add_argument('--input', help='入力台本の JSON 配列ファイル')
    r.add_argument('--auto', action='store_true', help='入力が足りない時に自動入力する')
    r.add_argument('--out', default='lispcheck_out', help='出力フォルダ (既定 lispcheck_out)')
    r.add_argument('--png', action='store_true', help='実行前後の比較画像 compare.png を出力')
    r.add_argument('--labels', action='store_true', help='画像にハンドルを表示')
    r.add_argument('--view', help='画像の範囲 x1,y1,x2,y2')
    r.add_argument('--save-dxf', action='store_true', help='変更が無くても result.dxf を出力')
    r.add_argument('--trace', action='append', help='呼び出しを表示する関数名')
    r.add_argument('--trace-all', action='store_true', help='全ユーザー関数の呼び出しを表示')
    r.add_argument('--json', action='store_true', help='report.json も出力')
    r.add_argument('--quiet', action='store_true', help='画面にレポートを出さない')
    r.add_argument('--max-steps', type=int, default=30000000)
    r.add_argument('--timeout', type=float, default=120)
    r.add_argument('--diff-limit', type=int, default=60)
    r.add_argument('--pick-tol', type=float, default=0)
    r.add_argument('--encoding', help='DXF の文字コードを強制 (例: cp932, utf-8)')

    l = sub.add_parser('lint', help='静的チェック')
    l.add_argument('files', nargs='+')

    i = sub.add_parser('info', help='図面の概要')
    i.add_argument('dxf')
    i.add_argument('--entities', action='store_true', help='図形一覧も表示')
    i.add_argument('--handle', help='このハンドルの entget 相当を表示')
    i.add_argument('--limit', type=int, default=300)
    i.add_argument('--encoding')

    rd = sub.add_parser('render', help='図面を PNG にする')
    rd.add_argument('dxf')
    rd.add_argument('png')
    rd.add_argument('--labels', action='store_true')
    rd.add_argument('--view')

    b = sub.add_parser('blank', help='空の DXF を作る')
    b.add_argument('dxf')
    b.add_argument('--force', action='store_true')

    fu = sub.add_parser('funcs', help='対応関数の一覧')
    fu.add_argument('--level', choices=['full', 'approx', 'stub'])

    rp = sub.add_parser('repl', help='対話モード')
    rp.add_argument('--dxf')
    rp.add_argument('--load', action='append')
    rp.add_argument('--in', dest='inp', action='append')
    rp.add_argument('--out', default='lispcheck_out')

    sub.add_parser('guide', help='AI向けの使い方ガイドを表示')

    args = ap.parse_args(argv)
    if hasattr(sys.stdout, 'reconfigure'):
        try:
            enc = (sys.stdout.encoding or '').lower().replace('-', '')
            if enc not in ('utf8', 'cp932', 'shiftjis', 'mbcs'):
                sys.stdout.reconfigure(encoding='utf-8')
            sys.stdout.reconfigure(errors='replace')
        except Exception:
            pass
    if args.sub is None or args.sub == 'guide':
        print(GUIDE)
        return 0
    try:
        return {'run': cmd_run, 'lint': cmd_lint, 'info': cmd_info, 'render': cmd_render, 'blank': cmd_blank,
                'funcs': cmd_funcs, 'repl': cmd_repl}[args.sub](args)
    except (OSError, ValueError) as e:
        print('エラー: %s' % e, file=sys.stderr)
        return 3
    except Exception:
        import traceback
        traceback.print_exc()
        print('lispcheck 内部エラーです（ツール側の不具合）。上の内容を開発者に伝えてください。', file=sys.stderr)
        return 3


def _run_main():
    sys.setrecursionlimit(200000)
    for mb in (512, 256, 64):
        try:
            threading.stack_size(mb * 1024 * 1024)
            break
        except (ValueError, RuntimeError):
            continue
    res = [3]

    def target():
        res[0] = main()
    th = threading.Thread(target=target)
    th.start()
    th.join()
    sys.exit(res[0])


# 空の図面テンプレート（AutoCAD 2010 形式 / mm単位）zlib+base64
BLANK_DXF = (
    'eNrtXVmXm8iSftev0MM8zJ17SodM9n66CNBiI8EAtfmljlyFbU3Lko9K7ts19/R/n8zITEgWSUjgnpk+9qIlyCWWj8jIAAXDoTJI'
    'fDedh8vBcIgHM9/x/Jh8tAf/5riOdwdf0MBxkYK1gr5w5ssUDprKwGB0737qhp4fOVOfENSBs0zmTwjrmB0OnCRNnDvfGz/CkNl/'
    'v/z+iR2aL5Oxk5BeSBkoI2UwxPxd5e+0kf+QLuZLaIOyv2PWin9S80+ipfMALW+KpjdF2xupcTBfiGFLU4tjfCANi6PYNsXxME5n'
    '4YLIDGrgxNif+suciBhxMg+CKu0/U8popfdiHseULjcM0sR1AtJMIyQxt5Om1QFpv2T+gTXEI51TY8f17+deuTu0TR/pqENzEH7L'
    'tslq+8qOuYHzCHa3BFeuH6SPEW1rDMZvweot24sDbhiEpK2BB1g3itYNHHvzJErmwUwW15svGlsunOQD0JQRMvWc6j+EgooLqhfM'
    'gaqOpKbx0uNNFamhX6P5D4KmSr3TqNYwXdRJ1E5Ak7hx/WXZALRhLo3UOQwqmiBwq1DSeVVbaVjTn49qFFzt5XgyUAjlA8U8oVg5'
    'ZRy8Z6d67M7SufteMkVY6ZzMqpQoTFLoXfRqIAVphS9CYYypMmkidKXaqqkopmVqhY4mjsvAopSVOQkqLKV3DTacP1R1FT54VZJT'
    'VTFRDSqLQii4TBEnEx74H7yHSQGHIK5OQEh+nVTVTSokVSQgTR0hVCHou9uk2jfxapjwapgIg3dVUh0VxBwf6kar0W6jtKJ+z3eB'
    'govR6yQy1G2dVMNE+kC0W3JU7m77km1fs5ebYP35y6Hofbuc10DWOG+Tf3CE/MXUXuJHQNKMolk64ZMU7Sax41ZPZy8W51RBy/kr'
    'mAnumbw3Msmvkoi3v/MrPScPQc1xElq4rHDyLpw6yykX17R01baQoaq2KYGNLFA1ABIaAWZVnbGbPFYdVbE8SCT/AdVJuEwiLtSb'
    'xyICKcYERSWyvMFtFHNDcneQvPdTdzZfumUlULZ9surxFS83sFMMmVPyIfkkC395CxYb8VAi8O8cxpuMlegIPZ0Rx7n0k6RMJo7d'
    'nfnUpRZzuzNnMfFjp9ySU8eNVLeRWoFx8j4Kg0d5ptRzY99JeVigGUhFaIQVU0dIF5419W5LjXQCEjxCBCm2YdlW3ijyzg9UaiQG'
    '0jTSWDSZL0msWNGcd5vEKVmO4zK9oBbehWCZhYu61JAQCZBkuSOvGlxFXh4eFaYM5ss8PCq0GAXkjF6UeifQlAG9iHoZNfGniew5'
    'Z86SeA6fjDrUB5bHm97Gk9QZo1J3RsM1WnUaQrutEu5kwq3Lg2iyBOWUJcggU8J4ejrOJm0eQJOIn1NHGj2KRmIk1NAIIuTYn1R5'
    'INS7uX8vq5fxlobRWfZIs3GYpuGiTcvAn6Rt2sXz6axVw0kcLls1HDv0jD/VLqrbLKobLWpjtaiV2aJWdouaDRcds1zU0nRRe9tF'
    'bY0XtbZe1Np8UVv73SZ+PC9FWkDBNYpao2g1il6lxKjqCgkNN9DUBprWQNPLtPswDrzclty3JjMSLnlTXw5vGG0+AZopHPY88Ksb'
    'ULJZdlyIu6lb4itC1Gp3HzWtkVH7PX900aY/OrXrj85t+2kcUV1a7uZJ7KcOjx+RtLZM/VJgEyX55ljaucdkrfCjlG08VEXw6S6C'
    'Yl+RHFbbl9X+JT9UDfxp63wzjQt54vDhcRo7EQlOkpK5fIesIj6JeUrBO9m+3/twPqk0BOVUf+m5TpQMsJXP9y4kpgX2JCKJZsk+'
    'P3AeicZyImlXBF8cFzOywsVEQe+5BxRRMoyYzHxf3j0+EPylMGLOZJQsYZFULUm3tC+YRmo6mS+nfhzF82U6vaULPdHlv3zX9lTF'
    '127G5DS/0czx5MbSVOtmbI8NHxu6bmj4D25aP05IpFf0NTRF0VUX3xgK9m80PFFvxo41vnFdU51MDFclodEfeSqKevNE5idK7qLC'
    'TrmZQiJ16sTpbSRrjnpcYh+md4RNoU/Pf3DTQFb8bO75kDmCllxtbjCPWCAjUWdOENKNpNQ5HCc8kUNjYd3MqSywl1oSLRJ9sIA9'
    't3Tz4YYRIZ2QhC50wTk+35EOfNUTFnfJVxLD17EU+MuE/J/Sk4XoTy/iYegxY9AtR3MpQUsEfPGwtHRExIRSSkH1vPsJ2xxAKicH'
    'WBiQWJFPTVorenGgPDMPBIOQhHfLKeJbFN1UTNtQsWHaeqkBPtlg4UwriwGn4jo1coi9masuiMswJpveREZBQPYv6a3HRFfNkTTh'
    'clocuUEYj1Sbn7RLGgBIG7ZSCE/i9A/hku9cLUXJdz9ELdPgMZrJeEHlZQQaJY9LdyYfdclemyyNTjBQNXOA83MimHuzeZLKwEtm'
    '4X1OE2mI+0kBfrFtni5rNLLzCWA1ZKeldK4CnMkmqzHNSdfF8L7MBKUQGZd+ELrVDaIy8OmuwIWPctbdDchJQZwEpcNnnnP3xt4c'
    'Wjnx4703oekz0tp59j566+fDerdd7d/u14cvXvZp9X1zgKx7+PG/sueDN34YupvV62v2Ohiyc8dG5JXxii00UCqzEQedj55838JY'
    'iesv/dCHEcgeTz07CFkFbx1pyaKD3a1fv682yeFtk51gUFMo/M4Mn6NBjL1YHbL9erU5MXArvrk7FuI/r07y2mpIsqmjDl3WRLr6'
    'uMn6UUQA12nKwy+CbPWS7YsJKICe5KZPfIS20xTou3PiBuzdrfadMEciDQaWBU1r8uHdbMPQslh9O20EfF5PZOl0gth5jMmZR/1/'
    'mpJgIClUlm0Pq028eouzLVVddjist59f6+CHi19nJoPzlcaAAQ2qy7bxssNqvblbZ/88Z38yld5qKu5A6nMlGdint8lih6ySMUHA'
    'HCCdzxOvXsnZRzCwprhmSpsni5a2pyIQR+n6szBglxzZqNFm9ZzNdpuXrBu2yDoT3hYOM1i97b5f4yGPuOxU6EJhH4F4F4U0jU9T'
    'PgOV7m5oSMFs8vb1424DDiAPtRWpPVahg9XUIc6edyTqF0eoXb/t9gf5GJ38Pxxi9t8ysSGo7mwQ4mkB/o4wP87fkcq/83eksQsP'
    'mL8jnX/n78jg7fm7avBxTU7n7yp/Z/EV+0hZUOkOFfPwTeOTahp7F4k9HbF3E6xhYhiCfFCpAk2NblBNHQ4Z8GrCq1UY0KBHkWbI'
    'KzCxV8VuIntN7HDGbpgZTuqgQQ/cwnDBepsd3r5lVcON38ab3fOv+U5OHYCohg6CKqUAQppY72FifiX3somNzhO7uy3xs993318v'
    'nXvSfW6fhnTSvC5ZA7L98In8GT6dfZO5ZDkWHWJ9zR6o7FI1gaUC32+UkaHKhOr3coOSoETIfgR9wHVR/x3//jcQBuQasv9N3+rC'
    'WiPLBt6NkXpSVjSie9VWoqKeRG2SdKRzUS+zKR7pGhdDtypyqMgq2bT8vdygLCjuLKjnJDPfk+T0Vq9fshdqtFb/ZEnzHSfWjlgM'
    'UyU0CaL2JEgJnFyUHJzDk691SdSRorETkVlPlkRXjphE60mSJkEY9o7/rYugjEwDH3MVqDBPWYbuC0E0c5aQks9liL6stofd12HZ'
    'KwyPfJclMUAS5h66O8ULvabRlypKyBTKoNB8kv4MhwKR5fcm92mIi9GQZunqQC9zsGZfWmlUinCxQ+5Oj73XtcGx0d3NXuiHrV5O'
    'ei9MKyf98GV3oGfF6OxLfcVRRzrNK53zXiCp0tK52X3JWfPTIKnkqUfDIx/qghojxWaCssCpD0GdvgRtlpM78tHx/3Ux0cg0rfPr'
    'apOYR5fdcXcxy5glwo2Gl/xrWrJ0Hv62N5fbhxxlTAo4jqgPPvfSFAUpyGiSgh9oksLrQ4qaECOdCtHmb5MtMA9b22PK7y7F/G4u'
    'XQslcqx/W79kzNWNzrzVFwVtpBhaZ0d4ER4nPemgDEmmhZKTlLxj/WNTEGUoWmdXeYkqNKUnVdQ1caEXNcSFNxV39qLnT4jmrBC/'
    'C14foHNZIabGvD1mERdqo0aaganqUBHaI7sBE+6XlDImcFGe7MBo+lZl18VQdX6r2/xe9unbbr09vJ7ig12SPcpNo0pFolof6OdU'
    'arCUa94Bs2hGbyFTmv1+gMx3Va7iDgomlsgxaTwnKtKOLN2oYX4Pvzo4/E5Tx9qgwpOGuvMk7mgWNzJfyFm5++hw+NTIKO6b0Zv5'
    'YbVZP3fklw1ylGu1P66vZzTOPn/frPZHmdR6VG1XpZ7Rp94jq0n2dT3ebV6uZ1aMcJRd4wew21XD5XGOsm72yHo3LZ/UsNUzm121'
    '20Kzdo8s+78f9qtu6s2HOMqw8yMY7qroykBHmR/3x3zxk51OGi8Pc5Rx90cw3m2JroxzlHXvR7DeETAV3s+gxu8uQbD+mO1X9D6G'
    'q1bvcveza/ikb4avw3jDGMdY1pUfwvKVMDk60lH2Ue/s98P6GbZxr2xn+/WnLgzT/uewrau9s9wZ3PkgR5nWfgzT3TFSGeqoAHr/'
    'AvTE/BnGjT4ZX+y2uw4M0+5n8W32zXBXeOdjHGXZ+iEsd8ZHZaSj7Nu9s98P601sN6ah2I+eiCjmmSzUiezgLf0tDRnCuH4IJ4rm'
    '7Bei6plBVOhZtMdsU6G2MAE5fZxv36r6pzVcJPaKka2uI8+c1J3Rn85N4/B26RW/AanNNO44E6+zcFrHUmUGEueduyuzSHx7668F'
    'cGHMfCSkEAMw5rUWzJdGOp2MRBz1gG+N3php0PtzaR4MSptoGs2D0w86P0P4jY2auMnS4u9w9WSAeBkSxMdEGrvZE7H7LaXyGgiG'
    'pkd03sLg303OBRJjG3aRn87vy1TEbXsspV65KRPBTZn0koNN7Q19EelLP2Oapoa+CPoi6IugL4IbOhHc0IlIX3Lmk170FcOrCq/0'
    'NlAMvTD0wqQXpVs0N4dNu3JTL7YwvKrwqhG2sAWdLehssbtHKaMiw41oHQaVzHmD60gw1c5IKAFZggGvfQNGQ1Ug8Ho1FyABqtS0'
    'hIKiVMCgQB8TCo90hwLCfz4WDMACvhALqIwFeoHSJW94QKc6gwy3B2Q8LZ5Io6cZ1p/cRSNG8I+FCALKT5BcDpIz6PD6QYd+Ehwo'
    'R4di1OGBrIvxgeo+xLgKIYr+EyLnIOL3AxECjxMQ4cAAU6oNPkSxL/ciHBMlmKjXeRIF/wTKWaBMegLKSV+i5DBpAImpK/IfdClg'
    'anC5EixK+Y/2EztnsGMpfUUpJ7FT+JgmF6NW4GNcCp+6u7nS26AKgPBPAJ0DEOopkDmJHymQaYpkFBrKyHZTL0VQQ2BzbWSjlMGs'
    '/AyGz2II9+SETmJIckKNXki5ItBp8DzXup6fODmPkz6SLU+0rMxt8udtppmt/0/mW5QfjQrUV77FOptvsaz+wPE0XybSXe1/bYwo'
    '7TGCfgRGlKswolyFEbsPjLi38V3xM9w/Mxv3v+xAMJTKwH+ZxaXxktE4CN33T7TkU8yuVNlnLhvpMECtG2JXF+0WWIMCELWCHovd'
    'S7Z5Sr6tnjMQATncdqzEVVGjpD71uOPU0epbtpen9ttObWrdpn7K68/TeZXW01odp3WDMPE9qB3tXTa1pfUy9ThwlqeFltB6pCoN'
    '8JYUbDIw8F+DmDkb/vawPrzxBzyUeBtnn9fbOvqO1JTJC3iqleasih+wyUqgEy7s9lz425eqDOxaCsH1RTLIMG4hQ6l5kwxeey7q'
    'MpjsniBTu0iG4nw4L4DUVnAf3NNy4LQOKePBPMkDPN/jkbNsYImraLd526y3GV8AxNJH1yKks6qrrDyQ+ID4gwuweIBBSZOm0V4X'
    'DZpkWDKtyzRZOsVbaLPcXmgUqg8yNsYn2TiuzHQPCINStfnkyNBU27ItsjxpZFepmgUziJdBwvxd5e9kVeYDYKgQ0TBCUd2Jt1SP'
    'tVTlGkm5nZz2mq7byWKIt7Rr7MT8YWsz8eZHcG+ZJzlpiXtV1O46a7la9S2pQ7P+y3q3jPaaE3o/sib4y3SeznmtsiNtwjGtwJrw'
    'eFkU/QNOnErwU1T/g5UJ8UqDjvfEbvVRdYKAgkjvAoqA6BZEXpuNUr2CWtT6JHRfosvFDumxiXyMFt/PjyClOBQFYZoX/IODqHKQ'
    'doOqs3AUF0ehHGRAi4nCEa04IlV1hEN6cUiufQnHDDgGN3c8LfzUASr2mpTMHIlzSsm1Pu4VfbzzfdQBrORMBIfdZge18xAj+U3j'
    '+m3GFXXOYJgJJ7EKZKAZZrvpZvdxxabHjTJM2syV31wF47hN4yDl8oFw40CojSWaq7nqFHct2Fju9l+5VpDa0FSuAgvxuppPWi6y'
    'qMPPdFWO97os2hWoQvo1nYw2cuOX+/U++7Rffc1AeJ0hcrx6XT8zAvM14z39WUq2ZTTmatzdZrd3v6y2n3lfj5O3z9m3w3euTt3n'
    'P1L/yr4yYPovnzPoH376BHSDoXNCFu5vq8Mh27OpDMbmZLM6sO84/05NQod5ZQdUhu7d9/3qO0OTocmkSnPmWGbrlxculMHcybs1'
    'nTznyuT3wW7LXFnFibzefmY0m/2g57dsT1WSj8AUGmerzfr1wJVqMKUmX1YvGefVlSjDfxJeh1nBrFccfB3uPg2n+9UbO8KUm/ya'
    'HZ6/cBJTcPpl/fwrF81kui1b2mSafbiJ+Vhm/it7VtdTp+6JQsgrFuvN7iDVcIVQQBs4Kn/kEDkvTLizEvHq+PQ2rhFL02BRf5JX'
    '/Nd0UfH/RKKG5VoU/l4k8RDP08CKb4rysZAnKVItOjzQCvItUGJEJFwwJFxUhd18yYay+NB8yuK3+6ymKeI+m0cnLLPTUABUPM0A'
    'CdmqRUDzcFHLn7eQf1LzT+R8zx+xUHxU8495vc1qTVERYyJeK1SqHapUaociuXYo0Q0Su8cqBvz/JxhQfiwAxBpdQAD9RSHAEiBS'
    'KXCdRhPkFBv8C+Kw2HfcNIwTaO3DgT/yz0q1bDgqyq/Cg27KKV2mRvE7BBsR8RSsakihac0htzK3KythKirTImZXnvktqprqPFfM'
    'xWcJVvixAt1jQZIVQXoVAcrA+owLCt8i14pEOp6zijiTiM1KgYVAZwimQDC6wCOCWehWYoBhKgxTYDY651HcAo6ZTEN7AIlaBIla'
    'BIla1FIHtsbWv4rZsNLJbOIxpD/N9iebDXUwGw/vf1rtz7BasTkGu+FjdkOKZDhUrC8LmvkQNeTrv1gBBsQTMXQ0sFnNbsw/wHUe'
    'tkTq0pMzaKaFlyrixaiaD4IApccc6HQnd0SEiSTBpBBAfiQCu/yETHYBC4Gh4OoXy2hKvzqDNZZplsFQN2xDM2jRLBuuHfEnhMBP'
    '0eh1SIZcdWDxnFShKRpNjBRYzeESJbal66gov0gGcLTV8lwEGxoMD1e7bLhQS3ACD68hVi635esllMpScqRim+FWyAQX4ziMsA3X'
    'zGzgQFypxBA8UnDaAEa7ae+GT+YRxEULBlH2WEnvafz4xH7nAhtpti+4j+dp6i/Lx6zqbp09e0KnnaA4GYv1Sk+h4E8gEE9ioWen'
    'NtKG/yCRDzZuFPsGm6mi/aJbv2j2SLV1W9X+rii/KCzfWX5qiU43mcdOFEM+UQypJr/8jBNc2rbyR17ZxU8bDV5Qi12cxLa4vlPj'
    'Y9yVD7ZP5s8C4pht5gA1c+B25kBszPnv6+STrTUXXlcu5FQAMGI0MGKdZ8TvzkiefKB82CKtfBkuJl3ZoNkO0AO6yiCG0pWBUn4F'
    '6r1dBw0DdeVEzuiASvTrGMGdGaE5JL6yXsOA2gcDRRaKbySv4UTryonIkvHaitfwoPfEQ1kh6nXMGF2Z4XlA/rTfk4682WUYZlcW'
    'isQjWOVKkFpd2ZBTnQBR7TpG7K6M5MlVluA7w8URq3QONOR0rng+zTXq6BxpFAlk/hTsa9TROdrgGWvQhHkdD14/PMg5clHP9Bp2'
    '/F7YKbLywIt6HS+dww5xHQCY0K5yZGbn0ENceYDz9jqHbnaOOsrbA/2q7YHZOeRgF1fYA1pLitCPsFDflFluP5syTVGQYkubMulO'
    'BT+cDP4HJ5zxAg=='
)


if __name__ == '__main__':
    _run_main()
