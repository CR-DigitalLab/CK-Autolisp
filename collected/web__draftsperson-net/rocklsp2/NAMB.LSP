 ; Namb: block name extractor.
 ; By SW for Rocket Software  Copyright 1991
 ; Sometimes "List" gets a bit carried away.
 (DEFUN C:NAMB (/ aa)
   (setq grn 0)
   (setq aa (entsel "Select entity:\n"))
   (if aa
       (progn
             (setq aa (entget (car aa)))
             (setq aa (cdr (assoc 2 aa))) 
             (if aa
                 (progn
                       (write-line (strcat "Block name: " aa))
;                       (repeat 25
;                       (setq grn (1+ grn))
;                       (grtext grn aa))
                        (grtext 25 aa))
                 (write-line "That was not a block."))))
 (princ))