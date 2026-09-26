# LISP Center of Gravity Tools for AutoCAD

AutoLISP tools for calculating and documenting centroid / center-of-gravity properties in AutoCAD (2024).

## Commands

### CG2D
Calculates centroidal section properties for closed 2D polylines and regions. Exports results to CSV and places centroid markers in model space.

<img width="523" height="262" alt="Picture1" src="https://github.com/user-attachments/assets/499454e3-e72b-4795-a9ef-865a62396bcd" />

### CG3D
Calculates the combined center of gravity of one or more 3DSOLIDs with user-defined material densities. Exports results to CSV and places a CG marker sphere in model space.

<img width="495" height="300" alt="Picture2" src="https://github.com/user-attachments/assets/760b94c9-6a94-4690-b96b-5716069312c7" />

## Installation

1. Download the files in the `/Source` folder.
2. Copy all `.lsp` and `.dcl` files into the same folder.
3. Add that folder to AutoCAD Support File Search Path.
4. Load `CG_2D.lsp` and/or `CG_3D.lsp` with `APPLOAD`.
5. Run `CG2D` or `CG3D`.

## Documentation

See `/Docs/LISP CG tools guide.pdf`.

## Current Status

Beta / work in progress. Verify all output independently before use.
