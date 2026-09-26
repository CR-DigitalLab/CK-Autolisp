(defun c:text2mtext (/
                     *error*
                     *kpblc-activedoc*
                     kpblc-conv-text-to-mtext
                     _kpblc-error-catch
                     _kpblc-error-print
                     _kpblc-get-msg-norm
                     _kpblc-string-replace
                     _kpblc-conv-value-to-string
                     _kpblc-conv-ent-to-ename
                     _kpblc-conv-ent-to-vla
                     _kpblc-conv-selset-to-ename
                     _kpblc-conv-ent-to-vla
                     _kpblc-conv-vla-to-list
                     _kpblc-property-get
                     _kpblc-property-set
                     _kpblc-get-text-point
                     _kpblc-get-boundingbox
                     _kpblc-get-boundingbox-list
                     )

  (defun *error* (msg)
    (vla-endundomark *kpblc-activedoc*)
    (princ msg)
    (princ)
    ) ;_ end of defun

  (defun _kpblc-get-boundingbox-list (lst / pt_lst maxp minp)
                                     ;|
;**************** lst-getboundingbox.lsp *************
;   Библиотечная функция
;   определения габаритного контейнера
;   для списка VLA объектов
;   Автор  Евгений Елпанов.
;*****************************************************
;   Аргумент lst - список VLA объектов
;   пример получения списка с использованием (ssget) :
(if (setq sset (ssget))
 (setq lst
       (mapcar
        (function vlax-ename->vla-object)
        (vl-remove-if
         (function listp)
         (mapcar (function cadr) (ssnamex sset))
        ) ;_ vl-remove-if
       ) ;_  mapcar
 ) ;_  setq
)
;   Пример вызова:
 (_kpblc-get-boundingbox-list lst)

;   Возвращает список из двух 3d точек
;   '((левая нижняя) (правая верхняя))
|;
    (if (setq lst (cond
                    ((= (type lst) 'list) (mapcar '_kpblc-conv-ent-to-vla lst))
                    ((= (type lst) 'pickset) (_kpblc-conv-selset-to-vla lst))
                    (t nil)
                    ) ;_ end of cond
              ) ;_ end of setq
      (progn
        (setq pt_lst (apply 'append
                            (mapcar '(lambda (x / minp maxp)
                                       (vla-getboundingbox x 'minp 'maxp)
                                       (list (_kpblc-conv-vla-to-list minp)
                                             (_kpblc-conv-vla-to-list maxp)
                                             ) ;_ end of list
                                       ) ;_ end of lambda
                                    lst
                                    ) ;_ end of mapcar
                            ) ;_ end of apply
              ) ;_ end of setq
        (list (list (apply 'min (mapcar 'car pt_lst))
                    (apply 'min (mapcar 'cadr pt_lst))
                    (apply 'min (mapcar 'caddr pt_lst))
                    ) ;_ end of list
              (list (apply 'max (mapcar 'car pt_lst))
                    (apply 'max (mapcar 'cadr pt_lst))
                    (apply 'max (mapcar 'caddr pt_lst))
                    ) ;_ end of list
              ) ;_ end of list
        ) ;_ end of progn
      ) ;_ end of if
    ) ;_ end of defun

  (defun _kpblc-get-boundingbox (minpoint maxpoint)
                                ;|
*    Возвращает список из 4 подсписков - точек прямоугольника. Требуется после
* применения (vla-getboundingbox () 'minp 'maxp) для получения полного описания
* прямоугольника. Корректно работает только в мировой системе координат.
*    Возвращает список точек прямоугольника:
*  4---3
*  |   |
*  1---2
*    Параметры вызова:
*	minpoint	variant, полученный от vla-GetBoundingBox
*	maxpoint	то же
*    В задании точек является критичной последовательность передачи параметров.
* Если первой указать не minpoint, a maxpoint, то получится
*  2---1
*  |   |
*  3---4
*    Примеры вызова:
(vla-GetBoundingBox (vlax-ename->vla-object (car (entsel))) 'minp 'maxp)
(_kpblc-get-boundingbox minp maxp)
|;
    (setq minpoint (_kpblc-conv-vla-to-list minpoint)
          maxpoint (_kpblc-conv-vla-to-list maxpoint)
          ) ;_ end of setq
    (list minpoint
          (list (car maxpoint) (cadr minpoint) (caddr minpoint))
          maxpoint
          (list (car minpoint) (cadr maxpoint) (caddr minpoint))
          ) ;_ end of list
    ) ;_ end of defun

  (defun _kpblc-property-set (obj property value / res)
                             ;|
*    Установка значения свойства объекта.
*    Параметры вызова:
*	obj		указатель на объект
*	property	наименование свойства
*	value		устанавливаемое значение
|;
    (_kpblc-error-catch
      (function
        (lambda ()
          (if (and obj
                   (vlax-property-available-p
                     (setq obj (_kpblc-conv-ent-to-vla obj))
                     property
                     t
                     ) ;_ end of vlax-property-available-p
                   (vlax-read-enabled-p obj)
                   (vlax-write-enabled-p obj)
                   (not (vlax-erased-p obj))
                   ) ;_ end of and
            (progn
              (vlax-put-property obj property value)
              (setq res (vlax-get-property obj property))
              ) ;_ end of progn
            ) ;_ end of if
          ) ;_ end of lambda
        ) ;_ end of function
      '(lambda (x)
         (_kpblc-error-print
           (strcat
             "_kpblc-property-set :"
             " obj->"
             (_kpblc-conv-value-to-string (_kpblc-property-get obj 'objectname))
             " property->"
             (_kpblc-conv-value-to-string property)
             " value-> "
             (_kpblc-conv-value-to-string value)
             ) ;_ end of strcat
           ) ;_ end of _kpblc-error-print
         ) ;_ end of lambda
      ) ;_ end of _kpblc-error-catch
    res
    ) ;_ end of defun

  (defun _kpblc-property-get (obj property / res)
                             ;|
*    Получение значения свойства объекта
|;
    (_kpblc-error-catch
      (function
        (lambda ()
          (if (and obj
                   (vlax-property-available-p
                     (setq obj (_kpblc-conv-ent-to-vla obj))
                     property
                     ) ;_ end of vlax-property-available-p
                   ) ;_ end of and
            (setq res (vlax-get-property obj property))
            ) ;_ end of if
          ) ;_ end of lambda
        ) ;_ end of function
      '(lambda (x)
         (_kpblc-error-print
           (strcat "_kpblc-property-get :"
                   " obj->"
                   (_kpblc-conv-value-to-string
                     (if (vlax-property-available-p
                           (setq obj (_kpblc-conv-ent-to-vla obj))
                           'objectname
                           ) ;_ end of vlax-property-available-p
                       (vla-get-objectname obj)
                       obj
                       ) ;_ end of if
                     ) ;_ end of _kpblc-conv-value-to-string
                   " property->"
                   (_kpblc-conv-value-to-string property)
                   ) ;_ end of strcat
           x
           ) ;_ end of _kpblc-error-print
         ) ;_ end of lambda
      ) ;_ end of _kpblc-error-catch
    res
    ) ;_ end of defun

  (defun _kpblc-get-text-point (ent / res)
                               ;|
*    Определение точки вставки одно- или многострочного текста
*    Параметры вызова:
*	ent	указатель на примитив
*    Примеры вызова:
(_kpblc-get-text-point (_kpblc-get-ent-with-type "*text" nil))
*    Возвращает точечную пару из DXF-кода и его значения.
|;
    (if
      (and (wcmatch (strcase (_kpblc-property-get ent 'objectname)) "ACDBTEXT")
           (/= (_kpblc-property-get ent 'alignment) 0)
           ) ;_ end of and
       (_kpblc-conv-vla-to-list (_kpblc-property-get ent 'textalignmentpoint))
       (_kpblc-conv-vla-to-list (_kpblc-property-get ent 'insertionpoint))
       ) ;_ end of if
    ) ;_ end of defun

  (defun _kpblc-conv-vla-to-list (value / res)
                                 ;|
*    Преобразовывает vlax-variant или vlax-safearray в список.
|;
    (_kpblc-error-catch
      (function
        (lambda ()
          (setq res (cond
                      ((= (type value) 'variant)
                       (_kpblc-conv-vla-to-list (vlax-variant-value value))
                       )
                      ((= (type value) 'safearray)
                       (if (>= (vlax-safearray-get-u-bound value 1) 0)
                         (vlax-safearray->list value)
                         ) ;_ end of if
                       )
                      (t value)
                      ) ;_ end of cond
                ) ;_ end of setq
          ) ;_ end of lambda
        ) ;_ end of function
      '(lambda (x) (_kpblc-error-print "_kpblc-conv-vla-to-list" x))
      ) ;_ end of _kpblc-error-catch
    res
    ) ;_ end of defun

  (defun _kpblc-conv-selset-to-vla (selset)
                                   ;|
*    Функция преобразования набора, полученного через (ssget), в список
* vla-примитивов.
*    Параметры вызова:
*	selset	набор примитивов
*    Примеры вызова:
(_kpblc-conv-selset-to-vla (ssget))
|;
    (if selset
      (mapcar '_kpblc-conv-ent-to-vla
              (_kpblc-conv-selset-to-ename selset)
              ) ;_ end of mapcar
      ) ;_ end of if
    ) ;_ end of defun

  (defun _kpblc-conv-selset-to-ename (selset)
                                     ;|
*    Функция преобразования набора, полученного через (ssget), в список
* ename-примитивов.
*    Параметры вызова:
*	selset	набор примитивов
*    Примеры вызова:
(_kpblc-conv-selset-to-ename (ssget))
|;
    (if selset
      (vl-remove-if 'listp (mapcar 'cadr (ssnamex selset)))
      ) ;_ end of if
    ) ;_ end of defun

  (defun _kpblc-conv-ent-to-vla (ent_value / res)
                                ;|
*    Функция преобразования полученного значения в vla-указатель.
*    Параметры вызова:
*	ent_value	значение, которое надо преобразовать в указатель. Может
*			быть именем примитива, vla-указателем или просто
*			списком.
*			Если не принадлежит ни одному из указанных типов,
*			возвращается nil
*    Примеры вызова:
(_kpblc-conv-ent-to-vla (entlast))
(_kpblc-conv-ent-to-vla (vlax-ename->vla-object (entlast)))
|;
    (_kpblc-error-catch
      (function
        (lambda ()
          (setq
            res
             (cond
               ((= (type ent_value) 'vla-object) ent_value)
               (t
                (vlax-ename->vla-object (_kpblc-conv-ent-to-ename ent_value))
                )
               ) ;_ end of cond
            ) ;_ end of setq
          ) ;_ end of lambda
        ) ;_ end of function
      '(lambda (x) (_kpblc-error-print "_kpblc-conv-ent-to-vla " x))
      ) ;_ end of _kpblc-error-catch
    res
    ) ;_ end of defun

  (defun _kpblc-conv-ent-to-ename (ent_value / res)
                                  ;|
*    Функция преобразования полученного значения в ename
*    Параметры вызова:
*	ent_value	значение, которое надо преобразовать в примитив. Может
*			быть именем примитива, vla-указателем или просто
*			списком.
*			Если не принадлежит ни одному из указанных типов,
*			возвращается nil
*    Примеры вызова:
(_kpblc-conv-ent-to-ename (entlast))
(_kpblc-conv-ent-to-ename (vlax-ename->vla-object (entlast)))
|;
    (_kpblc-error-catch
      (function
        (lambda ()
          (setq res (cond
                      ((= (type ent_value) 'vla-object)
                       (vlax-vla-object->ename ent_value)
                       )
                      ((= (type ent_value) 'ename) ent_value)
                      ((= (type ent_value) 'str) (handent ent_value))
                      ((= (type ent_value) 'list) (cdr (assoc -1 ent_value)))
                      (t nil)
                      ) ;_ end of cond
                ) ;_ end of setq
          ) ;_ end of lambda
        ) ;_ end of function
      '(lambda (x) (_kpblc-error-print " _kpblc-conv-ent-to-ename " x))
      ) ;_ end of _kpblc-error-catch
    res
    ) ;_ end of defun

  (defun _kpblc-conv-value-to-string (value /)
                                     ;|
*    конвертация значения в строку.
|;
    (if value
      (vl-princ-to-string value)
      ""
      ) ;_ end of if
    ) ;_ end of defun

  (defun _kpblc-string-replace (string old_substr new_substr / pos)
                               ;|
*    Функция замены вхождений подстроки в исходную строку на новые.
* Регистрозависимо
*    Параметры вызова:
*	string		исходная строка
*	ols_substr	старая подстрока
*	new_substr	новая подстрока
*    Примеры вызова:
(_kpblc-string-replace "Здесь были ВаВася и ВаВаВаня. Вася" "Ва" "Бу")
	; "Здесь были Буся и Буня. Буся"
|;
    (if (/= old_substr new_substr)
      (while (setq pos (vl-string-search old_substr string))
        (setq string
               (strcat
                 (substr string 1 pos)
                 new_substr
                 (_kpblc-string-replace
                   (substr string (+ (strlen old_substr) pos 1))
                   old_substr
                   new_substr
                   ) ;_ end of _kpblc-string-replace
                 ) ;_ end of strcat
              ) ;_ end of setq
        ) ;_ end of while
      ) ;_ end of if
    string
    ) ;_ end of defun

  (defun _kpblc-get-msg-norm (msg)
                             ;|
*    Нормализация строки запроса для использования в запросах ком.строки
|;
    (vl-string-trim "][ :\n<>" msg)
    ) ;_ end of defun

  (defun _kpblc-error-print (func-name msg)
                            ;|
*    Функция вывода сообщения об ошибке для (_kpblc-error-catch)
*    Параметры вызова:
*	func-name	имя функции, в которой возникла ошибка
*	msg		сообщение об ошибке
|;
    (princ (strcat "\n ** "
                   (_kpblc-get-msg-norm
                     (_kpblc-string-replace
                       (strcase (_kpblc-conv-value-to-string func-name) t)
                       "error"
                       ""
                       ) ;_ end of _kpblc-string-replace
                     ) ;_ end of _kpblc-get-msg-norm
                   " ERROR #"
                   (if msg
                     (strcat
                       (_kpblc-conv-value-to-string (getvar "errno"))
                       ": "
                       (_kpblc-conv-value-to-string msg)
                       ) ;_ end of strcat
                     ": undefined"
                     ) ;_ end of if
                   "\n"
                   ) ;_ end of strcat
           ) ;_ end of princ
    (princ)
    ) ;_ end of defun

  (defun _kpblc-error-catch (protected-function
                             on-error-function
                             /
                             catch_error_result
                             )
                            ;|
*** Функция взята из книжной версии ruCAD'a без каких бы то ни было переделок,
*** кроме переименования.
*    Оболочка отлова ошибок.
*    Параметры вызова:
*	protected-function	- "защищаемая" функция
*	on-error-function	- функция, выполняемая в случае ошибки
|;
    (setq catch_error_result (vl-catch-all-apply protected-function))
    (if (and (vl-catch-all-error-p catch_error_result)
             on-error-function
             ) ;_ end of and
      (apply on-error-function
             (list (vl-catch-all-error-message catch_error_result))
             ) ;_ end of apply
      catch_error_result
      ) ;_ end of if
    ) ;_ end of defun

  (defun kpblc-conv-text-to-mtext (/ selset str mtext minp maxp source *error*)
                                  ;|
*    Функция преобразовывает несколько объектов однострочного и многострочного
* текста в один многострочный (форматирование многострочных текстов оставляется
* на месте).
* Порядок выбора примитивов роли не играет. Выравнивание однострочных текстов
* также не имеет значения.
*    Вставка нового примитива выполняется на текущий слой, с текущими установками.
*    Функция сделана для работы в мировой системе координат.
*    Параметры вызова:
*	нет
*    Примеры вызова:
(kpblc-conv-text-to-mtext)
|;

    (vla-startundomark *kpblc-activedoc*)
    (_kpblc-error-catch
      (function
        (lambda ()
          (if
            (setq
              selset (_kpblc-conv-selset-to-vla (ssget '((0 . "TEXT,MTEXT"))))
              ) ;_ end of setq
             (progn
               ;; Сортируем выбранные примитивы
               ;; Но перед сортировкой им надо сделать нормальные точки
               ;; вставки - меняем y для них по следующей методике:
               ;; Берем 1 элемент, с него получаем контрольную точку и
               ;; проверяем на совпадение у с остальными с точностью до
               ;; высоты текста. Потом то же самое со вторым, третьим и т.п.
               ;; Проходим только по следующим за "отбираемым примитивом".
               (foreach item selset
                 (foreach subitem (cdr (member item selset))
                   (if (equal
                         (cadr (_kpblc-get-text-point item))
                         (cadr (_kpblc-get-text-point subitem))
                         (vla-get-height item)
                         ) ;_ end of equal
                     ;; Меняем эту точку
                     (vla-put-insertionpoint
                       subitem
                       (vlax-3d-point
                         (list (car (_kpblc-get-text-point subitem))
                               (cadr (_kpblc-get-text-point item))
                               (caddr (_kpblc-get-text-point subitem))
                               ) ;_ end of list
                         ) ;_ end of vlax-3d-point
                       ) ;_ end of vla-put-InsertionPoint
                     ) ;_ end of if
                   ) ;_ end of foreach
                 ) ;_ end of foreach
               (setq selset (vl-sort
                              (vl-sort selset
                                       '(lambda (c d)
                                          (< (car (_kpblc-get-text-point c))
                                             (car (_kpblc-get-text-point d))
                                             ) ;_ end of <
                                          ) ;_ end of lambda
                                       ) ;_ end of vl-sort
                              '(lambda (a b)
                                 (> (cadr (_kpblc-get-text-point a))
                                    (cadr (_kpblc-get-text-point b))
                                    ) ;_ end of <
                                 ) ;_ end of lambda
                              ) ;_ end of vl-sort
                     ) ;_ end of setq
               (foreach item selset
                 (if (= (length selset) (length (member item selset)))
                   (setq str (vla-get-textstring item))
                   (setq str
                          (strcat
                            str
                            (if
                              (=
                                (cadr (_kpblc-get-text-point item))
                                (cadr
                                  (_kpblc-get-text-point
                                    (nth
                                      (1-
                                        (- (length selset)
                                           (length (member item selset))
                                           ) ;_ end of -
                                        ) ;_ end of 1-
                                      selset
                                      ) ;_ end of nth
                                    ) ;_ end of _kpblc-get-text-point
                                  ) ;_ end of caddr
                                ) ;_ end of =
                               " "
                               "\\P"
                               ) ;_ end of if
                            (vla-get-textstring item)
                            ) ;_ end of strcat
                         ) ;_ end of setq
                   ) ;_ end of if
                 ) ;_ end of foreach
               (vla-getboundingbox (car selset) 'minp 'maxp)
               (setq
                 mtext (vla-addmtext
                         (vla-objectidtoobject
                           *kpblc-activedoc*
                           (_kpblc-property-get (car selset) 'ownerid)
                           ) ;_ end of vla-ObjectIDToObject
                         (vlax-3d-point
                           (caddr (_kpblc-get-boundingbox minp maxp))
                           ) ;_ end of vlax-3d-point
                         (abs (- (caadr (_kpblc-get-boundingbox-list selset))
                                 (caar (_kpblc-get-boundingbox-list selset))
                                 ) ;_ end of -
                              ) ;_ end of abs
                         str
                         ) ;_ end of vla-addmtext
                 ) ;_ end of setq
               (vla-put-visible mtext :vlax-false)
               (setq source
                      ((lambda (/ tmp)
                         (if
                           (and (not (vl-catch-all-error-p
                                       (vl-catch-all-apply
                                         '(lambda ()
                                            (setq tmp
                                                   (car
                                                     (entsel
                                                       "\nИсточник свойств <Первый элемент набора> : "
                                                       ) ;_ end of entsel
                                                     ) ;_ end of car
                                                  ) ;_ end of setq
                                            ) ;_ end of lambda
                                         ) ;_ end of vl-catch-all-apply
                                       ) ;_ end of VL-CATCH-ALL-ERROR-P
                                     ) ;_ end of not
                                tmp
                                (wcmatch (cdr (assoc 0 (entget tmp))) "*TEXT")
                                ) ;_ end of and
                            tmp
                            (car selset)
                            ) ;_ end of if

                         ) ;_ end of lambda
                       )
                     ) ;_ end of setq
               (foreach prop '("Alignment"         "Backward"
                               "Color"             "elevation"
                               "Fit"               "Height"
                               "HorizontalAlignment"
                               "HorizontalTextPosition"
                               "Invisible"         "Layer"
                               "Linetype"          "LinetypeScale"
                               "Lineweight"        "Normal"
                               "ObliqueAngle"      "ScaleFactor"
                               "StyleName"         "TextColor"
                               "TextGap"           "TextGenerationFlag"
                               "TextHeight"        "TextInside"
                               "TextInsideAlign"   "TextMovement"
                               "TextStyle"         "Thickness"
                               "Type"              "UpsideDown"
                               "Verify"            "VerticalAlignment"
                               "VerticalTextPosition"
                               "Visible"
                               )
                 (_kpblc-property-set
                   mtext
                   prop
                   (_kpblc-property-get source prop)
                   ) ;_ end of _kpblc-property-set
                 ) ;_ end of foreach
               (vla-put-visible mtext :vlax-true)
               (foreach item selset
                 (vla-erase item)
                 ) ;_ end of foreach
               ) ;_ end of progn
             ) ;_ end of if
          ) ;_ end of lambda
        ) ;_ end of function
      '(lambda (x)
         (if mtext
           (vla-erase mtext)
           ) ;_ end of if
         (_kpblc-error-print "kpblc-conv-text-to-mtext" x)
         ) ;_ end of lambda
      ) ;_ end of _kpblc-error-catch
    (vla-endundomark *kpblc-activedoc*)
    (princ)
    ) ;_ end of defun

  (vl-load-com)
  (setq *kpblc-activedoc* (vla-get-activedocument (vlax-get-acad-object)))
  (kpblc-conv-text-to-mtext)
  ) ;_ end of defun
