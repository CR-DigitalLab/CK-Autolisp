  ; Superimpose the current view on a slide.
  ; Copyright 1991  Rocket Software
  ; Please recycle this information when you are finished with it -
  ; don't let it wind up in a toxic information dump.
 (DEFUN C:STAR (/ sll)
  (if (or (/= (type sld) 'STR) (= sld ""))
      (setq sld "star"))
  (setq sll (getstring (strcat "Slide name <" sld ">:")))
  (if (= sll "") (setq sll sld))
  (command "vslide" sll)
  (command "select" "c" (getvar "extmin") (getvar "extmax") "")
  (setq sld sll)
  (PRINC))