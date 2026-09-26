(defun c:tlabel(/ p1 dx dy noff x i ip)
    (setvar "cmdecho" 0)
    (setq Myscale (getvar "dimscale"))
    (setq oldsnap (getvar "osmode"))
    (setvar "osmode" 0)
    (command "-layer" "m" (strcat "Text-" (rtos myscale 2 2))  "")
    (command "-style" (strcat "Text-" (rtos myscale 2 2)) "romans" (* myscale 0.125) "" "" "" "" "")
    
    (setq p1 (getpoint "\nStarting point for text placement:"))
    (setq dx (getreal "\nX offset :"))
    (setq dy (getreal "\nY offset :"))
    (setq n1 (getreal "\nStarting number :"))
    (setq noff (getreal "\nNumber increment value :"))
    (setq x (getint "\nNumber of items :"))
    (setq ip (getstring "\nInclude a + ? Y/N :"))
    
    (setq i 0)
    (while (< i x) (progn
       (if (or (= "y" ip) (= "Y" ip)) (progn
            (setq numb (strcat (itoa (fix (/ n1 100.0))) "+" (substr (rtos n1 2 0) (- (strlen (rtos n1 2 0)) 1))))
            (command "-text" "j" "m" p1 "0" numb)
       )(progn
            (command "-text" "j" "m" p1 "0" (rtos n1 2 0))
       ))
       (setq n1 (+ n1 noff))
       (setq p1 (list (+ (car p1) dx) (+ (cadr p1) dy)))
       (setq i (+ i 1))
       
       ))
    (setvar "cmdecho" 1)

    (setvar "osmode" oldsnap)
    
    
  (princ)
  )