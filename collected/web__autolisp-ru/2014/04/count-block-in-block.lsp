(vl-load-com)

(defun c:count-block-in-block (/                          selset                     blockname
                               adoc                       _kpblc-conv-vla-to-list    _kpblc-conv-list-to-string
                               _kpblc-conv-value-to-string                           _kpblc-conv-selset-to-ename
                               _kpblc-conv-ent-to-ename   _kpblc-conv-ent-to-vla     res
                               fun_getcount
                               )

  (defun fun_getcount (block-def block-name / lst _res)
    ;; Посчет состава блоков определенного имени внутри блока
    (apply '+
           (mapcar
             (function
               (lambda (subent)
                 (cond
                   ((and (= (vla-get-objectname subent) "AcDbBlockReference")
                         (wcmatch (strcase (if (vlax-property-available-p subent 'effectivename)
                                             (vla-get-effectivename subent)
                                             (vla-get-name subent)
                                             ) ;_ end of if
                                           ) ;_ end of strcase
                                  (strcase block-name)
                                  ) ;_ end of WCMATCH
                         ) ;_ end of and
                    1
                    )
                   ((and (= (vla-get-objectname subent) "AcDbBlockReference")
                         (not (wcmatch (strcase (if (vlax-property-available-p subent 'effectivename)
                                                  (vla-get-effectivename subent)
                                                  (vla-get-name subent)
                                                  ) ;_ end of if
                                                ) ;_ end of strcase
                                       (strcase block-name)
                                       ) ;_ end of WCMATCH
                              ) ;_ end of not
                         ) ;_ end of and
                    (fun_getcount (vla-item (vla-get-blocks adoc) (vla-get-name subent)) block-name)
                    )
                   (t 0)
                   ) ;_ end of cond
                 ) ;_ end of lambda
               ) ;_ end of function
             (_kpblc-conv-vla-to-list block-def)
             ) ;_ end of mapcar
           ) ;_ end of apply
    ) ;_ end of defun

  (defun _kpblc-conv-ent-to-vla (ent_value / res)
                                ;|
*    Функция преобразования полученного значения в vla-указатель.
*    Параметры вызова:
*  ent_value  значение, которое надо преобразовать в указатель. Может
*      быть именем примитива, vla-указателем или просто
*      списком.
*      Если не принадлежит ни одному из указанных типов,
*      возвращается nil
*    Примеры вызова:
(_kpblc-conv-ent-to-vla (entlast))
(_kpblc-conv-ent-to-vla (vlax-ename->vla-object (entlast)))
|;
    (cond
      ((= (type ent_value) 'vla-object) ent_value)
      ((= (type ent_value) 'ename) (vlax-ename->vla-object ent_value))
      ((setq res (_kpblc-conv-ent-to-ename ent_value))
       (vlax-ename->vla-object res)
       )
      ) ;_ end of cond
    ) ;_ end of defun

  (defun _kpblc-conv-ent-to-ename (ent_value / _lst)
                                  ;|
*    Функция преобразования полученного значения в ename
*    Параметры вызова:
*  ent_value  значение, которое надо преобразовать в примитив. Может
*      быть именем примитива, vla-указателем или просто
*      списком.
*      Если не принадлежит ни одному из указанных типов,
*      возвращается nil
*    Примеры вызова:
(_kpblc-conv-ent-to-ename (entlast))
(_kpblc-conv-ent-to-ename (vlax-ename->vla-object (entlast)))
|;
    ;; "_kpblc-conv-ent-to-ename")
    (cond
      ((= (type ent_value) 'vla-object)
       (vlax-vla-object->ename ent_value)
       )
      ((= (type ent_value) 'ename) ent_value)
      ((and (= (type ent_value) 'str) (handent ent_value) (entget (handent ent_value)))
       (handent ent_value)
       )
      ((and (= (type ent_value) 'str) (handent ent_value) (tblobjname "style" ent_value))
       (tblobjname "style" ent_value)
       )
      ((and (= (type ent_value) 'str) (handent ent_value) (tblobjname "dimstyle" ent_value))
       (tblobjname "dimstyle" ent_value)
       )
      ((and (= (type ent_value) 'str) (handent ent_value) (tblobjname "block" ent_value))
       (tblobjname "block" ent_value)
       )
      ((and (= (type ent_value) 'list) (cdr (assoc -1 ent_value))) (cdr (assoc -1 ent_value)))
      (t nil)
      ) ;_ end of cond
    ) ;_ end of defun

  (defun _kpblc-conv-selset-to-ename (selset / tab item)
                                     ;|
*    Преобразование набора, полученного через ssget, в список ename-представлени
* примитивов.
*    Параметры вызова:
  selset  набор примитивов
*    Примеры вызова:
(_kpblc-conv-selset-to-ename (ssget))
|;
    (cond
      ((not selset) nil)
      ((= (type selset) 'pickset)
       (repeat (setq tab  nil
                     item (sslength selset)
                     ) ;_ end setq
         (setq tab (cons (ssname selset (setq item (1- item))) tab))
         ) ;_ end repeat
       )
      ((= (type selset) 'vla-object)
       (_kpblc-conv-vla-to-list selset)
       )
      ((listp selset) (mapcar (function _kpblc-conv-ent-to-ename) selset))
      ) ;_ end of cond
    ) ;_ end of defun

  (defun _kpblc-conv-value-to-string (value /)
                                     ;|
*    конвертация значения в строку.
|;
    (cond
      ((= (type value) 'str) value)
      ((= (type value) 'int) (itoa value))
      ((= (type value) 'real) (rtos value 2 14))
      ((not value) "")
      (t (vl-princ-to-string value))
      ) ;_ end of cond
    ) ;_ end of defun

  (defun _kpblc-conv-list-to-string (lst sep)
                                    ;|
*    Преобразование списка в строку
*    Параметры вызова:
  lst  обрабатываемй список
  sep  разделитель. nil -> " "
|;
    (if (and lst
             (setq lst (mapcar (function _kpblc-conv-value-to-string) lst))
             (setq sep (if sep
                         sep
                         " "
                         ) ;_ end of if
                   ) ;_ end of setq
             ) ;_ end of and
      (strcat (car lst)
              (apply (function strcat)
                     (mapcar
                       (function
                         (lambda (x)
                           (strcat sep x)
                           ) ;_ end of lambda
                         ) ;_ end of function
                       (cdr lst)
                       ) ;_ end of mapcar
                     ) ;_ end of apply
              ) ;_ end of strcat
      ""
      ) ;_ end of if
    ) ;_ end of defun


  (defun _kpblc-conv-vla-to-list (value / res)
                                 ;|
*    Преобразовывает vlax-variant или vlax-safearray в список.
|;
    (cond
      ((listp value)
       (mapcar (function _kpblc-conv-vla-to-list) value)
       )
      ((= (type value) 'variant)
       (_kpblc-conv-vla-to-list (vlax-variant-value value))
       )
      ((= (type value) 'safearray)
       (if (>= (vlax-safearray-get-u-bound value 1) 0)
         (_kpblc-conv-vla-to-list (vlax-safearray->list value))
         ) ;_ end of if
       )
      ((and (= (type value) 'vla-object)
            (vlax-property-available-p value 'count)
            ) ;_ end of and
       (vlax-for sub (_kpblc-conv-ent-to-vla value)
         (setq res (cons sub res))
         ) ;_ end of vlax-for
       )
      (t value)
      ) ;_ end of cond
    ) ;_ end of defun

  (setq adoc (vla-get-activedocument (vlax-get-acad-object)))

  (if (and (= (type (setq selset (vl-catch-all-apply
                                   (function
                                     (lambda ()
                                       (ssget '((0 . "INSERT")))
                                       ) ;_ end of lambda
                                     ) ;_ end of function
                                   ) ;_ end of vl-catch-all-apply
                          ) ;_ end of setq
                    ) ;_ end of type
              'pickset
              ) ;_ end of =
           (= (type (setq blockname (vl-catch-all-apply
                                      (function
                                        (lambda ()
                                          (getstring t "\nEnter blockname to count <Cancel> : ")
                                          ) ;_ end of lambda
                                        ) ;_ end of function
                                      ) ;_ end of vl-catch-all-apply
                          ) ;_ end of setq
                    ) ;_ end of type
              'str
              ) ;_ end of =
           (wcmatch (strcase blockname)
                    (strcase
                      (_kpblc-conv-list-to-string
                        (mapcar
                          (function vla-get-name)
                          (vl-remove-if
                            (function
                              (lambda (x)
                                (or (equal (vla-get-isxref x) :vlax-true) (equal (vla-get-islayout x) :vlax-true))
                                ) ;_ end of lambda
                              ) ;_ end of function
                            (_kpblc-conv-vla-to-list (vla-get-blocks adoc))
                            ) ;_ end of vl-remove-if
                          ) ;_ end of mapcar
                        ","
                        ) ;_ end of _kpblc-conv-list-to-string
                      ) ;_ end of strcase
                    ) ;_ end of wcmatch
           ) ;_ end of and
    (princ (strcat "\n"
                   (itoa (apply '+
                                (mapcar (function (lambda (x)
                                                    (fun_getcount
                                                      (vla-item (vla-get-blocks adoc)
                                                                (vla-get-name
                                                                  (vlax-ename->vla-object x)
                                                                  ) ;_ end of vla-get-name
                                                                ) ;_ end of vla-item
                                                      blockname
                                                      ) ;_ end of fun_getcount
                                                    ) ;_ end of lambda
                                                  ) ;_ end of function
                                        (_kpblc-conv-selset-to-ename selset)
                                        ) ;_ end of mapcar
                                ) ;_ end of apply
                         ) ;_ end of itoa
                   " blocks named \""
                   blockname
                   "\" found"
                   ) ;_ end of strcat
           ) ;_ end of princ
    ) ;_ end of if
  (princ)
  ) ;_ end of defun
