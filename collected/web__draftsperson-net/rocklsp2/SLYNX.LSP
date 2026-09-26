   ;  Line Consolidator - the old version with the snap adjuster.
   ;  Copyright 1991  Rocket Software
   ;  Still included for those who like a program to make its own choices.
(DEFUN C:SLYNX (/ ss nm rot lll lln e1 e2 x1 x2 y1 y2 ax1 ax2 ay1 ay2
                                                  ff nx1 nx2 ny1 ny2 )
 (setvar "cmdecho" 0)
 (prompt "Select lines:")
 (setq ss (ssget))
;*******************************get line lean*********************************
 (setq nm 0)
 (setq rot 0)
 (while (setq na (ssname ss nm))
        (setq nn (entget na))
        (setq nm (1+ nm))
        (if (= (cdr (assoc 0 nn)) "LINE")
            (progn (setq xx (cdr (assoc 10 nn)))
                   (setq yy (cdr (assoc 11 nn)))
                   (setq angg (/ (angle xx yy) pi))
                   (if (or (>= 0.5 angg) (and (<= 1.0 angg) (> 1.5 angg)))
                       (setq rot (1+ rot))
                       (setq rot (1- rot)))
                   )))
;  (cond ((> rot 0) (print "Lean to right."))
;        ((= rot 0) (print "Balanced (Ortho on)."))
;        (t (print "Lean to left."))) 
;*******************************deduce corners********************************
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
                    (entdel lll)))                   ; if (2) end, progn end
       (ssdel lll ss)
    (if (ssname ss 0)                                ; if anything left in ss
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
                        (entdel lll)))
       (ssdel lll ss))                               ; while end
        (setq x1 ax1 x2 ax2 y1 ay1 y2 ay2))          ; if ss was empty, if end
;*******************************if snap is on*********************************
  (if (= 1 (getvar "snapmode"))
      (progn
            (setq aa (getvar "snapunit"))
            (setq bb (car aa) cc (cadr aa))
                        (setq df (abs (rem x1 bb)))
                        (if (> df (/ bb 2))
                        (setq x1 (+ x1 (- bb df)))
                        (setq x1 (- x1 df)))
                        (setq df (abs (rem x2 bb)))
                        (if (> df (/ bb 2))
                        (setq x2 (+ x2 (- bb df)))
                        (setq x2 (- x2 df)))
                        (setq df (abs (rem y1 cc)))
                        (if (> df (/ cc 2))
                        (setq y1 (+ y1 (- cc df)))
                        (setq y1 (- y1 df)))
                        (setq df (abs (rem y2 cc)))
                        (if (> df (/ cc 2))
                        (setq y2 (+ y2 (- cc df)))
                        (setq y2 (- y2 df)))))
;*********************************draw new line*******************************
  (if ff
      (if (or (= (getvar "orthomode") 1) (= rot 0))  ; if (1) ortho or balance
          (if (> (abs (- x1 x2)) (abs (- y1 y2)))    ; (2)horiz or vert greater
              (progn                                 ; (2) then
                    (setq midy (/ (+ y1 y2) 2))      ; horizontal line
                    (command "line" (list x1 midy) (list x2 midy) ""))
              (progn                                 ; (2) else
                    (setq midx (/ (+ x1 x2) 2))      ; vertical line
                    (command "line" (list midx y1) (list midx y2) ""))) ;(2)end
          (if (> rot 0)                                         ; else (1)
              (command "line" (list x1 y1) (list x2 y2) "")     ; if lean right
              (command "line" (list x2 y1) (list x1 y2) "")))))) ; else (left)
    (setq ss nil)
 (PRINC))