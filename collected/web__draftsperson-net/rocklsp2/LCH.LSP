  ;  Move entities to another layer by selecting an object thereon.
  ;  Copyright 1990   Rocket Software
  ;  Why are you reading this?  Don't you have work to do?
 (DEFUN C:LCH ( / tt zz ss num aa obj xx)
   (setvar "cmdecho" 0)
   (command "undo" "mark")
   (write-line "Pick objects to move:")
   (setq ss (ssget))
   (if (setq tt (entsel "Select an entity on the desired layer: \n"))
       (progn
             (setq zz (assoc 8 (entget (car tt))))
             (setq num 0)
             (while (setq aa (ssname SS 0))
                    (setq obj (entget aa))
                    (setq xx (assoc 8 obj))
                    (entmod (subst zz xx obj))
                    (ssdel aa ss)
                    (setq num (1+ num)))
             (if (= num 1)
                 (setq tt " item ") (setq tt " artifacts "))
             (write-line (strcat (itoa num) tt 
                         "moved from layer " (cdr xx) " to layer " (cdr zz)))
             (setq ss nil))
       (write-line "No entities selected"))
 (PRINC))