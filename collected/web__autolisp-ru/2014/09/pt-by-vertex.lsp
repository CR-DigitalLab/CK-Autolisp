(vl-load-com)

(defun c:pt-by-vertex (/ adoc ent)
  (if (and (= (type (setq ent (vl-catch-all-apply
                                (function
                                  (lambda ()
                                    (car (entsel "\nВыберите полилинию <Отмена> : "))
                                    ) ;_ end of lambda
                                  ) ;_ end of function
                                ) ;_ end of vl-catch-all-apply
                          ) ;_ end of setq
                    ) ;_ end of type
              'ename
              ) ;_ end of =
           (= (cdr (assoc 0 (entget ent))) "LWPOLYLINE")
           ) ;_ end of and
    (progn
      (vla-startundomark (setq adoc (vla-get-activedocument (vlax-get-acad-object))))
      (foreach item (mapcar 'cdr (vl-remove-if-not '(lambda (x) (= (car x) 10)) (entget ent)))
        (entmakex (list (cons 0 "POINT") (cons 10 item)))
        ) ;_ end of foreach
      (vla-endundomark adoc)
      ) ;_ end of progn
    (princ "\nОшибка выбора")
    ) ;_ end of if
  (princ)
  ) ;_ end of defun

(princ "\nВ ком.строке набрать pt-by-vertex")
