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


(defun mirror_4_times (figure)
  (command "зеркало"
	   figure ""
	   corpus_center
	   (list (+ (car corpus_center) 1) (cadr corpus_center))
	   ""
	   )
  (command "объединение" figure (entlast) "")
  (command "зеркало"
	   figure ""
	   corpus_center
	   (list (car corpus_center) (+ (cadr corpus_center) 1))
	   ""
	   )
  (command "объединение" figure (entlast) "")
  )


(defun corpus ()
  (setq corpus_center
	 (list (+ (car base_point) (/ corpus_length 2))
	       (+ (cadr base_point) (/ corpus_width 2))
	       (+ (caddr base_point) (/ corpus_height 2))
	       )
	)
  (command "прямоуг"
	   "с" corpus_round_radius
	   base_point
	   (list (+ (car base_point) corpus_length)
		 (+ (cadr base_point) corpus_width)
		 )
	   )
  (command "область" (entlast) "")
  (command "выдавить" (entlast) "" corpus_height)
  )


(defun legs ()
  (command "шар"
	   (list (+ (car base_point) corpus_round_radius)
		 (+ (cadr base_point) corpus_round_radius)
		 )
	   legs_radius
	   )
  (mirror_4_times (entlast))
  )


(defun antenna ()
  (setq body_axis_x1 (+ (car base_point) corpus_round_radius))
  (setq body_axis_x2 (+ body_axis_x1 (* antennas_width 2)))
  (setq body_axis_y (- (cadr base_point) antennas_width))
  (setq body_axis_z (- (caddr corpus_center) (/ antennas_width 2)))
  (setq pivot_center_x (+ body_axis_x1 antennas_width))
  (setq pivot_center_y (+ body_axis_y antennas_width))
  (setq pivot_center_z (caddr corpus_center))
  (command "эллипс"
	   (list body_axis_x1 body_axis_y body_axis_z)
	   (list body_axis_x2 body_axis_y)
	   (/ antennas_width 2)
	   )
  (command "область" (entlast) "")
  (command "выдавить" (entlast) "" antennas_length)
  (command "повернуть3d"
	   (entlast) ""
	   (list pivot_center_x 0 (+ body_axis_z (/ antennas_width 2)))
	   (list pivot_center_x 1 (+ body_axis_z (/ antennas_width 2)))
	   (- antennas_angle)
	   )
  (setq body (entlast))
  (command "цилиндр"
	   (list pivot_center_x pivot_center_y pivot_center_z)
	   (/ antennas_width 2)
	   antennas_width
	   )
  (command "повернуть3d"
	   (entlast) ""
	   (list 0 pivot_center_y pivot_center_z)
	   (list 1 pivot_center_y pivot_center_z)
	   90
	   )
  (command "объединение" body (entlast) "")
  )


(defun antennas ()
  (antenna)
  (mirror_4_times (entlast))
  )


(defun lan_port (k)
  (setq border_width (/ lan_port_length 10))
  (command "ящик"
	   (list (car base_point) (cadr corpus_center) (caddr corpus_center))
	   "Д" border_width
	   lan_port_length
	   lan_port_width
	   )
  (setq part_1 (entlast))
  (command "ящик"
	   (list (+ (car base_point) (/ border_width 2))
		 (+ (cadr corpus_center) (/ border_width 2))
		 (+ (caddr corpus_center) (* border_width 1.5))
		 )
	   "Д" (- lan_port_depth border_width)
	   (- lan_port_length border_width)
	   (/ lan_port_length 2)
	   )
  (setq part_2 (entlast))
  (command "ящик"
	   (list (+ (car base_point) border_width)
		 (+ (cadr corpus_center) (* border_width 2))
		 (caddr corpus_center)
		 )
	   "Д" (* border_width 3)
	   (* border_width 6)
	   (* border_width 1.5)
	   )
  (command "объединение" part_1 part_2 (entlast) "")
  (command "перенести"
	   (entlast) ""
	   "с" (list 0
		     (- (* lan_port_length 1.5 k) (/ lan_port_length 2))
		     (- (/ lan_port_width 2))
		     )
	   )
  )


(defun ports ()
  (command "цилиндр"
	   (list (car base_point) (cadr corpus_center) (caddr corpus_center))
	   round_port_radius
	   round_port_depth
	   )
  (command "повернуть3d"
	   (entlast) ""
	   (list (car base_point) 0 (caddr corpus_center))
	   (list (car base_point) 1 (caddr corpus_center))
	   90
	   )
  (setq round_port (entlast))
  (setq step 1)
  (repeat lan_port_count
    (setq step (* step (- 1)))
    (lan_port step)
    (command "объединение" round_port (entlast) "")
    (if (= step 1)
      (setq step (+ step 1))
      )
    ) 
  )


(defun c:router ()
  (setq osm (getvar "osmode")) 
  (setq base_point (input "Введите базовую точку фигуры" "point" '(0 0 0) null null))
  (setq corpus_length (input "Введите длину корпуса" "real" 180.0 10 600))
  (setq corpus_width (input "Введите ширину корпуса" "real" 300.0 30 800))
  (setq corpus_height (input "Введите высоту корпуса" "real" 40.0 20 70))
  (setq corpus_round_radius (input "Введите радиус скругления корпуса" "real" 25.0 0 50))
  (setq legs_radius (input "Введите радиус ножек" "real" 8.0 3 20))
  (setq antennas_length (input "Введите длину антенн" "real" 230.0 50 500))
  (setq antennas_width (input "Введите толщину антенн" "real" 10.0 5 20))
  (setq antennas_angle (input "Введите угол наклона антенн" "real" 20.0 0 70))
  (setq round_port_radius (input "Введите радиус круглого порта" "real" 3.5 1 10))
  (setq round_port_depth (input "Введите глубину круглого порта" "real" 15.0 5 30))
  (setq lan_port_length (input "Введите длину LAN-порта" "real" 20.0 10 40))
  (setq lan_port_width (input "Введите ширину LAN-порта" "real" 14.0 6 30))
  (setq lan_port_depth (input "Введите глубину LAN-порта" "real" 12.0 5 30))
  (setq lan_port_count (input "Введите количество LAN-портов" "int" 4 1 6))
  (corpus)
  (setq corpus_ (entlast))
  (ports)
  (command "вычитание" corpus_ "" (entlast) "")
  (legs)
  (antennas)
  (setvar "osmode" 0)
  )

