  ; Vertical venetian blind - adjust vertical text spacing.
  ; By SW for Rocket Software  Copyright 1991
  ; For those who would rather be hang gliding down Mount Everest.
 (DEFUN C:VVB ( / ss xa num incr txa nn yy)
  (setvar "cmdecho" 0)
  (command "undo" "mark")
  (prompt "Pick text strings:")
  (setq ss (ssget)
        xa (getpoint "\nPick startpoint:")
        num 0
        incr (getdist xa "\nLine spacing <5>:"))
  (if (null incr) (setq incr 5))
;---------------Remove non-text entities from ss------------------
  (while (setq txb (ssname ss num))
         (if (= (cdr (assoc 0 (entget txb))) "TEXT")
             (setq num (1+ num))
             (ssdel txb ss)))
  (setq num 0)
;-----------------------------------------------------------------
  (while (setq txa (ssname ss 0))
         (setq enn 1)
         (setq nna (entget txa))
         (setq ya (cdr (assoc 11 nna)))
         (while (setq txb (ssname ss enn))
                (setq yb (cdr (assoc 11 (entget txb))))
                (if (> (cadr yb) (cadr ya))
                    (progn
                          (setq txa txb)
                          (setq nna (entget txa))
                          (setq ya (cdr (assoc 11 nna)))))
                          (setq enn (1+ enn)))
         (setq num (1+ num))
         (if (or (= (cdr (assoc 72 nna)) 2)
                 (= (cdr (assoc 72 nna)) 4)
                 (= (cdr (assoc 72 nna)) 1))
             (progn
                   (if (= (cdr (assoc 72 nna)) 4)
                       (progn
                             (setq txh (cdr (assoc 40 (entget (ssname ss 0)))))
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
         (setq xa (list (car xa) (- (cadr xa) incr)))
         (ssdel txa ss))
  (setq ss nil)
  (if (> num 0)
      (progn    
            (if (= num 1)
                (prompt "\n1 line put on vertical hold")
                (prompt (strcat "\n " (ITOA num) " lines stratified")))
            (prompt "\n   ...by Nubian slave girls.")))
 (PRINC))