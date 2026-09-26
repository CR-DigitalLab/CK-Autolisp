  ;  Global text size changer for specified sizes.
  ;  Copyright 1990 by Rocket Software
  ;  Software that does what you actually want - and sometimes more.
   (DEFUN C:TXS ( / hi ss num ohh nhh txa thh nn)
   (setvar "cmdecho" 0)
   (setq hi (getvar "highlight"))
   (setq ohh (getdist "Present height (in your opinion): "))
   (setq nhh (getdist "Desired height: "))
   (write-line "Just a minute...")
   (setq ss (ssget "X" '((0 . "TEXT")))
         num 0)
   (while (setq txa (ssname ss 0))
          (setq nn (entget txa)
                thh (cdr (assoc 40 nn)))               ; old height
          (if (= ohh thh)
              (progn
              (setq num (1+ num))                      ; increment counter
              (entmod (subst (cons 40 nhh) (cons 40 thh) nn)))) ; update
          (ssdel txa ss)                               ; remove from SS
   )                                                   ; while end
    (setq ss nil)
    (if (< 1 num)
        (write-line (strcat (ITOA num) " lines resized.")))
    (if (= 1 num)
        (write-line "1 line resized by lobsters."))
    (if (= 0 num)
        (progn
              (write-line "No text of that height found...")
              (write-line " ...So eat leaden death!")
              (grclear)
        ))
    (setvar "highlight" hi)
    (PRINC))