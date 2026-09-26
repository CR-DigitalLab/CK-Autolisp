(defun _lispru-set-support-paths (file                    /                       _kpblc-list-dublicates-remove
                                  _kpblc-conv-list-to-string                      _kpblc-conv-string-to-list
                                  handle                  str                     lst
                                  paths
                                  )
                                 ;|
*    Назначение путей поддержки для AutoCAD на основании файла с перечисленными путями
*    Параметры вызова:
  file    путь к файлу txt с описаниями путей. nil -> запрос у пользователя
|;
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

  (defun _kpblc-list-dublicates-remove (lst / result)
                                       ;|
*    Функция исключения дубликатов элементов списка 
*    Параметры вызова:
*	lst	обрабатываемый список
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
      (t (list string))
      ) ;_ end of cond
    ) ;_ end of defun


  (if (or (and file (findfile file))
          (and (setq file (getfiled "Select file with supported paths enum" "" "txt" 4))
               (/= file "")
               (findfile file)
               ) ;_ end of and
          ) ;_ end of or
    (progn
      (setq handle (open file "r"))
      (while (setq str (read-line handle)) (setq lst (cons str lst)))
      (close handle)
      (setq lst ((lambda (/ res)
                   (foreach item (append
                                   (vl-remove-if-not
                                     (function
                                       (lambda (x)
                                         (setq x (vl-string-right-trim "\\" x))
                                         (if (findfile x)
                                           x
                                           ) ;_ end of if
                                         ) ;_ end of lambda
                                       ) ;_ end of function
                                     (_kpblc-conv-string-to-list (getenv "ACAD") ";")
                                     ) ;_ end of vl-remove-if-not
                                   (vl-remove-if-not
                                     (function
                                       (lambda (x)
                                         (if (findfile (setq x (vl-string-right-trim "\\" x)))
                                           x
                                           ) ;_ end of if
                                         ) ;_ end of lambda
                                       ) ;_ end of function
                                     (reverse lst)
                                     ) ;_ end of vl-remove-if-not
                                   ) ;_ end of append
                     (if (not (member (strcase item) (mapcar (function strcase) res)))
                       (setq res (cons item res))
                       ) ;_ end of if
                     ) ;_ end of foreach
                   (reverse res)
                   ) ;_ end of lambda
                 )
            ) ;_ end of setq
      (setenv "ACAD" (apply (function strcat) (mapcar (function (lambda (x) (strcat x ";"))) lst)))
      ) ;_ end of progn
    ) ;_ end of if
  ) ;_ end of defun
