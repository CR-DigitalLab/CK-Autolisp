(defun _lispru-ini-value-read (file group key)
                              ;|
*    Выполняет чтение указанного ключа секции ini-файла
*    Параметры вызова:
	file	имя файла
	group	имя секция
	key		имя ключа
|;
  (cdr (assoc (strcase key t)
              (cdr (assoc (strcase group t)
                          (_lispru-ini-datas-read file)
                          ) ;_ end of assoc
                   ) ;_ end of cdr
              ) ;_ end of assoc
       ) ;_ end of cdr
  ) ;_ end of defun
