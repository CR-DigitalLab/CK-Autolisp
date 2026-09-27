
(defun c:tta()
  (setvar "cmdecho" 0)
 (setq old_os (getvar "osmode")) 
(defun *error* (msg)(princ "편집종료: ")(princ msg)
          (setvar "osmode" old_os)
          (princ))
         ;-<*error* end


  (princ "\n표 안의 문자 좌우 위치 정렬하기 ")
  
  (setvar "osmode" 0)
(setq menu (getint "\n1=왼쪽 정렬 / 2=가운데 정렬 / 3=오른쪽 정렬"))
(if (= menu 1)
  (progn
    (setq pt1 (getpoint "\n표의 좌측 하단을 찍으세요: "))
     (while (= pt1 nil)
      (setq pt1 (getpoint "\n표의 좌측 하단을 찍으세요: "))
     )
    (setq pt3 (getcorner pt1 "\n표의 우측 상단을 찍으세요: "))
     (while (= pt3 nil)
      (setq pt3 (getcorner pt1 "\n표의 우측 상단을 찍으세요: "))
     )
    (setq pt2 (list (car pt3) (cadr pt1))) 
    (setq pt4 (list (car pt1) (cadr pt3)))
    (setq sg (ssget "W" pt1 pt3 '((0 . "TEXT"))))
    (setq len (sslength sg))
    (setq cnt 0)
    
    (setq leftx (car pt1))
    (repeat len
      
      (setq en (ssname sg cnt))
      (command "tjust" en "" "L")
      (setq eg (entget en))
      (setq mc (cdr (assoc 10 eg)))
      (setq ty (cadr mc))
      (setq tg (list leftx ty))
      (command "move" en "" mc tg)
      (setq cnt (+ cnt 1))
    ); repeat end
 );progn end
(setvar "osmode" old_os)
) ; menu 1  if end
(if (= menu 2)
  (progn
    (setvar "osmode" 0)
    (setq pt1 (getpoint "\n표의 좌측 하단을 찍으세요: "))
     (while (= pt1 nil)
      (setq pt1 (getpoint "\n표의 좌측 하단을 찍으세요: "))
     )
    (setq pt3 (getcorner pt1 "\n표의 우측 상단을 찍으세요: "))
     (while (= pt3 nil)
      (setq pt3 (getcorner pt1 "\n표의 우측 상단을 찍으세요: "))
     )
    (setq pt2 (list (car pt3) (cadr pt1))) 
    (setq pt4 (list (car pt1) (cadr pt3)))
    (setq sg (ssget "W" pt1 pt3 '((0 . "TEXT"))))
    (setq len (sslength sg))
    (setq cnt 0)
    
    (setq leftx (car pt1))
    (repeat len
      
      (setq en (ssname sg cnt))
      (command "tjust" en "" "mc")
      (setq eg (entget en))
      (setq mc (cdr (assoc 11 eg)))
      
      (setq ty (cadr mc))
      
      (setq xdist (distance pt1 pt2))
      (setq xmid (polar pt1 0 (/ xdist 2)))
      (setq leftx (car xmid))
      (setq tg (list leftx ty))
      (command "move" en "" mc tg)
      (setq cnt (+ cnt 1))
    ); repeat end
 );progn end
(setvar "osmode" old_os)
) ; menu 2  if end

(if (= menu 3)
  (progn
    (setvar "osmode" 0)
    (setq pt1 (getpoint "\n표의 좌측 하단을 찍으세요: "))
     (while (= pt1 nil)
      (setq pt1 (getpoint "\n표의 좌측 하단을 찍으세요: "))
     )
    (setq pt3 (getcorner pt1 "\n표의 우측 상단을 찍으세요: "))
     (while (= pt3 nil)
      (setq pt3 (getcorner pt1 "\n표의 우측 상단을 찍으세요: "))
     )
    (setq pt2 (list (car pt3) (cadr pt1))) 
    (setq pt4 (list (car pt1) (cadr pt3)))
    (setq sg (ssget "W" pt1 pt3 '((0 . "TEXT"))))
    (setq len (sslength sg))
    (setq cnt 0)
    
    (setq leftx (car pt2))
    (repeat len
      (setvar "osmode" 0)
      (setq en (ssname sg cnt))
      (command "tjust" en "" "r")
      (setq eg (entget en))
      (setq mc (cdr (assoc 11 eg)))
      (setq ty (cadr mc))
      (setq tg (list leftx ty))
      (command "move" en "" mc tg)
      (setq cnt (+ cnt 1))
      (setvar "osmode" old_os)
    ); repeat end
 );progn end
(setvar "osmode" old_os)
) ; menu 1  if end















)


