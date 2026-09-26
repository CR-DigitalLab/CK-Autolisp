  ;  Cleaner - automatic purge at any time.
  ;  Copyright 1990   Rocket Software
  ;  Deletes all unreferenced blocks, layers, styles, etc., thus
  ;  saving memory and making drawings load faster; this routine is
  ;  therefore invaluable unless you have unlimited memory and a Cray.
  ;  Another program not of unmitigated subtlety.
 (DEFUN C:CLEANER ()
  (SETQ NN (GETVAR "DWGNAME"))
  (COMMAND "WBLOCK" NN "Y" "*")
  (COMMAND "QUIT" "Y")
 )