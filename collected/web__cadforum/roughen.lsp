;;; ROUGHEN.LSP version 16.01, 20-Jun-2001
;;;
;;; ROUGHEN.LSP: AutoLISP program to "roughen" a polyline.
;;; Application prefix for global symbols = Daed_
;;;
;;;-----------------------------------------------------------------------
;;; copyright 1993-2001 by Mark Middlebrook
;;;   Daedalus Consulting
;;;   e-mail: mark@markcad.com
;;;
;;; Before you e-mail me with support questions, please make sure that
;;; you're using the current version. You can download it from
;;; http://markcad.com.
;;;
;;; This program is free software. You can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation: http://www.gnu.org/copyleft/gpl.html.
;;;
;;;-----------------------------------------------------------------------
;;; Revision history
;;;  v. 2k.0   31-May-1999  First release for AutoCAD 2000.
;;;  v. 2k.0f  14-Jul-1999  Added GNU GPL and download info to header.
;;;  v. 16.0   23-Apr-2001  Added multiple object selection.
;;;  v. 16.01  20-Jun-2001  Fixed an error handler bug.
;;;  v. 16.02  01-Nov-2024  Getdist - www.cadforum.cz
;;;
;;;-----------------------------------------------------------------------
;;;*Why Use ROUGHEN?
;;; Use ROUGHEN when you want to turn polylines and/or lines into an
;;; irregularly zigzaggy line. For example, you can use roughened lines
;;; to designate existing concrete surfaces that have been roughened
;;; for better adhesion with new concrete.
;;;
;;;-----------------------------------------------------------------------
;;;*How to Use ROUGHEN
;;;
;;; I have tested this version of ROUGHEN with AutoCAD R14 and 2000i.
;;; It roughens the newer AutoCAD R14 lwpolyline objects ("lightweight
;;; polylines"), as well as older "heavyweight" polyline objects.
;;;
;;; To run ROUGHEN, load it using AutoCAD's APPLOAD command, or type:
;;;   (load "ROUGHEN")
;;; at the AutoCAD command prompt. After you've loaded ROUGHEN.LSP, type:
;;;   ROUGHEN
;;; to run it. ROUGHEN will prompt you to select polylines and/or lines.
;;; After you select objects, ROUGHEN inserts a series of vertices in
;;; all of the polylines and lines in order to create an irregular,
;;; zigzaggy polyline.
;;;
;;; If you don't like the results, type U and press ENTER to undo
;;; ROUGHEN's work.
;;;
;;; Tips:
;;; (1) Each time you run the program, it gives you the opportunity to
;;;     change the roughness period (i.e., approximate length of the
;;;     zigzag lines) and roughness amplitude (i.e., height of the zigzag
;;;     lines.
;;; (2) You can select objects other than polylines and lines; Roughen.lsp
;;;     ignores them.
;;;
;;;-----------------------------------------------------------------------
;;;*Known limitations
;;;  1) The entire polyline or line must be visible in order for ROUGHEN
;;;     to work properly.
;;;  2) ROUGHEN turns arc segments into straight segments.
;;;
;;;=======================================================================

(defun C:ROUGHEN (/	    olderr    dwgscale	basicziglen
		  roughness ocmd      oosmode	en	  etype
		  en1	    expr      lstverts	vertnum	  vtx1
		  vtx2	    seglen    segang	inclen	  zignum
		  ziglen    zigdist   wanderdist	  wanderang
		  newvtx    ss1	      ss1len	i_ss      yorn
		 )


  ;;error handler
  (setq olderr *error*)
  (defun *error* (msg)
    (if	(or
	  (= msg "Function cancelled")
	  (= msg "quit / exit abort")
	)
      ;;if user cancelled or program aborted, exit quietly
      (princ)
      ;;otherwise report error message
      (princ (strcat "\nError: " msg))
    )
    (command "._UNDO" "_End")
    (if oosmode (setvar "OSMODE" oosmode))
    (if ocmd (setvar "CMDECHO" ocmd))
    (setq *error* olderr)		;restore old error handler
    (setq olderr nil)
    (princ)
  )

  ;; (daed_mgetreal prompt-string initgetbits default-real)
  ;; User input function for getting a real number
  ;;   initgetbits = sum of  0 for none
  ;;                         2 for disallow zero
  ;;                         4 for disallow negative
  ;;      (don't use the 1 bit; it's figured out automatically).
  ;;   default-real = real number or nil.
  ;;   returns real number.
  (defun daed_mgetreal (promptstr initbits defreal / answer)
    (setq promptstr (strcat promptstr
			    (if	defreal
			      (strcat " <" (rtos defreal 2) ">: ")
			      ": "
			    )
		    )
    )
    (if	defreal
      (initget initbits)
      (initget (1+ initbits))
    )
    (setq answer (getdist promptstr)) ; was: getreal
    (if	(null answer)
      (setq answer defreal)
    )
    answer
  )

  ;; Have the user select objects
  (prompt "\nSelect polylines or lines to roughen: ")
  (setq ss1 (ssget))

  ;;User selected entities, so proceed
  (if ss1
    (progn
      (command "._UNDO" "_Group")
      ;;Save system variable settings
      (setq ocmd (getvar "CMDECHO"))
      (setvar "CMDECHO" 0)
      (setq oosmode (getvar "OSMODE"))
      (setvar 'osmode (boole 7 (getvar 'osmode) 16384))

      ;;Set default length and roughness of "zigzags" here
      (if (null daed_dwgscale)
	(setq daed_dwgscale    (if (zerop (getvar "DIMSCALE"))
				 1
				 (getvar "DIMSCALE")
			       )
	      daed_basicziglen 0.05	;larger is longer segment
	      daed_roughness   0.015	;larger is rougher amplitude
	)
      )
      ;;Display current roughening parameters
      (prompt (strcat "\nDrawing scale = "
		      (rtos daed_dwgscale 2 4)
		      "  Roughness period = "
		      (rtos daed_basicziglen 2 4)
		      "  Roughness amplitude = "
		      (rtos daed_roughness 2 4)
	      )
      )

      (initget "Yes No")
      (setq yorn
	     (getkword
	       "\nDo you want to change the roughening parameters <N>: "
	     )
      )
      (if (= yorn "Yes")
	;;Allow user to change the roughening parameters
	(setq daed_dwgscale    (daed_mgetreal
				 "\nDrawing scale factor"
				 6
				 daed_dwgscale
			       )
	      daed_basicziglen (daed_mgetreal
				 "\nRoughness period (larger numbers give fewer zigzags)"
				 6
				 daed_basicziglen
			       )
	      daed_roughness   (daed_mgetreal
				 "\nRoughness amplitude (larger numbers give higher spikes)"
				 6
				 daed_roughness
			       )
	)

      )

      ;;Multiply roughening factors by drawing scale factor
      (setq basicziglen	(* daed_basicziglen daed_dwgscale)
	    roughness	(* daed_roughness daed_dwgscale)
	    ss1len	(sslength ss1)	;length of selection set
	    i_ss	0		;loop counter
      )
      (while (< i_ss ss1len)		;while more members in the SS
	(setq en (ssname ss1 i_ss))

	(setq etype    (cdr (assoc 0 (entget en)))
	      lstverts nil
	)
	(cond
	  ;;Entity is a line, so convert it to a polyline
	  ((equal etype "LINE")
	   (prompt "\nConverting a LINE object to a polyline.")
	   (command "._PEDIT" en "_Yes" "_eXit")
	   (setq en    (entlast)	;reset en
		 etype (cdr (assoc 0 (entget en)))
	   )
	  )
	)

	(cond

	  ;;Entity is an lwpolyline
	  ((equal etype "LWPOLYLINE")
	   (prompt "\nRoughening an LWPOLYLINE object....")
	   ;;Build list of vertices
	   (mapcar
	     '(lambda (expr)
		(if (= (car expr) 10)
		  (setq lstverts (cons (cdr expr) lstverts))
		)
	      )
	     (entget en)
	   )
	   (setq lstverts (reverse lstverts))
	  )

	  ;;Entity is a polyline
	  ((equal etype "POLYLINE")
	   (prompt "\nRoughening a POLYLINE object....")
	   ;;Build list of vertices
	   (setq en1 (entnext en))	;first vertex
	   (while (/= "SEQEND" (cdr (assoc 0 (entget en1))))
	     (setq lstverts (cons (cdr (assoc 10 (entget en1))) lstverts)
		   en1	    (entnext en1) ;next vertex
	     )
	   )
	   (setq lstverts (reverse lstverts))
	  )

	  (T (prompt "\nObject is not a polyline or line."))
	)

	;;There are vertices, so process the lwpolyline or polyline
	(if lstverts
	  (progn
	    (command "._PEDIT" en "_Edit") ;edit vertex
	    (setq vertnum 1)
	    (while (< vertnum (length lstverts))
	      (setq vtx1    (nth (1- vertnum) lstverts)
		    vtx2    (nth vertnum lstverts)
		    seglen  (distance vtx1 vtx2)
		    segang  (angle vtx1 vtx2)
		    zignum  (fix (/ seglen basicziglen))
					;# of "zigzags"...
		    zignum  (max zignum 2) ; but not less than 2
		    ziglen  (/ seglen zignum) ;zigzag length
		    zigdist ziglen
		    i	    2
	      )

	      (repeat (1- zignum)
		(setq newvtx	 (polar vtx1 segang zigdist)
					;vertex init. loc.
		      newvtx	 (trans newvtx 0 1)
		      wanderdist (* roughness (daed_randnum))
		      wanderang	 (if (= (rem i 2) 1)
					;wander back & forth
				   (+ segang (/ pi 4))
				   (- segang (/ pi 4))
				 )
		)
		(command "_Insert"
			 newvtx
		)
		;;PEDIT behaves inconsistently with polylines vs. lwpolylines
		(if (equal etype "POLYLINE")
		  (command "_Next")
		)
		(command "_Move"
			 (polar newvtx wanderang wanderdist)
		)
		(setq zigdist (+ ziglen zigdist)
		      i	      (1+ i)
		)
	      )

	      (command "_Next")
	      (setq vertnum (1+ vertnum))
	    )
	    (command "_eXit" "_eXit")	;exit PEDIT
	    (redraw en)
	  )
	)
	(setq i_ss (1+ i_ss))		;next entity
      )
    )


    (prompt "\nNo objects selected.")
  )
  (prompt "  Finished.")
  (command "._UNDO" "_End")
  (if oosmode (setvar "OSMODE" oosmode))
  (if ocmd (setvar "CMDECHO" ocmd))
  (setq *error* olderr)
  (princ)
)

;;;Random number generation function - based on the linear
;;; congruential method as presented in Doug Cooper's book
;;; Condensed Pascal, pp. 116-117.
;;; Returns a random number between 0 and 1.
(defun daed_randnum (/ modulus multiplier increment random)
  (if (not daed_seed)
    (setq daed_seed (getvar "DATE"))
  )
  (setq	modulus	   65536
	multiplier 25173
	increment  13849
	daed_seed  (rem (+ (* multiplier daed_seed) increment) modulus)
	random	   (/ daed_seed modulus)
  )
)

(prompt
  "\nROUGHEN version 16.02 loaded. Type ROUGHEN to run it."
)
(princ)
