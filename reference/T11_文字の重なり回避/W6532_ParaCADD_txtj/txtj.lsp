;;;Modify the text justification of a selection set of text entities. (uses UKWORD UPOINT)
;;;       The only input required is the desired
;;;       text justification and selection of the text to modify.  There
;;;       is no need to worry about selecting non-text entities because
;;;       they will be automatically filtered out of the selection set.
;;;	DO NOT select more than one "common note group".  All of the text
;;;	selected is assumed to belong to such a group and it ALL will be
;;;	justified to the same reference position.
;;;
;;;	AUTHOR: HENRY C. FRANCIS
;;;		425 N. ASHE ST.
;;;		SOUTHERN PINES, NC 28387
;;;              
;;;		All rights reserved without prejudice.
;;;
;;;	Copyright:	7-12-94
;;;	Edited:		8-13-01
;;;
(DEFUN c:txtj (/ tsln cntr edtw	xofbl tj10 tj11	tj72 tj73 tset tent enty mljust
	       entz)
  (IF ukword NIL (LOAD "ukword" "\nFile UKWORD.LSP not loaded! "))
  (IF upoint NIL (LOAD "upoint" "\nFile UPOINT.LSP not loaded! "))
  (IF auto_tjst
    (SETQ tjst auto_tjst)
  (SETQ	tjst
	 (ukword
	   1
	   "Align Fit Left Center Middle Right TL TC TR ML MC MR BL BC BR Y"
	   "Align/Fit/Left/Center/Middle/Right/TL/TC/TR/ML/MC/MR/BL/BC/BR/Y"
	   (IF tjst
	     tjst
	     "L"
	   ) ;_ end of if
	 ) ;_ end of ukword
  ) ;_ end of SETQ
    )
  (PROMPT "\nSelect Text: ")
  (SETQ	tset (SSGET '((-4 . "<or")
		      (0 . "TEXT")
		      (0 . "MTEXT")
		      (0 . "MULTILEADER")
		      (0 . "ATTDEF")
		      (-4 . "<and")
		      (0 . "INSERT")
		      (66 . 1)
		      (-4 . "and>")
		      (-4 . "or>")
		     )
	     ) ;_ end of ssget
  ) ;_ end of setq
  (IF tset
    (PROGN
  (IF (OR (EQ tjst "Y")(EQ (CDR (ASSOC 0 (ENTGET (SSNAME tset 0)))) "MULTILEADER"))
    nil
    (IF auto_tjst
      (SETQ inplace "In")
    (SETQ inplace (ukword 1
			  "In To"
			  "In place or To line?"
			  (IF inplace
			    inplace
			    "T"
			  ) ;_ end of if
		  ) ;_ end of ukword
    ) ;_ end of setq
      )
  ) ;_ end of if
      (SETQ tsln (SSLENGTH tset))
      (SETQ cntr 0)
      (COND
	((EQ (SUBSTR tjst 1 1) "A")
	 (IF (OR (> tsln 1)
		 (EQ (CDR (ASSOC 0 (ENTGET (SSNAME tset 0)))) "MTEXT")
		 (EQ (CDR (ASSOC 0 (ENTGET (SSNAME tset 0)))) "MULTILEADER")
	     ) ;_ end of or
	   (PROGN
	     (IF (> tsln 1)
	       (PROMPT "\nSelect only one text string!")
	       (PROMPT "\n\"Aligned\" not allowed for MTEXT or MULTILEADER!")
	     ) ;_ end of if
	     (SETQ tset nil)
	   ) ;_ end of PROGN
	   (SETQ tj71 0
		 tj72 3
		 tj73 0
		 tj10 (upoint 1 "" "\nFirst Align point" nil nil)
		 tj11 (upoint 1 "" "\nSecond Align point" nil nil)
	   ) ;_ end of SETQ
	 ) ;_ end of IF
	)
	((EQ (SUBSTR tjst 1 1) "F")
	 (IF (OR (> tsln 1)
		 (EQ (CDR (ASSOC 0 (ENTGET (SSNAME tset 0)))) "MTEXT")
		 (EQ (CDR (ASSOC 0 (ENTGET (SSNAME tset 0)))) "MULTILEADER")
	     ) ;_ end of or
	   (PROGN
	     (IF (> tsln 1)
	       (PROMPT "\nSelect only one text string!")
	       (PROMPT "\n\"Fit\" not allowed for MTEXT or MULTILEADER!")
	     ) ;_ end of if
	     (SETQ tset nil)
	   ) ;_ end of PROGN
	   (SETQ tj71 0
		 tj72 5
		 tj73 0
		 tj10 (upoint 1 "" "\nFirst Fit point" nil nil)
		 tj11 (upoint 1 "" "\nSecond Fit point" nil nil)
	   ) ;_ end of SETQ
	 ) ;_ end of IF
	)
	((EQ (SUBSTR tjst 1 1) "L")
	 (IF (EQ (CDR (ASSOC 0 (ENTGET (SSNAME tset 0)))) "MTEXT")
	   (PROMPT "\n\"Left\" not allowed for MTEXT!")
	   (IF (EQ (CDR (ASSOC 0 (ENTGET (SSNAME tset 0)))) "MULTILEADER")
	     (PROGN
	       (SETQ mljust 1); (VLAX-PUT-PROPERTY mltobj 'TextJustify 3)
                              ;  1=Left; 2=Center; 3=Right
	     )
             (SETQ tj71 0
                   tj72 0
                   tj73 0
                   tj10 (IF (EQ inplace "In")
                          T
                          (upoint 1 "" "\nLeft justification line" nil nil)
                        ) ;_ end of if
                   tj11 (LIST 0.0 0.0 0.0)
             ) ;_ end of SETQ
           )
	 ) ;_ end of if
	)
	((EQ (SUBSTR tjst 1 1) "Y")
	   (IF (EQ (CDR (ASSOC 0 (ENTGET (SSNAME tset 0)))) "MULTILEADER")
	     (PROMPT "\n\"Y\" option not allowed for MULTILEADER!")
             (SETQ tj10 (upoint 1 "" "\n\"Y\" justification" nil nil)
           )
	 ) ;_ end of SETQ
	)
	((EQ (SUBSTR tjst 1 1) "C")
	 (IF (EQ (CDR (ASSOC 0 (ENTGET (SSNAME tset 0)))) "MTEXT")
	   (PROMPT "\n\"Center\" not allowed for MTEXT!")
	   (IF (EQ (CDR (ASSOC 0 (ENTGET (SSNAME tset 0)))) "MULTILEADER")
	     (PROGN
	       (SETQ mljust 2); (VLAX-PUT-PROPERTY mltobj 'TextJustify 3)
                              ;  1=Left; 2=Center; 3=Right
	     )
	     (SETQ tj71 0
		   tj72 1
		   tj73 0
		   tj10 nil
		   tj11 (IF (EQ inplace "In")
			  T
			  (upoint 1 "" "\nCenter justification line" nil nil)
		        ) ;_ end of if
	     ) ;_ end of SETQ
	   )
	 ) ;_ end of if
	)
	((AND (EQ (SUBSTR tjst 1 1) "M") (NOT (EQ (STRLEN tjst) 2)))
	 (IF (OR (EQ (CDR (ASSOC 0 (ENTGET (SSNAME tset 0)))) "MTEXT")
		 (EQ (CDR (ASSOC 0 (ENTGET (SSNAME tset 0)))) "MULTILEADER")
             )
	   (PROMPT "\n\"Middle\" not allowed for MTEXT or MULTILEADER!")
	   (SETQ tj71 0
		 tj72 4
		 tj73 0
		 tj10 nil
		 tj11 (IF (EQ inplace "In")
			T
			(upoint 1 "" "\nMiddle justification line" nil nil)
		      ) ;_ end of if
	   ) ;_ end of SETQ
	 ) ;_ end of if
	)
	((EQ (SUBSTR tjst 1 1) "R")
	 (IF (EQ (CDR (ASSOC 0 (ENTGET (SSNAME tset 0)))) "MTEXT")
	   (PROMPT "\n\"Right\" not allowed for MTEXT!")
	   (IF (EQ (CDR (ASSOC 0 (ENTGET (SSNAME tset 0)))) "MULTILEADER")
	     (PROGN
	       (SETQ mljust 3); (VLAX-PUT-PROPERTY mltobj 'TextJustify 3)
                              ;  1=Left; 2=Center; 3=Right
	     )
	     (SETQ tj71 0
		   tj72 2
		   tj73 0
		   tj10 nil
		   tj11 (IF (EQ inplace "In")
			  T
			  (upoint 1 "" "\nRight justification line" nil nil)
		        ) ;_ end of if
	     ) ;_ end of SETQ
	   )
	 ) ;_ end of if
	)
	((EQ tjst "TL")
	 (IF (EQ (CDR (ASSOC 0 (ENTGET (SSNAME tset 0)))) "MTEXT")
	   (SETQ tj71 1
		 tj10 (IF (EQ inplace "In")
			T
			(upoint	1
				""
				"\nTop Left justification line"
				nil
				nil
			       ) ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
		      ) ;_ end of if
	   ) ;_ end of setq
           (IF (EQ (CDR (ASSOC 0 (ENTGET (SSNAME tset 0)))) "MULTILEADER")
	     (PROMPT "\n\"Right\" not allowed for MULTILEADER!")
	     (SETQ tj71 0
		   tj72 0
		   tj73 3
		   tj10 nil
		   tj11 (IF (EQ inplace "In")
			  T
			  (upoint	1
				  ""
				  "\nTop Left justification line"
				  nil
				  nil
			         ) ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
		        ) ;_ end of if
	     ) ;_ end of SETQ
	   )
	 ) ;_ end of if
	)
	((EQ tjst "ML")
	 (IF (EQ (CDR (ASSOC 0 (ENTGET (SSNAME tset 0)))) "MTEXT")
	   (SETQ tj71 4
		 tj10 (IF (EQ inplace "In")
			T
			(upoint
			  1			 ""
			  "\nMiddle Left justification line"
			  nil
			  nil
			 ) ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
		      ) ;_ end of if
	   ) ;_ end of setq
           (IF (EQ (CDR (ASSOC 0 (ENTGET (SSNAME tset 0)))) "MULTILEADER")
	     (PROMPT "\n\"Right\" not allowed for MULTILEADER!")
	     (SETQ tj71 0
		   tj72 0
		   tj73 2
		   tj10 nil
		   tj11 (IF (EQ inplace "In")
			  T
			  (upoint
			    1			 ""
			    "\nMiddle Left justification line"
			    nil
			    nil
			  ) ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
		        ) ;_ end of if
	     ) ;_ end of SETQ
	   )
	 ) ;_ end of if
	)
	((EQ tjst "BL")
	 (IF (EQ (CDR (ASSOC 0 (ENTGET (SSNAME tset 0)))) "MTEXT")
	   (SETQ tj71 7
		 tj10 (IF (EQ inplace "In")
			T
			(upoint
			  1			 ""
			  "\nBottom Left justification line"
			  nil			 nil
			 ) ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
		      ) ;_ end of if
	   ) ;_ end of setq
           (IF (EQ (CDR (ASSOC 0 (ENTGET (SSNAME tset 0)))) "MULTILEADER")
	     (PROMPT "\n\"Right\" not allowed for MULTILEADER!")
	   (SETQ tj71 0
		 tj72 0
		 tj73 1
		 tj10 nil
		 tj11 (IF (EQ inplace "In")
			T
			(upoint
			  1			 ""
			  "\nBottom Left justification line"
			  nil			 nil
			 ) ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
		      ) ;_ end of if
	   ) ;_ end of SETQ
	     )
	 ) ;_ end of if
	)
	((EQ tjst "TC")
	 (IF (EQ (CDR (ASSOC 0 (ENTGET (SSNAME tset 0)))) "MTEXT")
	   (SETQ tj71 2
		 tj10 (IF (EQ inplace "In")
			T
			(upoint
			  1			 ""
			  "\nTop Center justification line"
			  nil			 nil
			 ) ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
		      ) ;_ end of if
	   ) ;_ end of setq
           (IF (EQ (CDR (ASSOC 0 (ENTGET (SSNAME tset 0)))) "MULTILEADER")
	     (PROMPT "\n\"Right\" not allowed for MULTILEADER!")
	   (SETQ tj71 0
		 tj72 1
		 tj73 3
		 tj10 nil
		 tj11 (IF (EQ inplace "In")
			T
			(upoint
			  1			 ""
			  "\nTop Center justification line"
			  nil			 nil
			 ) ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
		      ) ;_ end of if
	   ) ;_ end of SETQ
	   )
	 ) ;_ end of if
	)
	((EQ tjst "MC")
	 (IF (EQ (CDR (ASSOC 0 (ENTGET (SSNAME tset 0)))) "MTEXT")
	   (SETQ tj71 5
		 tj10 (IF (EQ inplace "In")
			T
			(upoint
			  1
			  ""
			  "\nMiddle Center justification line"
			  nil
			  nil
			 ) ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
		      ) ;_ end of if
	   ) ;_ end of setq
           (IF (EQ (CDR (ASSOC 0 (ENTGET (SSNAME tset 0)))) "MULTILEADER")
	     (PROGN
	       (SETQ mljust 2); (VLAX-PUT-PROPERTY mltobj 'TextJustify 3)
                              ;  1=Left; 2=Center; 3=Right
	     )
	   (SETQ tj71 0
		 tj72 1
		 tj73 2
		 tj10 nil
		 tj11 (IF (EQ inplace "In")
			T
			(upoint
			  1
			  ""
			  "\nMiddle Center justification line"
			  nil
			  nil
			 ) ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
		      ) ;_ end of if
	   ) ;_ end of SETQ
	     )
	 ) ;_ end of if
	)
	((EQ tjst "BC")
	 (IF (EQ (CDR (ASSOC 0 (ENTGET (SSNAME tset 0)))) "MTEXT")
	   (SETQ tj71 8
		 tj10 (IF (EQ inplace "In")
			T
			(upoint
			  1
			  ""
			  "\nBottom Center justification line"
			  nil
			  nil
			 ) ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
		      ) ;_ end of if
	   ) ;_ end of setq
           (IF (EQ (CDR (ASSOC 0 (ENTGET (SSNAME tset 0)))) "MULTILEADER")
	     (PROMPT "\n\"Right\" not allowed for MULTILEADER!")
	   (SETQ tj71 0
		 tj72 1
		 tj73 1
		 tj10 nil
		 tj11 (IF (EQ inplace "In")
			T
			(upoint
			  1
			  ""
			  "\nBottom Center justification line"
			  nil
			  nil
			 ) ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
		      ) ;_ end of if
	   ) ;_ end of SETQ
	     )
	 ) ;_ end of if
	)
	((EQ tjst "TR")
	 (IF (EQ (CDR (ASSOC 0 (ENTGET (SSNAME tset 0)))) "MTEXT")
	   (SETQ tj71 3
		 tj10 (IF (EQ inplace "In")
			T
			(upoint	1
				""
				"\nTop Right justification line"
				nil
				nil
			       ) ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
		      ) ;_ end of if
	   ) ;_ end of setq
           (IF (EQ (CDR (ASSOC 0 (ENTGET (SSNAME tset 0)))) "MULTILEADER")
	     (PROMPT "\n\"Right\" not allowed for MULTILEADER!")
	   (SETQ tj71 0
		 tj72 2
		 tj73 3
		 tj10 nil
		 tj11 (IF (EQ inplace "In")
			T
			(upoint	1
				""
				"\nTop Right justification line"
				nil
				nil
			       ) ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
		      ) ;_ end of if
	   ) ;_ end of SETQ
	     )
	 ) ;_ end of if
	)
	((EQ tjst "MR")
	 (IF (EQ (CDR (ASSOC 0 (ENTGET (SSNAME tset 0)))) "MTEXT")
	   (SETQ tj71 6
		 tj10 (IF (EQ inplace "In")
			T
			(upoint
			  1
			  ""
			  "\nMiddle Right justification line"
			  nil
			  nil
			 ) ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
		      ) ;_ end of if
	   ) ;_ end of setq
           (IF (EQ (CDR (ASSOC 0 (ENTGET (SSNAME tset 0)))) "MULTILEADER")
	     (PROMPT "\n\"Right\" not allowed for MULTILEADER!")
	   (SETQ tj71 0
		 tj72 2
		 tj73 2
		 tj10 nil
		 tj11 (IF (EQ inplace "In")
			T
			(upoint
			  1
			  ""
			  "\nMiddle Right justification line"
			  nil
			  nil
			 ) ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
		      ) ;_ end of if
	   ) ;_ end of SETQ
	     )
	 ) ;_ end of if
	)
	((EQ tjst "BR")
	 (IF (EQ (CDR (ASSOC 0 (ENTGET (SSNAME tset 0)))) "MTEXT")
	   (SETQ tj71 9
		 tj10 (IF (EQ inplace "In")
			T
			(upoint
			  1
			  ""
			  "\nBottom Right justification line"
			  nil
			  nil
			 ) ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
		      ) ;_ end of if
	   ) ;_ end of setq
           (IF (EQ (CDR (ASSOC 0 (ENTGET (SSNAME tset 0)))) "MULTILEADER")
	     (PROMPT "\n\"Right\" not allowed for MULTILEADER!")
	   (SETQ tj71 0
		 tj72 2
		 tj73 1
		 tj10 nil
		 tj11 (IF (EQ inplace "In")
			T
			(upoint
			  1
			  ""
			  "\nBottom Right justification line"
			  nil
			  nil
			 ) ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
 ;_ end of upoint
		      ) ;_ end of if
	   ) ;_ end of SETQ
	     )
	 ) ;_ end of if
	)
      ) ;_ end of COND
    ) ;_ end of PROGN
  ) ;_ end of IF
  (WHILE
    (IF	(AND (< cntr tsln) tset)
      (SETQ tent (ENTGET (SSNAME tset cntr)))
    ) ;_ end of IF
     (PROGN
       (SETQ edtw (ENTGET (CDAR tent)))
       (IF (OR
	     (EQ (CDR (ASSOC 0 edtw)) "TEXT")
	     (EQ (CDR (ASSOC 0 edtw)) "MTEXT")
	     (EQ (CDR (ASSOC 0 edtw)) "MULTILEADER")
	     (EQ (CDR (ASSOC 0 edtw)) "INSERT")
	     (EQ (CDR (ASSOC 0 edtw)) "ATTDEF")
	   ) ;_ end of OR
	 (PROGN
	   (IF (EQ (CDR (ASSOC 0 edtw)) "INSERT")
	     (WHILE (/= (CDR (ASSOC 0 edtw)) "SEQEND")
	       (SETQ edtw (CDAR (ENTGET (ENTNEXT))))
	       (IF (EQ (CDR (ASSOC 0 edtw)) "ATTRIB")
		 (PROGN
		   (SETQ
		     shall_jst (ukword
				 1
				 "Yes No"
				 (STRCAT "\nAttribute value is "
					 (CDR (ASSOC 1 edtw))
					 "  Rejustify this attribute?"
				 ) ;_ end of strcat
				 (IF shall_jst
				   shall_jst
				   "No"
				 ) ;_ end of if
			       ) ;_ end of ukword
		   ) ;_ end of setq
		   (IF (EQ shall_jst "Yes")
		     (SETQ attrib_todo edtw)
		   ) ;_ end of if
		 ) ;_ end of progn
	       ) ;_ end of if
	       (IF attrib_todo
		 (SETQ edtw attrib_todo)
	       ) ;_ end of if
	     ) ;_ end of while
	   ) ;_ end of if
	   (SETQ
	     ent71 (CDR (ASSOC 71 edtw))
	     ent72 (CDR (ASSOC 72 edtw))
	     ent73 (CDR (ASSOC 73 edtw))
	     ent0y (CADDR (ASSOC 10 edtw))
	     ent0z (CADDDR (ASSOC 10 edtw))
	   ) ;_ end of setq
	   (IF (OR
		 (EQ (CDR (ASSOC 0 edtw)) "MTEXT")
		 (EQ (CDR (ASSOC 0 edtw)) "MULTILEADER")
		 (EQ (SUBSTR tjst 1 1) "Y")
	       ) ;_ end of OR
	     nil
	     (IF (EQ tj11 T)
	       (IF
		 (EQUAL
		   (LIST 0.0 0.0)
		   (LIST (CADR (ASSOC 11 edtw)) (CADDR (ASSOC 11 edtw)))
		   0.1
		 ) ;_ end of equal
		  (IF (EQ tjst "MC")
		    (PROGN
		      (SETQ tjbox (TEXTBOX edtw)
			    tjrot (CDR (ASSOC 50 edtw))
			    diang (ANGLE (CAR tjbox) (CADR tjbox))
			    hdist (* (/	(DISTANCE (CAR tjbox) (CADR tjbox))
					2.0
				     ) ;_ end of /
				     (COS diang)
				  ) ;_ end of *
			    tj11a (POLAR
				    (POLAR (CDR (ASSOC 10 edtw))
					   (CDR (ASSOC 50 edtw))
					   hdist
				    ) ;_ end of polar
				    (+ (/ PI 2.0) (CDR (ASSOC 50 edtw)))
				    (/ (CDR (ASSOC 40 edtw)) 2.0)
				  ) ;_ end of polar
			    tj11x (CAR tj11a)
			    tj11y (CADR tj11a)
			    tj11z (CADDR tj11a)
		      ) ;_ end of setq
		    ) ;_ end of PROGN
		    (SETQ tj11x	(CADR (ASSOC 10 edtw))
			  tj11y	(CADDR (ASSOC 10 edtw))
			  tj11z	(CADDDR (ASSOC 10 edtw))
		    ) ;_ end of setq
		  ) ;_ end of if
		  (SETQ	tj11x (CADR (ASSOC 11 edtw))
			tj11y (CADDR (ASSOC 11 edtw))
			tj11z (CADDDR (ASSOC 11 edtw))
		  ) ;_ end of setq
	       ) ;_ end of if
	       (SETQ tj11x (CAR (TRANS tj11 1 (SSNAME tset cntr)))
		     tj11y (CADR (TRANS tj11 1 (SSNAME tset cntr)))
		     tj11z (CADDR (TRANS tj11 1 (SSNAME tset cntr)))
	       ) ;_ end of SETQ
	     ) ;_ end of if
	   ) ;_ end of if
	   (IF (EQ (CDR (ASSOC 0 edtw)) "MTEXT")
	     (PROGN
	       (SETQ edtw
		      (SUBST (CONS 71 tj71)
			     (ASSOC 71 edtw)
			     edtw
		      ) ;_ end of subst
	       ) ;_ end of SETQ
	       (PROGN
		 (IF (EQ tj10 T)
		   nil
		   (SETQ tj10x (CAR (TRANS (CDR(ASSOC 10(ENTGET(SSNAME tset cntr)))) 10 1 (SSNAME tset cntr)))
			 edtw
			       (SUBST (LIST 10 tj10x ent0y ent0z)
				      (ASSOC 10 edtw)
				      edtw
			       ) ;_ end of subst
		   ) ;_ end of SETQ
		 ) ;_ end of IF
	       ) ;_ end of progn
	     ) ;_ end of progn
	     (IF (EQ (CDR (ASSOC 0 edtw)) "MULTILEADER")
	       (IF mljust
		 (PROGN
		   (setq mltobj (vlax-ename->vla-object (SSNAME tset 0)))
		   (VLAX-PUT-PROPERTY mltobj 'TextJustify mljust)
		 )
	       )
	     (PROGN
	       (IF (ASSOC 71 edtw)
		 (SETQ edtw
			(SUBST (CONS 71 tj71)
			       (ASSOC 71 edtw)
			       edtw
			) ;_ end of subst
		 ) ;_ end of SETQ
	       ) ;_ end of IF
	       (IF (ASSOC 72 edtw)
		 (SETQ edtw
			(SUBST (CONS 72 tj72)
			       (ASSOC 72 edtw)
			       edtw
			) ;_ end of subst
		 ) ;_ end of SETQ
	       ) ;_ end of IF
	       (IF (ASSOC 73 edtw)
		 (SETQ edtw
			(SUBST (CONS 73 tj73)
			       (ASSOC 73 edtw)
			       edtw
			) ;_ end of subst
		 ) ;_ end of SETQ
	       ) ;_ end of IF
	       (COND
		 ((EQ (SUBSTR tjst 1 1) "L")
		  (SETQ	edtw
			 (SUBST	(LIST 11 0.0 0.0 0.0)
				(ASSOC 11 edtw)
				edtw
			 ) ;_ end of subst
		  ) ;_ end of SETQ
		  (IF (EQ tj10 T)
		    nil
		    (PROGN
		      (SETQ tj10x (CAR (TRANS tj10 1 (SSNAME tset cntr)))
			    edtw
				  (SUBST (LIST 10 tj10x ent0y ent0z)
					 (ASSOC 10 edtw)
					 edtw
				  ) ;_ end of subst
		      ) ;_ end of SETQ
		    ) ;_ end of progn
		  ) ;_ end of if
		 )
		 ((NOT (OR (EQ (SUBSTR tjst 1 1) "A")
			   (EQ (SUBSTR tjst 1 1) "F")
			   (EQ (SUBSTR tjst 1 1) "Y")
		       ) ;_ end of or
		  ) ;_ end of not
		  (IF (EQ tj11 T)
		    (PROGN
		      (SETQ edtw
			     (SUBST (LIST 11 tj11x tj11y tj11z)
				    (ASSOC 11 edtw)
				    edtw
			     ) ;_ end of subst
		      ) ;_ end of SETQ
					;                (if (not tj10)
					;                  (setq edtw
					;                    (subst (list 10 tj10x tj10y tj10z)
					;                           (assoc 10 edtw)
					;                           edtw
					;                    )
					;                  )
					;                )
		    ) ;_ end of progn
		    (SETQ edtw
			   (SUBST (LIST 11 tj11x ent0y ent0z)
				  (ASSOC 11 edtw)
				  edtw
			   ) ;_ end of subst
		    ) ;_ end of SETQ
		  ) ;_ end of if
		 )
		 ((OR (EQ (SUBSTR tjst 1 1) "A")
		      (EQ (SUBSTR tjst 1 1) "F")
		  ) ;_ end of or
		  (SETQ	edtw
			 (SUBST	(LIST 11 tj11x tj11y tj11z)
				(ASSOC 11 edtw)
				edtw
			 ) ;_ end of subst
		  ) ;_ end of SETQ
		  (IF (EQ tj10 T)
		    nil
		    (PROGN
		      (SETQ tj10x (CAR (TRANS tj10 1 (SSNAME tset cntr)))
			    tj10y (CADR (TRANS tj10 1 (SSNAME tset cntr)))
			    tj10z (CADDR (TRANS tj10 1 (SSNAME tset cntr)))
			    edtw
				  (SUBST (LIST 10 tj10x tj10y tj10z)
					 (ASSOC 10 edtw)
					 edtw
				  ) ;_ end of subst
		      ) ;_ end of SETQ
		    ) ;_ end of progn
		  ) ;_ end of if
		 )
		 ((EQ (SUBSTR tjst 1 1) "Y")
		  (SETQ	edtw
			 (SUBST	(LIST 10
				      (CADR (ASSOC 10 edtw))
				      (CADR tj10)
				      (CADDDR (ASSOC 10 edtw))
				) ;_ end of LIST
				(ASSOC 10 edtw)
				edtw
			 ) ;_ end of subst
		  ) ;_ end of SETQ
		  (IF (EQUAL (ASSOC 11 edtw)
			     (CONS 11 (LIST 0.0 0.0 0.0))
			     0.01
		      ) ;_ end of EQUAL
		    NIL
		    (SETQ edtw
			   (SUBST (LIST	11
					(CADR (ASSOC 11 edtw))
					(CADR tj10)
					(CADDDR (ASSOC 11 edtw))
				  ) ;_ end of LIST
				  (ASSOC 11 edtw)
				  edtw
			   ) ;_ end of subst
		    ) ;_ end of SETQ
		  ) ;_ end of IF
		  (SETQ edtw (SUBST (CONS 72 ent72)(ASSOC 72 edtw)edtw))
		  (SETQ edtw (SUBST (CONS 73 ent73)(ASSOC 73 edtw)edtw))
		 )
	       ) ;_ end of COND
	     ) ;_ end of progn
	       )
	   ) ;_ end of if
	   (IF (EQ (CDR (ASSOC 0 edtw)) "MULTILEADER")
	     NIL
	     (ENTMOD edtw)
	   )
	 ) ;_ end of progn
       ) ;_ end of if
       (SETQ cntr (1+ cntr))
     ) ;_ end of progn
  ) ;_ end of while
  (SETQ auto_tjst NIL)
) ;_ end of DEFUN
(DEFUN C:TJMC ()
  (SETQ auto_tjst "MC")
  (c:txtj)
  (SETQ auto_tjst NIL)
  (PRINC)
)
(DEFUN c:fixmt ()
  (SETQ edtw (ENTGET (CAR (ENTSEL))))
;;;	   (IF (AND (EQ tjst "MC")(EQ (CDR (ASSOC 0 edtw)) "MTEXT"))
;;;	     (PROGN
  (SETQ
    tj10 (POLAR	(CDR (ASSOC 10 edtw))
		(ANGLE (CDR (ASSOC 10 edtw)) (CDR (ASSOC 11 edtw)))
		(DISTANCE (CDR (ASSOC 10 edtw)) (CDR (ASSOC 11 edtw)))
	 ) ;_ end of POLAR
  ) ;_ end of SETQ
  (SETQ
    tj11 (POLAR	(CDR (ASSOC 11 edtw))
		(ANGLE (CDR (ASSOC 10 edtw)) (CDR (ASSOC 11 edtw)))
		(DISTANCE (CDR (ASSOC 10 edtw)) (CDR (ASSOC 11 edtw)))
	 ) ;_ end of POLAR
  ) ;_ end of SETQ
  (SETQ edtw (SUBST (CONS 10 tj10) (ASSOC 10 edtw) edtw))
  (SETQ edtw (SUBST (CONS 11 tj11) (ASSOC 11 edtw) edtw))
  (ENTMOD edtw)
;;;	     )
;;;	   )
  (PRINC)
) ;_ end of defun
(PRINC)

 ;|«Visual LISP© Format Options» (72 2 40 2 T "end of " 60 9 2 0 0 T T nil T)
 ***Don't add text below the comment!***|;
