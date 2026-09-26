; ----- BAK
; Create a .bak copy of the current DWG file
; with a datetime stamp appended to the filename
;
;   local variables
;     bakName: name of directory to store .bak files
;     bakDir: path to bak directory
;     bakPath: full path to .bak file
(defun C:BAK (/ bakName bakDir bakPath)
  	(setq bakName "bak"
	      bakDir (strcat (getvar "DWGPREFIX") bakName "\\") ;change backslash to forwardslash for mac
  	      bakPath (strcat bakDir "[" (datetime) "]" "-" (vl-filename-base (getvar "DWGNAME")) ".bak")
	) ;setq
  	; create a directory named (bakName) in the current directory if it does not exist
	(makedir bakName)
  	(vl-file-copy (strcat (getvar "DWGPREFIX") "\\" (getvar "DWGNAME")) bakPath)
	(princ (strcat "Created a backup file at: " bakPath))
  	(princ)
) ;defun

;-----------------------------------------------------------;
;-------------------- utility functions --------------------;
;-----------------------------------------------------------;

; ----- makedir
; Create the specified directory in the current directory if it does not exist
;
;   dirname: name of directory to create
;
;   local variables
;     direxists: name of directory or nil if it does not exist
(defun makedir (dirname / cdir)
	(setq cdir (vl-directory-files (getvar "DWGPREFIX") dirname -1))
  	(if (not cdir)
		(progn
			(vl-mkdir (strcat (getvar "DWGPREFIX") "//" dirname))
			(vl-directory-files "" dirname -1)
		) ;progn
	) ;if
) ;defun

; ----- datetime
; Get the datetime
(defun datetime ( / d yr mo day hr m s)
     ; get the date and time and convert to text
     (setq d (rtos (getvar "CDATE") 2 6)
 
          yr (substr d 1 4)  	;year
          mo (substr d 5 2)	;month
          day (substr d 7 2)	;day
          hr (substr d 10 2)	;hour
          m (substr d 12 2)	;minute
          s (substr d 14 2)	;second
 
     ) ;setq
  
     ;concatenate 
     (strcat yr mo day "-" hr m s)
) ;defun
