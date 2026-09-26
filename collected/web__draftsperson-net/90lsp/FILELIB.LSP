;;;*; DO NOT LSPSTRIP - MERGEF contains ;'s
;;; AutoLISP File for
;;; Maximizing AutoLISP - IL DISK (c) 1987, '88, '89, '91, '92 New Riders Publ.
;;;                Version 12.00 for Release 12 PC-DOS/MS-DOS                 
;;;       Developed by Rustin Gesner, Joseph Smith, and Patrick Haessly       
;;;
;;;       Permission to use, copy, modify, and distribute this software       
;;;       for any purpose is hereby granted, provided that no fees are        
;;;       collected directly or indirectly and that the above copyright       
;;;       notice and this permission notice appear in all copies and in       
;;;       all supporting documentation. See IL DISK DISCLAIMER.TXT file.
;;;
;;;* FILELIB.LSP contains several file handling utility routines

;;;* CPATH returns the current DOS, OS/2 or Unix path, in the form:
;;;* "d:\\path\\...\\" or "/path/.../".
;;;* WARNING: If DOS or OS/2 APPEND is used results may be FALSE UNPREDICTABLY.
;;;*
(defun cpath ( / path fp slash)
                            ;Create 0 byte file, overwrite if existing...
  (close (open "$" "w"))    ;...allows READ-LINE to test SHell's success
  (command "SHELL"          ;Redirect current dir to temp file $
    (cond 
      ( (getenv "COMSPEC") (setq slash "\\") "CD   >  $")      ;If DOS or OS/2
      ( (getenv "USER")    (setq slash "/" ) "dirs >! $")      ;If Unix
      (T (prompt "\nUNKNOWN OPERATING SYSTEM for CPATH function. "))
  ) );command&cond
  (setq fp (open "$" "r"))
  (if (setq path (read-line fp))                ;Nil only if SHELL failed
    (if (/= slash (substr path (strlen path)))  ;If path has no trailing slash
      (setq path (strcat path slash))           ;Add it
    )                                     
    (progn (prompt "\nSHELL FAILED!")       ;Else prompt, and
           (setq path ""))                  ;set path to "", if SHELL failed
  )
  (close fp)
  (close (open "$" "w"))                    ;Reduce scratch file to 0 bytes
  path                       ;Return path, which is "" only if SHELL failed
);defun CPATH
;;;*

;;;* RPATH Resets the PATH to the "current AutoCAD drawing directory"
;;;* if changed by user. For DOS or OS/2 only. Requires CPATH function.
;;;*
(defun rpath ( / path)
  (if (equal
        (cpath)                                 ;If current path matches
        (setq path (getvar "DWGPREFIX"))        ;the drawing file's path
      )
      nil                                       ;Then return nil
      (command "SHELL" (strcat "CD "            ;Else change directory
                               (substr path 1 (- (strlen path) 1))))
  );if
);defun
;;;*

;;;* PSLASH PathSLASH converts "\\"s or "/"s in path strings to whichever is 
;;;* needed by the operating system (Unix or DOS and OS/2), and appends a
;;;* trailing "\\" or "/", if not supplied.
;;;*
(defun pslash (path / slash inc wpath char)
  (setq inc 1  wpath ""                                ;Initialize variables
        slash (if (getenv "COMSPEC")
                  "\\" "/")                     ;Set for DOS or OS/2, or Unix
  )
  (while (/= "" (setq char (substr path inc 1)))       ;Test each char
    (setq wpath                                        ;Reassemble string
      (strcat wpath (if (member char '("\\" "/"))
                        slash char))                   ;Append proper char
      inc (1+ inc)                                     ;Increment counter
  ) );while&setq
  (if
    (and (/= wpath "")                                 ;If PATH isn't empty &
      (/= (substr wpath (strlen wpath) 1) slash))      ;last char isn't slash
    (setq wpath (strcat wpath slash))                  ;Add one
  );if 
  wpath
);defun PSLASH
;;;*

;;;* FFNAME formats a filename as "filename.ext" given an input FNAME string
;;;* with or without extension, and EXT as a quoted string. Using "" as EXT
;;;* strips extensions.
;;;*
(defun ffname (fname ext / inc lngth pos)
  (setq inc -1  lngth (strlen fname))     ;Initialize variables
  (while                                  ;Loop
    (not                                  ;until OR is non-NIL
      (or                                 ;Eval 2nd AND only if 1st is NIL
        (and                              ;Setq FNAME either if "." is found
          (/= lngth (setq inc (1+ inc)))  ;Increment counter, compare length
          (= "." (substr fname (- lngth inc) 1))          ;Is last char "."?
          (setq fname                     ;If true so far, strip last char
            (strcat (substr fname 1 (- lngth inc)) ext)    ;and append EXT
          ) 
        ) 
        (and                              ;Or setq FNAME if... 
          (or (= inc 3)                   ;"." isn't one of last 3 chars
              (= inc lngth)               ;or the whole string's been tested
              (<= lngth 2))               ;even if it's only 1 or 2 chars long
          (setq fname (strcat fname "." ext))  ;Then append EXT to whole fname
  ) ) ) )
  fname
);defun
;;;*

;;;* VFFILE verifies a file's existence. It returns fspec or NIL.
;;;* WARNING: DOS or OS/2 APPEND may cause FALSE UNPREDICTABLE results.
;;;* May be called w/ fname specific path "\\path\\filename.ext", or just 
;;;* "filename.ext", which searches ACAD library path or prompts for path.
;;;* Uses PSLASH to return "/"s or "\\"s for Unix or DOS and OS/2.
;;;*
(defun vffile (fspec / fname fp path char prmpt)
  (setq inc -1  lngth (strlen fspec)  fname "") ;Initialize variables
  (while (and (/= lngth (1+ inc))               ;Parse FSPEC into PATH
              (not path))                       ;and FNAME
       (if (member                              ;Look for a slash char
             (setq char                      ;Get current char, back to front
                   (substr fspec (- lngth (setq inc (1+ inc))) 1)
             )
             '("/" "\\")
           );member
           (setq path (substr fspec 1 (- lngth inc)));Set PATH to remainder
           (setq fname (strcat char fname))          ;Else add char to FNAME
  )    )
  (if path nil (setq path ""))                       ;If null, set PATH to ""
  (while                                ;While file can't be opened, reprompt
    (and
      (/= "Q" path)                                  ;Until user Quits
      (not (setq fspec                               ;or file is found
                 (findfile (strcat (pslash path) fname))))
    )
    (setq prmpt                                      ;Build prompt
      (strcat "\n\nFile " fname " not found in " 
        (if (= "" path) "current directory," path)   ;Current dir if path=""
        "\nEnter path to search, or Q to quit: "
      );strcat
      path (strcase (getstring prmpt))
  ) );while & setq
  (if (= "Q" path)                                   ;If user Quit
      (progn (prompt "File not found. ") nil)        ;Returns nil 
      (substr (pslash fspec) 1 (strlen fspec))       ;Otherwise returns FSPEC
  )
);defun vffile
;;;*

;;;* VFPATH is for compatibility with original CA DISK programs which call it 
;;;* with a filename argument. It calls a substitute function, VPATH.
;;;* The FN argument is not used in VPATH.
(defun vfpath (fn) (vpath))
;*

;;;* VPATH prompts for and verifies a PATH. The filename "$." will be left
;;;* behind in the successful directory, as a 0 byte file. Adding
;;;* (command "_.FILES" "3" (strcat (pslash path) "$") "" "")
;;;* will delete it. It calls CPATH to present a default path.
;;;*
(defun vpath ( / char path fp def)
  (setq def (cpath))                             ;Set current path as default
  (while (not path)                              ;Loops until valid path
    (setq path                                   ;Ask user for path name
          (getstring (strcat "\nEnter path name <" def ">: "))
    )
    (if (/= "" path)                             ;If user specified a path
      (if (setq fp                               ;Try opening a temp file
                (open (strcat (pslash path) "$") "a"))
        (close fp)                               ;If opened, just close it
        (setq path (prompt "\nInvalid path, try again."))     ;Else prompt
      );if
      (setq path def)                            ;Else set PATH to CPATH
    );if/=
  );while
  (pslash path)                                  ;Return PATH
);defun VPATH
;;;*

;;;* BACKUP copies file FSPEC to its path\name.BAK, using the FFNAME
;;;* function to format the filename.
;;;*
(defun backup (fspec)
  (command "_.FILES" "5" fspec ;Copy filespec.EXT to 
    (ffname fspec "BAK")       ;filespec w/ EXT stripped & repl w/ BAK
    "" "" nil                  ;Nil cancels error if file didn't exist.
  );command 
);defun
;;;*

;;;* MERGEF appends FILE2 to FILE1, strips FILE1's ^Z if present, and
;;;* deletes FILE2. It uses the VFFILE function to verify the filenames'
;;;* existence. It returns T.
;;;*
(defun mergef (file1 file2)     
  (setq file1 (vffile file1)  file2 (vffile file2))    ;Verifies files
  (cond 
    ( (getenv "COMSPEC")                               ;If DOS or OS/2
      (command "SHELL" (strcat "COPY " file1 " + " file2
                               " "  file1) nil)        ;SHELL to DOS to copy
      (command "SHELL" (strcat "DEL " file2) nil)      ;then to delete FILE2
    ) 
    ( (getenv "USER")                                  ;Else, if Unix
      (command "SHELL" (strcat "cat " file1 file2 " >! $" ;Use cat command
                      " ; mv $ " file1 " ; rm " file2     ;Delete FILE2
      ) nil         );command&strcat              ;Nil cancels if SHELL fails
    )
    (T(prompt "\nUNKNOWN OPERATING SYSTEM for MERGEF function. "))
  );cond
  T                                                       ;Returns T
);defun
;;;*

(princ)
;;;* end of FILELIB.LSP
;;;*
