(defun fun_conv-string-to-list (string separator / i)
                               ;|
*    Функция разбора строки. Возвращает список либо точечную пару.
*    Параметры вызова:
* string    разбираемая строка
* separator символ, используемый в качестве разделителя частей
*    Примеры вызова:
(fun_conv-string-to-list "1;2;3;4;5;6" ";") ;'(1 2 3 4 5 6)
(fun_conv-string-to-list "1;2" ";")   ;'(1 2)
*    За основу взяты уроки Евгения Елпанова по рекурсиям
|;
  (cond
    ((= string "") nil)
    ((setq i (vl-string-search separator string))
     (cons (substr string 1 i)
           (fun_conv-string-to-list
             (substr string (+ (strlen separator) 1 i))
             separator
             ) ;_ end of fun_conv-string-to-list
           ) ;_ end of cons
     )
    (t (list string))
    ) ;_ end of cond
  ) ;_ end of defun
