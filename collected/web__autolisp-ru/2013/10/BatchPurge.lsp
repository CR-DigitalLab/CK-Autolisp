(vl-load-com)

(defun c:bp (/                          *kpblc-datas*              dcl_id
             dcl_lst                    dcl_res                    doc
             err_log                    file                       grp
             handle                     item                       path
             prop                       x                          _la
             prg_pos                    prg_msg                    prg_max
             demandload                 vl-browsefolder            vl-browsefiles-in-directory-nested
             vl-find-file-or-dir        _kpblc-acad-version        _kpblc-cmd-dcl-callback
             _kpblc-cmd-dcl-create      _kpblc-conv-ent-to-ename   _kpblc-conv-ent-to-vla
             _kpblc-conv-list-to-string _kpblc-conv-string-to-list _kpblc-conv-value-to-bool
             _kpblc-conv-value-to-int   _kpblc-conv-value-to-string
             _kpblc-conv-vla-to-list    _kpblc-dir-create          _kpblc-dir-path-and-splash
             _kpblc-dir-path-no-splash  _kpblc-error-catch         _kpblc-eval-value-round
             _kpblc-get-profile-name    _kpblc-get-path-root-temp  _kpblc-is-acad-rus
             _kpblc-is-file-read-only   _kpblc-list-add-or-subst   _kpblc-list-dublicates-remove
             _kpblc-list-nth            _kpblc-odbx-close          _kpblc-odbx-open
             _kpblc-odbx                _kpblc-progress-continue   _kpblc-progress-cmd
             _kpblc-progress-end        _kpblc-progress-modemacro  _kpblc-progress-start
             _kpblc-strcase             _kpblc-vars-set
             )

  (defun _kpblc-acad-version ()
                             ;|
*    Определение номера сборки AutoCAD
*    Возвращаемое значение: Число двойной точности. Для AutoCAD 2005 вернет 16.1, для 2006 - 16.2 и т.д.
Примеры вызова:
(_kpblc-acad-version)
|;
    (atof (getvar "acadver"))
    ) ;_ end of defun

  (defun _kpblc-cmd-dcl-callback (key value ref-list)
                                 ;|
*    CallBack-функция для диалога
|;
    (cond
      ((= key "txt_folder")
       (if (or (findfile value)
               (vl-find-file-or-dir value)
               ) ;_ end of or
         (progn
           (set ref-list (_kpblc-list-add-or-subst (eval ref-list) "path" (_kpblc-dir-path-no-splash value)))
           (mode_tile "accept" 0)
           ) ;_ end of progn
         (mode_tile "accept" 1)
         ) ;_ end of if
       )
      ((and (= key "chk_log")
            (not (_kpblc-conv-value-to-bool value))
            ) ;_ end of and
       (set ref-list (_kpblc-list-add-or-subst (eval ref-list) key (_kpblc-conv-value-to-bool value)))
       (set ref-list (_kpblc-list-add-or-subst (eval ref-list) "logfile" nil))
       (mode_tile "btn_log" 1)
       )
      ((and (= key "chk_log")
            (_kpblc-conv-value-to-bool value)
            ) ;_ end of and
       (set ref-list (_kpblc-list-add-or-subst (eval ref-list) key (_kpblc-conv-value-to-bool value)))
       (mode_tile "btn_log" 0)
       ;; (mode_tile "accept" 1)
       )
      ((= key "logfile")
       (set ref-list (_kpblc-list-add-or-subst (eval ref-list) key value))
       )
      (t
       (set ref-list (_kpblc-list-add-or-subst (eval ref-list) key (_kpblc-conv-value-to-bool value)))
       )
      ) ;_ end of cond
    ) ;_ end of defun

  (defun _kpblc-cmd-dcl-create (/ dcl_file dcl_handle)
                               ;|
*    Создание файла диалога
|;
    (setq dcl_file   (strcat (_kpblc-dir-path-no-splash (_kpblc-get-path-root-temp)) "\\dlg.dcl")
          dcl_handle (open dcl_file "w")
          reghive    "HKEY_CURRENT_USER\\Software\\kpblc\\BatchPurge"
          ) ;_ end of setq
    (foreach item
             (list (strcat "dlg:dialog{label=\"Пакетная обработка файлов v." (cdr (assoc "ver" *kpblc-datas*)) " \";")
                   "	:text{label=\"Программа проходит по всем файлам dwg, включая подкаталоги\";}"
                   "	:column{label=\"Настройки программы\";"
                   "		:row{children_fixed_width=true;"
                   "			:edit_box{key=\"txt_folder\";label=\"Каталог\";width=60;}"
                   "			:button{key=\"btn_folder\";label=\"...\";width=3;}"
                   "			}"
                   "		}"
                   "	:column{label=\"Выполняемые действия\";"
                   "		:toggle{key=\"chk_purge\";label=\"Очистка файла (аналог _.purge)\";}"
                   "		:toggle{key=\"chk_purgeapps\";label=\"Очистка зарегистрированных приложений\";}"
                   "		:toggle{key=\"chk_purgegroups\";label=\"Очистить пустые группы\";}"
                   "		:toggle{key=\"chk_proxy\";label=\"<Эксперимент> Очистка прокси\";}"
                   "		:toggle{key=\"chk_normblocks\";label=\"Нормализация блоков\";}"
                   "		:row{label=\"Лог\";children_fixed_width=true;"
                   "			:toggle{key=\"chk_log\";label=\"Вести лог работы\";}"
                   "			:text{label=\"Путь к файлу лога\";key=\"logfile\";}"
                   "			:button{key=\"btn_log\";label=\"...\";width=3;}"
                   "			}"
                   "		}"
                   "	:row{children_width=true;"
                   "		:button{key=\"remember\";label=\"Сохранить настройки\";width=10;}"
                   "		:button{key=\"accept\";label=\"OK\";is_default=true;width=10;}"
                   "		:button{key=\"cancel\";label=\"Отмена\";is_cancel=true;width=10;}"
                   "		}"
                   "	}"
                   ) ;_ end of list
      (write-line item dcl_handle)
      ) ;_ end of foreach
    (close dcl_handle)
    dcl_file
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
  (defun _kpblc-conv-string-to-list (string separator / i)
                                    ;|
*    Функция разбора строки. Возвращает список либо точечную пару.
*    Параметры вызова:
*  string    разбираемая строка
*  separator  символ, используемый в качестве разделителя частей
*    Примеры вызова:
(_kpblc-conv-string-to-list "1;2;3;4;5;6" ";")  ;'(1 2 3 4 5 6)
(_kpblc-conv-string-to-list "1;2" ";")    ;'(1 2)
*    За основу взяты уроки Евгения Елпанова по рекурсиям
|;
    (cond
      ((= string "") nil)
      ((vl-string-search separator string)
       ((lambda (/ pos res)
          (while (setq pos (vl-string-search separator string))
            (setq res    (cons (substr string 1 pos) res)
                  string (substr string (+ (strlen separator) 1 pos))
                  ) ;_ end of setq
            ) ;_ end of while
          (reverse (cons string res))
          ) ;_ end of lambda
        )
       )
      ((wcmatch (strcase string) (strcat "*" (strcase separator) "*"))
       ((lambda (/ pos res _str prev)
          (setq pos  1
                prev 1
                _str (substr string pos)
                ) ;_ end of setq
          (while (<= pos (1+ (- (strlen string) (strlen separator))))
            (if ;; (wcmatch (strcase (substr string pos)) (strcase (strcat separator "*")))
                (wcmatch (strcase (substr string pos (strlen separator))) (strcase separator))
              (setq res    (cons (substr string 1 (1- pos)) res)
                    string (substr string (+ (strlen separator) pos))
                    pos    0
                    ) ;_ end of setq
              ) ;_ end of if
            (setq pos (1+ pos))
            ) ;_ end of while
          (if (< (strlen string) (strlen separator))
            (setq res (cons string res))
            ) ;_ end of if
          (if (or (not res) (= _str string))
            (setq res (list string))
            (reverse res)
            ) ;_ end of if
          ) ;_ end of lambda
        )
       )
      (t (list string))
      ) ;_ end of cond
    ) ;_ end of defun
  (defun _kpblc-conv-value-to-bool (value)
                                   ;|
*    Функция преобразования переданного значения в лисповое t|nil
*    Параметры вызова:
*  value  преобразовываемое значение
*    Примеры вызова:
(_kpblc-conv-value-to-bool "0")   ; nil
_$ (_kpblc-conv-value-to-bool "1")  ; T
_$ (_kpblc-conv-value-to-bool "-1")  ; T
*    Для ошибочных значений возвращает nil.
|;
    (cond
      ((= (type value) 'str)
       (not (member (strcase value t) '("" "0" "n" "н" "false" "f")))
       )
      ((= (type value) 'vl-catch-all-apply-error)
       nil
       )
      (t
       (not (member value '(0 nil :vlax-false)))
       )
      ) ;_ end of cond
    ) ;_ end of defun
  (defun _kpblc-conv-value-to-int (value /)
                                  ;|
*    конвертация значения в целое. Для VLA-объектов возвращается nil.
*    Точечные списки не обрабатываются.
|;
    (cond
      ((not value) 0)
      ((equal value t) 1)
      (t (atoi (_kpblc-conv-value-to-string value)))
      ) ;_ end of cond
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
  (defun _kpblc-dir-create (path / tmp)
                           ;|
*    Гарантированное создание каталога.
*    Параметры вызова:
	path	создаваемый каталог
|;
    (cond
      ((vl-file-directory-p path) path)
      ((setq tmp (_kpblc-dir-create (vl-filename-directory path)))
       (vl-mkdir
         (strcat tmp
                 "\\"
                 (vl-filename-base path)
                 (cond ((vl-filename-extension path))
                       (t "")
                       ) ;_ end of cond
                 ) ;_ end of strcat
         ) ;_ end of vl-mkdir
       (if (vl-file-directory-p path)
         path
         ) ;_ end of if
       )
      ) ;_ end of cond
    ) ;_ end of defun
  (defun _kpblc-dir-path-and-splash (path)
                                    ;|
*    Возвращает путь со слешем в конце
*    Параметры вызова:
*	path	- обрабатываемый путь
*    Примеры вызова:
(_kpblc-dir-path-and-splash "c:\\kpblc-cad")	; "c:\\kpblc-cad\\"
|;
    (strcat (vl-string-right-trim "\\" path) "\\")
    ) ;_ end of defun
  (defun _kpblc-dir-path-no-splash (path)
                                   ;|
*    Возвращает путь без слеша в конце
*    Параметры вызова:
*	path	- обрабатываемый путь
*    Примеры вызова:
(_kpblc-dir-path-no-splash "c:\\kpblc-cad\\")	; "c:\\kpblc-cad"
|;
    (vl-string-right-trim "\\" path)
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
*  protected-function  - "защищаемая" функция
*  on-error-function  - функция, выполняемая в случае ошибки
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
  (defun _kpblc-get-path-root-temp (/ _tmp)
                                   ;|
*    Возвращает путь временных файлов AutoCAD
|;
    (setq _tmp (_kpblc-dir-path-no-splash
                 (_kpblc-dir-create
                   (strcat (vl-string-right-trim
                             "\\"
                             (cond
                               ((= (type (setq _tmp (vl-registry-read
                                                      "HKEY_CURRENT_USER\\Environment"
                                                      "Temp"
                                                      ) ;_ end of vl-registry-read
                                               ) ;_ end of setq
                                         ) ;_ end of type
                                   'list
                                   ) ;_ end of =
                                (strcat (getenv "USERPROFILE")
                                        (vl-string-left-trim
                                          "%USERPROFILE%"
                                          (strcase
                                            (cdr
                                              _tmp
                                              ) ;_ end of cdr
                                            ) ;_ end of strcase
                                          ) ;_ end of vl-string-left-trim
                                        ) ;_ end of strcat
                                )
                               ((= (type _tmp) 'str) _tmp)
                               (t (getenv "TEMP"))
                               ) ;_ end of cond
                             ) ;_ end of vl-string-right-trim
                           "\\kpblc\\"
                           (_kpblc-get-profile-name)
                           ) ;_ end of strcat
                   ) ;_ end of _kpblc-dir-create
                 ) ;_ end of _kpblc-dir-path-no-splash
          ) ;_ end of setq
    _tmp
    ) ;_ end of defun
  (defun _kpblc-get-profile-name ()
                                 ;|
*    ЗАмена стандартному (getvar "cprofile")
|;
    (vl-list->string
      (vl-remove-if-not
        (function
          (lambda (x)
            (or (<= 48 x 57)
                (<= 65 x 90)
                (<= 97 x 122)
                (= x 32)
                (<= 224 x 255)
                (<= 192 x 223)
                ) ;_ end of or
            ) ;_ end of LAMBDA
          ) ;_ end of function
        (vl-string->list (getvar "cprofile"))
        ) ;_ end of vl-remove-if
      ) ;_ end of vl-list->string
    ) ;_ end of defun
  (defun _kpblc-is-acad-rus ()
                            ;|
*    Проверяет, является ли AutoCAD русским. Для версий AutoCAD до 2012 включительно возвращает t
* независимо от локализации. В версии 2013 обрабатывает язык AutoCAD'a
|;
    (or (<= (_kpblc-acad-version) 18.2)
        (/= (_kpblc-acad-version) 19.)
        (= (vla-get-localeid (vlax-get-acad-object)) 1049)
        ) ;_ end of or
    ) ;_ end of defun
  (defun _kpblc-is-file-read-only (file-name / file_hangle res)
                                  ;|
*    Проверяет, является ли файл "read-only". Возвращает t, если да. Проверки
* наличия файла не выполняется.
*    Параметры вызова:
*  file-name  полное имя файла, с путем.
(_kpblc-is-file-read-only "Z:\\КТО transit\\Разное\\Устройство молниезащиты.dwg")
|;
    (and file-name
         (findfile file-name)
         (or (not (vl-file-systime file-name))
             ((lambda (/ svr obj res)
                (setq svr (vlax-get-or-create-object "Scripting.FileSystemObject")
                      obj (vlax-invoke-method svr 'getfile file-name)
                      res (vlax-get-property obj 'attributes)
                      ) ;_ end of setq
                (vlax-release-object obj)
                (vlax-release-object svr)
                (setq obj nil
                      svr nil
                      ) ;_ end of setq
                (/= (* 2 (/ res 2)) res)
                ) ;_ end of lambda
              )
             ) ;_ end of or
         ) ;_ end of and
    ) ;_ end of defun
  (defun _kpblc-list-add-or-subst (lst key value)
                                  ;|
*    Производит замену или дополнение элемента списка новым
*    Параметры вызова:
  lst      обрабатываемый список
  key      ключ
  value    устанавливаемое значение
|;
    (if (not value)
      (vl-remove-if (function (lambda (x) (= (car x) key))) lst)
      (if (cdr (assoc key lst))
        (subst (cons key value) (assoc key lst) lst)
        (cons (cons key value)
              (vl-remove-if
                (function
                  (lambda (x)
                    (= (car x) key)
                    ) ;_ end of lambda
                  ) ;_ end of function
                lst
                ) ;_ end of vl-remove-if
              ) ;_ end of cons
        ) ;_ end of if
      ) ;_ end of if
    ) ;_ end of defun
  (defun _kpblc-list-dublicates-remove (lst / result)
                                       ;|
*    Функция исключения дубликатов элементов списка 
*    Параметры вызова:
*  lst  обрабатываемый список
*    Возвращаемое значение: список без дубликатов соседних элементов
*    Примеры вызова:
(_kpblc-list-dublicates-remove '((0.0 0.0 0.0) (10.0 0.0 0.0) (10.0 0.0 0.0) (0.0 0.0 0.0)) nil)
((0.0 0.0 0.0) (10.0 0.0 0.0) (0.0 0.0 0.0))
|;
    (foreach x lst
      (if (not (member x result))
        (setq result (cons x result))
        ) ;_ end of if
      ) ;_ end of foreach
    (reverse result)
    ) ;_ end of defun
  (defun _kpblc-list-nth (num lst)
                         ;|
*    Получение элемента списка по номеру даже в том случае, если номер
* меньше 0 или больше (1- ДлинаСписка)
*    Параметры вызова:
  num    порядковый номер элемента в списке
  lst    опрашиваемый список
|;
    (if lst
      (cond
        ((< num 0) (_kpblc-list-nth (+ (length lst) num) lst))
        ((>= num (length lst)) (_kpblc-list-nth (- num (length lst)) lst))
        (t (nth num lst))
        ) ;_ end of cond
      ) ;_ end of if
    ) ;_ end of defun
  (defun _kpblc-odbx-close (conn)
                           ;|
*    Закрытие файла, открытого ранее через _kpblc-odbx-*. С попыткой сохранения
*    Параметры вызова:
*  conn  соединение с ObjectDBX, созданное ранее через (_kpblc-odbx)
*    либо список:
      '(("conn" . <ObjectDBXConnection>)  ; то же самое
  ("save" . t)      ; сохранять или нет изменения
  ("file" . "c:\\temp\\tmp.dwg")  ; имя, под которым сохранять. nil ->
    ; использовать текущее
|;
    (if (and (= (type conn) 'list)
             (cdr (assoc "save" conn))
             ) ;_ end of and
      (progn
        (vlax-invoke
          (cdr (assoc "conn" conn))
          'saveas
          (cond
            ((cdr (assoc "file" conn))
             (strcat
               (_kpblc-dir-path-and-splash (vl-filename-directory file))
               (_kpblc-string-ext (vl-filename-base file) "dwg")
               ) ;_ end of strcat
             )
            (t (vla-get-name (cdr (assoc "conn" conn))))
            ) ;_ end of cond
          ) ;_ end of vlax-invoke
        ) ;_ end of progn
      ) ;_ end of if
    (vl-catch-all-apply
      '(lambda ()
         (vlax-release-object
           (if (= (type conn) 'list)
             (cdr (assoc "conn" conn))
             conn
             ) ;_ end of if
           ) ;_ end of vlax-release-object
         ) ;_ end of lambda
      ) ;_ end of vl-catch-all-apply
    (setq conn nil)
    ) ;_ end of defun
  (defun _kpblc-odbx-open (file odbx / res obj tmp_file)
                          ;|
*    Открытие любого файла, даже в режиме "ReadOnly"
*    Параметры вызова:
  file  полное имя открываемого файла. Только строка, контроля не
    выполняется
  odbx  ObjectDBX-интерфейс, созданный (_kpblc-odbx).
*    Возвращает список вида:
  '(("obj" . <vla-указатель на гарантированно открытый документ>)
    ("close" . t | nil)  ; допускается ли закрытие файла
    ("save" . t | nil)  ; допускается ли сохранение файла
    ("write" . t | nil)  ; допускается ли запись в файл
    ("name" . <строка имени файла>))
|;
    (cond
      ((not file)
       (setq res (list (cons "obj" (vla-get-activedocument (vlax-get-acad-object)))
                       (cons "write" t)
                       (cons "name" (vla-get-fullname *kpblc-adoc*))
                       ) ;_ end of list
             ) ;_ end of setq
       )
      ((member
         (strcase file)
         (mapcar (function (lambda (x) (strcase (vla-get-fullname x))))
                 (_kpblc-conv-vla-to-list
                   (vla-get-documents (vlax-get-acad-object))
                   ) ;_ end of _kpblc-conv-vla-to-list
                 ) ;_ end of mapcar
         ) ;_ end of member
       (setq
         res (list
               (cons "obj"
                     (car (vl-remove-if-not
                            '(lambda (x)
                               (= (strcase (vla-get-fullname x)) (strcase file))
                               ) ;_ end of lambda
                            (_kpblc-conv-vla-to-list
                              (vla-get-documents (vlax-get-acad-object))
                              ) ;_ end of _kpblc-conv-vla-to-list
                            ) ;_ end of vl-remove-if-not
                          ) ;_ end of car
                     ) ;_ end of cons
               (cons "write" t)
               (cons "save" t)
               (cons "name" file)
               ) ;_ end of list
         ) ;_ end of setq
       )
      ((and (findfile file)
            (_kpblc-is-file-read-only file)
            ) ;_ end of and
       (vl-file-copy
         file
         (setq tmp_file
                (strcat
;;;                (vla-get-tempfilepath
;;;                  (vla-get-files (vla-get-preferences (vlax-get-acad-object)))
;;;                ) ;_ end of vla-get-tempfilepath
                  (vl-filename-mktemp
                    (strcat (vl-filename-base file)
                            (vl-filename-extension file)
                            ) ;_ end of strcat
                    ) ;_ end of vl-filename-mktemp
                  ) ;_ end of strcat
               ) ;_ end of setq
         ) ;_ end of vl-file-copy
       (vla-open odbx tmp_file)
       (setq res (list (cons "obj" odbx)
                       (cons "close" t)
                       (cons "save" nil)
                       (cons "write" nil)
                       (cons "name" file)
                       ) ;_ end of list
             ) ;_ end of setq
       )
      ((and (findfile file)
            (not (_kpblc-is-file-read-only file))
            ) ;_ end of and
       (vla-open odbx file)
       (setq res (list (cons "obj" odbx)
                       (cons "close" t)
                       (cons "save" t)
                       (cons "write" t)
                       (cons "name" file)
                       ) ;_ end of list
             ) ;_ end of setq
       )
      ) ;_ end of cond
    res
    ) ;_ end of defun
  (defun _kpblc-odbx (/)
                     ;|
*    функция возвращает интерфейс IAxDbDocument (для работы с файлами DWG без
* их открытия). Если интерфейс не поддерживается, возвращает nil. Проверено
* на ACAD 2002, 2004, 2005, 2006, 2007
*    Автор - Fatty aka Олег jr. Моего только адаптация под общую систему и
* переименование
*    Параметры вызова:
*  нет
*    Примеры вызова:
(_kpblc-odbx)
|;
    (cond
      ((< (_kpblc-acad-version) 15.06)
       (alert
         "ObjectDBX method not applicable\nin this AutoCAD version"
         ) ;_ end of alert
       nil
       )
      ((= (fix (_kpblc-acad-version)) 15)
       (if (not (vl-registry-read
                  "HKEY_CLASSES_ROOT\\ObjectDBX.AxDbDocument\\CLSID"
                  ) ;_ end of vl-registry-read
                ) ;_ end of not
         (startapp "regsvr32.exe"
                   (strcat "/s \"" (findfile "axdb15.dll") "\"")
                   ) ;_ end of startapp
         ) ;_ end of if
       (vla-getinterfaceobject
         (vlax-get-acad-object)
         "ObjectDBX.AxDbDocument"
         ) ;_ end of vla-getinterfaceobject
       )
      (t
       (vla-getinterfaceobject
         (vlax-get-acad-object)
         (strcat "ObjectDBX.AxDbDocument."
                 (_kpblc-conv-value-to-string
                   (_kpblc-conv-value-to-int (_kpblc-acad-version))
                   ) ;_ end of _kpblc-conv-value-to-string
                 ) ;_ end of strcat
         ) ;_ end of vla-getinterfaceobject
       )
      ) ;_ end of cond
    ) ;_ end of defun
  (defun _kpblc-progress-continue (msg pos)
                                  ;|
*    Заполняет прогресс-бар
*    Параметры вызова:
  msg    выводимое сообщение
  pos    текущая позиция
|;
    (cond
      (progressbar
       (progressbar (rem pos 32000))
       )
      (acet-ui-progress
       (acet-ui-progress (rem pos 32000))
       )
      (t
       (_kpblc-progress-cmd msg pos)
       )
      ) ;_ end of cond
    ) ;_ end of defun
  (defun _kpblc-progress-cmd (msg pos / lst)
                             ;|
*    Выводит в ком.строку сообщение с "прогрессом"
*    Параметры вызова:
  msg    строковое сообщение
  pos    счетчик выполняемых действий
|;
    (if msg
      (princ (strcat "\r" msg " : " (nth (rem pos 4) '("-" "\\" "|" "/"))))
      (princ "\n" msg " закончено")
      ) ;_ end of if
    ) ;_ end of defun
  (defun _kpblc-progress-end ()
                             ;|
*    Завершение прогресс-бара
|;
    (cond
      (progressbar
       (progressbar)
       )
      (acet-ui-progress
       (acet-ui-progress)
       )
      (t (princ))
      ) ;_ end of cond
    ) ;_ end of defun
  (defun _kpblc-progress-modemacro (msg pos / lst)
                                   ;|
*    Выводит в ком.строку сообщение с "прогрессом"
*    Параметры вызова:
  msg    строковое сообщение
  pos    счетчик выполняемых действий
|;
    (if msg
      (setvar "modemacro" (strcat msg " : " (nth (rem pos 4) '("-" "\\" "|" "/"))))
      (setvar "modemacro" (strcat msg " закончено"))
      ) ;_ end of if
    ) ;_ end of defun
  (defun _kpblc-progress-start (msg range)
                               ;|
*    Инициализирует прогресс-бар
*    Параметры вызова:
  msg    показываемое сообщение
  range  общая длина прогресс-бара
|;
    (cond
      ((and msg progressbar)
       (progressbar msg (min 32000 range))
       )
      ((and (not msg) progressbar)
       (progressbar (min 32000 range))
       )
      ((and msg acet-ui-progress)
       (acet-ui-progress msg (min 32000 range))
       )
      ((and (not msg) acet-ui-progress)
       (acet-ui-progress (min 32000 range))
       )
      (t
       (_kpblc-progress-cmd msg range)
       )
      ) ;_ end of cond
    ) ;_ end of defun
  (defun _kpblc-strcase (str)
    (strcase (vl-string-translate "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ"
                                  "абвгдеёжзийклмнопрстуфхцчшщъыьэюя"
                                  str
                                  ) ;_ end of vl-string-translate
             t
             ) ;_ end of strcase
    ) ;_ end of defun

  ;|
*    Пакетная обработка файлов
|;

  (defun vl-browsefolder (caption / shlobj folder fldobj outval)
                         ;|
http://www.autocad.ru/cgi-bin/f1/board.cgi?t=21054YY    
*    Без отображения файлов
*    Параметры вызова:
	caption		показываемый заголовок (пояснение) окна
(setq Folder (vlax-invoke-method ShlObj 'BrowseForFolder 0 "" 16384))
|;
    (setq shlobj (vla-getinterfaceobject
                   (vlax-get-acad-object)
                   "Shell.Application"
                   ) ;_ end of vla-getInterfaceObject
          folder (vlax-invoke-method shlobj 'browseforfolder 0 caption 0)
          ) ;_ end of setq
    (vlax-release-object shlobj)
    (if folder
      (progn (setq fldobj (vlax-get-property folder 'self)
                   outval (vlax-get-property fldobj 'path)
                   ) ;_ end of setq
             (vlax-release-object folder)
             (vlax-release-object fldobj)
             ) ;_ end of progn
      ) ;_ end of if
    outval
    ) ;_ end of defun

  (defun vl-browsefiles-in-directory-nested (path mask)
                                            ;|
*    Функция возвращает список файлов указанной маски, находящихся в
* заданном каталоге
*    Параметры вызова:
  path  путь к корневому каталогу. nil недопустим
  mask  маска имени файла. nil или список недопустим
*    Примеры вызова:
(vl-browsefiles-in-directory-nested "c:\\documents" "*.dwg")
|;
    (apply
      (function append)
      (cons
        (if (vl-directory-files path mask)
          (mapcar
            (function (lambda (x)
                        (strcat (vl-string-right-trim "\\" path) "\\" x)
                        ) ;_ end of lambda
                      ) ;_ end of function
            (vl-directory-files path mask)
            ) ;_ end of mapcar
          ) ;_ if
        (mapcar (function
                  (lambda (x)
                    (vl-browsefiles-in-directory-nested
                      (strcat (vl-string-right-trim "\\" path) "\\" x)
                      mask
                      ) ;_ end of vl-browsefiles-in-directory-nested
                    ) ;_ end of lambda
                  ) ;_ end of function
                (vl-remove ".."
                           (vl-remove "." (vl-directory-files path nil -1))
                           ) ;_ end of vl-remove
                ) ;_ mapcar
        ) ;_ cons
      ) ;_ end of apply
    ) ;_ end of defun

  (defun vl-find-file-or-dir (path / fso res)
    (cond
      ((or (findfile path)
           (findfile (vl-string-right-trim "\\" path))
           (findfile (strcat (vl-string-right-trim "\\" path) "\\"))
           ) ;_ end of or
       (setq res (vl-string-right-trim "\\" path))
       )
      ((vl-file-directory-p path)
       (if (vl-catch-all-error-p
             (setq res (vl-catch-all-apply
                         (function
                           (lambda (/ fso)
                             (setq fso (vlax-get-or-create-object
                                         "Scripting.FileSystemObject"
                                         ) ;_ end of vlax-get-or-create-object
                                   ) ;_ end of setq
                             (vlax-invoke-method fso 'getfolder path)
                             ) ;_ end of lambda
                           ) ;_ end of function
                         ) ;_ end of vl-catch-all-apply
                   ) ;_ end of setq
             ) ;_ end of vl-catch-all-error-p
         (setq res nil)
         (setq res (vl-string-right-trim "\\" path))
         ) ;_ end of if
       (vl-catch-all-apply
         (function
           (lambda ()
             (vlax-release-object fso)
             ) ;_ end of lambda
           ) ;_ end of function
         ) ;_ end of vl-catch-all-apply
       )
      ) ;_ end of cond
    res
    ) ;_ end of defun

  (setq *kpblc-datas* (list '("ver" . "0.1.0")
                            (cons "regname" (setq tmp "BatchPurge"))
                            (cons "reghive" (strcat "HKEY_CURRENT_USER\\Software\\kpblc\\" tmp))
                            ) ;_ end of list
        dcl_lst       (mapcar
                        (function
                          (lambda (x)
                            (cons (car x)
                                  (cond ((vl-registry-read (cdr (assoc "reghive" *kpblc-datas*)) (substr (car x) 5)))
                                        (t (cdr x))
                                        ) ;_ end of cond
                                  ) ;_ end of cons
                            ) ;_ end of lambda
                          ) ;_ end of function
                        '(("chk_purge" . 1)
                          ("chk_purgeapps" . 1)
                          ("chk_purgegroups" . 1)
                          ("chk_proxy" . 0)
                          ("chk_normblocks" . 0)
                          ("chk_log" . 0)
                          )
                        ) ;_ end of mapcar
        ) ;_ end of setq

  (while (not (member dcl_res '(0 1)))
    (setq dcl_id (load_dialog (_kpblc-cmd-dcl-create)))
    (new_dialog "dlg" dcl_id "(_kpblc-cmd-dcl-callback $key $value 'dcl_lst)")
    (action_tile "btn_folder" "(done_dialog 2)")
    (action_tile "btn_log" "(done_dialog 3)")
    (action_tile "remember" "(done_dialog 4)")
    (action_tile "accept" "(done_dialog 1)")
    (action_tile "cancel" "(done_dialog 0)")
    (foreach item dcl_lst
      (cond
        ((member (cdr item) (list nil t "0" "1" 0 1))

         (set_tile (car item)
                   (if (_kpblc-conv-value-to-bool (cdr item))
                     "1"
                     "0"
                     ) ;_ end of if
                   ) ;_ end of set_tile
         (_kpblc-cmd-dcl-callback (car item) (_kpblc-conv-value-to-string (cdr item)) 'dcl_lst)
         )
        ((and (= (car item) "path")
              (_kpblc-conv-value-to-bool (cdr item))
              ) ;_ end of and
         (set_tile "txt_folder" (cdr item))
         (_kpblc-cmd-dcl-callback "txt_folder" (cdr item) 'dcl_lst)
         )
        ((and (= (car item) "logfile")
              (_kpblc-conv-value-to-bool (cdr item))
              ) ;_ end of and
         (set_tile (car item) (cdr item))
         (_kpblc-cmd-dcl-callback (car item) (cdr item) 'dcl_lst)
         )
        ) ;_ end of cond
      ) ;_ end of foreach
    (if (cdr (assoc "path" dcl_lst))
      (progn
        (set_tile "txt_folder" (cdr (assoc "path" dcl_lst)))
        (mode_tile "accept" 0)
        ) ;_ end of progn
      (mode_tile "accept" 1)
      ) ;_ end of if
    (if (cdr (assoc "logfile" dcl_lst))
      (progn
        (set_tile "logfile" (cdr (assoc "logfile" dcl_lst)))
        ) ;_ end of progn
      ) ;_ end of if

    (set_tile "chk_log"
              (if (_kpblc-conv-value-to-bool (cdr (assoc "chk_log" dcl_lst)))
                "1"
                "0"
                ) ;_ end of if
              ) ;_ end of set_tile
    (_kpblc-cmd-dcl-callback "chk_log" (get_tile "chk_log") 'dcl_lst)

    (mode_tile "chk_proxy"
               (if explodeallproxyinblock
                 0
                 1
                 ) ;_ end of if
               ) ;_ end of mode_tile

    (setq dcl_res (start_dialog))
    (cond
      ((= dcl_res 2)
       ;; check folder and return to dcl
       (if (setq path (vl-browsefolder "Выберите каталог для обработки"))
         (progn
           (mode_tile "accept" 0)
           (set_tile "txt_folder" path)
           (_kpblc-cmd-dcl-callback "txt_folder" path 'dcl_lst)
           ) ;_ end of progn
         (if (not (cdr (assoc "path" dcl_lst)))
           (mode_tile "accept" 1)
           ) ;_ end of if
         ) ;_ end of if
       )
      ((= dcl_res 3)
       ;; select log file and return to dcl
       (if (setq path (getfiled "Укажите имя файла для лога" "" "log" 1))
         (_kpblc-cmd-dcl-callback "logfile" path 'dcl_lst)
         ) ;_ end of if
       )
      ((= dcl_res 4)
       ;; save to reg
       (foreach item '("chk_purge" "chk_purgeapps" "chk_purgegroups" "chk_proxy" "chk_normblocks")
         (vl-registry-write (cdr (assoc "reghive" *kpblc-datas*))
                            (substr item 5)
                            (if (cdr (assoc item dcl_lst))
                              1
                              0
                              ) ;_ end of if
                            ) ;_ end of vl-registry-write
         ) ;_ end of foreach
       )
      ) ;_ end of cond
    ) ;_ end of while
  (unload_dialog dcl_id)
  (if (= dcl_res 1)
    (progn
      (vla-startundomark (vla-get-activedocument (vlax-get-acad-object)))
      (setq demandload (getvar "demandload"))
      (setvar "demandload" 2)
      (foreach file (vl-browsefiles-in-directory-nested (cdr (assoc "path" dcl_lst)) "*.dwg")
        (if (_kpblc-is-file-read-only file)
          (setq err_log (cons "is ReadOnly. Can't open" err_log))
          (progn
            (_kpblc-error-catch
              (function
                (lambda (/ _la handle)
                  (setq prg_pos 0
                        prg_msg (strcat (if (_kpblc-is-acad-rus)
                                          "Обработка файла"
                                          "Proceeding file"
                                          ) ;_ end of if
                                        " "
                                        (vl-filename-base file)
                                        ".dwg"
                                        ) ;_ end of strcat
                        doc     (_kpblc-odbx-open file (_kpblc-odbx))
                        err_log (cons "opened" err_log)
                        prg_max (min
                                  32000
                                  (apply '+
                                         (mapcar
                                           (function
                                             (lambda (x)
                                               (* (cond
                                                    ((cdr x))
                                                    (t 1)
                                                    ) ;_ end of cond
                                                  (vla-get-count (vlax-get-property (cdr (assoc "obj" doc)) (car x)))
                                                  ) ;_ end of *
                                               ) ;_ end of lambda
                                             ) ;_ end of function
                                           '(("layers" . 5)
                                             ("groups" . 1)
                                             ("registeredapplications" . 1)
                                             ("blocks" . 5)
                                             ("linetypes" . 3)
                                             ("dimstyles" . 3)
                                             ("textstyles" . 3)
                                             )
                                           ) ;_ end of mapcar
                                         ) ;_ end of apply
                                  ) ;_ end of min
                        ) ;_ end of setq
                  (_kpblc-progress-start prg_msg prg_max)
                  (if (_kpblc-conv-value-to-bool (cdr (assoc "chk_normblocks" dcl_lst)))
                    (progn
                      (_kpblc-error-catch
                        (function
                          (lambda ()
                            (setq
                              _la (mapcar
                                    (function
                                      (lambda (x)
                                        (_kpblc-progress-continue prg_msg
                                                                  (setq prg_pos (if (> (1+ prg_pos) prg_max)
                                                                                  0
                                                                                  (1+ prg_pos)
                                                                                  ) ;_ end of if
                                                                        ) ;_ end of setq
                                                                  ) ;_ end of _kpblc-progress-continue
                                        (append (list (cons "obj" x)
                                                      (mapcar
                                                        (function
                                                          (lambda (a / res)
                                                            (setq res (cons (car a) (vlax-get-property x (car a))))
                                                            (vl-catch-all-apply
                                                              (function
                                                                (lambda ()
                                                                  (vlax-put-property x (car a) (cdr a))
                                                                  ) ;_ end of lambda
                                                                ) ;_ end of function
                                                              ) ;_ end of vl-catch-all-apply
                                                            res
                                                            ) ;_ end of lambda
                                                          ) ;_ end of function
                                                        (list (cons "freeze" :vlax-false)
                                                              (cons "lock" :vlax-false)
                                                              ) ;_ end of list
                                                        ) ;_ end of mapcar
                                                      ) ;_ end of list
                                                ) ;_ end of append
                                        ) ;_ end of lambda
                                      ) ;_ end of function
                                    (_kpblc-conv-vla-to-list (vla-get-layers (cdr (assoc "obj" doc))))
                                    ) ;_ end of mapcar
                              ) ;_ end of setq
                            (vlax-for blk_def (vla-get-blocks (cdr (assoc "obj" doc)))
                              (_kpblc-progress-continue prg_msg
                                                        (setq prg_pos (if (> (1+ prg_pos) prg_max)
                                                                        0
                                                                        (1+ prg_pos)
                                                                        ) ;_ end of if
                                                              ) ;_ end of setq
                                                        ) ;_ end of _kpblc-progress-continue
                              (if (and (equal (vla-get-isxref blk_def) :vlax-false)
                                       (equal (vla-get-islayout blk_def) :vlax-false)
                                       ) ;_ end of and
                                (vlax-for sub blk_def
                                  (vla-put-color sub 0)
                                  (vla-put-lineweight sub aclnwtbyblock)
                                  (vla-put-layer sub "0")
                                  (vla-put-linetype sub "ByBlock")
                                  ) ;_ end of vlax-for
                                ) ;_ end of if
                              ) ;_ end of vlax-for
                            (setq err_log (cons "normalizing blocks success" err_log))
                            ) ;_ end of lambda
                          ) ;_ end of function
                        '(lambda (x)
                           (setq err_log (cons (strcat "normalizing blocks error : "
                                                       (vl-catch-all-error-message x)
                                                       ) ;_ end of strcat
                                               err_log
                                               ) ;_ end of cons
                                 doc     (_kpblc-list-add-or-subst doc "save" nil)
                                 ) ;_ end of setq
                           ) ;_ end of lambda
                        ) ;_ end of _kpblc-error-catch
                      (foreach item _la
                        (foreach prop (cdr item)
                          (_kpblc-progress-continue prg_msg
                                                    (setq prg_pos (if (> (1+ prg_pos) prg_max)
                                                                    0
                                                                    (1+ prg_pos)
                                                                    ) ;_ end of if
                                                          ) ;_ end of setq
                                                    ) ;_ end of _kpblc-progress-continue
                          (vl-catch-all-apply
                            (function
                              (lambda ()
                                (vlax-put-property (cdr (assoc "obj" item)) (car prop) (cdr prop))
                                ) ;_ end of lambda
                              ) ;_ end of function
                            ) ;_ end of vl-catch-all-apply
                          ) ;_ end of foreach
                        ) ;_ end of foreach
                      ) ;_ end of progn
                    ) ;_ end of if
                  (cond
                    ((and (_kpblc-conv-value-to-bool (cdr (assoc "save" doc)))
                          (_kpblc-conv-value-to-bool (cdr (assoc "chk_proxy" dcl_lst)))
                          explodeallproxyinblock
                          ) ;_ end of and
                     (_kpblc-error-catch
                       (function
                         (lambda ()
                           (vlax-for blk_def (vla-get-blocks (cdr (assoc "obj" doc)))
                             (_kpblc-progress-continue prg_msg
                                                       (setq prg_pos (if (> (1+ prg_pos) prg_max)
                                                                       0
                                                                       (1+ prg_pos)
                                                                       ) ;_ end of if
                                                             ) ;_ end of setq
                                                       ) ;_ end of _kpblc-progress-continue
                             (if (and (equal (vla-get-isxref blk_def) :vlax-false)
                                      ;; (equal (vla-get-islayout blk_def) :vlax-false)
                                      ) ;_ end of and
                               (explodeallproxyinblock (vlax-vla-object->ename blk_def))
                               ) ;_ end of if
                             ) ;_ end of foreach
                           (setq err_log (cons (strcat "explode all proxy success")
                                               err_log
                                               ) ;_ end of cons
                                 ) ;_ end of setq
                           ) ;_ end of lambda
                         ) ;_ end of function
                       '(lambda (x)
                          (setq err_log (cons (strcat "explode all proxy error : " (vl-catch-all-error-message x))
                                              err_log
                                              ) ;_ end of cons
                                doc     (_kpblc-list-add-or-subst doc "save" nil)
                                ) ;_ end of setq
                          ) ;_ end of lambda
                       ) ;_ end of _kpblc-error-catch
                     )
                    ((and (_kpblc-conv-value-to-bool (cdr (assoc "chk_proxy" dcl_lst)))
                          (not (_kpblc-conv-value-to-bool (cdr (assoc "save" doc))))
                          ) ;_ end of and
                     (setq err_log (cons (strcat "can't be saved. Exploding proxy stopped") err_log))
                     )
                    ) ;_ end of cond
                  (cond
                    ((and (_kpblc-conv-value-to-bool (cdr (assoc "save" doc)))
                          (_kpblc-conv-value-to-bool (cdr (assoc "chk_purgegroups" dcl_lst)))
                          ) ;_ end of and
                     (_kpblc-error-catch
                       (function
                         (lambda ()
                           (vlax-for grp (vla-get-groups (cdr (assoc "obj" doc)))
                             (_kpblc-progress-continue prg_msg
                                                       (setq prg_pos (if (> (1+ prg_pos) prg_max)
                                                                       0
                                                                       (1+ prg_pos)
                                                                       ) ;_ end of if
                                                             ) ;_ end of setq
                                                       ) ;_ end of _kpblc-progress-continue
                             (if (= (vla-get-count grp) 0)
                               (vl-catch-all-apply
                                 (function
                                   (lambda ()
                                     (vla-delete grp)
                                     ) ;_ end of lambda
                                   ) ;_ end of function
                                 ) ;_ end of vl-catch-all-apply
                               ) ;_ end of if
                             ) ;_ end of vlax-for
                           (setq err_log (cons "erasing empty groups success" err_log))
                           ) ;_ end of lambda
                         ) ;_ end of function
                       '(lambda (x)
                          (setq err_log (cons "erasing empty groups error : " (vl-catch-all-error-message x))
                                doc     (_kpblc-list-add-or-subst doc "save" nil)
                                ) ;_ end of setq
                          ) ;_ end of lambda
                       ) ;_ end of _kpblc-error-catch
                     )
                    ((and (_kpblc-conv-value-to-bool (cdr (assoc "chk_purgegroups" dcl_lst)))
                          (not (_kpblc-conv-value-to-bool (cdr (assoc "save" doc))))
                          ) ;_ end of and
                     (setq err_log (cons (strcat "can't be saved. Erasing empty groups stopped") err_log))
                     )
                    ) ;_ end of cond
                  (cond
                    ((and (_kpblc-conv-value-to-bool (cdr (assoc "save" doc)))
                          (_kpblc-conv-value-to-bool (cdr (assoc "chk_purgeapps" dcl_lst)))
                          ) ;_ end of and
                     (_kpblc-error-catch
                       (function
                         (lambda ()
                           (vlax-for grp (vla-get-registeredapplications (cdr (assoc "obj" doc)))
                             (_kpblc-progress-continue prg_msg
                                                       (setq prg_pos (if (> (1+ prg_pos) prg_max)
                                                                       0
                                                                       (1+ prg_pos)
                                                                       ) ;_ end of if
                                                             ) ;_ end of setq
                                                       ) ;_ end of _kpblc-progress-continue
                             (vl-catch-all-apply
                               (function
                                 (lambda ()
                                   (vla-delete grp)
                                   ) ;_ end of lambda
                                 ) ;_ end of function
                               ) ;_ end of vl-catch-all-apply
                             ) ;_ end of vlax-for
                           (setq err_log (cons "purging registered apps success" err_log))
                           ) ;_ end of lambda
                         ) ;_ end of function
                       '(lambda (x)
                          (setq err_log (cons "purging registered apps error : " (vl-catch-all-error-message x))
                                doc     (_kpblc-list-add-or-subst doc "save" nil)
                                ) ;_ end of setq
                          ) ;_ end of lambda
                       ) ;_ end of _kpblc-error-catch
                     )
                    ((and (_kpblc-conv-value-to-bool (cdr (assoc "chk_purgeapps" dcl_lst)))
                          (not (cdr (assoc "save" doc)))
                          ) ;_ end of and
                     (setq err_log (cons (strcat "can't be saved. Purging registered apps stopped") err_log))
                     )
                    ) ;_ end of cond
                  (cond
                    ((and (_kpblc-conv-value-to-bool (cdr (assoc "chk_purge" dcl_lst)))
                          (cdr (assoc "save" doc))
                          ) ;_ end of and
                     (repeat 3
                       (foreach crit '("blocks" "layers" "linetypes" "dimstyles" "textstyles")
                         (vlax-for item (vlax-get-property (cdr (assoc "obj" doc)) crit)
                           (_kpblc-progress-continue prg_msg
                                                     (setq prg_pos (if (> (1+ prg_pos) prg_max)
                                                                     0
                                                                     (1+ prg_pos)
                                                                     ) ;_ end of if
                                                           ) ;_ end of setq
                                                     ) ;_ end of _kpblc-progress-continue
                           (vl-catch-all-apply
                             (function
                               (lambda ()
                                 (vla-delete item)
                                 ) ;_ end of lambda
                               ) ;_ end of function
                             ) ;_ end of vl-catch-all-apply
                           ) ;_ end of vlax-for
                         ) ;_ end of foreach
                       ;; (vla-purgeall (cdr (assoc "obj" doc)))
                       ) ;_ end of repeat
                     (setq err_log (cons "purge success" err_log))
                     )
                    ((and (_kpblc-conv-value-to-bool (cdr (assoc "chk_purge" dcl_lst)))
                          (not (cdr (assoc "save" doc)))
                          ) ;_ end of and
                     (setq err_log (cons "can't be saved. Purging stopped" err_log))
                     )
                    ) ;_ end of cond
                  ) ;_ end of lambda
                ) ;_ end of function
              '(lambda (x)
                 (setq
                   err_log (cons (strcat (_kpblc-strcase file) " can't be opened: " (vl-catch-all-error-message x))
                                 err_log
                                 ) ;_ end of cons
                   ) ;_ end of setq
                 ) ;_ end of lambda
              ) ;_ end of _kpblc-error-catch
            (_kpblc-progress-end)
            (if (cdr (assoc "save" doc))
              (_kpblc-error-catch
                (function
                  (lambda ()
                    (vlax-invoke (cdr (assoc "obj" doc))
                                 'saveas
                                 (vla-get-name (cdr (assoc "obj" doc)))
                                 ) ;_ end of vlax-invoke
                    (vlax-release-object (cdr (assoc "obj" doc)))
                    (setq err_log (cons "saved success" err_log))
                    ) ;_ end of lambda
                  ) ;_ end of function
                '(lambda (x)
                   (setq err_log (cons (strcat "saved cancelled : " (vl-catch-all-error-message x)) err_log))
                   (vlax-release-object (cdr (assoc "obj" doc)))
                   ) ;_ end of lambda
                ) ;_ end of _kpblc-error-catch
              ) ;_ end of if
            (if (and (_kpblc-conv-value-to-bool (cdr (assoc "chk_log" dcl_lst)))
                     (/= (cdr (assoc "logfile" dcl_lst)) "")
                     ) ;_ end of and
              (_kpblc-error-catch
                (function
                  (lambda ()
                    (setq handle
                           (open (strcat (_kpblc-dir-path-and-splash
                                           (_kpblc-dir-create (vl-filename-directory (cdr (assoc "logfile" dcl_lst)))
                                                              ) ;_ end of _kpblc-dir-create
                                           ) ;_ end of _kpblc-dir-path-and-splash
                                         (vl-filename-base (cdr (assoc "logfile" dcl_lst)))
                                         (vl-filename-extension (cdr (assoc "logfile" dcl_lst)))
                                         ) ;_ end of strcat
                                 "a"
                                 ) ;_ end of open
                          ) ;_ end of setq
                    (foreach item
                             (append
                               (mapcar (function (lambda (x) (strcat (_kpblc-strcase file) " " x))) (reverse err_log))
                               '("---==---")
                               ) ;_ end of append
                      (write-line item handle)
                      ) ;_ end of foreach
                    (close handle)
                    ) ;_ end of lambda
                  ) ;_ end of function
                '(lambda (x)
                   (alert "Can't create log file!")
                   (setq dcl_lst (_kpblc-list-add-or-subst dcl_lst "chk_log" nil))
                   ) ;_ end of lambda
                ) ;_ end of _kpblc-error-catch
              ) ;_ end of if
            (setq err_log nil)
            ) ;_ end of progn
          ) ;_ end of if
        ) ;_ end of foreach
      (setvar "demandload" demandload)
      (vla-endundomark (vla-get-activedocument (vlax-get-acad-object)))
      ) ;_ end of progn
    ) ;_ end of if
  (princ)
  ) ;_ end of defun
