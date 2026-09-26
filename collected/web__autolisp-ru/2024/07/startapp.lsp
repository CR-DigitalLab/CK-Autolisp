((lambda () 
   (vl-load-com)

   (if *kpblc-vlr-docman* 
     (progn 
       (vlr-remove *kpblc-vlr-docman*)
       (setq *kpblc-vlr-docman* nil)
     )
   )

   (if (not *kpblc-vlr-docman*) 
     (setq *kpblc-vlr-docman* (vlr-docmanager-reactor 
                                "kpblc-docman-reactor"
                                '((:vlr-documentcreated . _kpblc-document-created))
                              )
     )
   )

   (defun _kpblc-document-created (reactor cmd / fun_get-startup-filename fun_get-startup-applications fun_load-modules config_name ini_file full_app_list) 
     ;|
     Получает имя файла с перечислением загружаемых модулей
     @Returns Имя файла с перечислением загружаемых модулей
     |;
     (defun fun_get-startup-filename (/ folder) 
       (strcat 
         (vl-string-right-trim "\\" 
                               (strcat 
                                 (vl-registry-read 
                                   (strcat 
                                     "HKEY_CURRENT_USER\\"
                                     (vl-string-trim "\\" (vlax-product-key))
                                   )
                                   "UserDataDir"
                                 )
                                 "\\Config"
                               )
         )
         "\\Startup.ini"
       )
     )

     ;|
     Получает список загружаемых модулей. Пример вызова: (fun_get-startup-applications (fun_get-startup-filename))
     @Param filename Имя файла с описанием/перечислением модулей
     @Returns Группированный список с приложениями по профилям (в т.ч. и общими)
     |;
     (defun fun_get-startup-applications (filename / handle str file_content group_name res) 
       (if (findfile filename) 
         (progn 
           (setq handle (open filename "r"))
           (while (setq str (read-line handle)) 
             (setq str (vl-string-trim " " str))
             (cond 
               ((wcmatch str "`[*`]")
                (setq group_name (vl-string-trim "[]" str)
                      res        (cons (list group_name) res)
                )
               )
               ((and (not (wcmatch str ";*")) 
                     group_name
                )
                (setq res (subst 
                            (cons group_name 
                                  (append (cdr (assoc group_name res)) 
                                          (list str)
                                  )
                            )
                            (assoc group_name res)
                            res
                          )
                )
               )
             )
           )
           (close handle)
           res
         )
       )
     )

     ;|
     Загружает в текущий документ приложения указанной группы
     @Param app-list Список всех приложений. Фактически - результат выполнения fun_get-startup-applications
     @Param group-name Имя группы, для которой надо выполнять загрузку приложения
     |;
     (defun fun_load-modules (app-list group-name / sysvar err) 
       (setq sysvar (vl-remove nil 
                               (mapcar 
                                 (function 
                                   (lambda (x / temp) 
                                     (if (setq temp (getvar (car x))) 
                                       (progn 
                                         (setvar (car x) (cdr x))
                                         (cons (car x) temp)
                                       )
                                     )
                                   )
                                 )
                                 '(("cmdecho" . 0)
                                   ("menuecho" . 0)
                                   ("nomutt" . 1)
                                  )
                               )
                    )
       )
       (foreach app 
         (cdr 
           (assoc (strcase group-name) 
                  (mapcar 
                    (function 
                      (lambda (x) 
                        (cons (strcase (car x)) (cdr x))
                      )
                    )
                    app-list
                  )
           )
         )
         (if (findfile app) 
           (vl-catch-all-apply 
             (function 
               (lambda () 
                 (cond 
                   ((= (strcase (vl-filename-extension app)) ".LSP")
                    (load app)
                   )
                   ((= (strcase (vl-filename-extension app)) ".NRX")
                    (arxload app)
                   )
                   ((= (strcase (vl-filename-extension app)) ".DLL")
                    (vl-cmdf "_.netload" app)
                   )
                 )
               )
             )
           )
           (princ (strcat "\nНе найдено приложение" app))
         )
       )
       (foreach item sysvar 
         (setvar (car item) (cdr item))
       )
     )

     (setq config_name   (strcase 
                           (if (member (getvar "cconfiguration") (list nil "")) 
                             (getvar "cprofile")
                             (getvar "cconfiguration")
                           )
                         )
           ini_file      (fun_get-startup-filename)
           full_app_list (fun_get-startup-applications ini_file)
     )
     (foreach group (list "common" config_name) 
       (fun_load-modules full_app_list group)
     )
   )
   ; (_kpblc-document-created nil nil)

   (command "(_kpblc-document-created nil nil) ")

   (princ)
 ) 
)