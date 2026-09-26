 ; Get entity data
 ; By SW for Rocket Software  Copyright 1991
 ; Get at those deeper levels of reality
 ;         or totally lose contact with the stuff,
 ;                     depending on your perspective...
 (DEFUN C:GET (/ nst aa ntt)
  (if (/= (type st) 'ENAME)
      (progn
            (while (null aa)
            (setq aa (entsel "Select entity:")))
            (print (entget (setq st (car aa)))))
      (progn
            (redraw st)
            (setq nst (car (entsel "Select entity or <Return> for next.")))
            (if nst
                (setq st (cdar (print (entget nst))))
                (progn
                      (if (setq ntt (entnext st))
                          (progn
                                (setq st (cdar (print (entget ntt))))
                                (redraw st 3))
                          (write-line "There are no more entities."))))
      ))
 (princ))