;move text 2 center rectang
(defun c:dtt()

  (setvar "cmdecho" 0)
  (setq OS (getvar "OSMODE"))
  (setvar "OSMODE" 32)

  (setq P1 (getpoint "\nPick a corner of the rectangle: "))
  (setq P2 (getcorner P1 "\nPick opposite corner of the rectangle: "))
  (setq A (angle P1 P2))
  (setq D (distance P1 P2))
  (setq P3 (polar P1 A (/ D 2.0)))	

 (setq ST (entsel "\nSelect text to center inside rectangle: "))

  (while
    (= ST nil)
     (progn
       (prompt "\nText was not selected...")
       (setq ST (entsel "\nSelect text to center inside rectangle: "))
     )
  )

  (command "justifytext" ST "" "MC")
  (setq TMC (cdr (assoc 11 (entget (car ST)))))
  (command "move" ST "" TMC P3)

  (setvar "OSMODE" OS)
  (princ)

)