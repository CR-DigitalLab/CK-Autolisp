(defun c:AUTODIM ( / ent ent_data vlist p1 p2 p3 p4 d1 d2 len wid ang center txt textHeight offsetDist oldDimTxt oldOsnap)
  (vl-load-com)
  
  ;; 1. Select the Polyline
  (setq ent (car (entsel "\nSelect angled rectangle: ")))
  (if (not ent) (progn (princ "\nNothing selected.") (exit)))
  
  (setq ent_data (entget ent))
  (if (/= (cdr (assoc 0 ent_data)) "LWPOLYLINE")
    (progn (princ "\nPlease select a standard Polyline.") (exit))
  )
  
  ;; 2. Extract Exact Coordinates
  (setq vlist (mapcar 'cdr (vl-remove-if-not '(lambda (x) (= (car x) 10)) ent_data)))
  (if (< (length vlist) 4)
    (progn (princ "\nShape needs at least 4 corners.") (exit))
  )
  
  (setq p1 (nth 0 vlist)
        p2 (nth 1 vlist)
        p3 (nth 2 vlist)
        p4 (nth 3 vlist))
        
  ;; 3. Calculate True Length and Width
  (setq d1 (distance p1 p2)
        d2 (distance p2 p3))
        
  (if (> d1 d2)
    (setq len d1 wid d2 ang (angle p1 p2))
    (setq len d2 wid d1 ang (angle p2 p3))
  )
  
  ;; Keep text readable (upright)
  (if (and (> ang (/ pi 2)) (<= ang (* pi 1.5)))
    (setq ang (- ang pi))
  )
  
  ;; 4. Calculate Center Point & Text
  (setq center (list (/ (+ (car p1) (car p3)) 2.0) (/ (+ (cadr p1) (cadr p3)) 2.0) 0.0))
  (setq txt (strcat (rtos len 2 2) "x" (rtos wid 2 2) "m"))
  
  ;; 5. User Inputs for Size and Placement
  (setq textHeight (getreal "\nEnter Font Size for Text & Dimensions <2.0>: "))
  (if (not textHeight) (setq textHeight 2.0))
  
  (setq offsetDist (getreal "\nEnter Dimension Offset Distance <3.0>: "))
  (if (not offsetDist) (setq offsetDist 3.0))
  
  ;; Save user's original settings
  (setq oldDimTxt (getvar "DIMTXT"))
  (setq oldOsnap (getvar "OSMODE"))
  
  ;; Apply new settings temporarily
  (setvar "DIMTXT" textHeight)
  (setvar "OSMODE" 0) 
  
  ;; 6. Generate Center Text
  (entmake (list '(0 . "TEXT")
                 (cons 10 center)
                 (cons 11 center)
                 '(72 . 1) 
                 '(73 . 2) 
                 (cons 40 textHeight)
                 (cons 1 txt)
                 (cons 50 ang)))
                 
  ;; 7. Draw Aligned Dimensions
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
  
  ;; 8. Restore original settings
  (setvar "DIMTXT" oldDimTxt)
  (setvar "OSMODE" oldOsnap)
  
  (princ "\nPlot labeled and dimensioned successfully!")
  (princ)
)