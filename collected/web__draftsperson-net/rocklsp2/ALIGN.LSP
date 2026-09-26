  ; Convert text to aligned text.
  ; Copyright 1991  Rocket Software
  ; Try this routine: become the first living human to use aligned text.
 (DEFUN C:ALIGN ( / aa bb cc ll mm)
   (setvar "cmdecho" 0)
   (command "undo" "mark")
   (setq aa (entget (car (entsel "Pick text entity to align:\n"))))
   (if (= (cdr (assoc 0 aa)) "TEXT") (progn
   (setq bb (cdr (assoc 10 aa)))
   (setq cc (cdr (assoc 11 aa)))
   (setq ll (getpoint bb "New insertion point (<Return> for current): "))
   (if ll (setq aa (subst (cons 10 ll) (assoc 10 aa) aa))
          (setq ll bb))
   (if (/= (cdr (assoc 72 aa)) 0)
       (progn
             (setq mm (getpoint ll "New end point (<Return> for current): "))
             (if mm (setq aa (subst (cons 11 mm) (assoc 11 aa) aa))))
       (progn
             (setq mm (getpoint ll "New end point: "))
             (if mm (setq aa (subst (cons 11 mm) (assoc 11 aa) aa))
                    (setq aa (subst (cons 11 bb) (assoc 11 aa) aa)))))
   (setq aa (subst (cons 72 3) (assoc 72 aa) aa))
   (entmod (subst (cons 40 0.001) (assoc 40 aa) aa))))
 (PRINC))