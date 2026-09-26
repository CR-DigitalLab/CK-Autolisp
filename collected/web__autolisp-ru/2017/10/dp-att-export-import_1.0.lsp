;; ver 1.0

(vl-load-com)

(defun c:dp-att-export (/ adoc selset lst tag_lst file handle sep msg pos as_csv dp_name_lst)
  (setq adoc (vla-get-activedocument (vlax-get-acad-object)))
  (if (and (= (type (setq selset (vl-catch-all-apply (function (lambda () (ssget '((0 . "INSERT"))))))))
              'pickset
              ) ;_ end of =
           (setq selset (_kpblc-conv-selset-to-vla selset))
           (setq selset (vl-remove-if
                          (function
                            (lambda (x)
                              (equal (vla-get-isxref (vla-item (vla-get-blocks adoc) (_kpblc-get-ent-name x))) :vlax-true)
                              ) ;_ end of lambda
                            ) ;_ end of function
                          selset
                          ) ;_ end of vl-remove-if
                 ) ;_ end of setq
           ) ;_ end of and
    (progn (setq tag_lst     (vl-sort (_kpblc-list-dublicates-remove
                                        (apply (function append)
                                               (mapcar (function (lambda (ref)
                                                                   (mapcar (function (lambda (x) (strcase (vla-get-tagstring x))))
                                                                           (_kpblc-block-attr-get-pointer-mask ref nil)
                                                                           ) ;_ end of mapcar
                                                                   ) ;_ end of lambda
                                                                 ) ;_ end of function
                                                       selset
                                                       ) ;_ end of mapcar
                                               ) ;_ end of apply
                                        ) ;_ end of _kpblc-list-dublicates-remove
                                      '<
                                      ) ;_ end of vl-sort
                 dp_name_lst (vl-sort (vl-remove-if
                                        (function (lambda (x) (= x "ORIGIN")))
                                        (_kpblc-list-dublicates-remove
                                          (apply (function append)
                                                 (mapcar (function
                                                           (lambda (ref)
                                                             (if (equal (vla-get-isdynamicblock (vla-item (vla-get-blocks adoc) (_kpblc-get-ent-name ref)))
                                                                        :vlax-true
                                                                        ) ;_ end of equal
                                                               (mapcar (function (lambda (x) (strcase (vla-get-propertyname x))))
                                                                       (_kpblc-conv-vla-to-list (vla-getdynamicblockproperties ref))
                                                                       ) ;_ end of mapcar
                                                               ) ;_ end of if
                                                             ) ;_ end of lambda
                                                           ) ;_ end of function
                                                         selset
                                                         ) ;_ end of mapcar
                                                 ) ;_ end of apply
                                          ) ;_ end of _kpblc-list-dublicates-remove
                                        ) ;_ end of vl-remove-if
                                      '<
                                      ) ;_ end of vl-sort
                 msg         "Collecting attributes and dynprop values"
                 pos         0
                 ) ;_ end of setq
           (_kpblc-progress-start msg (length selset))
           (setq lst (vl-sort (vl-sort (mapcar (function (lambda (item / _l _d)
                                                           (_kpblc-progress-continue msg (setq pos (1+ pos)))
                                                           (setq _l (mapcar (function (lambda (att) (cons (strcase (vla-get-tagstring att)) (vla-get-textstring att))))
                                                                            (_kpblc-block-attr-get-pointer-mask item "*")
                                                                            ) ;_ end of mapcar
                                                                 _d (vl-remove-if
                                                                      (function (lambda (x) (= (car x) "ORIGIN")))
                                                                      (mapcar (function (lambda (pr)
                                                                                          (cons (strcase (vla-get-propertyname pr)) (_kpblc-conv-vla-to-list (vla-get-value pr)))
                                                                                          ) ;_ end of lambda
                                                                                        ) ;_ end of function
                                                                              (_kpblc-conv-vla-to-list (vla-getdynamicblockproperties item))
                                                                              ) ;_ end of mapcar
                                                                      ) ;_ end of vl-remove-if
                                                                 ) ;_ end of setq
                                                           (list (list "name" (_kpblc-get-ent-name item))
                                                                 (list "handle" (strcat "'" (vla-get-handle item)))
                                                                 (cons "att"
                                                                       (mapcar (function (lambda (a)
                                                                                           (cond ((cdr (assoc a _l)))
                                                                                                 (t "")
                                                                                                 ) ;_ end of cond
                                                                                           ) ;_ end of lambda
                                                                                         ) ;_ end of function
                                                                               tag_lst
                                                                               ) ;_ end of mapcar
                                                                       ) ;_ end of cons
                                                                 (cons "dyn"
                                                                       (mapcar (function (lambda (a)
                                                                                           (cond ((cdr (assoc a _d)))
                                                                                                 (t "")
                                                                                                 ) ;_ end of cond
                                                                                           ) ;_ end of lambda
                                                                                         ) ;_ end of function
                                                                               dp_name_lst
                                                                               ) ;_ end of mapcar
                                                                       ) ;_ end of cons
                                                                 ) ;_ end of list
                                                           ) ;_ end of lambda
                                                         ) ;_ end of function
                                               selset
                                               ) ;_ end of mapcar
                                       (function (lambda (a b)
                                                   (< (_kpblc-conv-string-hex-to-dec (cadr (assoc "handle" a)))
                                                      (_kpblc-conv-string-hex-to-dec (cadr (assoc "handle" b)))
                                                      ) ;_ end of <
                                                   ) ;_ end of lambda
                                                 ) ;_ end of function
                                       ) ;_ end of vl-sort
                              (function (lambda (a b) (< (cadr (assoc "name" a)) (cadr (assoc "name" b)))))
                              ) ;_ end of vl-sort
                 ) ;_ end of setq
           (_kpblc-progress-end)
           (if (and (setq file (if acet-file-writedialog
                                 (acet-file-writedialog
                                   "Enter output filename"
                                   (strcat (_kpblc-dir-path-and-splash (getvar "dwgprefix")) (vl-filename-base (getvar "dwgname")) "")
                                   "txt;csv"
                                   "Acet:Att"
                                   1665
                                   ) ;_ end of acet-file-writedialog
                                 (getfiled "Enter output filename" (vl-filename-base (getvar "dwgname")) "txt;csv" 1)
                                 ) ;_ end of if
                          ) ;_ end of setq
                    (/= file "")
                    (if (findfile file)
                      (vl-file-systime file)
                      t
                      ) ;_ end of if
                    ) ;_ end of and
             (progn (setq handle (open file "w")
                          sep    (if (setq as_csv (= (strcase (vl-string-trim "." (vl-filename-extension file))) "CSV"))
                                   ";"
                                   "\t"
                                   ) ;_ end of if
                          msg    "Write data to file"
                          pos    0
                          ) ;_ end of setq
                    (if as_csv
                      ;; Требуется переделка атрибутов: заменить внутри значений ";" на "\";\"" и "\"" на "\"\""
                      (setq lst (mapcar (function
                                          (lambda (x)
                                            (mapcar (function
                                                      (lambda (b)
                                                        (cons (car b)
                                                              (mapcar (function (lambda (a)
                                                                                  (setq a (_kpblc-conv-value-to-string a))
                                                                                  (cond ((wcmatch a "*\"*") (strcat "\"" (_kpblc-string-replace a "\"" "\"\"") "\""))
                                                                                        ((wcmatch a "*;*") (strcat "\"" a "\""))
                                                                                        (t a)
                                                                                        ) ;_ end of cond
                                                                                  ) ;_ end of lambda
                                                                                ) ;_ end of function
                                                                      (cdr b)
                                                                      ) ;_ end of mapcar
                                                              ) ;_ end of cons
                                                        ) ;_ end of lambda
                                                      ) ;_ end of function
                                                    x
                                                    ) ;_ end of mapcar
                                            ) ;_ end of lambda
                                          ) ;_ end of function
                                        lst
                                        ) ;_ end of mapcar
                            ) ;_ end of setq
                      ) ;_ end of if
                    (_kpblc-progress-start msg (1+ (length selset)))
                    (write-line (_kpblc-conv-list-to-string (append '("Name" "Handle") tag_lst dp_name_lst) sep) handle)
                    (_kpblc-progress-continue msg (setq pos (1+ pos)))
                    (foreach item lst
                      (_kpblc-progress-continue msg (setq pos (1+ pos)))
                      (write-line
                        (_kpblc-conv-list-to-string (apply (function append) (mapcar (function cdr) item)) sep)
                        handle
                        ) ;_ end of write-line
                      ) ;_ end of foreach
                    (close handle)
                    (_kpblc-progress-end)
                    (princ (strcat "\nAttributes and dynprop exported to file " file))
                    ) ;_ end of progn
             (princ "\nError selecting file or file is write-protected")
             ) ;_ end of if
           ) ;_ end of progn
    (princ "\nNothing selected")
    ) ;_ end of if
  (princ)
  ) ;_ end of defun

(defun c:dp-att-import (/ adoc file handle str lst layer ent tag_lst sep att_lst msg pos as_csv)
  (if (setq file (if acet-ui-getfile
                   (acet-ui-getfile
                     "Enter input filename"
                     (strcat (_kpblc-dir-path-and-splash (getvar "dwgprefix")) (vl-filename-base (getvar "dwgname")) "")
                     "txt;csv"
                     "Acet:Att"
                     1664
                     ) ;_ end of acet-ui-getfile
                   (getfiled "Enter input filename" "" "txt;csv" 4)
                   ) ;_ end of if
            ) ;_ end of setq
    (progn (vla-startundomark (setq adoc (vla-get-activedocument (vlax-get-acad-object))))
           (setq handle  (open file "r")
                 sep     (if (setq as_csv (= (strcase (vl-string-trim "." (vl-filename-extension file))) "CSV"))
                           ";"
                           "\t"
                           ) ;_ end of if
                 tag_lst (cddr (_kpblc-conv-string-to-list (read-line handle) sep))
                         ;; Здесь у нас теперь не только атрибуты, но и дин.свойства.
                 ) ;_ end of setq
           (while (setq str (read-line handle))
             (setq lst (cons (if as_csv
                               (mapcar (function (lambda (x) (_kpblc-string-replace x "\"\"" "\"")))
                                       (apply (function append)
                                              (mapcar (function
                                                        (lambda (x)
                                                          (setq x (_kpblc-conv-string-to-list x (strcat sep "\"")))
                                                          (if (> (length x) 1)
                                                            (apply 'append
                                                                   (append (mapcar '(lambda (a) (_kpblc-conv-string-to-list a sep)) (reverse (cdr (reverse x))))
                                                                           (list (cdr x))
                                                                           ) ;_ end of append
                                                                   ) ;_ end of apply
                                                            (_kpblc-conv-string-to-list (car x) sep)
                                                            ) ;_ end of if
                                                          ) ;_ end of lambda
                                                        ) ;_ end of function
                                                      (_kpblc-conv-string-to-list str (strcat "\"" sep))
                                                      ) ;_ end of mapcar
                                              ) ;_ end of apply
                                       ) ;_ end of mapcar
                               (_kpblc-conv-string-to-list str sep)
                               ) ;_ end of if
                             lst
                             ) ;_ end of cons
                   ) ;_ end of setq
             ) ;_ end of while
           (close handle)
           (vl-catch-all-apply
             (function
               (lambda ()
                 (setq msg "Saving layer status"
                       pos 0
                       ) ;_ end of setq
                 (_kpblc-progress-start msg (vla-get-count (vla-get-layers adoc)))
                 (setq layer (mapcar (function
                                       (lambda (item)
                                         (_kpblc-progress-continue msg (setq pos (1+ pos)))
                                         (cons item
                                               (mapcar (function (lambda (prop / tmp)
                                                                   (setq tmp (vlax-get-property item prop))
                                                                   (vl-catch-all-apply (function (lambda () (vlax-put-property item prop :vlax-false))))
                                                                   (cons prop tmp)
                                                                   ) ;_ end of lambda
                                                                 ) ;_ end of function
                                                       '("freeze" "lock")
                                                       ) ;_ end of mapcar
                                               ) ;_ end of cons
                                         ) ;_ end of lambda
                                       ) ;_ end of function
                                     (_kpblc-conv-vla-to-list (vla-get-layers adoc))
                                     ) ;_ end of mapcar
                       ) ;_ end of setq
                 (_kpblc-progress-end)
                 (setq pos 0)
                 (_kpblc-progress-start (setq msg "Set attribute values to entities") (length lst))
                 (foreach item lst
                   (_kpblc-progress-continue msg (setq pos (1+ pos)))
                   (if (and (setq ent (handent (if as_csv
                                                 (vl-string-trim "\"'" (cadr item))
                                                 (cadr item)
                                                 ) ;_ end of if
                                               ) ;_ end of handent
                                  ) ;_ end of setq
                            (_kpblc-is-ent-block-reference (setq ent (_kpblc-conv-ent-to-vla ent)))
                            (= (strcase (_kpblc-get-ent-name ent)) (strcase (car item)))
                            ) ;_ end of and
                     (progn (setq att_lst (mapcar (function (lambda (x) (cons (strcase (vla-get-tagstring x)) x)))
                                                  (_kpblc-block-attr-get-pointer-mask ent "*")
                                                  ) ;_ end of mapcar
                                  ) ;_ end of setq
                            (foreach att att_lst
                              (vla-put-textstring
                                (cdr att)
                                (nth (- (length tag_lst) (length (member (car att) tag_lst))) (cddr item))
                                ) ;_ end of vla-put-TextString
                              ) ;_ end of foreach
                            (setq att_lst (vl-remove-if
                                            (function (lambda (x) (= (car x) "ORIGIN")))
                                            (mapcar (function (lambda (x) (cons (strcase (vla-get-propertyname x)) x)))
                                                    (_kpblc-conv-vla-to-list (vla-getdynamicblockproperties ent))
                                                    ) ;_ end of mapcar
                                            ) ;_ end of vl-remove-if
                                  ) ;_ end of setq
                            (foreach att att_lst
                              (_kpblc-change-dyn-block-prop
                                ent
                                (car att)
                                (nth (- (length tag_lst) (length (member (car att) tag_lst))) (cddr item))
                                ) ;_ end of _kpblc-change-dyn-block-prop
                              ) ;_ end of foreach
                            ) ;_ end of progn
                     ) ;_ end of if
                   ) ;_ end of foreach
                 (_kpblc-progress-end)
                 ) ;_ end of lambda
               ) ;_ end of function
             ) ;_ end of vl-catch-all-apply
           (setq pos 0)
           (_kpblc-progress-start (setq msg "Restore layer status") (* 3 (length layer)))
           (foreach item layer
             (foreach prop (cdr item)
               (_kpblc-progress-continue msg (setq pos (1+ pos)))
               (vl-catch-all-apply (function (lambda () (vlax-put-property item (car prop) (cdr prop)))))
               ) ;_ end of foreach
             ) ;_ end of foreach
           (_kpblc-progress-end)
           (vla-endundomark adoc)
           ) ;_ end of progn
    ) ;_ end of if
  (princ)
  ) ;_ end of defun

(defun _kpblc-get-ent-name (ent /) ;|
*    Получение свойства name указанного примитива
*    Параметры вызова:
  ent  указатель на обрабатываемый примитив
|;
  (cond ((and (= (type ent) 'str) (handent ent)) (_kpblc-get-ent-name (handent ent)))
        ((= (type ent) 'str) ent)
        ((_kpblc-property-get ent 'modelspace)
         (strcat (_kpblc-dir-path-and-splash (_kpblc-property-get ent 'path))
                 (_kpblc-property-get ent 'name)
                 ) ;_ end of strcat
         )
        ((_kpblc-property-get ent 'effectivename))
        ((_kpblc-property-get ent 'name))
        ) ;_ end of cond
  ) ;_ end of defun

(defun _kpblc-dir-path-and-splash (path)
                                  ;|
*    Возвращает путь со слешем в конце
*    Параметры вызова:
*  path  - обрабатываемый путь
*    Примеры вызова:
(_kpblc-dir-path-and-splash "c:\\kpblc-cad")  ; "c:\\kpblc-cad\\"
|;
  (strcat (vl-string-right-trim "\\" path) "\\")
  ) ;_ end of defun


(defun _kpblc-property-get (obj property / res) ;|
*    Получение значения свойства объекта
|;
  (vl-catch-all-apply
    (function
      (lambda ()
        (if (and obj (vlax-property-available-p (setq obj (_kpblc-conv-ent-to-vla obj)) property))
          (setq res (vlax-get-property obj property))
          ) ;_ end of if
        ) ;_ end of lambda
      ) ;_ end of function
    ) ;_ end of vl-catch-all-apply
  res
  ) ;_ end of defun

(defun _kpblc-is-ent-block-reference (ent)
                                     ;|
*    Функция возвращает, является ли переданный указатель на примитив вхождением
* (а не описанием) блока
*    Параметры вызова:
  ent  vla- или ename-указатель на проверяемый примитив
*    Примеры вызова:
(_kpblc-is-ent-block-reference (car (entsel)))
(_kpblc-is-ent-block-reference (vla-item (vla-get-blocks *kpblc-adoc*) (_kpblc-property-get (car (entsel)) 'name)))
(_kpblc-is-ent-block-reference (vla-item (vla-get-blocks *kpblc-adoc*) (_kpblc-property-get (car (entsel)) 'effectivename)))
|;
  (and (setq ent (_kpblc-conv-ent-to-vla ent))
       (= (vla-get-objectname ent) "AcDbBlockReference")
       (not (vlax-property-available-p ent 'path))
       (not (_kpblc-conv-value-to-bool (_kpblc-property-get ent 'isxref)))
       ) ;_ end of and
  ) ;_ end of defun

(defun _kpblc-is-ent-block-with-attr
       (ent) ;|
*    Функция проверяет, является ли переданный указатель блоком и есть ли в нем
* изменяемые атрибуты
*    ent  указатель на проверяемый примитив
|;
  (setq ent (_kpblc-conv-ent-to-vla ent))
  (and (_kpblc-is-ent-block-reference ent)
       (= (_kpblc-property-get ent 'hasattributes) :vlax-true)
       (> (vlax-safearray-get-u-bound (vlax-variant-value (vla-getattributes ent)) 1) -1)
       ) ;_ end of and
  ) ;_ end of defun

(defun _kpblc-is-ent-block-with-constant-attr
       (ent) ;|
*    Функция проверяет, является ли переданный указатель блоком с постоянными атрибутами
*    Параметры вызова:
*  ent  указатель на вхождение блока
|;
  (setq ent (_kpblc-conv-ent-to-vla ent))
  (and (_kpblc-is-ent-block-reference ent)
       (vlax-method-applicable-p ent 'getconstantattributes)
       (> (vlax-safearray-get-u-bound (vlax-variant-value (vla-getconstantattributes ent)) 1) -1)
       ) ;_ end of and
  ) ;_ end of defun

(defun _kpblc-block-attr-get-pointer-mask (blk mask / res)
                                          ;|
*    Получение списка атрибутов блока по маске. Учитываются также постоянные атрибуты.
*    Параметры вызова:
  blk      указатель на вставку блока
  mask     строка с маской тэга атрибута
|;
  (if (not mask)
    (setq mask "*")
    ) ;_ end ofif
  (if (or (_kpblc-is-ent-block-with-attr blk) (_kpblc-is-ent-block-with-constant-attr blk))
    (progn (setq blk (_kpblc-conv-ent-to-vla blk))
           (vl-remove-if-not
             (function (lambda (x) (wcmatch (strcase (vla-get-tagstring x)) (strcase mask))))
             (apply (function append)
                    (mapcar (function _kpblc-conv-vla-to-list)
                            (list (vla-getattributes blk) (vla-getconstantattributes blk))
                            ) ;_ end of mapcar
                    ) ;_ end of apply
             ) ;_ end of vl-remove-if-not
           ) ;_ end of progn
    ) ;_ end of if
  ) ;_ end of defun

(defun _kpblc-progress-continue (msg pos) ;|
*    Заполняет прогресс-бар
*    Параметры вызова:
  msg    выводимое сообщение
  pos    текущая позиция
|;
  (while (> pos 32000) (setq pos (- pos 32000)))
  (cond (progressbar (progressbar (rem pos 32000)))
        (acet-ui-progress (acet-ui-progress (rem pos 32000)))
        (t (_kpblc-progress-cmd msg pos))
        ) ;_ end of cond
  ) ;_ end of defun

(defun _kpblc-progress-cmd (msg pos / lst) ;|
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

(defun _kpblc-progress-end ();|
*    Завершение прогресс-бара
|;
  (cond (progressbar (progressbar))
        (acet-ui-progress (acet-ui-progress))
        (t (princ))
        ) ;_ end of cond
  ) ;_ end of defun

(defun _kpblc-progress-modemacro
       (msg pos / lst) ;|
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

(defun _kpblc-progress-start (msg range) ;|
*    Инициализирует прогресс-бар
*    Параметры вызова:
  msg    показываемое сообщение
  range  общая длина прогресс-бара
|;
  (cond ((and msg progressbar) (progressbar msg (min 32000 range)))
        ((and (not msg) progressbar) (progressbar (min 32000 range)))
        ((and msg acet-ui-progress) (acet-ui-progress msg (min 32000 range)))
        ((and (not msg) acet-ui-progress) (acet-ui-progress (min 32000 range)))
        (t (_kpblc-progress-cmd msg range))
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
  (cond ((= (type ent_value) 'vla-object) (vlax-vla-object->ename ent_value))
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
  (cond ((= (type ent_value) 'vla-object) ent_value)
        ((= (type ent_value) 'ename) (vlax-ename->vla-object ent_value))
        ((setq res (_kpblc-conv-ent-to-ename ent_value)) (vlax-ename->vla-object res))
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
  (cond ((not selset) nil)
        ((= (type selset) 'pickset)
         (repeat (setq tab  nil
                       item (sslength selset)
                       ) ;_ end setq
           (setq tab (cons (ssname selset (setq item (1- item))) tab))
           ) ;_ end repeat
         )
        ((= (type selset) 'vla-object) (_kpblc-conv-vla-to-list selset))
        ((listp selset) (mapcar (function _kpblc-conv-ent-to-ename) selset))
        ) ;_ end of cond
  ) ;_ end of defun

(defun _kpblc-conv-selset-to-vla (selset) ;|
*    Преобразование набора примитивов в список vla-представлений примитивов
*    Параметры вызова:
  selset  набор, сформированный (ssget)
|;
  (mapcar (function _kpblc-conv-ent-to-vla) (_kpblc-conv-selset-to-ename selset))
  ) ;_ end of defun

(defun _kpblc-conv-value-to-bool (value)
                                 ;|
*    Функция преобразования переданного значения в лисповое t|nil. Для ошибочных значений возвращает nil.
*    Параметры вызова:
  value  преобразовываемое значение
*    Примеры вызова:
(_kpblc-conv-value-to-bool "0")   ; nil
(_kpblc-conv-value-to-bool "1")  ; T
(_kpblc-conv-value-to-bool "-1")  ; T
|;
  (cond ((= (type value) 'str) (not (member (strcase value t) '("" "0" "n" "н" "false" "f"))))
        ((= (type value) 'vl-catch-all-apply-error) nil)
        (t (not (member value '(0 nil :vlax-false))))
        ) ;_ end of cond
  ) ;_ end of defun

(defun _kpblc-conv-value-to-string (value /) ;|
*    конвертация значения в строку.
|;
  (cond ((= (type value) 'str) value)
        ((= (type value) 'int) (itoa value))
        ((and (= (type value) 'real)
              (equal value (_kpblc-eval-value-round value 1.) 1e-6)
              (equal value (fix value) 1e-6)
              ) ;_ end of and
         (itoa (fix value))
         )
        ((and (= (type value) 'real)
              (equal value (_kpblc-eval-value-round value 1.) 1e-6)
              (not (equal value (fix value) 1e-6))
              ) ;_ end of and
         (rtos value 2)
         )
        ((= (type value) 'real) (rtos value 2 14))
        ((not value) "")
        (t (vl-princ-to-string value))
        ) ;_ end of cond
  ) ;_ end of defun
(defun _kpblc-eval-value-round
       (value to) ;|
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

(defun _kpblc-conv-vla-to-list (value / res) ;|
*    Преобразовывает vlax-variant или vlax-safearray в список.
|;
  (cond ((listp value) (mapcar (function _kpblc-conv-vla-to-list) value))
        ((= (type value) 'variant) (_kpblc-conv-vla-to-list (vlax-variant-value value)))
        ((= (type value) 'safearray)
         (if (>= (vlax-safearray-get-u-bound value 1) 0)
           (_kpblc-conv-vla-to-list (vlax-safearray->list value))
           ) ;_ end of if
         )
        ((and (member (type value) (list 'ename 'str 'vla-object))
              (= (type (_kpblc-conv-ent-to-vla value)) 'vla-object)
              (vlax-property-available-p (_kpblc-conv-ent-to-vla value) 'count)
              ) ;_ end of and
         (vlax-for sub (_kpblc-conv-ent-to-vla value) (setq res (cons sub res)))
         )
        (t value)
        ) ;_ end of cond
  ) ;_ end of defun

(defun _kpblc-list-dublicates-remove
       (lst / result) ;|
*    Функция исключения дубликатов элементов списка. Строковые значения обрабатываются, наплевав на регистр
*    Параметры вызова:
*  lst  обрабатываемый список
|;
  (foreach x lst
    (if (not (member (if (= (type x) 'str)
                       (strcase x)
                       x
                       ) ;_ end of if
                     (mapcar (function (lambda (a)
                                         (if (= (type a) 'str)
                                           (strcase a)
                                           a
                                           ) ;_ end of if
                                         ) ;_ end of lambda
                                       ) ;_ end of function
                             result
                             ) ;_ end of mapcar
                     ) ;_ end of member
             ) ;_ end of not
      (setq result (cons x result))
      ) ;_ end of if
    ) ;_ end of foreach
  (reverse result)
  ) ;_ end of defun

(defun _kpblc-conv-string-hex-to-dec (hexstr / n i a s fun_conv-string-to-value)
                                     ;|
*    Функция преобразования шестнадцатиричной строки в десятичное число. Автор: А.Ривилис
* http://www.autocad.ru/cgi-bin/f1/board.cgi?t=29431LT
* Возвращает число.
|;
  (setq n 0.0
        i 0
        ) ;_ end of setq
  (setq hexstr (strcase hexstr))
  (while (> (strlen hexstr) 0)
    (setq s (substr hexstr (strlen hexstr) 1)
          a (ascii s)
          ) ;_ end of setq
    (cond ((<= (ascii "0") a (ascii "9")) (setq a (- a (ascii "0"))))
          ((<= (ascii "A") a (ascii "F")) (setq a (+ 10. (- a (ascii "A")))))
          ) ;_ end of cond
    (setq n (+ n (* a (expt 16. i)))
          i (1+ i)
          ) ;_ end of setq
    (setq hexstr (substr hexstr 1 (1- (strlen hexstr))))
    ) ;_ end of while
  n
  ) ;_ end of defun

(defun _kpblc-conv-list-to-string (lst sep) ;|
*    Преобразование списка в строку
*    Параметры вызова:
  lst  обрабатываемй список
  sep  разделитель. nil -> " "
|;
  (if (and lst
           (setq sep (if sep
                       sep
                       " "
                       ) ;_ end of if
                 ) ;_ end of setq
           ) ;_ end of and
    (strcat (car lst)
            (apply (function strcat) (mapcar (function (lambda (x) (strcat sep x))) (cdr lst)))
            ) ;_ end of strcat
    ""
    ) ;_ end of if
  ) ;_ end of defun

(defun _kpblc-conv-string-to-list (string separator / i)
                                  ;|
*    Функция разбора строки. Возвращает список либо точечную пару. За основу взяты уроки Евгения Елпанова по рекурсиям
*    Параметры вызова:
*  string    разбираемая строка
*  separator  символ, используемый в качестве разделителя частей
*    Примеры вызова:
(_kpblc-conv-string-to-list "1;2;3;4;5;6" ";")  ;-> '(1 2 3 4 5 6)
(_kpblc-conv-string-to-list "1;2" ";")          ;-> '(1 2)
|;
  (cond ((= string "") nil)
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
              (if (wcmatch (strcase (substr string pos (strlen separator))) (strcase separator))
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

(defun _kpblc-string-replace (str old new)
                             ;|
*    Функция замены вхождений подстроки на новую. Регистронезависима
*    Параметры вызова:
  str  исходная строка
  old  старая строка
  new  новая строка
*    Позволяет менять аналогичные строки: "str" -> "'_str'"
|;
  (_kpblc-conv-list-to-string (_kpblc-conv-string-to-list str old) new)
  ) ;_ end of defun
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
  (setq adoc (vla-get-activedocument (vlax-get-acad-object)))
  (if (vl-catch-all-error-p
        (vl-catch-all-apply
          (function
            (lambda ()
              (if (and (setq ent (cond ((= (type ent) 'ename) (vlax-ename->vla-object ent))
                                       ((= (type ent) 'vla-object) ent)
                                       ((= (type ent) 'str)
                                        ((lambda (/ tmp) (vl-catch-all-apply '(lambda () (setq tmp (vla-handletoobject ent)))) tmp))
                                        )
                                       (t nil)
                                       ) ;_ end of cond
                             ) ;_ end of setq
                       (= (strcase (vla-get-objectname ent) t) "acdbblockreference")
                       (equal (vla-get-isdynamicblock (setq blk (vla-item (vla-get-blocks adoc) (vla-get-effectivename ent))))
                              :vlax-true
                              ) ;_ end of equal
                       name
                       (= (type name) 'str)
                       value
                       (setq prop (car (vl-remove-if-not
                                         (function (lambda (x) (= (strcase (vla-get-propertyname x)) (strcase name))))
                                         (vlax-safearray->list (vlax-variant-value (vla-getdynamicblockproperties ent)))
                                         ) ;_ end of vl-remove-if-not
                                       ) ;_ end of car
                             ) ;_ end of setq
                       (or (not (vlax-property-available-p prop 'allowedvalues t))
                           (member value
                                   (mapcar 'vlax-variant-value
                                           (vlax-safearray->list (vlax-variant-value (vla-get-allowedvalues prop)))
                                           ) ;_ end of mapcar
                                   ) ;_ end of member
                           ) ;_ end of or
                       ) ;_ end of and
                (progn (vla-put-value prop (vlax-make-variant value (vlax-variant-type (vla-get-value prop))))
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
  ) ;_ end of defun