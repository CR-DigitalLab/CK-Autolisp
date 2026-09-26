(defun _lispru-acad-version ()
                            ;|
*    Возвращает номер сборки AutoCAD'a. Для 2005 вернет 16.1, для 2006 - 16.2
* и т.д.
|;
  (atof (getvar "acadver"))
  ) ;_ end of defun
