 ; Pointkill - removes all points from a drawing.
 ; By SW for Rocket Software  Copyright 1991
 ; Sorry, Suerat.
 (DEFUN C:PKILL (/ hi ss pos num rad so txa pa dell)
  (setvar "cmdecho" 0)
  (setq hi (getvar "highlight"))
  (setq ss (ssget "X" '((0 . "POINT"))))
  (setq pos 0)
  (if ss
     (progn
        (setq num (itoa (sslength ss)))
        (write-line (strcat "Points found: " num))
        (setq rad (/ (- (car (getvar "extmax")) (car (getvar "extmin"))) 25))
        (while (setq so (ssname ss pos))
               (setq pa (cdr (assoc 10 (entget so))))
               (grdraw (polar pa (/ pi 4) rad) (polar pa (* 1.25 pi) rad) 7)
               (grdraw (polar pa (* pi 0.75) rad) (polar pa (* pi 1.75) rad) 7)
               (setq pos (1+ pos)))
       (setq dell (getstring "Eradicate them? <Y>: "))
       (if (or (= dell "Y") (= dell "y") (= dell ""))
           (progn
                 (command "erase" ss "")
                 (write-line (strcat "\nPoints destroyed: " num)))))
     (write-line "No points found."))
  (setvar "highlight" hi)
 (PRINC))