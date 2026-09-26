   ;  Text Reverser - resreveR txeT
   ;  Copyright 1990   Rocket Software
   ;  Software that does things you hadn't realized you needed to do.
 (defun C:RTX ( / cc lll zz zza lena ntxb)
   (if (setq lll (entsel "Select Text:"))
       (progn
             (setq lll (entget (car lll)))
             (setq zza "")
             (setq zz (cdr (assoc 1. lll)))
             (setq lena (strlen zz))
             (while (/= 0 lena)
                    (setq ntxb (substr zz lena 1))
                    (setq lena (1- lena))
                    (setq zza (strcat zza ntxb)))
             (entmod (subst (cons 1 zza) (cons 1 zz) lll)))
       (write-line "\nNo entity selected."))
   (PRINC))
