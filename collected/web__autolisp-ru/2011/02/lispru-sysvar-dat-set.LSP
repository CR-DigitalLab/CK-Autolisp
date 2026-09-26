(defun _lispru-sysvar-dat-set (default / handle str)
                          ;|
*    Установка системных переменных *lispru-sysvar-list* в их значения "по
* умолчанию". Установленные значения записываются в файл *lispru-sysvar-datfile*
*    Параметры вызова
	default		устанавливать значения "по умолчанию" (t) или читать из файла
						*lispru-sysvar-datfile* и устанавливать записанные
|;
  (if default
    (progn
      (setq handle (open *lispru-sysvar-datfile* "w"))
      (foreach item *lispru-sysvar-list*
        (vl-catch-all-apply
          (function
            (lambda ()
              (setvar (car item) (cdr item))
              ) ;_ end of lambda
            ) ;_ end of function
          ) ;_ end of vl-catch-all-apply
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
      ) ;_ end of progn
    (if (not (findfile *lispru-sysvar-datfile*))
      (_lispru-sysvar-set t)
      (progn
        (setq handle (open *lispru-sysvar-datfile* "r"))
        (while (setq str (read-line handle))
          (vl-catch-all-apply
            (function
              (lambda ()
                (setq str (read str))
                (setvar (car str) (cdr str))
                ) ;_ end of lambda
              ) ;_ end of function
            ) ;_ end of vl-catch-all-apply
          ) ;_ end of while
        (close handle)
        ) ;_ end of progn
      ) ;_ end of if
    ) ;_ end of if
  ) ;_ end of defun
