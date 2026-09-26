(defun input (prompt_ type_ default min_ max_)
  (setq flag T)
  (if (= type_ "point")
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
      ((= type_ "point")
       (setq value (getpoint prompt_))
      )
      ((= type_ "real")
       (setq value (getreal prompt_))
      )
      ((= type_ "int")
       (setq value (getint prompt_))
      )
    )
    (if	(null value)
      (progn
	(setq value default)
	(setq flag nil)
      )
      (progn
	(setq flag (and	(/= type_ "point")
			(or (> value max_) (< value min_))
		   )
	)
	(if flag
	  (prompt (strcat "Значение должно быть в интервале от "
			  (rtos min_)
			  " до "
			  (rtos max_)
			  ". Попробуйте ещё раз.\n"
		  )
	  )
	)
      )
    )
    (setq value value)
  )
)


(defun corpus ()
  (command "прямоуг"
	   "с" corpus_round_radius
	   base_point
	   (list (+ (car base_point) corpus_width)
		 (+ (cadr base_point) corpus_length)
		 )
	   )
  (command "область" (entlast) "")
  (command "выдавить" (entlast) "" corpus_height)
  )


(defun cable ()
  (command "цилиндр"
	   (list (+ (car base_point) (/ corpus_width 2)) (cadr base_point) (+ (caddr base_point) (/ corpus_height 2)))
	   (+ cable_radius 3)
	   3
	   )
  (setq cable_ (entlast))
  (command "цилиндр"
	   (list (+ (car base_point) (/ corpus_width 2)) (cadr base_point) (+ (caddr base_point) (/ corpus_height 2)))
	   cable_radius
	   cable_length
	   )
  (command "объединение" (entlast) cable_ "")
  (command "повернуть3d"
	   (entlast) ""
	   (list 0 (cadr base_point) (+ (caddr base_point) (/ corpus_height 2)))
	   (list 1 (cadr base_point) (+ (caddr base_point) (/ corpus_height 2)))
	   90
	   )
  )


(defun plug (k)
  (setq y_coord (+ (cadr base_point) (- corpus_length (* (+ (* socket_radius 2) socket_distance) k)) socket_radius))
  (command "цилиндр"
	   (list (+ (car base_point) (/ corpus_width 2)) y_coord (+ (caddr base_point) corpus_height))
	   socket_radius
	   socket_depth
	   )
  (setq plug_ (entlast))
  (command "цилиндр"
	   (list (+ (car base_point) (/ corpus_width 2)) (+ y_coord (* socket_radius 0.6)) (+ (caddr base_point) corpus_height socket_depth))
	   (/ socket_radius 7)
	   pins_length
	   )
  (setq pin (entlast))
  (command "зеркало"
	   pin ""
	   (list 0 y_coord 0)
	   (list 1 y_coord 0)
	   ""
	   )
  (command "объединение" plug_ pin (entlast) "")
  (command "повернуть"
	   (entlast) ""
	   (list (+ (car base_point) (/ corpus_width 2)) y_coord 0)
	   socket_angle
	   )
  (command "повернуть3d"
	   (entlast) ""
	   (list 0 y_coord (+ (caddr base_point) corpus_height))
	   (list 1 y_coord (+ (caddr base_point) corpus_height))
	   180
	   )
  )


(defun sockets ()
  (setq step 1)
  (repeat socket_count
    (plug step)
    (setq step (+ step 1))
    (command "вычитание" corpus_ "" (entlast) "")
    ) 
  )


(defun switcher ()
  (command "ящик"
	   (list (+ (car base_point) (/ (- corpus_width switch_length 4) 2)) (+ (cadr base_point) socket_distance (- 2)) (+ (caddr base_point) corpus_height))
	   "д"
	   (+ switch_length 4)
	   (+ switch_width 4)
	   2
	   )
  (command "ящик"
	   (list (+ (car base_point) (/ (- corpus_width switch_length) 2)) (+ (cadr base_point) socket_distance) (+ (caddr base_point) corpus_height (- switch_height)))
	   "д"
	   switch_length
	   switch_width
	   (* switch_height 2)
	   )
  (command "повернуть3d"
	   (entlast) ""
	   (list (+ (car base_point) (/ corpus_width 2)) 0 (+ (caddr base_point) corpus_height))
	   (list (+ (car base_point) (/ corpus_width 2)) 1 (+ (caddr base_point) corpus_height))
	   switch_angle
	   )
  )


(defun c:extender ()
  (setq osm (getvar "osmode"))
  (setvar "osmode" 0)
  
  (setq base_point (input "Введите базовую точку фигуры" "point" '(0 0 0) null null))
  (setq cable_length (input "Введите длину фрагмента кабеля" "real" 60.0 30 150))
  (setq cable_radius (input "Введите радиус кабеля" "real" 3.0 1.5 5))
  (setq corpus_height (input "Введите высоту удлинителя" "real" 35.0 8 80))
  (setq socket_radius (input "Введите радиус розеток" "real" 21.0 10 30))
  (setq socket_distance (input "Введите расстояние между розетками" "real" 10.0 3 15))
  (setq socket_depth (input "Введите глубину розеток" "real" 10.0 5 20))
  (setq pins_length (input "Введите длину контактов" "real" 15.0 5 20))
  (setq socket_angle (input "Введите угол поворота розеток" "real" 45.0 (- 90) 90))
  (setq corpus_round_radius (input "Введите радиус скругления корпуса" "real" 15.0 0 30))
  (setq switch_length (input "Введите длину выключателя" "real" 30.0 15 60))
  (setq switch_width (input "Введите ширину выключателя" "real" 15.0 7 30))
  (setq switch_height (input "Введите высоту рычага выключателя" "real" 7.0 3 10))
  (setq switch_angle (input "Введите угол наклона рычага выключателя" "real" 15.0 (- 20) 20))
  (setq socket_count (input "Введите количество розеток" "int" 4 2 10))

  (setq corpus_width (* (+ socket_radius socket_distance) 2))
  (setq corpus_length (+ (* (+ (* socket_radius 2) socket_distance) socket_count) switch_width (* socket_distance 2)))

  (corpus)
  (setq corpus_ (entlast))
  (sockets)
  (cable)
  (switcher)
  
  (setvar "osmode" osm)
  )
