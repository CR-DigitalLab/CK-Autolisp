# OVDIFF-bgol (Find Difference in Overlapping Text)

**Category:** Text Lisps
**Command Name:** `OVDF`
**Lisp File:** `OVDIFF-bgol.lsp`
**Command Type:** AutoLISP routine (works in AutoCAD, BricsCAD, ZWCAD and
most AutoLISP-compatible CAD platforms)
**License:** Open-source, free to use, modify and share — for everyone.
**Developed by:** BGol Community — https://bgol.in/

> Inspired by the general concept of overlapping-text difference
> utilities used in earthwork/survey CAD drafting. This is an original,
> independently written routine — new file name, new command name, new
> source code — created so the CAD community has a free, editable,
> open-source alternative.


> **[Watch the animated tutorial](https://thevijayparmar.github.io/bgol-cad-lisps/Text%20Lisps/Find%20Difference%20in%20Over%20Lapping%20Text/OVDIFF-bgol.html)** — live demo, opens in your browser.

## Overview

`OVDF` detects pairs of numeric TEXT entities that sit at (or very near)
the same insertion point — for example, an "initial level" and a "final
level" stacked on top of each other on different layers in an earthwork
drawing — and creates a new text at that location showing the signed
numeric difference between the pair, in a distinguishing color.

## How to Use

1. Load `OVDIFF-bgol.lsp` into your CAD session (drag-and-drop the file
   onto the drawing window, or use the `APPLOAD` command).
2. Type `OVDF` at the command line and press **Enter**.
3. Select the numeric TEXT entities to scan for overlaps, then press
   **Enter** to confirm.
4. The routine groups entities by matching insertion point (within a
   small coincidence tolerance) and computes the signed difference
   (second value − first value) for every overlapping pair found.
5. A new difference text is created next to each pair on layer
   `BGOL-OVDF`, colored green for a positive difference and red for a
   negative difference, so cut/fill sense is visible at a glance.

## Why Use It

- **Automates Earthwork Comparison** — removes the need to manually
  cross-reference and subtract two overlapping elevation values at
  every grid point across a large earthwork drawing.
- **Enables Difference Contouring** — the resulting difference values
  at each grid point can be used as input for generating a
  difference/cut-fill contour map of the site.
- **Visual Distinction** — colour-coding the calculated difference by
  sign makes it immediately identifiable apart from the original
  overlapping source values.

## Where to Use It

- **Earthwork projects** — comparing initial (existing ground) and
  final (design/finished) levels at each grid point to quantify cut or
  fill depth.
- Preparing input data for a difference-contour visualization of how
  elevations have changed across a site.
- Any survey task involving two overlapping numeric text values at the
  same location that need their difference computed and displayed
  in-place.

## Notes

- Overlap detection uses a small coincidence tolerance
  (`*bgol-ovdf-tol*`, default 0.01 drawing units) rather than requiring
  an exact point match; edit the constant near the top of the .lsp file
  if your drawing's overlapping pairs sit slightly further apart.
- Only the first matching pair found for each text is used — a text
  already paired is not paired again with a third overlapping text.
- Source code is fully open — feel free to study, modify, and redistribute
  it under the same open, free-for-all spirit.

## Credits

Developed and shared for the CAD community by **BGol Community**.
Website: **https://bgol.in/**
Free and open-source — use it, modify it, share it, for personal or
commercial work alike.
