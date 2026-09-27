; ------------------------------------------------------------------ ;
; Polecenie ITEXT zamienia wskazane teksty jednoliniowe na teksty
; zorientowane na izoplaszczyznach
; by kojacek 2002 + 2016 
; ------------------------------------------------------------------ ;

(defun C:ITEXT ( / e d i v l z d330 d30 d90
                   _get _dtr _rtd _put _eqa
                   *itexterr
               )
  (defun *itexterr (msg)
    (if (= 8 (logand 8 (getvar "UNDOCTL")))(cd:SYS_UndoEnd))
    (if
      (or (= msg "Function cancelled")(= msg "quit / exit abort"))
      (princ (strcat "\nBłąd: " msg))
      (princ "\nAnulowano. ")
    )
    (if *olderror* (setq *error* *olderror*))
    (princ)
  )
  (defun _put (r l)
    (cd:ENT_SetDXF e 50 r)
    (cd:ENT_SetDXF e 51 l)
  )
  (defun _rtd (r)(* 180.0 (/ r pi)))
  (defun _dtr (d)(* pi (/ d 180.0)))
  (defun _get (d)
    (list
      (cdr (assoc 50 d))
      (cdr (assoc 51 d))
    )
  )
  (defun _eqa (a1 a2)
    (and (eq (car v) a1)(eq (cadr v) a2))
  )
;--->
  (setq *olderror* *error* *error* *itexterr)
  (if (zerop (getvar "SNAPSTYL"))(setvar "SNAPSTYL" 1))
  (setq i (getvar "SNAPISOPAIR")
        l '("lewa" "górna" "prawa")
  )
  (while
    (and
      (setq e
        (car
          (entsel
            (strcat "\nIzopłaszczyzna "
               (nth i l) ". Wybierz tekst: ")
          )
        )
      )
      (= "TEXT" (cdr (assoc 0 (setq d (entget e)))))
    )
    (progn
      (setq i (getvar "SNAPISOPAIR")
            v (mapcar '_rtd (_get d))
            z (and (zerop (car v))(zerop (cadr v)))
            d330 (_dtr 330)
            d30 (_dtr 30)
            d90 (_dtr 90)
      )
      (cd:SYS_UndoBegin)
      (cond
        ( (= i 0)
          (cond
            ( z (_put d330 d330))
            ( (_eqa 330 330)(_put d90 d30))
            ( (_eqa 90 30)(_put 0 0))
            ( t (_put 0 0))
          )
        )
        ( (= i 1)
          (cond
            ( z (_put d330 d30))
            ( (_eqa 330 30)(_put d30 d330))
            ( (_eqa 30 330)(_put 0 0))
            ( t (_put 0 0))
          )
        )
        ( (= i 2)
          (cond
            ( z (_put d30 d30))
            ( (_eqa 30 30)(_put d90 d330))
            ( (_eqa 90 330)(_put 0 0))
            ( t (_put 0 0))
          )
        )
        (t nil)
      )
      (cd:SYS_UndoEnd)
    )
  )
  (setq *error* *olderror*)
  (princ)
)
