;|
Aptxt.lsp  Written by Dennis Shinn and Don Jacobsen
(c) Seattle AutoCAD User Group

       APTXT.lsp automates the appendage of AutoCAD "DTEXT"
       to an existing line of text. Text attributes of the
       original line of text are used to match the new
       added text.

       This routine was conceived in response to an
       article in the comp.cad.autocad newsgroup requesting
       a method for appending text to an exising paragraph.

AutoCAD is the registered trade mark of Autodesk, Inc.
The Seattle AutoCAD User Group is an independent end
user support organization with no affiliation with
Autodesk other than through the use of the AutoCAD
software.

Permission is hereby granted to distribute this utility provided-
       o- no fee is charged
       o- this copyright notice is included in its entirety

Usual disclaimers apply: this program is guaranteed
to do nothing more than occupy space on your hard
drive provided you are successful in getting it there.
|;

(DeFun c:ApTxt (/	curlay	cursty	seltxt	insp	trot	valign
		halign	sty	styht	just	hl	vl	tlay
	       )
  (setvar "cmdecho" 0)
  (graphscr)

 ;SET AND SAVE SYSTEM VARIABLES

  (defun pushvars (varlist / varnames new-value old-value)
    (foreach entry varlist
      (if (setq
	    varname   (car entry)
	    old-value (getvar varname)
	  )
	(progn
	  (if (setq new-value (cdr entry))
	    (setvar varname new-value)
	  )
	  (setq
	    stack  (cons (cons varname old-value) stack)
	    cursty (getvar "textstyle")
	    curlay (getvar "clayer")
	  )
	)
      )
    )
  )
  (pushvars
    '(("SNAPMODE" . 0)
     )
  )
  (defun popvars ()
    (foreach entry stack
      (setvar (car entry) (cdr entry))
    )
    (setvar "textstyle" cursty)
    (setvar "clayer" curlay)
    (princ)
  )

 ;ERROR HANDLER

  (defun proto-error (S)
    (if	(not (member S '("CONSOLE BREAK" "FUNCTION CANCELED")))
      (PRINC S)
    )
    (command)
    (command)
    (command "UNDO" "END")
    (if	UNDOIT
      (command "UNDO" 1)
    )
    (setq *ERROR* old-error)
    (popvars)
  )
  (setq *ERROR* proto-error)
  (command "UNDO" "GROUP")

 ;CODE FOR PROGRAM

  (prompt "\nSelect text line to append new text below ... ")
  (while (not seltxt) (setq seltxt (entsel)))
  (setq
    gettxt (entget (car seltxt))
    sty	   (cdr (assoc 7 gettxt))
    halign (cdr (assoc 72 gettxt))
    valign (cdr (assoc 73 gettxt))
    styht  (cdr (assoc 40 (tblsearch "style" sty)))
    trot   (/ (* (cdr (assoc 50 gettxt)) 180.00) PI)
    tlay   (cdr (assoc 8 gettxt))
  )
  (setvar "clayer" tlay)
  (cond
    ((= halign 0) (setq hl "L"))
    ((= halign 1) (setq hl "C"))
    ((= halign 2) (setq hl "R"))
    ((= halign 4) (setq hl "M"))

  )
  (cond
    ((= valign 0) (setq vl ""))
    ((= valign 1) (setq vl "B"))
    ((= valign 2) (setq vl "M"))
    ((= valign 3) (setq vl "T"))
  )
  (if (= halign valign 0)
    (setq insp (cdr (assoc 10 gettxt)))
    (setq insp (cdr (assoc 11 gettxt)))
  )
  (setq just (strcat vl hl))
  (cond
    ((and (> styht 0.0) (= just "L"))
     (command "TEXT" "s" sty insp trot "%%10")
    )
    ((and (> styht 0.0) (/= just "L"))
     (command "TEXT" "s" sty "j" just insp trot "%%10")
    )
    ((and (= styht 0.0) (= just "L"))
     (command "TEXT"
	      "s"
	      sty
	      insp
	      (cdr (assoc 40 gettxt))
	      trot
	      "%%10"
     )
    )
    ((and (= styht 0.0) (/= just "L"))
     (command "TEXT"
	      "s"
	      sty
	      "j"
	      just
	      insp
	      (cdr (assoc 40 gettxt))
	      trot
	      "%%10"
     )
    )
  )
  (Prompt "\n\nText: ")
  (command "DTEXT" "")
  (princ)

 ;PUT EVERYTHING BACK WERE IT BELONGS

  (command "UNDO" "END")
  (setq *ERROR* old-error)
  (popvars)
)
 ;(prompt "\nAptxt loaded... ")
(princ)

