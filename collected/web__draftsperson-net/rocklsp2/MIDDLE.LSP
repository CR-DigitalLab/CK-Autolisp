  ; Convert text to middle justified text.
  ; Copyright 1991  Rocket Software
  ; This routine will centre text in a box
  ; if diagonally opposite corners are picked.
  ; Warning: do not use with the Grinley 411 Steam Monitor.
 (DEFUN C:MIDDLE ( / aa bb cc nn72 ll rr xa ya)
   (setvar "cmdecho" 0)
   (command "undo" "mark")
   (setq aa (entget (car (entsel "Select text to middle justify:\n"))))
   (if (= (cdr (assoc 0 aa)) "TEXT") (progn
   (setq bb (cdr (assoc 10 aa)))
   (setq cc (cdr (assoc 11 aa)))
   (setq nn72 (assoc 72 aa))
   (if (or (= (cdr nn72) 0)
           (= (cdr nn72) 5)
           (= (cdr nn72) 3))
       (progn
             (setq ll (getpoint bb 
                         "Pick one side or <Return> for current insertion: "))
             (if ll
                 (progn 
                       (setq rr (getpoint ll
                                   "\n...and the other side or <Return>:"))
                       (if rr
                           (progn
                                 (setq xa (/ (+ (car ll) (car rr)) 2))
                                 (setq ya (/ (+ (cadr ll) (cadr rr)) 2))
                                 (setq ll (list xa ya))))
                       (setq aa (subst (cons 11 ll) (assoc 11 aa) aa)))
                 (setq aa (subst (cons 11 bb) (assoc 11 aa) aa))))
       (progn
             (setq ll (getpoint cc 
                         "Pick one side or <Return> for current insertion: "))
             (if ll
                 (progn 
                       (setq rr (getpoint ll
                                   "\n...and the other side or <Return>:"))
                       (if rr
                           (progn
                                 (setq xa (/ (+ (car ll) (car rr)) 2))
                                 (setq ya (/ (+ (cadr ll) (cadr rr)) 2))
                                 (setq ll (list xa ya))))
                       (setq aa (subst (cons 11 ll) (assoc 11 aa) aa)))
                 (setq aa (subst (cons 11 cc) (assoc 11 aa) aa)))))
   (entmod (subst (cons 72 4) nn72 aa))))
 (PRINC))