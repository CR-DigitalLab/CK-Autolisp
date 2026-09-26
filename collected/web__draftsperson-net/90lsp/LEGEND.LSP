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
(if (not (and dxf upoint udist))                        ;test subroutines
  (prompt "\nRequires DXF UPOINT and UDIST functions. Load aborted. ") 
  (progn                                                ;else load OK

;;;* LEGEND.LSP scans the BLOCKs table and extracts all specially marked symbol
;;;* blocks, then builds a legend in the drawing listing all such blocks.
;;;* Mark symbol blocks with a constant invisible ATTDEF tagged LEGEND with
;;;* the symbol's description as its value.
;;;* The Attdef MUST be the first selected entity when making the block.
;;;* The LEGEND.LSP functions consist of C:LEGEND, OUTLEDG and LEDSWAP.
;;;* Legend must have the DXF and user interface functions loaded, and expects
;;;* a global dwg scale variable named #DWGSC to be set to plot scale.            
;;;*
(defun C:LEGEND ( / frst tbdata elist edata llist)
  (prompt "\nBuilding legend list...\n")       ;Tell user what is going on
  (setq frst t)                                ;Flag to rewind to first block
  (while (setq tbdata (tblnext "BLOCK" frst))  ;Loop thru all Blocks,
                                               ;retrieve head data
    (setq edata (entget (dxf -2 tbdata)))      ;Get 1st subentity's data.
    (if (and (= (dxf 0 edata) "ATTDEF")        ;if it is a legend symbol
             (= (dxf 2 edata) "LEGEND")
        )
        (setq llist                                      ;then append 
              (append llist (list (list (dxf 2 tbdata)   ;block name 
                                        (dxf 1 edata)    ;and legend descr,
              )             )     )
        );setq
    );if and =
    (setq frst nil)                      ;Resets flag to disable rewind
  );while
  (outledg llist)                        ;Outputs legend, using the list llist
  (ledswap)                              ;Allows user to swap entries
  (princ)                                ;End cleanly
);defun C:LEGEND
;;;*

;;;* OUTLEDG is used by LEGEND to draw the legend. It uses the current TEXTSIZE
;;;*
(defun outledg (llist / pt1 txtht txdist step)
  (setq ortho (getvar "ORTHOMODE"))                 ;Save
  (setvar "ORTHOMODE" 1)                            ;Turn ortho on
  (prompt                                           ;Number of entries
    (strcat "\nThere are " (itoa (length llist)) " entries for the legend.")
  );prompt
  (setq pt1 (upoint 1 "" "Starting point of first legend symbol" nil nil))
  (command "_.insert" (caar llist) pt1 #dwgsc "" "") ;temporarily inserts 
                                                     ;first symbol
  (setq txtht (getvar "TEXTSIZE")                    ;Gets height of text 
        txdist (udist 1 "" "Distance to first legend text" txdist pt1)
                                                     ;Horiz space
        step (udist 1 "" "Distance to next legend symbol" step pt1) ;Vert space
  );setq                                             ;Get relative positions
  (command "_.erase" (entlast) ""                    ;Erases temp insert
           "_.text"
           (polar pt1 (* 0.5 pi) (- step txtht))     ;Enter LEGEND title above
           (* 2.0 txtht) 0.0 "%%uLEGEND%%u"          ;PT1, %%u underscores
  );command
  (foreach item llist                                ;Insert ea symbol & descr
    (command "_.insert" (car item) pt1 #dwgsc "" "") ;Inserts symbol
    (setq bpt (polar pt1 (* pi 1.5) (/ txtht 2.0)))  ;Calc vert base pt of text
    (command "_.text" (polar bpt 0 txdist) txtht 0.0 (cadr item)) ;Puts in text
    (setq pt1 (polar pt1 (* 1.5 pi) step))           ;Steps to next line
  );foreach
  (setvar "ORTHOMODE" ortho)                         ;Restores
);defun OUTLEDG
;;;*

;;;* LEDSWAP is called by LEGEND to rearrange the entries.
(defun LEDSWAP ( / redrw s1name s2name t1name t2name bp1 bp2 )
 (while (setq s1name 
              (entsel "\nSelect first symbol to swap or ENTER to exit: "))
   (if  (setq s2name (entsel "\nSelect second symbol or ENTER to skip: "))
     (progn
       (setq t1name (entnext (car s1name))         ;get 1st descr. ename
             t2name (entnext (car s2name))         ;get 2nd descr. ename
             bp1 (osnap (cadr s1name) "INS")       ;get 1st INSert pt.
             bp2 (osnap (cadr s2name) "INS")       ;get 2nd INSert pt.
       )
       (command "_.MOVE" s1name t1name "" bp1 bp2  ;move 1st to 2nd
                "_.MOVE" s2name t2name "" bp2 bp1  ;move 2nd to 1st
       )
       (entupd (car s1name))                       ;"redraw" 1st
       (entupd t1name)
     );progn
   );if s2name
 );while s1name
 (princ)                                           ;finish cleanly
);defun LEDSWAP
(princ)
;;;*
;;;* end of LEGEND.LSP
));test subroutines                                                  
