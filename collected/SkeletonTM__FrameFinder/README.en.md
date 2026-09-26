# FrameFinder.lsp - auto-detect GOST sheet frames in AutoCAD model space

[Русская версия](README.md)

FrameFinder scans AutoCAD **model space** for **A4, A3, A2, A1, A0** frames
and their **extended lengths** (A4x3, A4x4, A3x4, A2x5, A1x3, A0x2 ... per
GOST 2.301-68), then either:

- creates a **Layout** with a viewport for each frame - for batch plotting
  via `PUBLISH`, or
- **plots** each frame right away (PDF/printer) - also through temporary
  layouts, which are deleted afterwards.

Frames can be **blocks** (dynamic included) and/or **closed polylines** -
Blocks / Lines / Both, selectable.

Tested with **AutoCAD 2022 and 2026** (requires ActiveX: full AutoCAD, not LT).

## Install

1. Put `FrameFinder.lsp` in any folder.
2. In AutoCAD: `APPLOAD` -> select the file -> **Load**
   (or add it to the Startup Suite for auto-loading).

## Commands

| Command | What it does |
|---|---|
| `FF` | Main dialog (DCL) - all settings in one window (recommended) |
| `FFDLG` | Alias for `FF` |
| `FFPLOT` | Find frames and plot immediately (command line) |
| `FFLAYOUT` | Find frames and create layouts for batch plotting |
| `FFCMD` | Command-line menu (Plot / Layouts) |
| `FFSET` | Settings: plot scale, device, style, tolerance |
| `FFMEDIA` | Diagnostics: paper sizes of the current plotter |
| `FFDIAG` | Diagnostics: object sizes and recognition results |

## The FF dialog

- **Scale** - frame size multiplier vs mm (`1` = 1:1, A4 = 210x297; `100` = x100).
- **Search in** - Blocks / Lines / Both.
- **Device** / **Plot style** - dropdowns populated from the system.
- **Action** - Plot frames / Create layouts.
- **Delete existing layouts** - checkbox (layout mode).

The `.dcl` file is generated into a temp folder automatically - no extra
files to keep next to the script.

## Drawing scale - set it explicitly

GOST formats are geometrically similar (side ratio ~1:1.41), so "A4 at 100x"
and "A0 at 25x" are indistinguishable by size alone. That is why the drawing
scale is always a number (1, 10, 100 ...) - recognition stays unambiguous.

## Layout plot scale (1:N) and driver units

The `DWG To PDF.pc3` driver may count paper in **inches** or
**millimeters**; the correct custom plot scale is **1:25.4** or **1:1**
respectively. Configured in `FFSET`:

- **Auto (by layout units)** - the default. Reads the units from the
  layout's own plot settings (DXF group code 72) - reliable, independent of
  template and locale.
- **1:25.4** - fixed (inch driver), **1:1** - fixed (metric driver),
  or any custom value N.

`FFSET` settings are stored in the Windows registry and survive AutoCAD
restarts.

## Extended formats - plotting 1:1

For extended formats (A4x3 = 297x630, A1x3 = 841x1783 ...) the script looks
for a paper size matching **exactly** (real size, no fit-to-page, no
margins). If the plotter has it (including your custom size), it is picked
automatically by size; otherwise the frame is **skipped** with a hint to
create it: `PLOTTERMANAGER -> DWG To PDF.pc3 -> Custom Paper Sizes -> Add`.

Regular formats (A4...A0) prefer **full bleed** media (no margins); `expand`
media is excluded.

## Limitations

- Frames drawn as separate **LINE** segments are not recognized - use blocks
  or polylines (`PEDIT` -> Join, or `BOUNDARY`).
- Size tolerance - 4% (configurable in `FFSET` / `*FF-TOL*`).
- A GOST frame has two lines (outer/inner); both get recognized as one
  format - the script keeps the outer line automatically.
- Plotting goes through temporary layouts: `FFPLOT` deletes them afterwards,
  `FFLAYOUT` keeps them for `PUBLISH`.
- PDFs are saved next to the .dwg as `<drawing>-<layout>.pdf`; on conflict
  you are asked to Overwrite / New name / Skip.
- Orientation (portrait/landscape) is detected from the actual paper size.

## Defaults (top of the file)

Most settings are easier to change via `FFSET`, but the defaults live in the
settings block at the top of `FrameFinder.lsp`: `*FF-PLOTTER*`,
`*FF-STYLE*`, `*FF-PLOTDENOM*`, `*FF-PLOTAUTO*` (default `T` = auto units),
`*FF-TOL*`. Custom formats can be added to `*FF-FORMATS*` as
`("NAME" short_side long_side)` in mm.

## Diagnostics

- `FFMEDIA` - lists all paper sizes of the current plotter as recognized by
  the script (useful to check whether a custom size exists).
- `FFDIAG` - walks all blocks/polylines in the model, prints sizes and
  recognition results (useful when a frame is not found).

## Credits

Based on proven open solutions, reworked and merged: BPDF (beastt1992,
GitHub) - batch PDF export of frame blocks; AddLay and forum LISP routines
(dwg.ru, caduser.ru) - layouts/viewports from frames; Plot-titles-in-model -
plotting frames from model space. Added: GOST format and extended-length
recognition, orientation and plot-unit auto-detection, frame dedup,
persistent settings, diagnostics.
