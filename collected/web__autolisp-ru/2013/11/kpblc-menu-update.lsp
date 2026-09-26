(vl-load-com)

(defun _kpblc-menu-update (/ loc_dir main_menu)
                           ;|
*    Обновление файла меню
|;
  (setq loc_dir   (_kpblc-dir-create
                    (strcat (_kpblc-get-path-appdata-current-user)
                            "\\LispRu\\"
                            (_kpblc-get-acad-product-name)
                            "\\"
                            (_kpblc-get-profile-name)
                            "\\menu"
                            ) ;_ end of strcat
                    ) ;_ end of _kpblc-dir-create
        main_menu (vla-get-menufile (vla-get-files (vla-get-preferences (vlax-get-acad-object))))
        ) ;_ end of setq
  (if (/= (_kpblc-dir-path-and-splash (strcase (vl-filename-directory main_menu)))
          (_kpblc-dir-path-and-splash (strcase loc_dir))
          ) ;_ end of /=
    (progn
      ;; Каталоги не совпадают. Надо копировать и устанавливать новый основной файл меню
      ;; не забывая про все остальное

      ;; Удаляем старые варианты,- вдруг они там есть
      (foreach file (vl-directory-files loc_dir (strcat (vl-filename-base main_menu) ".*") 1)
        (vl-file-delete (strcat (_kpblc-dir-path-and-splash loc_dir) file))
        ) ;_ end of foreach

      ;; Теперь копируем из текущего положения основного файла меню все необходимое
      (foreach file (vl-remove-if-not
                      (function (lambda (x)
                                  (wcmatch (strcase (vl-string-trim "." (vl-filename-extension x)))
                                           "CUI,CUIX,MNL,MNS,MNU,DLL,MNL"
                                           ) ;_ end of wcmatch
                                  ) ;_ end of lambda
                                ) ;_ end of function
                      (vl-directory-files
                        (vl-filename-directory main_menu)
                        (strcat (vl-filename-base main_menu) ".*")
                        1
                        ) ;_ end of vl-directory-files
                      ) ;_ end of vl-remove-if-not
        (vl-file-copy
          (strcat (_kpblc-dir-path-and-splash (vl-filename-directory main_menu))
                  file
                  ) ;_ end of strcat
          (strcat (_kpblc-dir-path-and-splash loc_dir) file)
          ) ;_ end of vl-file-copy
        ) ;_ end of foreach

      ;; Теперь получаем список уже загруженных файлов частичных меню.
      ;; Потом мы их снова загрузим
      ;; Получим общий список и из него исключим файл основного меню,
      ;; и файлы меню в loc_dir
      (setq partial_menus
             (vl-remove-if
               (function
                 (lambda (x)
                   (or (= (strcase (cdr (assoc "name" x)))
                          (strcase (vl-filename-base main_menu))
                          ) ;_ end of =
                       (wcmatch (strcase (vl-filename-directory (cdr (assoc "name" x))))
                                (strcat (strcase loc_dir "*"))
                                ) ;_ end of wcmatch
                       ) ;_ end of or
                   ) ;_ end of lambda
                 ) ;_ end of function
               (mapcar
                 (function
                   (lambda (x)
                     (list
                       (cons "name" (vla-get-name x))
                       (cons "file" (vla-get-menufilename x))
                       ) ;_ end of list
                     ) ;_ end of lambda
                   ) ;_ end of function
                 (_kpblc-conv-vla-to-list
                   (vla-get-menugroups (vlax-get-acad-object))
                   ) ;_ end of _kpblc-conv-vla-to-list
                 ) ;_ end of mapcar
               ) ;_ end of vl-remove-if
            ) ;_ end of setq

      ;; Сохраняем текущее рабочее пространство
      (if (setq wscurrent (getvar "wscurrent"))
        (command "_.wssave" wscurrent "_y")
        ) ;_ end of if

      ;; Меняем основной файл меню
      (vla-load (vla-get-menugroups (vla-get-activedocument (vlax-get-acad-object)))
                (findfile (strcat (_kpblc-dir-path-and-splash loc_dir)
                                  (car (vl-remove-if
                                         (function (lambda (x) (wcmatch (strcase x) "*.bak.cui*")))
                                         (vl-directory-files loc_dir (strcat (vl-filename-base main_menu) ".cui*"))
                                         ) ;_ end of vl-remove-if
                                       ) ;_ end of car
                                  ) ;_ end of strcat
                          ) ;_ end of findfile
                :vlax-true
                ) ;_ end of vla-load

      (foreach item partial_menus
        (vl-catch-all-apply
          (function
            (lambda ()
              (vla-load (vla-get-menugroups (vla-get-activedocument (vlax-get-acad-object)))
                        (cdr (assoc "file" item))
                        :vlax-false
                        ) ;_ end of vla-load
              ) ;_ end of lambda
            ) ;_ end of function
          ) ;_ end of vl-catch-all-apply
        ) ;_ end of foreach
      ;; Для ExpressTools немного "своя" доработка
      (if (findfile "acettest.fas")
        (progn
          (load "acettest.fas")
          (vla-sendcommand (vla-get-activedocument (vlax-get-acad-object)) "_expresstools ")
          ) ;_ end of progn
        ) ;_ end of if

      ;; Восстанавливаем рабочее пространство
      (if wscurrent
        (progn
          (setvar "wscurrent" wscurrent)
          (command "_.wssave" wscurrent "_y")
          ) ;_ end of progn
        ) ;_ end of if
      ) ;_ end of progn
    ) ;_ end of if
  ) ;_ end of defun
