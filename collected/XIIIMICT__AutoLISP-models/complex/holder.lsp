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



(defun rounded_border_section ()
  (command "дуга"
	   (list secondary_round_rad h)
	   "Ц"
	   (list secondary_round_rad (- h secondary_round_rad))
	   (list 0 (- h secondary_round_rad))
	   )
  (setq arc (entlast))
  (command "плиния"
	   (list 0 (- h secondary_round_rad))
	   '(0 0)
	   (list secondary_round_rad 0)
	   (list secondary_round_rad h)
	   ""
	   )
  (command "область" arc (entlast) "")
  (command "повернуть3d"
	   (entlast)
	   ""
	   "X"
	   '(0 0)
	   90
	   )
  )


(defun quater_rounded_border ()
  (rounded_border_section)
  (command "выдавить" (entlast) "" (- main_round_rad (/ w 2)))
  (command "перенести" (entlast) "" '(0 0) (list 0 main_round_rad))
  (setq part_w (entlast))
    
  (rounded_border_section)
  (command "повернуть3d"
	   (entlast)
	   ""
	   "Z"
	   '(0 0)
	   90
	   )
  (command "выдавить" (entlast) "" (- (/ l 2) main_round_rad))
  (command "перенести" (entlast) "" '(0 0) (list main_round_rad 0))
  (setq part_l (entlast))

  (rounded_border_section)
  (command "перенести" (entlast) "" '(0 0) (list 0 main_round_rad))
  (command "вращать"
	   (entlast)
	   ""
	   (list main_round_rad main_round_rad 0)
	   (list main_round_rad main_round_rad 1)
	   90
	   )
  (setq corner (entlast))
  
  (command "объединение" part_w corner part_l "")
  )



(defun platform ()
  (command "прямоуг"
	   "С"
	   secondary_round_rad
	   (list secondary_round_rad secondary_round_rad)
	   (list (- l secondary_round_rad) (- w secondary_round_rad))
	   )
  (command "область" (entlast) "")
  (command "выдавить" (entlast) "" h)
  (setq middle_part (entlast))
  
  (quater_rounded_border)
  (setq quater_rounded_border_ (entlast))
  (command "зеркало" quater_rounded_border_ ""
	   (list (/ l 2) 0)
	   (list (/ l 2) 1)
	   "Н"
	   )
  (command "объединение" quater_rounded_border_ (entlast) "")
  (command "зеркало" (entlast) ""
	   (list 0 (/ w 2))
	   (list 1 (/ w 2))
	   "Н"
	   )
  (command "объединение" middle_part quater_rounded_border_ (entlast) "")
  )



(defun cut_gutter (platform_)
  (command "цилиндр" '(0 0) gutter_rad w)
  (command "повернуть3d"
	   (entlast)
	   ""
	   "X"
	   '(0 0)
	   -90
	   )
  (command "перенести"
	   (entlast)
	   ""
	   '(0 0 0)
	   (list (+ secondary_round_rad gutter_rad)
		 0
		 h
		 )
	   )
  (command "вычитание" platform_ "" (entlast) "")
  )



(defun cut_slots_and_install_log (platform_)
  (setq step 1)
  (repeat slot_с
    (command "цилиндр"
	   (list (* (/ l (+ slot_с 1)) step)
		 (/ w 2)
		 (- h slot_depth)
		 )
	   log_rad
	   log_h
	   )
    (if (/= step 2)
      (command "вычитание" platform_ "" (entlast) "")
      )
    (setq step (+ step 1))
    ) 
  )



(defun c:holder ()
  (setq osm (getvar "osmode"))
  (setvar "osmode" 0)

  (setq base_pt (input "Введите базовую точку" "point" '(0 0 0) null null))
  (setq l (input "Введите длину платформы" "real" 120.0 50.0 300.0))
  (setq w (input "Введите ширину платформы" "real" 60.0 25.0 150.0))
  (setq h (input "Введите высоту платформы" "real" 15.0 8.0 30.0))
  (setq main_round_rad (input "Введите радиус скругления боковых углов платформы" "real" 10.0 0.0 20.0))
  (setq secondary_round_rad (input "Введите радиус скругления верхних углов платформы" "real" 5.0 0.0 10.0))
  (setq gutter_rad (input "Введите радиус желоба для телефона" "real" 4.0 2.0 10.0))
  (setq log_rad (input "Введите радиус перекладины для установки телефона" "real" 6.0 3.0 15.0))
  (setq log_h (input "Введите высоту перекладины для установки телефона" "real" 60.0 30.0 90.0))
  (setq slot_depth (input "Введите глубину ёмкостей для перекладины" "real" 10.0 5.0 20.0))
  (setq slot_с (input "Введите количество ёмкостей для перекладины" "int" 4 2 10))
 
  (platform)  
  (cut_gutter (entlast))
  (setq platform_ (entlast))
  (cut_slots_and_install_log (entlast))
  (command "перенести" platform_ (entlast) "" '(0 0 0) base_pt)
  
  (setvar "osmode" osm)
  )
