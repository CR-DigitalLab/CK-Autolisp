 ; Blg - alter polyline bulge factors on a whim.
 ; Rocket Software  Copyright 1991
 ; Hint: make a 60 sided polygon and give it a bulge factor of 20
 (DEFUN C:BLG (/ nn bu nname)
  (setvar "cmdecho" 0)
  (setq nn (entget (setq nname (car (entsel "Select entity:\n")))))
  (if (= (cdr (assoc 0 nn)) "POLYLINE")
      (progn
            (setq bu (getreal "Bulge factor: "))
            (while (/= (cdr (assoc 0 nn)) "SEQEND")
                   (entmod (subst (cons 42 bu) (assoc 42 nn) nn))
                   (setq nn (entget (setq nname (entnext nname)))))
            (entupd nname))
      (write-line "That was not a polyline, cretin."))
 (princ))