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
  (apply
    (function append)
    (cons
      (if (vl-directory-files path mask)
        (mapcar (function (lambda (x) (strcat path "\\" x)))
                (vl-directory-files path mask)
                ) ;_ end of mapcar
        ) ;_ if
      (mapcar
        (function (lambda (x)
                    (fun_browsefiles-in-directory-nested
                      (strcat path "\\" x)
                      mask
                      ) ;_ end of kpblc-browsefiles-in-directory-nested
                    ) ;_ end of lambda
                  ) ;_ end of function
        (vl-remove
          ".."
          (vl-remove "." (vl-directory-files path nil -1))
          ) ;_ end of vl-remove
        ) ;_ mapcar
      ) ;_ cons
    ) ;_ end of apply
  ) ;_ end of defun
