  ;  Move drawing base to 0,0
  ;  Copyright 1990   Rocket Software
  ;  When those position-dependent macros don't work consistently...
  (DEFUN C:MVA (/ min max orth)
   (setvar "cmdecho" 0)
   (setq orth (getvar "orthomode"))
   (setvar "orthomode" 0)
   (command "zoom" "e")
   (setq min (getvar "extmin")
         max (getvar "extmax"))
   (command "move" "w" min max "" min "0,0")
   (setvar "orthomode" orth)
  (princ))