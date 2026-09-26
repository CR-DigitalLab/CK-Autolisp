     ;  Random Number Generator for AutoCad
     ;   Copyright 1990   Rocket Software
     ;    For those drawings where precision is not an issue.
  (DEFUN C:RAN (/ s t1)
     (command "setvar" "cmdecho" "0")
     (setq s (* (getvar "cdate") 1000000.0))
     (setq t1 (fix (* 100 (- s ( fix s)))))
     (write-line (strcat "Your number is: " (itoa t1)))
  (princ))
