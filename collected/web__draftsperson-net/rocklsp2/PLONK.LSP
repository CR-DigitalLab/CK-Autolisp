 ; Plonk: automatic plot generator - plot data is stored in the block QAPLOT.
 ; Rocket Software  Copyright 1991
 ; Yeah, I know, you thought of that years ago.
 (DEFUN C:PLONK ( / atd hi num bl ss rad len so txa pa run nam plot units
                    size file rota scale txb fp dd)
  (setvar "cmdecho" 0)
  (setq atd (getvar "attdia"))
  (setvar "attdia" 1)
  (setq hi (getvar "highlight"))
  (setq num 0)
  (setq ss (ssget "X" '((2 . "QAPLOT"))))
  (setq rad (/ (- (car (getvar "extmax")) (car (getvar "extmin"))) 25))
  (if ss
     (progn
          (setq len (sslength ss))
          (while (setq so (ssname ss num))
                 (setq txa (entget so))
                 (setq pa (cdr (assoc 10 txa)))
                 (grdraw (polar pa (/ pi 4) rad) (polar pa (* 1.25 pi) rad) 7)
                 (grdraw (polar pa (* pi 0.75) rad) (polar pa (* pi 1.75) rad) 7)
                 (setq num (1+ num)))          ; while end
          (while (> (sslength ss) 1)
                 (entdel (ssname ss 0))
                 (ssdel (ssname ss 0) ss))     ; while end
          (if (> len 1) (prompt "Excess insertions of QAPLOT deleted.\n"))
  (setq txb (ssname ss 0))
  (setq run (getstring "Edit, Delete, or <Plot>: "))
  (if (or (= run "P") (= run "p") (= run ""))
      (setq run "P"))
  (if (or (= run "D") (= run "d"))
      (progn
            (entdel txb)
            (prompt "Qaplot deleted.")))
  (if (or (= run "E") (= run "e"))
      (progn
            (setq aa (cdr (assoc -1 (entget txb))))
            (command "ddatte" aa)
            (setq run (getstring "Plot <Y>:"))
            (if (or (= run "Y") (= run "y") (= run ""))
                (setq run "P"))))
  (if (= run "P")
      (progn
 ;********************** Extract parameters from block **********************
  (while (/= (cdr (assoc 0 (entget txb))) "SEQEND")
         (setq nam (cdr (assoc 2 (setq nn (entget txb)))))
         (setq as1 (cdr (assoc 1 nn)))
         (if (= nam "PLOT") (setq plot as1))
         (if (= nam "UNITS") (setq units as1))
         (if (= nam "SIZE") (setq size as1))
         (if (= nam "FILE") (setq file as1))
         (if (= nam "ROTA") (setq rota as1))
         (if (= nam "SCALE") (setq scale as1))
         (setq txb (entnext txb)))
 ;********************** Get drawing name **********************
   (setq dd (getvar "dwgname"))             ; extract dwg name sans path
   (setq ll (- (strlen dd) 8))
   (if (< ll 1)
       (setq ll 1))
   (setq dd (substr dd ll))
   (setq ll 1)
   (while (< ll 9)
          (if (or (= (substr dd ll 1) (chr 92))
                  (= (substr dd ll 1) ":"))
              (setq dd (substr dd (1+ ll))))
          (setq ll (1+ ll)))
 ;********************** Write script file **********************
   (setq fp (Open (strcat dd ".scr") "w"))
   (write-line "plot" fp)    ; Plot command.
   (write-line plot fp)      ; What to plot: Limits, Extents, Etc.
   (write-line "Y" fp)       ; Change anything?  Yes.
   (write-line "N" fp)       ; Change any of the above parameters?  No.
   (write-line file fp)      ; Write the plot to a file?
   (write-line units fp)     ; Size units: Inches or mm?
   (write-line "" fp)        ; Plot origin (0,0)
   (write-line size fp)      ; Paper size
   (write-line rota fp)      ; Rotate plot 90 degrees?
   (write-line "" fp)        ; Pen width (0.25)
   (write-line "" fp)        ; Adjust area fill boundaries for pen width? <N>
   (write-line "" fp)        : Remove hidden lines? <N>
   (write-line scale fp)     ; Scale or Fit
   (write-line "" fp)        ; File name for plot? <Same as drawing>
   (write-line "" fp)        ; Plot complete.  Press RETURN to continue.
   (Close fp)
   (command "script" dd)))
   ) (prompt "Can't run without block QAPLOT. "))
   (setvar "highlight" hi)
   (setvar "attdia" atd)
   (PRINC))