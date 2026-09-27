;;; Move all Text, Mtext, Multileader, Dimension objects to front
;;; Alan J. Thompson, 06.01.09
(defun c:TTF (/ #SSGet)
 (or (ssget "_I")
     (prompt
       "\nSelect Text, Multileader, Dimension objects to move to front: "
     ) ;_ prompt
 ) ;_ or
 (cond
   ((setq #SSGet (ssget ":L" '((0 . "MTEXT,TEXT,MULTILEADER,DIM*"))))
    (vl-cmdf "_.draworder" #SSGet "" "_f")
    (prompt
      (strcat (itoa (sslength #SSGet))
              " Text, Multileader, Dimension objects moved to front."
      ) ;_ strcat
    ) ;_ prompt
   )
 ) ;_ cond
 (princ)
) ;_ defun
