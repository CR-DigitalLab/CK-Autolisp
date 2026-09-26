  ;  Zoom Extents with (usually) no regen.
  ;  By SW (and probably numerous others)
  ;  This saves getting lost in endless zoom p's.
 (DEFUN C:ZE ( / a b ) 
  (setvar "cmdecho" 0)
  (setq a (getvar "extmin"))
  (setq b (getvar "extmax"))
  (command "zoom" "w" a b)
  (PRINC))