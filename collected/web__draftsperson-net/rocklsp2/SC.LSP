  ;  Style Change
  ;  Copyright 1991  Rocket Software
  ;  Welcome to the 20th Century.
 (DEFUN C:SC ( / SS CC NUM LLL LLN ZZ TT e)
  (setvar "cmdecho" 0)
  (setq b (cdr (assoc 2 (tblnext "style" t))))
  (setq a (cdr (assoc 2 (tblnext "style"))))
  (if (not (eq a nil))
      (progn
            (setq b (list a b))
            (while (not (eq a nil))
                   (setq a (cdr (assoc 2 (tblnext "style"))))
                   (if (not (eq a nil)) (setq b (cons a b))))
            (grtext 2 "        ")
            (grtext 3 "CHOOSE")
            (grtext 4 "STYLE")
            (grtext 5 "        ")
            (setq num 5)
            (setq nb b)
            (while b
                    (setq num (1+ num))
                    (setq a (car b))
                    (setq b (cdr b))
                    (grtext num a)
            )
            (setq x 1)
            (while (< x 3)
                   (grtext (+ num x) "        ")
                   (setq x (1+ x))
            )
            (prompt "Select text to change:")
            (setq ss (ssget))
            (grread)
            (if (= "TEXT" (cdr (assoc 0 (entget (ssname SS 0)))))
                (prompt (strcat "Select style from screen menu <" 
                                 (cdr (assoc 7 (entget (ssname ss 0)))) "> "))
                (prompt "Select style from screen menu" ))
            (setq xn (- (cadr (grread)) 6))
            (setq cc (nth xn nb))
            (setq num 0)                                ; Start counter
            (while (ssname ss 0)                        ; while there is a #1 
                   (setq lll (ssname ss 0))             ; get 1st entity name
                   (setq lln (entget lll))              ; get the whole thing
                   (if (= "TEXT" (cdr (assoc 0 LLN)))   ; Is entity text?
                       (progn
                       (setq num (1+ num))              ; increment counter
                       (SETQ zz (cdr (assoc 7 lln)))    ; get text string
                       (setq e (subst (cons 7 cc) (cons 7 zz) lln)) ; replace
                       (entmod e)                       ; Modify the original
                       ))                               ; progn end, if end
                   (ssdel lll ss)                       ; remove from sel. set
            )                                           ; while end
            (setq ss ())
            (if (= num 0)
                (prompt "\nNo lines changed")
                (prompt (strcat "\nLines changed: " (ITOA num)
                                "   New style: " CC)))
      )
  (write-line "It's difficult to change styles when only one is defined."))
  (grtext)
  (PRINC))