  ; Find file or files with the same name and a different extension.
  ; by SW for Rocket Software  Copyright 1991
  ; Neater than "shell & dir" and sets ff default for XX, Ld, and Scr.
  ; (You can edit the list of extensions for which to search.)
  (DEFUN C:FINDX (/ tt fn typ ll ch)
    (if (= (type ff) 'str)
          (setq tt (strcat "Filename <" ff ">: "))
          (setq tt "Filename: "))
    (setq fn (getstring T tt))
    (setq ch ())
    (if (/= fn "") (setq ff fn))
    (setq fn (findfile ff))
    (if fn
        (progn
              (print fn)
              (setq ch t))
        (progn
              (write-line (strcat "Can't find " ff))
              (write-line "Searching for similar files:")
              (setq len (strlen ff))
              (setq ll 1)
              (while (<= ll len)
                     (if (= (substr ff ll 1) ".")
                         (progn
                               (setq ff (substr ff 1 (1- ll)))
                               (setq ll len))
                         (setq ll (1+ ll))))
              (setq typ (list ".lsp" ".exe" ".com" ".bat" ".old" ".cfg" ".dwg"
                              ".zip" ".dat" ".scr" ".txt" ".bak" ".err" ".shx"
                              ".lin" ".pat" ".tnt" ".pgp" ".doc" ".cnf" ".hlp"
                              ".exp" ".hdx" ".mnu" ".mid" ".mnx" ".plt" ".slb"
                              ".arc" ".zac"))
              (setq ll 0)
              (while (nth ll typ)
                     (setq fn (strcat ff (nth ll typ)))
                     (setq fn (findfile fn))
                     (if fn (progn (print fn) (setq ch t)))
                     (setq ll (1+ ll)))))
    (if (null ch)
        (write-line "Can't find anything like that, old boy."))
    (PRINC))