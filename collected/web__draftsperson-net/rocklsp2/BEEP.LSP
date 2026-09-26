  ; Beep: a routine which, as you might suspect, produces a beep.
  ; Copyright 1991  Rocket Software
  ; It can be incorporated into other lisp routines or used as is in
  ; script or batch files.  Then your computer will be able to wake you up
  ; when it's finished doing your work.
 (defun C:BEEP ()
   (textscr)
   (write-line "")
   (graphscr)
  (PRINC))