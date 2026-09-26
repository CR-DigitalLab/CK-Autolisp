    ;  Change text to lower case
    ;  Copyright 1990   Rocket Software
    ;  yOU THOUGHT cAPS lOCK WAS off?
  (defun C:LCS (/ nn zz cc)
   (setvar "cmdecho" 0)
   (setq nn (entget (car (entsel "Pick text:"))))
   (if (= "TEXT" (cdr (assoc 0 nn)))
       (progn
             (setq zz (cdr (assoc 1 nn)))
             (setq cc (strcase zz t))
             (entmod (subst (cons 1 cc) (cons 1 zz) nn)))
       (write-line "\nI said TEXT."))
   (PRINC))