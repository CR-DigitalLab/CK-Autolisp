  ;  Set limits to extents
  ;  by SW for Rocket Software  Copyright 1991
  ;  You might want to do a Zoom All before running this.
  ;  You could live without Rocket Software...maybe at gunpoint...
 (defun C:LIX ()
  (command "limits" (getvar "extmin") (getvar "extmax"))
  (PRINC))