 ; 0/1 toggle for system variables
 ; Copyright 1991  Rocket Software
 ; 
(DEFUN C:TOGGLE (/ a b c)
 (setq a (getstring "Variable name: "))
 (setq b (getvar a))
 (setq c (abs (1- b)))
 (setvar a c)
 (write-line (strcat a " changed from " (itoa b) " to " (itoa (getvar a))))
 (princ))