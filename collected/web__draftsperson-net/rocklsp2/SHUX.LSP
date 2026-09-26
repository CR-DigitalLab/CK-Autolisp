  ; Text Reshuffler - moves text vertically so that it is evenly
  ; spaced between two picked points - the top of the top line
  ; and the bottom of the bottom one.
  ; By SW for Rocket Software  Copyright 1991
 (DEFUN C:SHUX ( / ss xa xb num incr txa txb nna enn nn yy ord)
  (setvar "cmdecho" 0)
  (command "undo" "mark")
  (prompt "Pick text strings: ")
  (setq ss (ssget)
        xa (getpoint "\nPick top line: ")
        num 0
        xb (getpoint xa "\nAnd bottom line: "))
;---------------Remove non-text entities from ss------------------
  (while (setq txb (ssname ss num))
         (if (= (cdr (assoc 0 (entget txb))) "TEXT")
             (setq num (1+ num))
             (ssdel txb ss)))
  (setq num 0)
;-----------------------------------------------------------------
  (setq ssl (sslength ss))
  (if (> ssl 1) (progn 
  (setq ht (- (cadr xa) (cadr xb)))                   ; total height
  (setq txh (cdr (assoc 40 (entget (ssname ss 0)))))  ; text height
  (setq txht (* ssl txh))                             ; total txt ht
  (setq ht (- ht txht))                               ; difference
  (setq ht (/ ht (1- ssl)))                           ; spaces
  (setq incr (+ txh ht))
         (setq xa (list (car xa) (- (cadr xa) txh)))  
  (while (setq txa (ssname ss 0))
         (setq enn 1)
         (setq nna (entget txa))
         (setq ya (cdr (assoc 10 nna)))

;---------------See if next entity in ss is highest on screen-------
         (while (setq txb (ssname ss enn))
                (setq yb (cdr (assoc 10 (entget txb))))
                (if (> (cadr yb) (cadr ya))
                    (progn
                          (setq txa txb)
                          (setq nna (entget txa))
                          (setq ya (cdr (assoc 10 nna)))))
                (setq enn (1+ enn)))
         (setq num (1+ num))

 ;-------------------------Get registration type-----------------------
        (if (or (= (cdr (assoc 72 nna)) 2)
                 (= (cdr (assoc 72 nna)) 4)
                 (= (cdr (assoc 72 nna)) 1))
             (progn
                   (if (= (cdr (assoc 72 nna)) 4)
                       (progn
                             (setq yy (cdr (assoc 11 nna)))
                             (setq nn (list (car yy) (+ (/ txh 2)(cadr xa))))
                             (command "move" txa "" yy nn))
                       (progn
                             (setq yy (cdr (assoc 11 nna)))
                             (setq nn (list (car yy) (cadr xa)))
                             (command "move" txa "" yy nn))))
             (progn
                   (setq yy (cdr (assoc 10 nna)))
                   (setq nn (list (car yy) (cadr xa)))
                   (command "move" txa "" yy nn)))
         (ssdel txa ss)
         (setq xa (list (car xa) (- (cadr xa) incr))))
  ) (if (< 0 ssl) 
        (write-line "\nThere aren't any spaces between one line.")))
  (setq ss nil)
  (if (> num 0)
      (prompt (strcat "\n" (ITOA num) " lines neatly stacked.")))
 (PRINC))