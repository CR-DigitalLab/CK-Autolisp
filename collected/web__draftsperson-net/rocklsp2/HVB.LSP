   ;  Horizontal Venetian Blind 
   ;  Copyright 1991  Rocket Software
   ;  Multiple text realigner - moves text to a common Y co-ordinate
   ;  without altering its X position. The "Align on Left..." option
   ;  is useful for aligning 90 degree rotated text which is not left
   ;  justified but should have been.
 (DEFUN C:HVB ( / ss xa txa nn yy bb mv)
  (setvar "cmdecho" 0)
  (command "undo" "mark")
  (prompt "Pick text strings:")
  (setq ss (ssget)
        xa (cadr (getpoint "\nPick insertion point level: \n")))
  (setq ll (getstring "Align on Left of text or on <Insertion>: "))
  (if (or (= ll "") (= ll "i") (= ll "I"))
      (progn
      (while (setq txa (ssname ss 0))
             (setq nn (entget txa))
             (if (and (= (cdr (assoc 0 nn)) "TEXT")
                      (or (= (cdr (assoc 72 nn)) 2)
                          (= (cdr (assoc 72 nn)) 4)
                          (= (cdr (assoc 72 nn)) 1)))
                 (progn
                       (setq bb (cdr (assoc 11 nn)))
                       (setq mv (list (car bb) xa))
                       (command "move" txa "" bb mv))
                 (progn
                       (setq bb (cdr (assoc 10 nn)))
                       (setq mv (list (car bb) xa))
                       (command "move" txa "" bb mv)))
             (ssdel txa ss)))
      (progn 
      (while (setq txa (ssname ss 0))
             (setq nn (entget txa))
             (setq bb (cdr (assoc 10 nn)))
             (setq mv (list (car bb) xa))
             (command "move" txa "" bb mv)
             (ssdel txa ss))))
  (setq ss nil)
  (princ))