  ;  Text Change To Date
  ;  Copyright 1990   Rocket Software
  ;  Brilliant Software (for your less than scintillating co-workers).
 (defun C:TXD ( / dd yy mm da mlst ss lll zz)
   (setvar "cmdecho" 0)
   (setq dd (car (entsel "Select Text: \n")))
   (setq lll (entget dd))
   (if lll
          (progn
                (setq zz (assoc 1. lll))
                (setq dd (getvar "cdate"))
                (setq yy (fix (/ dd 10000)))
                (setq mm (- (fix (/ dd 100)) (* yy 100.0)))
                (setq da (- (fix dd) (+ (* mm 100.0) (fix (* yy 10000.0)))))
                (setq mm (fix (1- mm)))
                (setq mlst (list "JANUARY " "FEBRUARY " "MARCH " "APRIL "
                                 "MAY " "JUNE " "JULY " "AUGUST " "SEPTEMBER "
                                 "OCTOBER " "NOVEMBER " "DECEMBER "))
                (setq mm (nth mm mlst)) 
                (setq dd (strcat mm (itoa (fix da)) ", " (itoa (fix yy))))
                (if (= (substr (cdr zz) 1 4) "ASB:")
                    (setq dd (strcat "ASB: " dd)))
                (entmod (subst (cons 1 dd) zz lll))))
 (princ))