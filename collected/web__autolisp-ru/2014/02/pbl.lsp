
(vl-load-com)

(defun c:pbl (/                             layer_status                  layer_settings
              selset                        *kpblc-adoc*                  _kpblc-layer-status-save-by-list
              _kpblc-layer-status-restore-by-list                         _kpblc-progress-start
              _kpblc-progress-end           _kpblc-progress-cmd           _kpblc-progess-continue
              _kpblc-conv-vla-to-list       _kpblc-conv-ent-to-ename      _kpblc-conv-ent-to-vla
              _kpblc-acad-version           _kpblc-is-acad-rus            _kpblc-property-get
              _kpblc-property-set           _kpblc-ent-modify-autoregen   _kpblc-list-assoc
              )

  (defun _kpblc-list-assoc (key lst)
                           ;|
*    Замена стандартному assoc
*    Параметры вызова:
	key	ключ
	lst	обрабатываеымй список
|;
    (if (= (type key) 'str)
      (setq key (strcase key))
      ) ;_ end of if
    (car (vl-remove-if-not
           (function
             (lambda (a / b)
               (and (setq b (car a))
                    (or (and (= (type b) 'str) (= (strcase b) key)) (equal b key))
                    ) ;_ end of and
               ) ;_ end of lambda
             ) ;_ end of function
           lst
           ) ;_ end of vl-remove-if-not
         ) ;_ end of car
    ) ;_ end of defun

  (defun _kpblc-ent-modify-autoregen (ent bit value ext_regen / ent_list old_dxf new_dxf layer_dxf70)
                                     ;|
*    Функция модификации указанного бита примитива
*    Параметры вызова:
*	entity	- примитив, полученный через (entsel), (entlast) etc
*	bit	- dxf-код, значение которого надо установить
*	value	- новое значение
*	regen	- выполнять или нет регенерацию примитива сразу. t/ nil
*    Примеры вызова:
(_kpblc-ent-modify-autoregen (entlast) 8 "0" t)	; перенести последний примитив на слой 0
(_kpblc-ent-modify-autoregen (entsel) 62 10 nil)	; установить выбранному примитиву цвет 10
*    Возвращаемое значение:
*	примитив с модифицированным dxf-списком. Примитив перерисовывается в
* зависимости от значения ключа ext_regen
|;
    (setq ent (_kpblc-conv-ent-to-ename ent))
    (if (not
          (and
            (or
              (= (strcase (cdr (assoc 0 (entget ent))) nil) "STYLE")
              (= (strcase (cdr (assoc 0 (entget ent))) nil) "DIMSTYLE")
              (= (strcase (cdr (assoc 0 (entget ent))) nil) "LAYER")
              ) ;_ end of or 
            (= bit 100)
            ) ;_ end of and 
          ) ;_ end of not 
      (progn
        (setq ent_list (entget ent)
              new_dxf  (cons bit
                             (if (and (= bit 62) (= (type value) 'str))
                               (if (= (strcase value) "BYLAYER")
                                 256
                                 0
                                 ) ;_ end of if 
                               value
                               ) ;_ end of if 
                             ) ;_ end of cons 
              ) ;_ end of setq 
        (if (not (equal new_dxf (setq old_dxf (assoc bit ent_list))))
          (progn
            (entmod (if old_dxf
          ;(_KPBLC-LIST-ADD-OR-SUBST ent_list bit (cdr new_dxf))
                      (subst new_dxf old_dxf ent_list)
                      (append ent_list (list new_dxf))
                      ) ;_ end of if 
                    ) ;_ end of entmod
            (if ent_regen
              (entupd ent)
              (redraw ent)
              ) ;_ end of if
            ) ;_ end of progn 
          ) ;_ end of if 
        ) ;_ end of progn 
      ) ;_ end of if 
    ent
    ) ;_ end of defun

  (defun _kpblc-conv-selset-to-ename (selset / tab item)
                                     ;|
*    Преобразование набора, полученного через ssget, в список ename-представлени
* примитивов.
*    Параметры вызова:
	selset	набор примитивов
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

  (defun _kpblc-property-set (obj prop value /)
                             ;|
*    Назначение свойства объекту
*    Параметры вызова:
	obj		указатель на обрабатываемый объект
	prop	наименование свойства
	value	устанавливаемое значение
*
|;
    (if (and (setq obj (_kpblc-conv-ent-to-vla obj))
             ((lambda (/ res)
                (if (member (setq res (vl-catch-all-apply
                                        (function
                                          (lambda ()
                                            (vlax-erased-p obj)
                                            ) ;_ end of lambda
                                          ) ;_ end of function
                                        ) ;_ end of vl-catch-all-apply
                                  ) ;_ end of setq
                            (list t nil)
                            ) ;_ end of member
                  (not (vlax-erased-p obj))
                  t
                  ) ;_ end of if
                ) ;_ end of lambda
              )
             (vlax-property-available-p obj prop t)
             ) ;_ end of and
      (vl-catch-all-apply
        (function
          (lambda ()
            (vlax-put-property obj
                               prop
                               ((lambda (/ tmp)
                                  (setq tmp (vlax-get-property obj prop))
                                  (cond
;;;                                  ((= (strcase (_kpblc-conv-value-to-string prop)) "TRUECOLOR")
;;;                                   ;; Для TrueColor передавать строку из RGB, разделенных запятой
;;;                                   (_kpblc-conv-color-rgb-to-true value)
;;;                                   )
                                    ((member tmp (list :vlax-false :vlax-true))
                                     (_kpblc-conv-value-bool-to-vla value)
                                     )
                                    ((= (type tmp) 'int) (_kpblc-conv-value-to-int value))
                                    ((= (type tmp) 'real) (_kpblc-conv-value-to-real value))
                                    ((= (type tmp) 'str) (_kpblc-conv-value-to-string value))
                                    ((and (= (type tmp) 'list) (= (type value) 'str))
                                     (apply (function append)
                                            (mapcar
                                              (function
                                                (lambda (x)
                                                  (_kpblc-conv-string-to-list x ",")
                                                  ) ;_ end of lambda
                                                ) ;_ end of function
                                              (_kpblc-conv-string-to-list value " ")
                                              ) ;_ end of mapcar
                                            ) ;_ end of apply
                                     )
                                    ((= (type tmp) 'list) (_kpblc-conv-value-to-list value))
                                    (t tmp)
                                    ) ;_ end of cond
                                  ) ;_ end of LAMBDA
                                )
                               ) ;_ end of vlax-put-property
            ) ;_ end of lambda
          ) ;_ end of function
        ) ;_ end of vl-catch-all-apply
      ) ;_ end of if
    (if (vlax-property-available-p obj prop)
      (vlax-get-property obj prop)
      ) ;_ end of if
    ) ;_ end of defun

  (defun _kpblc-property-get (obj property / res)
                             ;|
*    Получение значения свойства объекта
|;
    (vl-catch-all-apply
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
      ) ;_ end of vl-catch-all-apply
    res
    ) ;_ end of defun

  (defun _kpblc-is-acad-rus ()
                            ;|
*    Проверяет, является ли AutoCAD русским. Для версий AutoCAD до 2012 включительно возвращает t
* независимо от локализации. В версии 2013 обрабатывает язык AutoCAD'a
|;
    (or (<= (_kpblc-acad-version) 18.2)
        (= (vla-get-localeid (vlax-get-acad-object)) 1049)
        ) ;_ end of or
    ) ;_ end of defun

  (defun _kpblc-acad-version ()
                             ;|
*    Определение номера сборки AutoCAD
*    Возвращаемое значение: Число двойной точности. Для AutoCAD 2005 вернет 16.1, для 2006 - 16.2 и т.д.
Примеры вызова:
(_kpblc-acad-version)
|;
    (atof (getvar "acadver"))
    ) ;_ end of defun

  (defun _kpblc-conv-ent-to-ename (ent_value /)
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
    ;; "_kpblc-conv-ent-to-ename")
    (cond
      ((= (type ent_value) 'vla-object)
       (vlax-vla-object->ename ent_value)
       )
      ((= (type ent_value) 'ename) ent_value)
          ;((= (type ent_value) 'str) (handent ent_value))
      ((= (type ent_value) 'list) (cdr (assoc -1 ent_value)))
      (t nil)
      ) ;_ end of cond
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
    (cond
      ((= (type ent_value) 'vla-object) ent_value)
      ((= (type ent_value) 'ename) (vlax-ename->vla-object ent_value))
      ((setq res (_kpblc-conv-ent-to-ename ent_value))
       (vlax-ename->vla-object res)
       )
      ) ;_ end of cond
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
      ((and (member (type value) (list 'ename 'str 'vla-object))
            (= (type (_kpblc-conv-ent-to-vla value)) 'vla-object)
            (vlax-property-available-p (_kpblc-conv-ent-to-vla value) 'count)
            ) ;_ end of and
       (vlax-for sub (_kpblc-conv-ent-to-vla value)
         (setq res (cons sub res))
         ) ;_ end of vlax-for
       )
      (t value)
      ) ;_ end of cond
    ) ;_ end of defun

  (defun _kpblc-progess-continue (msg pos)
    (if *kpblc-is-express-loaded*
      (acet-ui-progress (rem pos 32000))
      (_kpblc-progress-cmd msg pos)
      ) ;_ end of if
    ) ;_ end of defun

  (defun _kpblc-progress-cmd (msg pos / lst)
                             ;|
*    Выводит в ком.строку сообщение с "прогрессом"
*    Параметры вызова:
	msg		строковое сообщение
	pos		счетчик выполняемых действий
|;
    (if msg
      (princ (strcat "\r" msg " : " (nth (rem pos 4) '("-" "\\" "|" "/"))))
      (princ "\n" (_kpblc-conv-value-to-string msg) " закончено")
      ) ;_ end of if
    ) ;_ end of defun

  (defun _kpblc-progress-end ()
    (if *kpblc-is-express-loaded*
      (acet-ui-progress)
      (princ)
      ) ;_ end of if
    ) ;_ end of defun

  (defun _kpblc-progress-start (msg range)
                               ;|
*    Инициализирует прогресс-бар
*    Параметры вызова:
	msg		показываемое сообщение
	range	общая длина прогресс-бара
|;
    (if *kpblc-is-express-loaded*
      (if msg
        (acet-ui-progress msg (min 32000 range))
        (acet-ui-progress (min 32000 range))
        ) ;_ end of if
      (_kpblc-progress-cmd msg range)
      ) ;_ end of if
    ) ;_ end of defun

  (defun _kpblc-layer-status-restore-by-list (doc lst-names lst-status / layer prg_pos prg_msg)
                                             ;|
*    Функция восстановления состояния слоев из *kpblc-list-layer-status*
*    Параметры вызова:
	doc		указатель на обрабатываемый документ
	lst-names	список имен слоев, состояние которых надо восстановить.
			nil -> брать все из lst-status
	lst-status	список состояния слоев, сохраненный
			_kpblc-layer-status-save-by-list. nil -> ничего не делается
*    Если имя файла отсутствует в списке состояния, он не обрабатывается.
|;
    (setq doc        (if (not doc)
                       *kpblc-adoc*
                       doc
                       ) ;_ end of if
          lst-status (mapcar
                       (function (lambda (x)
                                   (cons (cons (vla-get-name (car x)) (car x)) (cdr x))
                                   ) ;_ end of LAMBDA
                                 ) ;_ end of function
                       (vl-remove-if
                         (function (lambda (x) (vlax-erased-p (car x))))
                         lst-status
                         ) ;_ end of vl-remove-if
                       ) ;_ end of mapcar
          lst-names  (cond
                       ((not lst-names)
                        (mapcar (function (lambda (x) (caar x)))
                                lst-status
                                ) ;_ end of mapcar
                        )
                       (t
                        (vl-remove-if
                          (function (lambda (x)
                                      (vlax-erased-p
                                        (vla-item (vla-get-layers *kpblc-adoc*) x)
                                        ) ;_ end of vlax-erased-p
                                      ) ;_ end of lambda
                                    ) ;_ end of function
                          lst-names
                          ) ;_ end of vl-remove-if
                        )
                       ) ;_ end of cond
          lst-names  (vl-remove-if-not
                       (function
                         (lambda (x)
                           (member (strcase x)
                                   (mapcar (function strcase)
                                           (mapcar (function caar) lst-status)
                                           ) ;_ end of mapcar
                                   ) ;_ end of member
                           ) ;_ end of lambda
                         ) ;_ end of function
                       lst-names
                       ) ;_ end of vl-remove-if-not
          prg_msg    (if (_kpblc-is-acad-rus)
                       "Восстановление состояния слоев"
                       "Restore layer status"
                       ) ;_ end of if
          prg_pos    0
          ) ;_ end of setq
    (_kpblc-progress-start prg_msg (length lst-names))
    (foreach item lst-names
      (_kpblc-progess-continue prg_msg (setq prg_pos (1+ prg_pos)))
      (if (and (= (type (setq layer (vl-catch-all-apply
                                      (function
                                        (lambda ()
                                          (vla-item (vla-get-layers doc)
                                                    item
                                                    ) ;_ end of vla-item
                                          ) ;_ end of lambda
                                        ) ;_ end of function
                                      ) ;_ end of vl-catch-all-apply
                              ) ;_ end of setq
                        ) ;_ end of type
                  'vla-object
                  ) ;_ end of =
               (not (vlax-erased-p layer))
               ) ;_ end of and
        (foreach prop
                      (cdr (_kpblc-list-assoc
                             item
                             (mapcar '(lambda (x) (cons (caar x) (cdr x))) lst-status)
                             ) ;_ end of _kpblc-list-assoc
                           ) ;_ end of cdr
          (vl-catch-all-apply
            (function
              (lambda ()
                (vlax-put-property layer (car prop) (cdr prop))
                ) ;_ end of lambda
              ) ;_ end of function
            ) ;_ end of vl-catch-all-apply
          ) ;_ end of foreach
        ) ;_ end of if
      ) ;_ end of foreach
    (_kpblc-progress-end)
    ) ;_ end of defun

  (defun _kpblc-layer-status-save-by-list (doc lst options / res name prg_msg prg_pos)
                                          ;|
*    Функция разблокировки и разморозки слоев
*    Параметры вызова:
	doc	указатель на обрабатываемый документ. nil -> текущий
	lst	список имен слоев.
		<ИмяСлоя>	; допускается использование масок
		nil -> обрабатывать все
	options список предпринимаемых действий:
      '(("on" . <Включать слои>)		; t | nil
	("thaw" . <Размораживать слои>)		; t | nil
	("unlock" . <Разблокировать слои>)	; t | nil
	)
		nil -> '(("on" . nil) ("thaw" . t) ("unlock" . t))
*    Возвращает список вида
'((<vla-указатель на слой> ("layeron" . :vlax-true) ("freeze" . :vlax-false) ("lock" . :vlax-true)))
|;
    (if (not options)
      (setq options '(("thaw" . t) ("unlock" . t)))
      ) ;_ end of if
    (setq doc     (cond (doc)
                        (t *kpblc-adoc*)
                        ) ;_ end of cond
          lst     (cond
                    (lst
                     (strcase
                       (_kpblc-conv-list-to-string (_kpblc-conv-value-to-list lst) ",")
                       ) ;_ end of strcase
                     )
                    (t "*")
                    ) ;_ end of cond
          prg_msg (if (_kpblc-is-acad-rus)
                    "Обработка слоев"
                    "Layers proceeding"
                    ) ;_ end of if
          prg_pos 0
          ) ;_ end of setq
    (_kpblc-progress-start prg_msg (vla-get-count (vla-get-layers doc)))
    (vlax-for layer (vla-get-layers doc)
      (_kpblc-progess-continue prg_msg (setq prg_pos (1+ prg_pos)))
      (setq res
                 (cons
                   (cons
                     layer
                     (mapcar '(lambda (x) (cons x (_kpblc-property-get layer x)))
                             '("layeron" "freeze" "lock")
                             ) ;_ end of mapcar
                     ) ;_ end of list
                   res
                   ) ;_ end of cons
            name (strcase (vla-get-name layer))
            ) ;_ end of setq
      (if (wcmatch name lst)
        (progn
          (if (cdr (assoc "on" options))
            (vla-put-layeron layer :vlax-true)
            ) ;_ end of if
          (if (cdr (assoc "unlock" options))
            (vla-put-lock layer :vlax-false)
            ) ;_ end of if
          (if (cdr (assoc "thaw" options))
            (vl-catch-all-apply '(lambda () (vla-put-freeze layer :vlax-false)))
            ) ;_ end of if
          ) ;_ end of progn
        ) ;_ end of if
      ) ;_ end of vlax-for
    (_kpblc-progress-end)
    res
    ) ;_ end of defun

  (vla-startundomark (setq *kpblc-adoc* (vla-get-activedocument (vlax-get-acad-object))))
  (setq *kpblc-is-express-loaded* (member "ACETUTIL.ARX" (mapcar (function strcase) (arx)))
        layer_status              (_kpblc-layer-status-save-by-list nil nil '(("unlock" . t) ("thaw" . t)))
        layer_settings            (mapcar
                                    (function
                                      (lambda (x)
                                        (cons x
                                              (vl-remove-if-not
                                                (function
                                                  (lambda (a)
                                                    (member (car a) '(62 6 370 420))
                                                    ) ;_ end of lambda
                                                  ) ;_ end of function
                                                (entget (tblobjname "layer" x))
                                                ) ;_ end of vl-remove-if-not
                                              ) ;_ end of cons
                                        ) ;_ end of lambda
                                      ) ;_ end of function
                                    (vl-remove-if
                                      (function (lambda (x) (wcmatch x "*|*")))
                                      (mapcar (function vla-get-name) (_kpblc-conv-vla-to-list (vla-get-layers *kpblc-adoc*)))
                                      ) ;_ end of vl-remove-if
                                    ) ;_ end of mapcar
        ) ;_ end of setq
  (foreach layer layer_settings
    (foreach ent (_kpblc-conv-selset-to-ename (ssget "_X" (list (cons 8 (car layer)))))
      (if (not (cdr (assoc 6 (entget ent))))
        (_kpblc-ent-modify-autoregen ent 6 (cdr (assoc 6 (cdr layer))) nil)
        ) ;_ end of if
      (if (member (cdr (assoc 62 (entget ent))) (list nil 256))
        (_kpblc-ent-modify-autoregen ent 62 (cdr (assoc 62 (cdr layer))) nil)
        ) ;_ end of if
      (if (not (cdr (assoc 370 (entget ent))))
        (_kpblc-ent-modify-autoregen ent 370 (cdr (assoc 370 (cdr layer))) nil)
        ) ;_ end of if
      (if (and (not (cdr (assoc 420 (entget ent)))) (cdr (assoc 420 (cdr layer))))
        (_kpblc-ent-modify-autoregen ent 420 (cdr (assoc 420 (cdr layer))) nil)
        ) ;_ end of if
;;;      (foreach prop (cdr layer)
;;;        (vl-catch-all-apply
;;;          (function
;;;            (lambda ()
;;;              (_kpblc-ent-modify-autoregen ent (car prop) (cdr prop) nil)
;;;              ) ;_ end of lambda
;;;            ) ;_ end of function
;;;          ) ;_ end of vl-catch-all-apply
;;;        ) ;_ end of foreach
      ) ;_ end of foreach
    ) ;_ end of foreach
  (_kpblc-layer-status-restore-by-list nil nil layer_status)
  (vla-regen *kpblc-adoc* acallviewports)
  (vla-endundomark *kpblc-adoc*)
  (princ)

  ) ;_ end of defun
