# AutoLISP Civil Tools Community

Small, auditable GPL-3.0-or-later tools for civil-survey work in AutoCAD-compatible CAD software.

**Status:** v0.2.0 source is ready for community CAD testing. This is an independent public project and contains no code or data from private commercial toolkits.

[Huong dan tieng Viet khong dau](docs/README.vi.md) | [Command reference](docs/COMMANDS.md) | [Roadmap](ROADMAP.md)

## Commands

| Command | Purpose |
| --- | --- |
| `CTCOORD` | Label selected POINT entities with ID and WCS X/Y/Z coordinates. |
| `CTEXPORT` | Export selected POINT and TEXT entities to a WCS CSV file. |
| `CTIMPORT` | Import POINT entities from a CSV file with `x`, `y`, and `z` columns. |
| `CTELEV` | Create or update an elevation label at a selected POINT. |
| `CTCHAINAGE` | Label station and absolute offset for POINT entities along a selected curve. |
| `CTINTERP` | Interpolate clamped elevation labels between two control POINT entities. |
| `CTPROFILE` | Create a station/elevation/offset table for POINT entities along a selected curve. |

## Install

1. Download the release ZIP and verify it with `CHECKSUMS.txt`.
2. Extract it to a writable local folder.
3. In AutoCAD or BricsCAD, run `APPLOAD` and load `src/act-load.lsp`.
4. Confirm that the command line reports version `0.2.0`, then run a command above.

The loader does not install an updater, make network calls, or collect telemetry.

## Coordinate and data policy

All exported/imported coordinates and calculation inputs are WCS values. Entity DXF points are converted from OCS to WCS, and interactive table placement is converted from the current UCS to WCS. CSV files use the host CAD text encoding; UTF-8 output is not claimed until verified in supported Windows CAD versions.

`CTCHAINAGE` uses the selected curve start as station zero. Offsets are unsigned distances. `CTINTERP` projects targets in the WCS XY plane and clamps values to the elevation range between the two controls.

## Compatibility and test status

The target is AutoCAD and BricsCAD on Windows with Visual LISP curve/ActiveX support. Static QA and package validation run on every push. Interactive behavior has **not yet been verified in a real CAD runtime** because this Linux VPS has no AutoCAD, BricsCAD, or Wine installation. See [TEST_REPORT.md](TEST_REPORT.md) and the reproducible Windows checklist in [docs/CAD_TEST_MATRIX.md](docs/CAD_TEST_MATRIX.md).

Never rely on generated labels or CSV files as the sole source for production survey decisions. Review units, coordinate system, alignment direction, and results in the drawing.

## Development

```bash
python3 tests/check_repo.py
bash scripts/package_release.sh
unzip -t dist/autolisp-civil-tools-v0.2.0.zip
```

Please read [CONTRIBUTING.md](CONTRIBUTING.md). Report vulnerabilities privately using [SECURITY.md](SECURITY.md), not a public issue.

## License

Copyright (C) 2026 Truong Hoa and contributors. Licensed under [GPL-3.0-or-later](LICENSE).
