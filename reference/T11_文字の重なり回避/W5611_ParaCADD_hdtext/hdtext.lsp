;;;Place "hiding" solids over each text string. (on layer ?-NPLT?????HS).
;;;Adjust spacing using HDSPACE for numeric and HDMATCH for matched text.
;;;
;;;Added exclusion of text with thickness = 1.0
;;;
;;;	AUTHOR: HENRY C. FRANCIS
;;;		425 N. ASHE ST.
;;;		SOUTHERN PINES, NC 28387
;;;		All rights reserved without prejudice.
;;;
;;;	Copyright:      1-26-96
;;;	Edited:		10-25-01
;;;
(DEFUN c:hdtext	(/	ss     sslen  count  oldss  delold ntz
		 tname	tent   tp1    tang   tbang  tp2	   bxp1
		 bxp2	bxp3   bxp4
		)
  (vl-load-com)
  (SETVAR "cmdecho" 0)
  (IF sp_size
    NIL
    (SETQ sp_size 0.45)
  ) ;_ end of IF
  (IF hd_size
    NIL
    (SETQ hd_size 0.45)
  ) ;_ end of IF
  (IF hd_wcstr
    NIL
    (SETQ hd_wcstr "")
  ) ;_ end of IF
  (IF (/= "BYLAYER" (GETVAR "cecolor"))
    (SETVAR "CECOLOR" "BYLAYER")
  ) ;_ end of IF
  (IF ukword
    nil
    (LOAD "uutils")
  ) ;_ end of if
  (SETQ	cr    (LIST "w"	  "o"	"r"   "y"   "d"	  "u"	"e"   "t"
		    "h"	  "f"	"a"   "g"   "n"	  "c"	"i"   "p"
		    "r"	  "s"	"j"   "l"   "v"	  "b"
		   ) ;_ end of LIST
 ;_ end of LIST
 ;_ end of LIST
 ;_ end of LIST
 ;_ end of list
	wrd1  (STRCAT			;Copyright
		(STRCASE (NTH 13 cr))
		(NTH 1 cr)
		(NTH 15 cr)
		(NTH 3 cr)
		(NTH 2 cr)
		(NTH 14 cr)
		(NTH 11 cr)
		(NTH 8 cr)
		(NTH 7 cr)
	      ) ;_ end of strcat
	wrd2  " "
	wrd3  (STRCAT (ITOA 1996) "-" (ITOA 2015))
	wrd4  ", "
	wrd4b (STRCAT			;by
		(NTH 21 cr)
		(NTH 3 cr)
	      ) ;_ end of strcat
	wrd5  (STRCAT			;Henry
		(STRCASE (NTH 8 cr))
		(NTH 6 cr)
		(NTH 12 cr)
		(NTH 2 cr)
		(NTH 3 cr)
	      ) ;_ end of strcat
	wrd6  (STRCASE (NTH 13 cr))	;C
	wrd6a ". "
	wrd7  (STRCAT			;Francis
		(STRCASE (NTH 9 cr))
		(NTH 2 cr)
		(NTH 10 cr)
		(NTH 12 cr)
		(NTH 13 cr)
		(NTH 14 cr)
		(NTH 17 cr)
	      ) ;_ end of strcat
	wrd8  (STRCAT			;without
		(NTH 0 cr)
		(NTH 14 cr)
		(NTH 7 cr)
		(NTH 8 cr)
		(NTH 1 cr)
		(NTH 5 cr)
		(NTH 7 cr)
	      ) ;_ end of strcat
	wrd9  (STRCAT			;prejudice
		(NTH 15 cr)
		(NTH 2 cr)
		(NTH 6 cr)
		(NTH 18 cr)
		(NTH 5 cr)
		(NTH 4 cr)
		(NTH 14 cr)
		(NTH 13 cr)
		(NTH 6 cr)
	      ) ;_ end of strcat
	wrd10 (STRCAT			;All
		(STRCASE (NTH 10 cr))
		(NTH 19 cr)
		(NTH 19 cr)
	      ) ;_ end of strcat
	wrd11 (STRCAT			;rights
		(NTH 2 cr)
		(NTH 14 cr)
		(NTH 11 cr)
		(NTH 8 cr)
		(NTH 7 cr)
		(NTH 17 cr)
	      ) ;_ end of strcat
	wrd12 (STRCAT			;reserved
		(NTH 2 cr)
		(NTH 6 cr)
		(NTH 17 cr)
		(NTH 6 cr)
		(NTH 2 cr)
		(NTH 20 cr)
		(NTH 6 cr)
		(NTH 4 cr)
	      ) ;_ end of strcat
  ) ;_ end of setq
  (IF
    (NOT (EQ (STRCAT (NTH 3 cr) (NTH 6 cr) (NTH 17 cr)) "yes"))
     (PRINC "Copyright has been violated! ")
     (PROGN
       (SETQ curvpn (GETVAR "cvport"))
       (SETQ prehdtext_ss (SSGET "P"))
       (IF (EQ (GETVAR "tilemode") 0)
	 (SETQ mp_space
		(ukword
		  1
		  "Model Paper"
		  "Prepare to hide under text in Model or Paper space <M,P>?"
		  (IF mp_space
		    mp_space
		    "Model"
		  ) ;_ end of if
		) ;_ end of ukword
	 ) ;_ end of setq
	 (SETQ mp_space "Model")
       ) ;_ end of if
       (SETQ one_all (ukword 1
			     "Select All Visible"
			     "<S>elect text or <A>ll text? "
			     (IF one_all
			       one_all
			       "All"
			     ) ;_ end of if
		     ) ;_ end of ukword
       ) ;_ end of setq
       (COND
	 ((EQ mp_space "Model")
	  (IF (EQ one_all "Select")
	    (SETQ ss	(SSGET '((-4 . "<AND")
				 (0 . "TEXT")
				 (-4 . "<NOT")
				 (67 . 1)
				 (-4 . "NOT>")
				 (-4 . "AND>")
				)
			) ;_ end of ssget
		  as_67	0
	    ) ;_ end of setq
	    (SETQ ss	(SSGET "x"
			       '((-4 . "<AND")
				 (0 . "TEXT")
				 (-4 . "<NOT")
				 (67 . 1)
				 (-4 . "NOT>")
				 (-4 . "AND>")
				)
			) ;_ end of ssget
		  as_67	0
	    ) ;_ end of setq
	  ) ;_ end of if
	  (IF (EQ (GETVAR "tilemode") 0)
            (vla-put-MSpace (vla-get-Activedocument (vlax-get-Acad-Object)) :vlax-true)
;;;	    (COMMAND "_.mspace")
	  ) ;_ end of if
	 )
	 ((EQ mp_space "Paper")
	  (IF (EQ one_all "Select")
	    (SETQ ss	(SSGET '((-4 . "<AND")
				 (0 . "TEXT")
				 (67 . 1)
				 (-4 . "AND>")
				)
			) ;_ end of ssget
		  as_67	1
	    ) ;_ end of setq
	    (SETQ ss	(SSGET "x"
			       '((-4 . "<AND")
				 (0 . "TEXT")
				 (67 . 1)
				 (-4 . "AND>")
				)
			) ;_ end of ssget
		  as_67	1
	    ) ;_ end of setq
	  ) ;_ end of if
          (vla-put-MSpace (vla-get-Activedocument (vlax-get-Acad-Object)) :vlax-false)
;;;	  (COMMAND "_.pspace")
	 )
       ) ;_ end of cond
       (IF (tblobjname "block" "hdbox")
	 nil
	   (progn
	     (command "-insert" "hdbox")
	     (command)
	   )
       )
       (if (or(and(setq dwgfound (findfile "hdbox.dwg"))(setq bmpfound(findfile "1x1.bmp"))(EQ mp_space "Paper"))(EQ mp_space "Model"))
	 (progn
       (c:enplths)
       (IF (AND (OR (EQ mp_space "Model") (EQ mp_space "Paper")) ss)
	 (PROGN
	   (SETQ sslen (SSLENGTH ss)
		 count 0
		 ntz   100000
		 colr  "1"
	   ) ;_ end of setq
	   (WHILE
	     (NOT (EQ count sslen))
	      (IF (= (CDR (ASSOC 71 tent)) 2)
		(SETQ ntz (- 0 (ABS ntz)))
		(SETQ ntz (ABS ntz))
	      ) ;_ end of if
	      (SETQ tname (SSNAME ss count)
		    10a	  (ASSOC 10 (ENTGET tname))
		    11a	  (ASSOC 11 (ENTGET tname))
		    10b	  (LIST (CAR 10a) (CADR 10a) (CADDR 10a) 0.0);(CADDDR 10a)
		    11b	  (LIST (CAR 11a) (CADR 11a) (CADDR 11a) 0.0);(CADDDR 11a)
		    tname (ENTGET tname)
		    tname (SUBST 10b 10a tname)
		    tname (SUBST 11b 11a tname)
	      ) ;_ end of setq
	      (IF (AND (ASSOC 12 tname) (ASSOC 13 tname))
		(SETQ 12a   (ASSOC 12 tname)
		      13a   (ASSOC 13 tname)
		      12b   (LIST (CAR 12a) (CADR 12a) (CADDR 12a) 0.0);(CADDDR 12a)
		      13b   (LIST (CAR 13a) (CADR 13a) (CADDR 13a) 0.0);(CADDDR 13a)
		      tname (SUBST 12b 12a tname)
		      tname (SUBST 13b 13a tname)
		) ;_ end of setq
	      ) ;_ end of if
	      (ENTMOD tname)
	      (SETQ count (1+ count))
	   ) ;_ end of while
	   (SETQ count 0)
	   (WHILE (NOT (EQ sslen count))
;;;	     (SETQ tname (SSNAME ss count)
;;;		   tent	 (ENTGET tname)
;;;		   tval	 (CDR (ASSOC 1 tent))
;;;		   tbox	 (TEXTBOX tent)
;;;		   txht	 (CDR (ASSOC 40 tent))
;;;		   tdis	 (- (CAR (NTH 1 tbox)) (CAR (NTH 0 tbox)))
;;;		   tp1	 (POLAR
;;;			   (POLAR (CDR (ASSOC 10 tent))
;;;				  (CDR (ASSOC 50 tent))
;;;				  (CAR (NTH 0 tbox))
;;;			   ) ;_ end of POLAR
;;;			   (+ (CDR (ASSOC 50 tent)) (* PI 0.5))
;;;			   (CADR (NTH 0 tbox))
;;;			 ) ;_ end of POLAR
;;;	     ) ;_ end of setq
	     (SETQ tname (SSNAME ss count)
		   tent	 (ENTGET tname)
		   tenthk (ASSOC 39 tent)
		   tval	 (CDR (ASSOC 1 tent))
		   tbox	 (TEXTBOX tent)
             )
	     (SETQ tbox  (LIST(LIST(CAAR tbox) 0.0 0.0)(LIST(CAADR tbox)(CDR(ASSOC 40 tent)) 0.0))
	           txht	 (CDR (ASSOC 40 tent))
		   tdis	 (- (CAR (NTH 1 tbox)) (CAR (NTH 0 tbox)))
	           tp1	 (POLAR
			   (POLAR (CDR (ASSOC 10 tent))
				  (CDR (ASSOC 50 tent))
				  (CAR (NTH 0 tbox))
			   ) ;_ end of POLAR
			   (+ (CDR (ASSOC 50 tent)) (* PI 0.5))
			   (CADR (NTH 0 tbox))
			 ) ;_ end of POLAR
	     ) ;_ end of setq
	     (IF (AND
		   (NOT (WCMATCH tval (STRCAT (CHR 34) "*")))
		   (NOT (WCMATCH tval (STRCAT (CHR 40) "*")))
		   (NOT (WCMATCH tval (STRCAT (CHR 41) "*")))
		   (NOT (WCMATCH tval (STRCAT (CHR 46) "*")))
		 ) ;_ end of AND
	       (IF (AND	(OR (EQUAL (TYPE (READ tval)) 'INT)
			    (EQUAL (TYPE (READ tval)) 'REAL)
			) ;_ end of OR
			(NOT (WCMATCH tval "*@*"))
		   ) ;_ end of AND
		 (SETQ txtsp_fact (/ 1.0 sp_size))
					; TXTSP_FACT was hard coded at 2.10
		 (SETQ txtsp_fact (/ 1.0 0.45))
	       ) ;_ end of IF
	       (SETQ txtsp_fact (/ 1.0 0.45))
	     ) ;_ end of IF
	     (COND
	       ((AND
		  (NOT (WCMATCH tval (STRCAT (CHR 34) "*")))
		  (NOT (WCMATCH tval (STRCAT (CHR 40) "*")))
		  (NOT (WCMATCH tval (STRCAT (CHR 41) "*")))
		  (NOT (WCMATCH tval (STRCAT (CHR 46) "*")))
		) ;_ end of AND
		(IF (AND
		      (OR (EQUAL (TYPE (READ tval)) 'INT)
			  (EQUAL (TYPE (READ tval)) 'REAL)
		      ) ;_ end of OR
		      (NOT (WCMATCH tval "*@*"))
		    ) ;_ end of AND
		  (SETQ hd_sp sp_size)
		  (IF (WCMATCH tval hd_wcstr)
		    (SETQ hd_sp hd_size)
		    (SETQ hd_sp 0.45)
		  ) ;_ end of IF
		) ;_ end of IF
	       )
	       (T (SETQ hd_sp 0.45))
	     ) ;_ end of COND
	     (IF (< (NTH 1 (NTH 1 tbox)) txht)
	       (SETQ txht (NTH 1 (NTH 1 tbox)))
	     ) ;_ end of IF
	     (SETQ tang	 (CDR (ASSOC 50 tent))
		   tlayr (CDR (ASSOC 8 tent))
		   tp2	 (POLAR
			   (POLAR tp1 tang tdis)
			   (+ tang (* PI 0.5))
			   (- (CADR (NTH 1 tbox)) (CADR (NTH 0 tbox)))
			 ) ;_ end of POLAR
	     ) ;_ end of setq
	     (SETQ bxp1	(POLAR
			  (POLAR tp1	;Set 3DFace points for normal text
				 (- tang (* PI 0.5))
				 (* txht hd_sp)
			  ) ;_ end of POLAR
			  (- tang PI)
			  (* txht hd_sp)
			) ;_ end of polar
		   bxp2	(POLAR bxp1
			       (+ tang (* PI 0.50))
			       (+ (* 2.00 txht hd_sp)
				  (CADR (NTH 1 tbox))
				  (- (CADR (NTH 0 tbox)))
			       ) ;_ end of +
			) ;_ end of polar
		   bxp4	(POLAR
			  (POLAR tp2
				 (+ tang (* PI 0.5))
				 (* txht hd_sp)
			  ) ;_ end of polar
			  tang
			  (* txht hd_sp)
			) ;_ end of POLAR
		   bxp3	(POLAR bxp4
			       (- tang (* PI 0.50))
			       (+ (* 2.00 txht hd_sp)
				  (CADR (NTH 1 tbox))
				  (- (CADR (NTH 0 tbox)))
			       ) ;_ end of +
			) ;_ end of polar
	     ) ;_ end of setq
	     (IF (= (CDR (ASSOC 71 tent)) 2)
					;if its backward (mirrored in x)
	       (SETQ ntz (- 0 (ABS ntz))) ;reverse the Z
	       (SETQ ntz (ABS ntz))
	     ) ;_ end of if
	     (SETQ bxp1	(TRANS (LIST (CAR bxp1) (CADR bxp1) ntz) 0 1)
		   bxp2	(TRANS (LIST (CAR bxp2) (CADR bxp2) ntz) 0 1)
		   bxp3	(TRANS (LIST (CAR bxp3) (CADR bxp3) ntz) 0 1)
		   bxp4	(TRANS (LIST (CAR bxp4) (CADR bxp4) ntz) 0 1)
	     ) ;_ end of setq
	     (IF (>= 11 (STRLEN tlayr))
	       (SETQ modf (SUBSTR tlayr 8 4))
	       (SETQ modf "NOTE")
	     ) ;_ end of if
	     (IF (>= (STRLEN tlayr) 6)
	       (SETQ hsvno (SUBSTR tlayr 3 4))
	       (SETQ hsvno "NOTE")
	     ) ;_ end of if
	     (SETQ tlayr (STRCAT "C-"
				 hsvno
				 (IF (EQ mp_space "Paper")
				   "-TEXT-HIDE"
				   "DNPLT"
				 )
				 (IF (EQ mp_space "Paper")
				   ""
				   (IF (> (STRLEN tlayr) 11)
				     (SUBSTR tlayr 12)
				     ""
				   ) ;_ end of if
				 )
				 (IF (EQ mp_space "Paper")
				   ""
				   "HS"
				 )
			 ) ;_ end of strcat
	     ) ;_ end of setq
	     (IF (AND (> tdis 0)(OR (NOT tenthk)(/=(CDR tenthk)1.0)))
	       (PROGN
		 (SETQ box_angle (ANGLE bxp1 bxp3)
		       box_x_scale (DISTANCE bxp1 bxp3)
		       box_y_scale (DISTANCE bxp1 bxp2)
		 )
		 (IF (EQ mp_space "Paper")
		   (PROGN
		     (SETQ hdboxlst
			(LIST
			  (CONS 0 "INSERT")
			  (CONS 2 "HDBOX")
			  (CONS 10 bxp1)
			  (CONS 8 tlayr)
			  (CONS 41 box_x_scale)
			  (CONS 42 box_y_scale)
			  (CONS 43 1.0)
			  (CONS 50 box_angle)
			  (CONS 67 as_67)
			  (CONS 70 1)
			  (CONS 71 1)
			)
		     )
		     (ENTMAKE hdboxlst)
		   )
		   (PROGN
		     (SETQ 3dflst
			(LIST
			  (CONS 0 "3DFACE")
			  (CONS 8 tlayr)
			  (CONS 10 bxp1)
			  (CONS 11 bxp2)
			  (CONS 12 bxp4)
			  (CONS 13 bxp3)
			  (CONS 62 255)
			  (CONS 67 as_67)
			  (CONS 70 15)
			) ;_ end of list
		     ) ;_ end of setq
		     (ENTMAKE 3dflst)
		   )
		 )
	       ) ;_ end of progn
	     ) ;_ end of if
	     (SETQ count (1+ count))
	   ) ;_ end of while
	   
	   (IF (OR (EQ (SUBSTR (GETVAR "clayer") 3 4) "NPLT")
		   (EQ (SUBSTR (GETVAR "clayer") 8 4) "NPLT")
	       ) ;_ end of or
	     (COMMAND ".layer" "m" "TEMP" "")
	   ) ;_ end of if
	 ) ;_ end of progn
       ) ;_ end of if


       
;;;Setq debugpts T to enable placement of text at the points "bxp#"
        (IF debugpts
          (IF pttxt
            NIL
            (LOAD "pttxt" "\nFile PTXT.LSP not loaded!")
          ) ;_ end of IF
        ) ;_ end of if
        (IF (AND debugpts pttxt)
          (PROGN (IF fthk
                   nil
                   (SETQ fthk 5.0)
                 ) ;_ end of IF
                 (pttxt "HDBOX_" "bxp" 1 5)
          ) ;_ end of PROGN
        ) ;_ end of if
;;;Use the above to graphically identify and debug the defined points.
  
       (SETQ hide_dims (ukword 1
			       "Yes No"
			       "Hide dimension text also?"
			       (IF hide_dims
				 hide_dims
				 "Yes"
			       ) ;_ end of IF
		       ) ;_ end of ukword
       ) ;_ end of SETQ
       (IF (EQ hide_dims "Yes")
	 (PROGN
	   (IF c:dims
	     nil
	     (LOAD "dims")
	   ) ;_ end of if
	   (c:dims)
	 ) ;_ end of PROGN
       ) ;_ end of IF


       
       (COND
	 ((EQ mp_space "Model")
	  (IF (EQ one_all "Select")
	    (SETQ hdbox_ss	(SSGET '((-4 . "<AND")
				 (0 . "INSERT")
				 (2 . "HDBOX")
				 (-4 . "<NOT")
				 (67 . 1)
				 (-4 . "NOT>")
				 (-4 . "AND>")
				)
			) ;_ end of ssget
		  as_67	0
	    ) ;_ end of setq
	    (SETQ hdbox_ss	(SSGET "x"
			       '((-4 . "<AND")
				 (0 . "INSERT")
				 (2 . "HDBOX")
				 (-4 . "<NOT")
				 (67 . 1)
				 (-4 . "NOT>")
				 (-4 . "AND>")
				)
			) ;_ end of ssget
		  as_67	0
	    ) ;_ end of setq
	  ) ;_ end of if
	  (IF (EQ one_all "Select")
	    (SETQ txdim_ss	(SSGET
			       '((-4 . "<AND")
				 (-4 . "<OR")
				 (0 . "TEXT")
				 (0 . "DIMENSION")
				 (-4 . "OR>")
				 (-4 . "<NOT")
				 (67 . 1)
				 (-4 . "NOT>")
				 (-4 . "AND>")
				)
			) ;_ end of ssget
		  as_67	0
	    ) ;_ end of setq
	    (SETQ txdim_ss	(SSGET "x"
			       '((-4 . "<AND")
				 (-4 . "<OR")
				 (0 . "TEXT")
				 (0 . "DIMENSION")
				 (-4 . "OR>")
				 (-4 . "<NOT")
				 (67 . 1)
				 (-4 . "NOT>")
				 (-4 . "AND>")
				)
			) ;_ end of ssget
		  as_67	0
	    ) ;_ end of setq
	  ) ;_ end of if
	  (IF (EQ (GETVAR "tilemode") 0)
            (vla-put-MSpace (vla-get-Activedocument (vlax-get-Acad-Object)) :vlax-true)
;;;	    (COMMAND "_.mspace")
	  ) ;_ end of if
	 )
	 ((EQ mp_space "Paper")
	  (IF (EQ one_all "Select")
	    (SETQ hdbox_ss	(SSGET
			       '((-4 . "<AND")
				 (0 . "INSERT")
				 (2 . "HDBOX")
				 (67 . 1)
				 (-4 . "AND>")
				)
			) ;_ end of ssget
		  as_67	1
	    ) ;_ end of setq
	    (SETQ hdbox_ss	(SSGET "x"
			       '((-4 . "<AND")
				 (0 . "INSERT")
				 (2 . "HDBOX")
				 (67 . 1)
				 (-4 . "AND>")
				)
			) ;_ end of ssget
		  as_67	1
	    ) ;_ end of setq
	  ) ;_ end of if
	  (IF (EQ one_all "Select")
	    (SETQ txdim_ss	(SSGET
			       '((-4 . "<AND")
				 (-4 . "<OR")
				 (0 . "TEXT")
				 (0 . "DIMENSION")
				 (-4 . "OR>")
				 (67 . 1)
				 (-4 . "AND>")
				)
			) ;_ end of ssget
		  as_67	1
	    ) ;_ end of setq
	    (SETQ txdim_ss	(SSGET "x"
			       '((-4 . "<AND")
				 (-4 . "<OR")
				 (0 . "TEXT")
				 (0 . "DIMENSION")
				 (-4 . "OR>")
				 (67 . 1)
				 (-4 . "AND>")
				)
			) ;_ end of ssget
		  as_67	1
	    ) ;_ end of setq
	  ) ;_ end of if
          (vla-put-MSpace (vla-get-Activedocument (vlax-get-Acad-Object)) :vlax-false)
;;;	  (COMMAND "_.pspace")
	 )
       ) ;_ end of cond
       (IF (EQ mp_space "Paper")
	 (PROGN
           (COMMAND "_.draworder" hdbox_ss "" "f")
           (COMMAND "_.draworder" txdim_ss "" "f")
           (COMMAND "_.move" txdim_ss "" "0,0" "" "")
	 )
       )
       (IF (AND (= (GETVAR "tilemode") 0) (= curvpn 1))
         (vla-put-MSpace (vla-get-Activedocument (vlax-get-Acad-Object)) :vlax-false)
;;;	 (COMMAND "._pspace")
       ) ;_ end of if
       (PRINC wrd1)
       (PRINC wrd2)
       (PRINC wrd3)
       (PRINC wrd2)
       (PRINC wrd4b)
       (PRINC wrd2)
       (PRINC wrd5)
       (PRINC wrd2)
       (PRINC wrd6)
       (PRINC wrd6a)
       (PRINC wrd7)
       (PRINC wrd4)
       (PRINC wrd10)
       (PRINC wrd2)
       (PRINC wrd11)
       (PRINC wrd2)
       (PRINC wrd12)
       (PRINC wrd2)
       (PRINC wrd8)
       (PRINC wrd2)
       (PRINC wrd9)
       (PRINC wrd6a)
       (IF prehdtext_ss
         (COMMAND ".select" prehdtext_ss "")
       )
       )
	 (PROGN
	   (IF (NOT dwgfound)
	     (PROGN (PRINC "\nRequired file HDBOX.DWG not found! ")(PRINC))
	   )
	   (IF (NOT bmpfound)
	     (PROGN (PRINC "\nRequired file 1X1.BMP not found! ")(PRINC))
	   )
	   (IF (AND dwgfound bmpfound)
     	     (SETQ bmpfound NIL dwgfound NIL)
	     (PROGN (PRINC "\nFunction cancelled! ")(PRINC))
	   )
	 )
	 )
     ) ;_ end of progn
  ) ;_ end of if
  (IF (EQ (BOOLE 1 (GETVAR "CMDACTIVE") 4)4)
    (COMMAND "'RESUME")
  )
  (PRINC)
) ;_ end of defun
(DEFUN c:hdspace ()
  (SETQ	sp_size
	 (ureal
	   1
	   ""
	   "HDTEXT spacing for numeric text (fraction of text height, normal=0.45):"
	   (IF sp_size
	     sp_size
	     0.45
	   ) ;_ end of if
	 ) ;_ end of ureal
  ) ;_ end of setq
) ;_ end of defun
(DEFUN c:hdmatch ()
  (SETQ	hd_wcstr
	 (ustr 0 "Wildcard to match for special spacing" "" T)
	hd_size
	 (ureal
	   1
	   ""
	   "HDTEXT spacing for all matched text (fraction of text height, normal=0.45):"
	   (IF hd_size
	     hd_size
	     0.45
	   ) ;_ end of if
	 ) ;_ end of ureal
  ) ;_ end of setq
) ;_ end of defun
(defun c:ehdt ()
       (SETQ oldss (SSGET "X"
			  '((-4 . "<and")
			    (-4 . "<or")
			      (8 . "*DIMS-HIDE")
			      (8 . "*TEXT-HIDE")
			      (8 . "*NPLTHS")
			      (8 . "*NPLT*HS")
			    (-4 . "or>")
			    (-4 . "<not")
			      (8 . "*|*")
			    (-4 . "not>")
			    (-4 . "<or")
			      (0 . "3DFACE")
			      (-4 . "<and")
			        (0 . "INSERT")
			        (2 . "HDBOX")
			      (-4 . "and>")
			    (-4 . "or>")
			    (-4 . "and>")
			   )
		   ) ;_ end of ssget
       ) ;_ end of setq
       (IF oldss
	 (COMMAND ".erase" oldss "")
       ) ;_ end of if
  (princ)
)
(setq c:enplths c:ehdt)
(PRINC
  "\nType \"HDSPACE\" to set spacing of 3DFace edges around numeric text. (normal=0.45)"
) ;_ end of PRINC
(PRINC
  "\nType \"HDMATCH\" to set spacing of 3DFace edges around wildcard matched text. (normal=0.45)"
) ;_ end of PRINC
(PRINC)
(DEFUN c:hdupd ()
  (SETQ oldtilemode (GETVAR "tilemode"))
  (SETQ cvport_no (GETVAR "cvport"))
  (SETQ oldcmdecho (GETVAR "cmdecho"))
  (SETVAR "cmdecho" 0)
  (SETQ mp_space "Paper")
  (IF (NOT (EQ (SETQ cvport_no (GETVAR "cvport")) 1))
    (vla-put-MSpace (vla-get-Activedocument (vlax-get-Acad-Object)) :vlax-false)
;;;    (COMMAND "_.pspace")
  ) ;_ end of IF
  (SETQ	hdbox_ss (SSGET	"x"
			'((-4 . "<AND")
			  (0 . "INSERT")
			  (2 . "HDBOX")
			  (8 . "~*RAIL?HAND-HIDE")
			  (67 . 1)
			  (-4 . "AND>")
			 )
		 ) ;_ end of ssget
  ) ;_ end of setq
  (SETQ hdcirc_ss (SSGET "x"
			 '((8 . "*RAIL?HAND-HIDE"))
	          )
  )
  (SETQ hrails_ss (SSGET "X"
			 '((8 . "*RAIL?HAND"))
	          )
  )
  (SETQ	txdim_ss (SSGET	"x"
			'((-4 . "<AND")
			  (-4 . "<OR")
			  (0 . "TEXT")
			  (0 . "DIMENSION")
			  (2 . "*TTBAT")
			  (2 . "GTB????#")
			  (8 . "*NOHIDE*")
			  (8 . "*NHID*")
			  (-4 . "OR>")
			  (67 . 1)
			  (-4 . "AND>")
			 )
		 ) ;_ end of ssget
  ) ;_ end of setq
  (IF (AND hrails_ss hdcirc_ss)
    (PROGN
      (COMMAND "_.draworder" hdcirc_ss "" "f")
      (COMMAND "_.draworder" hrails_ss "" "f")
      (COMMAND "_.move" hdcirc_ss "" "0,0" "")
      (COMMAND "_.move" hrails_ss "" "0,0" "")
    )
  )
  (IF (AND hdbox_ss txdim_ss)
    (PROGN
      (COMMAND "_.draworder" hdbox_ss "" "f")
      (COMMAND "_.draworder" txdim_ss "" "f")
      (COMMAND "_.move" hdbox_ss "" "0,0" "")
      (COMMAND "_.move" txdim_ss "" "0,0" "")
    ) ;_ end of PROGN
    (COND
      ((AND(NOT hdbox_ss)(NOT txdim_ss))
        (PRINC "\nNo text, dimensions or hiding objects found! ")
        (PRINC))
      ((NOT hdbox_ss)
        (PRINC "\nNo hiding objects found! ")
        (PRINC))
      ((NOT txdim_ss)
        (PRINC "\nNo text or dimensions found! ")
        (PRINC))
    )
  )
  (IF (EQ oldtilemode 1)
    (SETVAR "tilemode" oldtilemode)
    (IF (NOT (EQ cvport_no 1))
      (vla-put-MSpace (vla-get-Activedocument (vlax-get-Acad-Object)) :vlax-true)
;;;      (COMMAND "_.mspace")
    )
  ) ;_ end of if
  (SETVAR "cmdecho" oldcmdecho)
) ;_ end of defun


 ;|«Visual LISP© Format Options» (72 2 40 2 T "end of " 60 9 2 0 0 T T nil T)
 ***Don't add text below the comment!***|;
