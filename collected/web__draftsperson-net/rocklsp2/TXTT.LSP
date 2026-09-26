  ;  Text To Title (with path)
  ;  Rocket Software  Copyright 1990
  ;  Computers will free us all from drudgery...
  ;  in the year 2497.
  ;  Until then, use Rocket Software.
 (defun C:TXTT ( / tt lll zz)
   (setvar "cmdecho" 0)
   (command "undo" "mark")
   (setq tt (getvar "dwgname"))
   (setq lll (entget (car (entsel "Select Text: "))))
   (setq zz (assoc 1. lll))
   (entmod (subst (cons 1 tt) zz lll))
  (PRINC))