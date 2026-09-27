;LTR.lsp - select Line entity and Text entitiy. Rotate text based on line angle.
(defun C:LTR()
;turn off the system echo
(setvar "cmdecho" 0)
;display a message on the command line
(princ "\n Select LINE with Correct Angle.")
;let the user select one entity
(if (setq eset(entsel))
(progn
;get the entity name from the entsel command
(setq en(car eset))
;get the DXF group codes of the selected entity
(setq enlist(entget en))
;check to see if a LINE was selected
(if(= "LINE" (cdr(assoc 0 enlist)))
(progn
;display a message on the command line
(princ "\n Select TEXT to Match Line Angle.")
;let the user select one entity
(if(setq eset2(entsel))
(progn
;get the starting point of the line
(setq ept1(cdr(assoc 10 enlist)))
;get the end point of the line
(setq ept2(cdr(assoc 11 enlist)))
;get the angle from the end points of the line
(setq ang1(angle ept1 ept2))
;get the entity name from the entsel function
(setq en2(car eset2))
;get the DXF Group Codes of the entity
(setq enlist2(entget en2))
;change the angle in the text entities DXF group codes
(setq enlist2(subst (cons 50 ang1)(assoc 50 enlist2)enlist2))
;update the text entity
(entmod enlist2)
)
;if the second entity wasn't selected...
(princ "\n Select Text Entity Please. Program Aborted.")
)
)
;if the first entity wasn't a line
(princ "\n Enitity selected was not a LINE. Program Aborted.")
)
)
;if the first entity wasn't selected
(princ "\n Nothing selected. Program Aborted.")
)
;reset the system echo
(setvar "cmdecho" 1)
;suppress the last echo
(princ)
)
;End of Program