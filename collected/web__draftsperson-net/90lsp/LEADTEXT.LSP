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
(if (not (and upoint adderr mlayer dxf))                ;Test subroutines
  (prompt "\nRequires ERROR.LSP, UPOINT DXF and MLAYER functions. Load aborted. ")
  (progn                                                ;Else load OK

;;;* LEADTEXT.LSP is an example of error control. S-LEAD draws leaders.
;;;* L-TEXT adds text to leaders. It requires ERROR.LSP and the
;;;* user GET functions.

;;;* C:S-LEAD (Straight LEADer) draws a pline leader using as many
;;;* line segments as desired. The start point is the arrow head.
;;;* L-TEXT is called to provide correctly justified DTEXT.
;;;*
(defun C:S-LEAD ( / pt1 pt2 pt3 args)
  (setq args '(pt1 pt2 pt3 args))         ;Arg list for *error*
  (setvar "BLIPMODE" 0)                   ;Turn blipmode off
  (setvar "CMDECHO" 0)                    ;Turn command echo off
  (setvar "MENUECHO" 0)                   ;Turn menu echo off
  (initerr)                               ;Initialize error list
  (adderr                    ;Adds command function to reset layer name
    (list 'command "_.LAYER" "_S" (getvar "CLAYER") "") ;to current layer
  )                                                     ;name in #ERROR list
  (mlayer "ANN01" "G" "")                 ;Creates/sets annotation layer

  ;get start point of arrow head, a point for 1st line segment
  ;calc arrow head size
  (setq pt1 (upoint 1 "" "Pick arrow head point" nil nil)
        pt2 (upoint 1 "" "To point" nil pt1)
        pt3 (polar pt1 (angle pt1 pt2) (* 0.125 #dwgsc))
  );setq

  (adderr '(command "_.U"))         ;Add undo to error list
  (adderr '(command))               ;Add cancel to error list

  ;draw arrow head and 1st line segment
  (command "_.PLINE" pt1 "_W" "0" (* 0.0625 #dwgsc) pt3 "_W" "0" "0" pt2)

  ;loop for additional line segments or, until ENTER is pressed
  (while (setq pt2 (getpoint "\nTo point: " pt2))
     (command pt2)
  );end while

  (command "")                      ;End pline
  (delerr '(command "_.U"))         ;The pline can stay now if user cancels
  (l-text)                          ;Call l-text function
  (reset nil)                       ;Reset environment and #ERROR list
);end defun

;;;* L-TEXT (Leader TEXT) starts a DTEXT command following any leader.
;;;* The text justification (Left or Right) is determined by the last
;;;* point and mid point of the last line or arc of the leader.
;;;*
(defun l-text ( / pt1 pt2)
   ;;get last point of leader, get midpoint using pt1, use quick
   ;;also get current text height
   (setq pt1 (getvar "LASTPOINT")
         pt2 (osnap pt1 "_quick,_midp")
         txtht (getvar "TEXTSIZE")
   );setq
   (prompt "\nEnter text: ")
   (if (> (car pt1) (car pt2))      ;Determine X point position
      (progn                        ;If X of pt1 is greater, Left text
         (setq pt1 (polar pt1 5.759 txtht)) ;Based on text size
         (command "_.DTEXT" pt1 txtht 0)    ;Start DTEXT - leave user there
      );end progn
      (progn                        ;If X of pt2 is greater use Right text
         (setq pt1 (polar pt1 3.665 txtht))   ;Based on text size
         (command "_.DTEXT" "_R" pt1 txtht 0) ;Start DTEXT - leave user there
      );end progn
   );end if
);defun L-TEXT
;;;*
(princ)
;;;*end of LEADTEXT.LSP
));test subroutines                     
