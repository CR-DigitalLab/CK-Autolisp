(defun _lispru-file-get-date-and-time (file / lst)
                                      ;|
*    Получение времени создания файла.
|;
  (if (and file (findfile file) (setq lst (vl-file-systime file)))
    (apply (function strcat)
           (mapcar (function (lambda (x / tmp)
                               (if (< (strlen (setq tmp (itoa (nth x lst)))) 2)
                                 (strcat "0" tmp)
                                 tmp
                                 ) ;_ end of if
                               ) ;_ end of lambda
                             ) ;_ end of function
                   '(0 1 3 4 5 6)
                   ) ;_ end of mapcar
           ) ;_ end of apply
    ) ;_ end of if
  ) ;_ end of defun
