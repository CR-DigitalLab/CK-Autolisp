(defun _kpblc-load-priority (path                        mask                        /
                             fun_conv-value-to-string    fun_conv-list-to-string     fun_eval-value-round
                             fun_list-dublicates-remove  fun_list-add-or-subst       fun_browsefiles-in-directory-nested
                             fun_conv-string-to-list     fun_eval-prior              file_lst
                             err_lst
                             )
                            ;|
*    Вычисляет последовательность загрузки lsp-кодов
*    Параметры вызова:
  path    каталог расположения исходных кодов. Оттуда "проверяются" все файлы lsp
  mask    маска вызова функций
*    Примеры вызова:
(kpblc:load-priority "b:\\_отчуждаемые\\semantic" "*kpblc*")
|;

  (defun fun_list-add-or-subst (lst key value)
                               ;|
*    Производит замену или дополнение элемента списка новым
*    Параметры вызова:
	lst			обрабатываемый список
	key			ключ
	value		устанавливаемое значение
|;
    (if (not value)
      (vl-remove-if (function (lambda (x) (= (car x) key))) lst)
      (if (cdr (assoc key lst))
        (subst (cons key value) (assoc key lst) lst)
        (cons (cons key value) lst)
        ) ;_ end of if
      ) ;_ end of if
    ) ;_ end of defun

  (defun fun_list-dublicates-remove (lst / result)
                                    ;|
*    Функция исключения дубликатов элементов списка 
*    Параметры вызова:
*	lst	обрабатываемый список
*    Возвращаемое значение: список без дубликатов соседних элементов
*    Примеры вызова:
(fun_list-dublicates-remove '((0.0 0.0 0.0) (10.0 0.0 0.0) (10.0 0.0 0.0) (0.0 0.0 0.0)) nil)
((0.0 0.0 0.0) (10.0 0.0 0.0) (0.0 0.0 0.0))
|;
    (foreach x lst
      (if (not (member x result))
        (setq result (cons x result))
        ) ;_ end of if
      ) ;_ end of foreach
    (reverse result)
    ) ;_ end of defun

  (defun fun_eval-value-round (value to)
                              ;|
;; http://forum.dwg.ru/showthread.php?p=301275
*    Выполняет округление числа до указанной точности
*    Примеры вызова:
(fun_eval-value-round 16.365 0.01) ; 16.37
|;
    (if (zerop to)
      value
      (* (atoi (rtos (/ (float value) to) 2 0)) to)
      ) ;_ end of if
    ) ;_ end of defun

  (defun fun_conv-value-to-string (value /)
                                  ;|
*    конвертация значения в строку.
|;
    (cond
      ((= (type value) 'str) value)
      ((= (type value) 'int) (itoa value))
      ((and (= (type value) 'real) (equal value (fun_eval-value-round value 1.) 1e-6))
       (itoa (fix value))
       )
      ((= (type value) 'real) (rtos value 2 14))
      ((not value) "")
      (t (vl-princ-to-string value))
      ) ;_ end of cond
    ) ;_ end of defun


  (defun fun_conv-list-to-string (lst sep)
                                 ;|
*    Преобразование списка в строку
*    Параметры вызова:
	lst	обрабатываемй список
	sep	разделитель. nil -> " "
|;
    (if (and lst
             (setq lst (mapcar (function fun_conv-value-to-string) lst))
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


  (defun fun_conv-string-to-list (string separator / i)
                                 ;|
*    Функция разбора строки. Возвращает список либо точечную пару.
*    Параметры вызова:
*	string		разбираемая строка
*	separator	символ, используемый в качестве разделителя частей
*    Примеры вызова:
(fun_conv-string-to-list "1;2;3;4;5;6" ";")	;'(1 2 3 4 5 6)
(fun_conv-string-to-list "1;2" ";")		;'(1 2)
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

  (defun fun_browsefiles-in-directory-nested (path mask)
;;;    Функция возвращает список файлов указанной маски, находящихся в
;;; заданном каталоге
;;;    Параметры вызова:
;;;	path	путь к корневому каталогу. nil недопустим
;;;  	mask	маска имени файла. nil или список недопустим
;;;    Примеры вызова:
    ;|
(fun_browsefiles-in-directory-nested "c:\\documents" "*.dwg")
|;
    (apply (function append)
           (cons (if (vl-directory-files path mask)
                   (mapcar (function (lambda (x) (strcat (vl-string-right-trim "\\" path) "\\" x)) ;_ end of lambda
                                     ) ;_ end of function
                           (vl-directory-files path mask)
                           ) ;_ end of mapcar
                   ) ;_ if
                 (mapcar (function
                           (lambda (x)
                             (fun_browsefiles-in-directory-nested (strcat (vl-string-right-trim "\\" path) "\\" x) mask)
                             ) ;_ end of lambda
                           ) ;_ end of function
                         (vl-remove ".." (vl-remove "." (vl-directory-files path nil -1))) ;_ end of vl-remove
                         ) ;_ mapcar
                 ) ;_ cons
           ) ;_ end of apply
    ) ;_ end of defun

  (defun fun_eval-prior (item / res)
                        ;|
*    вычисление приоритета загрузки
*    Параметры вызова:
  item   элемент file_lst '(("file" . "B:\\_отчуждаемые\\semantic\\kpblc-semantic-loader.LSP") ("calls" "kpblc-semantic-loader" "fun_autoload-autostart") ("defuns" "kpblc-semantic-loader") ("prior"))
  lst    file_lst
|;
    ;; (princ (strcat "\n File : " (cdr(assoc"file"item))))
    (cond
      ((setq res (cdr (assoc "prior" item))))
      (t
       (setq res      (apply (function +)
                             (mapcar
                               (function
                                 (lambda (calls)
                                   (+ 1.
                                      ((lambda (/ tmp)
                                         (setq tmp
                                                (car (vl-remove-if-not
                                                       (function
                                                         (lambda (x)
                                                           (member (strcase calls) (mapcar (function strcase) (cdr (assoc "defuns" x))))
                                                           ) ;_ end of lambda
                                                         ) ;_ end of function
                                                       file_lst
                                                       ) ;_ end of vl-remove-if-not
                                                     ) ;_ end of car
                                               ) ;_ end of setq
                                         (if (not tmp)
                                           (progn
                                             (if (not (member (strcase (vl-filename-base (cdr (assoc "file" item))) t)
                                                              (mapcar
                                                                (function car)
                                                                err_lst
                                                                ) ;_ end of mapcar
                                                              ) ;_ end of member
                                                      ) ;_ end of not
                                               (setq err_lst (cons (cons (strcase (vl-filename-base (cdr (assoc "file" item))) t)
                                                                         (if (listp calls)
                                                                           (fun_conv-list-to-string calls "; ")
                                                                           calls
                                                                           ) ;_ end of if
                                                                         ) ;_ end of cons
                                                                   err_lst
                                                                   ) ;_ end of cons
                                                     ) ;_ end of setq
                                               ) ;_ end of if
                                             0
                                             ) ;_ end of progn
                                           (fun_eval-prior tmp)
                                           ) ;_ end of if
                                         ) ;_ end of lambda
                                       )
                                      ;; file_lst
                                      ;; ) ;_ end of fun_eval-prior
                                      ) ;_ end of +
                                   ) ;_ end of lambda
                                 ) ;_ end of function
                               (cdr (assoc "calls" item)
                                    ) ;_ end of cdr
                               ) ;_ end of mapcar
                             ) ;_ end of apply
             file_lst (subst (subst (cons "prior" res) (assoc "prior" item) item)
                             item
                             file_lst
                             ) ;_ end of subst
                      ;; (fun_list-add-or-subst file_lst item (subst  (cons "prior" res ) (assoc"prior"item) item))
             ) ;_ end of setq
       )
      ) ;_ end of cond
          ;(princ (strcat "\n File : " (vl-filename-base (cdr (assoc "file" item))) " prior : " (rtos res 2 0))
          ;       ) ;_ end of princ
    res
    ) ;_ end of defun

  (setq
    file_lst (mapcar
               (function
                 (lambda (file / handle str calls defuns is_comment)
                   (setq handle (open file "r"))
                   (while (setq str (read-line handle))
                     (setq str (vl-string-trim " \t" str))
                     (if (wcmatch str "*;|,;*")
                       (setq is_comment t
                             str        (fun_conv-list-to-string (cdr (fun_conv-string-to-list str ";|")) " ")
                             ) ;_ end of setq
                       ) ;_ end of if
                     (if (wcmatch str "*|;*")
                       (setq is_comment nil
                             str        (fun_conv-list-to-string (cdr (fun_conv-string-to-list str "|;")) " ")
                             ) ;_ end of setq
                       ) ;_ end of if
                     (if (not is_comment)
                       (cond
                         ((wcmatch (strcase str) (strcat "*(DEFUN " (strcase mask) "*"))
                          (setq defuns (cons str defuns))
                          )
                         ((and (wcmatch (strcase str) (strcat "*(" (strcase mask) "*"))
                               (not (wcmatch (strcase str) (strcat "*`*" (strcase mask) "*")))
                               ) ;_ end of and
                          (setq calls (cons (vl-string-trim " \t" str) calls))
                          )
                         ) ;_ end of cond
                       ) ;_ end of cond
                     ) ;_ end of while
                   (close handle)
                   (list (cons "file" (findfile file))
                         (cons "calls"
                               (fun_list-dublicates-remove
                                 (vl-remove-if
                                   (function
                                     (lambda (x)
                                       (wcmatch x "\"*,*\"")
                                       ) ;_ end of lambda
                                     ) ;_ end of function
                                   (mapcar
                                     (function
                                       (lambda (x)
                                         (vl-string-trim " ()'" x)
                                         ) ;_ end of lambda
                                       ) ;_ end of function
                                     (vl-remove-if-not
                                       (function
                                         (lambda (x)
                                           (wcmatch (strcase x) (strcase mask))
                                           ) ;_ end of lambda
                                         ) ;_ end of function
                                       (apply (function append)
                                              (mapcar
                                                (function
                                                  (lambda (x)
                                                    (fun_conv-string-to-list x " ")
                                                    ) ;_ end of lambda
                                                  ) ;_ end of function
                                                calls
                                                ) ;_ end of mapcar
                                              ) ;_ end of apply
                                       ) ;_ end of vl-remove-if-not
                                     ) ;_ end of mapcar
                                   ) ;_ end of vl-remove-if
                                 ) ;_ end of fun_list-dublicates-remove
                               ) ;_ end of cons
                         (cons "defuns"
                               (mapcar
                                 (function
                                   (lambda (x)
                                     (vl-string-trim " ()" x)
                                     ) ;_ end of lambda
                                   ) ;_ end of function
                                 (vl-remove-if-not
                                   (function
                                     (lambda (x)
                                       (wcmatch (strcase x) (strcase mask))
                                       ) ;_ end of lambda
                                     ) ;_ end of function
                                   (apply (function append)
                                          (mapcar
                                            (function
                                              (lambda (x)
                                                (fun_conv-string-to-list x " ")
                                                ) ;_ end of lambda
                                              ) ;_ end of function
                                            defuns
                                            ) ;_ end of mapcar
                                          ) ;_ end of apply
                                   ) ;_ end of vl-remove-if-not
                                 ) ;_ end of mapcar
                               ) ;_ end of cons
                         (cons "prior"
                               (if (= (length calls) 0)
                                 -1
                                 ) ;_ end of if
                               ) ;_ end of cons
                         ) ;_ end of list
                   ) ;_ end of lambda
                 ) ;_ end of function
               (vl-remove-if
                 (function
                   (lambda (x)
                     (vl-catch-all-error-p
                       (vl-catch-all-apply
                         (function
                           (lambda ()
                             (load x)
                             ) ;_ end of lambda
                           ) ;_ end of function
                         ) ;_ end of vl-catch-all-apply
                       ) ;_ end of vl-catch-all-error-p
                     ) ;_ end of lambda
                   ) ;_ end of function
                 (fun_browsefiles-in-directory-nested path "*.lsp")
                 ) ;_ end of vl-remove-if
               ) ;_ end of mapcar
    file_lst (mapcar
               (function
                 (lambda (x)
                   (fun_list-add-or-subst
                     x
                     "calls"
                     (vl-remove-if
                       (function
                         (lambda (x1)
                           (member (strcase x1) (mapcar (function strcase) (cdr (assoc "defuns" x))))
                           ) ;_ end of lambda
                         ) ;_ end of function
                       (cdr (assoc "calls" x))
                       ) ;_ end of vl-remove-if
                     ) ;_ end of fun_list-add-or-subst
                   ) ;_ end of lambda
                 ) ;_ end of function
               file_lst
               ) ;_ end of mapcar
    ) ;_ end of setq
  (mapcar
    (function
      (lambda (x)
        (fun_eval-prior x)
        ) ;_ end of lambda
      ) ;_ end of function
    (vl-remove nil file_lst)
    ) ;_ end of mapcar
  (if err_lst
    ((lambda (/ filelog handle)
       (setq filelog (strcat (vl-string-right-trim "\\" path) "\\eval.log")
             handle  (open filelog "w")
             ) ;_ end of setq
       (mapcar
         (function
           (lambda (err)
             (write-line (strcat "File " (car err) " uses : " (cdr err)) handle)
             ) ;_ end of lambda
           ) ;_ end of function
         (vl-sort err_lst '(lambda (a b) (< (car a) (car b))))
         ) ;_ end of mapcar
       (close handle)
       ) ;_ end of lambda
     )
    ) ;_ end of if
  (vl-sort file_lst (function (lambda (a b) (< (cdr (assoc "prior" a)) (cdr (assoc "prior" b))))))
  ) ;_ end of defun
