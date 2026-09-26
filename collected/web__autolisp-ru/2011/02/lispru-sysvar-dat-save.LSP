(defun _lispru-sysvar-dat-save (/ handle)
                           ;|
*    „тение установленных в текущем файле значений системных переменных
* из *lispru-sysvar-list* и запись их в *lispru-sysvar-datfile*
|;
  (setq handle (open *lispru-sysvar-datfile* "w"))
  (foreach item *lispru-sysvar-list*
    (write-line (strcat "(\""
                        (car item)
                        "\" "
                        (if (listp (cdr item))
                          ""
                          ". "
                          ) ;_ end of if
                        (vl-string-trim "()" (vl-princ-to-string (cdr item)))
                        ")"
                        ) ;_ end of strcat
                handle
                ) ;_ end of write-line
    ) ;_ end of foreach
  (close handle)
  ) ;_ end of defun
