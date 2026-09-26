  ;  Position switcher
  ;  Copyright 1990   Rocket Software
  ;  For those who die a thousand deaths with each wasted keystroke.
  (DEFUN C:SWX ( / SS1 SS2 P1 P2)
   (WRITE-LINE "Select lot #1\n")
   (SETQ SS1 (SSGET))
   (SETQ P1 (GETPOINT "First point\n"))
   (WRITE-LINE "Select lot #2\n")
   (SETQ SS2 (SSGET))
   (SETQ P2 (GETPOINT P1 "Second point\n"))
   (COMMAND "MOVE" SS1 "" P1 P2)
   (COMMAND "MOVE" SS2 "" P2 P1)
   (WHILE (SETQ XA (SSNAME SS1 0))
          (REDRAW XA)
          (SSdel XA SS1))
   (SETQ SS1 ()
         SS2 ())
   (PRINC))