 ; Change a selected attribute in a selected block to the date.
 ; The block is REVDATE and the attribute ATTDATE, but these can be changed.
 ; By SW for Rocket Software  Copyright 1991
 ; For those with a compulsion to manufacture organizational systems.
 (DEFUN C:PLDT ( / hi dd yy mm da ss txa txb nn)
  (setvar "cmdecho" 0)
  (setq hi (getvar "highlight"))
  (setq dd (rtos (fix (getvar "cdate"))))
  (setq yy (substr dd 3 2) mm (substr dd 5 2) da (substr dd 7 2))
  (setq dd (strcat yy "/" mm "/" da))
  (setq ss (ssget "X" '((2 . "REVDATE"))))
  (while (setq txa (setq txb (ssname ss 0)))
         (while (/= (cdr (assoc 0 (entget txb))) "SEQEND")
                (if (= (cdr (assoc 2 (setq nn (entget txb)))) "ATTDATE")
                    (progn
                          (entmod (subst (cons 1 dd) (assoc 1 nn) nn))
                          (entupd txb)
                ))
                (setq txb (entnext txb)))
         (ssdel txa ss))
  (setq ss nil)
  (setvar "highlight" hi)
  (PRINC))