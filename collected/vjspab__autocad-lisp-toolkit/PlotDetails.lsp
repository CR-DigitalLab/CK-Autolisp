(defun c:PLOTDETAILS ( / ent ent_data obj vlist p1 p2 p3 p4 d1 d2 len wid ang center area txt textHeight offsetDist oldOsnap draw-dim)
  (vl-load-com)
  
  ;; 1. Select the Polyline
  (setq ent (car (entsel "\nSelect a rectangular plot (closed polyline): ")))
  (if (not ent) (progn (princ "\nNo object selected.") (exit)))
  
  (setq ent_data (entget ent))
  (if (/= (cdr (assoc 0 ent_data)) "LWPOLYLINE")
    (progn (princ "\nPlease select a Polyline.") (exit))
  )
  
  (setq obj (vlax-ename->vla-object ent))
  
  ;; 2. Calculate the Exact Area
  (setq area (vla-get-area obj))
  
  ;; 3. Extract Coordinates for Dimensions
  (setq vlist (mapcar 'cdr (vl-remove-if-not '(lambda (x) (= (car x) 10)) ent_data)))
  (if (< (length vlist) 4)
    (progn (princ "\nShape needs at least 4 corners to determine length and breadth.") (exit))
  )
  
  (setq p1 (nth 0 vlist)
        p2 (nth 1 vlist)
        p3 (nth 2 vlist)
        p4 (nth 3 vlist))
        
  ;; 4. Calculate True Length, Breadth, and Angle
  (setq d1 (distance p1 p2)
        d2 (distance p2 p3))
        
  (if (> d1 d2)
    (setq len d1 wid d2 ang (angle p1 p2))
    (setq len d2 wid d1 ang (angle p2 p3))
  )
  
  ;; Keep text upright and readable
  (if (and (> ang (/ pi 2)) (<= ang (* pi 1.5)))
    (setq ang (- ang pi))
  )
  
  ;; 5. Calculate Center Point & Format Area Text
  (setq center (list (/ (+ (car p1) (car p3)) 2.0) (/ (+ (cadr p1) (cadr p3)) 2.0) 0.0))
  (setq txt (strcat "Area: " (rtos area 2 2) " sq.m"))
  
  ;; 6. AUTOMATIC SIZING: Read system variables (No Prompts)
  ;; Get current dimension text height
  (setq textHeight (getvar "DIMTXT"))
  ;; Failsafe just in case text height is set to 0 in style
  (if (<= textHeight 0.0) (setq textHeight 2.0)) 
  
  ;; Set the dimension line offset proportionally to the text height (1.5x)
  (setq offsetDist (* textHeight 1.5))
  
  ;; Save user's original settings
  (setq oldOsnap (getvar "OSMODE"))
  
  ;; Apply new settings temporarily (Turn off snaps)
  (setvar "OSMODE" 0) 
  
  ;; 7. Generate Centered Area Text Inside Polygon
  (entmake (list '(0 . "TEXT")
                 (cons 10 center)
                 (cons 11 center)
                 '(72 . 1) 
                 '(73 . 2) 
                 (cons 40 textHeight)
                 (cons 1 txt)
                 (cons 50 ang)))
                 
  ;; 8. Draw Aligned Dimensions Around the Outside
  (defun draw-dim (ptA ptB / mid angCenter dimPt)
    (setq mid (list (/ (+ (car ptA) (car ptB)) 2.0) (/ (+ (cadr ptA) (cadr ptB)) 2.0) 0.0))
    (setq angCenter (angle center mid))
    (setq dimPt (polar mid angCenter offsetDist))
    (command "_DIMALIGNED" ptA ptB dimPt)
  )
  
  (draw-dim p1 p2)
  (draw-dim p2 p3)
  (draw-dim p3 p4)
  (draw-dim p4 p1)
  
  ;; 9. Restore original settings
  (setvar "OSMODE" oldOsnap)
  
  (princ "\nPlot area and dimensions calculated successfully!")
  (princ)
)