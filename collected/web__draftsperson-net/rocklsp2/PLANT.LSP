  ; Automatic plant constructor
  ; Another amazing Rocket Software product.  Copyright 1991
  ; Could probably be modified into a wiring diagram generator.
 (DEFUN C:PLANT ( / col p1 pa pts pts2 len num s pb)
   (setvar "cmdecho" 0)
   (setq col 1) (command "color" "2")
   (setq p1 (getpoint "Start point:\n"))
   (setq len (getdist p1 "Segment length:\n"))
   (setq incr (getreal "Length increment <0.8>: "))
   (if (null incr)
       (setq incr 0.8))
   (setq nn (getint "Number of iterations:\n"))
   (command "line" p1 (setq pa (polar p1 1.57 len)) "")
   (setq pts (list pa))
   (setq pts2 ())
   (setq num 0)
   (repeat nn
          (if pts
             (progn
                   (setq col (1+ col))
                   (command "color" col)
                   (while (nth num pts)
                          (setq pa (nth num pts))
                          (repeat 3
                                  (setq s (* (getvar "cdate") 10000000.0))
                                  (setq s (* pi (- s ( fix s))))
                                  (if (= s 0) (setq s 1.5))
                                  (setq pb (polar pa s len))
                                  (setq pts2 (if pts2 (append pts2 (list pb))
                                                      (list pb)))
                                  (command "line" pa pb ""))
                          (setq num (1+ num)))
                   (setq num 0)
                   (setq pts pts2)
                   (setq len (* len incr))
                   (setq pts2 ()))))
   (while (setq pa (nth num pts))
   (command "insert" "leaf" pa "1" "" "")
   (setq num (1+ num)))
  (princ))