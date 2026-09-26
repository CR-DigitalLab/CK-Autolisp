 ; Full function text editing from within AutoCAD
 ; Copyright 1991  Rocket Software  By SW
 ; Maybe overkill, but everyone seems to want this.
(DEFUN C:ED (/ fn ll zz cc)
   (setvar "cmdecho" 0)
   (setq fn (Open "edtex" "w"))
   (setq ll (entget (car (entsel "Select text: "))))
   (if (= "TEXT" (cdr (assoc 0 ll)))
       (progn
             (setq zz (cdr (assoc 1 ll)))
             (write-line zz fn)
             (Close fn)
             (command "XXX" "edtex")
             (if (setq fn (Open "edtex" "r"))
                 (progn
                       (setq cc (read-line fn))
                       (Close fn)
                       (entmod (subst (cons 1 cc) (cons 1 zz) ll)))))
   (write-line "That was not text"))
 (PRINC))