; ----- PLAREA
; Compute the area of multiple polylines
; computes the closed area if each polyline is not already closed
;
;   local variables
;     intCount: variable for iterating through selected entities
;     entSelection: current selected entity
;     areaTotal: running total of polyline areas
;     objSelection: current selected object
;     ssSelections: list of selected entities
(defun C:PLAREA (/ intCount entSelection areaTotal objSelection ssSelections )
 ; prompt user to select polylines if not already selected
 (princ "\nSelect Polylines: ")
 (setq ssSelections (ssget (list (cons 0 "*polyline, circle, ellipse")))
	   areaTotal	 0
 ) ;setq
 ; iterate through selected entities and sum their areas
 (repeat (setq intCount (sslength ssSelections))
  (setq intCount	 (1- intCount)
	entSelection (ssname ssSelections intCount)
	objSelection (vlax-ename->vla-object entSelection)
  ) ;setq
  (setq areaTotal (+ areaTotal (vla-get-area objSelection)))
 ) ;repeat
 ; print the total area
 (princ "\n")
 (princ areaTotal)
 (princ " square units")
 (princ "\n")
 (princ)
) ;defun