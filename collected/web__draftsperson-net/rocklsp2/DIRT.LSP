 ; This program was designed for use with Batch.lsp.  It writes a directory
 ; listing (you can specify the type using wild cards etc.) to a text file
 ; and removes sizes, dates, extensions and so on leaving a list of file
 ; names which BATCH can combine with a template file to create a script
 ; or batch file.
 ; by SW for Rocket Software   Copyright 1991
 ; Rocket Software: more fun than crash-landing a 747 full of pigs in a swamp.
  (DEFUN C:DIRT (/ dd nn fp len fn fo tt txt ffx fn txt)
   (setvar "cmdecho" 0)
   (setq dd (Getstring "Directory specification <*.dwg>:"))
   (if (= dd "") (setq dd "*.dwg"))
   (setq nn (Getstring "Filename? <Varia.ble>:"))
   (if (= nn "") (setq nn "Varia.ble"))
   (setq dd (strcat "dir " dd " | sort > " nn))
   (setq fp (Open "Dirinfo.bat" "w"))
   (write-line dd fp)
   (Close fp)
   (command "shell" "dirinfo")
   (command "shell" "del Dirinfo.bat")
   (write-line (strcat "File created: " nn))
   (if (and (setq fn (Open nn "r"))
            (setq fo (Open "dirinf.del" "w")))
       (progn
             (write-line "Processing...")
             (while (setq tt (read-line fn))
                    (setq txt tt)
                    (if (and (/= (substr txt 1 1) " ")
                             (/= (substr txt 1 1) ".")
                             (/= txt ""))
                        (progn
                              (setq txt (substr txt 1 10))
                              (setq len 1)
                              (while (/= (substr txt len 1) " ")
                                     (setq len (1+ len)))
                              (setq txt (substr txt 1 (1- len)))
                              (write-line txt fo)))
             )
             (Close fn)
             (close fo)
             (command "shell" (strcat "del " nn))
             (command "shell" (strcat "ren dirinf.del " nn))
             (write-line (strcat "*" nn "*"))))
   (PRINC))