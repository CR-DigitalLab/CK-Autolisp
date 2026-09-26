    ;  Lottery number generator for AutoCad
    ;  Copyright 1990   Rocket Software
    ;  Of course, you might love your job...
  (DEFUN C:SIX ( / n lst nn s t2 t1)
   (command "setvar" "cmdecho" "0")
   (setq n 0)
   (setq nn (list))
   (while (< n 6) 
          (setq s (* (getvar "cdate") 10000000.0))
          (setq t1 (fix (* 10 (- s ( fix s)))))
          (setq s (* (getvar "cdate") 10000000.0))
          (setq t2 (* 10 (fix (* 10 (- s ( fix s))))))
          (setq t1 (+ t2 t1))
          (setq t1 (fix (/ t1 2)))
          (if (not (or (< t1 1) (member t1 nn)))
              (progn
                    (setq nn (append nn (list t1)))
                    (setq n (1+ n))))
   )
   (setq n 0 s 1)
   (setq lst "Your numbers are:")
   (while (< n 6)
          (if (member s nn)
              (progn
                    (setq lst (strcat lst " " (itoa s)))
                    (setq n (1+ n))))
          (setq s (1+ s)))
   (write-line lst)
   (princ))