;; ==================================================================== ;;
;;                                                                      ;;
;;  TALON.LSP - Allows to place a text in parallel or                   ;;
;;              perpendicularly a Line, Polyline, LwPolyline,           ;;
;;              Arc, Circle, Ellipse or spline.                         ;;
;;                                                                      ;;
;; ==================================================================== ;;
;;                                                                      ;;
;;  Command(s) to call: TALON                                           ;;
;;                                                                      ;;
;;  Type or copy text, select curve and place text to point you         ;;
;;  need. Settings allow to adjust the text size, offset from a         ;;
;;  the curve and parallel or perpendicular text direction. All         ;;
;;  settings remain to following AutoCAD session.                       ;;
;;                                                                      ;;
;; ==================================================================== ;;
;;                                                                      ;;
;;  THIS PROGRAM AND PARTS OF IT MAY REPRODUCED BY ANY METHOD ON ANY    ;;
;;  MEDIUM FOR ANY REASON. YOU CAN USE OR MODIFY THIS PROGRAM OR        ;;
;;  PARTS OF IT ABSOLUTELY FREE.                                        ;;
;;                                                                      ;;
;;  THIS PROGRAM PROVIDES 'AS IS' WITH ALL FAULTS AND SPECIFICALLY      ;;
;;  DISCLAIMS ANY IMPLIED WARRANTY OF MERCHANTABILITY OR FITNESS        ;;
;;  FOR A PARTICULAR USE.                                               ;;
;;                                                                      ;;
;; ==================================================================== ;;
;;                                                                      ;;
;;  V1.3, 26th Aug, 2008, Riga, Latvia                                  ;;
;;  © Aleksandr Smirnov (ASMI)                                          ;;
;;  For AutoCAD 2000 - 2009 (isn't tested in a next versions)           ;;
;;                                                                      ;;
;;                             http://www.asmitools.com                 ;;
;;                                                                      ;;
;; ==================================================================== ;;


(defun c:talon(/ cWid cHei cStr tVrx cCur grDat stFlg
	         cAng sPt cPt aPt bPt pt1 pt2 pt3 pt4
	         nTxt mPt xPt oldStr cFlg cOpt cTxt
	         aRot actDoc actSp *error*)

(vl-load-com)

(defun *error*(msg)
  (if nTxt(vla-Delete nTxt))
  (princ "\nQuit TALON. ")
  (redraw)
  (princ)
  ); end of *error*

(defun Entsel_or_Text(Spaces Message
		      / lChr tStr grLst filPt selSet outVal pSps)
  (princ Message)
  (setq tStr ""); end setq
  (if Spaces
    (setq pSps(list "\r"))
    (setq pSps(list " " "\r"))
    ); end if
   (while
      (and
        (not(member lChr pSps))
	(/= 3(car grLst))
        ); end and
      (if
        (setq grLst(grread nil 4 2))
        (progn
         (cond
          ((= 3(car grLst))
           (setq filPt(cadr grLst)
                 selSet(ssget filPt)
                 ); end setq
           (if selSet
                (setq outVal
                (list(ssname selSet 0)filPt))
             ); end if
           ); end condition #1
	  ((or
	     (equal '(2 13) grLst)
	     (equal 25(car grLst))
	     ); end or
	    (setq lChr "\r"
		  outVal tStr); end setq
	   ); end condition #2
	  ((and
	     (equal '(2 8) grLst)
	     (< 0(strlen tStr))
	     ); end and
	   (setq tStr(substr tStr 1(1-(strlen tStr))))
	   (princ(strcat(chr 8)(chr 32)(chr 8)))
	   ); end condition #3
          ((and
	     (= 2(car grLst))
	     (<= 32(cadr grLst)126)
	     ); end and
           (setq lChr(chr(cadr grLst)))
           (if(not(member lChr pSps))
                 (progn
                 (setq tStr(strcat tStr lChr)
                       outVal tStr); end setq
             (princ lChr)
           ); end progn
          ); end if
         ); end condition #4
        ); end cond
       ); end progn
      ); end if
     ); end while
    outVal
 ); end of Entsel_or_Text


  (defun MText_Clear(Mtext / Text Str)
      (setq Text "")
      (while(/= Mtext "")
        (cond
          ((wcmatch(strcase
           (setq Str
            (substr Mtext 1 2)))"\\[\\{}`~]")
            (setq Mtext(substr Mtext 3)
               Text(strcat Text Str)
               ); end setq
           ); end condition #1
         ((wcmatch(substr Mtext 1 1) "[{}]")
          (setq Mtext
          (substr Mtext 2))
          ); end condition #2
         ((and
          (wcmatch
           (strcase
             (substr Mtext 1 2)) "\\P")
               (/=(substr Mtext 3 1) " ")
           ); end and
         (setq Mtext (substr Mtext 3)
               Text (strcat Text " ")
               ); end setq
           ); end condition #3
        ((wcmatch
           (strcase
             (substr Mtext 1 2)) "\\[LOP]")
             (setq Mtext(substr Mtext 3))
           ); end condition #4
        ((wcmatch
           (strcase
             (substr Mtext 1 2)) "\\[ACFHQTW]")
           (setq Mtext
            (substr Mtext
             (+ 2(vl-string-search ";" Mtext))))
           ); end condition #5
        ((wcmatch
           (strcase (substr Mtext 1 2)) "\\S")
             (setq Str(substr Mtext 3 (- (vl-string-search ";" Mtext) 2))
                   Text(strcat Text (vl-string-translate "#^\\" " " Str))
                   Mtext(substr Mtext (+ 4 (strlen Str)))
              ); end setq
            (print Str)
          ); end condition #6
         (T(setq Text(strcat Text(substr Mtext 1 1))
                 Mtext (substr Mtext 2)
                 ); end setq
         ); end condition #7
       ); end cond
     ); end while
   Text
 ); end of MText_Clear


(defun Trim_String(paseStr Chars)
    (if(< Chars(strlen paseStr))
      (strcat(substr paseStr 1 Chars)"...")
       paseStr
   ); end if
 ); end of Trim_String

(defun talonset(/ tSize tOff tDir tRot)
  (princ "\n\n================= TALON Settings =================\n") 
   (if(not(getenv "talon:tsize"))
      (setenv "talon:tsize"(rtos(getvar "TEXTSIZE")))
     ); end if
   (if(not(getenv "talon:offset"))
     (setenv "talon:offset"(rtos(/(getvar "TEXTSIZE")4)))
    ); end if
   (if(not(getenv "talon:direct"))
    (setenv "talon:direct" "Par")
    ); end if
   (if(not(getenv "talon:rotate"))
    (setenv "talon:rotate" "Yes")
    ); end if
  (if(setq tSize(getdist
		  (strcat "\nSpecify text size <"
			  (getenv "talon:tsize") ">: ")))
    (setenv "talon:tsize"(rtos tSize))
    ); end if
  (if(setq tOff(getdist
		  (strcat "\nSpecify offset from curve <"
			  (getenv "talon:offset") ">: ")))
    (setenv "talon:offset"(rtos tOff))
    ); end if
  (initget "Parallel pErpendicular")
    (if(setq tDir(getkword
		   (strcat "\nSpecify text direction [Parallel/pErpendicular] <"
			  (getenv "talon:direct") ">: ")))
    (setenv "talon:direct" tDir)
    ); end if
   (initget "Yes No")
    (if(setq tRot(getkword
		   (strcat "\nRotate text to 0°- 90° [Yes/No] <"
			  (getenv "talon:rotate") ">: ")))
    (setenv "talon:rotate" tRot)
    ); end if
  (princ
  (strcat "\n<<< Size = " (getenv "talon:tsize")
	  ", Offset = " (getenv "talon:offset")
	  ", Direction = " (getenv "talon:direct")
	  ", Rotation 0°- 90° = " (getenv "talon:rotate")
	  " >>> "); end strcat
  ); end princ
  (princ "\n\n================= End of Settings =================\n") 
  (princ)
  ); end of talonset
  

(if(not(getenv "talon:tsize"))
  (setenv "talon:tsize"(rtos(getvar "TEXTSIZE")))
  ); end if
 (if(not(getenv "talon:offset"))
  (setenv "talon:offset"(rtos(/(getvar "TEXTSIZE")4)))
  ); end if
 (if(not(getenv "talon:direct"))
  (setenv "talon:direct" "Parallel")
  ); end if
 (if(not(getenv "talon:rotate"))
    (setenv "talon:rotate" "Yes")
    ); end if
 (if(not talon:str)(setq talon:str "text"))
 (setq oldStr talon:str)
(princ
  (strcat "\n<<< Size = " (getenv "talon:tsize")
	  ", Offset = " (getenv "talon:offset")
	  ", Direction = " (getenv "talon:direct")
	  ", Rotation 0°- 90° = " (getenv "talon:rotate")
	  " >>> "); end strcat
  ); end princ
(while(not cFlg)
 (setq cOpt(Entsel_or_Text T
	    (strcat "\nType or Copy text, Right Click to repeat <"
		    (Trim_String talon:str 15) ">: ")))
 (cond
   ((= 'STR(type cOpt))
    (setq talon:str cOpt
	  cFlg T); end setq
    ); end condition #1
   ((= 'LIST(type cOpt))
      (if(vlax-property-available-p
	   (setq cTxt(vlax-ename->vla-object
		       (car cOpt))) 'TextString)
	(progn
	  (setq talon:str
		 (MText_Clear(vla-get-TextString cTxt))
		cFlg T); end setq
	  (princ(strcat "\nText = \""
			(Trim_String talon:str 15)"\""))
	  ); end progn
	  (princ "\n<!> This isn't Text or MText <!> ")
	); end if
    ); end condition #2
   ); end cond
  ); end while
 (if(= "" talon:str)(setq talon:str oldStr))
 (if(/= talon:str "")
  (progn
   (setq actDoc(vla-get-ActiveDocument
		 (vlax-get-acad-object))
	 cFlg nil
	 ); end setq
   (while(not cFlg)
     (setq cCur
	    (Entsel_or_Text nil
	      "\nSelect curve or [Settings] > "))
     (cond
       ((= 'STR(type cCur))
	  (if(member(strcase cCur) '("S" "_S" "SETTINGS" "_SETTINGS"))
	    (talonset)
	    (princ "\n<!> Invalid keyword option <!> ")
	   ); end if
	); end condition #1
	((= 'LIST(type cCur))
          (if(member(cdr(assoc 0(entget(car cCur))))
	      '("LINE" "LWPOLYLINE" "POLYLINE"
		"CIRCLE" "ELLIPSE" "ARC" "SPLINE"))
           (progn
	     (setq tVrx(textbox(list(cons 1 talon:str)
		               (cons 40(atof(getenv "talon:tsize"))))))
	        (if(=(getenv "talon:direct") "Parallel")
                  (setq cWid(caadr tVrx)
	                cHei(cadadr tVrx)
	                aRot(/ pi 2)
	                ); end setq
                  (setq cWid(cadadr tVrx)
	                cHei(caadr tVrx)
	                aRot(* 2 pi)
	                ); end setq
                   ); end if
	     (setq cCur(vlax-ename->vla-object(car cCur))
		   actSp(vla-ObjectIdToObject actDoc
			  (vla-get-OwnerID cCur))
		   cFlg T); end setq
	      (while
	        (and
	         (= 5(car(setq grDat(grread T 1))))
	         (not stFlg)
	        ); end and
	         (redraw)
	        (if(= 'LIST(type(setq sPt(trans(cadr grDat)1 0))))
	          (progn
	           (setq cPt(vlax-curve-GetClosestPointTo cCur sPt)
		         cAng(angle cPt sPt)
                         aPt(trans(polar cPt cAng
				   (atof(getenv "talon:offset")))0 1)
		         bPt(trans(polar cPt cAng
				(+(atof(getenv "talon:offset"))cHei))0 1)
		         pt1(polar aPt(+ cAng(/ pi 2))(/ cWid 2))
		         pt2(polar aPt(- cAng(/ pi 2))(/ cWid 2))
		         pt3(polar bPt(- cAng(/ pi 2))(/ cWid 2))
		         pt4(polar bPt(+ cAng(/ pi 2))(/ cWid 2))
		        ); end setq
	                (grvecs(list 3 pt1 pt2 3 pt2 pt3
				     3 pt3 pt4 3 pt4 pt1))
	             ); end progn
	           ); end if
	         ); end while
	     (if(= 3(car grDat))
	       (progn
	       (vla-StartUndoMark actDoc)
                (setq stFlg T
		      nTxt(vla-AddText actSp talon:str
			   (vlax-3D-point '(0.0 0.0 0.0))
			    (atof(getenv "talon:tsize")))
		      tVrx(textbox(entget(entlast)))
		      mPt(vlax-3d-Point
			  (mapcar '/
			    (mapcar '+
			      (car tVrx)(cadr tVrx))
				  '(2.0 2.0 1.0)))
		      xPt(vlax-3d-Point
			   (mapcar '/
			    (mapcar '+
			      (trans aPt 1 0)(trans bPt 1 0))
				  '(2.0 2.0 1.0)))
		      ); end setq
		(vla-Move nTxt mPt xPt)
	      (if(= "Yes"(getenv "talon:rotate"))
		  (if(and(> cAng 0)(<= cAng pi))
		    (vla-Rotate nTxt xPt(- cAng aRot))
		    (vla-Rotate nTxt xPt(+ cAng aRot))
		   ); end if
		(vla-Rotate nTxt xPt(- cAng aRot))
		); end if
	       (redraw)
	      (vla-EndUndoMark actDoc)
	      ); end progn
	    ); end if
	  ); end progn
        (princ "\n<!> Invalid object <!> ")
        ); end if
       ); end condition #2
      ); end cond
     ); end while
    ); end progn
   (princ "\n<!> Empty string <!> ")
  ); end if
 (princ)
); end of c:talon


(princ "\n[Info] http:\\\\www.AsmiTools.com [Info]")
(princ "\n[Info] Type TALON to place text along curve [Info]")





