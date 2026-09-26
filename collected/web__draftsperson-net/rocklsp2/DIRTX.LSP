   ;  Copy directory listing to text file, optional alphabetic sort
   ;  and/or edit out everything but filenames.
   ;  by SW for Rocket Software   Copyright 1991
   ;  A good example of what lisp can do,
   ;  and useful for many things such as...well...
  (DEFUN C:DIRTX (/ dd nn yy mm ch fp len fn fo tt txt ffx fn txt)
   (setvar "cmdecho" 0)
   (setq dd (Getstring T "Directory specification:"))
   (setq nn (Getstring T "Filename? <Dirinfo.txt>:"))
   (if (= nn "") (setq nn "Dirinfo.txt"))
   (setq yy (getstring "Sort alphabetically? <Y>"))
   (if (or (equal yy "") (equal yy "y") (equal yy "Y"))
       (setq dd (strcat "dir " dd " | sort > " nn))
       (setq dd (strcat "dir " dd " > " nn)))
   (setq mm (getstring "Create *filenames only* text file? <Y>"))
   (if (or (equal mm "") (equal mm "y") (equal mm "Y"))
       (setq ch t))
   (setq fp (Open "Dirinfo.bat" "w"))
   (write-line dd fp)
   (Close fp)
   (command "shell" "dirinfo")
   (command "shell" "del Dirinfo.bat")
   (write-line (strcat "File created: " nn))
   (if (and ch
            (setq fn (Open nn "r"))
            (setq fo (Open "dirinf.del" "w")))
       (progn
             (write-line "Processing...")
             (while (setq tt (read-line fn))
                    (setq txt tt)
                    (if (and (/= (substr txt 1 1) " ")
                             (/= (substr txt 1 1) ".")
                             (/= txt ""))

                        (progn
                              (setq txt (substr txt 1 12))
                              (setq len 1)
                              (while (/= (substr txt len 1) " ")
                                     (setq len (1+ len)))
                              (setq txa (substr txt 1 (1- len)))
                              (setq txb (substr txt 10))
                              (setq txt (strcat txa "." txb))
                              (write-line txt fo)))
             )
             (Close fn)
             (close fo)
             (command "shell" (strcat "del " nn))
             (command "shell" (strcat "ren dirinf.del " nn))
             (write-line (strcat "*" nn "*")))
       (if ch
           (write-line "You got a problem somewhere, mac.")))
   (PRINC))