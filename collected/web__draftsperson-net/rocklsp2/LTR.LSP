   ;  LTR - letter writing utility - writes to a text file
   ;  from the command line. (Can interrupt & resume later.)
   ;  Work on your correspondence from within autocad.
   ;  Copyright 1991   Rocket Software
 (DEFUN C:LTR (/ tt ffx fn txt)
   (setvar "cmdecho" 0)
   (if (= (type ff) 'str)
       (setq tt (strcat "Filename <" ff ">: "))
       (setq tt "filename: "))
   (setq ffx (getstring tt))
   (if (/= ffx "")
       (setq ff ffx))
   (if (setq fn (Open ff "r"))
       (progn
             (while (setq tt (read-line fn))
                    (setq txt tt))
             (Close fn)
             (if txt (write-line (strcat "Last line in file: <" txt ">"))
                     (write-line "Existing (empty) file.")))
       (write-line "New file."))
   (setq fn (Open ff "a"))
   (while (/= (setq txt (getstring t "Text: ")) "")
          (write-line txt fn))
   (Close fn)
   (PRINC))