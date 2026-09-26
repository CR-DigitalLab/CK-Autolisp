  ; Make all 3 scale factors in a block equal.
  ; Copyright 1990   Rocket Software
  ; Useful if some of the lines in your drawings are really
  ; '56 Chevys with a very small Y scale.
 (defun C:PROPS ( / ss prp fac lll lln xx yy zz)
  (setvar "cmdecho" 0)
  (command "undo" "mark")
  (prompt "Select entities: ")
  (setq ss (ssget))
 (setq prp (getstring "Set scales to X, Y, or Z scale or input a scale <1>: "))
  (if (= "." (substr prp 1 1)) (setq prp (strcat "0" prp)))
  (setq prp (cond ((= prp "x") '(cdr xx)) ((= prp "X") '(cdr xx))
                  ((= prp "y") '(cdr yy)) ((= prp "Y") '(cdr yy))
                  ((= prp "z") '(cdr zz)) ((= prp "Z") '(cdr zz))
                  ((= prp "") 1) (t (read prp))))
  (while (setq lll (ssname ss 0))
         (setq lln (entget lll))
         (if (= "INSERT" (cdr (assoc 0 lln)))
             (progn
                   (setq xx (assoc 41 lln))
                   (setq yy (assoc 42 lln))
                   (setq zz (assoc 43 lln))
                   (setq fac (eval prp))
                   (setq lln (subst (cons 41 fac) xx lln))
                   (setq lln (subst (cons 42 fac) yy lln))
                   (entmod (subst (cons 43 fac) zz lln))))
         (ssdel lll ss))
  (PRINC))