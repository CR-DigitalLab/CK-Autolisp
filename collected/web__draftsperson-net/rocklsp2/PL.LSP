  :  Plot command utility
  ;  Generates and runs a short script file
  ;  By SW for Rocket Software  1991
  ;    For that small minority
  ;         who don't think that tedium is morally desirable.
  (DEFUN C:PL (/ dd ll fp fn nn)
   (setvar "cmdecho" 0)
   (if (setq fn (Open "name.txt" "r"))
       (progn
             (setq nn (read-line fn))
             (close fn))
       (progn
             (setq fn (open "name.txt" "w"))
             (setq nn (getstring "Your initials:"))
             (write-line nn fn)
             (close fn)))
   (setq nn (substr nn 1 3))
   (setq dd (getvar "dwgname"))
   (setq ll (- (strlen dd) 4))
   (if (< ll 1)
       (setq ll 1))
   (setq dd (substr dd ll))
   (setq ll 1)
   (while (< ll 5)
          (if (or (= (substr dd ll 1) (chr 92))
                  (= (substr dd ll 1) ":"))
              (setq dd (substr dd (1+ ll))))
          (setq ll (1+ ll)))
   (setq dd (strcat "d:/plot/" nn dd))
   (setq fp (Open "plot.scr" "w"))
   (write-line "plot" fp)
   (write-line " " fp)
   (write-line dd fp)
   (Close fp)
   (command "script" "plot")
   (PRINC))