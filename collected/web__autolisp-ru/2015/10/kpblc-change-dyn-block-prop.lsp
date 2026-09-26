(defun _kpblc-change-dyn-block-prop (ent name value / adoc prop value_lst blk)
                                    ;|
*    Функция изменения свойства динамического блока.
*    Параметры вызова:
*   ent   указатель на блок (vla-, ename или string). Строка воспринимается
      как хендл объекта. nil -> запрашивается у пользователя
*   name   имя дин.свойства
*   value   новое значение
*    Функция проверяет, является ли переданный примитив указателем на динамический
* блок, наличие у этого дин.блока указанного свойства и возможности назначения
* value.
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
  (vla-startundomark
    (setq adoc (vla-get-activedocument (vlax-get-acad-object)))
    ) ;_ end of vla-StartUndoMark
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
                        (setq
                          blk (vla-item (vla-get-blocks adoc)
                                        (vla-get-effectivename ent)
                                        ) ;_ end of vla-item
                          ) ;_ end of setq
                        ) ;_ end of vla-get-isxref
                      :vlax-true
                      ) ;_ end of =
                   name
                   (= (type name) 'str)
                   value
                   (setq
                     prop (car (vl-remove-if-not
                                 '(lambda (x)
                                    (= (strcase (vla-get-propertyname x))
                                       (strcase name)
                                       ) ;_ end of =
                                    ) ;_ end of lambda
                                 (vlax-safearray->list
                                   (vlax-variant-value
                                     (vla-getdynamicblockproperties ent)
                                     ) ;_ end of vlax-variant-value
                                   ) ;_ end of vlax-safearray->list
                                 ) ;_ end of vl-remove-if-not
                               ) ;_ end of car
                     ) ;_ end of setq
                   (or (not (vlax-property-available-p prop 'allowedvalues t))
                       (member
                         value
                         (mapcar 'vlax-variant-value
                                 (vlax-safearray->list
                                   (vlax-variant-value (vla-get-allowedvalues prop))
                                   ) ;_ end of vlax-safearray->list
                                 ) ;_ end of mapcar
                         ) ;_ end of member
                       ) ;_ end of or
                   ) ;_ end of and
               (progn
                 (vla-put-value
                   prop
                   (vlax-make-variant
                     value
                     (vlax-variant-type (vla-get-value prop))
                     ) ;_ end of vlax-make-variant
                   ) ;_ end of vla-put-value
                 (vla-update ent)
                 (vla-regen adoc acactiveviewport)
                 ) ;_ end of progn
               (princ "\nТакого значения или свойства в блоке нет")
               ) ;_ end of if
            ) ;_ end of lambda
          ) ;_ end of function
        ) ;_ end of vl-catch-all-apply
      ) ;_ end of vl-catch-all-error-p
     (princ (strcat "\nОшибка выполнения :: " (itoa (getvar "errno"))))
     ) ;_ end of if
  (vla-endundomark adoc)
  (princ)
  ) ;_ end of defun
