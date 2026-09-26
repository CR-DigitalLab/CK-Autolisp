;;; Command: PLOTDIM
;;; Description: Hybrid Area & Dimension tool. 
;;; Features: 1 decimal place, scaled outputs, and auto-layer assignment.

(defun c:PLOTDIM ( / pt ent obj isTemp area areaStr textPt explObjs p1 p2 midPt ang dimPt offsetDist txtHgt dimSc objName segName oldLW oldDIMLWD oldDIMLWE oldDIMTXT oldDIMASZ oldDIMGAP oldDIMTAD oldDIMDEC oldLayer targetLayer areaTextScale dimTextScale arrowScale textGap dimOffsetMultiplier)
  (vl-load-com)
  
  ;; --- USER SETTINGS --------------------------------------------------------
  (setq targetLayer "Plot_Dimensions") ; <-- NEW: Name of the layer for outputs
  (setq areaTextScale 1.0) ; 1.0 = standard size for the central Area text
  (setq dimTextScale 0.5)  ; 0.5 = half size for Dimension Text
  (setq arrowScale 0.2)    ; 0.5 = half size for Dimension Arrows
  (setq textGap 0.1)       ; Space between the dimension line and the text
  (setq dimOffsetMultiplier 0.1) ; Distance multiplier for the dimension lines
  ;; --------------------------------------------------------------------------

  ;; Save current settings to restore them after the script finishes
  (setq oldLW (getvar "CELWEIGHT"))
  (setq oldDIMLWD (getvar "DIMLWD"))
  (setq oldDIMLWE (getvar "DIMLWE"))
  (setq oldDIMTXT (getvar "DIMTXT"))
  (setq oldDIMASZ (getvar "DIMASZ"))
  (setq oldDIMGAP (getvar "DIMGAP")) 
  (setq oldDIMTAD (getvar "DIMTAD")) 
  (setq oldDIMDEC (getvar "DIMDEC"))
  (setq oldLayer (getvar "CLAYER")) ; Save original active layer

  ;; Create the target layer if it doesn't exist, and set it as current
  (if (not (tblsearch "LAYER" targetLayer))
    (command "_.-layer" "_M" targetLayer "")
    (setvar "CLAYER" targetLayer)
  )

  ;; Set Lineweights to 0.09mm
  (setvar "CELWEIGHT" 9) 
  (setvar "DIMLWD" 9)
  (setvar "DIMLWE" 9)
  
  ;; Apply Scales to Dimensions
  (setvar "DIMTXT" (* oldDIMTXT dimTextScale))
  (setvar "DIMASZ" (* oldDIMASZ arrowScale))
  
  ;; Fix Text Overlap & Set 1 Decimal Precision
  (setvar "DIMTAD" 1) 
  (setvar "DIMGAP" (* (getvar "DIMTXT") textGap)) 
  (setvar "DIMDEC" 1) 

  ;; Get current dimension settings for scaling
  (setq dimSc (getvar "DIMSCALE"))
  (if (= dimSc 0.0) (setq dimSc 1.0))
  
  (setq txtHgt (* (* oldDIMTXT dimSc) areaTextScale))
  (setq offsetDist (* txtHgt dimOffsetMultiplier))

  (setvar "CMDECHO" 0)

  ;; HYBRID PROMPT
  (setq pt (getpoint "\nPick internal point for intersecting lines (or press Enter to select an existing Region): "))

  (if pt
    (progn
      (command "_.-boundary" "_A" "_O" "_R" "" pt "")
      (setq ent (entlast))
      (setq isTemp T) 
    )
    (progn
      (setq ent (car (entsel "\nSelect the boundary (Region or Polyline): ")))
      (setq isTemp nil)
    )
  )

  (if ent
    (progn
      (setq obj (vlax-ename->vla-object ent))
      (setq objName (vla-get-ObjectName obj))
      
      (if (vl-position objName '("AcDbRegion" "AcDbPolyline" "AcDb2dPolyline"))
        (progn
          ;; 1. Get Exact Area mathematically
          (setq area (vl-catch-all-apply 'vla-get-Area (list obj)))
          (if (vl-catch-all-error-p area)
            (princ "\nError calculating area.")
            (progn
              ;; 2. Format Area string to 1 Decimal Place
              (setq areaStr (rtos area 2 1))

              ;; 3. Determine where to place the text
              (if pt
                (setq textPt pt) 
                (setq textPt (getpoint "\nPick point to place Area text: "))
              )

              (if textPt
                (entmakex 
                  (list 
                    '(0 . "TEXT") 
                    (cons 10 textPt) 
                    (cons 11 textPt) 
                    (cons 40 txtHgt) 
                    (cons 1 areaStr) 
                    '(72 . 1) 
                    '(73 . 2)
                    '(370 . 9) 
                    (cons 8 targetLayer) ; Assign Area Text directly to the layer
                  )
                )
              )

              ;; 4. Virtually explode the object
              (setq explObjs (vl-catch-all-apply 'vlax-invoke (list obj 'Explode)))
              
              (if (not (vl-catch-all-error-p explObjs))
                (progn
                  ;; 5. Loop through segments and draw dimensions
                  (foreach exObj explObjs
                    (setq segName (vla-get-ObjectName exObj))
                    
                    (if (or (= segName "AcDbLine") (= segName "AcDbArc"))
                      (progn
                        (setq p1 (vlax-get exObj 'StartPoint))
                        (setq p2 (vlax-get exObj 'EndPoint))

                        (if (> (distance p1 p2) 0.001)
                          (progn
                            (setq midPt (list (/ (+ (car p1) (car p2)) 2.0) (/ (+ (cadr p1) (cadr p2)) 2.0)))
                            (setq ang (angle p1 p2))
                            (setq dimPt (polar midPt (+ ang (/ pi 2.0)) offsetDist))
                            (command "_.dimaligned" "_non" p1 "_non" p2 "_non" dimPt)
                          )
                        )
                      )
                    )
                    ;; 6. Delete temporary segment
                    (vla-delete exObj)
                  )
                )
                (princ "\nError extracting boundary segments for dimensions.")
              )
            )
          )
          ;; 7. Clean up temporary boundary
          (if isTemp (vla-delete obj))
        )
        (princ "\nInvalid object. Please ensure it forms a valid Region or Polyline.")
      )
    )
    (princ "\nNo valid boundary found or selected.")
  )
  
  ;; Restore original system variables
  (setvar "CELWEIGHT" oldLW)
  (setvar "DIMLWD" oldDIMLWD)
  (setvar "DIMLWE" oldDIMLWE)
  (setvar "DIMTXT" oldDIMTXT)
  (setvar "DIMASZ" oldDIMASZ) 
  (setvar "DIMGAP" oldDIMGAP) 
  (setvar "DIMTAD" oldDIMTAD) 
  (setvar "DIMDEC" oldDIMDEC) 
  (setvar "CLAYER" oldLayer) ; Restore original active layer
  (setvar "CMDECHO" 1)
  
  (princ "\nCommand PLOTDIM ended.")
  (princ)
)

(princ "\n--- Plot Area & Auto-Layer LISP loaded. ---")
(princ "\n--- Type 'PLOTDIM' to execute the command. ---")
(princ)