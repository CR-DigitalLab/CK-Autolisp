;;; AutoLISP File for
;;; Maximizing AutoLISP - IL DISK (c) 1987, '88, '89, '91, '92 New Riders Publ.
;;;                Version 12.00 for Release 12 PC-DOS/MS-DOS                 
;;;* Developed by Rustin Gesner, Patrick Haessly, Joseph Smith, & Kenneth Billing
;;;
;;;       Permission to use, copy, modify, and distribute this software       
;;;       for any purpose is hereby granted, provided that no fees are        
;;;       collected directly or indirectly and that the above copyright       
;;;       notice and this permission notice appear in all copies and in       
;;;       all supporting documentation. See IL DISK DISCLAIMER.TXT file.
;;;
;;;* FLATPAT.LSP Draws a flat pattern to be wrapped around a pipe indicating
;;;* the cut line for pipe intersection.
;;;  P1   = Start point for pattern
;;;  ANG  = Angle of intersection for pipes
;;;  R1   = Radius of pipe 1
;;;  R2   = Radius of pipe 2
;;;  ANG1 = Angle for a 16 segment circle
;;;  D1   = Circumference of pipe 1
;;;  X1   = X length for list 1
;;;  X2   = X length for list 2
;;;  L1   = List of points for top quarter of pipe 1
;;;  L2   = List of points for bottom quarter of pipe 2
;;;  C1   = Chord of pipe 1
;;;  AT   = Top altitude of pipe 1
;;;  AB   = Bottom altitude of pipe 1
;;;  A2   = Altitude pipe 2
;;;  Y1   = Y length for list 1
;;;  Y2   = Y length for list 2
;;;  GA   = Go ahead flag
;;;
(defun C:FLATPAT ( / P1 ANG R1 R2 ANG1 D1 X1 X2 L1 L2 C1 AT AB A2 Y1 Y2 GA)
  (setq 
    P1 (getpoint "\nPick start point: ")           ;Get start point of pattern
    ANG (getangle "\nEnter intersection angle: ")  ;Get angle of intersection
    R1 (/ (getdist "\nEnter Dia. of Intersecting Pipe: ") 2);Get pipe 1 diam
    R2 (/ (getdist "\nEnter Dia. of Base Pipe: ") 2)        ;Get pipe 2 diam 
    ANG1 (/ PI 8)                     ;Angle for single segment
    D1 (* R1 (* PI 2))                ;Calculate circumference of pipe 1
    X1 (/ D1 16)                      ;Initiate X1 length 
    X2 (* X1 7)                       ;Initiate X2 length
    L1 (list P1)                      ;Initiate list 1
    L2 (list P1)                      ;Initiate list 2
  );setq
  (if (<= R1 R2)
    (progn
      (if (> ANG 1.4)
        (progn
          (initget "Yes No")
          (prompt "\nAn intersection angle that small may create a")
          (prompt "\nvery long pattern that may be very difficult to")
          (prompt "\nbuild. Do you wish to continue? Yes or <N>o: ")
          (setq ga (getkword))
          (if (= ga nil)
            (setq ga "No")
          )
        );thenprogn
      );if
      (if (or (= ga nil) (= ga "Yes"))
        (progn
          ;; Repeat statements calculating points for both lists
          (repeat 4 
            (setq
              C1 (* (sin ANG1) (* R1 2))         ;Calculate chord for pipe 1
              AT (- R1 (sqrt (- (expt R1 2) (expt (/ C1 2) 2)))) ;Top altitude 
                                                                 ;pipe 1
              AB (- (* R1 2) AT)                 ;Bottom altitude pipe 1
              A2 (- R2 (sqrt (- (expt R2 2) (expt (/ C1 2) 2)))) ;Altitude
                                                                 ;pipe 2
              Y1 (+ (* (/ AT (cos ang)) (sin ang)) (/ A2 (cos ang))) ;Y length
                                                                     ;list 1
              Y2 (+ (* (/ AB (cos ang)) (sin ang)) (/ A2 (cos ang))) ;Y length
                                                                     ;list 2
              ANG1 (+ ANG1 (/ PI 8))             ;Increase angle for next loop
              L1 (append L1 (list (list X1 Y1))) ;Make list 1
              X1 (+ X1 (/ D1 16))                ;Increase X length for list 1
              L2 (append L2 (list (list X2 Y2))) ;Make list 2
              X2 (- X2 (/ D1 16))                ;Increase X length for list 2
            );setq
          );repeat
          (setq
            L2 (cdr (reverse L2))           ;Reverse and remove duplicate point
            Y2 (* (/ (* R1 2) (cos ang)) (sin ang))       ;Calc final Y length
            L2 (subst (list (/ D1 2) Y2) (last L2) L2)    ;Replace final point
                                                          ;list 2
            L1 (append (cdr L1) L2)         ;Combine lists & remove first point
          );setq
          (foreach X L1 (setq L1 (subst (mapcar '+ P1 X) X L1))) ;Adj points to
                                                                 ;start point
          (command                                      ;Draw pattern
            "._PLINE" P1 (foreach x L1 (command x))     ;Draw first half
            "._MIRROR" "_L" "" "@"                      ;Mirror second half
            (polar (getvar "LASTPOINT") (/ PI 2) 3) ""
            "._PEDIT" "_L" "_J" P1 "" "_F" "_X"         ;Join and Fit pattern
            "._LINE" P1                                 ;Draw 3" wrap
            "@0,-3" (polar (getvar "LASTPOINT") 0 D1)   ;section and
            "@.5,.5" "@0,2" "@-.5,.5" "@0,-3" ""        ;tab
            "._CHANGE" "_L" "" "_P" "_LT" "HIDDEN" ""   ;Make tab line hidden
          );command
        );thenprogn
      );if
    );elseprogn
    (prompt 
"\nBase pipe diameter must equal or exceed intersecting pipe diam. Aborting."
    )
  );if
  (princ)
);defun
(princ)
