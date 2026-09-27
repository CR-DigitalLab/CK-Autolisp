(defun c:git(/ ss kc i obj lispobj lisdau lisobj diemBcuoi tdi spt des)
(vl-load-com)
;copyright by Tue_NV
(setq ss (ssget '((0 . "*TEXT"))) i 0 lispobj (list))
(if (not kco) (setq kco (cdr(assoc 40 (entget(ssname ss 0))))) )
(setq kc (getdist (strcat "\n Khoang cach giua cac Text <" (rtos kco 2 2) "> :")))
(if (not kc) (setq kc kco) (setq kco kc))

(while (< i (sslength ss))
	(vla-getboundingbox (setq obj (vlax-ename->vla-object (ssname ss i))) 'bl 'tl)
	(setq lispobj (cons (cons (list (safearray-value tl) (safearray-value bl)) obj) lispobj))
	(setq i (1+ i))
)
(setq lispobj (vl-sort lispobj
			'(lambda (x y)
				(< (caaar x) (caaar y))
			 )
	      )
)
(setq lisdau (mapcar 'caar lispobj))
;(setq liscuoi (mapcar 'cadar lispobj))
(setq lisobj (mapcar 'cdr lispobj))
(setq diemBcuoi (list (car (last lisdau)) (cadr (last lisdau)) 0))

(setq tdi (tdiem (car lisdau) diemBcuoi))
(setq spt (/ (float (length lispobj)) 2) i spt)
;(if (= (rem i 1) 0) 
    (progn
	(setq i (- i 0.5)) (setq j 0) 
	(foreach x lisobj
		(setq des (list (- (car tdi) (* i kc)) (cadr (nth j lisdau)) 0))
		(vla-move x (vlax-3d-point (nth j lisdau)) (vlax-3d-point tdi))
		(vla-move x (vlax-3d-point tdi) (vlax-3d-point des))
		(setq i (1- i)) (setq j (1+ j))

       )
    )

)
;
(defun tdiem(x y)
(list (/ (+ (car x) (car y)) 2) (/ (+ (cadr x) (cadr y)) 2) 0)
)

