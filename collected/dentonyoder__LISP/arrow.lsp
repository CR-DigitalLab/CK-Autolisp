(defun c:arrow(/ p1 p2 arrowlength oldsnap)
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; Command to draw an arrow by Denton Yoder (c) 2016       ;;;
  ;;; Uses dimension arrow size variable and current dimscale ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  (setq p1 (getpoint "\nPick arrow point location:"))
  (setq p2 (getpoint "\nnext point:" p1))

  (setq oldsnap (getvar "osmode"))
  (setvar "osmode" 0)
  
  (setq arrowlength (* (getvar "dimscale") (getvar "dimasz")))
  (command "pline" p1 "w" "0" (/ arrowlength 3.0) (polar p1 (angle p1 p2) arrowlength) "w" 0 0)
  (while (/= p2 nil)
    (command p2)
    (setq p2 (getpoint "\nnext point:" p2))
    )
  (command "")

  (setvar "osmode" oldsnap)
  
  (princ)
  ) 
  
  (defun c:farrow(/ p1 p2 arrowlength oldsnap)
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; Command to draw an arrow by Denton Yoder (c) 2016       ;;;
  ;;; Uses dimension arrow size variable and current dimscale ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  (setq p1 (getpoint "\nPick arrow point location:"))
  (setq p2 (getpoint "\nnext point:" p1))

  (setq oldsnap (getvar "osmode"))
  (setvar "osmode" 0)
  
  (setq arrowlength (* (getvar "dimscale") (getvar "dimasz")))
  (command "pline" p1 "w" "0" arrowlength (polar p1 (angle p1 p2) arrowlength) "w" 0 0)
  (while (/= p2 nil)
    (command p2)
    (setq p2 (getpoint "\nnext point:" p2))
    )
  (command "")

  (setvar "osmode" oldsnap)
  
  (princ)
  ) 
  
  
  (defun c:sarrow(/ p1 p2 ptemp arrowlength oldsnap)
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;;; Command to draw an arrow by Denton Yoder (c) 2016       ;;;
  ;;; Uses dimension arrow size variable and current dimscale ;;;
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  (setq p1 (getpoint "\nPick arrow point location:"))
  (setq p2 (getpoint "\nnext point:" p1))

  (setq oldsnap (getvar "osmode"))
  (setvar "osmode" 0)
  
  (setq arrowlength (* (getvar "dimscale") (getvar "dimasz")))
  (setq ptemp (polar p1 (angle p1 p2) arrowlength))
  
  (command "pline" p1 "w" "0" (/ arrowlength 3.0) ptemp "w" 0 0 "")
  (command "spline" p1 ptemp)
  (while (/= p2 nil)
    (command p2)
    (setq p2 (getpoint "\nnext point:" p2))
    )
  (command "" "" "")

  (setvar "osmode" oldsnap)
  
  (princ)
  ) 