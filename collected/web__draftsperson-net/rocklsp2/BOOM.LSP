  ; Boom: zoom previous and draw a temporary box around the previous view.
  ; By SW for Rocket Software  Copyright 1991
  ; The program Godzilla uses to find his way around Tokyo.
 (defun C:BOOM ( / ra a vs ctr w maxx minx maxy miny aa bb cc dd)
    (setq ra (getvar "regenmode"))
    (setvar "regenmode" 1)
    (setq a (getvar "screensize"))           ; view height & width (pixels)
    (setq a (/ (car a) (cadr a)))            ; view width/height ratio
    (setq vs (* (getvar "viewsize") 0.5))    ; view height in drawing units
    (setq ctr (getvar "viewctr"))            ; centre point of screen
    (setq w (* vs a ))                       ; view half width
    (setq maxx (+ (car ctr) w))
    (setq minx (- (car ctr) w))
    (setq maxy (+ (cadr ctr) vs))
    (setq miny (- (cadr ctr) vs))
    (setq AA (list minx miny))
    (setq BB (list minx maxy))
    (setq CC (list maxx maxy))
    (setq DD (list maxx miny))
    (command "zoom" "p")
    (grdraw AA BB 7 1)
    (grdraw BB CC 7 1)
    (grdraw CC DD 7 1)
    (grdraw DD AA 7 1)
    (setvar "regenmode" ra)
    (princ))