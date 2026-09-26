; XLINE.LSP
; Tony Tanzillo
; 2/24/87
;
; Notice
;
; The information contained herein is being donated to the public domain soley
; for the benefit of licensed AutoCAD END USERS everywhere. You are free to
; reproduce, modify and distribute the information contained herein for ANY
; NON-COMMERCIAL use, provided such reproduction/distribution is NOT FOR PROFIT,
; and the information contained herein (or any portion thereof)is NOT ALTERED
; from it's original content in ANY manner, shape, or form.
;
; You ARE NOT free to reproduce and/or distribute the information contained
; herein (regardless of medium or form of reproduction) for profit, or to
; include it or any portion thereof, as a part of any commercially marketed
; goods regardless of its intended nature, scope, or form, without the
; expressed written permission of the author.
;
; If you seek such permission, it will be granted provided you furnish
; ONE fully-functional licensed sample of the finished product(s) in final
; marketed form. In return for which you may solict and will recieve the
; author's objective opinions, advice and insight regarding any and all
; aspects of said product(s), free of charge, with appropriate and complete
; written assurance of non-disclosure.
;
; Additional information can be obtained
; by writing to:
;                   Anthony F. Tanzillo,
;                   32 Gould Ave.
;                   Paterson, N. J. 07503
;
; Or, via electronic medium thru;
;
;                   Compuserve ID: 70307,2556
;
;
; XLINE.LSP is a demonstration of an easier way to select objects to
; be TRIMmed and EXTENDed. It permits you to select multiple LINE
; entities to be trimmed or extended by drawing a "crossing line"
; thru the LINE entites which you would normally have to PICK one at
; a time to submit them to EXTEND or TRIM. Once you have drawn the
; crossing line thru the objects, each LINE entity that physically
; intersects the crossing line will be selected, with the associated
; selection point at the intersection of the XLINE and the lines to
; be TRIMmed/EXTENDed.
;
; Included is a short script that helps to illustrate the use of the
; crossing line. The objective with the resulting objects is to TRIM
; the portions of ALL vertical lines BETWEEN the 2 horizontal lines.
; This will be done by the script which will invoke XLINE at the
; TRIM command's "Select object to trim" prompt, and specify the 2
; endpoints of the XLINE.
;
; The CROSSING line should CROSS thru all the vertical lines
; somewhere between the 2 horizontal lines. Once this is done, you
; should see each line TRIMmed one by one, and the blips will show
; the points that are being passed to AutoCAD by the LISP routine.
;
; Tip: the closer the angle of the crossing line is to either 0 or
; 90 degrees the better, a diagonal line being least desirable. The
; reason is that the crossing line actually starts out as a CROSSING
; BOX and then the resulting entities are sifted thru, and when a
; line is found which intersects the crossing line, that point of
; intersection is passed to AutoCAD as a response to "Select object
; to trim: ". Thats basically how it works.

; Also, the crossing line WILL ONLY SELECT LINES to TRIM/EXTEND,
; and will not work with other entity types.

; Note! XLINE.LSP requires the function SS-EACH which is not
; included here to avoid redundancy and to conserve data library
; file space.
;
; SS-EACH can be obtained from the file TEXTED.LSP in the
; the data libraries.
;


(defun xline( / fr to pr in)
  (setvar "cmdecho" 0)
  (setq fr (getpoint "\nCrossing line from point: "))
  (setq to (getpoint fr "To point: "))
  (ss-each (ssget "c" fr to) 'obj
    '(if
       (and
         (setq pr (etype obj "line"))
         (setq in (apply 'inters (list (get 10 pr) (get 11 pr) fr to T))))
       (command in)))
  (progn))

(defun etype(e n / pr)
  (cond ((eq (cdr (assoc 0 (setq pr (entget e)))) (strcase n)) pr) (T NIL)))

(defun get(k l) (cdr (assoc k l)))


Script to demonstrate use of XLINE.
=====================================
SETVAR BLIPMODE 0
ZOOM L 0,0 8
LINE 2,2 10,2  (SETQ A (ENTLAST))
COPY L  @ @4<90 (SETQ B (ENTLAST))
LINE 2.5,1.5
@5<90  ARRAY L  R 1 28 .25
SETVAR BLIPMODE 1
TRIM !A !B  (XLINE) 1,3 12,5
=====================================

Objective of the demonstration is to TRIM ALL the vertical lines
BETWEEN the 2 horizontal lines.

To use (XLINE), load it and the support fuctions into ACAD.LSP,
and use the TRIM and EXTEND commands as you usually would, only
when you are prompted for the OBJECT to TRIM/EXTEND, enter (XLINE) <CR>.
In the above script the blips to the left and right of the "railroad
tracks" represent the endpoints of the crossing line.

  -Tony T.
