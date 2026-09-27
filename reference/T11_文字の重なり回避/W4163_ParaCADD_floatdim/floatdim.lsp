;;;Modify dimension properties to Move text and add a leader
;;;
;;;	Author: Henry C. Francis
;;;		425 N. Ashe St.
;;;		Southern Pines, NC 28387
;;;
;;;	http://www.paracadd.com
;;;	All rights reserved.
;;;
;;;	Copyright: 4/2012
;;;	   Edited: 4/2012
;;;
(defun C:FLOATDIM ()
  (vl-load-com)
  (setq selected-dimension (entsel))
  (if (and selected-dimension
           (eq (cdr (assoc 0 (entget (car selected-dimension)))) "DIMENSION")
      ) ;_ end of AND
    (progn
      (setq dimobj (vlax-ename->vla-object (car selected-dimension)))
      (vlax-put-property dimobj 'ExtLine2Suppress 0)
      (vlax-put-property dimobj 'TextMovement 1)
    ) ;_ end of PROGN
    (progn
      (princ "\nNO DIMENSION WAS SELECTED! ")
      (princ)
    ) ;_ end of PROGN
  ) ;_ end of IF
  (princ)
) ;_ end of DEFUN
(DEFUN C:DIMFLOAT () (C:FLOATDIM))
(PRINC)
;|«Visual LISP© Format Options»
(120 2 15 2 T "end of " 100 9 0 0 nil nil T nil T)
;*** DO NOT add text below the comment! ***|;
