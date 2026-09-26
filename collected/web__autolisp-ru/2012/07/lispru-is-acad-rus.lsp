(defun _lispru-is-acad-rus ()
                          ;|
*    Проверяет, является ли AutoCAD русским. Для версий AutoCAD до 2012 включительно возвращает t
* независимо от локализации. В версии 2013 обрабатывает язык AutoCAD'a
|;
  (or (<= (_lispru-acad-version) 18.2)
      (= (vla-get-localeid (vlax-get-acad-object)) 1049)
      ) ;_ end of or
  ) ;_ end of defun