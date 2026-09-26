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
	(setq vvod defolt
	      flag nil)
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


(defun podstavka ()
  (setq	podstavka_c (korrektniy_vvod
	   "p"
	   "Vvedite tsentr podstavki lampy"
	   '(0 0 0)
	   nil
	   nil
	  )
  
   	podstavka_r (korrektniy_vvod
	   "r"
	   "Vvedite radius podstavki lampy"
	   35
	   25
	   50
	  )
  
  	podstavka_h (korrektniy_vvod
	   "r"
	   "Vvedite vysotu podstavki lampy"
	   5
	   2
	   7
	  )
  
  	knopka_k (korrektniy_vvod
		   "i"
		   "Vvedite kolichestvo knopok na podstavke"
		   3
		   1
		   5
		  )
  
  	knopka_r (korrektniy_vvod
		   "r"
		   "Vvedite radius knopki na podstavke"
		   3
		   1
		   5
		  )
  
  	knopka_h (korrektniy_vvod
		   "r"
		   "Vvedite vysotu knopki na podstavke"
		   1
		   1
		   3
		  )
  )

  (setq x (car podstavka_c)
        y (cadr podstavka_c)
        z (caddr podstavka_c)
  )
  (command "_cylinder" podstavka_c podstavka_r podstavka_h)
  (command "_cylinder"
	   (list (- x (* knopka_r (- knopka_k 1)))
		 y
		 (+ z podstavka_h)
	   )
	   knopka_r
	   knopka_h
  )
  (setq knopka (entlast))
  (setq i 2)
  (repeat (- knopka_k 1)
    (command "_copy"
	     knopka
	     ""
	     (list (* knopka_r i) 0 0)
	     ""
	     )
    (setq i (+ i 2))
  )
)


(defun treugolnaya_prizma (tochka_pryamogo_ugla l h w)
  (setq x (car tochka_pryamogo_ugla)
        y (cadr tochka_pryamogo_ugla)
        z (caddr tochka_pryamogo_ugla)
  )
  
  (command "_pline"
	   tochka_pryamogo_ugla
	   (list (+ x h) y z)
	   (list x (- y l) z)
	   "З"
  )
  (command "_region" (entlast) "")
  (command "_extrude" (entlast) "" w)
  (command "_ucs" "X" 90)
  (command "_rotate"
	   (entlast)
	   ""
	   (list x z (- y))
	   90
  )
  (command "_ucs" "X" -90)
  (command "_move"
	   (entlast)
	   ""
	   (list (/ w 2) 0 0)
	   ""
  )
)


(defun nozhka ()
  (setq	nozhka_h
	 (korrektniy_vvod
	   "r"
	   "Vvedite vysotu nozhki lampy"
	   150
	   80
	   250
	   )
  	nozhka_w
	 (korrektniy_vvod
	   "r"
	   "Vvedite shirinu nozhki lampy"
	   (* podstavka_r 0.35)
	   5
	   100
	 )
  	nozhka_l
	 (korrektniy_vvod
	   "r"
	   "Vvedite tolshchinu nozhki lampy"
	   (* podstavka_r 0.15)
	   3
	   70
	 )
 	krepleniye_h
	 (korrektniy_vvod
	   "r"
	   "Vvedite dlinu verkhnego krepleniya lampy"
	   (* nozhka_h 0.66)
	   50
	   170
	  )
  	krepleniye_l
	 (korrektniy_vvod
	   "r"
	   "Vvedite tolshchinu verkhnego krepleniya lampy"
	   nozhka_l
	   (* nozhka_l 0.3)
	   (* nozhka_l 1.5)
	 )
  )

  (treugolnaya_prizma
    (list (car podstavka_c)
	  (+ (cadr podstavka_c) podstavka_r)
	  (+ (caddr podstavka_c) (/ podstavka_h 2))
    )
    nozhka_l
    nozhka_h
    nozhka_w
  )
  (treugolnaya_prizma
    (list (car podstavka_c)
	  (+ (cadr podstavka_c) podstavka_r)
	  (+ (caddr podstavka_c) (/ podstavka_h 2) nozhka_h)
    )
    krepleniye_l
    krepleniye_h
    nozhka_w
  )
  (command "_ucs" "Y" -90)
  (command
    "_rotate"
    (entlast)
    ""
    (list (+ (caddr podstavka_c) (/ podstavka_h 2) nozhka_h)
	  (+ (cadr podstavka_c) podstavka_r)
	  (- (car podstavka_c))
    )
    -90
  )
  (command "_ucs" "Y" 90)
)


(defun pustaya_polusfera (c r r_)
  (command "_sphere" c r)
  (setq obj1 (entlast))
  (command "_sphere" c r_)
  (setq obj2 (entlast))
  (command "_box"
	   (list (- (car c) r) (- (cadr c) r) (caddr c))
	   (list (+ (car c) r) (+ (cadr c) r) (- (caddr c) r))
	   (* r 2)
  )
  (setq obj3 (entlast))
  (command "_subtract" obj1 "" obj2 obj3 "")
)


(defun neposredstvenno_lampa ()
  (setq	sharnir_r
	 (korrektniy_vvod
	   "r" "Vvedite radius sharnira" 4 2 30)
  )
  (setq	polusfera_r
	 (korrektniy_vvod
	   "r" "Vvedite radius polusfery" 50 20	100)
  )
  (setq	lampa_r
	 (korrektniy_vvod
	   "r" "Vvedite radius lampy" 15 5 50)
  )
  (setq	polusfera_a
	 (korrektniy_vvod
	   "r" "Vvedite ugol naklona lampy" 45 0 135)
  )

  (pustaya_polusfera
    (list (car podstavka_c)
	  (- (+ (cadr podstavka_c) podstavka_r)
	     (+ krepleniye_h sharnir_r)
	  )
	  (- (+ (caddr podstavka_c) (/ podstavka_h 2) nozhka_h)
	     (+ polusfera_r (/ sharnir_r 4))
	  )
    )
    polusfera_r
    (- polusfera_r 5)
  )
  (setq obj1 (entlast))
  (command "_sphere"
	   (list (car podstavka_c)
		 (- (+ (cadr podstavka_c) podstavka_r)
		    (+ krepleniye_h sharnir_r)
		 )
		 (- (+ (caddr podstavka_c) (/ podstavka_h 2) nozhka_h)
		    (- (+ polusfera_r (/ sharnir_r 4)) lampa_r)
		 )
	   )
	   lampa_r
  )
  (setq obj2 (entlast))
  (command "_cylinder"
	   (list (car podstavka_c)
		 (- (+ (cadr podstavka_c) podstavka_r)
		    (+ krepleniye_h sharnir_r)
		 )
		 (- (+ (caddr podstavka_c) (/ podstavka_h 2) nozhka_h)
		    (- (+ polusfera_r (/ sharnir_r 4)) lampa_r)
		 )
	   )
	   (* lampa_r 0.75)
	   (- (- polusfera_r 5) lampa_r)
  )
  (setq obj3 (entlast))
  (command "_union" obj1 obj2 obj3 "")
  (command "_ucs" "Y" -90)
  (command "_rotate"
	   (entlast)
	   ""
	   (list (+ (caddr podstavka_c) (/ podstavka_h 2) nozhka_h)
		 (- (+ (cadr podstavka_c) podstavka_r)
		    (+ krepleniye_h sharnir_r)
		 )
		 (- (car podstavka_c))
	   )
	   polusfera_a
  )
  (command "_cylinder"
	   (list (+ (caddr podstavka_c) (/ podstavka_h 2) nozhka_h)
		 (- (+ (cadr podstavka_c) podstavka_r)
		    (+ krepleniye_h sharnir_r)
		 )
		 (- (+ (car podstavka_c) (/ nozhka_w 2)))
	   )
	   sharnir_r
	   nozhka_w
  )
  (command "_ucs" "Y" 90)

)


(defun c:lampa ()
  (setq osm (getvar "osmode"))
  (podstavka)
  (nozhka)
  (neposredstvenno_lampa)
  (setvar "osmode" 0)
)



