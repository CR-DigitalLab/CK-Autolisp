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
;;;* GRPT GRdrawPoinT mimics the Point command drawing a fake point at 
;;;* centerpoint CPT, using GRDRAW translated parallel to the display. 
;;;* PDMODE and PDSIZE mimic and default to their setvar settings if supplied 
;;;* as 0. COLOR defaults to Setvar CECOLOR if supplied as 0 (7 if setvar is 
;;;* BYLAYER or BYBLOCK).  COLOR and HILITE are GRDRAW arguments.
;;;* A small function C:TEST is included for demonstation purposes and testing.
;;;* It uses the defaults, for an un-highlighted cyan point.

(defun grpt (cpt pdmode pdsize color hilite)
  (setq cpt (trans cpt 1 2)         ;Translate center point from UCS 
                                    ;to DCS, the display coord system
        ang 0                       ;Initialize
  )
  (if (eq pdmode 0) (setq pdmode (getvar "PDMODE")))  ;Use setvar PDMODE if 0
  (if (eq pdsize 0) (setq pdsize (getvar "PDSIZE")))  ;Use setvar PDSIZE if 0
  (if (eq color 0)                                    ;Use setvar CECOLOR if 0
    (if (numberp (setq color (read (getvar "CECOLOR"))))  ;Use 7 if bylayer or
                                                          ;byblock
       nil
       (setq color 7)
  ) );if if
  (if (> pdsize 0)                                   ;Set INC to 1/2 size
    (setq inc (* 0.5 pdsize ))                       ;Positive = absolute size
    (setq inc (* 0.005 pdsize (getvar "VIEWSIZE")))  ;Neg = % view height
  );if
  (while (> pdmode 31)                 ;Loop until 32 (circle) and 64 (square) 
                                       ;values are deducted and drawn
    (if (> pdmode 63)                            ;64+ get square
      (setq                                      ;Set to draw square
        pdmode (- pdmode 64)                     ;Deduct square bit 
        num 4 anginc 1.570796327 side inc ang 0  ;Set variables for square
        pt (polar cpt -0.785398164 (* inc 0.707106781))
      )
      (setq                            ;Set to draw circle
        pdmode (- pdmode 32)           ;Deduct circle bit
        num 12 anginc 0.523598776      ;12 sides at angular inc of 30 deg
        ang 1.308996939                ;90 deg minus 1/2 ANGINC 
        side (* inc (sin 0.261799388)) ;Ea side 2 x 1/2 INC x sin 15 deg long
        pt (polar cpt 0 (* inc 0.5))   ;Start 1/2 INC at -15 deg
      )
    );if 
    (repeat num                        ;4 for square, 12 for circle
      (grdraw                          ;Draw square or circle
        (trans pt 2 1)                 ;Trans 1st pt from DCS to UCS
                                       ;Trans 2nd pt from DCS to UUCS
        (trans (setq pt (polar pt (setq ang (+ ang anginc)) side)) 2 1)
        color hilite
    ) )
  );while
  (cond                                ;See what else to draw
    ((eq pdmode 4)                     ;Vertical line
      (grdraw 
        (trans cpt 2 1)                ;Trans center for 1st pt
        (trans (polar cpt 1.570796327 (* 0.5 inc)) 2 1)  ;Trans endpt of 
                                                         ;vert tick
        color hilite
    ) )
    ((> pdmode 1)                                        ;X or cross
      (setq anginc 1.570796327 side inc) 
      (if (eq pdmode 3)
        (setq ang 0.785398163)                           ;Set to draw X
        (setq ang 0)                                     ;Set to draw cross
      )
      (repeat 2                                          ;Draw X or cross
        (grdraw 
          (trans (polar cpt ang inc) 2 1)
          (trans (polar cpt (+ ang pi) inc) 2 1)
          color hilite
        )
        (setq ang (+ ang  1.570796327))         ;Rotate ANG 90 degrees
      );repeat
    )
    ((eq pdmode 0)                              ;Just draw point
      (grdraw 
        (trans cpt 2 1)                         ;Zero length line
        (trans cpt 2 1)
        color hilite
      )
    )
  );cond
  (princ)
);defun GRPT
;;;*

(defun C:TEST ()
 (while (setq pt (getpoint "\nPoint: "))
   (grpt pt 0 0 4 0)
 )
 (prompt "\nDone.")
 (princ)
);defun
(princ)
