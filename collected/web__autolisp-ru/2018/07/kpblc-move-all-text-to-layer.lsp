(vl-load-com)

(defun _kpblc-move-all-text-to-layer (/ layer adoc selset str num)
  (if (and (= (type
                (setq layer (vl-catch-all-apply
                              (function
                                (lambda () (getstring t "\nВведите имя слоя, на который надо переместить тексты <Отмена> : "))
                                ) ;_ end of function
                              ) ;_ end of vl-catch-all-apply
                      ) ;_ end of setq
                ) ;_ end of type
              'str
              ) ;_ end of =
           (setq layer (vl-string-trim " " layer))
           (/= layer "")
           (= (type (setq selset (vl-catch-all-apply (function (lambda () (ssget "_:L" '((0 . "*TEXT,ATT*"))))))))
              'pickset
              ) ;_ end of =
           ) ;_ end of and
    (progn (vla-startundomark (setq adoc (vla-get-activedocument (vlax-get-acad-object))))
           (setq num '(32 44 46 48 49 50 51 52 53 54 55 56 57))
           (foreach ent ((lambda (/ tab item)
                           (repeat (setq tab  nil
                                         item (sslength selset)
                                         ) ;_ end setq
                             (setq tab (cons (ssname selset (setq item (1- item))) tab))
                             ) ;_ end of repeat
                           ) ;_ end of lambda
                         )
             (setq str (vl-string->list (vla-get-textstring (vlax-ename->vla-object ent))))
             (if (apply 'and (mapcar '(lambda (x) (member x num)) str))
               (progn (entmod (subst (cons 8 layer) (assoc 8 (entget ent)) (entget ent))))
               ) ;_ end of if
             ) ;_ end of foreach
           (vla-regen adoc acallviewports)
           (vla-endundomark adoc)
           ) ;_ end of progn
    ) ;_ end of if
  ) ;_ end of defun

(defun c:text-to-layer () (_kpblc-move-all-text-to-layer))

(princ "\nНаберите без кавычек \"text-to-layer\" для запуска команды")
(princ)