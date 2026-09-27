; ------------------------------------------------------------------ ;
; Polecenie CHELT ustawia dla zbioru wskazan TEXT/MTEXT wspolrzedna  ;
; X / Y / Z lub XYZ z pobranego tekstu zrodlowego                    ;
; kojacek 2017                                                       ;
; ------------------------------------------------------------------ ;
(defun C:CHELT (/ e d s c v l -ch10)
  (defun -ch10 (e i v / d n)
    (setq d (cdr (assoc 10 (entget e))))
    (setq n
      (cond
        ( (= "X" i)(list v (cadr d)(caddr d)))
        ( (= "Y" i)(list (car d) v (caddr d)))
        ( (= "Z" i)(list (car d)(cadr d) v))
        (t v)
      )
    )
    (cd:ENT_SetDXF e 10 n)
  )
  (if
    (and
      (setq e (entsel "\nWybierz źródłowy TEXT lub MTEXT: "))
      (wcmatch (cdr (assoc 0 (setq d (entget (car e))))) "*TEXT")
    )
    (progn
      (redraw (car e) 3)
      (setq v (cdr (assoc 10 d)))
      (princ
        (strcat "\nZmiana współrzędnej wstawienia"
                " [X=" (cd:CON_Real2Str (car v) 2 nil)
                ", Y=" (cd:CON_Real2Str (cadr v) 2 nil)
                ", Z=" (cd:CON_Real2Str (caddr v) 2 nil)
                "]"
        )
      )
      (if
        (setq s (ssget "_:L" '((0 . "*TEXT"))))
        (if
          (setq c
            (cd:USR_GetKeyWord
              "\nUstal składową współrzędnej obiektów"
              '("X" "Y" "Z" "Wszystkie" "Koniec") "Z")
          )
          (if
            (= c "Koniec")
            (princ "\nAnulowano. ")
            (progn
              (setq l (cd:SSX_Convert s 0))
              (cd:SYS_UndoBegin)
              (foreach % l
                (cond
                  ( (= c "X")(-ch10 % c (car v)))
                  ( (= c "Y")(-ch10 % c (cadr v)))
                  ( (= c "Z")(-ch10 % c (caddr v)))
                  ( (= c "Wszystkie")(-ch10 % "W" v))
                  (t  nil)
                )
              )
              (cd:SYS_UndoEnd)
            )
          )
          (princ "\nAnulowano. ")
        )
        (princ "\nNie wybrano obiektów. ")
      )
      (redraw (car e) 4)
    )
    (princ "\nNie wskazano prawidłowego obiektu. ")
  )
  (princ)
)
