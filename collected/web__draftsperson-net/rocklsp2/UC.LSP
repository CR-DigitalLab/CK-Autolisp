   ;   Change text to upper case
   ;   Copyright 1990   Rocket Software
   ;   Look for a key marked "Caps Lock".
 (defun C:UC (/ nn zz cc)
   (setvar "cmdecho" 0)
   (setq nn (entget (car (entsel "Pick text:"))))         ; select object
   (if (= "TEXT" (cdr (assoc 0 nn)))                      ; Is entity text?
       (progn
             (setq zz (cdr (assoc 1. nn)))                ; get text string
             (setq cc (strcase zz))                       ; capitalise it
             (entmod (subst (cons 1 cc) (cons 1 zz) nn))) ; replace & update
       (write-line "\nI said TEXT."))
   (PRINC))