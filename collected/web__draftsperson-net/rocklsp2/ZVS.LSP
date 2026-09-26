  ;  Zoom to virtual screen extents.
  ;  By SW (and probably numerous others)
  ;  This won't regen, but the virtual screen extents
  ;  aren't necessarily the same as the drawing extents.
 (DEFUN C:ZVS () 
  (setvar "cmdecho" 0)
  (command "zoom" "w" (getvar "vsmin") (getvar "vsmax"))
  (PRINC))