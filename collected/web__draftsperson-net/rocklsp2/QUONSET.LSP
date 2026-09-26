  ; Quonset: Set attribute Quonset in block Qname to drawing file name
  ; bereft of path.  Designed be used with (S::STARTUP) to automatically
  ; set the name upon starting a drawing.
  ; Copyright 1991  Rocket Software
  ; Why "Quonset"?  Because that's what was suggested, because it's
  ; easy to remember, and because there are no other lisps starting with Q.
 (DEFUN C:QUONSET ( / hi pos tt ss txa txb nn)
  (setvar "cmdecho" 0)
  (setq hi (getvar "highlight"))
  (setq pos (strlen (setq tt (getvar "dwgname"))))  ; start at end of string
  (while (< 0 pos)
         (if (= (substr tt pos 1) (chr 92))         ; if char = \
             (progn
                   (setq tt (substr tt (1+ pos)))   ; then set tt to all after
                   (setq pos 1)))                   ;  and set pos to first
         (setq pos (1- pos)))                       ; set pos to previous
  (setq ss (ssget "X" '((2 . "QNAME"))))
  (while (setq txa (setq txb (ssname ss 0)))
         (while (/= (cdr (assoc 0 (entget txb))) "SEQEND")
                (if (= (cdr (assoc 2 (setq nn (entget txb)))) "QUONSET")
                    (progn
                          (entmod (subst (cons 1 tt) (assoc 1 nn) nn))
                          (entupd txb)
                ))
                (setq txb (entnext txb)))
         (ssdel txa ss))
  (setq ss nil)
  (setvar "highlight" hi)
  (PRINC))