(defun _carcass (p l w h corner_r)
  (command "отрезок"
	   p
	   (list (car p) (cadr p) (+ (caddr p) h))
	   ""
	   )
  (setq obj1 (entlast))
  (command "отрезок"
	   (list (car p) (cadr p) (+ (caddr p) h))
	   (list (car p) (+ (cadr p) w) (+ (caddr p) h))
	   ""
	   )
  (setq obj2 (entlast))
  (command "сопряжение" "д" corner_r "\e")
  (command "сопряжение" obj1 obj2)
  (setq obj3 (entlast))
  (command "3dплиния"
	   (list (car p) (+ (cadr p) w) (+ (caddr p) h))
           (list (car p) (+ (cadr p) w) (caddr p))
	   p
	   ""
	   )
  (command "область" obj1 obj2 obj3 (entlast) "")
  (command "выдавить" (entlast) "" l)
  )


(defun _semicircle (c r w h)
  (command "дуга"
	   (list (- (car c) r) (cadr c) (caddr c))
	   (list (car c) (- (cadr c) r) (caddr c))
           (list (+ (car c) r) (cadr c) (caddr c))
	   )
  (setq obj1 (entlast))
  (command "отрезок"
	   (list (- (car c) r) (cadr c) (caddr c))
           (list (+ (car c) r) (cadr c) (caddr c))
	   ""
	   )
  (setq obj2 (entlast))
  (command "область" obj1 obj2 "")
  (setq greater (entlast))

  (command "дуга"
	   (list (+ (car c) (- r) w) (cadr c) (caddr c))
	   (list (car c) (+ (cadr c) (- r) w) (caddr c))
           (list (+ (car c) r (- w)) (cadr c) (caddr c))
	   )
  (setq obj1 (entlast))
  (command "отрезок"
	   (list (+ (car c) (- r) w) (cadr c) (caddr c))
           (list (+ (car c) r (- w)) (cadr c) (caddr c))
           ""
	   )
  (setq obj2 (entlast))
  (command "область" obj1 obj2 "")
  (setq less (entlast))

  (command "вычитание" greater "" less "")
  (command "выдавить" (entlast) "" h)
  (setq obj1 (entlast))
  )


(defun semicircles ()
  (setq p (list (+ (car base_p) (/ main_l 2)) (+ (cadr base_p) main_w) (caddr base_p)))
  (_semicircle (list (- (car p) central_semicircle_r) (cadr p) (caddr p)) side_semicircle_r border_w main_h)
  (setq left (entlast))
  (_semicircle p central_semicircle_r border_w central_semicircle_h)
  (setq central (entlast))
  (command "объединение" left central "")
  (setq semicircles_ (entlast))
  
  (command "круг" p (- central_semicircle_r border_w))
  (command "область" (entlast) "")
  (command "выдавить" (entlast) "" main_h)
  
  (command "вычитание" semicircles_ "" (entlast) "")
  (setq obj1 (entlast))
  (command "ящик"
           (list (- (car p) central_semicircle_r) (cadr p) (+ (caddr p) main_h))
	   "д"
	   central_semicircle_r
	   (- border_w)
	   (- central_semicircle_h main_h)
	   )
  (setq obj2 (entlast))
  (command "объединение" obj1 obj2 "")
  )


(defun corpus ()
  (_carcass base_p (/ main_l 2) main_w main_h corner_r)
  (setq carcass (entlast))

  (setq i (+ internal_border_c 2)
        a (- side_segment_w (* border_w 2))
	b (- (/ main_w i) border_w)
	)
  (while (> i 0)
    (setq i (- i 1))
    (command "ящик"
	     (list (+ (car base_p) border_w) (+ (cadr base_p) (* (+ b border_w) i)) (+ (caddr base_p) border_w))
             "д"
	     a
             b
             main_h
	     )
    (command "вычитание" carcass "" (entlast) "")
    )

  (command "ящик"
	   (list (+ (car base_p) side_segment_w) (cadr base_p) (+ (caddr base_p) border_w))
           "д"
	   main_l
	   (- main_w border_w)
	   main_h
	   )
  (setq obj1 (entlast))
  (command "ящик"
	   (list (+ (car base_p) border_w) (cadr base_p) (+ (caddr base_p) border_w))
           "д"
	   main_l
	   b
	   main_h
	   )
  (setq obj2 (entlast))
  
  (command "вычитание" carcass "" obj1 obj2 "")
  )


(defun input (type_ prompt_ default min_ max_)
  (setq flag T)
  (if (= type_ "p")
    (setq prompt_
	   (strcat prompt_
		   " ("
		   (rtos (car default))
		   ","
		   (rtos (cadr default))
		   ","
		   (rtos (caddr default))
		   "): "
	   )
    )
    (setq prompt_ (strcat prompt_ " (" (rtos default) "): "))
  )
  (while flag
    (cond
      ((= type_ "p")
       (setq inp (getpoint prompt_))
      )
      ((= type_ "r")
       (setq inp (getreal prompt_))
      )
      ((= type_ "i")
       (setq inp (getint prompt_))
      )
    )
    (if	(null inp)
      (progn
	(setq inp  default
	      flag nil
	)
      )
      (progn
	(setq flag (and	(/= type_ "p")
			(or (> inp max_) (< inp min_))
		   )
	)
	(if flag
	  (prompt (strcat "Значение должно быть между "
			  (rtos min_)
			  " и "
			  (rtos max_)
			  ". Попробуйте снова.\n"
		  )
	  )
	)
      )
    )
    (setq inp inp)
  )
)


(defun c:organizer ()
  (setq base_p (input "p" "Введите базовую точку" '(0 0 0) nil nil)
	border_w (input "r" "Введите толщину стенок" 1 0.1 5)
        main_l (input "r" "Введите длину платформы" 100 50 300)
	main_w (input "r" "Введите ширину платформы" 60 30 150)
	main_h (input "r" "Введите высоту боковых сегментов" 30 10 70)
	side_segment_w (input "r" "Введите ширину боковых сегментов" 15 5 40)
	corner_r (input "r" "Введите радиус скругления углов стенок боковых сегментов" 15 0 40)
	central_semicircle_r (input "r" "Введите радиус центрального полукруга" 20 5 60)
	central_semicircle_h (input "r" "Введите высоту центрального полукруга" 40 main_h 60)
	side_semicircle_r (input "r" "Введите радиус боковых полукругов" 15 5 central_semicircle_r)
	internal_border_c (input "i" "Введите число стенок внутри боковых сегментов" 2 0 10)
	)
  
  (corpus)
  (setq obj1_ (entlast))
  (semicircles)
  (setq obj2_ (entlast))
  (command "объединение" obj1_ obj2_ "")
  (setq obj1 (entlast))
  (command "зеркало"
	   (entlast)
	   ""
	   (list (+ (car base_p) (/ main_l 2)) 0 0)
	   (list (+ (car base_p) (/ main_l 2)) 1 0)
	   ""
	   )
  (setq obj2 (entlast))
  (command "объединение" obj1 obj2 "")
  )
