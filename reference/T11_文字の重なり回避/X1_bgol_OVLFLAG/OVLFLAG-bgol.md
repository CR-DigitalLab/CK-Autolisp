# OVLFLAG-bgol (Find & Flag Overlapping Text)

**Category:** Text Lisps
**Command Name:** `OVFX`
**Lisp File:** `OVLFLAG-bgol.lsp`
**Command Type:** AutoLISP routine (works in AutoCAD, BricsCAD, ZWCAD and
most AutoLISP-compatible CAD platforms)
**License:** Open-source, free to use, modify and share — for everyone.
**Developed by:** BGol Community — https://bgol.in/

> Inspired by the general concept of overlapping-text detection utilities
> used in CAD/survey drafting QA passes. This is an original, independently
> written routine — new file name, new command name, new source code —
> created so the CAD community has a free, editable, open-source
> alternative.


> **[Watch the animated tutorial](https://thevijayparmar.github.io/bgol-cad-lisps/Text%20Lisps/Find%20Overlapping/OVLFLAG-bgol.html)** — live demo, opens in your browser.

## Overview

`OVFX` scans TEXT and MTEXT entities — either a selection you make or the
whole drawing — and finds pairs whose insertion points sit at (or very
near) the same location. Overlapping labels like this render as an
unreadable smudge when a drawing is plotted, so catching them before
submission matters. Any text found to be overlapping is moved onto a
dedicated layer and recolored so it's instantly visible.

## How to Use

1. Load `OVLFLAG-bgol.lsp` into your CAD session (drag-and-drop the file
   onto the drawing window, or use the `APPLOAD` command).
2. Type `OVFX` at the command line and press **Enter**.
3. Select the text entities you want to check, or press **Enter** with
   nothing selected to scan every TEXT/MTEXT entity in the drawing.
4. Enter the overlap tolerance distance when prompted (defaults to
   `0.05` drawing units).
5. Any text entity found overlapping another is switched to layer
   `BGOL-OVFX` (colour cyan), flagging it for review. Entities that don't
   overlap anything are left untouched.

## Why Use It

- **Fills a real gap** — general duplicate-object finders catch exact
  duplicates, not near-coincident text at slightly different positions or
  content; this routine targets overlap specifically.
- **Protects readability** — catches label clutter before it reaches a
  plotted or PDF-exported drawing.
- **Fast QA pass** — checks an entire drawing's text in one command
  instead of eyeballing it label by label.

## Where to Use It

- Pre-submission quality checks on survey, civil, or architectural
  drawings before plotting or sharing.
- Cleaning up drawings merged or compiled from multiple source files,
  where duplicate/overlapping labels commonly creep in.
- Any drafting workflow where legible, non-overlapping annotation matters
  for the final output.

## Notes

- Overlap is judged purely by proximity of each text's insertion point —
  a practical approximation that works well for the short single-line
  labels (elevations, point numbers, remarks) this kind of routine is
  typically used on.
- The tolerance distance is user-adjustable at run time, so it can be
  tuned to the drawing's scale and text height.
- The original text entities are not deleted or altered in content — only
  their layer and color change, so the flag can be reviewed and reversed
  easily.
- Source code is fully open — feel free to study, modify, and redistribute
  it under the same open, free-for-all spirit.

## Credits

Developed and shared for the CAD community by **BGol Community**.
Website: **https://bgol.in/**
Free and open-source — use it, modify it, share it, for personal or
commercial work alike.
