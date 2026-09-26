 ;  LD - Lisp loader
 ;  By SW for Rocket Software  1991
 ;  Saves time wasted on repeated typing errors.
 ;  Shares ff default with XX.lsp and Find.lsp for easy editing & reloading.
  (DEFUN C:LD (/ fn tt)
    (if (= (type ff) 'str)
          (setq tt (strcat "File to load <" ff ">: "))
          (setq tt "File to load: "))
    (setq fn (getstring T tt))
    (if (/= fn "") (setq ff fn))
    (setq fn (load ff))
    (print fn)
  (PRINC))