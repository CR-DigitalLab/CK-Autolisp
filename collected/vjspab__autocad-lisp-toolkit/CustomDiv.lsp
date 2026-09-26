;;; Command: CUSTOMDIV
;;; Description: Divides an arc or polyline into custom sequential lengths.
;;; Places a POINT object at each specified distance along the curve.

(defun c:CUSTOMDIV ( / ent obj curDist maxDist val pt oldPdmode)
  (vl-load-com)
  
  (setvar "CMDECHO" 0)
  
  ;; Make sure points are visible on screen (Crosshair style)
  (setq oldPdmode (getvar "PDMODE"))
  (if (or (= oldPdmode 0) (= oldPdmode 1)) (setvar "PDMODE" 3))

  ;; Prompt to select the curve
  (setq ent (car (entsel "\nSelect the Arc or Polyline to divide: ")))
  
  (if ent
    (progn
      (setq obj (vlax-ename->vla-object ent))
      
      ;; Get total length of the curve
      (setq maxDist (vlax-catch-all-apply 'vlax-curve-getDistAtParam (list obj (vlax-curve-getEndParam obj))))
      
      (if (vl-catch-all-error-p maxDist)
        (princ "\nInvalid object selected. Must be a curve, arc, or polyline.")
        (progn
          (setq curDist 0.0)
          (princ (strcat "\nTotal curve length is: " (rtos maxDist 2 3) "m"))
          
          ;; Loop to ask for sequential lengths
          (while (setq val (getreal (strcat "\nEnter segment length (Remaining: " (rtos (- maxDist curDist) 2 3) "m) [Press Enter to stop]: ")))
            (setq curDist (+ curDist val))
            
            ;; Add a tiny tolerance (0.001) for floating point precision on the final segment
            (if (<= curDist (+ maxDist 0.001))
              (progn
                ;; Calculate the point exactly at the specified arc distance
                (setq pt (vlax-curve-getPointAtDist obj curDist))
                (if pt
                  ;; Create a POINT object at the calculated coordinate
                  (entmakex (list '(0 . "POINT") (cons 10 pt)))
                  (princ "\nError calculating point.")
                )
              )
              (progn
                (princ "\nDistance exceeds remaining curve length! Stopping.")
                (setq curDist (- curDist val)) ; Step back if they entered a number too large
              )
            )
          )
        )
      )
    )
    (princ "\nNo object selected.")
  )
  
  (setvar "CMDECHO" 1)
  (princ "\n--- CUSTOMDIV command finished. ---")
  (princ)
)

(princ "\n--- Custom Divide LISP loaded. ---")
(princ "\n--- Type 'CUSTOMDIV' to execute the command. ---")
(princ)