# XRL — Xref Reload Tool for AutoCAD
**Version 2.5 | Author: drzkid96**

A lean AutoLISP tool for reloading xrefs in AutoCAD. Define a saved set once, type `XRL` every time. The set persists automatically beside the drawing — no manual save or load required.

---

## Installation

1. Copy `XREF-RELOAD.lsp` anywhere on your machine.
2. In AutoCAD, type `APPLOAD` and load the file.
3. To auto-load on every startup, add it to your **Startup Suite** inside the APPLOAD dialog.

---

## Commands

### `XRL`
Reloads xrefs using current config. No prompts. Defaults to Saved mode. If the saved set is empty, opens XRLCONFIG automatically to build one.

### `XRLCONFIG`
Opens the settings panel. Shows current state including the full saved set. Reprints after every change, then asks whether to run XRL immediately — Enter defaults to Yes.

| Option | Action | Default |
|---|---|---|
| M — Mode | Quick / Select / Saved | Saved |
| S — Set | Add / Remove / Clear | Add |
| A — SaveAll | On / Off | current |

### `XRL_VER`
Prints version info.

---

## Modes

**Saved** *(default)* — Reloads a fixed set of xrefs. Built once in XRLCONFIG and written automatically to a `.xrl` file beside the drawing. Loads automatically when you reopen. If the set is empty, XRL opens XRLCONFIG to build one.

**Quick** — Reloads every xref in the drawing. No prompts.

**Select** — Numbered list, pick which xrefs to reload. Accepts ranges: `1,3,5-8` or `*` for all.

---

## SaveAll

When enabled, saves any open drawings that match the xrefs being reloaded and have unsaved changes — before reloading. Skips the active drawing and anything not in the current run.

---

## Persistence

The saved set writes automatically to `<drawing-name>.xrl` beside the `.dwg` on every change and loads automatically on open. No user action needed.

Mode resets to Saved on every load. SaveAll state persists for the session.

---

## Selection Format

| Input | Meaning |
|---|---|
| `1,3,5-8,12` | individual, range, or mixed |
| `*` | all |
| `0` or Enter | cancel |

---

## Notes

- Requires AutoCAD 2000+ (Visual LISP / ActiveX)
- `CMDECHO` and `FILEDIA` are suppressed during execution and restored on exit, including on error
