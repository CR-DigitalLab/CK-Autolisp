  ;  Change attribute to drawing name.
  ;  By SW for Rocket Software  1991
  ;  For people who use attributes in title blocks
  ;  against the dictates of common sense.
  (DEFUN C:ATTNAME (/ dd ll fp)
   (setvar "cmdecho" 0)
   (setq fp (getpoint "Pick attribute (with crosshairs - don't be alarmed):"))
   (setq dd (getvar "dwgname"))
   (setq ll (- (strlen dd) 7))
   (setq dd (strcase (substr dd ll)))
   (command "attedit" "" "" "" "" fp "" "v" "r" dd "")
   (PRINC))
