(vl-load-com)

(defun c:PlotNum ( / ss prefix startNum txtHeight i ent obj polyList guideLine ptDataList minPt maxPt centerPt closestPt dist sortedList count numStr pt textStr oldCmd)
  
  ;; Get User Inputs
  (setq prefix (getstring "\nEnter the alphabetic prefix for the plots (e.g., L): "))
  (setq startNum (getint "\nEnter the starting number (e.g., 1): "))
  (setq txtHeight (getdist "\nSpecify Text Height: "))
  
  (princ "\nSelect ALL the closed polygons AND your single open sequence polyline together: ")
  (if (and prefix startNum txtHeight (setq ss (ssget '((0 . "LWPOLYLINE,POLYLINE")))))
    (progn
      ;; Save settings
      (setq oldCmd (getvar "CMDECHO"))
      (setvar "CMDECHO" 0)
      
      (setq i 0)
      (setq polyList nil)
      (setq guideLine nil)

      ;; 1. Separate the guide line (open) from the plots (closed)
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (setq obj (vlax-ename->vla-object ent))
        
        (if (vlax-curve-isClosed obj)
          (setq polyList (cons obj polyList)) ; It is closed, so it's a plot
          (progn
            (if guideLine (princ "\nWarning: Multiple open lines selected. Using the most recent one as the guide."))
            (setq guideLine obj) ; It is open, so it's the sequence guide line
          )
        )
        (setq i (1+ i))
      )

      ;; 2. Verify we have both a guide line and plots
      (if (and guideLine polyList)
        (progn
          (setq ptDataList nil)
          
          ;; 3. Calculate distance along the guide line for each plot
          (foreach polyObj polyList
            ;; Get Bounding Box to find the center of the plot
            (vla-GetBoundingBox polyObj 'minPt 'maxPt)
            (setq minPt (vlax-safearray->list minPt))
            (setq maxPt (vlax-safearray->list maxPt))
            
            ;; Calculate Center Point (X, Y)
            (setq centerPt (list (/ (+ (car minPt) (car maxPt)) 2.0)
                                 (/ (+ (cadr minPt) (cadr maxPt)) 2.0)
                                 0.0))
            
            ;; Find the closest point on the guide line to the plot's center
            (setq closestPt (vlax-curve-getClosestPointTo guideLine centerPt))
            
            ;; Find how far along the guide line that closest point is
            (setq dist (vlax-curve-getDistAtPoint guideLine closestPt))
            
            ;; Store the distance and the center point
            (setq ptDataList (cons (list dist centerPt) ptDataList))
          )

          ;; 4. Sort the list based on the distance along the guide line (ascending)
          (setq sortedList (vl-sort ptDataList '(lambda (a b) (< (car a) (car b)))))

          ;; 5. Generate the Text in Sequence
          (setq count startNum)
          (foreach item sortedList
            (setq pt (cadr item)) ; The center point we stored
            
            ;; Format the number string with leading zero (e.g., "01", "02", "10")
            (if (< count 10)
              (setq numStr (strcat "0" (itoa count)))
              (setq numStr (itoa count))
            )
            
            ;; Combine to format: L01, L15, etc.
            (setq textStr (strcat prefix numStr))
            
            ;; Create Text Entity centered in the polygon
            (entmake (list '(0 . "TEXT")
                           (cons 10 pt)               ; First alignment point
                           (cons 11 pt)               ; Second alignment point
                           (cons 40 txtHeight)        ; Text Height
                           (cons 1 textStr)           ; Text String
                           '(72 . 1)                  ; Horizontal Justification: Center
                           '(73 . 2)                  ; Vertical Justification: Middle
                     )
            )
            (setq count (1+ count))
          )
          
          (princ (strcat "\nSuccess: Sequenced " (itoa (length polyList)) " plots based on the guide line."))
        )
        (princ "\nError: You must select at least one CLOSED polygon and EXACTLY ONE OPEN polyline to act as the sequence guide.")
      )
      (setvar "CMDECHO" oldCmd)
    )
    (princ "\nCommand cancelled or missing input.")
  )
  (princ)
)

(princ "\nType 'PlotNum' to load and run the path sequence numbering command.")
(princ)