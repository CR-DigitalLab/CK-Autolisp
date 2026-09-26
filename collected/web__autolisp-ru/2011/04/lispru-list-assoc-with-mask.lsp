(defun _lispru-list-assoc-with-mask (key lst)
                                   ;|
*    Замена стандартному assoc
*    Параметры вызова:
	key	ключ (возможно, строка. Допускается применение масок).
	lst	обрабатываеымй список
|;
  (if (= (type key) 'str)
    (setq key (strcase key))
    ) ;_ end of if
  (car
    (vl-remove-if-not
      (function
        (lambda (a / b)
          (and
            (setq b (car a))
            (or (and (= (type b) 'str) (wcmatch (strcase b) key)) (equal b key))
            ) ;_ end of and
          ) ;_ end of lambda
        ) ;_ end of function
      lst
      ) ;_ end of vl-remove-if-not
    ) ;_ end of car
  ) ;_ end of defun
