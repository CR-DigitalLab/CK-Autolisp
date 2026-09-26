(vl-load-com)

(defun inoe-erase-acad-virus (/ path files adoc _msg fun_msg-start fun_msg-end)

  (defun fun_msg-start (msg)
    (princ (strcat "\n" (vl-string-left-trim "\r\n " msg) " : start"))
    ) ;_ end of defun

  (defun fun_msg-end (msg)
    (princ (strcat "\r" (vl-string-left-trim "\r\n " msg) " : finished"))
    ) ;_ end of defun

  (if
    (not
      (wcmatch
        (strcase (setq path (vl-string-right-trim "\\" (getvar "dwgprefix"))))
        (strcase
          (strcat (vl-string-right-trim "\\"
                                        (vl-registry-read (strcat "HKEY_LOCAL_MACHINE\\" (vlax-product-key)) "Location")
                                        ) ;_ end of vl-string-right-trim
                  "\\Support*"
                  ) ;_ end of strcat
          ) ;_ end of strcase
        ) ;_ end of wcmatch
      ) ;_ end of not
     (progn
       (foreach _file (vl-directory-files path "acad*.*")
         (if (not (vl-file-delete _file))
           (setq files (cons _file files))
           ) ;_ end of if
         ) ;_ end of foreach
       (if files
         (alert (apply (function strcat)
                       (append
                         '("Не удалось удалить файлы:")
                         (mapcar
                           (function
                             (lambda (x)
                               (strcat "\n" path "\\" x)
                               ) ;_ end of LAMBDA
                             ) ;_ end of function
                           files
                           ) ;_ end of mapcar
                         '("\nЗакройте AutoCAD, не сохраняя изменения"
                           "\nи удалите их вручную"
                           )
                         ) ;_ end of append
                       ) ;_ end of apply
                ) ;_ end of alert
         ) ;_ end of if
       ) ;_ end of progn
     ) ;_ end of if

  (fun_msg-start (setq _msg "Audit"))
  (vla-auditinfo (setq adoc (vla-get-activedocument (vlax-get-acad-object))) :vlax-true)
  (fun_msg-end _msg)
  (fun_msg-start (setq _msg "PurgeAll"))
  (repeat 3 (vla-purgeall adoc))
  (fun_msg-end _msg)
  (fun_msg-start (setq _msg "PurgeRegisteredApplications"))
  (vlax-for item (vla-get-registeredapplications adoc)
    (vl-catch-all-apply
      (function
        (lambda ()
          (vla-delete item)
          ) ;_ end of lambda
        ) ;_ end of function
      ) ;_ end of vl-catch-all-apply
    ) ;_ end of vlax-for
  (fun_msg-end _msg)
  (princ)
  ) ;_ end of defun

(inoe-erase-acad-virus)