   ; Sequential text changer - short version
   ; by SW for Rocket Software  Copyright 1991
   ; For those of you with slow machines, small memories...
 (defun C:TXX ( / ss xa nn zz tt)
   (write-line "Select text: ")
   (setq ss (ssget))
   (while (setq xa (ssname ss 0))
          (setq nn (entget xa))
          (if (= (cdr (assoc 0 nn)) "TEXT")
              (progn
                    (redraw xa 3) 
                    (setq zz (cdr (assoc 1 nn))
                          tt (getstring t (strcat "New text <" zz ">: ")))
                    (if (/= tt "")
                        (entmod (subst (cons 1 tt) (cons 1 zz) nn))
                        (redraw xa))))
          (ssdel xa ss))
    (setq ss nil)
  (princ))