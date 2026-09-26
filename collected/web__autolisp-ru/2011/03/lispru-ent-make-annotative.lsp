(defun _lispru-ent-make-annotative (ent make / res)
                                   ;|
*    Добавление аннотативности объекту
*    Параметры вызова:
  ent     ename-указатель на объект
  make    делать аннотативным или снимать аннотативность
|;
  (if
    (and (> (_lispru-acad-version) 17.0)
         (not
           (assoc "AcadAnnotative" (cdr (assoc -3 (entget ent '("*")))))
           ) ;_ end of not
         ) ;_ end of and
     (if make
       (progn
         (regapp "AcadAnnotative")
         (setq
           res (entmod
                 (list (cons -1 ent)
                       '(-3
                         ("AcadAnnotative"
                          (1000 . "AnnotativeData")
                          (1002 . "{")
                          (1070 . 1)
                          (1070 . 1)
                          (1002 . "}")
                          )
                         )
                       ) ;_ end of list
                 ) ;_ end of entmod
           ) ;_ end of setq
         ) ;_ end of progn
       (setq res
              (entmod
                (append
                  (entget ent)
                  (list
                    (cons
                      -3
                      (append '(("AcadAnnotative"))
                              (vl-remove-if
                                (function
                                  (lambda (x)
                                    (= (car x "AcadAnnotative"))
                                    ) ;_ end of lambda
                                  ) ;_ end of function
                                (cdr (assoc -2 (entget ent '("*"))))
                                ) ;_ end of vl-remove-if
                              ) ;_ end of append
                      ) ;_ end of cons
                    ) ;_ end of list
                  ) ;_ end of append
                ) ;_ end of entmod
             ) ;_ end of setq
       ) ;_ end of if
     ) ;_ end of if
  ) ;_ end of defun
