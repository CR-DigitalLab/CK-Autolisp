 ; Leading and trailing space remover.
 ; By SW 1991
 ; Alternately you could left justify all of your text on the left side
 ; of the drawing and position it by adding spaces to the beginning.
 (defun C:SPARE ( / num ss lll ta txa1 aa bb)
   (setvar "cmdecho" 0)
   (setq num 0)
   (command "undo" "mark")
   (prompt "Select text")
   (setq ss (ssget))
   (while (ssname ss 0)
          (setq lll (ssname ss 0))
          (setq ta (entget lll))
          (if (= "TEXT" (cdr (assoc 0 ta)))
              (progn
                    (setq txa1 (setq txa (cdr (assoc 1 ta))))
                    (while (= (substr txa 1 1) " ")
                           (setq txa (substr txa 2))
                           (setq aa t))
                    (while (= (substr txa (strlen txa) 1) " ")
                           (setq txa (substr txa 1 (1- (strlen txa))))
                           (setq bb t))
                    (if (or aa bb)
                        (progn
                              (setq num (1+ num))
                              (entmod (subst (cons 1 txa) (cons 1 txa1) ta))
                              (setq aa nil bb nil)))))
                    (ssdel lll ss))
   (setq ss ())
 (write-line (strcat "Lines changed: " (itoa num)))
 (PRINC))