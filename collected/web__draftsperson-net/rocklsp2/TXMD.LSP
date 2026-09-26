   ;  Text Change To (Metric) Date 
   ;  Copyright 1990   Rocket Software
   ;  When you can't remember what day it is...
 (defun C:TXMD ( / dd yy mm da mlst ss lll zz)
   (setvar "cmdecho" 0)
   (grtext -2 "AAAAARGH")
   (setq ss (car (entsel "Select text:")))
   (if ss
      (progn
            (setq lll (entget ss))
            (setq zz (assoc 1. lll))
            (setq dd (rtos (fix (getvar "cdate"))))
            (setq yy (substr dd 3 2) mm (substr dd 5 2) da (substr dd 7 2))
            (setq dd (strcat yy "/" mm "/" da))
            (entmod (subst (cons 1 dd) zz lll))))
   (princ))