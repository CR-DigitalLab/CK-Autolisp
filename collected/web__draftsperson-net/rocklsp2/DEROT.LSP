  ; Remove the rotation from an entity. (Block or Text)
  ; by SW for Rocket Software  Copyright 1990 
  ; Another program that seemed to need to be written.
 (defun C:DEROT ( / un ss num lll lln typ ra)
   (setvar "cmdecho" 0)
   (command "undo" "mark")
   (prompt "Select entities to derotate: ")
   (setq ss (ssget))
       (setq num 0)
       (while (ssname ss 0)
              (setq lll (ssname ss 0))
              (setq lln (entget lll))
              (if (setq ra (assoc 50 lln))
                  (progn
                        (setq num (1+ num))
                        (entmod (subst (cons 50 0) ra lln)))
                  (setq un (if un (1+ un) 1)))
              (ssdel lll ss))
   (setq typ (strcat "Entities derotated: " (itoa num)))
   (prompt (if un (strcat typ ", untouched: " (itoa un)) typ))
   (PRINC))