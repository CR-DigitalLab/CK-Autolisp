(vl-load-com)

;|  **  История изменений **
0.0.2: исправлена ошибка, возникавшая при обработке примитивов на
       заблокированных слоях.
|;

(defun c:erase-wipeout (/                                *kpblc-adoc*
                        _kpblc-eval-value-round          _kpblc-conv-value-to-string
                        _kpblc-error-catch               _kpblc-layer-status-save-by-list
                        _kpblc-layer-status-restore-by-list
                        _kpblc-progress-start            _kpblc-progress-end
                        _kpblc-progress-cmd              _kpblc-progess-continue
                        _kpblc-get-ent-name              _kpblc-property-get
                        _kpblc-conv-ent-to-vla           _kpblc-conv-ent-to-ename
                        )

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

  (defun _kpblc-get-ent-name (ent /)
                             ;|
*    Получение свойства name указанного примитива
*    Параметры вызова:
	ent	указатель на обрабатываемый примитив
		допускаются значения
		ename
		vla-object
		string (хендл объекта текущего файла)
|;
    (cond ((= (type ent) 'str) ent)
          ((_kpblc-property-get ent 'modelspace)
           (strcat (_kpblc-dir-path-and-splash (_kpblc-property-get ent 'path))
                   (_kpblc-property-get ent 'name)
                   ) ;_ end of strcat
           )
          ((_kpblc-property-get ent 'effectivename))
          ((_kpblc-property-get ent 'name))
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

  (defun _kpblc-conv-value-to-string (value /)
                                     ;|
*    конвертация значения в строку.
|;
    (cond
      ((= (type value) 'str) value)
      ((= (type value) 'int) (itoa value))
      ((and (= (type value) 'real) (equal value (_kpblc-eval-value-round value 1.) 1e-6))
       (itoa (fix value))
       )
      ((= (type value) 'real) (rtos value 2 14))
      ((not value) "")
      (t (vl-princ-to-string value))
      ) ;_ end of cond
    ) ;_ end of defun

  (defun _kpblc-eval-value-round (value to)
                                 ;|
;; http://forum.dwg.ru/showthread.php?p=301275
*    Выполняет округление числа до указанной точности
*    Примеры вызова:
(_kpblc-eval-value-round 16.365 0.01) ; 16.37
|;
    (if (zerop to)
      value
      (* (atoi (rtos (/ (float value) to) 2 0)) to)
      ) ;_ end of if
    ) ;_ end of defun

  (vla-startundomark (setq *kpblc-adoc* (vla-get-activedocument (vlax-get-acad-object))))
  (vlax-for blk_def (vla-get-blocks *kpblc-adoc*)
    (if (equal (vla-get-isxref blk_def) :vlax-false)
      (vlax-for ent blk_def
        (if (= (vla-get-objectname ent) "AcDbWipeout")
          (_kpblc-error-catch
            (function
              (lambda ()
                (vla-erase ent)
                ) ;_ end of lambda
              ) ;_ end of function
            (function
              (lambda (x)
                (princ (strcat "\nCan't erase WIPEOUT object at BlockDefinition "
                               (_kpblc-get-ent-name blk_def)
                               ". Check layer state"
                               ) ;_ end of strcat
                       ) ;_ end of princ
                ) ;_ end of lambda
              ) ;_ end of lambda
            ) ;_ end of _kpblc-error-catch
          ) ;_ end of if
        ) ;_ end of vlax-for
      ) ;_ end of if
    ) ;_ end of vlax-for
  (vla-endundomark *kpblc-adoc*)
  (princ)
  ) ;_ end of defun