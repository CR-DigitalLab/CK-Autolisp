 ; Find and mark all occurrences of a specified block.
 ; By SW for Rocket Software  Copyright 1991
 ; Endlessly valuable for those times when you can't think...of...you know.
 (DEFUN C:FIBL ( / hi num bl ss rad len so txa pa)
  (setvar "cmdecho" 0)
  (setq hi (getvar "highlight"))
  (setq num 0)
  (setq bl (list (cons 2 (getstring "Block to find: "))))
  (setq ss (ssget "X" bl))
  (setq rad (/ (- (car (getvar "extmax")) (car (getvar "extmin"))) 25))
  (if ss
     (progn
          (setq len (strcat "/" (itoa (sslength ss))))
          (while (setq so (ssname ss 0))
                 (setq txa (entget so))
                 (setq num (1+ num))
                 (write-line (strcat (itoa num) len))
                 (setq pa (cdr (assoc 10 txa)))
                 (grdraw (polar pa (/ pi 4) rad) (polar pa (* 1.25 pi) rad) 7)
                 (grdraw (polar pa (* pi 0.75) rad) (polar pa (* pi 1.75) rad) 7)
                 (ssdel so ss))
          (write-line (strcat "Blocks found: " (itoa num)))
          (setq ss nil))
    (write-line "Can't find any such block. "))
  (setvar "highlight" hi)
 (PRINC))
