(defun lispru-defuns (file / err start res)
                     ;|
*    Определение имен функций и переменных, загруженных fas- или vlx-файлом
*    Параметры вызова:
	file		полный путь к загружаемому файлу, с указанием расширения.
|;
  (if (and (findfile file)
           (not (vl-file-directory-p file))
           ) ;_ end of and
    (progn
      (setq start (mapcar (function strcase) (atoms-family 1)))
      (if (not (vl-catch-all-error-p
                 (setq err (vl-catch-all-apply
                             (function
                               (lambda ()
                                 (cond
                                   ((member (strcase (vl-filename-extension file) t)
                                            '(".lsp" ".fas" ".vlx")
                                            ) ;_ end of member
                                    (load file)
                                    )
                                   ((= (strcase (vl-filename-extension file) t) ".arx")
                                    (arxload file)
                                    )
                                   ((= (strcase (vl-filename-extension file) t) ".dll")
                                    (command "_.netload" file)
                                    )
                                   ) ;_ end of cond
                                 (foreach item (mapcar (function strcase) (atoms-family 1))
                                   (if (not (member item start))
                                     (setq res (cons item res))
                                     ) ;_ end of if
                                   ) ;_ end of foreach
                                 ) ;_ end of lambda
                               ) ;_ end of function
                             ) ;_ end of vl-catch-all-apply
                       ) ;_ end of setq
                 ) ;_ end of vl-catch-all-error-p
               ) ;_ end of not
        (progn
          (if (setq res (vl-sort (vl-remove-if
                                   (function
                                     (lambda (x)
                                       (member (strcase x) '("START" "FILE" "LISPRU-DEFUNS"))
                                       ) ;_ end of lambda
                                     ) ;_ end of function
                                   res
                                   ) ;_ end of vl-remove-if
                                 '>
                                 ) ;_ end of vl-sort
                    ) ;_ end of setq
            (princ (apply (function strcat)
                          (cons (car res)
                                (mapcar
                                  (function
                                    (lambda (x)
                                      (strcat "\n" x)
                                      ) ;_ end of lambda
                                    ) ;_ end of function
                                  (cdr res)
                                  ) ;_ end of mapcar
                                ) ;_ end of cons
                          ) ;_ end of apply
                   ) ;_ end of princ
            ) ;_ end of if
          ) ;_ end of progn
        (alert (strcat "Ошибка загрузки файла "
                       file
                       ":\n"
                       (vl-catch-all-error-message err)
                       ) ;_ end of strcat
               ) ;_ end of alert
        ) ;_ end of if
      ) ;_ end of progn
    ) ;_ end of if
  (princ)
  ) ;_ end of defun
