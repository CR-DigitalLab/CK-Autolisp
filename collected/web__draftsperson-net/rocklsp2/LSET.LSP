  ;  Change layer to another by selecting an object thereon.
  ;  Copyright 1990   Rocket Software
  ;  Unless, of course, you have the layer names memorized...
 (DEFUN C:LSET ( / cc xx zz)
   (setvar "cmdecho" 0)
   (setq cc (getvar "clayer"))
   (if (setq xx (entsel "\nSelect an object on desired layer: \n"))
       (progn
             (setq zz (cdr (assoc 8 (entget (car xx)))))
             (if (equal cc zz)
                 (prompt (strcat "You are already on layer " cc "."))
                 (progn
                       (command "layer" "s" ZZ "")
                       (write-line (strcat "Previous layer: " cc
                                   "  Current layer: " (getvar "clayer")))))
       )
       (prompt "An entity, not the atmosphere."))
   (princ))