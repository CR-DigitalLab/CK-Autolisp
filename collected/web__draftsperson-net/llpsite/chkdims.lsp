;***************************************** CHKDIMS.LSP *********************************
; AUTOLISP PROGRAM DESCRIPTION: PLACES INDICATORS OVER DIMENSIONS WITH  
; DIMENSION TEXT OVERRIDES & ASSOCIATIVE DIMENSIONS TO AID CHECKING
;
; DEVELOPED ON AUTOCAD R13c4a WIN95 PLATFORM
;
; COPYRIGHT (C) 1998  Patrick J. Hughes Jr. ALL RIGHTS RESERVED
;
; DEVELOPED BY: Patrick J. Hughes Jr.
;                            ENGINEERED DESIGN SOLUTIONS
;                            2620 Auburn Street
;                            Rockford Il, 61101
;                            (815) 968-9133
;                            e-mail: duhvinci@inwave.com
;                            homepage: http://www.inwave.com/~duhvinci/
;
; CREATED: 02/24/98
; LAST MODIFIED: 05/04/98
;
;   Permission to use, copy, modify, and distribute this software 
;   for any purpose and without fee is hereby granted, provided 
;   that the above copyright notice appears in all copies and that 
;   both that copyright notice and this permission notice appear in 
;   all supporting documentation.
;      
;   THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT EXPRESS OR IMPLIED
;   WARRANTY.  ALL IMPLIED WARRANTIES OF FITNESS FOR ANY PARTICULAR
;   PURPOSE AND OF MERCHANTABILITY ARE HEREBY DISCLAIMED.

;************************************************ ERROR HANDLER *************************

(defun chkdims_err (s)                 ; If an error (such as CTRL-C <ESC>) occurs
(if (/= s "Function cancelled")
    (princ (strcat "\nError: " s))
)

; VARIABLE RESETS AND COMMANDS TO PERFORM UPON ERRORS FOLLOW:

(SETVAR "CLAYER" "CURLAY")
(SETVAR "OSMODE" OMODE)
(SETVAR "BLIPMODE" BLPMODE)
(SETVAR "REGENMODE" RGNMODE)
;;(SETVAR "CMDECHO" CMDECH)
;;(SETVAR "TEXTEVAL" TEXTEV)
(command "UCS" "P")

(if olderr (setq *error* olderr))  ; Restore old *error* handler
(princ)
);;defun

;************************************************ MAIN PROGRAM *******

(defun c:chkdims ( / olderr  mode found ss1 ovrblk asoblk CURLAY OMODE BLPMODE
                                 RGNMODE SS1MAX COUNT EN ED OLDTX TXTPOS TXTSC)

(setq olderr  *error*                    ; Save acad error routine
         *error* chkdims_err          ; Substitute eds routine
)

(princ "chkdims") (princ)
(initget "Display Clean")

(setq mode (getkword "\nDisplay/Clean <D>: "))
(if ( = nil mode ) (setq mode "Display"))

(if (= mode "Display")

(progn  

;VARIABLES TO SAVE FOR ERROR HANDLER FOLLOW:

(SETQ CURLAY (GETVAR "CLAYER")
            OMODE (GETVAR "OSMODE")
            BLPMODE (GETVAR "BLIPMODE")
            RGNMODE (GETVAR "REGENMODE"))
;;             TEXTEV (GETVAR "TEXTEVAL")
;;             CMDECH (GETVAR "CMDECHO")

(SETVAR "CLAYER" "0")
(SETVAR "OSMODE" 0)
(SETVAR "BLIPMODE" 0)
(SETVAR "REGENMODE" 0)
;; (SETVAR "TEXTEVAL" 1)
;; (SETVAR "CMDECHO" 1)
(command "UCS" "W")

(if ( > (* (getvar "DIMLFAC") (GETVAR "DIMTXT")) (GETVAR "TEXTSIZE"))
         (setq TXTSC (* 6.0 (GETVAR "DIMTXT") (getvar "DIMLFAC")))
         (setq TXTSC (* 6.0 (GETVAR "TEXTSIZE")))
)

(if (not (tblsearch "block" "DIMTXOVR"))
    (makeovrblk)
)

(if (not (tblsearch "block" "DIMTXASO"))
    (makeasoblk)
)

(setq found 0)

(setq ss1
(ssget "X" '((0 . "DIMENSION")))
)

(if ss1 (setq SS1MAX (sslength SS1)))
(setq COUNT 0)

(while (< COUNT SS1MAX)

  (setq EN (ssname SS1 COUNT)
           ED (entget EN)
           OLDTX (DXF 1 ED)
           TXTPOS (DXF 11 ED)) ;;10 ED)) ;;11 = text position, 10 = dim line position

(if (and (/= oldtx "") (/= "<>" (substr oldtx 1 2)))

(progn
(setq found (1+ found))
(if (not (tblsearch "block" "DIMTXOVR"))
    (progn
       (makeovrins)
       (setq ovrins (entmake ovrblklst))
    );progn

   (command "insert" "DIMTXOVR" TXTPOS TXTSC "" "" )

);if
);progn
);if

(if (or (= "" oldtx) (wcmatch oldtx "*<>*" ))

(progn
(if (not (tblsearch "block" "DIMTXASO"))
    (progn
       (makeasoins)
       (setq asoins (entmake asoblklst))
    );progn

   (command "insert" "DIMTXASO" TXTPOS TXTSC "" "" )

);if
);progn
);if

(setq count (1+ count))

);while

; VARIABLE RESETS AND COMMANDS TO PERFORM UPON COMPLETION FOLLOW:

(SETVAR "CLAYER" CURLAY)
(SETVAR "OSMODE" OMODE)
(SETVAR "BLIPMODE" BLPMODE)
(SETVAR "REGENMODE" RGNMODE)
(command "UCS" "P" )

(prompt (strcat (rtos found 2 0) " dimensions found with text overrides."))
);;progn if Display

(progn
  (if (setq ss1 (ssget "X" '((2 . "DIMTXOVR,DIMTXASO"))))
    (progn 
      (command "ERASE" ss1 "")
      (prompt (strcat (itoa (sslength ss1)) " indicators deleted."))
    )
    (prompt "no indicators found")
)

);;progn
);;if

(setq *error* olderr)              ; Reset acad error handler
(princ)

);defun

(defun makeovrblk ()
(entmake '((0 . "BLOCK") (2 . "DIMTXOVR") (70 . 0) (8 . "0") (10 0.0 0.0 0.0)))
(entmake '((0 . "LINE") (8 . "0") (10 -0.3535 -0.3535 0.0) (11 0.3535 0.3535 0.0) (62 . 1)))
(entmake '((0 . "LINE") (8 . "0") (10 -0.3535 0.3535 0.0) (11 0.3535 -0.3535 0.0) (62 . 1)))
(entmake '((0 . "CIRCLE") (8 . "0") (10 0.0 0.0 0.0) (40 . 0.5) (62 . 1)))
(setq ovrblk (entmake '( (0 . "endblk"))))
);defun

(defun makeovrins ()
(setq ovrblklst (list  '(0 . "INSERT")
                               (cons 2 "DIMTXOVR")
                               (cons 10 TXTPOS)
                               (cons 41 TXTSC)
                               (cons 0 "SEQEND"))
);setq
);defun

(defun makeasoblk ()
(entmake '((0 . "BLOCK") (2 . "DIMTXASO") (70 . 0) (8 . "0") (10 0.0 0.0 0.0)))
(entmake '((0 . "LINE") (8 . "0") (10 -0.500 -0.250 0.0) (11 0.500 -0.250 0.0) (62 . 3)))
(entmake '((0 . "LINE") (8 . "0") (10 0.500 -0.250 0.0) (11 0.500 0.250 0.0) (62 . 3)))
(entmake '((0 . "LINE") (8 . "0") (10 0.500 0.250 0.0) (11 -0.500 0.250 0.0) (62 . 3)))
(entmake '((0 . "LINE") (8 . "0") (10 -0.500 0.250 0.0) (11 -0.500 -0.250 0.0) (62 . 3)))
(setq asoblk (entmake '( (0 . "endblk"))))
);defun

(defun makeasoins ()
(setq asoblklst (list  '(0 . "INSERT")
                               (cons 2 "DIMTXASO")
                               (cons 10 TXTPOS)
                               (cons 41 TXTSC)
                               (cons 0 "SEQEND"))
);setq
);defun

(defun dxf(code elist)
  (cdr (assoc code elist))   ;finds the association pair, strips 1st element
);defun

(princ)

