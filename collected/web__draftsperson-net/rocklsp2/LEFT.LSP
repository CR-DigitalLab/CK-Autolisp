  ; Convert text to left justified text.
  ; Copyright 1991  Rocket Software
  ; Disclaimer: this program has no political significance.
 (DEFUN C:LEFT ( / aa bb ll)
   (setvar "cmdecho" 0)
   (command "undo" "mark")
   (setq aa (entget (car (entsel "Pick text to left justify:\n"))))
   (if (= (cdr (assoc 0 aa)) "TEXT") (progn
   (setq bb (cdr (assoc 10 aa)))
   (setq ll (getpoint bb "New insertion point (<Return> for current): "))
   (if ll (setq aa (subst (cons 10 ll) (assoc 10 aa) aa)))
   (entmod (subst (cons 72 0) (assoc 72 aa) aa))))
 (PRINC))