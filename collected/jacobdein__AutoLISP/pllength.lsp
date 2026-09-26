; ----- PLLENGTH
; Compute the length of multiple polylines
;
;   local variables
;     intCount: variable for iterating through selected entities
;     entSelection: current selected entity
;     lengthTotal: running total of polyline lengths
;     objSelection: current selected object
;     ssSelections: list of selected entities
(defun C:PLLENGTH (/ intCount entSelection lengthTotal objSelection ssSelections )
 ; prompt user to select polylines if not already selected
 (princ "\nSelect Polylines: ")
 (setq ssSelections (ssget (list (cons 0 "*polyline, circle, ellipse")))
	   lengthTotal	 0
 ) ;setq
 ; iterate through selected entities and sum their areas
 (repeat (setq intCount (sslength ssSelections))
  (setq intCount	 (1- intCount)
	entSelection (ssname ssSelections intCount)
	objSelection (vlax-ename->vla-object entSelection)
  ) ;setq
  (setq lengthTotal (+ lengthTotal (vla-get-length objSelection)))
 ) ;repeat
 ; print the total area
 (princ "\n")
 (princ lengthTotal)
 (princ " units")
 (princ "\n")
 (princ)
) ;defun