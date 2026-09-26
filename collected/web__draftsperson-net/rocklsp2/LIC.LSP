  ; Line changer - changes the end nearest to the pick point,
  ; not the one closest to the change point. Ignores Ortho setting.
  ; Copyright 1991  Rocket Software
  ; It's usually better to make changes than to wonder what they'll be.
 (defun C:LIC ( / pt ll np ra rb)
   (setvar "cmdecho" 0)
   (command "undo" "mark")
   (setq pt (entsel "Select a line:\n"))
   (if pt
       (progn
             (setq ll (entget (car pt)))
             (setq pt (cadr pt))
             (if (= "LINE" (cdr (assoc 0 LL)))
                 (progn
                       (setq np (getpoint "New endpoint? "))
                       (setq ra (cdr (assoc 10 ll)))
                       (setq rb (cdr (assoc 11 ll)))
                       (if (< (distance ra pt) (distance rb pt))
                           (entmod (subst (cons 10 np) (cons 10 ra) ll))
                           (entmod (subst (cons 11 np) (cons 11 rb) ll)))))))
   (PRINC))