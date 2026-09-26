   ;  Text to middle justified text.
   ;  Copyright 1990   Rocket Software
   ;  Use the side positioning option to put a diagonal line
   ;  across a box, this will centrally position the text.
 (DEFUN C:TTM (/ dd nn zz hh ss tt fh cc ee xa ya)
   (setvar "cmdecho" 0)
   (command "undo" "mark")
   (setq dd (car (entsel "\nPick text:"))
         nn (entget dd)
         zz (cdr (assoc 1. nn))
         hh (cdr (assoc 40 nn))
         tt (getvar "textstyle")
         fh (cdr (assoc 40 (tblsearch "style" tt))))
   (setq ss (getpoint "\nPick new midpoint or <Return> for side positioning:"))
   (if (null ss)
       (progn
             (setq cc (getpoint "\nPick one side:"))
             (setq ee (getpoint cc "\n...and the other:"))
             (setq xa (/ (+ (car cc) (car ee)) 2))
             (setq ya (/ (+ (cadr cc) (cadr ee)) 2))
             (setq ss (list xa ya))))
   (entdel dd)
   (if (= fh 0.0)
       (command "text" "m" ss hh "" zz)
       (command "text" "m" ss "" zz))
   (PRINC))