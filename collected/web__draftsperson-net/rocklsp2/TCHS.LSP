   ;  Text Change Single
   ;  Copyright 1990   Rocket Software
   ;  Software that works, for people who'd rather think...
 (defun C:TCHS ( / ss cc lll zz)
     (setvar "cmdecho" 0)
     (setq ss (car (entsel "Select Text: ")))
     (setq lll (entget SS))
     (setq zz (cdr (assoc 1. lll)))
     (setq cc (getstring t (strcat "\n<" zz "> New text:")))
     (if (/= cc "")
         (entmod (subst (cons 1 cc) (cons 1 zz) lll)))
     (PRINC))