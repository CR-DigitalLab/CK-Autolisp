;;;Place "hiding" objects over each text string. (on layer ?-NPLT?????HS).
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
;;;	Edited:		1-29-04
;;;
;;;	disabled creation of 3Dfaces - now makes HDBOX inserts only.
;;;	added automatic management of UCS.
;;;
(DEFUN c:ddhtext (/	 ss	sslen  count  oldss  delold ntz
		  tname	 tent	tp1    tang   tbang  tp2    bxp1
		  bxp2	 bxp3	bxp4
		 )
  (PROGN
    (SETQ oldtilemode (GETVAR "tilemode"))
    (SETQ oldregenmode (GETVAR "regenmode"))
    (SETQ oldosmode (GETVAR "osmode"))
    (SETQ oldexpert (GETVAR "expert"))
    (IF gvpno NIL (LOAD "gvpno" "\nFile GVPNO.LSP not loaded! "))
    (IF gvpno
      (PROGN
	(gvpno)
	(SETQ oldcvport viewno)is
      )
      (SETQ oldcvport NIL)
    )
    (SETVAR "OSMODE" 0)
    (SETVAR "REGENMODE" 0)
    (SETVAR "EXPERT" 5)
    (IF	ureal
      nil
      (LOAD "uutils" "\nFile UUTILS.LSP not loaded! ")
    ) ;_ end of IF
    (IF	browser_help
      NIL
      (LOAD "browser_help" "\nFile BROWSER_HELP not loaded!")
    ) ;_ end of IF
    (IF	dimscl
      NIL
      (LOAD "dimscl" "\nFile DIMSCL.LSP not loaded! ")
    ) ;_ end of IF
    (SETQ ddhtext_dlg# (LOAD_DIALOG "ddhtext"))
    (SETQ newdlg_hdtext
	   (NEW_DIALOG
	     "ddhtext"
	     ddhtext_dlg#
	     (IF defact_ddhtext
	       defact_ddhtext
	       ""
	     ) ;_ end of IF
	     (IF ddhtext_loc
	       ddhtext_loc
	       '(-1 -1)
	     ) ;_ end of IF
	   ) ;_ end of NEW_DIALOG
    ) ;_ end of SETQ
    (IF	space_opt
      (SET_TILE "space_opt" space_opt)
      (SET_TILE "space_opt" "paper_space")
    ) ;_ end of IF
    (IF	select_opt
      (SET_TILE "select_opt" select_opt)
      (SET_TILE "select_opt" "select_all")
    ) ;_ end of IF
    (IF	custom_margin
      (PROGN
	(SET_TILE "custom_margin" custom_margin)
	(IF (EQ custom_margin "0")
	  (PROGN
	    (MODE_TILE "margin_width" 1)
	    (MODE_TILE "x_text" 1)
	    (SET_TILE "margin_width" "0.35")
	  ) ;_ end of PROGN
	  (PROGN
	    (MODE_TILE "margin_width" 0)
	    (MODE_TILE "x_text" 0)
	    (IF	margin_width
	      (SET_TILE "margin_width" margin_width)
	      (SET_TILE "margin_width" "0.35")
	    ) ;_ end of IF
	  ) ;_ end of PROGN
	) ;_ end of IF
      ) ;_ end of PROGN
      (PROGN
	(MODE_TILE "margin_width" 1)
	(MODE_TILE "x_text" 1)
	(SET_TILE "margin_width" "0.35")
      ) ;_ end of PROGN
    ) ;_ end of IF
    (IF	apply_opt
      (SET_TILE "apply_opt" apply_opt)
      (SET_TILE "apply_opt" "apply_both")
    ) ;_ end of IF
    (IF	existhd_opt
      (SET_TILE "existhd_opt" existhd_opt)
      (PROGN
	(SETQ existhd_opt "existhd_erase")
	(SET_TILE "existhd_opt" existhd_opt)
      ) ;_ end of PROGN
    ) ;_ end of IF
    (ACTION_TILE "space_opt" "(setq space_opt $value)")
    (ACTION_TILE
      "paper_space"
      "(setq space_opt (get_tile\"space_opt\"))"
    ) ;_ end of ACTION_TILE
    (ACTION_TILE
      "model_space"
      "(setq space_opt (get_tile\"space_opt\"))"
    ) ;_ end of ACTION_TILE
    (ACTION_TILE "select_opt" "(setq select_opt $value)")
    (ACTION_TILE
      "custom_margin"
      "(setq custom_margin $value)(set_margin)"
    ) ;_ end of ACTION_TILE
    (ACTION_TILE "margin_width" "(setq margin_width $value)")
    (ACTION_TILE "apply_opt" "(setq apply_opt $value)")
    (ACTION_TILE
      "apply_text"
      "(setq apply_opt (get_tile\"apply_opt\"))"
    ) ;_ end of ACTION_TILE
    (ACTION_TILE
      "apply_dims"
      "(setq apply_opt (get_tile\"apply_opt\"))"
    ) ;_ end of ACTION_TILE
    (ACTION_TILE
      "apply_both"
      "(setq apply_opt (get_tile\"apply_opt\"))"
    ) ;_ end of ACTION_TILE
    (ACTION_TILE "existhd_opt" "(setq existhd_opt $value)")
    (ACTION_TILE
      "existhd_erase"
      "(setq existhd_opt (get_tile\"existhd_opt\"))"
    ) ;_ end of ACTION_TILE
    (ACTION_TILE
      "existhd_keep"
      "(setq existhd_opt (get_tile\"existhd_opt\"))"
    ) ;_ end of ACTION_TILE
    (ACTION_TILE
      "accept"
      "(hdtext_values)(setq ddhtext_loc(done_dialog 1))"
    ) ;_ end of ACTION_TILE
    (ACTION_TILE "cancel" "(setq ddhtext_loc(done_dialog 0))")
    (ACTION_TILE "help" "(browser_help \"ddhtext\")")
    (SETQ exit_no (START_DIALOG))
    (IF	(EQ exit_no 1)
      (hdtext)
      (PROGN
;;;      (princ exit_no)
	(PRINC "\nFunction cancelled, nothing to do! ")
      ) ;_ end of progn
    ) ;_ end of IF
    (UNLOAD_DIALOG ddhtext_dlg#)
    (SETVAR "REGENMODE" oldregenmode)
    (IF vpset NIL
      (LOAD "vpset" "\nFile VPSET.LSP not loaded! ")
    )
    (IF (AND oldcvport vpset)
      (vpset oldcvport)
    )
    (SETVAR "EXPERT" oldexpert)
    (SETVAR "OSMODE" oldosmode)
    (PRINC)
  ) ;_ end of PROGN
) ;_ end of DEFUN
;;;*********************************************************************
(DEFUN set_margin ()
  (MODE_TILE "margin_width" (ABS (1- (READ custom_margin))))
  (MODE_TILE "x_text" (ABS (1- (READ custom_margin))))
  (IF (EQ custom_margin "0")
    (PROGN
      (SETQ margin_width "0.35")
      (SET_TILE "margin_width" margin_width)
    ) ;_ end of progn
  ) ;_ end of if
) ;_ end of defun
;;;*********************************************************************
(DEFUN hdtext_values ()
  (SETQ space_opt (GET_TILE "space_opt"))
  (SETQ select_opt (GET_TILE "select_opt"))
  (SETQ custom_margin (GET_TILE "custom_margin"))
  (SETQ margin_width (GET_TILE "margin_width"))
  (SETQ apply_opt (GET_TILE "apply_opt"))
  (SETQ existhd_opt (GET_TILE "existhd_opt"))
) ;_ end of defun
;;;*********************************************************************
(DEFUN hdtext ( / prehdtext_ss ss hdbox_ss txdim_ss oldss hddim_ss hdtxt_ss hddimarea_ss hdcirc_ss hrails_ss prtee_ss txt_ss bubs_ss dim_ss)
  (SETVAR "cmdecho" 0)
;;;  (PRINC "\nmargin_width=")
;;;  (PRINC margin_width)
;;;  (PRINC)
  (IF (AND
	margin_width
	(NOT (EQ margin_width "0.35"))
	(OR
	  (EQ (TYPE (READ margin_width)) 'REAL)
	  (EQ (TYPE (READ margin_width)) 'INT)
	) ;_ end of OR
      ) ;_ end of and
    (SETQ sp_size (READ margin_width))
    (SETQ sp_size 0.35)
  ) ;_ end of IF
;;;  (princ "\nsp_size=")
;;;  (princ sp_size)
;;;  (princ)
  (IF (AND
	margin_width
	(NOT (EQ margin_width "0.35"))
	(OR
	  (EQ (TYPE (READ margin_width)) 'REAL)
	  (EQ (TYPE (READ margin_width)) 'INT)
	) ;_ end of OR
      ) ;_ end of and
    (SETQ hd_size (READ margin_width))
    (SETQ hd_size 0.35)
  ) ;_ end of IF
;;;  (princ "\nhd_size=")
;;;  (princ hd_size)
;;;  (princ)
  (IF hd_wcstr
    NIL
    (SETQ hd_wcstr "")
  ) ;_ end of IF
  (IF (/= "BYLAYER" (GETVAR "cecolor"))
    (SETVAR "CECOLOR" "BYLAYER")
  ) ;_ end of IF
  (IF ukword
    nil
    (LOAD "uutils" "\nFile UUTILS.LSP not loaded! ")
  ) ;_ end of if
  (SETQ	cr    (LIST "w"	  "o"	"r"   "y"   "d"	  "u"	"e"   "t"
		    "h"	  "f"	"a"   "g"   "n"	  "c"	"i"   "p"
		    "r"	  "s"	"j"   "l"   "v"	  "b"
		   ) ;_ end of LIST
 ;_ end of LIST
 ;_ end of LIST
 ;_ end of LIST
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
       (IF (EQ space_opt "model_space")
	 (SETQ mp_space "Model")
	 (SETQ mp_space "Paper")
       ) ;_ end of if
       (IF (EQ select_opt "select_all")
	 (SETQ one_all "All")
	 (SETQ one_all "Select")
       ) ;_ end of IF
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
	    (COMMAND "_.mspace")
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
;;;	  (SETQ oldtilemode (GETVAR "tilemode"))
	  (IF (NOT (EQ (SETQ cvport_no (GETVAR "cvport")) 1))
	    (IF	(EQ (GETVAR "tilemode") 1)
	      (PROGN
		(SETVAR "tilemode" 0)
		(COMMAND "_.pspace")
	      ) ;_ end of PROGN
	      (COMMAND "_.pspace")
	    ) ;_ end of IF
	  ) ;_ end of IF
	 )
       ) ;_ end of cond
       (IF (TBLOBJNAME "block" "hdbox")
	 nil
	 (PROGN
	   (COMMAND "-insert" "hdbox")
	   (COMMAND)
	 ) ;_ end of progn
       ) ;_ end of IF
       (IF (OR (AND (SETQ dwgfound (FINDFILE "hdbox.dwg"))
		    (SETQ bmpfound (FINDFILE "1x1.bmp"))
		    (EQ mp_space "Paper")
	       ) ;_ end of and
	       (EQ mp_space "Model")
	   ) ;_ end of or
	 (PROGN
	   (IF (AND
		 (EQUAL (GETVAR "UCSORG") (LIST 0.0 0.0 0.0) 0.0001)
		 (EQUAL (GETVAR "UCSXDIR") (LIST 1.0 0.0 0.0) 0.0001)
		 (EQUAL (GETVAR "UCSYDIR") (LIST 0.0 1.0 0.0) 0.0001)
	       ) ;_ end of AND
	     (PROGN
	       (SETQ ddht_ucsname NIL)
;;;        (PRINC "\nUCSNAME=")
;;;	(princ (GETVAR "ucsname"))
;;;        (PRINC "\nUCSORG=")
;;;	(princ (GETVAR "ucsorg"))
;;;        (PRINC "\nUCSXDIR=")
;;;	(princ (GETVAR "ucsxdir"))
;;;        (PRINC "\nUCSYDIR=")
;;;	(princ (GETVAR "ucsydir"))
	     ) ;_ end of PROGN
	     (PROGN
	       (IF gvpno
		 NIL
		 (LOAD "gvpno" "\nFile GVPNO.LSP not loaded! ")
	       ) ;_ end of IF
	       (gvpno)
	       (IF viewno
		 (PROGN
;;;	  (PRINC "\nVIEWNO=")
;;;	  (princ viewno)
;;;	  (princ)
		   (SETQ ddht_vpno viewno)
		 ) ;_ end of PROGN
;;;	(PROGN
;;;	  (PRINC "\nDID NOT SET VIEWNO! ")
;;;	  (princ)
;;;	)
	       ) ;_ end of IF
	       (IF (EQUAL (GETVAR "UCSNAME") "")
		 (SETQ ddht_ucsname "DDHT-TEMP-UCS")
		 (SETQ ddht_ucsname (GETVAR "UCSNAME"))
	       ) ;_ end of IF
	       (COMMAND ".UCS" "SAVE" ddht_ucsname)
	       (COMMAND ".UCS" "WORLD")
	     ) ;_ end of PROGN
	   ) ;_ end of IF
	   (c:ehdt)
	   (IF (AND (OR (EQ mp_space "Model") (EQ mp_space "Paper"))
		    ss
		    (OR	(EQ apply_opt "apply_both")
			(EQ apply_opt "apply_text")
		    ) ;_ end of OR
	       ) ;_ end of AND
	     (PROGN
	       (dimscl)
	       (SETQ sslen (SSLENGTH ss)
		     count 0
		     ntz   (* dimsc 1000)
		     colr  "1"
	       ) ;_ end of setq
	       (WHILE
		 (NOT (EQ count sslen))
		  (IF (= (CDR (ASSOC 71 tent)) 2)
		    (SETQ ntz (- 0 (ABS ntz)))
		    (SETQ ntz (ABS ntz))
		  ) ;_ end of if
		  (SETQ	tname (SSNAME ss count)
			10a   (ASSOC 10 (ENTGET tname))
			11a   (ASSOC 11 (ENTGET tname))
			10b   (LIST (CAR 10a) (CADR 10a) (CADDR 10a) 0.0)
					;(CADDDR 10a)
			11b   (LIST (CAR 11a) (CADR 11a) (CADDR 11a) 0.0)
					;(CADDDR 11a)
			tname (ENTGET tname)
			nohide (ENTGET (tblobjname "layer" (cdr(assoc 8 tname))))
			tname (SUBST 10b 10a tname)
			tname (SUBST 11b 11a tname)
		  ) ;_ end of setq
		  (IF (AND (ASSOC 12 tname) (ASSOC 13 tname))
		    (SETQ 12a	(ASSOC 12 tname)
			  13a	(ASSOC 13 tname)
			  12b	(LIST (CAR 12a) (CADR 12a) (CADDR 12a) 0.0)
					;(CADDDR 12a)
			  13b	(LIST (CAR 13a) (CADR 13a) (CADDR 13a) 0.0)
					;(CADDDR 13a)
			  tname	(SUBST 12b 12a tname)
			  tname	(SUBST 13b 13a tname)
		    ) ;_ end of setq
		  ) ;_ end of if
		  (IF (OR (> (CDR(ASSOC 70 nohide)) 0)(< (CDR(ASSOC 62 nohide)) 0))
		    NIL
		    (ENTMOD tname)
		  )
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
		 (SETQ tname  (SSNAME ss count)
		       tent   (ENTGET tname)
		       tenthk (ASSOC 39 tent)
		       tval   (CDR (ASSOC 1 tent))
		       tbox   (TEXTBOX tent)
		       nohide (ENTGET (tblobjname "layer" (cdr(assoc 8 tent))))
		 ) ;_ end of SETQ
		 (SETQ tbox (LIST
			      (LIST (CAAR tbox) 0.0 0.0)
			      (LIST (CAADR tbox) (CDR (ASSOC 40 tent)) 0.0)
			    ) ;_ end of LIST
		       txht (CDR (ASSOC 40 tent))
		       tdis (- (CAR (NTH 1 tbox)) (CAR (NTH 0 tbox)))
		       tp1  (POLAR
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
		   (IF (AND (OR	(EQUAL (TYPE (READ tval)) 'INT)
				(EQUAL (TYPE (READ tval)) 'REAL)
			    ) ;_ end of OR
			    (NOT (WCMATCH tval "*@*"))
		       ) ;_ end of AND
		     (SETQ txtsp_fact (/ 1.0 sp_size))
					; TXTSP_FACT was hard coded at 2.10
		     (SETQ txtsp_fact (/ 1.0 0.35))
		   ) ;_ end of IF
		   (SETQ txtsp_fact (/ 1.0 0.35))
		 ) ;_ end of IF
		 (COND
		   ((AND
		      (NOT (WCMATCH tval (STRCAT (CHR 34) "*")))
		      (NOT (WCMATCH tval (STRCAT (CHR 40) "*")))
		      (NOT (WCMATCH tval (STRCAT (CHR 41) "*")))
		      (NOT (WCMATCH tval (STRCAT (CHR 46) "*")))
		    ) ;_ end of AND
		    (IF	(AND
			  (OR (EQUAL (TYPE (READ tval)) 'INT)
			      (EQUAL (TYPE (READ tval)) 'REAL)
			  ) ;_ end of OR
			  (NOT (WCMATCH tval "*@*"))
			) ;_ end of AND
		      (SETQ hd_sp sp_size)
;;;		  (IF (WCMATCH tval hd_wcstr)
		      (SETQ hd_sp hd_size)
;;;		    (SETQ hd_sp 0.35)
;;;		  ) ;_ end of IF
		    ) ;_ end of IF
		   )
		   (T
		    (IF	sp_size
		      (SETQ hd_sp sp_size)
		      (IF hd_size
			(SETQ hd_sp hd_size)
			(SETQ hd_sp 0.35)
		      ) ;_ end of IF
		    ) ;_ end of IF
		   )
		 ) ;_ end of COND
		 (IF (< (NTH 1 (NTH 1 tbox)) txht)
		   (SETQ txht (NTH 1 (NTH 1 tbox)))
		 ) ;_ end of IF
		 (SETQ tang  (CDR (ASSOC 50 tent))
		       tlayr (CDR (ASSOC 8 tent))
		       tp2   (POLAR
			       (POLAR tp1 tang tdis)
			       (+ tang (* PI 0.5))
			       (- (CADR (NTH 1 tbox)) (CADR (NTH 0 tbox)))
			     ) ;_ end of POLAR
		 ) ;_ end of setq
		 (SETQ bxp1 (POLAR
			      (POLAR tp1;Set 3DFace points for normal text
				     (- tang (* PI 0.5))
				     (* txht hd_sp)
			      ) ;_ end of POLAR
			      (- tang PI)
			      (* txht hd_sp)
			    ) ;_ end of polar
		       bxp2 (POLAR bxp1
				   (+ tang (* PI 0.50))
				   (+ (* 2.00 txht hd_sp)
				      (CADR (NTH 1 tbox))
				      (- (CADR (NTH 0 tbox)))
				   ) ;_ end of +
			    ) ;_ end of polar
		       bxp4 (POLAR
			      (POLAR tp2
				     (+ tang (* PI 0.5))
				     (* txht hd_sp)
			      ) ;_ end of polar
			      tang
			      (* txht hd_sp)
			    ) ;_ end of POLAR
		       bxp3 (POLAR bxp4
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
		 (SETQ bxp1 (TRANS (LIST (CAR bxp1) (CADR bxp1) ntz) 0 1)
		       bxp2 (TRANS (LIST (CAR bxp2) (CADR bxp2) ntz) 0 1)
		       bxp3 (TRANS (LIST (CAR bxp3) (CADR bxp3) ntz) 0 1)
		       bxp4 (TRANS (LIST (CAR bxp4) (CADR bxp4) ntz) 0 1)
		 ) ;_ end of setq
		 (IF (>= 11 (STRLEN tlayr))
		   (SETQ modf (SUBSTR tlayr 8 4))
		   (SETQ modf "NOTE")
		 ) ;_ end of if
		 (IF (>= (STRLEN tlayr) 6)
		   (SETQ hsvno (SUBSTR tlayr 3 4))
		   (SETQ hsvno "NOTE")
		 ) ;_ end of if
		 (SETQ tlayr (STRCAT "G-"
				     hsvno
;;;				     (IF (EQ mp_space "Paper")
				     "7TEXT-HIDE"
;;;				       "DNPLT"
;;;				     ) ;_ end of IF
				     (IF (EQ mp_space "Paper")
				       ""
				       (IF (> (STRLEN tlayr) 11)
					 (SUBSTR tlayr 12)
					 ""
				       ) ;_ end of if
				     ) ;_ end of IF
;;;				     (IF (EQ mp_space "Paper")
				     ""
;;;				       "HS"
;;;				     ) ;_ end of IF
			     ) ;_ end of strcat
		 ) ;_ end of setq
		  (IF (OR (> (CDR(ASSOC 70 nohide)) 0)(< (CDR(ASSOC 62 nohide)) 0))
		    NIL
		 (IF (AND (> tdis 0)
			  (OR (NOT tenthk) (/= (CDR tenthk) 1.0))
		     ) ;_ end of AND
		   (PROGN
		     (SETQ box_angle   (ANGLE bxp1 bxp3)
			   box_x_scale (DISTANCE bxp1 bxp3)
			   box_y_scale (DISTANCE bxp1 bxp2)
		     ) ;_ end of SETQ
		     (IF T		;(EQ mp_space "Paper")
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
				) ;_ end of LIST
			 ) ;_ end of SETQ
			 (ENTMAKE hdboxlst)
		       ) ;_ end of PROGN
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
		       ) ;_ end of PROGN
		     ) ;_ end of IF
		   ) ;_ end of progn
		 ) ;_ end of if
		    )
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
	     (PROGN (IF	fthk
		      nil
		      (SETQ fthk 5.0)
		    ) ;_ end of IF
		    (pttxt "HDBOX_" "bxp" 1 5)
	     ) ;_ end of PROGN
	   ) ;_ end of if
;;;Use the above to graphically identify and debug the defined points.

	   (COND
	     ((EQ apply_opt "apply_both")
	      (SETQ hide_dims "Yes")
	     )
	     ((EQ apply_opt "apply_dims")
	      (SETQ hide_dims "Yes")
	     )
	     ((EQ apply_opt "apply_text")
	      (SETQ hide_dims "No")
	     )
	   ) ;_ end of COND
	   (IF (EQ hide_dims "Yes")
	     (PROGN
	       (IF c:dims
		 nil
		 (LOAD "dims" "\nFile DIMS.LSP not loaded! ")
	       ) ;_ end of if
	       (c:dims)
	     ) ;_ end of PROGN
	   ) ;_ end of IF



	   (COND
	     ((EQ mp_space "Model")
	      (IF (EQ one_all "Select")
		(SETQ hdbox_ss (SSGET '((-4 . "<AND")
					(0 . "INSERT")
					(2 . "HDBOX")
					(8 . "~*AREA*")
					(8 . "~*@@##P-HIDE")
					(8 . "~*@@##P-HIDE")
					(-4 . "<NOT")
					(67 . 1)
					(-4 . "NOT>")
					(-4 . "AND>")
				       )
			       ) ;_ end of ssget
		      as_67    0
		) ;_ end of setq
		(SETQ hdbox_ss (SSGET "x"
				      '((-4 . "<AND")
					(0 . "INSERT")
					(2 . "HDBOX")
					(8 . "~*AREA*")
					(8 . "~*@@##PHIDE")
					(8 . "~*@@##P-HIDE")
					(-4 . "<NOT")
					(67 . 1)
					(-4 . "NOT>")
					(-4 . "AND>")
				       )
			       ) ;_ end of ssget
		      as_67    0
		) ;_ end of setq
	      ) ;_ end of if
	      (IF (EQ one_all "Select")
		(SETQ txdim_ss (SSGET
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
		      as_67    0
		) ;_ end of setq
		(SETQ txdim_ss (SSGET "x"
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
		      as_67    0
		) ;_ end of setq
	      ) ;_ end of if
	      (IF (EQ (GETVAR "tilemode") 0)
		(COMMAND "_.mspace")
	      ) ;_ end of if
	     )
	     ((EQ mp_space "Paper")
	      (IF (EQ one_all "Select")
		(SETQ hdbox_ss (SSGET
				 '((-4 . "<AND")
				   (0 . "INSERT")
				   (2 . "HDBOX")
				   (8 . "~*AREA*")
				   (8 . "~*@@##PHIDE")
				   (8 . "~*@@##P-HIDE")
				   (67 . 1)
				   (-4 . "AND>")
				  )
			       ) ;_ end of ssget
		      as_67    1
		) ;_ end of setq
		(SETQ hdbox_ss (SSGET "x"
				      '((-4 . "<AND")
					(0 . "INSERT")
					(2 . "HDBOX")
					(8 . "~*AREA*")
					(8 . "~*@@##PHIDE")
					(8 . "~*@@##P-HIDE")
					(67 . 1)
					(-4 . "AND>")
				       )
			       ) ;_ end of ssget
		      as_67    1
		) ;_ end of setq
	      ) ;_ end of if
	      (IF (EQ one_all "Select")
		(SETQ txdim_ss (SSGET
				 '((-4 . "<AND")
				   (-4 . "<OR")
				   (0 . "TEXT")
				   (0 . "DIMENSION")
				   (-4 . "OR>")
				   (67 . 1)
				   (-4 . "AND>")
				  )
			       ) ;_ end of ssget
		      as_67    1
		) ;_ end of setq
		(SETQ txdim_ss (SSGET "x"
				      '((-4 . "<AND")
					(-4 . "<OR")
					(0 . "TEXT")
					(0 . "DIMENSION")
					(-4 . "OR>")
					(67 . 1)
					(-4 . "AND>")
				       )
			       ) ;_ end of ssget
		      as_67    1
		) ;_ end of setq
	      ) ;_ end of if
	      (COMMAND "_.pspace")
	     )
	   ) ;_ end of cond
	   (IF (AND hdbox_ss txdim_ss)	;(EQ mp_space "Paper")
	     (PROGN
	       (C:HDUPD)
;;;	       (COMMAND "_.draworder" hdbox_ss "" "f")
;;;	       (COMMAND "_.draworder" txdim_ss "" "f")
;;;	       (COMMAND "_.move" hdbox_ss txdim_ss "" "0,0" "")
	     ) ;_ end of PROGN
	     (COND
	       ((EQ mp_space "Model") (PRINC))
	       ((AND (NOT hdbox_ss) (NOT txdim_ss))
		(PRINC "\nNo text, dimensions or hiding objects found! ")
		(PRINC)
	       )
	       ((NOT hdbox_ss)
		(PRINC "\nNo hiding objects found! ")
		(PRINC)
	       )
	       ((NOT txdim_ss)
		(PRINC "\nNo text or dimensions found! ")
		(PRINC)
	       )
	     ) ;_ end of COND
	   ) ;_ end of IF
	   (IF (AND ddht_vpno ddht_ucsname)
	     (PROGN
	       (IF vpset
		 NIL
		 (LOAD "vpset" "\nFile VPSET.LSP not loaded! ")
	       ) ;_ end of IF
	       (vpset ddht_vpno)
	       (COMMAND ".UCS" "RESTORE" ddht_ucsname)
	       (SETQ ddht_ucsname NIL)
	     ) ;_ end of progn
	   ) ;_ end of IF
	   (IF (EQ oldtilemode 1)
	     (SETVAR "tilemode" oldtilemode)
	     (IF (NOT (EQ (GETVAR "cvport") 1))
	       (COMMAND "_.pspace")
	     ) ;_ end of IF
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
	   ) ;_ end of IF
	 ) ;_ end of progn
	 (PROGN
	   (IF (NOT dwgfound)
	     (PROGN (PRINC "\nRequired file HDBOX.DWG not found! ")
		    (PRINC)
	     ) ;_ end of PROGN
	   ) ;_ end of IF
	   (IF (NOT bmpfound)
	     (PROGN (PRINC "\nRequired file 1X1.BMP not found! ")
		    (PRINC)
	     ) ;_ end of PROGN
	   ) ;_ end of IF
	   (IF (AND dwgfound bmpfound)
	     (SETQ bmpfound NIL
		   dwgfound NIL
	     ) ;_ end of SETQ
	     (PROGN (PRINC "\nFunction cancelled! ") (PRINC))
	   ) ;_ end of IF
	 ) ;_ end of PROGN
       ) ;_ end of if
     ) ;_ end of progn
  ) ;_ end of if
  (IF (EQ (BOOLE 1 (GETVAR "CMDACTIVE") 4) 4)
    (COMMAND "'RESUME")
  ) ;_ end of IF
  (PRINC)
) ;_ end of defun
;;;*********************************************************************
(DEFUN c:hdspace ()
  (SETQ	sp_size
	 (ureal
	   1
	   ""
	   "HDTEXT spacing for numeric text (fraction of text height, normal=0.35):"
	   (IF sp_size
	     sp_size
	     0.35
	   ) ;_ end of if
	 ) ;_ end of ureal
  ) ;_ end of setq
) ;_ end of defun
;;;*********************************************************************
(DEFUN c:hdmatch ()
  (SETQ	hd_wcstr
		 (ustr 0 "Wildcard to match for special spacing" "" T)
	hd_size
		 (ureal
		   1
		   ""
		   "HDTEXT spacing for all matched text (fraction of text height, normal=0.35):"
		   (IF hd_size
		     hd_size
		     0.35
		   ) ;_ end of if
		 ) ;_ end of ureal
  ) ;_ end of setq
) ;_ end of defun
;;;*********************************************************************
(DEFUN c:ehdt ()
  (IF (OR (NOT existhd_opt) (EQ existhd_opt "existhd_erase"))
    (PROGN
      (IF (EQ mp_space "Paper")
	(SETQ oldss (SSGET "X"
			   '((-4 . "<and")
			     (-4 . "<or")
			     (8 . "*DIMS-HIDE")
			     (8 . "*TEXT-HIDE")
			     (8 . "*TEXT-HIDE-*")
			     (-4 . "or>")
			     (-4 . "<not")
			     (8 . "*|*")
			     (-4 . "not>")
			     (0 . "INSERT")
			     (2 . "HDBOX")
			     (-4 . "and>")
			    )
		    ) ;_ end of ssget
	) ;_ end of setq
	(SETQ oldss (SSGET "X"
			   '((-4 . "<and")
			     (-4 . "<or")
			     (8 . "*NPLTHS")
			     (8 . "*NPLT*HS")
			     (8 . "*DIMS-HIDE")
			     (8 . "*TEXT-HIDE")
			     (8 . "*TEXT-HIDE-*")
			     (-4 . "or>")
			     (-4 . "<not")
			     (8 . "*|*")
			     (-4 . "not>")
			     (-4 . "<or")
			     (-4 . "<and")
			     (0 . "INSERT")
			     (2 . "HDBOX")
			     (-4 . "and>")
			     (0 . "3DFACE")
			     (-4 . "or>")
			     (-4 . "and>")
			    )
		    ) ;_ end of ssget
	) ;_ end of setq
      ) ;_ end of IF
      (IF oldss
	(COMMAND ".erase" oldss "")
      ) ;_ end of if
    ) ;_ end of PROGN
  ) ;_ end of IF
  (PRINC)
) ;_ end of defun
;;;*********************************************************************
;;;(SETQ c:enplths c:ehdt)
;;;(PRINC
;;;  "\nType \"HDSPACE\" to set spacing of 3DFace edges around numeric text. (normal=0.35)"
;;;) ;_ end of PRINC
;;;(PRINC
;;;  "\nType \"HDMATCH\" to set spacing of 3DFace edges around wildcard matched text. (normal=0.35)"
;;;) ;_ end of PRINC
;;;(PRINC)
;;;*********************************************************************
(DEFUN c:hdupd ()
  (SETQ oldcmdecho (GETVAR "cmdecho"))
  (SETQ oldtilemode (GETVAR "tilemode"))
  (SETVAR "cmdecho" 0)
  (IF (EQ mp_space "Paper")
    (IF	(NOT (EQ (SETQ cvport_no (GETVAR "cvport")) 1))
      (IF (EQ (GETVAR "tilemode") 1)
	(PROGN
	  (SETVAR "tilemode" 0)
	  (COMMAND "_.pspace")
	) ;_ end of PROGN
	(COMMAND "_.pspace")
      ) ;_ end of IF
    ) ;_ end of IF
  ) ;_ end of IF
  (getsets mp_space)
  (dodraworder)
  (IF (EQ oldtilemode 1)
    (SETVAR "tilemode" oldtilemode)
    (IF	(NOT (EQ cvport_no 1))
      (COMMAND "_.mspace")
    ) ;_ end of IF
  ) ;_ end of if
  (SETVAR "cmdecho" oldcmdecho)
  (PRINC)
  (PRINC)
) ;_ end of defun
(DEFUN ureal (bit kwd msg def / inp)
  (IF def
    (SETQ msg (STRCAT "\n"
		      msg
		      " <"
		      (IF (EQ (TYPE def) 'REAL)
			(RTOS def 2)
			(IF (EQ (TYPE def) 'INT)
			  (ITOA def)
			  def
			) ;_ end of if
		      ) ;_ end of if
		      ">: "
	      ) ;_ end of strcat
	  bit (* 2 (FIX (/ bit 2)))
    ) ;_ end of setq
    (SETQ msg (STRCAT "\n" msg ": "))
  )					;if
  (INITGET bit kwd)
  (SETQ inp (GETREAL msg))
  (IF inp
    inp
    def
  ) ;_ end of if
)					;defun
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
  inp
) ;_ end of defun
(DEFUN ukword (bit kwd msg def / inp)
  (IF (AND def (/= def ""))
    (SETQ msg (STRCAT "\n" msg " <" def ">: ")
	  bit (* 2 (FIX (/ bit 2)))
    )					;setq
  )					;if
  (INITGET bit kwd)
  (SETQ inp (GETKWORD msg))
  (IF inp
    inp
    def
  ) ;_ end of if
)					;defun
(DEFUN getsets (ddo_space /)
  (IF (EQ ddo_space "Paper")
    (SETQ ddo_asso67 0)
    (SETQ ddo_asso67 1)
  ) ;_ end of IF
  (SETQ	hddim_ss (SSGET	"x"
			(LIST
			  (CONS -4 "<AND")
			  (CONS 0 "INSERT")
			  (CONS 2 "HDBOX")
			  (CONS 8 "~*RAIL?HAND-HIDE")
			  (CONS 8 "*DIMS?HIDE*")
			  (CONS -4 "<not")
			  (CONS 67 ddo_asso67)
			  (CONS -4 "not>")
			  (CONS -4 "AND>")
			) ;_ end of LIST
		 ) ;_ end of ssget
  ) ;_ end of setq
  (SETQ	hdtxt_ss (SSGET	"x"
			(LIST
			  (CONS -4 "<AND")
			  (CONS 0 "INSERT")
			  (CONS -4 "<OR")
			  (CONS 2 "PR*")
			  (CONS 2 "HDBOX")
			  (CONS -4 "OR>")
			  (CONS 8 "~*RAIL?HAND-HIDE")
			  (CONS 8 "~*DIMS?HIDE")
			  (CONS 8 "~*AREA*")
			  (CONS 8 "~*@@##PHIDE")
			  (CONS 8 "~*@@##P-HIDE")
			  (CONS -4 "<not")
			  (CONS 67 ddo_asso67)
			  (CONS -4 "not>")
			  (CONS -4 "AND>")
			) ;_ end of LIST
		 ) ;_ end of ssget
  ) ;_ end of setq
  (SETQ	hddimarea_ss (SSGET	"x"
			(LIST
			  (CONS -4 "<AND")
			  (CONS 0 "INSERT")
			  (CONS 2 "HDBOX")
			  (CONS 8 "*DIMA-HIDE")
			  (CONS -4 "<not")
			  (CONS 67 ddo_asso67)
			  (CONS -4 "not>")
			  (CONS -4 "AND>")
			) ;_ end of LIST
		 ) ;_ end of ssget
  ) ;_ end of setq
  (SETQ	hdcirc_ss (SSGET "x"
			 (LIST
			   (CONS 8 "*RAIL?HAND-HIDE*")
			   (CONS -4 "<not")
			   (CONS 67 ddo_asso67)
			   (CONS -4 "not>")
			 ) ;_ end of LIST
		  ) ;_ end of SSGET
  ) ;_ end of SETQ
  (SETQ	hrails_ss (SSGET "X"
			 (LIST
			   (CONS 8 "*RAIL?HAND*")
			   (CONS -4 "<not")
			   (CONS 67 ddo_asso67)
			   (CONS -4 "not>")
			 ) ;_ end of LIST
		  ) ;_ end of SSGET
  ) ;_ end of SETQ
  (SETQ prtee_ss (SSGET "X" '((2 . "PRTEE"))))
  (IF prtee_ss
    (PROGN
      (SETQ prtpnts nil)
      (SETQ ell10lst nil)
      (SETQ prtcnt 0)
      (WHILE (< (1+ prtcnt) (SSLENGTH prtee_ss))
	(SETQ prtpnts (APPEND prtpnts (LIST (CDR(ASSOC 10(ENTGET(SSNAME prtee_ss prtcnt)))))))
	(SETQ prtcnt (1+ prtcnt))
      )
      (foreach n prtpnts (setq ell10lst (append ell10lst (list (cons 10 n)))))
      (setq ell10lst (append (list (cons -4 "<OR")) ell10lst (list (cons -4 "OR>"))))
    )
  )
  (SETQ	txt_ss (SSGET "x"
		      (APPEND
		      (LIST
			(CONS -4 "<AND")
			(CONS -4 "<OR")
			(CONS 0 "TEXT")
			(CONS 0 "LEADER")
			(CONS -4 "<AND")
			(CONS 0 "ELLIPSE")
		      )
		      ell10lst
		      (LIST
			(CONS -4 "AND>")
			(CONS 2 "*TTBAT")
			(CONS 2 "B1")
			(CONS 2 "GTB????#")
			(CONS 8 "*NOHIDE*")
			(CONS 8 "*NHID*")
			(CONS -4 "OR>")
			(CONS -4 "<not")
			(CONS 67 ddo_asso67)
			(CONS -4 "not>")
			(CONS -4 "AND>")
		      ) ;_ end of LIST
		      )
	       ) ;_ end of ssget
  ) ;_ end of setq
  (SETQ bubs_ss (SSGET "x"
		      (LIST
			(CONS -4 "<OR")
			(CONS 2 "B")
			(CONS 2 "B1")
			(CONS 2 "B_TAG")
			(CONS 2 "D_TAG")
			(CONS 2 "H_TAG")
			(CONS -4 "OR>")
		      )
		)
  )
  (SETQ	dim_ss (SSGET "x"
		      (LIST
			(CONS -4 "<AND")
			(CONS 0 "DIMENSION")
			(CONS -4 "<not")
			(CONS 67 ddo_asso67)
			(CONS -4 "not>")
			(CONS -4 "AND>")
		      ) ;_ end of LIST
	       ) ;_ end of ssget
  ) ;_ end of setq
) ;_ end of defun
(DEFUN dodraworder ()
  (IF (AND hrails_ss
	   hdcirc_ss
	   (> (SSLENGTH hrail_ss) 0)
	   (> (SSLENGTH hdcirc_ss) 0)
      ) ;_ end of AND
    (PROGN
      (COMMAND "_.draworder" hdcirc_ss "" "f")
      (COMMAND "_.draworder" hrails_ss "" "f")
      (COMMAND "_.move" hdcirc_ss "" "0,0" "")
      (COMMAND "_.move" hrails_ss "" "0,0" "")
    ) ;_ end of PROGN
  ) ;_ end of IF
  (IF (AND hddim_ss dim_ss)
    (IF (WCMATCH (STRCASE (GETVAR "DWGNAME")) "?????X##.DWG")
      (PROGN
	(COND
	  ((AND (>(SSLENGTH hddim_ss)0)(>(SSLENGTH hddimarea_ss)0))
            (COMMAND "_.COPY" hddim_ss hddimarea_ss "" "0,0" "" "")
	    (COMMAND "_.ERASE" hddim_ss hddimarea_ss ""))
	  ((>(SSLENGTH hddim_ss)0)
            (COMMAND "_.COPY" hddim_ss "" "0,0" "" "")
	    (COMMAND "_.ERASE" hddim_ss ""))
	  ((>(SSLENGTH hddimarea_ss)0)
            (COMMAND "_.COPY" hddimarea_ss "" "0,0" "" "")
	    (COMMAND "_.ERASE" hddimarea_ss ""))
	)
	(COND
	  ((>(SSLENGTH dim_ss)0)
            (COMMAND "_.COPY" dim_ss "" "0,0" "" "")
            (COMMAND "_.ERASE" dim_ss ""))
	)
      ) ;_ end of PROGN
      (PROGN
	(if hddimarea_ss
          (COMMAND "_.draworder" hddim_ss hddimarea_ss "" "f")
          (COMMAND "_.draworder" hddim_ss "" "f")
	)
        (COMMAND "_.draworder" dim_ss "" "f")
	(if hddimarea_ss
          (COMMAND "_.move" hddim_ss hddimarea_ss dim_ss "" "0,0" "")
          (COMMAND "_.move" hddim_ss dim_ss "" "0,0" "")
	)
      ) ;_ end of PROGN
    )
  ) ;_ end of IF
  (IF (AND hdtxt_ss txt_ss)
    (IF (WCMATCH (STRCASE (GETVAR "DWGNAME")) "?????X##.DWG")
      (PROGN
	(COND
	  ((AND(>(SSLENGTH hdtxt_ss)0)(>(SSLENGTH txt_ss)0))
            (COMMAND "_.COPY" hdtxt_ss "" "0,0" "" "")
            (COMMAND "_.COPY" txt_ss "" "0,0" "" "")
            (COMMAND "_.ERASE" hdtxt_ss txt_ss ""))
	  ((>(SSLENGTH hdtxt_ss)0)
            (COMMAND "_.COPY" hdtxt_ss "" "0,0" "" "")
            (COMMAND "_.ERASE" hdtxt_ss ""))
	  ((>(SSLENGTH txt_ss)0)
            (COMMAND "_.COPY" txt_ss "" "0,0" "" "")
            (COMMAND "_.ERASE" txt_ss ""))
	)
      ) ;_ end of PROGN
      (PROGN
        (COMMAND "_.draworder" hdtxt_ss "" "f")
        (COMMAND "_.draworder" txt_ss "" "f")
        (COMMAND "_.move" hdtxt_ss txt_ss "" "0,0" "")
      ) ;_ end of PROGN
    )
  ) ;_ end of IF
  (IF bubs_ss
    (IF (WCMATCH (STRCASE (GETVAR "DWGNAME")) "?????X##.DWG")
      (PROGN
	(COND
	  ((>(SSLENGTH bubs_ss)0)
            (COMMAND "_.COPY" bubs_ss "" "0,0" "" "")
            (COMMAND "_.ERASE" bubs_ss ""))
	)
      )
      (PROGN
        (COMMAND "_.draworder" bubs_ss "" "f")
        (COMMAND "_.move" bubs_ss "" "0,0" "")
      ) ;_ end of PROGN
    )
  )
  (IF (OR (AND (NOT dim_ss) (NOT txt_ss))
	  (AND (NOT hddim_ss) (NOT hdtxt_ss))
	  (NOT bubs_ss)
      ) ;_ end of OR
    (COND
      ((AND (NOT hddim_ss)
	    (NOT hdtxt_ss)
	    (NOT dim_ss)
	    (NOT txt_ss)
	    (NOT bubs_ss)
       ) ;_ end of AND
       (PRINC
	 "\nNo text, dimensions, bubbles, border sheets or hiding objects found! "
       ) ;_ end of PRINC
       (PRINC)
      )
      ((AND (NOT hdtxt_ss) (NOT hddim_ss))
       (PRINC "\nNo hiding objects found! ")
       (PRINC)
      )
      ((AND (NOT dim_ss) (NOT txt_ss) (NOT bubs_ss))
       (PRINC "\nNo text, dimensions, bubbles or border sheets found! ")
       (PRINC)
      )
    ) ;_ end of COND
    (ddhtextsof)
  ) ;_ end of IF
) ;_ end of defun
(DEFUN ddhtextsof (/)
  (SETQ clayr (GETVAR "clayer"))
  (IF (WCMATCH (STRCASE clayr) "*NPLT*")
    (SETVAR "clayer" "0")
  ) ;_ end of if
  (COMMAND "_.layer" "off" "*nplt*" "")
  (IF
    (AND
      (TBLOBJNAME "block" "hdbox")
      (SSGET "X"
	     '((-4 . "<AND") (0 . "INSERT") (2 . "HDBOX") (-4 . "AND>"))
      ) ;_ end of SSGET
    ) ;_ end of AND
     (COMMAND "_.imageframe" "off")
  ) ;_ end of IF
) ;_ end of defun

(PRINC)
 ;|«Visual LISP© Format Options»
(72 2 40 2 T "end of " 60 9 2 0 0 T T nil T)
;*** DO NOT add text below the comment! ***|;
