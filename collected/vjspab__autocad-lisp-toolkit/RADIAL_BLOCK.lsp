;;; ==========================================================================
;;; RADIAL_BLOCK.lsp
;;; --------------------------------------------------------------------------
;;; Description:
;;;   Automates the generation of radial/wedge-shaped residential plots along
;;;   an existing Arc or 2D Polyline. Ideal for urban planning and layouts.
;;;
;;; Commands:
;;;   RADIAL_BLOCK - Main execution command.
;;;
;;; Inputs:
;;;   1. Select Alignment (Arc/Polyline).
;;;   2. Alignment Type: [C]enterline, [F]ront, or [B]ack.
;;;   3. Plot Dimensions (Frontage Width, Depth).
;;;   4. Total Count.
;;;
;;; Output:
;;;   - Closed LWPOLYLINEs on layer "PLOT-BOUNDARY" (Color 2).
;;;   - Text labels (e.g., P-1) on layer "PLOT-TEXT" (Color 3).
;;;
;;; Notes:
;;;   - Uses ActiveX (vlax-*) for precise curve calculations.
;;;   - Disables OSNAP during execution for accuracy.
;;; ==========================================================================

(defun c:RADIAL_BLOCK ( / *error* adoc spc sel ent curveObj align width depth count 
                          curveLen sidePt sideVec i distStart distEnd pt1 pt2 
                          deriv1 deriv2 norm1 norm2 p3 p4 p3_opp p4_opp 
                          midP1P2 midP3P4 cenPt txtAng txtStr 
                          old_osmode old_cmdecho layer_bdry layer_text)

  ;; 1. INITIALIZATION & SAFETY
  ;; ------------------------------------------------------------------------
  (vl-load-com)
  (setq adoc (vla-get-activedocument (vlax-get-acad-object)))
  (setq spc  (vla-get-modelspace adoc))

  ;; Store system variables
  (setq old_osmode  (getvar "OSMODE"))
  (setq old_cmdecho (getvar "CMDECHO"))

  ;; Local Error Handler
  (defun *error* (msg)
    (if old_osmode (setvar "OSMODE" old_osmode))
    (if old_cmdecho (setvar "CMDECHO" old_cmdecho))
    (vla-EndUndoMark adoc)
    (if (and msg (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*")))
      (princ (strcat "\nError: " msg))
    )
    (princ)
  )

  ;; Start Undo Group
  (vla-StartUndoMark adoc)
  (setvar "CMDECHO" 0)

  ;; 2. LAYER SETUP
  ;; ------------------------------------------------------------------------
  (setq layer_bdry "PLOT-BOUNDARY")
  (setq layer_text "PLOT-TEXT")

  ;; Create Boundary Layer (Color 2 - Yellow)
  (if (not (tblsearch "LAYER" layer_bdry))
    (entmake (list '(0 . "LAYER")
                   '(100 . "AcDbSymbolTableRecord")
                   '(100 . "AcDbLayerTableRecord")
                   (cons 2 layer_bdry)
                   '(70 . 0)
                   '(62 . 2))) ;; Yellow
  )

  ;; Create Text Layer (Color 3 - Green)
  (if (not (tblsearch "LAYER" layer_text))
    (entmake (list '(0 . "LAYER")
                   '(100 . "AcDbSymbolTableRecord")
                   '(100 . "AcDbLayerTableRecord")
                   (cons 2 layer_text)
                   '(70 . 0)
                   '(62 . 3))) ;; Green
  )

  ;; 3. USER INPUTS
  ;; ------------------------------------------------------------------------
  (princ "\n--- Radial Plot Generator ---")
  
  ;; Select Curve
  (while (not (and (setq sel (entsel "\nSelect Alignment Curve (Arc or Polyline): "))
                   (wcmatch (cdr (assoc 0 (entget (car sel)))) "ARC,LWPOLYLINE,POLYLINE,SPLINE")))
    (princ "\nInvalid object. Please select an ARC or POLYLINE.")
  )
  (setq ent (car sel))
  (setq curveObj (vlax-ename->vla-object ent))
  (setq curveLen (vlax-curve-getDistAtParam curveObj (vlax-curve-getEndParam curveObj)))

  ;; Alignment Mode
  (initget "Centerline Front Back")
  (setq align (getkword "\nSpecify Alignment [Centerline/Front/Back] <Front>: "))
  (if (null align) (setq align "Front"))

  ;; Dimensions
  (setq width (getdist "\nEnter Plot Frontage Width (Along Curve): "))
  (setq depth (getdist "\nEnter Plot Depth (Radial): "))
  (setq count (getint  "\nEnter Total Number of Plots: "))

  ;; Validate Length
  (if (> (* count width) curveLen)
    (princ (strcat "\nWarning: Total width (" (rtos (* count width) 2 2) 
                   ") exceeds curve length (" (rtos curveLen 2 2) "). Plots will be truncated."))
  )

  ;; Determine Offset Direction (if not Centerline)
  (setq sideVec 1.0) ;; Default multiplier
  (if (or (= align "Front") (= align "Back"))
    (progn
      (setq sidePt (getpoint "\nClick on the side of the curve to place the plots: "))
      (if sidePt
        (progn
          ;; Math to determine if clicked point is "Left" or "Right" of curve
          ;; We take a test point at start of curve
          (setq pt1 (vlax-curve-getPointAtDist curveObj 0.0))
          (setq deriv1 (vlax-curve-getFirstDeriv curveObj 0.0))
          ;; Normal vector (Rotated 90 degrees CCW: -y, x)
          (setq norm1 (list (- (cadr deriv1)) (car deriv1) 0.0))
          ;; Vector from Curve to Pick Point
          (setq pickVec (mapcar '- sidePt pt1))
          ;; Dot product
          (setq dotProd (+ (* (car norm1) (car pickVec)) (* (cadr norm1) (cadr pickVec))))
          ;; If Dot > 0, pick is on Left (Normal direction). If < 0, pick is Right.
          (if (< dotProd 0) (setq sideVec -1.0) (setq sideVec 1.0))
          
          ;; Logic adjustment based on Front/Back
          ;; If Alignment is Back, we want plots to extend Towards the road (Opposite to depth direction?)
          ;; Actually, standard interpretation:
          ;; Front: Curve is Front, Offset is Away (into the block).
          ;; Back: Curve is Back, Offset is Away (towards the road).
          ;; The user click indicates the area *where the plot body exists*.
          ;; So we always offset *towards* the click.
        )
      )
    )
  )

  ;; 4. GEOMETRY GENERATION
  ;; ------------------------------------------------------------------------
  (setvar "OSMODE" 0) ;; Critical: Disable snaps for drawing
  (setq i 0)
  (setq plotNum 1)

  (while (< i count)
    ;; Calculate Station Distances
    (setq distStart (* i width))
    (setq distEnd   (* (+ i 1) width))

    ;; Stop if we run off the curve
    (if (> distEnd curveLen)
      (setq i count) ;; Force exit
      (progn
        ;; Get Points on Curve
        (setq pt1 (vlax-curve-getPointAtDist curveObj distStart))
        (setq pt2 (vlax-curve-getPointAtDist curveObj distEnd))

        ;; Get Derivatives (Tangents)
        (setq deriv1 (vlax-curve-getFirstDeriv curveObj (vlax-curve-getParamAtDist curveObj distStart)))
        (setq deriv2 (vlax-curve-getFirstDeriv curveObj (vlax-curve-getParamAtDist curveObj distEnd)))

        ;; Calculate Unit Normals (Rotated 90 deg CCW: -Y, X)
        (setq norm1 (LM:UnitVector (list (- (cadr deriv1)) (car deriv1) 0.0)))
        (setq norm2 (LM:UnitVector (list (- (cadr deriv2)) (car deriv2) 0.0)))

        ;; ----------------------------------------------------------
        ;; CASE: CENTERLINE (Double Loaded)
        ;; ----------------------------------------------------------
        (if (= align "Centerline")
          (progn
            ;; Side A (Positive Normal)
            (setq p3 (mapcar '+ pt2 (mapcar '* norm2 (list depth depth depth))))
            (setq p4 (mapcar '+ pt1 (mapcar '* norm1 (list depth depth depth))))
            (DrawPlotPoly pt1 pt2 p3 p4 layer_bdry)
            (AddPlotText pt1 pt2 p3 p4 (strcat "P-" (itoa plotNum)) layer_text)
            (setq plotNum (1+ plotNum))

            ;; Side B (Negative Normal)
            (setq p3_opp (mapcar '- pt2 (mapcar '* norm2 (list depth depth depth))))
            (setq p4_opp (mapcar '- pt1 (mapcar '* norm1 (list depth depth depth))))
            (DrawPlotPoly pt1 pt2 p3_opp p4_opp layer_bdry)
            (AddPlotText pt1 pt2 p3_opp p4_opp (strcat "P-" (itoa plotNum)) layer_text)
            (setq plotNum (1+ plotNum))
          )
        )

        ;; ----------------------------------------------------------
        ;; CASE: FRONT / BACK (Single Loaded)
        ;; ----------------------------------------------------------
        (if (or (= align "Front") (= align "Back"))
          (progn
            ;; Calculate offset vector based on Side selection
            (setq offsetDist (* depth sideVec))
            
            (setq p3 (mapcar '+ pt2 (mapcar '* norm2 (list offsetDist offsetDist offsetDist))))
            (setq p4 (mapcar '+ pt1 (mapcar '* norm1 (list offsetDist offsetDist offsetDist))))
            
            (DrawPlotPoly pt1 pt2 p3 p4 layer_bdry)
            (AddPlotText pt1 pt2 p3 p4 (strcat "P-" (itoa plotNum)) layer_text)
            (setq plotNum (1+ plotNum))
          )
        )

        (setq i (1+ i))
      )
    )
  )

  ;; 5. CLEANUP
  ;; ------------------------------------------------------------------------
  (setvar "OSMODE" old_osmode)
  (setvar "CMDECHO" old_cmdecho)
  (vla-EndUndoMark adoc)
  (princ (strcat "\nSuccessfully generated " (itoa (1- plotNum)) " radial plots."))
  (princ)
)

;;; ==========================================================================
;;; HELPER FUNCTIONS
;;; ==========================================================================

;;; DrawPlotPoly
;;; Draws a closed LWPolyline given 4 3D points
(defun DrawPlotPoly (p1 p2 p3 p4 lyr)
  (entmake
    (list
      '(0 . "LWPOLYLINE")
      '(100 . "AcDbEntity")
      (cons 8 lyr)
      '(100 . "AcDbPolyline")
      '(90 . 4)
      '(70 . 1) ;; Closed
      (cons 10 (list (car p1) (cadr p1)))
      (cons 10 (list (car p2) (cadr p2)))
      (cons 10 (list (car p3) (cadr p3)))
      (cons 10 (list (car p4) (cadr p4)))
    )
  )
)

;;; AddPlotText
;;; Calculates centroid and adds text aligned to the radial center
(defun AddPlotText (p1 p2 p3 p4 str lyr / cenX cenY cenPt ang)
  ;; Geometric center (average of vertices)
  (setq cenX (/ (+ (car p1) (car p2) (car p3) (car p4)) 4.0))
  (setq cenY (/ (+ (cadr p1) (cadr p2) (cadr p3) (cadr p4)) 4.0))
  (setq cenPt (list cenX cenY 0.0))

  ;; Calculate angle perpendicular to the "front" chord (p1-p2)
  ;; Angle of chord
  (setq ang (angle p1 p2))
  ;; Perpendicular is +90 degrees? Or align with radial line?
  ;; Usually text aligns with the "depth" line or simply horizontal (0) 
  ;; or parallel to the chord (ang).
  ;; Let's align parallel to the chord for readability along the curve.
  (if (and (> ang (/ pi 2)) (<= ang (* 1.5 pi)))
    (setq ang (+ ang pi)) ;; Flip text if upside down
  )

  (entmake
    (list
      '(0 . "TEXT")
      '(100 . "AcDbEntity")
      (cons 8 lyr)
      '(100 . "AcDbText")
      (cons 10 cenPt)
      '(40 . 2.5)         ;; Text Height (Adjustable or could be an input)
      (cons 1 str)
      (cons 50 ang)       ;; Rotation
      '(72 . 4)           ;; Middle Center justification
      (cons 11 cenPt)     ;; Alignment point (required for 72=4)
    )
  )
)

;;; LM:UnitVector (Lee Mac)
;;; Returns the unit vector of a supplied vector
(defun LM:UnitVector ( v / d )
    (if (and v (/= 0.0 (setq d (distance '(0.0 0.0 0.0) v))))
        (mapcar '/ v (list d d d))
    )
)

(princ "\nRADIAL_BLOCK command loaded. Type RADIAL_BLOCK to run.")
(princ)