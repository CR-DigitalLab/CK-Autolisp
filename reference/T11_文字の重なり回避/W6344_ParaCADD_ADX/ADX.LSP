;;; CADALYST 04/07  Tip 2200: ADX.lsp 	Aligned Multiple Line Text 	(c) 2007 David Harrington 

(DEFUN DTR (Z)
  (* PI (/ Z 180.0))
)
(defun RTD (Z) (/ (* Z 180.0) PI))

(defun text_angle (point1 point2 / point_angle)
  (setq point_angle (angle point1 point2))
  (if (or (>= point_angle (* pi 1.5)) (<= point_angle (dtr 91.0)))
    (setq l nil)
    (setq point_angle (angle point2 point1))
  )
  (setq point_angle (rtd point_angle))
)
(defun getnearpt ()
  (princ "\nSelect on object :")
  (setq	point1	 (cadr (nentsel))
	textsize (* (getvar "dimtxt") (getvar "dimscale"))
  )
  (setvar "osmode" 512)
  (if point1
    (progn
      (command ".line"
	       point1
	       (polar point1 0.01 (* textsize 0.01))
	       ""
      )
      (setq listvar (entget (setq ent (entlast)))
	    p1	    (trans (cdr (assoc 10 listvar)) 0 1)
	    p2	    (trans (cdr (assoc 11 listvar)) 0 1)
	    ang	    (text_angle p1 p2)
      )
      (setq pt2 (polar point1 (+ (dtr ang) (* pi 0.5)) 10.0))
      (setq pt3 (inters point1 pt2 p1 p2 nil))
      (entdel ent)
      (command ".id" "mid" pt3)
      (setq lpt (getvar "lastpoint"))
      (if (< (distance lpt pt3) (* 2 textsize))
	(setq pt3 lpt)
      )
    )
    (setq pt3 nil)
  )
)
(defun c:ADX (/ pt1 ts lst end p1 p2 ang spt JST ELST old1 oldosmode)
  (princ "\n   ADX - Add Mtext multiple times")
  (setvar "cmdecho" 0)
  (SETQ oldosmode (getvar "osmode"))
  (setvar "TSPACEFAC" 1.0)
  (getnearpt)
  (setvar "osmode" 0)
  (initdia 1)
  (command ".mtext" pt3	"j" "mc" "r" ang "l" "A" "1.25x" "w" "0")
  (setq val (cdr (assoc 1 (entget (entlast)))))
  (if (NOT (vl-string-search "\\P" VAL))
    (setq jst 2)
  )
  (if (= jst 2)
    (progn
      (setq elst (entget (entlast)))
      (setq old1 (assoc 1 elst))
      (setq elst (subst	(cons 1 (strcat (cdr (assoc 1 elst)) "\\P "))
			(assoc 1 elst)
			elst
		 )
      )
      (entmod elst)
    )
  )
  (while pt3
    (princ "\nPick locations to place additional text :")
    (getnearpt)
    (if	pt3
      (progn
	(IF JST
	  (command ".mtext"
		   pt3
		   "j"
		   "mc"
		   "r"
		   ang
		   "l"
		   "A"
		   "1.25x"
		   "w"
		   0
		   (STRCAT val "\\P ")
		   ""
	  )
	  (command ".mtext" pt3 "j" "mc"	"r" ang	"l" "A"	"1.25x"	"w" 0
		   val "")
	)
      )
    )
  )(princ "\nPick locations to place additional text")
  (command ".mtext"
	   (GETVAR "LASTPOINT")
	   "l"
	   "a"
	   "1x"
	   "w"
	   "0"
	   ""
  )
  (entdel (entlast))
  (setvar "osmode" oldosmode)
  (princ)
)
(princ "\nADX loaded.")
(princ)

