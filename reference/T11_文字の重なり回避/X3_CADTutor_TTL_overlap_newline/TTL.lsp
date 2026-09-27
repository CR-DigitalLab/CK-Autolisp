;;sub-foo renamed as
(defun ++rarify (l n / i ls) 
  ;incremental rarify - hp 14.06.2018
  (cons    (setq i (car l))
    (progn (repeat (1- (length l))
         (setq ls (cons    (setq i    (if (> (cadr l) (+ n i))
                      (cadr l)
                      (+ n i)
                      )
                      )
                ls
                )
               )
         (setq l (cdr l))
         )
           (reverse ls)
           )
    )
  )



(defun c:TTL ( / *error* ss p ls Y )

(setq *distance* (* 1.25 (getvar 'textsize))); default 

(defun *error* (msg) (vl-cmdf "_UNDO" "_END")(princ msg))
(vl-cmdf "_UNDO" "_BEGIN")

(initget 6)
(setq *distance* (cond ((getreal (strcat "\nLines X-distancing <"(rtos *distance* 2 2)"> : ")))(*distance*)))
(princ "\nSelect vertical LINES ")
(and
(setq ss (ssget '((0 . "LINE"))))
(setq p (getpoint "\nPick crank point "))
(setq p  (trans p 1 0)
      Y  (cadr p)
      ls (mapcar '(lambda (en)(cons (cdr(assoc 10 (entget en))) en)) (vl-remove-if 'listp (mapcar 'cadr (ssnamex ss)))))
(mapcar	'(lambda (en X / n l lst )
	   (setq en (cdr en)
	    	l  (vl-sort
	            (mapcar '(lambda (x) (cdr (assoc x (entget en)))) '(10 11))
	            '(lambda (a b) (> (cadr a) (cadr b)))
	            )
              n (cadadr l) 
	        lst (list (car l) (list (caar l) Y ) (list X (- Y (* (- Y n ) 0.1)) ) (list X n)))
	   (entdel en)
	   (entmakex
	    (vl-list*
	     '(0 . "LWPOLYLINE")
	     '(100 . "AcDbEntity")
	     '(100 . "AcDbPolyline")
	     '(70 . 0)
	     (cons 90 (length lst))
	     (mapcar '(lambda (x) (cons 10 x)) lst)
	     )
	    )
	   )
	(setq l2 (vl-sort ls '(lambda (a b) (< (caar a) (caar b)))))
	(++rarify (mapcar 'caar l2) *distance* )
	)
  )
(vl-cmdf "_UNDO" "_END")
  (princ)
)

  
