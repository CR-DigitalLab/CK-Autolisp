; C:COLORX
;
; Changes color of entities in selection set to a new color value
; based on the original color value (ie. translation table).  
;    NOTE: Does not change 'bylayer' color value.
;
; By: Jason A. Cox
;
(DEFUN C:COLORX ( / count e max ss1)
        (prompt "COLOR TRANSLATION PROGRAM")
        (setq ss1 (ssget))
        (setq max (sslength ss1))
        (setq count 0)
        (prompt (strcat "\nTotal Entities to Scan = " (rtos max 2 0) "\n"))
        (while (< count max)
                (setq e (entget (ssname ss1 count)))
                (setq count (1+ count))
                (prompt (strcat "\rProcessing " (rtos count 2 0)))
                (prompt (strcat "  " (cdr (assoc 0 e)) "            \r"))
                (cond
; *****************
; TRANSLATION TABLE - Adjust or add color values to translate
;            FORMAT:    ((= *a (cdr (assoc 62 e))) (entmod (subst '(62 . *b) '(62 . *a) e)))
;             WHERE:   *a is the original color value
;                      *b is the new color value
;             \/ORIG. COLOR                     NEW COLOR\/        \/ORIG.
          ((= 5 (cdr (assoc 62 e))) (entmod (subst '(62 . 4) '(62 . 5) e)))
; *****************
                        (t nil)
                );cond
        );while
        (princ)
)
(princ)
