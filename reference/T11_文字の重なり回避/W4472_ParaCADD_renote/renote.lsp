;;;;Reformat and relocate/reinsert multiline text notes (pre-MTEXT). 
;;;;
;;;;          AUTHOR: HENRY C. FRANCIS
;;;;                  425 N. Ashe Street
;;;;                  Southern Pines, NC 28387
;;;;              
;;;;          All rights reserved without prejudice.
;;;;
;;;;       Copyright:      1997
;;;;       Edited:         11-24-2006
;;;;
;;;;     Requirements:
;;;;       Dimscale must be set to drawing scale, e.g., if drawing scale is
;;;;       1/4" = 1'-0" set dimscale to 48, if dimscale is 1" = 30' set
;;;;       dimscale to 30.  (Note: dimscale=0 is equivalent to dimscale=1
;;;;       within this function).  Dimscale is a multiplier in this function.
;;;;       A Leroy 100 template is 0.10" high with no scale multiplier or a
;;;;       dimscale of 1.  It is 3.00" high with a scale multiplier of 30 on a
;;;;       1" = 30' full scale drawing.  If your drawing is not drawn full
;;;;       scale then adjust dimscale to match.
;;;;
;;;;       The following function's path must be in your SET ACAD= statement:
;;;;       GETSTYLE.LSP, MKLAYR.LSP, UUTILS.LSP
;;;;
;;;; 
;;;****************************************************************************
(DEFUN renote_error (msg /)
  (PRINC (STRCAT "\nError: " msg))
  (SETQ *error* orig_renoteerror)
  (SETVAR "osmode" oldrenote_osmode)
  (SETVAR "clayer" oldrenote_clayer)
  (PRINC)
) ;_ end of DEFUN
(defun c:renote	(/ cntr nostr)
  (SETQ orig_renoteerror *error*)
  (SETQ oldrenote_osmode (GETVAR "osmode"))
  (SETQ oldrenote_clayer (GETVAR "clayer"))
  (SETVAR "osmode" 0)
  (if c:mklayr
    nil
    (load "mklayr" "\nMKLAYR.LSP not loaded! ")
  ) ;_ end of if
  (if upoint
    nil
    (load "upoint" "\nUPOINT.LSP not loaded! ")
  ) ;_ end of if
  (if ukword
    nil
    (load "ukword" "\nUKWORD.LSP not loaded! ")
  ) ;_ end of if
  (if dimscl
    nil
    (load "dimscl" "\nDIMSCL.LSP not loaded! ")
  ) ;_ end of if
  (command "_.undo" "begin")
  (dimscl)
  (c:svlayr)
  (setq cntr 0)
  (if getstyle
    (getstyle "A")
    (progn (load "getstyle") (getstyle "A"))
  ) ;_ end of if
  (if txtsize nil (load "txtsize" "\nFile TXTSIZE.LSP not loaded! "))
  (setq	how_to_do1 (ukword 1
			  "Under Over Reposition"
			  "<U>nder/<O>ver first string or <R>eposition?"
			  (if how_to_do1
			    how_to_do1
			    "Reposition"
			  ) ;_ end of if
		  ) ;_ end of ukword
  ) ;_ end of setq
  (prompt "\nSelect text strings ")
  (setq txtent nil)
  (setq txtent (ssget '((0 . "TEXT"))))
  (while txtent
    (setq nostr (sslength txtent))
    (setq cntr (if(eq how_to_do1 "Over")0 nostr))
    (if	(or(eq how_to_do1 "Under")(eq how_to_do1 "Over"))
      (txtsize
	     (rtos
	       (/ (cdr (assoc 40 (entget (ssname txtent 0)))) 0.001 dimsc)
	       2
	       4
	     ) ;_ end of rtos
      ) ;_ end of setq
      (txtsize nil)
    ) ;_ end of if
    (if	(or(eq how_to_do1 "Under")(eq how_to_do1 "Over"))
      (setq tnjst "L")
      (setq tnjst
	     (ukword 1
		     "Left Center Middle Right TL TC TR ML MC MR BL BC BR"
		     "Left/Center/Middle/Right/TL/TC/TR/ML/MC/MR/BL/BC/BR"
		     (if tnjst
		       tnjst
		       "L"
		     ) ;_ end of if
	     ) ;_ end of ukword
      )					;setq
    ) ;_ end of if
    (cond
      ((eq tnjst "Center") (setq tnjst "C"))
      ((eq tnjst "Middle") (setq tnjst "M"))
    )					;cond
      (COND
        ((EQ (SUBSTR tnjst 1 1) "L")
         (SETQ assoc_72 0
               assoc_73 0))
        ((EQ (SUBSTR tnjst 1 1) "C")
         (SETQ assoc_72 1
               assoc_73 0))
        ((EQ (SUBSTR tnjst 1 1) "M")
         (SETQ assoc_72 4
               assoc_73 0))
        ((EQ (SUBSTR tnjst 1 1) "R")
         (SETQ assoc_72 2
               assoc_73 0))
        ((EQ tnjst "TL")
         (SETQ assoc_72 0
               assoc_73 3))
        ((EQ tnjst "TC")
         (SETQ assoc_72 1
               assoc_73 3))
        ((EQ tnjst "TR")
         (SETQ assoc_72 2
               assoc_73 3))
        ((EQ tnjst "ML")
         (SETQ assoc_72 0
               assoc_73 2))
        ((EQ tnjst "MC")
         (SETQ assoc_72 1
               assoc_73 2))
        ((EQ tnjst "MR")
         (SETQ assoc_72 2
               assoc_73 2))
        ((EQ tnjst "BL")
         (SETQ assoc_72 0
               assoc_73 1))
        ((EQ tnjst "BC")
         (SETQ assoc_72 1
               assoc_73 1))
        ((EQ tnjst "BR")
         (SETQ assoc_72 2
               assoc_73 1))
        (T
         (SETQ assoc_72 0
               assoc_73 0))
      )
    (if	(or(eq how_to_do1 "Under")(eq how_to_do1 "Over"))
      (progn
        (setq txtpt (cdr (assoc 10 (entget (ssname txtent 0)))))
	(if (or (eq how_to_do2 "Under")(not how_to_do2))
	  (setq cntr 0)
	)
      )
      (PROGN
	(setq how_to_do2 (ukword 1 "Under Over" "Reposition <U>nder or <O>ver first line of text?" (IF how_to_do2 how_to_do2 "Under")))
        (SETVAR "osmode" 64)
        (setq txtpt (upoint 1 "" "Insertion point for first line of text " nil nil))
        (SETVAR "osmode" 0)
	(if (or (eq how_to_do2 "Under")(not how_to_do2))
	  (setq cntr 0)
	)
      )
    ) ;_ end of if
    (setq sel1 (list (ssname txtent 0) txtpt))
    (if(entget(ssname txtent 0))
      (PROGN
        (setvar "clayer" (cdr(assoc 8(entget(ssname txtent 0)))))
	(SETQ txtobl (cdr(assoc 51(entget(ssname txtent 0)))))
      )
      (SETQ txtobl 0)
    )
    (while (if(eq how_to_do2 "Under")(< cntr (sslength txtent))(> cntr 0))
;;;      (> cntr 0)
      (setq icntr (if(eq how_to_do2 "Under")cntr(- nostr cntr))
	    ent	  (ssname txtent (max 0 icntr))
	    txrot (cdr (assoc 50 (entget (ssname txtent 0))))
	    txstr (cdr (assoc 1 (entget ent)))
      )					;setq
      (while (eq (substr txstr 1 1) " ") ;this while loop strips off
	(setq txstr (substr txstr 2))	;leading spaces, true text 
      )					;while                                   ;justification requires it
      (while (eq (substr txstr (strlen txstr) 1) " ")
					;this while loop strips off
	(setq txstr (substr txstr 1 (1- (strlen txstr))))
					;trailing spaces, true text 
      )					;while                                         ;justification requires it
;;;      (if (eq cntr nostr)
;;;	(if (eq (substr tnjst 1 1) "L")
;;;	  (command ".text" txtpt txtht txrot txstr)
;;;	  (command ".text" tnjst txtpt txtht txrot txstr)
;;;	)				;if
;;;	(command ".text" "" txstr)
;;;      )					;if
        (setq newtxtdef
               (list
		 (cons -1 ent)
                 (cons 0 "TEXT")
                 (cons 1 txstr)
                 (cons 10 txtpt)
                 (cons 11 txtpt)
                 (cons 40 txtht)
                 (cons 50 txrot)
                 (cons 51 txtobl)
                 (assoc 71 (entget ent))
                 (cons 72 assoc_72)
                 (cons 73 assoc_73)
               ) ;_ end of list
        ) ;_ end of setq
      (entmod newtxtdef)
      (if (or (eq how_to_do2 "Under")(not how_to_do2))
        (SETQ
          txtpt (POLAR txtpt
                       (+ (* PI 1.5)
                          txrot
                       ) ;_ end of +
                       (* txtht 1.5)
                ) ;_ end of POLAR
        ) ;_ end of SETQ
        (SETQ
          txtpt (POLAR txtpt
                       (+ (* PI 0.5)
                          txrot
                       ) ;_ end of +
                       (* txtht 1.5)
                ) ;_ end of POLAR
        ) ;_ end of SETQ
      )      
      (if(or(eq how_to_do2 "Under")(not how_to_do2))(setq cntr (1+ cntr))(setq cntr (1- cntr)))
;;;      (setq cntr (1- cntr))
    )
    (prompt "\nSelect text strings ")
    (setq cntr 0)
    (setq txtent nil)
    (setq txtent (ssget '((0 . "TEXT"))))
  ) ;_ end of while
  (getstyle "")
  (c:rslayr)
  (command "_.undo" "end")
  (SETVAR "osmode" oldrenote_osmode)
  (SETVAR "clayer" oldrenote_clayer)
  (SETQ *error* orig_renoteerror)
  (princ)
)					;defun

;|«Visual LISP© Format Options» (72 2 40 2 T "end of " 60 9 0 0 0 T T nil T)
 ***Don't add text below the comment!***|;
