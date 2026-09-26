  ;  Reaction Time Tester
  ;  Copyright 1990   Rocket Software
  ;  See if you're really losing your grip.
 (DEFUN C:RT ( / s t1 t2 num nnum et mlst mm)
    (setvar "cmdecho" 0)
    (write-line "Ready?")
    (setq num 0)
    (setq s (* (getvar "cdate") 10000000.0))
    (setq nnum (fix (* 35 (- s ( fix s)))))
    (while (/= num (+ nnum 127))
           (princ)
           (setq num (1+ num)))
    (setq s (getvar "date"))
    (setq t1 (* 86400.0 (- s (fix s))))
    (write-line "NOW!")
    (while (not (grread)))
    (setq s (getvar "date"))
    (setq t2 (* 86400.0 (- s (fix s))))
    (setq ET (- t2 t1 0.05))
    (write-line (strcat "Reaction time: " (rtos et 2 3) " seconds."))
    (if (>= 0.175 ET)
        (write-line "Unbelievable."))
    (if (and (< 0.175 ET) (> 0.245 ET))
        (write-line "Tolerable."))
    (if (<= 0.245 ET)
        (progn
              (setq s (* (getvar "cdate") 10000000.0))
              (setq nnum (fix (* 10 (- s ( fix s)))))
              (setq mlst (list "How long have you been smoking that?"
                               "Pretty good, for one so recently deceased."
                               "What do you do for an encore - pass out?"
                               "Would you like me to explain this again?"
                               "You probably haven't used a keyboard before."
                               "Use your hand, not your tongue"
                               "We also make a Walk-and-chew-gum tester."
                               "Well, you're probably good at darts."
                               "Just what qualifications were you hired for?"
                               "Are you the one they call 'The Kid'?"))
             (setq mm (nth nnum mlst))
             (prompt mm)))
 (PRINC))