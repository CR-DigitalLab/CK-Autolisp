(defun _kpblc-ws-get-drive-type (drive / svr res)
                                ;|
*    Получение типа привода.
*    Параметры вызова:
  drive  - имя привода, для которого надо получить тип
*    Возвращает:
  -1    ошибка (привод не существует или к нему нет доступа)
  1      съемный диск (дисковод или Flash-накопитель)
  2      локальный (жесткий) диск
  3      подключенный сетевой диск или указан адрес типа "\\\\server\\drive$"
  4      CD / DVD-ROM
|;
  (setq svr (vlax-get-or-create-object "Scripting.FileSystemObject"))
  (if (vl-catch-all-error-p
        (vl-catch-all-apply
          (function
            (lambda ()
              (setq res (vlax-get-property (vlax-invoke-method svr 'getdrive drive) 'drivetype))
              ) ;_ end of lambda
            ) ;_ end of function
          ) ;_ end of vl-catch-all-apply
        ) ;_ end of vl-catch-all-error-p
    (setq res -1)
    ) ;_ end of if
  (vlax-release-object svr)
  (setq svr nil)
  res
  ) ;_ end of defun
