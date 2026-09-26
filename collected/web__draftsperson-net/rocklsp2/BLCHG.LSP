 ; Globally replace a block with another.
 ; By SW for Rocket Software  Copyright 1991
 ; This was not designed to handle blocks with attributes; it will do so,
 ; but only by prompting for the new values. The rotation angle is matched
 ; that of the specific insertion of the previous block, if you wish to
 ; specify a constant rotation remove the semicolons from the start of
 ; lines eight and nine and place similar ones at the beginning of lines
 ; thirteen and fourteen.
 (DEFUN C:BLCHG ( / at bl nb ra ss txa ins scax scay)
  (setvar "cmdecho" 0)
  (setq hi (getvar "highlight"))
  (setq at (getvar "attdia"))
  (setvar "attdia" 1)
  (setq num 0)
  (setq bl (list (cons 2 (getstring "Block to replace: "))))
  (setq nb (getstring "New Block name: "))
;  (setq ra (getangle (getvar "viewctr") "Rotation angle <0>: "))
;  (if (null ra) (setq ra 0) (setq ra (* ra (/ 180 pi))))
  (setq ss (ssget "X" bl))
  (while (setq txa (ssname ss 0))
         (setq ins (cdr (assoc 10 (entget txa))))
         (setq ra (cdr (assoc 50 (entget txa))))      ;
         (setq ra (* ra (/ 180 pi)))                  ;
         (setq scax (cdr (assoc 41 (entget txa))))
         (setq scay (cdr (assoc 42 (entget txa))))
         (setq num (1+ num))
         (command "insert" nb ins scax scay ra)
         (entdel txa)
         (ssdel txa ss)
         (redraw (entlast)))
  (setq ss nil)
  (write-line (strcat "\nBlocks replaced: " (itoa num)))
  (setvar "attdia" at)
  (setvar "highlight" hi)
  (PRINC))