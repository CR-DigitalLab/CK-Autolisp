    ;  Box drawer
    ;  Copyright 1991  Rocket Software
    ;  Yes, another box maker -
    ;  admittedly a better one than most...
  (defun c:box ( / AA BB CC DD)
    (setvar "cmdecho" 0)
    (setq AA (getpoint "First corner:"))
    (setq CC (getcorner AA " Other corner:\n"))
    (setq BB (cons (car CC) (cdr AA)))
    (setq DD (cons (car AA) (cdr CC)))
    (command "pline" AA BB CC DD "C")
    (princ))