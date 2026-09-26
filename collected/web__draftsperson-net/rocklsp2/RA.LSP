    ;  Redraw timer
    ;  Copyright 1990   Rocket Software
    ;  Almost identical to ZP & ZA,
    ;  but now you don't have to write it
    ;  (or think of it).
  (DEFUN C:RA ( / s t1 t2)
     (setvar "cmdecho" 0)
     (setq s (getvar "date"))
     (setq t1 (* 86400.0 (- s (fix s))))
     (command "redraw")
     (setq s (getvar "date"))
     (setq t2 (* 86400.0 (- s (fix s))))
     (write-line (strcat "Redraw time: " (rtos (- t2 t1) 2 1) " seconds."))
    (PRINC))
