(defun korrektniy_vvod (tip priglasheniye defolt minimum maksimum)
  (setq flag T)
  (if (= tip "p")
    (setq priglasheniye
	   (strcat priglasheniye
		   " ("
		   (rtos (car defolt))
		   ","
		   (rtos (cadr defolt))
		   ","
		   (rtos (caddr defolt))
		   "): "
	   )
    )
    (setq priglasheniye (strcat priglasheniye " (" (rtos defolt) "): "))
  )
  (while flag
    (cond
      ((= tip "p")
       (setq vvod (getpoint priglasheniye))
      )
      ((= tip "r")
       (setq vvod (getreal priglasheniye))
      )
      ((= tip "i")
       (setq vvod (getint priglasheniye))
      )
    )
    (if	(null vvod)
      (progn
	(setq vvod defolt)
	(setq flag nil)
      )
      (progn
	(setq flag (and	(/= tip "p")
			(or (> vvod maksimum) (< vvod minimum))
		   )
	)
	(if flag
	  (prompt (strcat "Znachenie dolzhno byt mezhdu "
			  (rtos minimum)
			  " i "
			  (rtos maksimum)
			  ". Poprobuyte snova.\n"
		  )
	  )
	)
      )
    )
    (setq vvod vvod)
  )
)


(defun treugolnaya_prizma_s_pryamym_uglom (tochka_pryamogo_ugla
					   menshiy_katet_osnovaniya
					   bolshiy_katet_osnovaniya
					   h
					  )
  (command "_pline"
	   tochka_pryamogo_ugla
	   (list (car tochka_pryamogo_ugla)
		 (+ (cadr tochka_pryamogo_ugla) bolshiy_katet_osnovaniya)
		 (caddr tochka_pryamogo_ugla)
	   )
	   (list (+ (car tochka_pryamogo_ugla) menshiy_katet_osnovaniya)
		 (cadr tochka_pryamogo_ugla)
		 (caddr tochka_pryamogo_ugla)
	   )
	   "З"
  )
  (command "_region"
	   (entlast)
	   ""
  )
  (command "_extrude"
	   (entlast)
	   ""
	   h
  )
)


(defun polusfera (c r)
  (command "_sphere" c r)
  (setq obj1 (entlast))
  (command "_box"
	   (list (- (car c) r) (cadr c) (- (caddr c) r))
	   (list (+ (car c) r) (- (cadr c) r) (+ (caddr c) r))
	   (* r 2)
  )
  (setq obj2 (entlast))
  (command "_subtract" obj1 "" obj2 "")
)


(defun nozhka (x y z r h)
  (command "_cylinder" (list x y z) r (- h r))
  (setq obj1 (entlast))
  (command "_sphere" (list x y z) r)
  (setq obj2 (entlast))
  (command "_union" obj1 obj2 "")
  (command "_ucs" "Y" -90)
  (command "_rotate" (entlast) "" (list (- z) y x) 90)
  (command "_ucs" "Y" 90)
  (command "_move"
	   (entlast)
	   ""
	   (list 0 (- (- h r)) 0)
	   ""
  )
)


(defun strelka (tochka_vrashcheniya w)
  (command "_box" "Ц" tochka_vrashcheniya "Д" 4 (* w 0.9) 3)
  (setq obj1 (entlast))
  (command "_move"
	   obj1
	   ""
	   (list 0 (* w 0.45) 1.5)
	   ""
  )
  (treugolnaya_prizma_s_pryamym_uglom
    (list (car tochka_vrashcheniya)
	  (+ (cadr tochka_vrashcheniya) (* w 0.9))
	  (caddr tochka_vrashcheniya)
    )
    2
    (* w 0.1)
    3
  )
  (setq obj2 (entlast))
  (command "_mirror"
	   (entlast)
	   ""
	   (list (car tsiferblat_c) (cadr tsiferblat_c))
	   (list (car tsiferblat_c) (+ (cadr tsiferblat_c) 1))
	   ""
  )
  (setq obj3 (entlast))
  (command "_union" obj1 obj2 obj3 "")
)


(defun rychag (osnovaniye_c h)
  (command "_box" "Ц" osnovaniye_c "Д" 4 h 3)
  (setq obj1 (entlast))
  (command "_move" obj1 "" (list 0 (/ h 2) 0) "")
  (command "_ucs" "Y" -90)
  (command "_cylinder"
	   (list (caddr osnovaniye_c)
		 (+ (cadr osnovaniye_c) h)
		 (- (car osnovaniye_c))
	   )
	   1.5
	   25
  )
  (setq obj2 (entlast))
  (command "_ucs" "Y" 90)
  (command "_move" obj2 "" '(12.5 0 0) "")
  (command "_sphere"
	   (list (- (car osnovaniye_c) 12.5)
		 (+ (cadr osnovaniye_c) h)
		 (caddr osnovaniye_c)
	   )
	   1.5
  )
  (setq obj3 (entlast))
  (command "_sphere"
	   (list (+ (car osnovaniye_c) 12.5)
		 (+ (cadr osnovaniye_c) h)
		 (caddr osnovaniye_c)
	   )
	   1.5
  )
  (setq obj4 (entlast))
  (command "_union" obj1 obj2 obj3 obj4 "")
)


(defun korpus ()
  (setq	korpus_c (korrektniy_vvod
		   "p"
		   "Vvedite tochku tsentra korpusa budilnika"
		   '(0 0 0)
		   nil
		   nil
		  )
  )
  (setq	korpus_r (korrektniy_vvod
		   "r"
		   "Vvedite radius korpusa budilnika"
		   75			  30
		   1500
		  )
  )
  (setq	korpus_h (korrektniy_vvod
		   "r"
		   "Vvedite tolshchinu korpusa budilnika"
		   30			     5
		   1000
		  )
  )

  (command "_cylinder"
	   korpus_c
	   korpus_r
	   korpus_h
  )
  (command "_move"
	   (entlast)
	   ""
	   (list 0 0 (- (/ korpus_h 2)))
	   ""
  )
)


(defun tsiferblat ()
  (setq	serdtsevina_r
	 (korrektniy_vvod
	   "r"
	   "Vvedite radius serdtseviny tsiferblata"
	   6			      1
	   70
	  )
  )
  (setq	deleniya_k
	 (korrektniy_vvod
	   "i"
	   "Vvedite kolichestvo deleniy tsiferblata"
	   4			      2
	   12
	  )
  )

  (setq	tsiferblat_c
	 (list (car korpus_c)
	       (cadr korpus_c)
	       (+ (caddr korpus_c) (/ korpus_h 2))
	 )
  )
  (command "_sphere"
	   tsiferblat_c
	   serdtsevina_r
  )
  (command "_box"
	   (list (- (car tsiferblat_c) 2)
		 (- (+ (cadr tsiferblat_c) korpus_r) 13)
		 (caddr tsiferblat_c)
	   )
	   (list (+ (car tsiferblat_c) 2)
		 (+ (cadr tsiferblat_c) korpus_r)
		 (caddr tsiferblat_c)
	   )
	   3
  )
  (setq deleniye (entlast))
  (command "_line"
	   tsiferblat_c
	   (list (car tsiferblat_c)
		 (+ (cadr tsiferblat_c) korpus_r)
		 (caddr tsiferblat_c)
	   )
	   ""
  )
  (setq liniya_deleniya (entlast))
  (setq gradus_povorota (/ 360 deleniya_k))
  (repeat (- deleniya_k 1)
    (command "_copy" deleniye "" '(0 0 0) "")
    (setq deleniye (entlast))
    (command "_copy" liniya_deleniya "" '(0 0 0) "")
    (setq liniya_deleniya (entlast))
    (command "_rotate"	      deleniye	       liniya_deleniya
	     ""		      tsiferblat_c     gradus_povorota
	    )
  )
)


(defun strelki ()
  (setq	strelki_k (korrektniy_vvod
		    "i"
		    "Vvedite kolichestvo strelok tsiferblata"
		    2
		    1
		    5
		   )
  )
  (setq	strelka_w (korrektniy_vvod
		    "r"
		    "Vvedite dlinu minutnoy strelki tsiferblata"
		    60
		    15
		    1485
		   )
  )
  (setq gradus_povorota (/ 360 (max (/ deleniya_k 4) strelki_k)))
  (setq i 0)
  (repeat strelki_k
    (strelka tsiferblat_c strelka_w)
    (command "_rotate"
	     (entlast)
	     ""
	     tsiferblat_c
	     (* gradus_povorota i)
    )
    (setq strelka_w (* strelka_w 0.75))
    (setq i (+ i 1))
  )
)


(defun nozhki ()
  (setq	nozhka_r (korrektniy_vvod
		   "r"
		   "Vvedite radius nozhki budilnika"
		   4			  0.5
		   10
		  )
  )
  (setq	nozhka_h (korrektniy_vvod
		   "r"
		   "Vvedite dlinu nozhki budilnika"
		   40			 20
		   60
		  )
  )
  (nozhka (car korpus_c)
	  (- (cadr korpus_c) korpus_r)
	  (caddr korpus_c)
	  nozhka_r
	  nozhka_h
  )
  (setq nozhka_ (entlast))
  (command "_rotate"
	   (entlast)
	   ""
	   tsiferblat_c
	   30
  )
  (command "_mirror"
	   (entlast)
	   ""
	   (list (car korpus_c) (cadr korpus_c))
	   (list (car korpus_c) (+ (cadr korpus_c) 1))
	   ""
  )
  (nozhka (car korpus_c)
	  (- (cadr korpus_c) korpus_r)
	  (caddr korpus_c)
	  nozhka_r
	  (* nozhka_h 2)
  )
  (command "_move"
	   (entlast)
	   ""
	   (list 0 (+ nozhka_h nozhka_r) 0)
	   ""
  )
  (command "_ucs" "Y" -90)
  (command "_rotate"
	   (entlast)
	   ""
	   (list (- (caddr korpus_c))
		 (- (cadr korpus_c) (- korpus_r (+ nozhka_h nozhka_r)))
		 (car korpus_c)
	   )
	   -45
  )
  (command "_ucs" "Y" 90)
)


(defun zvonki ()
  (setq	zvonki_k (korrektniy_vvod
		   "i"
		   "Vvedite kolichestvo zvonkov budilnika"
		   2			     1
		   2
		  )
  )
  (setq	zvonki_r (korrektniy_vvod
		   "r"
		   "Vvedite radius zvonkov budilnika"
		   30			  3
		   70
		  )
  )
  (setq	rychagi_k (korrektniy_vvod
		    "i"
		    "Vvedite kolichestvo rychagov budilnika"
		    1
		    1
		    3
		   )
  )
  (setq	rychagi_h (korrektniy_vvod
		    "r"
		    "Vvedite vysotu rychagov budilnika"
		    13			    5
		    35
		   )
  )
  (polusfera (list (car korpus_c)
		   (+ (cadr korpus_c) korpus_r)
		   (caddr korpus_c)
	     )
	     zvonki_r
  )
  (command "_rotate"
	   (entlast)
	   ""
	   korpus_c
	   -30
  )
  (if (= zvonki_k 2)
    (command "_mirror"
	   (entlast)
	   ""
	   (list (car korpus_c) (cadr korpus_c))
	   (list (car korpus_c) (+ (cadr korpus_c) 1))
	   ""
    )
  )
  (rychag (list	(car korpus_c)
		(+ (cadr korpus_c) korpus_r)
		(caddr korpus_c)
	  )
	  rychagi_h
  )
  (setq rychag_ (entlast))
  (if (>= rychagi_k 2)
    (command "_copy" rychag_ "" '(0 0 5) "")
  )
  (if (= rychagi_k 3)
    (command "_copy" rychag_ "" '(0 0 -5) "")
  )
)


(defun c:budilnik ()
  (setq osm (getvar "osmode"))
  (korpus)
  (tsiferblat)
  (strelki)
  (nozhki)
  (zvonki)
  (setvar "osmode" 0)
)
