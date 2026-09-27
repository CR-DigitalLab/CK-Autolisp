;文字のX座標を揃える
(defun c:XS ( / );ss1 p1 p2 p3 l1 cnt num et)
	(princ "¥n文字のX座標を揃える")
	(setq ss1(ssget (list (cons 0 "TEXT"))))
	(setq p1 (getpoint"¥n基点を指示:"))
	(setq cnt 0)
        (setq num (sslength ss1))
	(command "undo" "be")
	(while (< cnt num)
                  (setq l1(ssname ss1 cnt))
                  (setq et(entget l1))
		(if 
		(and 
		(= 0 (cdr (assoc 72 et)))
		(= 0 (cdr (assoc 73 et)))
		)
		  (setq p2 (cdr(assoc 10 et)))		;選択文字の基点
		  (setq p2 (cdr(assoc 11 et)))
		);if
		(setq p3 (cons (car p1)(cdr p2)))	;変更後の文字基点
		  
		  (command "move" l1 "" "non" p2 "non" p3)

;		　(setq et (subst (cons 10 p3) (assoc 10 et) et ))
;		  (entmod et)
                  (setq cnt(1+ cnt))
           )
	(command "undo" "e")
           (princ)
)
