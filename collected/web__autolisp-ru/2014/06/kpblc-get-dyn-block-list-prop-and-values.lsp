(defun _kpblc-get-dyn-block-list-prop-and-values (ent / res)
                                                 ;|
*    Функция получения списка свойств и их возможных значений для дин.блока
*    Параметры вызова:
*  ent  указатель на блок (vla-, ename или string). Строка воспринимается
   как хендл объекта. nil -> запрашивается у пользователя
|;
  (vl-load-com)
  (vl-catch-all-apply
    '(lambda ()
       (setq ent (cond (ent)
                       (t (car (entsel "\nУкажите блок <Отмена> : ")))
                       ) ;_ end of cond
             ) ;_ end of setq
       ) ;_ end of lambda
    ) ;_ end of vl-catch-all-apply
  (if
    (vl-catch-all-error-p
      (vl-catch-all-apply
        (function
          (lambda ()
            (if
              (and (setq
                     ent (cond
                           ((= (type ent) 'ename) (vlax-ename->vla-object ent))
                           ((= (type ent) 'vla-object) ent)
                           ((= (type ent) 'str)
                            ((lambda (/ tmp)
                               (vl-catch-all-apply
                                 '(lambda () (setq tmp (vla-handletoobject ent)))
                                 ) ;_ end of vl-catch-all-apply
                               tmp
                               ) ;_ end of lambda
                             )
                            )
                           (t nil)
                           ) ;_ end of cond
                     ) ;_ end of setq
                   (= (strcase (vla-get-objectname ent) t) "acdbblockreference")
                   (= (vla-get-isdynamicblock
                        (vla-item
                          (vla-get-blocks
                            (vla-get-activedocument (vlax-get-acad-object))
                            ) ;_ end of vla-get-blocks
                          (vla-get-effectivename ent)
                          ) ;_ end of vla-item
                        ) ;_ end of vla-get-isxref
                      :vlax-true
                      ) ;_ end of =
                   ) ;_ end of and
               (setq res
                      (mapcar
                        '(lambda (x / еьз)
                           (cons
                             (vla-get-propertyname x)
                             (if (vl-catch-all-error-p
                                   (vl-catch-all-apply
                                     '(lambda ()
                                        (setq tmp (mapcar 'vlax-variant-value
                                                          ­
                                                          (vlax-safearray->list
                                                            ­
                                                            (vlax-variant-value
                                                              (vla-get-allowedvalues x)
                                                              ­
                                                              ) ;_ end of vlax-variant-value
                                                            ­
                                                            ) ;_ end of vlax-safearray->list
                                                          ­
                                                          ) ;_ end of mapcar
                                              ) ;_ end of setq
                                        ) ;_ end of lambda
                                     ) ;_ end of vl-catch-all-apply
                                   ) ;_ end of vl-catch-all-error-p
                               (list "Неиндексированное значение")
                               tmp
                               ) ;_ end of if
                             ) ;_ end of cons
                           ) ;_ end of lambda
                        (vl-remove-if
                          '(lambda (a)
                             (= (strcase (vla-get-propertyname a)) "ORIGIN")
                             ) ;_ end of lambda
                          (vlax-safearray->list
                            (vlax-variant-value
                              (vla-getdynamicblockproperties ent)
                              ) ;_ end of vlax-variant-value
                            ) ;_ end of vlax-safearray->list
                          ) ;_ end of vl-remove-if
                        ) ;_ end of mapcar
                     ) ;_ end of setq
               (princ "\nОшибка указания примитива")
               ) ;_ end of if
            ) ;_ end of lambda
          ) ;_ end of function
        ) ;_ end of vl-catch-all-apply
      ) ;_ end of vl-catch-all-error-p
     (princ (strcat "\nОшибка выполнения :: " (itoa (getvar "errno"))))
     ) ;_ end of if
  res
  ) ;_ end of defun