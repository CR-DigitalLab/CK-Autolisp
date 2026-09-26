;;;  **********************************************************************
;;;        tube.lsp  georg mischler  version 29.01.1993
;;;           Generate meshes sweeping along a path with a given profile.
;;;           Splinefit the path to any degree with a defined # of points.
;;;  **********************************************************************
;;;        Permission to use, copy, modify, and distribute this software
;;;        for any purpose and without fee is hereby granted, provided
;;;        that the above originator notice appears in all copies and that
;;;        both that originator notice and this permission notice appear in
;;;        all distributed versions of the software.
;;;
;;;        THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT EXPRESS OR IMPLIED
;;;        WARRANTY.  ALL IMPLIED WARRANTIES OF FITNESS FOR ANY PARTICULAR
;;;        PURPOSE AND OF MERCHANTABILITY ARE HEREBY DISCLAIMED.
;;;  **********************************************************************

(setvar "cmdecho" 0)
(setvar "osmode" 0)

;;; tube generation ----------------------------------------------------
;;;

(defun make_tube (prof path nclose mclose / nprof firstpt proflist)
  (if (equal (car path)(last path))
    (setq mclose T
      path (reverse (cdr (reverse path))) ) )
  (setq path (elimstraights (uniquepts path))
    prof (uniquepts prof)
    firstpt (car path)
    proflist (list (if mclose (nexttubeprof prof (cons (last path) path))
               prof )))
  (while (cddr path)
     (setq prof (if (setq nprof (nexttubeprof prof path))
            nprof
            prof)
         proflist (if nprof (cons prof proflist) proflist)
         path (cdr path))
     )
  (setq prof (if mclose (nexttubeprof prof (append path (list firstpt)))
         (endtubeprof prof path) )
    proflist (cons prof proflist) )
  (command "3dMESH" (length proflist) (length prof))
  (foreach profile (reverse proflist)
       (foreach point profile
          (command point) ) )
  (if nclose (command "pedit" "l" "N" ""))
  (if mclose (command "pedit" "l" "M" ""))
  )


(defun nexttubeprof (prof path / dir1 dir2 ai p0 v1 v2)
  (setq p0 (cadr path)
    dir1 (vector (car path) (cadr path))
    dir2 (vector (caddr path)(cadr path)) 
    ai (full_interang dir1 dir2)
    v1 (vect-prod dir1 dir2)
    v2 (car (intervectors dir1 dir2 v1 ai 1)) )
  (if (equal 0.0 ai 0.0000001)
    (endtubeprof prof path)
    (mapcar '(lambda (pt)
             (pointthru (list pt dir1) p0 v1 v2) )
        prof ) ) )


(defun endtubeprof (prof path / p0 dir v1 v2 )
  (setq dir (vector (car path) (cadr path))
    p0 (cadr path)
    v1 (if (or (equal '(-1.0 0.0 0.0) dir 0.5)
           (equal '(1.0 0.0 0.0) dir 0.5) )
         (vect-prod dir '(0.0 1.0 0.0))
         (vect-prod dir '(1.0 0.0 0.0)) )
    v2 (vect-prod dir v1) )
  (mapcar '(lambda (pt)
           (pointthru (list pt dir) p0 v1 v2) )
      prof) )

;;;
;;; end tube generation -----------------------------------------------

;;; vector calc -------------------------------------------------------
;;;

(defun intervectors (v1 v2 vn ai num / astep a1 a2 vect vlist)
  ;; return: a list of one or more vectors interpolated regularly between
  ;;         the vectors 'v2' and 'v2'.
  ;;    'vn' must be a vector perpendicular to the other two.
  ;;    'ai' must be the angle between the two vectors.
  ;;    'num' is the number of vectors to return.
  (setq astep (/ ai (1+ num))
    a1 0 )
  (repeat num
      (setq a1 (+ a1 astep)
        a2 (- ai a1)
        vect (if (or (equal v1 v2)
               (equal v1 (mapcar '- v2)) )
             v1
             (3angvector v1 v2 vn (list (cos a1) (cos a2) 0)) )
        vlist (append vlist (list vect)) ) )
  vlist )


(defun 3angvector (av bv cv coslist / xyz sxyz rxyz vallist)
  ;; parameters: three normalised vectors and
  ;;             coslist: (cos-a cos-b cos-c)
  ;; return: vector spanning certain angles with three other vectors.
  ;;         all vectors must be normalised.
  ;;         the result will only be correct if the angles fit possibly
  ;;         together with the three vectors (strange, what?).
  ;;
  (setq xyz  (mapcar 'list av bv cv)
    sxyz (mapcar 'shift xyz)
    rxyz (mapcar 'shift sxyz)
    vallist (mapcar '(lambda (ry sz sy rz)
                 (mapcar '(lambda (yc zb yb zc)
                          (- (* yc zb)
                           (* yb zc) ) )
                     ry sz sy rz ) )
            (shift rxyz)
            (shift (shift sxyz))
            (shift sxyz)
            (shift (shift rxyz)) ) )
  (mapcar '(lambda (xlist vals)
           (/ (apply '+ (mapcar '* coslist vals))
            (apply '+ (mapcar '* xlist vals)) ) )
      xyz vallist ) )


(defun pointthru (vl p0 vv vw)
  ;;
  ;; parameters: a vectorized line and a plane consisting of a
  ;;             origin-point and two vectors.
  ;; return: the meetingpoint of  the vectorized line with the plane.
  ;;
  (extend-vline vl (pointthru-t vl p0 vv vw)) )


(defun pointthru-t (vl p0 vv vw / svv svw abc o-p   )
  ;;
  ;; parameters: a vectorized line and a plane consisting of a
  ;;             origin-point and two vectors.
  ;; return: the parameter extending the vectorized line to the plane.
  ;;
  (setq svv (shift vv)
    svw (shift vw)
    abc (mapcar '(lambda (yv zw yw zv)
               (- (* yv zw)
                (* yw zv) ) )
          svv (shift svw) svw (shift svv) )
    o-p (mapcar '- p0 (car vl)) )
  (/ (apply '+ (mapcar '* abc o-p))
   (apply '+ (mapcar '* abc (cadr vl))) ) )


(defun orthparamt (pt vl / tc tn tval)
  ;;  return : parameter t extending vectorised line 'vl' to
  ;;           the point perpendicular on 'vl' from point 'pt'.
  ;;
  (setq tc (apply '+ (mapcar '(lambda (xv xp xr)
                    (* xv (- xp xr)) )
               (cadr vl) pt (car vl) ))
    tn (apply '+ (mapcar '(lambda (xv)
                    (* xv xv) )
               (cadr vl) )) )
  (if (= 0 tn)
    (prompt "\ndivbyzero in orthparamt!\007 ");(/ pi 2)
    (/ tc tn) ) )


(defun full_interang (v1 v2 / ot pp d1 ang)
  ;; return : angle between vectors 'v1' and 'v2'. 
  (setq ot (orthparamt v2 (list '(0 0 0) v1))
    pp (extend-vline  (list '(0 0 0) v1) ot)
    d1 (distance '(0 0 0) pp) )
  (cond ( (= 0 d1)
      (setq ang (/ pi 2)) )
    ( T
     (setq ang (atan (/ (distance v2 pp) d1 ))) ) )
  ang )


(defun vector (p1 p2 / len)
  ;; return: vector of length 1 from p1 towards p2.
  ;;         null-vector if points are identical.
  (setq len (distance p1 p2))
  (if (= 0 len)
    '(0.0 0.0 0.0)
    (mapcar '(lambda (x1 x2)
             (/ (- x2 x1)
              len ) )
        p1 p2 ) ) )


(defun vect-prod (v1 v2 / yzx)
  ;; vector-product
  ;;
  ;;    x = y1 z2 - y2 z1
  ;;    y = z1 x2 - z2 x1
  ;;    z = x1 y2 - x2 y1
  ;;
  (setq yzx (shift (mapcar 'list v1 v2)))
  (normalize (mapcar '(lambda (yl zl)
                (- (* (car yl)(cadr zl))
                 (* (cadr yl)(car zl)) ) )
           yzx (shift yzx) )) )


(defun transf-p (vect matrix / factor)
  (if (numberp (setq factor (last matrix)))
    (setq vect (mapcar '* vect (list factor factor factor))
      matrix (reverse (cdr (reverse matrix))) ) )
  (mapcar '(lambda (mline)
           (apply '+ (mapcar '* vect mline)) )
      matrix ) )


(defun extend-vline (vline dist)
  ;; return: point on vectorised line 'vline' in distance 'dist' from its
  ;;         origin-point.
  (mapcar '(lambda (xp xv)
           (+ xp (* xv dist)) )
      (car vline)(cadr vline) ) )


(defun normalize (vect / len)
  ;; return: vector of length 1 in direction of vector 'vect'.
  (setq len (distance '(0 0 0) vect))
  (if (= 0 len)
    vect
    (mapcar '(lambda (co)
             (/ co len) )
        vect ) ) )

;;;
;;; end vector calc ---------------------------------------------------

;;; spline fitting ---------------------------------------------------
;;;

(defun tubeplinetolist (pline / a b plist flag)
  ;; input : entity-name of a polyline.
  ;;         no fitted plines!
  ;; output: list of two element for every point in that polyline
  ;;          containing one point and a vertex-name.
  (setq flag (getval pline 70)   ;polyline flags
    a (entget pline)
    b (entget (entnext (cdar a)))
    plist NIL )
  (cond  
   ( (= 0 (logand flag (+ 2 4 16 32 64))) ; 0, 1, 8 are allowed
   (while (/= "SEQEND" (cdr (assoc 0 b)))
      (setq plist (cons (trans (cdr (assoc 10 b )) pline 1)
                plist )
          b (entget (entnext (cdar b))) ) ) )
   ( T NIL) )
  (reverse plist) ) ; end plinetolist


(defun bspl_knot (jj tt nn)
  ;; position of a single point 'uj'.
  (cond ( (< jj tt) 0.0)
    ( (> jj nn) (- nn tt -2.0))
    ( T       (- jj tt -1.0)) )
  )


(defun bspl_blend (k    ; current ctrl-pt number
            tt   ; degr - rec
            n    ; # of ctr-segs
            u    ; pos of pt
            kN   ; 
            kT
            / tmp v)
  ;; contribution 'v' of a ctrl-pt 'k' out of 'n' to a pt 'u'.
  (setq v 0.0)
  (cond ;; last ctrl-pt and last pt
    (  (and (= k n) (= u (- n tt -2.0)))
       (setq v 1.0) )
    ;; first ctrl-pt and first pt
    (  (and (equal k 0 0.0000001) (equal u 0 0.0000001))
       (setq v 1.0) )
    ( (= tt 1)   ; last recursion
      (if (and (<= (bspl_knot k kN kT) u)
           (< u (bspl_knot (+ k 1.0) kN kT)) )
        (setq v 1.0) ) )
    ( T  (if (/= 0.0 (setq tmp (- (bspl_knot (- (+ k tt) 1.0) kN kT)
                    (bspl_knot k kN kT) )) )
         (setq v (/ (* (- u (bspl_knot k kN kT))
                 (bspl_blend k (- tt 1.0) n u kN kT) )
              tmp )) )
       (if (/= 0.0 (setq tmp (- (bspl_knot (+ k tt) kN kT)
                    (bspl_knot (+ k 1.0) kN kT) )))
         (setq v (+ v (/ (* (- (bspl_knot (+ k tt) kN kT) u)
                  (bspl_blend (+ k 1.0) (- tt 1.0) n u kN kT) )
                 tmp ))) ) ) )
  v )


(defun bspl_calcpt (tt   ; degr-1
             n    ; # of ctr-segs
             u    ; pos of pt
             cpts ; list of ctrl-pts
             /
             k    ; current ctrl-pt number
             B    ; current blend-value
             pt   ; current pt
             )
  (setq k 0.0
    pt '(0.0 0.0 0.0) )
  (foreach cpt cpts
       (setq B (bspl_blend k tt n u tt n) 
         pt (mapcar '(lambda (p c)
                   (+ p (* c B)) )
              pt cpt )
         k (+ k 1.0) ) )
  pt )


(defun bspline (cpts segs degr / i n tt pts)
  (setq i 0.0
    n (- (length cpts) 1.0)
    tt (1+ degr) )
  (while (<= i segs)
     (setq pts (cons (bspl_calcpt tt n (* (/ (- n tt -2.0) segs) i) cpts)
             pts )
         i (+ i 1) ) )
  (reverse pts) )

;;;
;;; end spline fitting ---------------------------------------------------

;;; util ----------------------------------------------------------------
;;;

(defun elimstraights (plist / nplist)
  (mapcar '(lambda (p0 p1 p2)
           (if (and nplist
              (equal 0.0
                   (full_interang (vector (car plist)
                              (cadr plist) )
                          (vector (cadr plist)
                              (caddr plist) ) )
                   0.0000001) )
              NIL
              (setq nplist (cons p1 nplist)) ) )
      (reverse (shift (reverse plist)))  plist (shift plist) )
  (reverse nplist) )


(defun uniquepts (plist / nplist)
  ;; takes identical points out of a pointlist if they follow each other or
  ;;    close the list.
  (mapcar '(lambda (p0 p1)
           (if (equal p0 p1)
             NIL
             (setq nplist (cons p0 nplist)) ) )
      plist (shift plist) )
  (reverse nplist) )

(defun getval (ele code)
  (cdr (assoc code (entget ele))) )


(defun shift (alist)
  (append (cdr alist) (list (car alist))) )


(defun bspl_error (msg)
  (princ msg)
  (setq *error* nil) )

;;;
;;; end util -------------------------------------------------------------

;;; commands ------------------------------------------------------------
;;;

(defun c:fitpoly ( / ele plist segs degr splist)
  (setq *error* bspl_error)
  (setq ele (entsel "select polyline: "))
  (cond ((and ele (= "POLYLINE" (cdr (assoc 0 (entget (car ele))))))
     (setq segs (getint "\nnumber of segments: ")
         degr (getint "\npolynominal degree of spline: ")
         plist (tubeplinetolist (car ele))
         splist (bspline plist segs degr) )
     (command "3dpoly") (foreach pt splist (command pt))(command "")
     )
    (T (prompt "not a polyline!\007\n")) ) 
  (setq *error* nil)
  (princ))


(defun c:tube ( / cele pele cplist pplist fflag segs degr)
  (setq *error* bspl_error)
  (setq cele (entsel "select Polyline as profile: "))
  (cond ( (and cele (= "POLYLINE" (cdr (assoc 0 (entget (car cele))))) )
      (redraw (car cele) 3)
      (setq pele (entsel "select Polyline as path: "))
      (cond ( (and pele (= "POLYLINE" (cdr (assoc 0 (entget (car pele))))) )
          (redraw (car pele) 3)
          (initget "Yes No")
          (setq cplist (tubeplinetolist (car cele) )
            pplist (tubeplinetolist (car pele) )
            fflag (getkword "\nFit path-curve Yes/<No>: ") )
          (if (= "Yes" fflag)
            (setq segs (getint "\nTotal number of segments: ")
              degr (getint "\npolynominal degree of spline: ")
              pplist (bspline pplist segs degr) ) )
          (make_tube cplist pplist
               (if (= 1 (logand 1 (getval (car cele) 70 ))) T NIL)
               (if (= 1 (logand 1 (getval (car pele) 70 ))) T NIL) )
          (redraw (car pele)) )
        ( T (prompt "not a Polyline!\007\n")) )
      (redraw (car cele)) )
      (T (prompt "not a Polyline!\007\n")) )
    (setq *error* nil)
    (princ))
  
;;;
;;; end commands ------------------------------------------------------
(prompt "type \"FITPOLY\" or \"TUBE\" to start.\n")
(princ)
;;; end tube.lsp  ------------------------------------------------------
