;atext.lsp
;
;     Copyright (C) 1988-1992 by Autodesk, Inc.
;
;     Permission to use, copy, modify, and distribute this software 
;     for any purpose and without fee is hereby granted, provided 
;     that the above copyright notice appears in all copies and that 
;     both that copyright notice and this permission notice appear in 
;     all supporting documentation.
;
;     THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT EXPRESS OR IMPLIED
;     WARRANTY.  ALL IMPLIED WARRANTIES OF FITNESS FOR ANY PARTICULAR
;     PURPOSE AND OF MERCHANTABILITY ARE HEREBY DISCLAIMED.
;     ****************************************************************
;  Larry Knott  
;
;  Draws center aligned text along an ARC.  The start point of the text
;  is the ENDpoint of the ARC closest the pick point.
;

(defun rtd (a) (* a (/ 180 pi)))         ;  radians to degrees

(defun getarc (/ no_arc e0 e1)
(setq no_arc T)
(while no_arc
  (if (setq e0 (entsel "\nSelect arc: "))  
    (if (= (cdr (assoc 0 (setq e1 (entget (car e0))))) "ARC")
      (setq no_arc nil)
      (princ (strcat (cdr (assoc 0 e1)) ", Not an arc."))
    )                                    ;  end IF
    (princ " No object found.")
  )                                      ;  end IF
)                                        ;  end WHILE
(setq c1 (cdr (assoc 10 e1))             ;  center point
      r1 (cdr (assoc 40 e1))             ;  radius
      a0 (cdr (assoc 50 e1))             ;  start arc angle
      a1 (cdr (assoc 51 e1))             ;  end arc angle
      i1 (if (> a1 a0)                   ;  included angle
           (- a1 a0)
           (+ a1 (- (* pi 2) a0))
         )                               ;  end IF
      p1 (osnap (cadr e0) "end")         ;  start point pick
      p2 (polar c1 a1 r1)                ;  end point arc
)                                        ;  end SETQ
)                                        ;  end DEFUN

(defun getset (/ h1 t1 n1 a2)
(setq h1                                 ;  check current text style height
  (if (zerop (cdr (assoc 40 (tblsearch "style" (getvar "textstyle")))))
         (getdist p1 "\nHeight: ")       ;  text height
         nil                             ;  height defined by STYLE
  )                                      ;  end IF
      t1 (getstring T "\nText: ")        ;  text string
      n1 1                               ;  counter
      a2 (/ i1 (1- (strlen t1)))         ;  angle increment
)                                        ;  end SETQ
(if (< (distance p1 p2) 1.0E-8)          ;  clockwise?
  (setq o1 '-)                           ;  clockwise
  (setq o1 '+                            ;  counter-clockwise
        a1 a0
  )                                      ;  end SETQ
)                                        ;  end IF
(setvar "cmdecho" 0)                     ;  suppress command echo
(setvar "highlight" 0)                   ;  suppress hightlighting
(setvar "blipmode" 0)                    ;  suppress blips
(repeat (strlen t1)                      ;  for each character
  (command "text" "c" p1)                ;  TEXT command
  (if h1 (command h1))
  (command ((eval o1) (rtd a1) 90) (substr t1 n1 1))
  (setq a1 ((eval o1) a1 a2)             ;  increment angle 
        n1 (1+ n1)                       ;  increment counter
        p1 (polar c1 a1 r1)              ;  increment text point
  )                                      ;  end SETQ
)                                        ;  end REPEAT
(setvar "cmdecho" 1)                     ;  enable command echo
(setvar "highlight" 1)                   ;  enable hightlighting
(setvar "blipmode" 1)                    ;  enable blips
)                                        ;  end DEFUN

(defun c:atext()
(princ "\n  *** Draws text on arcs ***") ;  banner
(getarc)                                 ;  get the arc
(getset)                                 ;  get the settings and draw text
(prin1)                                  ;  quiet exit
)                                        ;  end DEFUN
