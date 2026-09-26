  ; Insert a block at a scale specified by the Dimscale system variable.
  ; Useful for working on scaled drawings (you have to set Dimscale first).
  ; Copyright 1991  Rocket Software
  ; Coming soon: Rocket Software exercise wear and sports gear.
 (DEFUN C:JACK ( / pt anx nb tt)
  (setvar "cmdecho" 0)
  (if (= (type nn) 'str)
         (setq tt (strcat "Block name <" nn ">:"))
         (setq tt "Block name: "))
  (setq nb (getstring tt))
  (if (/= nb "") (setq nn nb))
  (setq pt (getpoint "Insertion point: "))
  (if (null angg) (setq angg 0.0))
  (setq anx (getangle pt (strcat "\nAngle <" (rtos angg) ">: ")))
  (if anx (setq angg (* (/ 180 pi) anx)))
  (command "insert" nn pt (getvar "dimscale") "" angg)
 (PRINC))