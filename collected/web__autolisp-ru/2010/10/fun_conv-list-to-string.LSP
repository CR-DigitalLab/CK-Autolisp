(defun fun_conv-list-to-string (lst sep)
                               ;|
*    Преобразование списка в строку
*    Параметры вызова:
	lst	обрабатываемй список
	sep	разделитель. nil -> " "
|;
  (setq   ;lst (mapcar (function fun_conv-value-to-string) lst)
    sep (if sep
          sep
          " "
          ) ;_ end of if
    ) ;_ end of setq
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
  ) ;_ end of defun
