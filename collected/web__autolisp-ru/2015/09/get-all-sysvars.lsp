(vl-load-com)

(defun c:html-report (/ lst file handle ver_lst)
  (if (and (setq lst (get-all-sysvars))
           (setq file (getfiled "Имя отчета" "" "html" 1))
           ) ;_ end of and
    (progn
      (setq handle (open file "w"))
      (foreach item (append
                      (list "<html><body>"
                            "<table width=\"100%\" cellpadding=\"4\" cellspacing=\"0\" border=\"1px\">"
                            "<tr style=\"text-align:center;\"><td rowspan=\"2\">Название переменной</td><td colspan=\""
                            (itoa
                              (apply
                                (function max)
                                (mapcar
                                  (function
                                    (lambda (x)
                                      (length (cdr (assoc "ver" x)))
                                      ) ;_ end of lambda
                                    ) ;_ end of function
                                  lst
                                  ) ;_ end of mapcar
                                ) ;_ end of apply
                              ) ;_ end of itoa
                            "\">Доступна в версиях...</td></tr>"
                            "<tr>"
                            (apply (function strcat)
                                   (mapcar
                                     (function
                                       (lambda (x)
                                         (strcat "<td>" x "</td>")
                                         ) ;_ end of lambda
                                       ) ;_ end of function
                                     (setq
                                       ver_lst
                                        (vl-sort
                                          (_kpblc-list-dublicates-remove
                                            (apply 'append
                                                   (mapcar '(lambda (x) (cdr (assoc "ver" x))) lst)
                                                   ) ;_ end of apply
                                            ) ;_ end of _kpblc-list-dublicates-remove
                                          '<
                                          ) ;_ end of vl-sort
                                       ) ;_ end of setq
                                     ) ;_ end of mapcar
                                   ) ;_ end of apply
                            "</tr>"
                            ) ;_ end of list
                      (mapcar
                        (function
                          (lambda (sysvar)
                            (strcat "<tr><td>"
                                    (cdr (assoc "name" sysvar))
                                    "</td>"
                                    (apply (function strcat)
                                           (mapcar
                                             (function
                                               (lambda (av_ver)
                                                 (strcat "<td>"
                                                         (if (member av_ver (cdr (assoc "ver" sysvar)))
                                                           "+"
                                                           ""
                                                           ) ;_ end of if
                                                         "</td>"
                                                         ) ;_ end of strcat
                                                 ) ;_ end of lambda
                                               ) ;_ end of function
                                             ver_lst
                                             ) ;_ end of mapcar
                                           ) ;_ end of apply
                                    "</tr>"
                                    ) ;_ end of strcat
                            ) ;_ end of lambda
                          ) ;_ end of function
                        lst
                        ) ;_ end of mapcar
                      '("</table></body></html>")
                      ) ;_ end of append
        (write-line item handle)
        ) ;_ end of foreach
      (close handle)
      (setq file   (strcat (vl-string-right-trim "\\" (vl-filename-directory file))
                           "\\"
                           (vl-filename-base file)
                           ".lsp"
                           ) ;_ end of strcat
            handle (open file "w")
            ) ;_ end of setq
      (foreach item (append '("(setq *global-sysvar-list* '(")
                            (mapcar
                              (function
                                (lambda (x)
                                  (strcat "((\"name\" . \""
                                          (cdr (assoc "name" x))
                                          "\")(\"ver\" . \""
                                          (apply (function strcat)
                                                 (append (list (cadr (assoc "ver" x)))
                                                         (mapcar
                                                           (function
                                                             (lambda (a)
                                                               (strcat "," a)
                                                               ) ;_ end of lambda
                                                             ) ;_ end of function
                                                           (cddr (assoc "ver" x))
                                                           ) ;_ end of mapcar
                                                         ) ;_ end of append
                                                 ) ;_ end of apply
                                          "\"))"
                                          ) ;_ end of strcat
                                  ) ;_ end of lambda
                                ) ;_ end of function
                              lst
                              ) ;_ end of mapcar
                            '("))")
                            ) ;_ end of append
        (write-line item handle)
        ) ;_ end of foreach
      (close handle)
      ) ;_ end of progn
    ) ;_ end of if
  ) ;_ end of defun

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
        folder (vlax-invoke-method
                 shlobj
                 'browseforfolder
                 (vla-get-hwnd (vlax-get-acad-object))
                 caption
                 (+ 512 16)
                 ) ;_ end of vlax-invoke-method
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

(defun get-all-sysvars (/ dir lst_files handle str lst tmp curver)
                       ;|
*    Получение перечисления всех системных переменных с указанием версии, в которой эта
* переменная существует. Проверка выполняется на основе файлов *.svf; *.log; acadinfo*.txt
|;
  (if (and (setq dir (vl-browsefolder "Каталог *.log, *.svf, acadinfo*.txt"))
           (setq lst_files (vl-directory-files dir "*.*" 1))
           (setq lst_files (vl-remove-if-not
                             (function
                               (lambda (x)
                                 (wcmatch (strcase x) "*####*.LOG,*####*.SVF,*####*.TXT")
                                 ) ;_ end of lambda
                               ) ;_ end of function
                             lst_files
                             ) ;_ end of vl-remove-if-not
                 ) ;_ end of setq
           (setq lst_files (mapcar
                             (function
                               (lambda (x)
                                 (strcat (vl-string-right-trim "\\" dir) "\\" x)
                                 ) ;_ end of lambda
                               ) ;_ end of function
                             lst_files
                             ) ;_ end of mapcar
                 ) ;_ end of setq
           ) ;_ end of and
    (progn
      (foreach file lst_files
        (prin1 (strcat "\nОбработка файла " file))
        (setq
          curver (vl-list->string
                   (vl-remove-if-not (function (lambda (x) (<= 48 x 57))) (vl-string->list (vl-filename-base file)))
                   ) ;_ end of vl-list->string
          handle (open file "r")
          ) ;_ end of setq
        (while (setq str (read-line handle))
          (if (/= str "")
            (progn
              (setq str
                     (cond
                       ((= (strcase (vl-filename-extension file)) ".LOG")
                        (strcase (car (_kpblc-conv-string-to-list str " ")) t)
                        )
                       ((and (= (strcase (vl-filename-extension file)) ".TXT")
                             (wcmatch (strcase str) "; READ-ONLY - *")
                             ) ;_ end of and
                        (strcase (car (_kpblc-conv-string-to-list (substr str (1+ (strlen "; read-only - "))) " "))
                                 t
                                 ) ;_ end of strcase
                        )
                       ((and (= (strcase (vl-filename-extension file)) ".TXT")
                             (wcmatch (strcase str) "(SETVAR *")
                             ) ;_ end of and
                        (vl-string-trim
                          "\""
                          (strcase (car (_kpblc-conv-string-to-list (substr str (1+ (strlen "(setvar "))) " ")) t)
                          ) ;_ end of vl-string-trim
                        )
                       ((and (= (strcase (vl-filename-extension file)) ".TXT")
                             (wcmatch (strcase str) ";(SETVAR *")
                             ) ;_ end of and
                        (vl-string-trim
                          "\""
                          (strcase (car (_kpblc-conv-string-to-list (substr str (1+ (strlen ";(setvar "))) " ")) t)
                          ) ;_ end of vl-string-trim
                        )
                       ((= (strcase (vl-filename-extension file)) ".SVF")
                        (strcase (vl-string-trim "_" (car (_kpblc-conv-string-to-list str " "))) t)
                        )
                       ) ;_ end of cond
                    ) ;_ end of setq
              (if str
                (if
                  (setq tmp (car (vl-remove-if-not (function (lambda (x) (= (cdr (assoc "name" x)) str))) lst)))
                   (if (not (wcmatch (cdr (assoc "ver" tmp)) (strcat "*" curver "*")))
                     (setq lst (subst (_kpblc-list-add-or-subst tmp "ver" (strcat (cdr (assoc "ver" tmp)) "," curver))
                                      tmp
                                      lst
                                      ) ;_ end of subst
                           ) ;_ end of setq
                     ) ;_ end of if
                   (setq lst (cons (list (cons "name" str) (cons "ver" curver)) lst))
                   ) ;_ end of if
                ) ;_ end of if
              ) ;_ end of progn
            ) ;_ end of if
          ) ;_ end of while
        (close handle)
        ) ;_ end of foreach
      ) ;_ end of progn
    ) ;_ end of if
  (vl-sort (mapcar
             (function
               (lambda (x)
                 (list (assoc "name" x)
                       (cons "ver" (vl-sort (_kpblc-conv-string-to-list (cdr (assoc "ver" x)) ",") '<))
                       ) ;_ end of list
                 ) ;_ end of lambda
               ) ;_ end of function
             lst
             ) ;_ end of mapcar
           (function (lambda (a b) (< (cdr (assoc "name" a)) (cdr (assoc "name" b)))))
           ) ;_ end of vl-sort
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
*    Функция исключения дубликатов элементов списка. Строковые значения обрабатываются, наплевав на регистр
*    Параметры вызова:
*  lst  обрабатываемый список
*    Возвращаемое значение: список без дубликатов соседних элементов
*    Примеры вызова:
(_kpblc-list-dublicates-remove '((0.0 0.0 0.0) (10.0 0.0 0.0) (10.0 0.0 0.0) (0.0 0.0 0.0)) nil) ; ((0.0 0.0 0.0) (10.0 0.0 0.0) (0.0 0.0 0.0))
|;
  (foreach x lst
    (if (not (member (if (= (type x) 'str)
                       (strcase x)
                       x
                       ) ;_ end of if
                     (mapcar
                       (function
                         (lambda (a)
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