(defun c:bacres(/ o1 a1 ostyle p1)
  (setvar "cmdecho" 0)
  (setq olayer (getvar "clayer"))
  (setq ostyle (getvar "textstyle"))
  
  (command "undo" "group")

;;;                                                   ;;;
;;; program to draw a boundary and label its acres....;;;
;;;                                                   ;;;
  
 (princ "\nProgram to label Acreage by picking inside the boundary: ")
 (setq p1 (getpoint "Pick inside boundary at label location:"))
 (command "-layer" "m" "boundary" "Plot" "no" "boundary" "color" "2" "boundary" "")
  
 (command "style" "dyplain" "romans" "" "" "" "" "" "")
 
	
 (command "-boundary" p1 "")
	
 (command "area" "ob" "last")
	
	(setq a1 (getvar "area"))
	(setq a1 (cvunit a1 "sq ft" "acres"))
	(princ (strcat "\n   Acres = " (rtos a1 2 3)))
	(command "text" "j" "m" p1 (* 0.25 (getvar "dimscale")) 0 (strcat "Acres = " (rtos a1 2 3)))
		 
	(command "undo" "end")
	
  (setvar "textstyle" ostyle)
  (setvar "clayer" olayer)
  (setvar "cmdecho" 1)
  (princ)
  
  )