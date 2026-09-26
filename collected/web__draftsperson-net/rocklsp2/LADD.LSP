 ; Line adder for fragmented text. Also removes excess intermediate spaces.
 ; By SW 1991
 ; For  those   drawings done by     the  illit erate.
 (defun C:LADD ( / ta tb txa txa1 txb)
   (setvar "cmdecho" 0)
   (command "undo" "mark")
   (if (setq ta (entsel "Select base text line:"))
       (setq ta (entget (car ta))))
   (if (setq tb (entsel "\nSelect end line:"))
       (setq tb (entget (car tb))))
   (if (and (= "TEXT" (cdr (assoc 0 ta)))
            (= "TEXT" (cdr (assoc 0 tb))))
       (progn
             (setq txa1 (setq txa (cdr (assoc 1 ta))))
             (while (= (substr txa (strlen txa) 1) " ")
                    (setq txa (substr txa 1 (1- (strlen txa)))))
             (setq txb (cdr (assoc 1 tb)))
             (while (= (substr txb 1 1) " ")
                    (setq txb (substr txb 2)))
             (setq sp (getstring "\nInsert intervening space? <Y>:"))
             (if (or (= sp "y") (= sp "Y") (= sp ""))
                 (setq txa (strcat txa " " txb))
                 (setq txa (strcat txa txb)))
             (entdel (cdar tb)) 
             (entmod (subst (cons 1 txa) (cons 1 txa1) ta))))
 (PRINC))