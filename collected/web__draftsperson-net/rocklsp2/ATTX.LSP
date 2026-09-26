  ;  Change text; also attributes belonging to exploded title blocks.
  ;  by SW for Rocket Software  Copyright 1991
  ;  Rocket Software - for those rare occasions when things aren't ideal.
  (defun C:ATTX (/ nn tx zz cc)
   (setvar "cmdecho" 0)
   (command "undo" "mark")
   (setq nn (entget (car (entsel "Select text to change. "))))
   (setq tx (getstring t "\nNew text:"))
   (if (/= tx "")
       (progn
             (setq zz (assoc 2 nn))
             (if zz
             (setq cc (cons 2 tx))
             (progn
                   (setq zz (assoc 1 nn))
                   (setq cc (cons 1 tx))))
             (entmod (subst cc zz nn))))
   (PRINC))