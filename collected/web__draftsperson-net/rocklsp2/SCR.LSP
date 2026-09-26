  ;  SCR - Script loader
  ;  By SW for Rocket Software  Copyright 1991
  ;  Saves a few seconds...largely by sharing defaults with
  ;  XX.lsp and Find.lsp.  Useful if you use scripts a lot...
  (DEFUN C:SCR (/ fn)
    (if (= (type ff) 'str)
          (setq tt (strcat "Script to load <" ff ">: "))
          (setq tt "Script to load: "))
    (setq fn (getstring T tt))
    (if (/= fn "") (setq ff fn))
    (setq len (strlen ff))
    (while (and (< 1 len) (/= (substr ff len 1) "."))
           (setq len (1- len)))
    (if (> len 1)
        (setq fn (substr ff 1 (1- len))))
    (command "script" fn)
    (PRINC))