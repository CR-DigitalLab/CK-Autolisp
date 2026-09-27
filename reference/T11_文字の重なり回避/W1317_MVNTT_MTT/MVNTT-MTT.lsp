(defun C:MVNTT (/	   ANG2	      CAODOMIN	 E1	    ENAMEPLINE
		EnamePline1	      GOCDICHUYEN	    I
		KTHUONG	   LTS1	      LTS2	 LTSTEXT    LTST_LOC
		LTST_LOC1  LTSVER     OBJLINE	 OBJNEWTUYEN
		OBJSAVE	   P1	      P2	 PNTDAU	    PNTHUONG
		PNTHUONGVG PNTNEW     PNTNEW1	 PNTT	    PNT_TMIN
		PNT_TMINVG SS	      SS1	 TEXTMIN    VLAPLINE
		X
	       )
;;;;MOVE TEXT NHIEU TEXT TRUNG 
  (vl-load-com)
  (setvar "CMDECHO" 0)
  (defun *error* (msg)
    (if	Olmode
      (setvar 'osmode Olmode)
    )
    (if	(not (member msg '("*BREAK,*CANCEL*,*EXIT*")))
      (princ (strcat "\nError: " msg))
    )
    (princ)
  )
  (setq Olmode (getvar "OSMODE"))
  (setq	ObjLine
	 (ssget "_:E:S:L" (list '(0 . "*POLYLINE,LWPOLYLINE")))
  )

  (setq EnamePline (ssname ObjLine 0))
  (setvar "OSMODE" 1)
  (setq	PntDau
	 (getpoint
	   "\nCh\U+1ECDn \U+0111i\U+1EC3m \U+0111\U+1EA7u tuy\U+1EBFn: "
	 )
  )
  (setq
    LtsVer (LM:UniqueFuzz (acet-geom-vertex-list EnamePline) 1e-8)
  )

  (if (not (equal PntDau (car LtsVer) 0.00001))
    (progn
      (dch (entget EnamePline))
      (setq ObjNewTuyen (entlast))
    )
    (setq ObjNewTuyen EnamePline)
  )
  (setq VlaPline (vlax-ename->vla-object ObjNewTuyen))

  (setvar "OSMODE" 0)
  (setq	PntHuong
	 (getpoint
	   "\nCh\U+1ECDn h\U+01B0\U+1EDBng \U+0111\U+1EC3 cao \U+0111\U+1ED9 nh\U+1ECF h\U+01A1n s\U+1EBD di chuy\U+1EC3n: "
	 )
  )

  (setq	PntHuongVG
	 (vlax-curve-getClosestPointTo
	   VlaPline
	   PntHuong
	 )
  )
  (setq	P1 (vlax-curve-getpointatparam
	     VlaPline
	     (fix (vlax-curve-getParamAtPoint VlaPline PntHuongVG))
	   )
  )
  (setq
    P2
     (vlax-curve-getpointatparam
       VlaPline
       (+ (fix (vlax-curve-getParamAtPoint VlaPline PntHuongVG)) 1)
     )
  )


  (or *Khoangcach* (setq *Khoangcach* 0.5))
  (setq	Khoangcach
	 (getreal
	   (strcat
	     "\nNh\U+1EADp kho\U+1EA3ng c\U+00E1ch l\U+1ECDc Text g\U+1EA7n Polyline <"
	     (rtos *Khoangcach* 2 2)
	     "> :"
	   )
	 )
  )
  (if (not Khoangcach)
    (setq Khoangcach *Khoangcach*)
    (setq *Khoangcach* Khoangcach)
  )


  (or *KhoangDichchuyen* (setq *KhoangDichchuyen* 0.01))
  (setq	KhoangDichchuyen
	 (getreal
	   (strcat
	     "\nNh\U+1EADp kho\U+1EA3ng d\U+1ECBch chuy\U+1EC3n <"
	     (rtos *KhoangDichchuyen* 2 2)
	     "> :"
	   )
	 )
  )
  (if (not KhoangDichchuyen)
    (setq KhoangDichchuyen *KhoangDichchuyen*)
    (setq *KhoangDichchuyen* KhoangDichchuyen)
  )
  (setq KtHuong (CCW P1 P2 PntHuong))
  (setq ss (ChonTextSo (ssget (list (cons 0 "TEXT")))))
  (setq LtsText (LM:ss->ent ss))

  (setq
    LtsT_Loc (vl-remove
	       nil
	       (mapcar
		 '(lambda (x)
		    (if	(> (distance (TachXY (TD:Text-Base x))
				     (vlax-curve-getClosestPointTo
				       VlaPline
				       (TD:Text-Base x)
				     )
			   )
			   Khoangcach
			)
		      nil
		      x
		    )
		  )
		 LtsText
	       )
	     )
  )
  (ZmObj ObjLine)
  (setq i 0)
  (while
    (if	(and LtsT_Loc (< i (length LtsT_Loc)))
      (progn
	(setq e1 (nth i LtsT_Loc))
	(setq PntT (TachXY (TD:Text-Base e1)))
	(setvar "OSMODE" 0)
	(setq ss1 (ChonTextSo
		    (ssget "CP"
			   (PntVongtron PntT Khoangcach)
			   (list (cons 0 "TEXT"))
		    )
		  )
	)
	(if (> (sslength ss1) 1)
	  (progn
	    (setq Lts1 (LM:ss->ent ss1))
	    (setq
	      Lts2
	       (mapcar '(lambda	(x)
			  (list (atof (cdr (assoc 1 (entget x)))) x)
			)
		       Lts1
	       )
	    )
	    (setq TextMin (cadar (SortX Lts2)))
	    (setq CaodoMin (caar (SortX Lts2)))
	    (setq Pnt_Tmin (TD:Text-Base TextMin))
	    (setq Pnt_TminVG
		   (vlax-curve-getClosestPointTo
		     VlaPline
		     Pnt_Tmin
		   )
	    )
	    (setq
	      ang2
	       (angle '(0 0)
		      (Vlax-curve-getfirstderiv
			VlaPline
			(vlax-curve-getParamAtPoint VlaPline Pnt_TminVG)
		      )
	       )
	    )
	    (cond
	      ((= KtHuong 1)
	       (setq Gocdichuyen (- ang2 (/ pi 2)))
	      )
	      ((= KtHuong -1)
	       (setq Gocdichuyen (+ ang2 (/ pi 2)))
	      )
	    )
	    (progn
	      (setq
		PntNew (polar Pnt_Tmin Gocdichuyen KhoangDichchuyen)
	      )
	      (setq PntNew1 (list (car PntNew) (cadr PntNew) CaodoMin))
	      (vla-move	(vlax-ename->vla-object TextMin)
			(vlax-3d-point Pnt_Tmin)
			(vlax-3d-point PntNew1)
	      )
	    )
	    (setq LtsT_Loc (vl-remove TextMin LtsT_Loc))
	  )
	)
	(setq i (1+ i))
      )
    )
  )
  (setvar "OSMODE" Olmode)
  (princ)
)

(defun C:MTT (/ ss0 ss ss1 ss2 item Caodo Pn)
;;;;MOVE TEXT TRUNG 
  (vl-load-com)
  (setvar "CMDECHO" 0)
  (defun *error* (msg)
    (if	Olmode
      (setvar 'osmode Olmode)
    )
    (if	(not (member msg '("*BREAK,*CANCEL*,*EXIT*")))
      (princ (strcat "\nError: " msg))
    )
    (princ)
  )
  (setq Olmode (getvar "OSMODE"))

  (setq ss (ssget (list (cons 0   "TEXT"))))
  (setvar "OSMODE" 512)
  (setq Gocdichuyen (getangle "\nChon huong di chuyen: "))
  (setvar "OSMODE" Olmode)
  (setq ss2 (LM:ss->ent (ChonTextSo ss)))
    (or *KhoangDichchuyen* (setq *KhoangDichchuyen* 0.01))
  (setq	KhoangDichchuyen
	 (getreal
	   (strcat
	     "\nNh\U+1EADp kho\U+1EA3ng d\U+1ECBch chuy\U+1EC3n <"
	     (rtos *KhoangDichchuyen* 2 2)
	     "> :"
	   )
	 )
  )
  (if (not KhoangDichchuyen)
    (setq KhoangDichchuyen *KhoangDichchuyen*)
    (setq *KhoangDichchuyen* KhoangDichchuyen)
  )
  (setq Lts1 (list))
  (foreach item	ss2
    (setq Caodo (atof (cdr (assoc 1 (entget item)))))
    (setq Lts1 (append Lts1 (list (list Caodo item))))
  )
  (setq EnameTextMin (cadar (SortX Lts1)))
  (setq	P1 (vlax-get (vlax-ename->vla-object EnameTextMin)
		     'InsertionPoint
	   )
  )
  (setq Pnt (TachXY (TD:Text-Base EnameTextMin)))
  (setq PntNew (polar Pnt Gocdichuyen KhoangDichchuyen))
  (setq PntNew1 (list (car PntNew) (cadr PntNew) (caddr P1)))
  (vla-move (vlax-ename->vla-object EnameTextMin)
	    (vlax-3d-point P1)
	    (vlax-3d-point PntNew1)
  )
  (setvar "OSMODE" Olmode)
  (princ)
)

(defun ChonTextSo (ss / ss i ent str ss1)
  (progn
    (setq i   0
	  ss1 (ssadd)
    )
    (repeat (sslength ss)
      (setq ent	(ssname ss i)
	    str	(cdr (assoc 1 (entget ent)))
	    i	(+ 1 i)
      )
      (if (distof str 2)
	(ssadd ent ss1)
      )
    )
    (if	(> (sslength ss1) 0)
      ss1
    )
  )
)
(defun LM:ss->ent (ss / i l)
  (if ss
    (repeat (setq i (sslength ss))
      (setq l (cons (ssname ss (setq i (1- i))) l))
    )
  )
)

(defun TachXY (Pnt /)
  (setq Pt (list (car Pnt) (cadr Pnt)))
  pt
)

(defun TD:Text-Base (ent / MA71 MA72 X11)
  (setq Ma10 (cdr (assoc 10 (entget ent))))
  (setq Ma11 (cdr (assoc 11 (entget ent))))
  (setq X11 (car Ma11))
  (setq Ma71 (cdr (assoc 71 (entget ent))))
  (setq Ma72 (cdr (assoc 72 (entget ent))))
  (if (or (and (= Ma71 0) (= Ma72 0) (= X11 0))
	  (and (= Ma71 0) (= Ma72 3))
	  (and (= Ma71 0) (= Ma72 5))
      )
    Ma10
    Ma11
  )
)

(defun SortX (lstPnt /)
  (setq
    Lts-Sort (vl-sort lstPnt '(lambda (e1 e2) (< (car e1) (car e2))))
  )
  Lts-Sort
)
(defun dch (ent / eo el len)
  (vl-load-com)
  (setq eo ent)
  (setq el (list (assoc 210 ent)))
  (while (member (assoc 10 ent) ent)
    (if	(= 0.0 (assoc 42 ent))
      (setq el (cons (assoc 42 ent) el))
      (setq el (cons (cons 42 (- (cdr (assoc 42 ent)))) el))
    )
    (setq el (cons (assoc 41 ent) el))
    (setq el (cons (assoc 40 ent) el))
    (setq el (cons (assoc 10 ent) el))
    (setq ent (member (assoc 10 ent) ent))
    (setq ent (cdr ent))
  )
  (setq len (- (LENGTH eo) (LENGTH (member (assoc 10 eo) eo)) 1))
  (while (>= len 0)
    (setq el (cons (nth len eo) el))
    (setq len (- len 1))
  )
  (setq ent el)
  (entmod ent)
  (princ)
)

;;;(defun LM:UniqueFuzz (l f)
;;;  (if l
;;;    (cons (car l)
;;;	  (LM:UniqueFuzz
;;;	    (vl-remove-if
;;;	      (function (lambda (x) (equal x (car l) f)))
;;;	      (cdr l)
;;;	    )
;;;	    f
;;;	  )
;;;    )
;;;  )
;;;)

(defun LM:UniqueFuzz (l f / x r)
  (while l
    (setq x (car l)
	  l (vl-remove-if (function (lambda (y) (equal x y f))) (cdr l))
	  r (cons x r)
    )
  )
  (reverse r)
)

;;;;;; XET DIEM BEN TRAI HAY PHAI DOAN THANG;;;;;;;;;;;;;;;;;;;
(defun CCW (P1 P2 P /)
  (setq	dX  (- (car P) (car P1))
	dY  (- (cadr P) (cadr P1))
	dX0 (- (car P2) (car P1))
	dY0 (- (cadr P2) (cadr P1))
	d   (- (* dX dY0) (* dY dX0))
  )
  (if (> d 0)
    (setq CCW1 1)
    ;;BEN PHAI
    (setq CCW1 -1)
;;;BEN TRAI
  )
  CCW1
)

(defun PntVongtron (Pnt R / L1 i)
  (setq L1 (list))
  (setq L2 (list))
  (setq i 0)
  (repeat 10
    (setq L1 (polar Pnt (/ (* i 36 pi) 180) R))
    (setq L2 (append L2 (list L1)))
    (setq i (1+ i))

  )
  L2
)

(defun ZmObj (ss / Minp Maxp lst)
  (vl-load-com)
  (foreach Obj (mapcar 'vlax-ename->vla-object
		       (vl-remove-if
			 'listp
			 (mapcar 'cadr
				 (ssnamex ss)
			 )
		       )
	       )
    (vla-getBoundingBox Obj 'Minp 'Maxp)
    (setq lst (cons
		(mapcar	'vlax-safearray->list
			(list Minp Maxp)
		)
		lst
	      )
    )
  )
  (vla-ZoomWindow
    (vlax-get-acad-object)
    (vlax-3D-point
      (list
	(apply 'min
	       (mapcar 'car
		       (mapcar 'car lst)
	       )
	)
	(apply 'min
	       (mapcar 'cadr
		       (mapcar 'car lst)
	       )
	)
	0.0
      )
    )
    (vlax-3D-point
      (list
	(apply 'max
	       (mapcar 'car
		       (mapcar 'cadr lst)
	       )
	)
	(apply 'max
	       (mapcar 'cadr
		       (mapcar 'cadr lst)
	       )
	)
	0.0
      )
    )
  )
)

(defun XDT1PL (ObjTuyen	 KCXOA	   /	     COLOR     L1
	       LAYER	 LINETYPE  LTSCALE   LTSVER    OBJPLINE
	      )
;;;XOA DIEM TRUNG 1 PLINE
  (setvar "CMDECHO" 0)
  (setq LtsVer (acet-geom-vertex-list ObjTuyen))
  (setq L1 (LM:UniqueFuzz LtsVer KCXOA))
  (setq Linetype (cdr (assoc 6 (entget ObjTuyen))))
  (setq LTScale (cdr (assoc 48 (entget ObjTuyen))))
  (setq Layer (cdr (assoc 8 (entget ObjTuyen))))
  (setq Color (cdr (assoc 62 (entget ObjTuyen))))
  (entdel ObjTuyen)
  (MakeLWPolyline L1 nil Linetype LTScale Layer Color nil)
)
(defun MakeLWPolyline
       (listpoint closed Linetype LTScale Layer Color xdata / Lst)
  (setq	Lst (list (cons 0 "LWPOLYLINE")
		  (cons 100 "AcDbEntity")
		  (cons	8
			(if Layer
			  Layer
			  (getvar "Clayer")
			)
		  )
		  (cons	6
			(if Linetype
			  Linetype
			  "bylayer"
			)
		  )
		  (cons	48
			(if LTScale
			  LTScale
			  1
			)
		  )
		  (cons	62
			(if Color
			  Color
			  256
			)
		  )
		  (cons 100 "AcDbPolyline")
		  (cons 90 (length listpoint))
		  (cons	70
			(if closed
			  1
			  0
			)
		  )
	    )
  )
  (foreach PP listpoint
    (setq Lst (append Lst (list (cons 10 PP))))
  )
  (if xdata
    (setq Lst (append lst (list (cons -3 (list xdata)))))
  )
  (entmakex Lst)
)