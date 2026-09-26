(vl-load-com)

(defun get-all-workspaces (/ res mainmenu acadver copy xml_doc)
  (setq	acadver	 (atof (getvar "acadver"))
	mainmenu (vla-get-menufile
		   (vla-get-files
		     (vla-get-preferences (vlax-get-acad-object))
		   )
		 )
	mainmenu (strcat
		   (vl-string-right-trim
		     "\\"
		     (vl-filename-directory mainmenu)
		   )
		   "\\"
		   (car
		     (vl-remove-if
		       (function
			 (lambda (x)
			   (wcmatch (strcase x) "*.BAK.*")
			 ) ;_ end of lambda
		       ) ;_ end of function
		       (vl-directory-files
			 (vl-filename-directory mainmenu)
			 (strcat (vl-filename-base mainmenu) "*.CUI*")
		       )
		     ) ;_ end of vl-remove-if
		   ) ;_ end of car
		 ) ;_ end of strcat
  ) ;_ end of setq
  (cond
    ((<= acadver 16.1)
     (alert
       "В версиях до 2005 включительно рабочих пространств не было!"
     )
    )
    ((<= acadver 17.2)
     ;; 2009, последняя версия, использующая cui
     (setq xml_doc (_kpblc-xml-doc-get mainmenu)
	   res	   (mapcar
		     (function
		       (lambda (node /)
			 (_kpblc-xml-text-get-by-node
			   (car (_kpblc-xml-nodes-get-child-by-tag node "Name"))
			 )
		       ) ;_ end of lambda
		     ) ;_ end of function
		     (_kpblc-xml-nodes-get-child
		       (car (_kpblc-xml-nodes-get-child-by-tag
			      (car (_kpblc-xml-nodes-get-child-by-tag
				     (car (_kpblc-xml-nodes-get-child-by-tag
					    (_kpblc-xml-node-get-main xml_doc)
					    "header"
					  )
				     )
				     "WorkspaceRoot"
				   ) ;_ end of _kpblc-xml-nodes-get-child-by-tag
			      ) ;_ end of car
			      "WorkspaceConfigRoot"
			    ) ;_ end of _kpblc-xml-nodes-get-child-by-tag
		       ) ;_ end of car
		     ) ;_ end of _kpblc-xml-nodes-get-child
		   ) ;_ end of mapcar
     ) ;_ end of setq
     (_kpblc-xml-doc-release xml_doc)
     res
    )
    ((> acadver 17.2)
     ;; cuix
     ;; Копируем файл cuix -> %temp%\<Name>.zip

     ;; Создаем временный каталог
     (if (not
	   (vl-find-file-or-dir
	     (setq
	       copy (strcat (vl-string-right-trim "\\" (getenv "temp"))
			    "\\"
			    (vl-filename-base mainmenu)
		    )
	     )
	   ) ;_ end of vl-find-file-or-dir
	 ) ;_ end of not
       (vl-mkdir copy)
       (foreach	file (vl-directory-files copy "*.*" 1)
	 (vl-file-delete
	   (strcat (vl-string-right-trim "\\" copy) "\\" file)
	 )
       ) ;_ end of foreach
     ) ;_ end of if
     (vl-file-copy
       mainmenu
       (setq copy (strcat copy "\\" (vl-filename-base mainmenu) ".zip"))
     )
     (if (and (extractfilefromzip
		copy
		"WorkspaceRoot.cui"
		(vl-filename-directory copy)
	      ) ;_ end of extractfilefromzip
	      (findfile
		(setq copy (strcat (vl-string-right-trim
				     "\\"
				     (vl-filename-directory copy)
				   )
				   "\\WorkspaceRoot.cui"
			   )
		)
	      ) ;_ end of findfile
	 ) ;_ end of and
       (progn
	 (setq xml_doc (_kpblc-xml-doc-get copy)
	       res     (mapcar
			 (function
			   (lambda (node /)
			     (_kpblc-xml-text-get-by-node
			       (car
				 (_kpblc-xml-nodes-get-child-by-tag node "Name")
			       )
			     )
			   ) ;_ end of lambda
			 ) ;_ end of function
			 (_kpblc-xml-nodes-get-child
			   (car	(_kpblc-xml-nodes-get-child-by-tag
				  (_kpblc-xml-node-get-main xml_doc)
				  "WorkspaceConfigRoot"
				)
			   )
			 ) ;_ end of _KPBLC-XML-NODES-GET-CHILD
		       ) ;_ end of mapcar
	 ) ;_ end of setq
	 (_kpblc-xml-doc-release xml_doc)
	 res
       ) ;_ end of progn
     ) ;_ end of if
    )
  ) ;_ end of cond
) ;_ end of defun

(defun extractfilefromzip (zipfile srcname strdest / folder fso)
  ;; http://forum.dwg.ru/showthread.php?p=1295861#post1295861
  (if (member (strcase srcname)
	      (mapcar (function strcase) (getallfilesinzip zipfile))
      )
    (progn
      (setq fso (vlax-create-object "Shell.Application"))
      (setq folder (vlax-invoke fso 'namespace strdest))
      (vlax-invoke folder 'copyhere (strcat zipfile "\\" srcname))
      (vlax-release-object folder)
      (vlax-release-object fso)
    ) ;_ end of progn
  ) ;_ end of if
) ;_ end of defun

(defun getallfilesinzip
       (zipfile / count file filelist files folder fso ndx path)
  ;; http://forum.dwg.ru/showthread.php?p=1295861#post1295861
  ;; (GetAllFilesInZip "source file.zip with path") returns a list of all files in the zip file
  (setq path (car (fnsplitl zipfile)))
  (setq fso (vlax-create-object "Shell.Application"))
  (setq folder (vlax-invoke fso 'namespace zipfile))
  (setq files (vlax-invoke folder 'items))
  (setq count (vlax-get-property files 'count))
  (setq ndx 0)
  (repeat count
    (setq file (vlax-invoke files 'item ndx))
    (setq
      filelist (append filelist (list (vlax-get-property file 'name)))
    )
    (setq ndx (1+ ndx))
  ) ;_ end of repeat
  filelist
) ;_ end of defun


(defun _kpblc-xml-doc-get (file / doc)
			  ;|
*    Получение указателя на xml-DOMDocument
*    Параметры вызова:
  file  xml-файл. Валидность не проверяется
|;
  (if (findfile file)
    (_kpblc-error-catch
      (function
	(lambda	()
	  (setq
	    doc	(vlax-get-or-create-object "MSXML2.DOMDocument.3.0")
	  )
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
  doc  указатель на XML-документ.
*    Примеры вызова:
(setq obj (_kpblc-xml-get-document
            (findfile (strcat (_kpblc-dir-path-and-splash (_kpblc-get-path-root-xml)) "tables.xml"))
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

(defun _kpblc-xml-node-get-main	(obj / res)
				;|
*    Получение главного (верхнего) узла xml-дерева. Валидность xml-файла не
* проверяется
*    Параметры вызова:
  obj  указатель на объект XML-документа
*    Примеры вызова:
(setq obj (_kpblc-xml-doc-get (findfile (strcat (_kpblc-dir-path-and-splash(_kpblc-get-path-root-xml))"tables.xml"))))
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

(defun _kpblc-xml-nodes-get-child (parent / node childs res)
				  ;|
*    Получение подчиненных элементов xml-дерева
*    Параметры вызова
  parent  указатель на узел, для которого получаем Child
    nil недопустим
*    Примеры вызова:
(setq obj (_kpblc-xml-get-document (findfile (strcat (_kpblc-dir-path-and-splash(_kpblc-get-path-root-xml))"tables.xml"))))
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

(defun _kpblc-xml-nodes-get-child-by-name-or-id	(parent value)
						;|
*    Получает список подчиненных xml-узлов
*    Параметры вызова:
  parent    vla-указатель на родительский узел. nil недопустим
  value     значение (строковое) атрибута name или ID. Приоритет отдается ID. nil недопустим
*    Возвращает список подузлов, у которых совпадает ID или name
|;
  (cond
    ((_kpblc-xml-nodes-get-child-by-attribute parent "id" value)
    )
    ((_kpblc-xml-nodes-get-child-by-attribute
       parent
       "name"
       value
     )
    )
  ) ;_ end of cond
) ;_ end of defun

(defun _kpblc-xml-nodes-get-child-by-attribute
       (parent name value / lst res)
       ;|
*    Получение списка подчиненных узлов, у которых есть атрибут с указанным
* именем и значением
*    Параметры вызова:
  parent  указатель на "родительский" узел
  name  имя атрибута. Строка либо nil (nil -> "*")
  value  значение атрибута. Строка либо nil (nil не учитывается)
|;
  (setq	name (if name
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
			       (list
				 (cons "name"
				       (strcase (_kpblc-property-get a 'name))
				 ) ;_ end of cons
				 (cons
				   "value"
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
				  (wcmatch (strcase value)
					   (cdr (assoc "value" a))
				  )
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

(defun _kpblc-xml-nodes-get-child-by-tag (parent tag)
					 ;|
*    Получение списка подчиненных узлов, у которых тэг совпадает с указанным
*    Параметры вызова:
  parent  указатель на "родительский" узел
  tag  маска имени тэга. nil -> "*"
|;
  (setq	tag (if	tag
	      (strcase tag)
	      "*"
	    ) ;_ end of if
  ) ;_ end of setq
  (vl-remove-if-not
    (function
      (lambda (x)
	(wcmatch
	  (strcase (_kpblc-conv-value-to-string
		     (_kpblc-property-get x 'tagname)
		   )
	  ) ;_ end of strcase
	  tag
	) ;_ end of wcmatch
      ) ;_ end of lambda
    ) ;_ end of function
    (_kpblc-xml-nodes-get-child parent)
  ) ;_ end of vl-remove-if-not
) ;_ end of defun

(defun _kpblc-xml-attribute-get-name-and-value (xml-attribute)
					       ;|
*    Получение списка точечной пары имени и значения атрибута
*    Параметры вызова:
  xml-attribute  указатель на xml-атрибут документа. Допустимые
    значения:
      vla-object  указатель на 1 атрибут / узел дерева
      list    список атрибутов
      nil    ничего не делается
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
	      (setq _res (vlax-variant-value
			   (_kpblc-property-get xml-attribute 'nodevalue)
			 )
	      )
	      (foreach item '(("@qute;" . "\"")
			      ("&quot;" . "\"")
			      ("&amp;" . "&")
			      ("&#10;" . "\r")
			      ("&#13;" . "\n")
			     )
		(setq _res (_kpblc-string-replace-noreg
			     _res
			     (car item)
			     (cdr item)
			   )
		)
	      ) ;_ end of foreach
	      _res
	    ) ;_ end of lambda
	   )
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
     (mapcar (function _kpblc-xml-attribute-get-name-and-value)
	     xml-attribute
     )
    )
  ) ;_ end of cond
) ;_ end of defun

(defun _kpblc-xml-attributes-get-by-node (node)
					 ;|
*    Получение атрибутов узла XML-дерева.
*    Параметры вызова:
  node  проверяемый узел
|;
  (if (vlax-property-available-p node 'attributes)
    (_kpblc-xml-conv-nodes-to-list
      (_kpblc-property-get node 'attributes)
    ) ;_ end of _kpblc-xml-conv-nodes-to-list
  ) ;_ end of if
) ;_ end of defun

(defun _kpblc-xml-text-get-by-node (node)
				   ;|
*    Получение text'a с узла дерева
*    Параметры вызова:
  node  указатель на обрабатываемый узел дерева
|;
  (_kpblc-property-get node 'text)
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
    ((= (type ent_value) 'ename)
     (vlax-ename->vla-object ent_value)
    )
    ((setq res (_kpblc-conv-ent-to-ename ent_value))
     (vlax-ename->vla-object res)
    )
  ) ;_ end of cond
) ;_ end of defun

(defun _kpblc-conv-ent-to-ename	(ent_value / _lst)
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
    ((and (= (type ent_value) 'str)
	  (handent ent_value)
	  (entget (handent ent_value))
     )
     (handent ent_value)
    )
    ((and (= (type ent_value) 'str)
	  (handent ent_value)
	  (tblobjname "style" ent_value)
     )
     (tblobjname "style" ent_value)
    )
    ((and (= (type ent_value) 'str)
	  (handent ent_value)
	  (tblobjname "dimstyle" ent_value)
     )
     (tblobjname "dimstyle" ent_value)
    )
    ((and (= (type ent_value) 'str)
	  (handent ent_value)
	  (tblobjname "block" ent_value)
     )
     (tblobjname "block" ent_value)
    )
    ((and (= (type ent_value) 'list) (cdr (assoc -1 ent_value)))
     (cdr (assoc -1 ent_value))
    )
    (t nil)
  ) ;_ end of cond
) ;_ end of defun

(defun _kpblc-xml-conv-nodes-to-list (nodes / i res)
				     ;|
*    Преобразование указателя на коллекцию Nodes xml-объекта в список.
*    Исключаются описания не узлов (комментарии, DATA-узлы и т.п.)
*    Параметры вызова:
  nodes  указатель на коллекцию узлов xml-документа
|;
  (_kpblc-error-catch
    (function
      (lambda ()
	(setq i 0)
	(while (< i (_kpblc-property-get nodes 'length))
	  (setq	res (cons (vlax-get-property nodes 'item i) res)
		i   (1+ i)
	  ) ;_ end of setq
	) ;_ end of while
	(setq
	  res (vl-remove-if-not
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

(defun _kpblc-error-print (func-name msg / res)
			  ;|
*    Функция вывода сообщения об ошибке для (_kpblc-error-catch)
*    Параметры вызова:
*  func-name  имя функции, в которой возникла ошибка
*  msg    сообщение об ошибке
|;
  (princ (setq res
		(strcat	"\n ** "
			(vl-string-trim
			  "][ :\n<>"
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
  (princ)
) ;_ end of defun

(defun _kpblc-conv-value-to-string (value /)
				   ;|
*    конвертация значения в строку.
|;
  (cond
    ((= (type value) 'str) value)
    ((= (type value) 'int) (itoa value))
    ((and (= (type value) 'real)
	  (equal value (_kpblc-eval-value-round value 1.) 1e-6)
     )
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

(defun _kpblc-string-replace-noreg (str old new / pos)
				   ;|
*    Функция замены вхождений подстроки на новую. Регистронезависима
*    Параметры вызова:
*  str  исходная строка
*  old  старая строка
*  new  новая строка
*    Позволяет менять аналогичные строки: "str" -> "'_str'"
|;
  (_kpblc-conv-list-to-string
    (_kpblc-conv-string-to-list str old)
    new
  )
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
	  (setq	res    (cons (substr string 1 pos) res)
		string (substr string (+ (strlen separator) 1 pos))
	  ) ;_ end of setq
	) ;_ end of while
	(reverse (cons string res))
      ) ;_ end of lambda
     )
    )
    ((wcmatch (strcase string)
	      (strcat "*" (strcase separator) "*")
     )
     ((lambda (/ pos res _str prev)
	(setq pos  1
	      prev 1
	      _str (substr string pos)
	) ;_ end of setq
	(while (<= pos (1+ (- (strlen string) (strlen separator))))
	  (if ;; (wcmatch (strcase (substr string pos)) (strcase (strcat separator "*")))
	      (wcmatch (strcase (substr string pos (strlen separator)))
		       (strcase separator)
	      )
	    (setq res	 (cons (substr string 1 (1- pos)) res)
		  string (substr string (+ (strlen separator) pos))
		  pos	 0
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


(defun vl-find-file-or-dir (path /)
  (cond
    ((or (findfile path)
	 (findfile (vl-string-right-trim "\\" path))
	 (findfile (strcat (vl-string-right-trim "\\" path) "\\"))
     ) ;_ end of or
     (vl-string-right-trim "\\" path)
    )
    ((vl-file-directory-p path)
     (if (not (vl-catch-all-error-p
		(vl-catch-all-apply
		  (function
		    (lambda (/ fso _res)
		      (setq fso	 (vlax-get-or-create-object
				   "Scripting.FileSystemObject"
				 ) ;_ end of vlax-get-or-create-object
			    _res (vlax-invoke-method fso 'getfolder path)
		      ) ;_ end of setq
		      (vl-catch-all-apply
			(function
			  (lambda ()
			    (vlax-release-object fso)
			  ) ;_ end of lambda
			) ;_ end of function
		      ) ;_ end of vl-catch-all-apply
		      _res
		    ) ;_ end of lambda
		  ) ;_ end of function
		) ;_ end of vl-catch-all-apply
	      ) ;_ end of vl-catch-all-error-p
	 ) ;_ end of not
       (vl-string-right-trim "\\" path)
     ) ;_ end of if
    )
  ) ;_ end of cond
) ;_ end of defun