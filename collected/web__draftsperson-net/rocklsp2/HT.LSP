   ;  Multiple text Height Change - also works on fixed height text.
   ;  Copyright 1990   Rocket Software
   ;  Yet another function Autodesk forgot.
 (defun C:HT ( / ss cc nn num lll lln zz tt)
   (setvar "cmdecho" 0)
   (prompt "Select text to change:")
   (setq ss (ssget))
   (if ss (progn
   (if (= "TEXT" (cdr (assoc 0 (entget (ssname ss 0)))))
       (setq tt (strcat "<" (rtos (cdr (assoc 40 (entget (ssname ss 0)))))
                        "> New height or <Return> to select: "))
       (setq tt "New Height or <Return> to select: "))
   (setq cc (getreal tt))
   (if (null cc)
       (progn
           (setq nn (entget (car (entsel "Select text of desired height:\n"))))
           (if (= "TEXT" (cdr (assoc 0 nn)))
               (setq cc (cdr (assoc 40 nn))))))
   (setq num 0)
   (if cc
       (progn
             (while (ssname ss 0)
                    (setq lll (ssname ss 0))
                    (setq lln (entget lll))
                    (if (= "TEXT" (cdr (assoc 0 LLN)))
                        (progn
                        (setq num (1+ num))
                        (setq zz (cdr (assoc 40 lln)))
                        (entmod (subst (cons 40 cc) (cons 40 zz) lln))
                    )   )
             (ssdel lll ss))))
   (prompt (strcat "Lines changed: " (itoa num)))
   (setq ss nil)
   ))
   (PRINC))