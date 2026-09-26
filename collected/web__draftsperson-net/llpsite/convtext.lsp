; convtext.lsp
;
;     Copyright (C) 1992 by Autodesk, Inc.
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
;********************************
;* Convert all text in drawing  *
;* to a new height.             *
;*                              *
;* by F. Phil DeGeorge          *
;* Autodesk Product Support     *
;********************************
(defun c:CONVTEXT()
	; ask user for new text height to use
	; if user does not supply a height, then
	; get the system variable TEXTSIZE to use
	(setq newhyt (getreal "New height for all text? <system default>: "))
	(if (= newhyt nil) (setq newhyt (getvar("TEXTSIZE"))))
	;
	; get selection set of all text items in database
	(setq sset1 (ssget "X" (list (cons 0 "TEXT"))))
	;
	; initialize counter
	(setq counter 0)
	;
	; loop through all selection set items
	(repeat (sslength sset1)
		;
		; get entity name
		(setq txt (ssname sset1 counter))
		;
		; get entity data
		(setq txtdata (entget txt))
		;
		; extract current height
		(setq hyt (assoc 40 txtdata))
		;
		; substitute current height with new height
		(setq txtdata (subst (cons 40 newhyt) hyt txtdata))
		;
		; update entity in database and on screen
		(entmod txtdata)
		(entupd txt)
		;
		; increment counter to point to next item in selection set
		(setq counter (+ counter 1))
	)
)

