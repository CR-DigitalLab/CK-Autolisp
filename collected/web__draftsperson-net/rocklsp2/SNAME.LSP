  ; Place the drawing name in the upper screen menu box.
  ; By SW for Rocket Software  Copyright 1991
  ; The powers that be will probably make this automatic sooner or later...
  (DEFUN C:SNAME (/ len name)
   (if (> (setq len (strlen (setq name (getvar "dwgname")))) 8)
       (setq name (substr name (- len 7))))
   (grtext 0 name)
   (PRINC))