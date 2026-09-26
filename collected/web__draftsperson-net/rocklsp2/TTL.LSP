  ;  Text to left justified text 
  ;  Copyright 1990   Rocket Software
 (DEFUN C:TTL (/ dd nn zz hh ss tt fh)
   (setvar "cmdecho" 0)
   (command "undo" "mark")
   (setq dd (car (entsel "\nPick text:"))
         nn (entget dd)
         zz (cdr (assoc 1. nn))
         hh (cdr (assoc 40 nn))
         ss (getpoint "\nPick new start:")
         tt (getvar "textstyle")
         fh (cdr (assoc 40 (tblsearch "style" tt))))
   (entdel dd)
   (if (= fh 0.0)
       (command "text" ss hh "" zz)
       (command "text" ss "" zz))
   (PRINC))