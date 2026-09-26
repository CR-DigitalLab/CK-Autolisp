     ;  Zoom All timer
     ;  Copyright 1990   Rocket Software
     ;  Time those glacial regens.
  (DEFUN C:ZA ( / s t1 t2 )
    (setvar "cmdecho" 0)
    (setq s (getvar "date"))
    (setq t1 (* 86400.0 (- s (fix s))))
    (command "zoom" "a")     ; Change "a" if you want a different zoom type.
    (setq s (getvar "date"))
    (setq t2 (* 86400.0 (- s (fix s))))
    (write-line (strcat "Regen time: " (rtos (- t2 t1) 2 1) " seconds."))
   (PRINC))