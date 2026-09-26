   ;   SeQuential text change
   ;   Copyright 1990   Rocket Software
   ;   Smoke Havana cigars...and use Rocket Software
 (defun C:SQ ( / SS CC NUM LLL LLN ZZ TT e)
   (setvar "cmdecho" 0)
   (grtext -1 " Rocket Software")
   (write-line "Select some text (several if you wish).")
   (setq ss (ssget))
   (if (null ss)
       (write-line "You missed")
       (progn
   (setq num 0 ign 0 obj 0)
   (while (ssname ss 0)
          (setq lll (ssname ss 0))
          (setq lln (entget lll))
          (if (= "TEXT" (cdr (assoc 0 LLN)))
              (progn
                    (redraw lll 3) 
                    (setq zz (cdr (assoc 1 lln)))
                    (setq TT (strcat "<"
                                     (cdr (assoc 1 (entget (ssname ss 0))))
                                     "> New text: "))
                    (setq CC (getstring t tt))
                    (if (not (equal cc ""))
                        (progn
                              (command "undo" "mark")
                              (setq e (subst (cons 1 cc) (cons 1 zz) lln))
                              (entmod e)
                              (setq num (1+ num)))
                        (progn
                              (redraw lll 1) 
                              (setq ign (1+ ign)))
                    )
              )
              (setq obj (1+ obj))
          )
              (ssdel LLL SS)
          )
   (setq ss nil)
   (if (or (< 0 num) (< 0 ign))
       (progn
             (setq ss (strcat "Text strings rehashed: " (ITOA num)))
             (if (< 0 ign)
                 (setq ss (strcat ss "   Strings unadulterated: " (itoa ign))))
             (write-line ss)
             (if (= 1 obj)
                 (write-line "   ...and one non-text item ignored"))
             (if (< 1 obj)
                 (write-line (strcat "   ...and " (itoa obj) 
                                     " other entities ignored")))))
   (if (and (= 0 num) (= 1 obj) (= 0 ign))
       (progn
       (write-line "I'm sorry but that wasn't text. ")
       (write-line "You cretin.  ")))
   (if (and (= 0 num) (= 0 ign) (< 1 obj))
       (write-line (strcat (itoa obj) " entities, no text. ")))
   ))
   (grtext)
   (PRINC))