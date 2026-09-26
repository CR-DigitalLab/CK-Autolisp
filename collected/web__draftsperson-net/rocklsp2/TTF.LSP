  ;  Text To Fit 
  ;  Copyright 1990   Rocket Software
 (DEFUN C:TTF (/ dd nn zz hh ss ee tt fh)
   (setvar "cmdecho" 0)
   (command "undo" "mark")
   (setq dd (car (entsel "\nPick text:"))
         nn (entget dd)
         zz (cdr (assoc 1. nn))
         hh (cdr (assoc 40 nn))
         ss (getpoint "\nPick new start:")
         ee (getpoint ss "\nPick new end:")
         tt (getvar "textstyle")
         fh (cdr (assoc 40 (tblsearch "style" tt))))
   (entdel dd)
   (if (= fh 0.0)
       (command "text" "f" ss ee hh zz)
       (command "text" "f" ss ee zz))
   (PRINC))