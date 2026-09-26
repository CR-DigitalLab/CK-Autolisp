  ; Draw a circle with the same diameter as the Earth.
  ; (Several optional units are provided.)
  ; By SW for Rocket Software  Copyright 1991
  ; Bet you wish you had thought of this.
 (DEFUN C:EARTH ()
  (setvar "cmdecho" 0)
  (command "circle" (getvar "viewctr") "6378160000")  ; mm
;  (command "circle" (getvar "viewctr") "6378160")    ; metres
;  (command "circle" (getvar "viewctr") "251108000")  ; inches
;  (command "circle" (getvar "viewctr") "20925667")   ; feet
  (command "zoom" "a")
  (PRINC))