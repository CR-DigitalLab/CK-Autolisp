 ; A variation on IHI.LSP
 ; by SW for Rocket Software  Copyright 1991
 ; Inserts block "circ" on a line and chops out a 4 unit line segment.
 (defun C:IHI2 ( / pa xa xb)
  (setvar "cmdecho" 0)
  (setq pa (getpoint "Insertion point:"))
  (setq xa (cons (- (car pa) 2) (cdr pa)))
  (setq xb (cons (+ (car pa) 2) (cdr pa)))
  (command "break" pa "f" xa xb )
  (command "insert" "circ" pa "" "" "" )
 (PRINC)) 
