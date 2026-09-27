;;; This function is freeware courtesy of the author's of "Inside AutoLisp" for
;;; rel. 10 published by New Riders Publications. This credit must accompany all
;;; copies of this
;;; function.
;;;
;;; USTR User interface string If BIT=1 no null "" input allowed, 0 for none, BIT
;;; ignored if DEF present. MSG is the prompt string, to which a default string
;;; is added as <DEF> (nil or "" for none), and a : is added. If SPFLAG T, spaces
;;; are allowed in
;;; string.
;;;
(DEFUN ustr (bit msg def spflag / inp nval)
  (IF (AND def (/= def ""))
    (SETQ msg (STRCAT "\n" msg " <" def ">: ")
	  inp (GETSTRING msg spflag)
	  inp (IF (= inp "")
		def
		inp
	      ) ;_ end of if
    ) ;_ end of setq
    (PROGN
      (SETQ msg (STRCAT "\n" msg ": "))
      (IF (= bit 1)
	(WHILE (= "" (SETQ inp (GETSTRING msg spflag))))
	(SETQ inp (GETSTRING msg spflag))
      ) ;_ end of if
    ) ;_ end of progn
  ) ;_ end of if
;;;  (IF (WCMATCH inp "*'_NAVSWHEEL *")
;;;    (PROGN
;;;      (SETQ cnt 1)
;;;      (WHILE (NOT (WCMATCH (SUBSTR inp cnt) "'_NAVSWHEEL *"))
;;;	(SETQ cnt (1+ cnt))
;;;      )
;;;      (COND
;;;	((> cnt 1)
;;;          (SETQ inp (STRCAT
;;;		      (SUBSTR inp 1 (1- cnt))
;;;		      (SUBSTR inp cnt 13)
;;;		      "W"
;;;		      (IF (> (STRLEN inp) (+ cnt 13))
;;;		        (SUBSTR inp (+ cnt 14))
;;;			""
;;;	              )
;;;		    )
;;;          ))
;;;	(T
;;;          (SETQ inp (STRCAT
;;;		      (SUBSTR inp cnt 13)
;;;		      "W"
;;;		      (IF (> (STRLEN inp) (+ cnt 13))
;;;		        (SUBSTR inp (+ cnt 14))
;;;			""
;;;	              )
;;;		    )
;;;          ))
;;;      )
;;;    )
    inp
;;;  )
) ;_ end of defun
(PRINC)

 ;|«Visual LISP© Format Options» (80 2 40 2 T "end of " 60 9 2 1 0 T T T T)
 ***Don't add text below the comment!***|;
