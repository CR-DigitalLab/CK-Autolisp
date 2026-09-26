  ; Snake: put entities on snap, change them if necessary.
  ; Copyright 1991  Rocket Software
  ; The software equivalent of a fairly large hammer.

  (DEFUN SNAC (asnum / fin x2 df y2)
    (setq fin (cdr (assoc asnum nn)))
    (setq x2 (car fin))
    (setq df (rem x2 bb))
    (if (> (abs df) (/ bb 2))
        (setq x2 (+ x2 (- bb df)))
        (setq x2 (- x2 df)))
    (setq y2 (cadr fin))
    (setq df (rem y2 cc))
    (if (> (abs df) (/ cc 2))
        (setq y2 (+ y2 (- cc df)))
        (setq y2 (- y2 df)))
    (setq nn (subst (cons asnum (list x2 y2)) (assoc asnum nn) nn)))

 (DEFUN C:SNAKE ( / ss aa bb cc txa nn nam nam72 df rad txsav)
  (setvar "cmdecho" 0)
  (setq ss (ssget))                               ; select entities
  (command "undo" "mark")
  (setq aa (getvar "snapunit"))                   ; get snap settings
  (setq bb (car aa) cc (cadr aa))                 ; bb=X, cc=Y
  (while (setq txa (ssname ss 0))                 ; first in selection set
         (setq nn (entget txa))                   ; entity data
         (setq nam (cdr (assoc 0 nn)))            ; get entity type
         (if (assoc 72 nn)
             (setq nam72 (cdr (assoc 72 nn))))    ; get text justification
         (if (and (or (= nam "TEXT")              ; if text or
                      (= nam "ATTDEF"))           ; attribute and either:
                  (or (= nam72 2)                 ; right aligned
                      (= nam72 4)                 ; or middle aligned
                      (= nam72 1)))               ; or centred
             (progn                               ; then
                   (snac 11) (entmod nn))
             (progn                               ; if not c, r or m text
                   (if (= nam "CIRCLE")           ; if a circle
             (progn
                   (snac 10)
                   (setq rad (cdr (assoc 40 nn)))
                   (setq df (rem rad bb))
                   (if (> (abs df) (/ bb 2))
                       (setq rad (+ rad (- bb df)))
                       (setq rad (- rad df)))
                   (if (= rad 0)                  ; radius should not be 0
                       (setq rad bb))
                   (setq nn (subst (cons 40 rad) (assoc 40 nn) nn))
                   (entmod nn)))                  ; progn end, if circle end

             (if (or (= nam "LINE")               ; if a line
                     (= nam "TRACE")              ; or a trace
                     (= nam "SOLID")              ; or a solid
                     (and (or (= nam "TEXT")      ; or text
                              (= nam "ATTDEF"))   ; or an attribute
                          (or (= nam72 3)         ; and either aligned
                              (= nam72 0)         ; or left justified
                              (= nam72 5))))      ; or fit
             (progn (snac 10) (snac 11)

             (if (or (= nam "SOLID")              ; also only if a solid
                     (= nam "TRACE"))             ; or a trace
                 (progn (snac 12) (snac 13)))     ; progn end, if solid end
             (entmod nn)))                        ; progn end, if line etc end

             (if (= nam "POLYLINE")
                 (progn
                      (setq txsav txa)
                      (setq nn (entget (setq txa (entnext txa)))) ; Next entity
                      (setq nam (cdr (assoc 0 nn)))               ; type
                      (while (/= nam "SEQEND")
                             (snac 10)                            ; snap it
                             (entmod nn)
                             (entupd (cdr (assoc -1 nn)))
                             (setq nn (entget (setq txa (entnext txa)))) ;Next
                             (setq nam (cdr (assoc 0 nn))))
                      (setq txa txsav)))

             (if (= nam "INSERT")
                 (progn
                      (setq fin (cdr (assoc 10 nn)))
                      (setq x2 (car fin))
                      (setq df (rem x2 bb))
                      (if (> (abs df) (/ bb 2))
                          (setq x2 (+ x2 (- bb df)))
                          (setq x2 (- x2 df)))
                      (setq y2 (cadr fin))
                      (setq df (rem y2 cc))
                      (if (> (abs df) (/ cc 2))
                          (setq y2 (+ y2 (- cc df)))
                          (setq y2 (- y2 df)))
                      (command "move" txa "" fin (list x2 y2))))

             (if (and (/= nam "CIRCLE")           ; if not a circle
                      (/= nam "INSERT")           ; or a block
                      (/= nam "SEQEND")           ; or a polyline seqend
                      (/= nam "LINE")             ; or a line
                      (/= nam "SOLID")            ; or a solid
                      (/= nam "TRACE")            ; or a trace
                      (/= nam "ATTDEF")           ; or an attribute
                      (/= nam "TEXT"))            ; or text
                 (progn (snac 10) (entmod nn)))))
         (ssdel txa ss))                          ; delete from ss, while end
  (setq ss nil)                                   ; trash selection set
  (PRINC))