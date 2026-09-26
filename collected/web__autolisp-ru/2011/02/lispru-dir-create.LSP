(defun _lispru-dir-create (path)
                          ;|
*    Гарантированное создание каталога.
*    Параметры вызова:
	path	создаваемый каталог
|;
  (setq path (vl-string-right-trim "\\" path))
  (cond
    ((vl-file-directory-p path) path)
    (t
     (vl-mkdir
       (strcat (_lispru-dir-create (vl-filename-directory path))
               "\\"
               (vl-filename-base path)
               (cond ((vl-filename-extension path))
                     (t "")
                     ) ;_ end of cond
               ) ;_ end of strcat
       ) ;_ end of vl-mkdir
     (if (vl-file-directory-p path)
       path
       ) ;_ end of if
     )
    ) ;_ end of cond
  ) ;_ end of defun