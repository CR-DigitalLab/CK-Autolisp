(defun platform (basis_p0     ;;; Начальная точка параллелепипеда основы
                  basis_size   ;;; Размер параллелепипеда основы
                  resess_p0    ;;; Начальная точка параллелепипеда выемки
                  resess_size  ;;; Размер параллелепипеда выемки
                  )
  (command "ящик"       ;;; Основа
           basis_p0
           "Д"
           (car basis_size)
           (cadr basis_size)
           (caddr basis_size))
  (setq basis (entlast))
  (command "ящик"       ;;; Выемка
           resess_p0
           "Д"
           (car resess_size)
           (cadr resess_size)
           (caddr resess_size))
  (command "вычитание"  ;;; Итоговая платформа
           basis
           ""
           (entlast)
           ""))
  
(defun arc (start_p   ;;; Начальная точка дуги
           center_p  ;;; Центр дуги
           end_p     ;;; Конечная точка дуга
           width     ;;; Толщина фигуры
           )
  (command "отрезок"   ;;; Хорда для создания грани
           start_p
           end_p
           "")
  (setq chord (entlast))
  (command "дуга"      ;;; Дуга
           start_p
           "Ц" center_p
           end_p)
  (command "повернуть"
           (entlast)
           ""
           center_p
           180)
  (command "область"   ;;; Грань
           chord
           (entlast)
           "")
  (command "выдавить"  ;;; Объёмная фигура
           (entlast)
           ""
           width
           ""))
  
(defun prism (a           ;;; Координата по Z
              b           ;;; Координата по X
              prism_h     ;;; Высота призмы
              platform_h  ;;; Высота платформы, на которой стоит призма
              width       ;;; Толщина призмы
              )
  (command "плиния"    ;;; Основание призмы
           (list 0 platform_h a)
           (list b platform_h a)
           (list b (+ platform_h prism_h) a)
           "З")
  (command "область"   ;;; Грань
           (entlast)
           "")
  (command "выдавить"  ;;; Призма
           (entlast)
           ""
           width
           ""))
  
(defun main ()
  (setq a 100
        b 70
        h 20
        h_ 10
        _h 15
        r 50
        w 15)
  
  (platform '(0 0 0)
            (list a b h)
            (list w 0 h_)
            (list b (- b w) h_))
  
  (command "пск"
           "X"
           90)
  
  (arc (list 0 h (- 0 b))
       (list (/ a 2) h (- 0 b))
       (list a h (- 0 b))
       w)
  
  (command "пск"
           "Y"
           90)
  
  (prism (- (/ a 2) (/ w 2))
         (- b w)
         (+ (- r _h) h_)
         h_
         w)
  
  (command "пск" ""))
  
(defun c:bldlab ()
  (main))
