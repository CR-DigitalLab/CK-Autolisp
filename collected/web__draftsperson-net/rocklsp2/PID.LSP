  ; Pid: add a prefix and/or suffix to a text string.
  ; Copyright 1991  Rocket Software
  ; A single space is interpreted as an empty string.
 (defun C:PID ( / cc lln zz ppref psuff)
  (setvar "cmdecho" 0)
  (command "undo" "mark")
  (if (and pref suff) 
      (progn
           (setq lln (entsel "Pick text or Return to edit pre/suffix: "))
           (if lln
               (if (= "TEXT" (cdr (assoc 0 (setq nnn (entget (car lln))))))
                   (progn
                        (setq zz (cdr (assoc 1 nnn)))
                        (setq cc (strcat pref zz suff))
                        (entmod (subst (cons 1 cc) (cons 1 zz) nnn)))
                   (prompt "That was not text")))))
  (if (null lln)
      (progn
           (if (= (type pref) 'STR)
               (progn
                    (setq ppref (getstring t (strcat "\nPrefix <" pref ">: ")))
                    (if (/= ppref "") (setq pref ppref)))
               (setq pref (getstring t "Prefix: ")))
           (if (= pref " ") (setq pref ""))
           (if (= (type suff) 'STR)
               (progn
                    (setq psuff (getstring t (strcat "\nSuffix <" suff ">: ")))
                    (if (/= psuff "") (setq suff psuff)))
               (setq suff (getstring t "Suffix: ")))
           (if (= suff " ") (setq suff ""))))
 (PRINC))