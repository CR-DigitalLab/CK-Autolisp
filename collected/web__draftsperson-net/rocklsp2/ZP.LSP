     ;  Zoom Previous with timer
     ;  Copyright 1990   Rocket Software
     ;  Software to keep track of every wasted second.
  (DEFUN C:ZP ( / s t1 t2 )
     (command "setvar" "cmdecho" "0")
     (setq s (getvar "date"))
     (setq t1 (* 86400.0 (- s (fix s))))
     (command "zoom" "p")
     (setq s (getvar "date"))
     (setq t2 (* 86400.0 (- s (fix s))))
     (write-line (strcat "Zoom time: " (rtos (- t2 t1) 2 1) " seconds "))
    (PRINC))
