  ; Convert text to right justified text.
  ; Copyright 1991  Rocket Software
  ; Rocket Software: the ketchup of CAD.
   (DEFUN C:RIGHT ( / aa bb cc ll)
   (setvar "cmdecho" 0)
   (command "undo" "mark")
   (setq aa (entget (car (entsel "Pick text to right justify:\n"))))
   (if (= (cdr (assoc 0 aa)) "TEXT") (progn
   (setq bb (cdr (assoc 10 aa)))
   (setq cc (cdr (assoc 11 aa)))
   (if (/= (cdr (assoc 72 aa)) 0)
    (progn
        (setq ll (getpoint cc "New insertion point (<Return> for current): "))
        (if ll (setq aa (subst (cons 11 ll) (assoc 11 aa) aa))))
    (progn
        (setq ll (getpoint bb "New insertion point (<Return> for current): "))
        (if ll (setq aa (subst (cons 11 ll) (assoc 11 aa) aa))
               (setq aa (subst (cons 11 bb) (assoc 11 aa) aa)))))
   (entmod (subst (cons 72 2) (assoc 72 aa) aa))))
 (PRINC))