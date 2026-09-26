   ;  Text width change
   ;  By SW for Rocket Software  Copyright 1990
   ;  Allows adjustment of the width scale factor without using fitted text
   ;  or defining a new style.  Also useful with rotated text.
 (DEFUN C:WT ( / ss cc num lll lln zz tt)
   (setvar "cmdecho" 0)
   (setq num 0)
   (prompt "Select text to change:")
   (setq ss (ssget))
   (if ss (progn
   (if (= "TEXT" (cdr (assoc 0 (entget (ssname ss 0)))))
       (setq tt (strcat "<" (rtos (cdr (assoc 41 (entget (ssname ss 0)))))
                        "> New width factor: "))
       (setq tt "New width factor: "))
   (setq cc (getreal tt))
   (if cc
       (progn
             (while (ssname ss 0)
                    (setq lll (ssname ss 0))
                    (setq lln (entget lll))
                    (if (= "TEXT" (cdr (assoc 0 LLN)))
                        (progn
                        (setq num (1+ num))
                        (setq zz (cdr (assoc 41 lln)))
                        (entmod (subst (cons 41 cc) (cons 41 zz) lln))
                    )   )
             (ssdel lll ss))))
   (prompt (strcat "Lines changed: " (itoa num)))
   (setq ss nil)
   ))
   (PRINC))