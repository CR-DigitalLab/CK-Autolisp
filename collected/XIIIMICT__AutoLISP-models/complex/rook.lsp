(defun correctInput (type_ prompt_ default min_ max_)
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


(defun c:rook ()
  (setq osm (getvar "osmode"))
  (setvar "osmode" 0)

  (setq basePoint (correctInput "p" "Введите базовую точку" '(0 0 0) nil nil)
	baseHeight (correctInput "r" "Введите высоту первого нижнего основания" 15 7 45)
	baseRadius (correctInput "r" "Введите радиус первого нижнего основания" 20 10 50)
	baseRoundRadius (correctInput "r" "Введите радиус скругления углов стенок боковых сегментов" 2 0 10)
	secondBaseHeight (correctInput "r" "Введите высоту второго нижнего основания" 12 5 40)
	secondBaseRadius (correctInput "r" "Введите радиус второго нижнего основания" 15 5 45)
	coneHeight (correctInput "r" "Введите высоту центрального усечённого конуса" 25 10 75)
	segmentRadius (correctInput "r" "Введите радиус кольцевого сегмента на верхушке фигуры" 3 1 10)
	ringCount (correctInput "i" "Введите количество кольцевых сегментов в центре фигуры" 1 0 3)
	undercrownHeight (correctInput "r" "Введите высоту перепонки между короной и кольцевым сегментом" 2 0 10)
	crownHeight (correctInput "r" "Введите высоту короны" 10 5 20)
	)

  (command "отрезок"
        (list (- (car basePoint) baseRadius) (cadr basePoint) (caddr basePoint))
        (list (+ (- (car basePoint) baseRadius) (/ baseHeight 8)) (+ (cadr basePoint) baseHeight) (caddr basePoint))
        ""
        )
  (setq obj1 (entlast))
  (command "отрезок"
        (list (+ (- (car basePoint) baseRadius) (/ baseHeight 8)) (+ (cadr basePoint) baseHeight) (caddr basePoint))
        (list (- (car basePoint) (* secondBaseRadius 0.9)) (+ (cadr basePoint) baseHeight) (caddr basePoint))
        ""
        )
  (setq obj2 (entlast))
  (command "сопряжение" "д" baseRoundRadius "\e")
  (command "сопряжение" obj1 obj2)
  (setq obj3 (entlast))

  (command "дуга"
	   (list (- (car basePoint) (* secondBaseRadius 0.9)) (+ (cadr basePoint) baseHeight) (caddr basePoint))
           (list (- (car basePoint) secondBaseRadius) (+ (cadr basePoint) baseHeight (/ secondBaseHeight 2)) (caddr basePoint))
	   (list (- (car basePoint) (* secondBaseRadius 0.9)) (+ (cadr basePoint) baseHeight secondBaseHeight) (caddr basePoint))
	   )
  (setq obj4 (entlast))

  (command "плиния"
	   (list (- (car basePoint) (* secondBaseRadius 0.9)) (+ (cadr basePoint) baseHeight secondBaseHeight) (caddr basePoint))
	   (list (- (car basePoint) (* secondBaseRadius 0.8)) (+ (cadr basePoint) baseHeight secondBaseHeight) (caddr basePoint))
           (list (- (car basePoint) (* secondBaseRadius 0.6)) (+ (cadr basePoint) baseHeight secondBaseHeight coneHeight) (caddr basePoint))
	   (list (- (car basePoint) (* secondBaseRadius 0.6)) (+ (cadr basePoint) baseHeight secondBaseHeight coneHeight) (caddr basePoint))
           (list (- (car basePoint) (* secondBaseRadius 0.7)) (+ (cadr basePoint) baseHeight secondBaseHeight coneHeight) (caddr basePoint))
           "д"
	   (list (- (car basePoint) (* secondBaseRadius 0.7)) (+ (cadr basePoint) baseHeight secondBaseHeight coneHeight (* segmentRadius 2)) (caddr basePoint))
           "л"
	   (list (- (car basePoint) (* secondBaseRadius 0.6)) (+ (cadr basePoint) baseHeight secondBaseHeight coneHeight (* segmentRadius 2)) (caddr basePoint))
           (list (- (car basePoint) (* secondBaseRadius 0.6)) (+ (cadr basePoint) baseHeight secondBaseHeight coneHeight (* segmentRadius 2) undercrownHeight) (caddr basePoint))
           (list (- (car basePoint) (* secondBaseRadius 0.7)) (+ (cadr basePoint) baseHeight secondBaseHeight coneHeight (* segmentRadius 2) undercrownHeight) (caddr basePoint))
           (list (- (car basePoint) (* secondBaseRadius 0.7)) (+ (cadr basePoint) baseHeight secondBaseHeight coneHeight (* segmentRadius 2) undercrownHeight crownHeight) (caddr basePoint))
           (list (car basePoint) (+ (cadr basePoint) baseHeight secondBaseHeight coneHeight (* segmentRadius 2) undercrownHeight crownHeight) (caddr basePoint))
	   basePoint
	   (list (- (car basePoint) baseRadius) (cadr basePoint) (caddr basePoint))
	   ""
	   )
  (setq obj5 (entlast))
  
  (command "полред" obj1 "" "д" obj2 obj3 obj4 obj5 "" "")
  (setq obj1 (entlast))

  (if (>= ringCount 1)
    (progn
      (command "круг"
           (list (- (car basePoint) (* secondBaseRadius 0.7)) (+ (cadr basePoint) baseHeight secondBaseHeight (/ coneHeight 2)) (caddr basePoint))
           (* coneHeight 0.03)
           )
      
      (command "область" (entlast) "")
      (setq obj2 (entlast))
      )
   )
  (if (>= ringCount 2)
    (progn
      (command "круг"
           (list (- (car basePoint) (* secondBaseRadius 0.69)) (+ (cadr basePoint) baseHeight secondBaseHeight (/ coneHeight 1.8)) (caddr basePoint))
           (* coneHeight 0.03)
           )
      (command "область" (entlast) "")
      (setq obj3 (entlast))
      )
   )
  (if (= ringCount 3)
    (progn
      (command "круг"
           (list (- (car basePoint) (* secondBaseRadius 0.72)) (+ (cadr basePoint) baseHeight secondBaseHeight (/ coneHeight 2.45)) (caddr basePoint))
           (* coneHeight 0.03)
           )
      (command "область" (entlast) "")
      (setq obj4 (entlast))
      )
   )
  
  (command "область" obj1 "")
  (setq obj1 (entlast))
  (command "объединение" obj1 obj2 obj3 obj4 "")
  (command "вращать"
	   (entlast)
	   ""
	   basePoint
	   (list (car basePoint) (+ (cadr basePoint) 1) (caddr basePoint))
	   ""
	   )
  (command "пск" "Y" -90)
  (command "повернуть" (entlast) "" (list (caddr basePoint) (cadr basePoint) (- (car basePoint))) -90)
  (command "пск" "Y" 90)
  (setq obj1 (entlast))

  (command "ящик"
	   (list (- (car basePoint) (* secondBaseRadius 0.7)) (+ (cadr basePoint) (* secondBaseRadius 0.3)) (+ (caddr basePoint) baseHeight secondBaseHeight coneHeight (* segmentRadius 2) undercrownHeight (* crownHeight 0.4)))
	   (list (+ (car basePoint) (* secondBaseRadius 0.7)) (+ (cadr basePoint) (* secondBaseRadius 0.7)) (+ (caddr basePoint) baseHeight secondBaseHeight coneHeight (* segmentRadius 2) undercrownHeight crownHeight))
	   )
  (setq obj2 (entlast))
  (command "зеркало" obj2 "" basePoint (list (+ (car basePoint) 1) (cadr basePoint) (caddr basePoint)) "")
  (setq obj3 (entlast))

  (command "ящик"
	   (list (- (car basePoint) (* secondBaseRadius 0.5)) (- (cadr basePoint) (* secondBaseRadius 0.3)) (+ (caddr basePoint) baseHeight secondBaseHeight coneHeight (* segmentRadius 2) undercrownHeight (* crownHeight 0.8)))
	   (list (- (car basePoint) (* secondBaseRadius 0.2)) (+ (cadr basePoint) (* secondBaseRadius 0.3)) (+ (caddr basePoint) baseHeight secondBaseHeight coneHeight (* segmentRadius 2) undercrownHeight crownHeight))
	   )
  (setq obj4 (entlast))
  
  (command "3dплиния"
	   (list (- (car basePoint) (* secondBaseRadius 0.2)) (- (cadr basePoint) (* secondBaseRadius 0.3)) (+ (caddr basePoint) baseHeight secondBaseHeight coneHeight (* segmentRadius 2) undercrownHeight (* crownHeight 0.9)))
           (list (- (car basePoint) (* secondBaseRadius 0.2)) (- (cadr basePoint) (* secondBaseRadius 0.3)) (+ (caddr basePoint) baseHeight secondBaseHeight coneHeight (* segmentRadius 2) undercrownHeight crownHeight))
	   (list (car basePoint) (- (cadr basePoint) (* secondBaseRadius 0.3)) (+ (caddr basePoint) baseHeight secondBaseHeight coneHeight (* segmentRadius 2) undercrownHeight crownHeight))
           "З"
	   )
  (command "область" (entlast) "")
  (command "выдавить" (entlast) "" (* secondBaseRadius 0.6))
  (setq obj5 (entlast))
  (command "объединение" obj4 obj5 "")
  (setq obj4 (entlast))

  (command "зеркало" obj4 "" basePoint (list (car basePoint) (+ (cadr basePoint) 1) (caddr basePoint)) "")
  (setq obj5 (entlast))
  
  (command "вычитание" obj1 "" obj2 obj3 obj4 obj5 "")

  (setvar "osmode" osm)
)
