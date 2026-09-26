  ;  Chgx - change entity data directly - allows access to subentities.
  ;  By SW for Rocket Software  Copyright 1990
  ;  People who own poodles should not attempt to use this software.
 (DEFUN C:CHGX ( / as aa nst ntt au zz xx rr)
  (setvar "cmdecho" 0)
  (command "undo" "mark")
  (setq as ())
  (while (null as)
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
                             (progn
                             (setq st ())
                             (write-line "There are no more entities.")))))))
  (if st
        (progn
              (setq as (getint "\nAssociation number to replace or <Return> for another entity: "))
              (setq aa (entget st)))
        (setq as t)))
  (if (/= as T) (progn
  (if (>= 9 as)
      (setq au (getstring "New (string) value: ")))
  (if (and (<= 10 as) (>= 37 as))
      (setq au (getpoint "New point: ")))
  (if (and (<= 38 as) (>= 59 as))
      (setq au (getreal "New (real number) value: ")))
  (if (and (<= 60 as) (>= 79 as))
      (setq au (getint "New (integer) value: ")))a
  (if (and (<= 210 as) (>= 239 as))
      (setq au (getpoint "New point: ")))
  (if (= 999 as)
      (setq au (getstring t "New (string) value: ")))
  (setq zz (cons as au))
  (if (setq xx (assoc as aa))
      (setq rr (entmod (subst zz xx aa)))
      (setq rr (entmod (append aa (list zz)))))
  (if rr
        (progn
              (write-line "Modification successful. ")
              (entupd st))
        (write-line "Unable to make such a change."))
 ))
 (PRINC))