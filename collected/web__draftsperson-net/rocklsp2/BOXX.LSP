  (DEFUN C:BOXX (/ ss lll lln e1 e2 x1 x2 y1 y2 ax1 ax2 ay1 ay2
                                             ff nx1 nx2 ny1 ny2 )
   (prompt "Select lines:")
   (setq ss (ssget))
     (IF ss                                            ; if (1) any selected
         (progn
            (setq lll (ssname ss 0))                   ; 1st entity name...
            (setq lln (entget lll))                    ; & its entirety
            (if (= (cdr (assoc 0 lln)) "LINE" )        ; if (2) it's a line
                (progn
                      (setq ff t)
                      (setq e1 (cdr (assoc 10 lln)))   ; get one end
                      (setq e2 (cdr (assoc 11 lln)))   ; and the other
                      (setq x1 (car e1))
                      (setq y1 (cadr e1))
                      (setq x2 (car e2))
                      (setq y2 (cadr e2))
                      (setq ax1 (max x1 x2))
                      (setq ay1 (max y1 y2))
                      (setq ax2 (min x1 x2))
                      (setq ay2 (min y1 y2))
                      (command "undo" "mark")
                                  ))                   ; if (2) end, progn end
         (ssdel lll ss)
         (while (ssname ss 0)                          ; while next entity
                (setq lll (ssname ss 0))               ; 1st name remaining...
                (setq lln (entget lll))                ; the whole schmear
                (if (= (cdr (assoc 0 lln)) "LINE")
                    (progn
                          (setq ff t)
                          (setq e1 (cdr (assoc 10 lln)))
                          (setq e2 (cdr (assoc 11 lln)))
                          (setq nx1 (car e1))
                          (setq ny1 (cadr e1))
                          (setq nx2 (car e2))
                          (setq ny2 (cadr e2))
                          (setq x1 (max nx1 nx2 ax1 x1))
                          (setq y1 (max ny1 ny2 ay1 y1))
                          (setq x2 (min nx1 nx2 ax2 x2))
                          (setq y2 (min ny1 ny2 ay2 y2))
                          (command "undo" "mark")
                          ))
         (ssdel lll ss)
         )
     (if ff
             (command "line" (list x1 y1) (list x2 y1) 
                             (list x2 y2) (list x1 y2) "C"))))
     (setq ss nil)
  (PRINC))