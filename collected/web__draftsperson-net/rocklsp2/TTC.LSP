  ;  Text to centred text 
  ;  Copyright 1990   Rocket Software
  ;  Caution: if the side positioning option is used
  ;  text will be positioned halfway between the selected points
  ;  both horizontally and vertically.
 (DEFUN C:TTC (/ dd nn zz hh ss tt fh cc ee xa ya)
   (setvar "cmdecho" 0)
   (command "undo" "mark")
   (setq dd (car (entsel "\nPick text:"))
         nn (entget dd)
         zz (cdr (assoc 1. nn))
         hh (cdr (assoc 40 nn))
         tt (getvar "textstyle")
         fh (cdr (assoc 40 (tblsearch "style" tt))))
   (setq ss (getpoint "\nPick new centre or <Return> for side positioning:"))
   (if (null ss)
       (progn
             (setq cc (getpoint "\nPick one side:"))
             (setq ee (getpoint cc "\n...and the other:"))
             (setq xa (/ (+ (car cc) (car ee)) 2))
             (setq ya (/ (+ (cadr cc) (cadr ee)) 2))
             (setq ss (list xa ya))))
   (entdel dd)
   (if (= fh 0.0)
       (command "text" "c" ss hh "" zz)
       (command "text" "c" ss "" zz))
   (PRINC))