# WallForge

**Automated wall plan generation for AutoCAD — from structured data to production-ready PDFs.**

WallForge takes wall specifications entered in a structured Excel workbook and automatically generates complete technical documentation in AutoCAD: dynamic blocks with all parameters applied, material lists, annotated layouts with correctly scaled viewports, titleblock data filled in, and individual PDFs exported — all from a single command.

What used to take a skilled drafter around five hours of manual work — opening a base file, adjusting every element to the required dimensions, calculating materials by hand, building the layout, and exporting PDFs — now runs in under a minute.

![WallForge demo](04_docs/wallforge-demo.gif)
---

## How it works

The system has two layers that work together:

```
Excel workbook (WAENDE_SCHEMA_V01.xlsm)
    │
    │  guided data entry with automatic validation
    │  and real-time synchronization between sheets
    │
    ▼
CSV export  (01_wand_export.csv + 02_plankopf_export.csv)
    │
    │  structured wall data + titleblock metadata
    │
    ▼
AutoCAD LSP (Automatic_wall_v01.lsp)
    │
    │  reads CSVs, inserts and configures dynamic blocks,
    │  calculates materials, generates layouts and viewports,
    │  fills titleblocks, assigns annotative scales, exports PDFs
    │
    ▼
Output: one complete set of technical drawings per wall
        WAND layouts (A1) + Drucklayout sheets (A3) + PDFs
```

**Layer 1 — Excel workbook**
The workbook guides the user through wall specification using smart forms: selecting a frame type auto-fills structural dimensions from a reference table, cladding type locks or unlocks the relevant material fields, and Drucklayout rows in the titleblock sheet are created or removed automatically as digital print materials are added or removed. When the data is ready, a single macro exports two clean CSV files.

**Layer 2 — AutoCAD LSP**
The `c:WAND` command reads both CSVs and processes each wall row through a full pipeline: dynamic blocks are inserted and configured with parameters from the CSV, material quantities are calculated (including 2D splitting and orientation optimization for sheet materials), MText annotations are generated, paper space layouts are created with auto-scaled viewports, titleblocks are filled, annotative scales are assigned, and PDFs are exported via Publish.

---

## Requirements

| Component | Version |
|---|---|
| AutoCAD | 2025 or later |
| Microsoft Excel | 2019 or later (XLOOKUP required) |
| AutoCAD blocks | `BLK_WAND_*` dynamic block library — demo version included |

> The LSP and Excel workbook were originally designed for scenic construction, where walls are fabric-clad temporary structures. A demo block library is included in `01_autocad/blocks/` so the full pipeline can be tested without any additional files. The blocks have been adapted visually from standard light partition wall details; the original proprietary blocks are not included.
>
> The Drucklayout system (`BLK_WAND_DL_*`) is specific to scenic construction — it generates print specification sheets for digitally printed fabric cladding, including visible area and bleed dimensions. For other use cases this subsystem can be disabled or replaced; it is fully isolated in Section 11.3 of the LSP.

---

## Project structure

```
wallforge/
│
├── README.md
│
├── 01_autocad/
│   ├── Automatic_wall_v01.lsp           # AutoLISP source
│   └── blocks/
│       └── WallForge_demo_blocks.dwg    # Demo block library
│
├── 02_excel/
│   └── WAENDE_SCHEMA_V01.xlsm           # Excel workbook with VBA macros
│
├── 03_examples/
│   ├── 01_wand_export_example.csv       # Example wall data CSV
│   └── 02_plankopf_export_example.csv   # Example titleblock CSV
│
└── 04_docs/
    ├── autolisp-reference.md            # Code architecture and function reference
    ├── Automatic_wall_flow.html         # Interactive execution flow diagram
    ├── excel-schema.md                  # Excel structure, fields, and validation logic
    └── wallforge-demo.gif               # Demo screencast
```

---

## Quick start

1. Open `WAENDE_SCHEMA_V01.xlsm` in Excel
2. Fill in wall data in the `WAND_DATA` sheet — fields are validated and locked automatically as you go
3. Check `PLANKOPF` — titleblock rows are created automatically; fill in project metadata
4. Run the **Export CSV** macro — two CSV files are saved to a folder of your choice
5. Open `01_autocad/blocks/WallForge_demo_blocks.dwg` in AutoCAD — the demo block library is already loaded
6. Load the LSP file: type `APPLOAD` in the command line, browse to `01_autocad/Automatic_wall_v01.lsp` and 
   click Load
7. Type `WAND` and press Enter
8. Select the wall data CSV, then the titleblock CSV, then confirm the DSD file in the Publish dialog

AutoCAD will generate all layouts and export one PDF per layout to the same folder as the DWG.

---

## CSV format

**01_wand_export.csv** — one row per wall, semicolon-separated

Key fields: `UK_ID`, `BREITE_UK`, `WAND_HOEHE`, `TIEFE_UK`, `BESP_ID`, `SB_ID`, `DC_VH`, `BESP_MAT_V`, `BESP_MAT_H` and related dimension and material columns. Full field reference in [`04_docs/excel-schema.md`](04_docs/excel-schema.md).

**02_plankopf_export.csv** — one row per layout (WAND or DRUCKLAYOUT type), semicolon-separated

Key fields: `PLAN_TYP`, `PROJEKT_NR`, `PLAN_TITEL`, `POSITION_NR`, `DATUM_PLAN`, `GEZEICHNET_VON`. PDF filenames are built from these fields automatically.

---

## Output

For each wall row in the CSV, WallForge generates:

- **1 WAND layout** (A1 format) with multiple viewports: main elevation, section, detail views — all auto-scaled based on wall dimensions
- **1–2 Drucklayout sheets** (A3 format) for digital print specifications, one per cladding face with visible area and bleed dimensions
- **PDF files** named `YYMMDD_Pos. XX_Plan Title_Project Nr.pdf`

---

## Code architecture

The LSP is organized in 13 sections with clear separation between pure logic and AutoCAD side effects. A full interactive function reference with execution flow diagram is available in [`04_docs/autolisp-reference.md`](04_docs/autolisp-reference.md).

The central design pattern is an **immutable context object** (`ctx`) — an association list that threads all state through the pipeline without global variables. Every function receives `ctx` and returns an updated copy.

```lisp
;; Entry point
(defun c:WAND (/ ctx)
  (setq ctx (wall-init))               ; open files, build context
  (setq ctx (wall-read-titleblock ctx)) ; load titleblock CSV
  (setq ctx (wall-process-all ctx))     ; process all wall rows
  (setq ctx (wall-export-pdfs ctx))     ; export PDFs
  ...
)
```

---

## About this project

This is my first programming project — and my first lines of code in any language.

I work in scenic construction, where producing wall documentation is a routine but time-consuming task. I built WallForge over the course of a month using iterative AI-assisted development, learning AutoLISP, VBA, and software architecture concepts along the way.

The goal was practical from the start: eliminate five hours of repetitive manual work per set of wall drawings. The result turned out to be a complete system with a data layer, a calculation engine, a drawing generation pipeline, and an export system — things I didn't know had names when I started.

I'm sharing it here as both a portfolio piece and a potentially useful tool for others working in similar technical documentation contexts.

**Eva Rodríguez Molina**
Munich, 2026

---

## License

MIT License — free to use, modify, and distribute with attribution.
