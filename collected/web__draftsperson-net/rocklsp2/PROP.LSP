  ; Set all 3 scale factors in a block to 1.
  ; Copyright 1990   Rocket Software  by SW
  ; You might want to combine this and Derot.lsp into one routine.
  ; Then again, you might not.
  ; You could also substitute other numbers for the "1"s.
 (defun C:PROP ( / ss num lll lln xx yy zz)
   (setvar "cmdecho" 0)
   (command "undo" "mark")
   (prompt "Select entities:")
   (setq ss (ssget))
   (while (ssname ss 0)
          (setq lll (ssname ss 0))
          (setq lln (entget lll))
          (if (= "INSERT" (cdr (assoc 0 LLN)))
              (progn
                    (setq xx (assoc 41 lln))
                    (setq yy (assoc 42 lln))
                    (setq zz (assoc 43 lln))
                    (setq lln (subst (cons 41 1) xx lln))     ; set x to 1
                    (setq lln (subst (cons 42 1) yy lln))     ; set y to 1
                    (entmod (subst (cons 43 1) zz lln))))     ; set z to 1
          (ssdel lll ss))
   (PRINC))