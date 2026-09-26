   ; XX - Editor start - uses acad.pgp command XXX to shell out to
   ; a text editor (See the file "sample.pgp"). Adds ".lsp" to the
   ; filename automatically and saves the filename as the default.
   ; The ff variable is also used as the default by Ld.lsp, Find.lsp
   ; and Scr.lsp so that a file can be passed between functions
   ; without repeatedly re-entering the file name.
  (defun C:XX (/ fn tt len ll ch)
    (if (= (type ff) 'str)
          (setq tt (strcat "Lisp file <" ff ">: "))
          (setq tt "Lisp file: "))
    (setq fn (getstring T tt))
    (if (/= fn "") (setq ff fn))
    (setq len (strlen ff))
    (setq ll 1)
    (while (< ll len)
           (if (= (substr ff ll 1) ".")
               (setq ch T))
           (setq ll (1+ ll)))
    (if (null ch)
        (setq fn (setq ff (strcat ff ".lsp")))
        (setq fn ff))
    (command "xxx" fn)
    (PRINC))