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
(defun _kpblc-conv-list-to-string (lst sep)
                                  ;|
*    Преобразование списка в строку
*    Параметры вызова:
	lst	обрабатываемй список
	sep	разделитель. nil -> " "
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
*	string		разбираемая строка
*	separator	символ, используемый в качестве разделителя частей
*    Примеры вызова:
(_kpblc-conv-string-to-list "1;2;3;4;5;6" ";")	;'(1 2 3 4 5 6)
(_kpblc-conv-string-to-list "1;2" ";")		;'(1 2)
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

(defun _kpblc-error-print (func-name msg / res)
                          ;|
*    Функция вывода сообщения об ошибке для (_kpblc-error-catch)
*    Параметры вызова:
*	func-name	имя функции, в которой возникла ошибка
*	msg		сообщение об ошибке
|;
  (princ (setq res (strcat "\n ** "
                           (vl-string-trim "][ :\n<>"
                                           (vl-string-subst
                                             ""
                                             "error"
                                             (strcase (_kpblc-conv-value-to-string func-name) t)
                                             ) ;_ end of vl-string-subst
                                           ) ;_ end of vl-string-trim
                           " ERROR #"
                           (if msg
                             (strcat
                               (_kpblc-conv-value-to-string (getvar "errno"))
                               ": "
                               (_kpblc-conv-value-to-string msg)
                               ) ;_ end of strcat
                             ": undefined"
                             ) ;_ end of if
                           ) ;_ end of strcat
               ) ;_ end of setq
         ) ;_ end of princ
  (_kpblc-log res nil)
  (princ)
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

(defun _kpblc-string-replace (str old new)
                             ;|
*    Функция замены вхождений подстроки на новую. Регистронезависима
*    Параметры вызова:
*	str	исходная строка
*	old	старая строка
*	new	новая строка
*    Позволяет менять аналогичные строки: "str" -> "'_str'"
|;
  (_kpblc-conv-list-to-string (_kpblc-conv-string-to-list str old) new)
  ) ;_ end of defun

(defun _kpblc-sysvar-set (var value)
                         ;|
*    Установка системных переменных. Замена стандартному (setvar) для безошибочной обработки

|;
  (if (getvar var)
    (if (and (= value "") (wcmatch (strcase var t) "dim*"))
      (setvar var ".")
      (vl-catch-all-apply
        (function
          (lambda (/ tmp)
            (setq tmp (getvar var)
                  tmp (cond
                        ((or (= (type value) (type tmp))
                             (and (member value (list 'int 'real))
                                  (member tmp (list 'int 'real))
                                  ) ;_ end of and
                             ) ;_ end of or
                         value
                         )
                        ((= (type tmp) 'int) (_kpblc-conv-value-to-int value))
                        ((= (type tmp) 'real) (_kpblc-conv-value-to-real value))
                        ((= (type tmp) 'str) (_kpblc-conv-value-to-string value))
                        ((= (type tmp) 'list)
                         (mapcar (function atof)
                                 (_kpblc-conv-string-to-list (vl-string-trim "()" (_kpblc-conv-value-to-string value)) ",")
                                 ) ;_ end of mapcar
                         )
                        ) ;_ end of cond
                  ) ;_ end of setq
            (setvar var tmp)
            ) ;_ end of lambda
          ) ;_ end of function
        ) ;_ end of vl-catch-all-apply
      ) ;_ end of if
    ) ;_ end of if
  (getvar var)
  ) ;_ end of defun

(defun _kpblc-xml-attribute-add-or-modify (node tag value save /)
                                          ;|
*    Добавление атрибута к узлу дерева с установкой значения. Если такой атрибут
* уже есть, он заменяется
*    Параметры вызова:
	node	обрабатываемый узел дерева
	tag	имя (тэг) добавляемого атрибута
	value	значение атрибута
	save	сохранять или нет документ
|;
  (_kpblc-error-catch
    (function
      (lambda ()
        (_kpblc-xml-attribute-remove-by-tag node tag)
        (vlax-invoke-method node 'setattribute tag value)
        (if save
          (_kpblc-xml-doc-save (_kpblc-xml-doc-get-by-node node))
          ) ;_ end of if
        ) ;_ end of lambda
      ) ;_ end of function
    '(lambda (x) (_kpblc-error-print "_kpblc-xml-attribute-remove-by-tag" x))
    ) ;_ end of _kpblc-error-catch
  ) ;_ end of defun

(defun _kpblc-xml-attribute-get-name-and-value (xml-attribute)
                                               ;|
*    Получение списка точечной пары имени и значения атрибута
*    Параметры вызова:
	xml-attribute	указатель на xml-атрибут документа. Допустимые
		значения:
		  vla-object	указатель на 1 атрибут / узел дерева
		  list		список атрибутов
		  nil		ничего не делается
*    Пример вызова:
|;
  (cond
    ((and xml-attribute
          (= (type xml-attribute) 'vla-object)
          (vlax-property-available-p xml-attribute 'nodename)
          (not (_kpblc-property-get xml-attribute 'attributes))
          ) ;_ end of and
     (cons (strcase (_kpblc-property-get xml-attribute 'nodename) t)
           ((lambda (/ _res)
              (setq _res (vlax-variant-value (_kpblc-property-get xml-attribute 'nodevalue)))
              (foreach item '(("@qute;" . "\"")
                              ("&quot;" . "\"")
                              ("&amp;" . "&")
                              ("&#10;" . "\r")
                              ("&#13;" . "\n")
                              )
                (setq _res (_kpblc-string-replace-noreg _res (car item) (cdr item)))
                ) ;_ end of foreach
              _res
              ) ;_ end of lambda
            )
;;;              (_kpblc-string-replace-noreg (vlax-variant-value (_kpblc-property-get xml-attribute 'nodevalue))
;;;                                        "@qute;"
;;;                                        "\""
;;;                                        )
           ) ;_ end of cons
     )
    ((and xml-attribute
          (= (type xml-attribute) 'vla-object)
          (vlax-property-available-p xml-attribute 'nodename)
          (_kpblc-property-get xml-attribute 'attributes)
          ) ;_ end of and
     (mapcar (function _kpblc-xml-attribute-get-name-and-value)
             (_kpblc-xml-attributes-get-by-node xml-attribute)
             ) ;_ end of mapcar
     )
    ((and xml-attribute (listp xml-attribute))
     (mapcar (function _kpblc-xml-attribute-get-name-and-value) xml-attribute)
     )
    ) ;_ end of cond
  ) ;_ end of defun

(defun _kpblc-xml-attribute-remove-by-tag (node tag / attr)
                                          ;|
*    Удаление атрибута из узла. Если атрибута нет, ничего не выполняется
*    Параметры вызова:
	node	указатель на узел xml-дерева
	tag	имя (тэг) атрибута
|;
  (if (and node
           (setq tag (if tag
                       (strcase tag)
                       "*"
                       ) ;_ end of if
                 ) ;_ end of setq
           ) ;_ end of and
    (foreach attr (vl-remove-if-not
                    (function (lambda (x)
                                (wcmatch (strcase x) tag)
                                ) ;_ end of lambda
                              ) ;_ end of function
                    (mapcar (function
                              (lambda (a)
                                (_kpblc-property-get a 'nodename)
                                ) ;_ end of lambda
                              ) ;_ end of function
                            (_kpblc-xml-attributes-get-by-node node)
                            ) ;_ end of mapcar
                    ) ;_ end of vl-remove-if
      (_kpblc-error-catch
        (function
          (lambda ()
            (vlax-invoke-method node 'removeattribute attr)
            ) ;_ end of lambda
          ) ;_ end of function
        '(lambda (x)
           (_kpblc-error-print "_kpblc-xml-attribute-remove" x)
           ) ;_ end of lambda
        ) ;_ end of _kpblc-error-catch
      ) ;_ end of foreach
    ) ;_ end of if
  ) ;_ end of defun
	
(defun _kpblc-xml-attributes-get-by-node (node)
          ;(defun _kpblc-xml-get-attrbitutes (node)
                                         ;|
*    Получение атрибутов узла XML-дерева.
*    Параметры вызова:
	node	проверяемый узел
|;
  (if (vlax-property-available-p node 'attributes)
    (_kpblc-xml-conv-nodes-to-list
      (_kpblc-property-get node 'attributes)
      ) ;_ end of _kpblc-xml-conv-nodes-to-list
    ) ;_ end of if
  ) ;_ end of defun

(defun _kpblc-xml-conv-nodes-to-list (nodes / i res)
                                     ;|
*    Преобразование указателя на коллекцию Nodes xml-объекта в список.
*    Исключаются описания не узлов (комментарии, DATA-узлы и т.п.)
*    Параметры вызова:
	nodes	указатель на коллекцию узлов xml-документа
|;
  (_kpblc-error-catch
    (function
      (lambda ()
        (setq i 0)
        (while (< i (_kpblc-property-get nodes 'length))
          (setq res (cons (vlax-get-property nodes 'item i) res)
                i   (1+ i)
                ) ;_ end of setq
          ) ;_ end of while
        (setq res (vl-remove-if-not
                    (function
                      (lambda (x)
                        (member (_kpblc-property-get x 'nodetype) '(1 2))
                        ) ;_ end of lambda
                      ) ;_ end of function
                    (reverse res)
                    ) ;_ end of vl-remove-if-not
              ) ;_ end of setq
        ) ;_ end of lambda
      ) ;_ end of function
    '(lambda (x)
       (_kpblc-error-print "_kpblc-xml-conv-nodes-to-list" x)
       (setq res nil)
       ) ;_ end of lambda
    ) ;_ end of _kpblc-error-catch
  res
  ) ;_ end of defun

(defun _kpblc-xml-doc-create (file root / handle)
                             ;|
*    Если файл не существует, создает его "с нуля".
*    Параметры вызова:
	file	полный путь создаваемого xml-файла. Расширение лобое, не меняется
	root	имя Root-узла дерева
*    Возвращает путь созданного файла либо nil в случае ошибки. Содержимое файла
* не проверяется.
|;
  (cond
    ((or (not file) (not root)) nil)
    ((findfile file))
    ((not (vl-directory-files (vl-filename-directory file)))
     (vl-mkdir (vl-filename-directory file))
     (_kpblc-xml-doc-create file root)
     )
    (t
     (setq handle (open file "w"))
     (foreach item (list "<?xml version=\"1.0\" encoding=\"utf-8\"?>"
                         (strcat "<" root ">")
                         (strcat "</" root ">")
                         ) ;_ end of list
       (write-line item handle)
       ) ;_ end of foreach
     (close handle)
     (findfile file)
     )
    ) ;_ end of cond
  ) ;_ end of defun

(defun _kpblc-xml-doc-get-by-node (obj)
                                  ;|
*    Получение указателя на документ-владелец узла.
*    Параметры вызова:
	obj	указатель на обрабатываемый узел. Если это указатель на документ
		xml, он же и возвращается
|;
  (cond
    ((_kpblc-property-get obj 'ownerdocument))
    (t obj)
    ) ;_ end of cond
  ) ;_ end of defun

(defun _kpblc-xml-doc-get (file / doc)
                          ;|
*    Получение указателя на xml-DOMDocument
*    Параметры вызова:
	file	xml-файл. Валидность не проверяется
|;
  (if (findfile file)
    (_kpblc-error-catch
      (function
        (lambda ()
          (setq doc (vlax-get-or-create-object "MSXML2.DOMDocument.3.0"))
          (vlax-put-property doc 'async :vlax-false)
          (vlax-invoke-method doc 'load file)
          ) ;_ end of lambda
        ) ;_ end of function
      '(lambda (x)
         (_kpblc-error-print "_kpblc-xml-doc-get" x)
         (setq doc nil)
         ) ;_ end of lambda
      ) ;_ end of _kpblc-error-catch
    ) ;_ end of if
  doc
  ) ;_ end of defun
	
(defun _kpblc-xml-doc-release (doc)
                              ;|
*    Освобождение ресурсов XML-документа
*    Параметры вызова:
	doc	указатель на XML-документ.
*    Примеры вызова:
(setq obj (_kpblc-xml-get-document
            (findfile (strcat (_kpblc-dir-path-and-splash (_kpblc-dir-get-root-xml)) "tables.xml"))
            ) ;_ end of _kpblc-xml-get-document
      ) ;_ end of setq
<...>
(_kpblc-xml-doc-release obj)
|;
  (vl-catch-all-apply
    (function
      (lambda ()
        (vlax-release-object doc)
        (setq doc nil)
        ) ;_ end of lambda
      ) ;_ end of function
    ) ;_ end of vl-catch-all-apply
  ) ;_ end of defun

(defun _kpblc-xml-doc-save-and-close (node-or-doc / doc)
                                     ;|
*    Сохранение и закрытие xml-документа
*    Параметры вызова:
	node-or-doc	указатель на объект XML_DOMDocument или один из узлов
			документа
|;
  (if (setq doc (cond
                  ((_kpblc-property-get node-or-doc 'ownerdocument))
                  (t node-or-doc)
                  ) ;_ end of cond
            ) ;_ end of setq
    (progn
      (_kpblc-xml-doc-save doc)
      (_kpblc-xml-doc-release doc)
      ) ;_ end of progn
    ) ;_ end of if
  ) ;_ end of defun

(defun _kpblc-xml-doc-save (node-or-doc / doc)
                           ;|
*    Сохранение xml-документа
*    Параметры вызова:
	node-or-doc	указатель на объект XML_DOMDocument или один из узлов
			документа
|;
  (if (setq doc (cond
                  ((_kpblc-property-get node-or-doc 'ownerdocument))
                  (t node-or-doc)
                  ) ;_ end of cond
            ) ;_ end of setq
    (_kpblc-error-catch
      (function
        (lambda ()
          (vlax-invoke-method
            doc
            'save
            (_kpblc-string-replace-noreg
              (vl-string-left-trim
                "file:"
                (_kpblc-string-replace-noreg
                  (_kpblc-property-get doc 'url)
                  "%20"
                  " "
                  ) ;_ end of _kpblc-string-replace-noreg
                ) ;_ end of vl-string-left-trim
              "/"
              "\\"
              ) ;_ end of _kpblc-string-replace-noreg
            ) ;_ end of vlax-invoke-method
          ) ;_ end of lambda
        ) ;_ end of function
      '(lambda (x)
         (_kpblc-error-print "_kpblc-xml-doc-save" x)
         ) ;_ end of lambda
      ) ;_ end of _kpblc-error-catch
    ) ;_ end of if
  ) ;_ end of defun

(defun _kpblc-xml-node-add-child (parent tag save / res)
                                 ;|
*    Добавление подчиненного узла
*    Параметры вызова:
	parent	указатель на родительский узел, в который и выполняется добавление
	tag	тэг нового узла
	save	выполнять или нет сохранение документа для parent'a
|;
  (_kpblc-error-catch
    (function
      (lambda ()
        (setq res (vlax-invoke-method
                    parent
                    'appendchild
                    (vlax-invoke-method
                      (_kpblc-xml-doc-get-by-node parent)
                      'createelement
                      tag
                      ) ;_ end of vlax-invoke-method
                    ) ;_ end of vlax-invoke-method
              ) ;_ end of setq
        (if save
          (_kpblc-xml-doc-save (_kpblc-xml-doc-get-by-node node))
          ) ;_ end of if
        ) ;_ end of lambda
      ) ;_ end of function
    '(lambda (x)
       (_kpblc-error-print "_kpblc-xml-node-add-child" x)
       (setq res nil)
       ) ;_ end of lambda
    ) ;_ end of _kpblc-error-catch
  res
  ) ;_ end of defun

(defun _kpblc-xml-node-get-main (obj / res)
                                ;|
*    Получение главного (верхнего) узла xml-дерева. Валидность xml-файла не
* проверяется
*    Параметры вызова:
	obj	указатель на объект XML-документа
*    Примеры вызова:
(setq obj (_kpblc-xml-doc-get (findfile (strcat (_kpblc-dir-path-and-splash(_kpblc-dir-get-root-xml))"tables.xml"))))
(_kpblc-xml-node-get-main obj)
|;
  (_kpblc-error-catch
    (function
      (lambda ()
        (setq res (car (_kpblc-xml-conv-nodes-to-list
                         (_kpblc-property-get
                           obj
                           'childnodes
                           ) ;_ end of _kpblc-property-get
                         ) ;_ end of _kpblc-xml-conv-nodes-to-list
                       ) ;_ end of car
              ) ;_ end of setq
        ) ;_ end of lambda
      ) ;_ end of function
    '(lambda (x)
       (_kpblc-error-print "_kpblc-xml-node-get-main" x)
       (setq res nil)
       ) ;_ end of lambda
    ) ;_ end of _kpblc-error-catch
  res
  ) ;_ end of defun

(defun _kpblc-xml-node-get-parent (node)
  ;|
*    Получение указателя на родительский узел
*    Параметры вызова:
	node	указатель на узел, для которого надо получить родителя.
|;
  (_kpblc-property-get node 'parentnode)
  ) ;_ end of defun

(defun _kpblc-xml-node-remove (node / parent res)
                              ;|
*    Удаление узла xml-дерева
*    Параметры вызова:
	node	указатель на удаляемый узел. Не может быть родительским узлом
		дерева
*    При успешном удалении возвращает t.
|;
  (if (and (setq parent (_kpblc-property-get node 'parentnode))
           (not (equal parent node))
           ) ;_ end of and
    (_kpblc-error-catch
      (function
        (lambda ()
          (vlax-invoke-method parent 'removechild node)
          (setq res t)
          ) ;_ end of lambda
        ) ;_ end of function
      (function
        (lambda (x)
          (_kpblc-error-print "_kpblc-xml-node-remove" x)
          (setq res nil)
          ) ;_ end of lambda
        ) ;_ end of function
      ) ;_ end of _kpblc-error-catch
    ) ;_ end of if
  res
  ) ;_ end of defun

(defun _kpblc-xml-nodes-get-child-by-attribute (parent name value / lst res)
                                               ;|
*    Получение списка подчиненных узлов, у которых есть атрибут с указанным
* именем и значением
*    Параметры вызова:
	parent	указатель на "родительский" узел
	name	имя атрибута. Строка либо nil (nil -> "*")
	value	значение атрибута. Строка либо nil (nil не учитывается)
|;
  (setq name (if name
               (strcase name)
               "*"
               ) ;_ end of if
        lst  (mapcar
               (function
                 (lambda (x)
                   (cons
                     (cons "obj" x)
                     (list
                       (cons
                         "attr"
                         (mapcar
                           (function
                             (lambda (a)
                               (list (cons "name"
                                           (strcase (_kpblc-property-get a 'name))
                                           ) ;_ end of cons
                                     (cons "value"
                                           (strcase (_kpblc-conv-value-to-string
                                                      (vlax-variant-value
                                                        (_kpblc-property-get a 'value)
                                                        ) ;_ end of vlax-variant-value
                                                      ) ;_ end of _kpblc-conv-value-to-string
                                                    ) ;_ end of strcase
                                           ) ;_ end of cons
                                     ) ;_ end of list
                               ) ;_ end of lambda
                             ) ;_ end of function
                           (_kpblc-xml-attributes-get-by-node x)
                           ) ;_ end of mapcar
                         ) ;_ end of cons
                       ) ;_ end of list
                     ) ;_ end of cons
                   ) ;_ end of lambda
                 ) ;_ end of function
               (_kpblc-xml-nodes-get-child parent)
               ) ;_ end of mapcar
        res  (mapcar
               (function
                 (lambda (q) (cdr (assoc "obj" q)))
                 ) ;_ end of function
               (if value
                 (vl-remove-if-not
                   (function
                     (lambda (x)
                       (vl-remove-if-not
                         (function
                           (lambda (a)
                             (and (wcmatch (cdr (assoc "name" a)) name)
                                  (wcmatch (strcase value) (cdr (assoc "value" a)) )
                                  ) ;_ end of and
                             ) ;_ end of lambda
                           ) ;_ end of function
                         (cdr (assoc "attr" x))
                         ) ;_ end of vl-remove-if-not
                       ) ;_ end of lambda
                     ) ;_ end of function
                   lst
                   ) ;_ end of vl-remove-if-not
                 (vl-remove-if-not
                   (function
                     (lambda (x)
                       (vl-remove-if-not
                         (function (lambda (a)
                                     (wcmatch (cdr (assoc "name" a)) name)
                                     ) ;_ end of lambda
                                   ) ;_ end of function
                         (cdr (assoc "attr" x))
                         ) ;_ end of vl-remove-if-not
                       ) ;_ end of lambda
                     ) ;_ end of function
                   lst
                   ) ;_ end of vl-remove-if-not
                 ) ;_ end of if
               ) ;_ end of mapcar
        ) ;_ end of setq
  res
  ) ;_ end of defun

(defun _kpblc-xml-nodes-get-child-by-name-or-id (parent value)
                                                ;|
*    Получает список подчиненных xml-узлов
*    Параметры вызова:
  parent    vla-указатель на родительский узел. nil недопустим
  value     значение (строковое) атрибута name или ID. Приоритет отдается ID. nil недопустим
*    Возвращает список подузлов, у которых совпадает ID или name
|;
  (cond
    ((_kpblc-xml-nodes-get-child-by-attribute parent "id" value))
    ((_kpblc-xml-nodes-get-child-by-attribute parent "name" value))
    ) ;_ end of cond
  ) ;_ end of defun

(defun _kpblc-xml-nodes-get-child-by-tag (parent tag)
                                         ;|
*    Получение списка подчиненных узлов, у которых тэг совпадает с указанным
*    Параметры вызова:
	parent	указатель на "родительский" узел
	tag	маска имени тэга. nil -> "*"
|;
  (setq tag (if tag
              (strcase tag)
              "*"
              ) ;_ end of if
        ) ;_ end of setq
  (vl-remove-if-not
    (function
      (lambda (x)
        (wcmatch
          (strcase (_kpblc-conv-value-to-string (_kpblc-property-get x 'tagname))
                   ) ;_ end of strcase
          tag
          ) ;_ end of wcmatch
        ) ;_ end of lambda
      ) ;_ end of function
    (_kpblc-xml-nodes-get-child parent)
    ) ;_ end of vl-remove-if-not
  ) ;_ end of defun

(defun _kpblc-xml-nodes-get-child (parent / node childs res)
                                  ;|
*    Получение подчиненных элементов xml-дерева
*    Параметры вызова
	parent	указатель на узел, для которого получаем Child
		nil недопустим
*    Примеры вызова:
(setq obj (_kpblc-xml-get-document (findfile (strcat (_kpblc-dir-path-and-splash(_kpblc-dir-get-root-xml))"tables.xml"))))
(_kpblc-xml-get-nodes-child (_kpblc-xml-node-get-main obj))
|;
  (if (and parent
           (vlax-method-applicable-p parent 'haschildnodes)
           (equal (vlax-invoke-method parent 'haschildnodes)
                  :vlax-true
                  ) ;_ end of equal
           (setq childs (_kpblc-property-get parent 'childnodes))
           ) ;_ end of and
    (_kpblc-xml-conv-nodes-to-list childs)
    ) ;_ end of if
  ) ;_ end of defun

(defun _kpblc-xml-text-get-by-node (node)
                                   ;|
*    Получение text'a с узла дерева
*    Параметры вызова:
	node	указатель на обрабатываемый узел дерева
|;
  (_kpblc-property-get node 'text)
  ) ;_ end of defun

(defun _kpblc-xml-text-set-by-node (node text save)
                                   ;|
*    Назначение text'a узлу
*    Параметры вызова:
	node	указатель на узел дерева
	text	назначаемый текст. строка, тип не проверяется
	save	выполнять или нет запись xml-файла.
|;
  (_kpblc-error-catch
    (function
      (lambda ()
        (vlax-put-property node 'text text)
        (if save
          (_kpblc-xml-doc-save (_kpblc-xml-doc-get-by-node node))
          ) ;_ end of if
        ) ;_ end of lambda
      ) ;_ end of function
    '(lambda (x)
       (_kpblc-error-print "_kpblc-xml-text-set-by-node" x)
       ) ;_ end of lambda
    ) ;_ end of _kpblc-error-catch
  (_kpblc-xml-text-get-by-node node)
  ) ;_ end of defun
