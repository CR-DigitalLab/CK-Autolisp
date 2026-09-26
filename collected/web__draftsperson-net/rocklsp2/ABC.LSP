  ; ABC - Put text entities in alphabetical order (vertically).
  ; Copyright 1991  Rocket Software
  ; Give hindsight the leverage it needs.
  (DEFUN C:ABC (/ co lu fn ss lll lln num zz cc)
   (setvar "cmdecho" 0)
;***************** Write text to file ***************
   (setq fn (open "aaaa.txt" "w"))
   (close fn)
   (setq fn (open "aaaa.txt" "a"))
   (write-line "Select some text entities:")
   (setq ss (ssget))
   (setq num 0)
   (while (setq lll (ssname ss num))
          (setq lln (entget lll))
          (setq num (1+ num))
          (if (= "TEXT" (cdr (assoc 0 lln)))
              (write-line (cdr (assoc 1 lln)) fn)
              (progn
                    (setq num (1- num))
                    (ssdel lll ss))))
   (close fn)
;***************** Sort text file alphabetically ***************
   (command "shell" "sort < aaaa.txt > zzzz.txt")
   (graphscr)
   (setq fn (open "zzzz.txt" "r"))
;***************** Find highest text insertion ***************
   (setq lu (getvar "luprec"))
   (setvar "luprec" 7)
   (while (ssname ss 0)
          (setq num 0)
          (setq zz "(max ")
          (while (setq lll (ssname ss num))
                 (setq lln (entget lll))
                 (setq num (1+ num))
                 (setq zz (strcat zz " " (rtos (caddr (assoc 10 lln))))))
          (setq zz (strcat zz ")"))
          (setq hh (eval (read zz)))
;***************** Find & modify highest text ***************
          (setq num 0)
          (while (setq lll (ssname ss num))
                 (setq lln (entget lll))
                 (setq num (1+ num))
                 (setq nn (caddr (assoc 10 lln)))
                 (if (equal nn hh 0.000001)
                     (progn
                           (ssdel lll ss)
                           (setq cc (read-line fn))
                           (entmod (subst (cons 1 cc) (assoc 1 lln) lln))))
   ))
   (close fn)
   (setq ss ())
   (setvar "luprec" lu)
   (PRINC))