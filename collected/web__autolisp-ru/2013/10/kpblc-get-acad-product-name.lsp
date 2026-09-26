(defun _kpblc-get-acad-product-name (/ res)
                                    ;|
*    Возвращает короткое имя приложения AutoCAD
|;
  (strcat (cond
            ((vl-registry-read (strcat "HKEY_LOCAL_MACHINE\\" (vlax-product-key)) "ProductNameShort"))
            ((setq res (vl-registry-read (strcat "HKEY_LOCAL_MACHINE\\" (vlax-product-key)) "ProductName"))
             (apply (function strcat)
                    (vl-remove-if-not
                      (function (lambda (x) (wcmatch (strcase x) "*CAD,####")))
                      (_kpblc-conv-string-to-list res " ")
                      ) ;_ end of vl-remove-if-not
                    ) ;_ end of apply
             )
            ) ;_ end of cond
          "x"
          (if (wcmatch (getvar "platform") "*x64*")
            "64"
            "32"
            ) ;_ end of if
          (cond
            ((= (vl-registry-read (strcat "HKEY_LOCAL_MACHINE\\" (vlax-product-key)) "LocaleId") "409") "En")
            ((= (vl-registry-read (strcat "HKEY_LOCAL_MACHINE\\" (vlax-product-key)) "LocaleId") "419") "Ru")
            (t "UnKnown")
            ) ;_ end of cond
          ) ;_ end of strcat
  ) ;_ end of defun
