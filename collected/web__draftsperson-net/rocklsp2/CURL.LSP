  ;  Move entities to the current layer.
  ;  Copyright 1990   Rocket Software
  ;  Handy if you're inclined to forget where you are.
 (DEFUN C:CURL ( / tt zz ss num aa obj xx)
   (command "undo" "mark")
   (write-line (strcat "Pick objects to move to "
                        (setq zz (getvar "clayer")) ":"))
   (if (setq ss (ssget))
       (progn
             (setq num 0)
             (while (setq aa (ssname SS 0))
                    (setq obj (entget aa))
                    (setq xx (assoc 8 obj))
                    (entmod (subst (cons 8 zz) xx obj))
                    (ssdel aa ss)
                    (setq num (1+ num)))
             (if (= num 1)
                 (setq tt " item") (setq tt " artifacts"))
                 (write-line (strcat (itoa num) tt 
                            " moved to layer " zz))
                 (setq ss nil))
           (write-line "No entities selected"))
 (PRINC))