   ;  Venetian Blind Centred
   ;  Text rejustifier with style check - 
   ;  Tests text string style vs current style before altering text.
   ;  Copyright 1991  Rocket Software
 (DEFUN C:VBHX ( / ss xa num txa nn yy zz st styl fh hh tt)
  (setvar "cmdecho" 0)
  (prompt "Pick text strings:")
  (setq ss (ssget)
        xa (car (getpoint "Centre point ?\n"))
        num 0)
  (setq tt (getvar "textstyle"))
  (while (setq txa (ssname ss 0)) (setq nn (entget txa))
         (if (= (cdr (assoc 0 nn)) "TEXT")
             (progn (setq yy (cddr (assoc 10 nn))
                          zz (cdr (assoc 1 nn))
                          styl (cdr (assoc 7 nn))
                          hh (cdr (assoc 40 nn))
                          st (cons xa yy ))
                    (setq fh (cdr (assoc 40 (tblsearch "style" TT))))
             (if (eq tt styl)
                 (progn
                       (entdel txa)
                       (if (= fh 0.0)
                           (progn (setq num (1+ num))
                                  (command "text" "c" st hh "" zz ))
                           (progn (setq num (1+ num))
                                  (command "text" "c" st "" zz )))
                 )
                 (prompt (strcat "\n*" zz "* is not in style " tt
                                  " and was not rejustified.")))))
         (ssdel txa ss))
   (setq ss nil)
   (if (> num 0)
       (progn    
             (if (= num 1)
                 (prompt "\n 1 line centred")
                 (prompt (strcat "\n " (ITOA num) " lines centred"))
             )
       )
   )
 (PRINC))