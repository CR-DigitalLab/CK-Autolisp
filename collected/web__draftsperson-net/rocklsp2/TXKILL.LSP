  ; Textkill - removes empty ("" or " ") text strings from a drawing.
  ; Copyright 1991  Rocket Software
  ; This could be modified to write the offending entities
  ; to a text file for closer scrutiny...
 (DEFUN C:TXKILL ( / rad ss ssd num nuf len so txa pa)
  (setvar "cmdecho" 0)
  (setq rad (/ (- (car (getvar "extmax")) (car (getvar "extmin"))) 25))
  (setq ss (ssget "X" '((0 . "TEXT"))))
  (setq ssd (ssadd))
  (setq num 0)
  (setq nuf 0)
  (setq len (strcat "/" (itoa (sslength ss))))
  (while (setq so (ssname ss 0))
         (setq txa (entget so))
         (setq num (1+ num))
         (grtext -2 (strcat (itoa num) len))
         (if (or (= (cdr (assoc 1 txa)) "") (= (cdr (assoc 1 txa)) " "))
             (progn
                   (setq pa (cdr (assoc 10 txa)))
               (grdraw (polar pa (/ pi 4) rad) (polar pa (* 1.25 pi) rad) 7)
               (grdraw (polar pa (* pi 0.75) rad) (polar pa (* pi 1.75) rad) 7)
                   (setq nuf (1+ nuf))
                   (ssadd so ssd)))
         (ssdel so ss))
  (write-line (strcat "Empty strings found: " (itoa nuf)))
  (if (/= (setq nuf (sslength ssd)) 0)
      (progn
            (setq dell (getstring "Delete them? <Y>: "))
            (if (or (= dell "Y") (= dell "y") (= dell ""))
                (progn
                (command "erase" ssd "")
                (write-line (strcat "Strings eradicated: " (itoa nuf)))))))
  (setq ss nil ssd nil)
  (PRINC))