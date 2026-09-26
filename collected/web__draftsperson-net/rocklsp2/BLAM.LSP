  ; Blam: explode blocks and replace the attributes with text.
  ; Also erases any resulting text consisting of either " " or"".
  ; Rocket Software  Copyright 1991
  ; Another subversive program from Rocket.
 (defun C:BLAM ( / ss nn bb xx yy zz bbx bbn tt fh aa bb)
  (setvar "cmdecho" 0)
  (command "undo" "mark")
  (setq ss (ssadd))
  (setq del 0)
  (setq tt (getvar "textstyle"))                         ; get style
  (setq fh (cdr (assoc 40 (tblsearch "style" tt))))      ; fixed height?
  (setq bb (entget (setq bbx (setq bbn (car (entsel "Block to atomize:\n"))))))
  (if (= (cdr (assoc 0 bb)) "INSERT") (progn             ; if it's a block
      (setq xx (cdr (assoc 41 bb)))
      (setq yy (cdr (assoc 42 bb)))
      (setq zz (cdr (assoc 43 bb)))
      (if (= xx yy zz) (progn                            ; if scales are equal
        (if (assoc 66 bb) (progn                         ; if attributes
 ;****** Cycle through the block insertion and make the text entities ******
  (while (/= (cdr (assoc 0 (setq bb 
             (entget (setq bbn (entnext bbn)))))) "SEQEND")
         (setq nn 2)
         (if (= fh 0.0)                                         ; fixed height?
             (command "text" (getvar "viewctr") "" "" ".")      ; no
             (command "text" (getvar "viewctr") "" "."))        ; yes
         (ssadd (entlast) ss)
         (setq aa (entget (entlast)))
         (setq bbf (list (nth 1 aa) (nth 0 aa)))
         (while (nth nn bb)
                (if (not (or (= 3 (car (nth nn bb)))
                             (= 2 (car (nth nn bb)))
                             (= 70 (car (nth nn bb)))
                             (= 73 (car (nth nn bb)))))
                    (setq bbf (cons (nth nn bb) bbf)))
                (setq nn (1+ nn)))
         (setq bbf (reverse bbf))
         (entmod bbf))
 ;****** end of text creation and remanufacturing ******
  (command "explode" bbx)                      ; explode the block
  (setq aa (cdr (assoc -1 aa)))
  (while (setq aa (entnext aa))
         (if (= (cdr (assoc 0 (entget aa))) "ATTDEF")
             (entdel aa)))
  (setq conv (sslength ss))
  (while (setq aa (ssname ss 0))
         (if (or (= (cdr (assoc 1 (entget aa))) "")
                 (= (cdr (assoc 1 (entget aa))) " "))
             (progn
                   (setq del (1+ del))
                   (entdel aa))
             (redraw aa))
         (ssdel aa ss))
  (if (< 0 del)
      (if (= 1 del)
          (setq del ", 1 vacant string erased.")
          (setq del (strcat ", " (itoa del)
                            " empty text strings eradicated.")))
      (setq del "."))
  (if (> conv 1)
      (prompt (strcat (itoa conv) " attributes converted" del))
      (prompt (strcat "1 attribute converted" del)))
  )                                            ; end of if attributes
  (progn                                     ;if no attributes
          (command "explode" bbx)
          (prompt "Block exploded, no attributes found")))) ; if xyz eq end
  (prompt "X, Y and Z scales are different.  Cannot explode this Block."))
  ) (prompt "\nThat doesn't look much like a block to me.")) ; if a block end
  (princ))