 ; Igglesden hole inserter
 ; by SW for Rocket Software  1991
 ; Inserts a circle on a line and trims the line from inside.
 ; If you need to cut more than 1 line (i.e. at an intersection)
 ; then place another "pa" after the one in the 2nd last line.
 (defun C:IHI ( / pa)
  (setvar "cmdecho" 0)
  (setq pa (getpoint "\nInsertion point:"))
  (command "circle" pa "2")
  (command "trim" "last" "" pa "")
 (PRINC)) 


