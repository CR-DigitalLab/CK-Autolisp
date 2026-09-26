   ;  Change existing text to incremented numbers (in order selected).
   ;  by SW for Rocket Software  Copyright 1990
   ;  A variation of Num.lsp - allows prefixes and suffixes.
   ;  Useful if you have more numbers than fingers.
   ;  A space input as prefix or suffix is read as an empty string.
 (defun C:NUMTX ( / nnum ss ppref psuff pincr lll lln zz numt nn)
   (setvar "cmdecho" 0)
   (command "undo" "mark")
   (if (= (type num) 'REAL)
       (progn
            (setq nnum (getreal (strcat "Start # <" (rtos num) ">: ")))
            (if nnum (setq num nnum)))
       (progn
            (setq num (getreal "Start # <1>: "))
            (if (null num) (setq num 1.0))))
   (if (and (= (type pref) 'STR) (/= pref ""))
       (progn
            (setq ppref (getstring t (strcat "Text to prefix <" pref ">:")))
            (if (/= ppref "") (setq pref ppref)))
       (progn
            (setq pref (getstring t "Text to prefix <None>:"))))
   (if (= pref " ") (setq pref ""))
   (if (and (= (type suff) 'STR) (/= suff ""))
       (progn
            (setq psuff (getstring t (strcat "Text to append <" suff ">:")))
            (if (/= psuff "") (setq suff psuff)))
       (progn
            (setq suff (getstring t "Text to append <None>:"))))
   (if (= suff " ") (setq suff ""))
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
                    (entmod (subst (cons 1 (strcat pref numt suff))
                                        (cons 1 zz) lln)))))
  (PRINC))