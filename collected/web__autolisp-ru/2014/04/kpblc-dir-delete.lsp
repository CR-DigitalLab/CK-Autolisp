(defun _kpblc-dir-delete (path / svr)
                         ;|
*    Удаляет каталог
*    Параметры вызова
  path  удаляемый каталог, строка
|;
  (if (vl-find-file-or-dir path)
    (progn
      (setq svr (vlax-get-or-create-object "Scripting.FileSystemobject"))
      (vlax-invoke-method
        svr
        'deletefolder
        (vl-string-right-trim "\\" path)
        :vlax-true
        ) ;_ end of vlax-invoke-method
      (if svr
        (vlax-release-object svr)
        ) ;_ end of if
      ) ;_ end of progn
    ) ;_ end of if
  ) ;_ end of defun
