   ;  Text Style Change
   ;  Copyright 1990   Rocket Software
   ;  A useful product if you work with chimps (or their equivalent).
 (defun C:ST ( / ss a b cc num lll lln zz tt)
   (setvar "cmdecho" 0)
   (prompt "Select text to change:")
   (setq ss (ssget))                           ; Get text entities
  (if ss
      (progn
   (setq b (cdr (assoc 2 (tblnext "style" t))))
   (setq a (cdr (assoc 2 (tblnext "style"))))
   (if (not (eq a nil))
       (progn
             (setq b (strcat a " " b))
             (while a
                   (setq a (cdr (assoc 2 (tblnext "style"))))
                   (if (not (eq a nil)) (setq b (strcat a " " b))))))
   (write-line (strcat "Defined styles: " b))
   (if (= "TEXT" (cdr (assoc 0 (entget (ssname SS 0)))))
       (setq TT (strcat "New style <" (cdr (assoc 7 (entget (ssname ss 0))))
                        "> or <Return> to select example: "))
       (setq TT "New style or <Return> to select example: "))
   (setq CC (getstring t tt))                  ; Get new style
   (if (= cc "")
       (progn
             (setq nn (entget (car (entsel "Select text:\n"))))
             (if (= "TEXT" (cdr (assoc 0 nn)))
                 (setq cc (cdr (assoc 7 nn))))))
   (setq num 0)                                ; Start counter
   (while (ssname ss 0)                        ; while there is a #1 
          (setq lll (ssname ss 0))             ; get 1st entity name
          (setq lln (entget lll))              ; get the whole thing
          (if (= "TEXT" (cdr (assoc 0 lln)))   ; Is entity text? (group 0)
              (progn
              (setq num (1+ num))              ; increment counter
              (setq zz (cdr (assoc 7 lln)))    ; get text string
              (setq a (entmod (subst (cons 7 cc) (cons 7 zz) lln)))
              ) )                              ; progn end, if end
              (SSDEL lll ss)                   ; remove from sel. set
   )                                           ; while end
   (setq ss ())
   (if a
       (prompt (strcat "Lines restyled: " (ITOA num)))
       (prompt "Undefined style."))))
   (PRINC))