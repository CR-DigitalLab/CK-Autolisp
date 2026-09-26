;;; ==========================================================================
;;; RADIAL_BLOCK_V2.lsp
;;; --------------------------------------------------------------------------
;;; Description:
;;;   Automates the generation of radial/wedge-shaped residential plots along
;;;   an existing Arc or 2D Polyline.
;;;   FEATURES:
;;;   - Matches exact curvature and intermediate vertices of the road.
;;;   - Creates concentric back-lines (Wedge shape).
;;;   - Calculates centroids for text numbering.
;;; ==========================================================================

(defun c:RADIAL_BLOCK ( / *error* adoc spc sel ent curveObj align width depth count 
                          curveLen sidePt sideVec i distStart distEnd distMid
                          pt1 pt2 ptMid bulge deriv1 deriv2 norm1 norm2 
                          p3 p4 p3_opp p4_opp plotNum
                          old_osmode old_cmdecho layer_bdry layer_text
                          entType paramStart paramEnd frontData)

  ;; 1. INITIALIZATION & SAFETY
  ;; ------------------------------------------------------------------------
  (vl-load-com)
  (setq adoc (vla-get-activedocument (vlax-get-acad-object)))
  (setq spc  (vla-get-modelspace adoc))

  (setq old_osmode  (getvar "OSMODE"))
  (setq old_cmdecho (getvar "CMDECHO"))

  (defun *error* (msg)
    (if old_osmode (setvar "OSMODE" old_osmode))
    (if old_cmdecho (setvar "CMDECHO" old_cmdecho))
    (vla-EndUndoMark adoc)
    (if (and msg (not (wcmatch (strcase msg) "*BREAK*,*CANCEL*,*EXIT*")))
      (princ (strcat "\nError: " msg))
    )
    (princ)
  )

  (vla-StartUndoMark adoc)
  (setvar "CMDECHO" 0)

  ;; 2. LAYER SETUP
  ;; ------------------------------------------------------------------------
  (setq layer_bdry "PLOT-BOUNDARY")
  (setq layer_text "PLOT-TEXT")

  (if (not (tblsearch "LAYER" layer_bdry))
    (entmake (list '(0 . "LAYER") '(100 . "AcDbSymbolTableRecord") '(100 . "AcDbLayerTableRecord")
                   (cons 2 layer_bdry) '(70 . 0) '(62 . 2)))
  )
  (if (not (tblsearch "LAYER" layer_text))
    (entmake (list '(0 . "LAYER") '(100 . "AcDbSymbolTableRecord") '(100 . "AcDbLayerTableRecord")
                   (cons 2 layer_text) '(70 . 0) '(62 . 3)))
  )

  ;; 3. USER INPUTS
  ;; ------------------------------------------------------------------------
  (princ "\n--- Radial Plot Generator (Exact Contour) ---")
  
  (while (not (and (setq sel (entsel "\nSelect Alignment Curve (Arc or Polyline): "))
                   (wcmatch (cdr (assoc 0 (entget (car sel)))) "ARC,LWPOLYLINE,POLYLINE,SPLINE")))
    (princ "\nInvalid object. Please select an ARC or POLYLINE.")
  )
  (setq ent (car sel))
  (setq curveObj (vlax-ename->vla-object ent))
  (setq entType (cdr (assoc 0 (entget ent))))
  (setq curveLen (vlax-curve-getDistAtParam curveObj (vlax-curve-getEndParam curveObj)))

  (initget "Centerline Front Back")
  (setq align (getkword "\nSpecify Alignment [Centerline/Front/Back] <Front>: "))
  (if (null align) (setq align "Front"))

  (setq width (getdist "\nEnter Plot Frontage Width (Along Curve): "))
  (setq depth (getdist "\nEnter Plot Depth (Radial): "))
  (setq count (getint  "\nEnter Total Number of Plots: "))

  (if (> (* count width) curveLen)
    (princ (strcat "\nWarning: Total width (" (rtos (* count width) 2 2) 
                   ") exceeds curve length (" (rtos curveLen 2 2) "). Plots will be truncated."))
  )

  (setq sideVec 1.0)
  (if (or (= align "Front") (= align "Back"))
    (progn
      (setq sidePt (getpoint "\nClick on the side of the curve to place the plots: "))
      (if sidePt
        (progn
          (setq pt1 (vlax-curve-getPointAtDist curveObj 0.0))
          (setq deriv1 (vlax-curve-getFirstDeriv curveObj 0.0))
          (setq norm1 (list (- (cadr deriv1)) (car deriv1) 0.0))
          (setq pickVec (mapcar '- sidePt pt1))
          (setq dotProd (+ (* (car norm1) (car pickVec)) (* (cadr norm1) (cadr pickVec))))
          (if (< dotProd 0) (setq sideVec -1.0) (setq sideVec 1.0))
        )
      )
    )
  )

  ;; 4. GEOMETRY GENERATION
  ;; ------------------------------------------------------------------------
  (setvar "OSMODE" 0)
  (setq i 0 plotNum 1)

  (while (< i count)
    (setq distStart (* i width))
    (setq distEnd   (* (+ i 1) width))
    (setq distMid   (/ (+ distStart distEnd) 2.0))

    (if (> distEnd curveLen)
      (setq i count)
      (progn
        (setq pt1 (vlax-curve-getPointAtDist curveObj distStart))
        (setq pt2 (vlax-curve-getPointAtDist curveObj distEnd))
        (setq ptMid (vlax-curve-getPointAtDist curveObj distMid))

        ;; Calculate general bulge for the back curve offset
        (setq bulge (CalcBulge pt1 ptMid pt2))

        ;; NEW: Extract exact frontage vertices if the alignment is a polyline
        (setq paramStart (vlax-curve-getParamAtDist curveObj distStart))
        (setq paramEnd   (vlax-curve-getParamAtDist curveObj distEnd))
        
        (if (wcmatch entType "*POLYLINE")
          (setq frontData (GetFrontageData curveObj paramStart paramEnd))
          (setq frontData (list (cons pt1 bulge))) ;; Fallback for native Arcs/Lines
        )

        (setq deriv1 (vlax-curve-getFirstDeriv curveObj paramStart))
        (setq deriv2 (vlax-curve-getFirstDeriv curveObj paramEnd))
        (setq norm1 (LM:UnitVector (list (- (cadr deriv1)) (car deriv1) 0.0)))
        (setq norm2 (LM:UnitVector (list (- (cadr deriv2)) (car deriv2) 0.0)))

        ;; Centerline Mode
        (if (= align "Centerline")
          (progn
            ;; Side A 
            (setq p3 (mapcar '+ pt2 (mapcar '* norm2 (list depth depth depth))))
            (setq p4 (mapcar '+ pt1 (mapcar '* norm1 (list depth depth depth))))
            (DrawPlotPoly frontData pt2 p3 p4 bulge layer_bdry)
            (AddPlotText pt1 pt2 p3 p4 (strcat "P-" (itoa plotNum)) layer_text)
            (setq plotNum (1+ plotNum))

            ;; Side B
            (setq p3_opp (mapcar '- pt2 (mapcar '* norm2 (list depth depth depth))))
            (setq p4_opp (mapcar '- pt1 (mapcar '* norm1 (list depth depth depth))))
            (DrawPlotPoly frontData pt2 p3_opp p4_opp bulge layer_bdry)
            (AddPlotText pt1 pt2 p3_opp p4_opp (strcat "P-" (itoa plotNum)) layer_text)
            (setq plotNum (1+ plotNum))
          )
        )

        ;; Front / Back Mode
        (if (or (= align "Front") (= align "Back"))
          (progn
            (setq offsetDist (* depth sideVec))
            (setq p3 (mapcar '+ pt2 (mapcar '* norm2 (list offsetDist offsetDist offsetDist))))
            (setq p4 (mapcar '+ pt1 (mapcar '* norm1 (list offsetDist offsetDist offsetDist))))
            (DrawPlotPoly frontData pt2 p3 p4 bulge layer_bdry)
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
  (princ (strcat "\nSuccessfully generated " (itoa (1- plotNum)) " exact contour plots."))
  (princ)
)

;;; ==========================================================================
;;; HELPER FUNCTIONS
;;; ==========================================================================

;;; GetFrontageData
;;; Extracts exact vertices and bulges from an LWPOLYLINE between two
;;; curve parameters.  Bulge values are read directly from the entity's
;;; DXF group-42 data so arc segments are reproduced exactly.
(defun GetFrontageData (curveObj paramStart paramEnd
                        / ent dxf verts bulges nVerts
                          iStart iEnd data segIdx rawBulge
                          scaledBulgeStart scaledBulgeEnd
                          p b startFrac endFrac)

  ;; ---- read raw DXF vertex list and bulge list from the entity ----
  (setq ent    (vlax-vla-object->ename curveObj))
  (setq dxf    (entget ent))

  ;; Collect all group-10 (vertex XY) entries in order
  (setq verts  nil)
  (foreach pair dxf
    (if (= (car pair) 10)
      (setq verts (append verts (list (cdr pair))))
    )
  )

  ;; Collect all group-42 (bulge) entries in order.
  ;; A missing group-42 between two vertices means bulge = 0.
  ;; We build a parallel list the same length as verts.
  (setq bulges nil)
  (setq nVerts (length verts))
  (foreach pair dxf
    (if (= (car pair) 42)
      (setq bulges (append bulges (list (cdr pair))))
    )
  )
  ;; Pad with zeros if some vertices had no bulge group
  (while (< (length bulges) nVerts)
    (setq bulges (append bulges '(0.0)))
  )

  ;; ---- map curve parameters to vertex indices ----
  ;; For LWPOLYLINE the param of vertex i is exactly (float i)
  (setq iStart (fix paramStart))   ; integer index of segment containing paramStart
  (setq iEnd   (fix paramEnd))     ; integer index of segment containing paramEnd

  ;; ---- build output list: (point . bulge) for each segment ----
  (setq data nil)
  (setq segIdx iStart)

  (while (<= segIdx iEnd)
    (setq p        (vlax-curve-getPointAtParam curveObj
                     (max paramStart (float segIdx))))
    (setq rawBulge (nth segIdx bulges))
    (if (null rawBulge) (setq rawBulge 0.0))

    ;; If paramStart falls inside a segment we must scale the bulge
    ;; of that segment to cover only the sub-arc we actually want.
    ;; We also stop at paramEnd if it falls inside the last segment.
    (cond
      ;; First segment AND paramStart is not at the vertex boundary
      ((and (= segIdx iStart) (> paramStart (float iStart)))
       (setq startFrac (- paramStart (float iStart)))
       (if (= segIdx iEnd)
         ;; wholly inside one segment
         (setq b (* rawBulge (- paramEnd paramStart)))
         (setq b (* rawBulge (- 1.0 startFrac)))
       )
      )
      ;; Last segment AND paramEnd is not at the vertex boundary
      ((and (= segIdx iEnd) (< paramEnd (float (1+ iEnd))))
       (setq endFrac (- paramEnd (float iEnd)))
       (setq b (* rawBulge endFrac))
      )
      ;; Full segment
      (t (setq b rawBulge))
    )

    (setq data (append data (list (cons p b))))
    (setq segIdx (1+ segIdx))
  )
  data
)

;;; CalcBulge
;;; Computes the standard DXF polyline bulge = tan(included_angle / 4)
;;; for three points (start, midArc, end) on a circular arc.
;;; Used only for native Arc entities; polylines read bulge directly.
(defun CalcBulge (p1 pMid p2 / chord sagitta midChordPt crossProd R theta _x _x2)
  (setq chord (distance p1 p2))
  (if (equal chord 0.0 1e-6)
    0.0
    (progn
      (setq midChordPt (mapcar '(lambda (a b) (/ (+ a b) 2.0)) p1 p2))
      (setq sagitta    (distance midChordPt pMid))
      (setq crossProd  (- (* (- (car  p2) (car  p1)) (- (cadr pMid) (cadr p1)))
                          (* (- (cadr p2) (cadr p1)) (- (car  pMid) (car  p1)))))
      (if (equal sagitta 0.0 1e-9)
        0.0   ; straight segment
        (progn
          ;; Radius from sagitta-chord relationship: R = (c²/4 + s²) / (2s)
          (setq R     (/ (+ (* chord chord 0.25) (* sagitta sagitta))
                         (* 2.0 sagitta)))
          ;; Included angle: sin(theta/2) = (chord/2) / R
          ;; AutoLISP has no asin; use identity: asin(x) = atan(x, sqrt(1-x^2))
          (setq _x  (min 1.0 (/ (* chord 0.5) R)))
          (setq _x2 (* _x _x))
          (setq theta
            (* 2.0
               (if (>= _x2 1.0)
                 (/ pi 2.0)
                 (atan _x (sqrt (- 1.0 _x2)))
               )
            )
          )
          ;; DXF bulge = tan(theta/4); sign follows cross-product
          (if (< crossProd 0)
            (* -1.0 (tan (/ theta 4.0)))
            (tan (/ theta 4.0))
          )
        )
      )
    )
  )
)

;;; UPDATED: DrawPlotPoly
;;; Rebuilds the boundary by stepping through the exact frontage data, ensuring zero gaps.
(defun DrawPlotPoly (frontData p2 p3 p4 backBulge lyr / entList)
  (setq entList
    (list
      '(0 . "LWPOLYLINE")
      '(100 . "AcDbEntity")
      (cons 8 lyr)
      '(100 . "AcDbPolyline")
      ;; Vertex count: all frontData start-points  +  p2  +  p3  +  p4
      (cons 90 (+ 3 (length frontData)))
      '(70 . 1) ;; Closed
    )
  )
  ;; Append all front vertices tracing the exact polyline segments
  (foreach item frontData
    (setq entList (append entList (list (cons 10 (list (car (car item)) (cadr (car item)))))))
    (setq entList (append entList (list (cons 42 (cdr item)))))
  )
  ;; Vertex 2 (End of front curve)
  (setq entList (append entList (list (cons 10 (list (car p2) (cadr p2))) '(42 . 0.0))))
  ;; Vertex 3 (Back/Offset corner)
  (setq entList (append entList (list (cons 10 (list (car p3) (cadr p3))) (cons 42 (* -1.0 backBulge)))))
  ;; Vertex 4 (Back/Offset corner)
  (setq entList (append entList (list (cons 10 (list (car p4) (cadr p4))) '(42 . 0.0))))
  
  (entmake entList)
)

;;; AddPlotText
(defun AddPlotText (p1 p2 p3 p4 str lyr / cenX cenY cenPt ang)
  (setq cenX (/ (+ (car p1) (car p2) (car p3) (car p4)) 4.0))
  (setq cenY (/ (+ (cadr p1) (cadr p2) (cadr p3) (cadr p4)) 4.0))
  (setq cenPt (list cenX cenY 0.0))
  (setq ang (angle p1 p2))
  (if (and (> ang (/ pi 2)) (<= ang (* 1.5 pi)))
    (setq ang (+ ang pi))
  )
  (entmake
    (list
      '(0 . "TEXT")
      '(100 . "AcDbEntity")
      (cons 8 lyr)
      '(100 . "AcDbText")
      (cons 10 cenPt)
      '(40 . 2.5)         
      (cons 1 str)
      (cons 50 ang)       
      '(72 . 4)           
      (cons 11 cenPt)     
    )
  )
)

;;; LM:UnitVector 
(defun LM:UnitVector ( v / d )
    (if (and v (/= 0.0 (setq d (distance '(0.0 0.0 0.0) v))))
        (mapcar '/ v (list d d d))
    )
)

(princ "\nRADIAL_BLOCK command loaded. Type RADIAL_BLOCK to run.")
(princ)