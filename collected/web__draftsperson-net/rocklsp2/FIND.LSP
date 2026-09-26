  ;  By SW for Rocket Software  1991
  ;  An implementation of the "Findfile" function.
  ;  Shares the ff default variable with XX.lsp, Scr.lsp and LD.lsp.
  (DEFUN C:FIND (/ tt fn)
    (if (= (type ff) 'str)
          (setq tt (strcat "Filename <" ff ">: "))
          (setq tt "Filename: "))
    (setq fn (getstring T tt))
    (if (/= fn "") (setq ff fn))
    (setq fn (findfile ff))
    (if (null fn)
        (write-line "Can't find that one, old boy.")
        (print fn))
    (PRINC))