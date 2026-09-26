  ;  Text To Title (without path).
  ;  by SW for Rocket Software  Copyright 1990
  ;  Contains SNAME.LSP as an added bonus.
 (DEFUN C:TXN ( / tt name len ll lll zz)
   (setvar "cmdecho" 0)
   (command "undo" "mark")
   (if (> (setq len (strlen (setq tt (getvar "dwgname")))) 8)
       (setq tt (substr tt (- len 7))))
   (grtext 0 tt)
   (setq ll (strlen tt))
   (while (< 0 ll)
          (if (= (substr tt ll 1) (chr 92))
              (progn
                    (setq tt (substr tt (1+ ll)))
                    (setq ll 1)))
          (setq ll (1- ll)))
   (setq lll (entget (car (entsel "Select Text:"))))
   (setq zz (assoc 1. lll))
   (entmod (subst (cons 1 tt) zz lll))
   (PRINC))