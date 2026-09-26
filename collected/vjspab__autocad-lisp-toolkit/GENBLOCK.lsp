;;; ============================================================
;;; RESIDENTIAL BLOCK PLOT GENERATOR
;;; Version: 2.0  |  For AutoCAD 2016 and later
;;; Command: GENBLOCK
;;; Purpose: Auto-generates residential plot blocks for layout schemes
;;; Author : Urban Planning Layout Tool
;;; ============================================================
;;; LAYERS CREATED AUTOMATICALLY:
;;;   PLOT-BOUNDARY  [Color: Yellow] - Individual plot outlines
;;;   PLOT-TEXT      [Color: Green]  - Plot labels and numbers
;;;   BLOCK-BOUNDARY [Color: Red]    - Overall block outer boundary
;;;   ROAD           [Color: Cyan]   - Flanking road boundaries
;;; ============================================================

(defun C:GENBLOCK (/
  *error* old-cmdecho old-osmode old-layer
  plot-w plot-d num-cols num-rows
  back-to-back back-gap road-opt road-w
  ins-pt base-x base-y block-w block-d txt-ht
  i j x1 y1 x2 y2 txt-x txt-y
  plot-num plot-label total-plots mirror-offset road-txt-ht
  )

  ;; ===== Error Handler =====
  (defun *error* (msg)
    (if old-cmdecho (setvar "CMDECHO" old-cmdecho))
    (if old-osmode  (setvar "OSMODE"  old-osmode))
    (if old-layer   (command "_.LAYER" "S" old-layer ""))
    (if (not (wcmatch (strcase msg) "*CANCEL*,*QUIT*,*EXIT*,*ABORT*"))
      (princ (strcat "\n** Error: " msg " **"))
    )
    (princ)
  )

  ;; ===== Save System Variables =====
  (setq old-cmdecho (getvar "CMDECHO")
        old-osmode  (getvar "OSMODE")
        old-layer   (getvar "CLAYER"))
  (setvar "CMDECHO" 0)
  (setvar "OSMODE"  0)

  ;; ===== Create Layers =====
  (command "_.LAYER"
    "M" "PLOT-BOUNDARY"  "C" "2" "PLOT-BOUNDARY"
    "M" "PLOT-TEXT"      "C" "3" "PLOT-TEXT"
    "M" "BLOCK-BOUNDARY" "C" "1" "BLOCK-BOUNDARY"
    "M" "ROAD"           "C" "4" "ROAD"
    ""
  )

  ;; ===== Print Header =====
  (princ "\n")
  (princ "\n +------------------------------------------+")
  (princ "\n |  RESIDENTIAL BLOCK PLOT GENERATOR  v2.0  |")
  (princ "\n |  Urban Planning Layout Tool               |")
  (princ "\n +------------------------------------------+")
  (princ "\n  NOTE: All dimensions in METERS")
  (princ "\n  Ensure drawing units are set to METERS")
  (princ "\n")

  ;; ===== Collect User Inputs =====

  ;; [1] Plot Width (Frontage)
  (if (not (setq plot-w (getreal "\n[1/7] Plot FRONTAGE WIDTH (e.g. 6 for 6M): ")))
    (exit)
  )

  ;; [2] Plot Depth
  (if (not (setq plot-d (getreal "\n[2/7] Plot DEPTH (e.g. 12 for 12M): ")))
    (exit)
  )

  ;; [3] Number of Columns
  (if (not (setq num-cols (getint "\n[3/7] Number of plot COLUMNS per side (e.g. 2): ")))
    (exit)
  )

  ;; [4] Number of Rows
  (if (not (setq num-rows (getint "\n[4/7] Number of plot ROWS (e.g. 10): ")))
    (exit)
  )

  ;; [5] Back-to-back layout?
  (initget "Yes No")
  (setq back-to-back (getkword "\n[5/7] Back-to-back layout (mirrored both sides)? [Yes/No] <No>: "))
  (if (null back-to-back) (setq back-to-back "No"))

  (if (= back-to-back "Yes")
    (progn
      (setq back-gap (getreal "\n      Internal path/gap between back-to-back plots (0 = none): "))
      (if (null back-gap) (setq back-gap 0.0))
    )
    (setq back-gap 0.0)
  )

  ;; [6] Draw Roads?
  (initget "Yes No")
  (setq road-opt (getkword "\n[6/7] Draw flanking ROADS on both sides? [Yes/No] <Yes>: "))
  (if (null road-opt) (setq road-opt "Yes"))

  (if (= road-opt "Yes")
    (progn
      (setq road-w (getreal "\n      Road WIDTH (e.g. 12 for 12M): "))
      (if (null road-w) (setq road-w 12.0))
    )
    (setq road-w 0.0)
  )

  ;; [7] Insertion Point (user clicks in drawing)
  (if (not (setq ins-pt (getpoint "\n[7/7] Click INSERTION POINT (bottom-left corner of block): ")))
    (exit)
  )

  ;; ===== Calculate Dimensions =====
  (setq base-x  (car  ins-pt)
        base-y  (cadr ins-pt)
        block-w (if (= back-to-back "Yes")
                  (+ (* num-cols plot-w) back-gap (* num-cols plot-w))
                  (* num-cols plot-w))
        block-d (* num-rows plot-d)
        txt-ht  (* plot-w 0.12)
  )

  ;; ===== Draw Left / Single-Side Plots =====
  (setq j 0)
  (repeat num-rows
    (setq i 0)
    (repeat num-cols
      ;; --- Draw plot rectangle ---
      (command "_.LAYER" "S" "PLOT-BOUNDARY" "")
      (setq x1 (+ base-x (* i plot-w))
            y1 (+ base-y (* j plot-d))
            x2 (+ x1 plot-w)
            y2 (+ y1 plot-d))
      (command "_.RECTANG" (list x1 y1) (list x2 y2))

      ;; --- Draw plot dimension label and plot number ---
      (command "_.LAYER" "S" "PLOT-TEXT" "")
      (setq txt-x     (+ x1 (* plot-w 0.50))
            txt-y     (+ y1 (* plot-d 0.62))
            plot-num  (1+ (+ (* j num-cols) i))
            plot-label (strcat (rtos plot-w 2 0) "Mx" (rtos plot-d 2 0) "M"))

      (command "_.TEXT" "J" "MC"
               (list txt-x txt-y) txt-ht "0" plot-label)
      (command "_.TEXT" "J" "MC"
               (list txt-x (- txt-y (* plot-d 0.18)))
               (* txt-ht 0.90) "0"
               (strcat "P-" (itoa plot-num)))

      (setq i (1+ i))
    )
    (setq j (1+ j))
  )

  ;; ===== Draw Right Side Plots (Back-to-Back mode) =====
  (if (= back-to-back "Yes")
    (progn
      (setq mirror-offset (+ (* num-cols plot-w) back-gap))
      (setq j 0)
      (repeat num-rows
        (setq i 0)
        (repeat num-cols
          ;; --- Draw plot rectangle (right side) ---
          (command "_.LAYER" "S" "PLOT-BOUNDARY" "")
          (setq x1 (+ base-x mirror-offset (* i plot-w))
                y1 (+ base-y (* j plot-d))
                x2 (+ x1 plot-w)
                y2 (+ y1 plot-d))
          (command "_.RECTANG" (list x1 y1) (list x2 y2))

          ;; --- Draw label and plot number (right side) ---
          (command "_.LAYER" "S" "PLOT-TEXT" "")
          (setq txt-x    (+ x1 (* plot-w 0.50))
                txt-y    (+ y1 (* plot-d 0.62))
                plot-num (1+ (+ (* num-rows num-cols) (* j num-cols) i))
                plot-label (strcat (rtos plot-w 2 0) "Mx" (rtos plot-d 2 0) "M"))

          (command "_.TEXT" "J" "MC"
                   (list txt-x txt-y) txt-ht "0" plot-label)
          (command "_.TEXT" "J" "MC"
                   (list txt-x (- txt-y (* plot-d 0.18)))
                   (* txt-ht 0.90) "0"
                   (strcat "P-" (itoa plot-num)))

          (setq i (1+ i))
        )
        (setq j (1+ j))
      )
    )
  )

  ;; ===== Draw Block Outer Boundary =====
  (command "_.LAYER" "S" "BLOCK-BOUNDARY" "")
  (command "_.RECTANG"
           (list base-x base-y)
           (list (+ base-x block-w) (+ base-y block-d)))

  ;; ===== Draw Flanking Roads =====
  (if (= road-opt "Yes")
    (progn
      (setq road-txt-ht (* road-w 0.10))

      ;; Left Road boundary
      (command "_.LAYER" "S" "ROAD" "")
      (command "_.RECTANG"
               (list (- base-x road-w) base-y)
               (list base-x (+ base-y block-d)))

      ;; Right Road boundary
      (command "_.RECTANG"
               (list (+ base-x block-w) base-y)
               (list (+ base-x block-w road-w) (+ base-y block-d)))

      ;; Road Labels
      (command "_.LAYER" "S" "PLOT-TEXT" "")

      ;; Left road label (rotated 90 deg, centered on road)
      (command "_.TEXT" "J" "MC"
               (list (- base-x (* road-w 0.50))
                     (+ base-y (* block-d 0.50)))
               road-txt-ht "90"
               (strcat "ROAD  " (rtos road-w 2 1) " M. WIDE"))

      ;; Right road label (rotated 90 deg, centered on road)
      (command "_.TEXT" "J" "MC"
               (list (+ base-x block-w (* road-w 0.50))
                     (+ base-y (* block-d 0.50)))
               road-txt-ht "90"
               (strcat "ROAD  " (rtos road-w 2 1) " M. WIDE"))
    )
  )

  ;; ===== Restore System Variables =====
  (command "_.LAYER" "S" old-layer "")
  (setvar "CMDECHO" old-cmdecho)
  (setvar "OSMODE"  old-osmode)

  ;; ===== Print Summary =====
  (setq total-plots (if (= back-to-back "Yes")
                      (* num-rows num-cols 2)
                      (* num-rows num-cols)))

  (princ "\n")
  (princ "\n +------------------------------------------+")
  (princ "\n |       BLOCK GENERATED SUCCESSFULLY       |")
  (princ "\n +------------------------------------------+")
  (princ (strcat "\n  Plot Size      : " (rtos plot-w 2 1)
                 "M  x  " (rtos plot-d 2 1) "M"))
  (princ (strcat "\n  Plot Area      : " (rtos (* plot-w plot-d) 2 2)
                 " Sq.M  (" (rtos (/ (* plot-w plot-d) 9.0) 2 2) " Sq.Yd)"))
  (princ (strcat "\n  Total Plots    : " (itoa total-plots)))
  (princ (strcat "\n  Block Width    : " (rtos block-w 2 2) " M"))
  (princ (strcat "\n  Block Depth    : " (rtos block-d 2 2) " M"))
  (princ (strcat "\n  Block Area     : " (rtos (* block-w block-d) 2 2) " Sq.M"))
  (if (= road-opt "Yes")
    (progn
      (princ (strcat "\n  Road Width     : " (rtos road-w 2 1) " M"))
      (princ (strcat "\n  Total Corridor : "
                     (rtos (+ block-w (* 2 road-w)) 2 2) " M (incl. roads)"))
    )
  )
  (princ "\n +------------------------------------------+")
  (princ "\n")
  (princ)
)

;;; ===== Load Confirmation Message =====
(princ "\n")
(princ "\n +------------------------------------------+")
(princ "\n |  GENBLOCK.lsp loaded successfully.       |")
(princ "\n |  Type  GENBLOCK  to start the tool.      |")
(princ "\n +------------------------------------------+")
(princ)
