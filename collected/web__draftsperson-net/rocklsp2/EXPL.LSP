  ; Make the Y and Z scale factors in a block equal to the X and explode it.
  ; Copyright 1990   Rocket Software
  ; Desperate situations call for desperate measures...
 (defun C:EXPL ( / ss num lll lln xx yy zz)
   (setvar "cmdecho" 0)
   (command "undo" "mark")
   (prompt "Select entities:")
   (setq ss (ssget))
       (setq num 0)
       (while (ssname ss 0)
              (setq lll (ssname ss 0))
              (setq lln (entget lll))
              (if (= "INSERT" (cdr (assoc 0 LLN)))
                  (progn
                        (setq num (1+ num))
                        (setq xx (cdr (assoc 41 lln)))
                        (setq yy (assoc 42 lln))
                        (setq zz (assoc 43 lln))
                        (setq lln (subst (cons 42 xx) yy lln))
                        (entmod (subst (cons 43 xx) zz lln))
                        (command "explode" lll)
              )   )
              (ssdel lll ss)
       )
   (prompt (strcat "Entities exploded: " (itoa num))) 
   (PRINC))