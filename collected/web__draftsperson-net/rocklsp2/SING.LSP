   ; Breaks first line of two selected.
   ; Also works on linetypes other than continuous, at which Xing may balk.
   ; Copyright 1991  Rocket Software
   ; Note the absence of timers, clocks, funny prompts, debriefing, etc.
  (DEFUN C:SING ( / cc z1 xx yy a1 b2 c3 d4 int)
    (setvar "cmdecho" 0)
    (setq cc 2)
    (setq xx (entget (car (setq z1 (entsel "Select line to cut: ")))))
    (setq z1 (cadr z1))
    (setq yy (entget (car (entsel "\nand the one to not cut: "))))
    (setq a1 (cdr (assoc 10 xx)))
    (setq b2 (cdr (assoc 11 xx)))
    (setq c3 (cdr (assoc 10 yy)))
    (setq d4 (cdr (assoc 11 yy)))
    (setq int (inters a1 b2 c3 d4))
    (setq xx (car int) yy (cadr int))
    (if (> (abs (- (car a1) (car b2))) (abs (- (cadr a1) (cadr b2))))
        (progn
              (setq a1 (list (+ xx cc) yy))
              (setq b2 (list (- xx cc) yy)))
        (progn
              (setq a1 (list xx (+ yy cc)))
              (setq b2 (list xx (- YY cc)))))
    (command "break" z1 "f" a1 b2)
  (PRINC))