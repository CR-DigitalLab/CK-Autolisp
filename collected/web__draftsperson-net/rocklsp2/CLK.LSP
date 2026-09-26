 ;  Clock Display
 ;  by SW for Rocket Software  Copyright 1991
 ;  Analog displays are infinitely preferable to digital.
  (DEFUN C:CLK ( / ang pa cd thr tmn)
   (setq ang (getvar "angbase"))
   (setvar "angbase" 0)
   (setvar "cmdecho" 0)
   (setq pa (getpoint "Pick centre point:"))
   (command "circle" pa "25")                  ;
;   (command "insert" "clk" pa "" "" "" )
   (setq cd (getvar "cdate"))
   (setq thr (fix (* 100 (- cd (fix cd)))))
   (setq tmn (fix (* 100 (- (* 100 cd) (fix (* 100 cd))))))
   (command "line" pa (polar pa (+ (/ pi 2)(* -1 (+ (/ (* thr pi) 6)
                                   (/ (* tmn pi) 360)))) 10) "")
   (command "line" pa (polar pa (+ (/ pi 2)(* -1 (/ (* pi tmn) 30))) 18) "")
   (setvar "angbase" ang)
   (PRINC))