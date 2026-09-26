   ;  Change existing text to incremented numbers (in order selected).
   ;  by SW for Rocket Software  Copyright 1990
   ;  Also handles negatives and reals - for those odd numbering schemes.
   ;  LUPREC must be larger than the number of decimals places used.
 (defun C:NUM ( / ss nnum pincr lll lln zz numt nn)
   (setvar "cmdecho" 0)
   (command "undo" "mark")
   (if (= (type num) 'REAL)
       (progn
            (setq nnum (getreal (strcat "Start # <" (rtos num) ">:")))
            (if nnum (setq num nnum)))
       (progn
            (setq num (getreal "Start # <1>:"))
            (if (null num) (setq num 1.0))))
   (if (= (type incr) 'REAL)
       (progn
            (setq pincr (getreal (strcat "Increment <" (rtos incr) ">: ")))
            (if pincr (setq incr pincr)))
       (progn
            (setq incr (getreal "Increment <1>: "))
            (if (null incr) (setq incr 1.0))))
   (while (setq lll (entsel "Select text: "))
          (setq lln (entget (car lll)))
          (if (= "TEXT" (cdr (assoc 0 lln)))
              (progn
                    (setq numt (rtos num))
                    (setq nn (strlen numt))
                    (if (equal num 0)
                        (setq numt "0")
                        (progn
                              (setq ch ())
                              (if (> (getvar "luprec") 0)
                                (progn
                                  (while (and (or (= (substr numt nn 1) ".")
                                                  (= (substr numt nn 1) "0"))
                                              (null ch))
                                         (if (= (substr numt nn 1) ".")
                                             (setq ch t))
                                         (setq nn (1- nn)))
                                  (setq numt (substr numt 1 nn))))
                              ))
                    (setq num (+ incr num))
                    (setq zz (cdr (assoc 1 lln)))
                    (entmod (subst (cons 1 numt) (cons 1 zz) lln)))))
  (PRINC))