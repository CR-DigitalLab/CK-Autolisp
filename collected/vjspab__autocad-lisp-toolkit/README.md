# 🏗️ AutoCAD LISP Toolkit for Urban & Land Planning

> A curated collection of AutoLISP routines for AutoCAD, designed specifically for **Urban Planning, Land Subdivision, and Plot Layout** workflows.

[![AutoCAD](https://img.shields.io/badge/AutoCAD-2016%2B-red?logo=autodesk)](https://www.autodesk.com/products/autocad/)
[![Language](https://img.shields.io/badge/Language-AutoLISP-blue)](https://help.autodesk.com/view/ACD/2024/ENU/?guid=GUID-21D1AD1B-B106-4D6A-AB11-83F877E79ED6)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![Maintained](https://img.shields.io/badge/Maintained-Yes-brightgreen)]()

---

## 📋 Overview

This toolkit automates repetitive and complex drafting tasks in AutoCAD for land subdivision and urban planning projects. The routines cover the full workflow — from generating plot blocks and creating polygons, to numbering plots sequentially and exporting plot data to CSV.

**Built for:** Urban Planners, Town Planners, Urban Designers, Layout Scheme Draftsmen, and GIS professionals who work in AutoCAD.

---

## 📂 File Index

| File | Command | Category | Description |
|------|---------|----------|-------------|
| [`GENBLOCK.lsp`](GENBLOCK.lsp) | `GENBLOCK` | Plot Generation | Auto-generates full residential plot blocks with roads, labels, and boundaries |
| [`MAKEPLOTS.lsp`](MakePlots.lsp) | `MAKEPLOTS` | Plot Generation | Quickly draws back-to-back plot rectangles with user-specified dimensions |
| [`MAKE POLYgon automatically.lsp`](<MAKE%20POLYgon%20automatically.lsp>) | `MAKEPOLY` | Polygon Tools | Creates closed polylines from enclosed areas by clicking inside them |
| [`makepolygon.lsp`](makepolygon.lsp) | `MAKEPOLY` | Polygon Tools | Alternative polygon creation routine |
| [`CopyClosedPolygons.lsp`](CopyClosedPolygons.lsp) | `CopyClosedPolys` | Polygon Tools | Copies all closed polygons to a dedicated layer with custom color |
| [`AutoDim.lsp`](AutoDim.lsp) | `AUTODIM` | Dimensioning | Adds aligned dimensions and a size label to an angled rectangle |
| [`LabelSize.lsp`](LabelSize.lsp) | `AUTODIM` | Dimensioning | Labels a rectangle with its LxW dimensions (variant of AutoDim) |
| [`PLOTDIM.lsp`](PLOTDIM.lsp) | `PLOTDIM` | Dimensioning | Dimensions a plot (Polyline or Region) and labels its area |
| [`PlotDetails.lsp`](PlotDetails.lsp) | `PLOTDETAILS` | Dimensioning | Calculates and labels area + dimensions for a rectangular plot |
| [`PlotDimensioningRegion.lsp`](PlotDimensioningRegion.lsp) | `PLOTDETAILS` | Dimensioning | Variant of PlotDetails with auto Region-to-Polyline conversion |
| [`PlotAreaDim.lsp`](PlotAreaDim.lsp) | `PLOTAREADIM` | Dimensioning | Dimensions plot areas across a selection |
| [`PlotNumbering.lsp`](PlotNumbering.lsp) | `PlotNum` | Numbering | Numbers plots sequentially based on a user-drawn guide polyline |
| [`CustomDiv.lsp`](CustomDiv.lsp) | `CUSTOMDIV` | Measurement | Divides an arc/polyline into custom sequential lengths with point markers |
| [`ExportPlotAreas.lsp`](ExportPlotAreas.lsp) | `ExportPlotData` | Data Export | Exports plot numbers, areas, and center coordinates to CSV |
| [`ExportPlotData_CORRECTED.lsp`](ExportPlotData_CORRECTED.lsp) | `ExportPlotData` | Data Export | Corrected/updated version of the plot data exporter |
| [`RADIAL_BLOCK.lsp`](RADIAL_BLOCK.lsp) | `RADIALBLOCK` | Advanced | Generates radially arranged plot blocks around a curve |
| [`RADIAL_BLOCK_V2.lsp`](RADIAL_BLOCK_V2.lsp) | `RADIALBLOCK` | Advanced | Version 2 of the radial block generator with improvements |
| [`PLOTDIM.lsp`](PLOTDIM.lsp) | `PLOTDIM` | Dimensioning | Dimensions a plot and labels area; accepts Polyline or Region |

---

## 🚀 How to Load a LISP Routine in AutoCAD

### Method 1: Load on Demand (Single Session)
1. Open AutoCAD
2. Type `APPLOAD` in the command line and press **Enter**
3. Browse to and select the `.lsp` file
4. Click **Load**, then **Close**
5. Type the **Command** from the table above and press **Enter**

### Method 2: Auto-Load on Startup
1. Place the `.lsp` files in a trusted AutoCAD support folder (e.g., `C:\Users\<you>\AppData\Roaming\Autodesk\AutoCAD 20XX\RXX\enu\Support\`)
2. In AutoCAD, go to **Tools → Load Application → Startup Suite → Contents**
3. Add the routines you want loaded automatically every session.

### Method 3: Load via Script (Recommended for Power Users)
Add this to your `acad.lsp` or `acaddoc.lsp` startup file:
```lisp
(load "C:/path/to/GENBLOCK.lsp")
(load "C:/path/to/PlotNumbering.lsp")
;; ... add more as needed
```

---

## 🛠️ Tool Descriptions

### 🏘️ Plot Generation

#### `GENBLOCK` — Residential Block Plot Generator
The most comprehensive tool in the toolkit. Interactively generates a full residential plot block layout.
- Configure plot frontage, depth, rows, and columns
- Optional **back-to-back** mirrored layout
- Optionally draws flanking **roads** on both sides with labels
- Auto-creates 4 layers: `PLOT-BOUNDARY`, `PLOT-TEXT`, `BLOCK-BOUNDARY`, `ROAD`
- Prints a full summary table (total plots, areas, block dimensions)

```
Command: GENBLOCK
[1/7] Plot FRONTAGE WIDTH: 6
[2/7] Plot DEPTH: 12
[3/7] Number of COLUMNS per side: 2
[4/7] Number of ROWS: 10
[5/7] Back-to-back layout? [Yes/No]: Yes
[6/7] Draw flanking ROADS? [Yes/No]: Yes
      Road WIDTH: 12
[7/7] Click INSERTION POINT
```

#### `MAKEPLOTS` — Quick Plot Generator
Faster, simpler version for generating back-to-back plots in a straight row.

---

### 🔷 Polygon Tools

#### `MAKEPOLY` — Auto-Polygon from Enclosed Areas
Traces closed polylines from areas bounded by intersecting lines. Just click inside an enclosed area — it does the rest. Ideal for quickly converting a hatched site plan into selectable plot polygons.

#### `CopyClosedPolys` — Copy & Separate Closed Polygons
Selects all closed polylines in the drawing and copies them to a new `Closed_Polygons_Copied` layer (RGB: 69, 84, 165 — indigo blue, 0.09mm lineweight). Useful for separating plot boundaries from other drawing entities.

---

### 📐 Dimensioning Tools

#### `AUTODIM` / `LabelSize` — Auto-Dimension Angled Rectangles
Prompts for text size and offset distance, then:
1. Labels the rectangle center with `LxW` dimensions (e.g., `12.50x6.00m`)
2. Draws all 4 aligned dimensions around the outside

#### `PLOTDIM` — Plot Dimensioner (Polyline + Region)
Like `AUTODIM` but also **auto-converts Regions** to polylines before dimensioning. Reads current `DIMTXT` for automatic text sizing.

#### `PLOTDETAILS` / `PlotDimensioningRegion` — Area + Dimension Label
Calculates exact area from AutoCAD's geometry engine and labels the plot with:
- **Center text**: `Area: 72.00 sq.m`
- **4 aligned dimensions** around the perimeter

---

### 🔢 Numbering & Sequencing

#### `PlotNum` — Path-Sequence Plot Numbering
Numbers plots in a custom sequence defined by a hand-drawn guide polyline. 
- Select all closed plot polygons **and** one open guide line together
- Plots are sorted by their proximity along the guide line
- Labels are added as centered text: `L01`, `L02`, `L03`...

---

### 📏 Measurement

#### `CUSTOMDIV` — Custom Sequential Curve Divider
Divides any arc or polyline into non-uniform segments. Unlike AutoCAD's built-in DIVIDE, you can specify **different lengths** for each segment interactively. Point markers are placed at each division.

---

### 📤 Data Export

#### `ExportPlotData` — Export Plot Data to CSV
Automatically matches plot number text labels to their enclosing polygons using a **ray-casting point-in-polygon algorithm** and exports to CSV:

```csv
Plot Number,Area,Center X,Center Y
L01,72.000,2045.123,1890.456
L02,68.500,2045.123,1902.456
```

---

### 🌀 Radial & Advanced Tools

#### `RADIAL_BLOCK` / `RADIAL_BLOCK_V2`
Generates residential plot blocks arranged radially around a curved road. V2 includes improvements and additional configurations.

---

## 📋 Requirements

| Requirement | Details |
|-------------|---------|
| AutoCAD Version | 2016 or later (uses `vl-load-com`) |
| Drawing Units | **Meters** (all dimensions assume metric) |
| Visual LISP | Must be enabled (standard in all modern AutoCAD) |

---

## 🗂️ Suggested Workflow: Full Plot Layout

```
1. MAKEPOLY     → Trace plot polygons from site plan lines
2. CopyClosedPolys → Isolate plot boundaries on a dedicated layer  
3. GENBLOCK     → Or generate new blocks from scratch
4. PlotNum      → Number all plots sequentially
5. PLOTDETAILS  → Label individual plot dimensions and area
6. ExportPlotData → Export plot data to CSV for further analysis
```

---

## 📁 Project Structure

```
autocad-lisp-toolkit/
├── README.md                        ← This file
├── LICENSE                          ← MIT License
├── .gitignore                       ← Ignores AutoCAD temp files
│
├── # Plot Generation
├── GENBLOCK.lsp                     ← Full block generator (v2.0)
├── MakePlots.lsp                    ← Quick back-to-back plot generator
│
├── # Polygon Tools
├── MAKE POLYgon automatically.lsp   ← Trace polygons from enclosed areas
├── makepolygon.lsp                  ← Alternative polygon routine
├── CopyClosedPolygons.lsp           ← Copy closed polys to new layer
│
├── # Dimensioning
├── AutoDim.lsp                      ← Dimension + label angled rectangles
├── LabelSize.lsp                    ← Size labeler (AutoDim variant)
├── PLOTDIM.lsp                      ← Dimension plots (incl. Regions)
├── PlotDetails.lsp                  ← Area + dimension labeler
├── PlotDimensioningRegion.lsp       ← PlotDetails with Region support
├── PlotAreaDim.lsp                  ← Batch area dimensioner
│
├── # Numbering
├── PlotNumbering.lsp                ← Sequence-number plots via guide line
│
├── # Measurement
├── CustomDiv.lsp                    ← Custom division of curves
│
├── # Data Export
├── ExportPlotAreas.lsp              ← Export plot data to CSV
└── ExportPlotData_CORRECTED.lsp     ← Corrected CSV exporter
```

---

## 🤝 Contributing

Contributions, improvements, and bug fixes are welcome!

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/new-tool`
3. Commit your changes: `git commit -m 'Add new LISP tool: XYZ'`
4. Push to the branch: `git push origin feature/new-tool`
5. Open a Pull Request

---

## 📜 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

## 👤 Author

**Vijay** — Urban & Transport Planner | AutoCAD Automation Enthusiast

> *Designed to save hours of repetitive drafting work for planners and draftsmen working on land subdivision and layout scheme projects.*

---

*Tested on AutoCAD 2016, 2019, 2021, 2024 — Windows & Mac (where LISP is supported)*
