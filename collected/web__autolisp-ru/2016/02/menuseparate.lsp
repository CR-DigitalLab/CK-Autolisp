(vl-load-com)

(defun c:menuseparate (/ get-all-reg-hives _kpblc-conv-string-to-list _kpblc-dir-create _kpblc-get-profile-name hive)
                      ;|
*    Проходит по всем профилям всех версий и локализаций AutoCAD.
* Переносит основной файл меню в отдельный каталог
* %appdata%\Autodesk\<AppName>\<rus|enu>\Support\Profiles\<ProfileName>
* и добавляет этот каталог в путь поддержки AutoCAD, в самое начало.
*    Критерием необходимости переноса является то, что в пути к основному файлу меню
* отсутствует имя профиля. Перед этим имя профиля преобразовывается - из него исключаются символы,
* недопустимые в именах файлов Windows
|;

  (defun get-all-reg-hives (parent)
    (cond
      ((and (vl-registry-descendents parent)
            (member "PROFILES" (mapcar (function strcase) (vl-registry-descendents parent)))
            ) ;_ end of and
       (mapcar
         (function (lambda (x)
                     (strcat parent "\\Profiles\\" x)
                     ) ;_ end of lambda
                   ) ;_ end of function
         (vl-registry-descendents (strcat parent "\\Profiles"))
         ) ;_ end of mapcar
       )
      ((vl-registry-descendents parent)
       (apply (function append)
              (mapcar
                (function
                  (lambda (x)
                    (get-all-reg-hives (strcat parent "\\" x))
                    ) ;_ end of lambda
                  ) ;_ end of function
                (vl-registry-descendents parent)
                ) ;_ end of mapcar
              ) ;_ end of apply
       )
      ) ;_ end of cond
    ) ;_ end of defun

  (defun _kpblc-conv-string-to-list (string separator / i)
    (cond
      ((= string "") nil)
      ((vl-string-search separator string)
       ((lambda (/ pos res)
          (while (setq pos (vl-string-search separator string))
            (setq res    (cons (substr string 1 pos) res)
                  string (substr string (+ (strlen separator) 1 pos))
                  ) ;_ end of setq
            ) ;_ end of while
          (reverse (cons string res))
          ) ;_ end of lambda
        )
       )
      ((wcmatch (strcase string) (strcat "*" (strcase separator) "*"))
       ((lambda (/ pos res _str prev)
          (setq pos  1
                prev 1
                _str (substr string pos)
                ) ;_ end of setq
          (while (<= pos (1+ (- (strlen string) (strlen separator))))
            (if (wcmatch (strcase (substr string pos (strlen separator))) (strcase separator))
              (setq res    (cons (substr string 1 (1- pos)) res)
                    string (substr string (+ (strlen separator) pos))
                    pos    0
                    ) ;_ end of setq
              ) ;_ end of if
            (setq pos (1+ pos))
            ) ;_ end of while
          (if (< (strlen string) (strlen separator))
            (setq res (cons string res))
            ) ;_ end of if
          (if (or (not res) (= _str string))
            (setq res (list string))
            (reverse res)
            ) ;_ end of if
          ) ;_ end of lambda
        )
       )
      (t (list string))
      ) ;_ end of cond
    ) ;_ end of defun

  (defun _kpblc-dir-create (path / tmp)
    (cond
      ((vl-file-directory-p path) path)
      ((setq tmp (_kpblc-dir-create (vl-filename-directory path)))
       (vl-mkdir
         (strcat tmp
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

  (defun _kpblc-get-profile-name (profile)
    (vl-list->string
      (vl-remove-if-not
        (function
          (lambda (x)
            (or (<= 48 x 57)
                (<= 65 x 90)
                (<= 97 x 122)
                (= x 32)
                (<= 224 x 255)
                (<= 192 x 223)
                ) ;_ end of or
            ) ;_ end of lambda
          ) ;_ end of function
        (vl-string->list
          (cond (profile)
                (t (getvar "cprofile"))
                ) ;_ end of cond
          ) ;_ end of vl-string->list
        ) ;_ end of vl-remove-if
      ) ;_ end of vl-list->string
    ) ;_ end of defun

  (foreach profile
           (vl-remove-if
             (function
               (lambda (x / path)
                 (or (not x)
                     (/= (strcase (vl-filename-directory (vl-filename-directory (cdr (assoc "folder" x)))))
                         (strcase (vl-filename-directory (cdr (assoc "menu" x))))
                         ) ;_ end of /=
                     (= (strcase (cdr (assoc "menu" x))) (strcase (cdr (assoc "folder" x))))
                     ) ;_ end of or
                 ) ;_ end of lambda
               ) ;_ end of function
             (mapcar
               (function
                 (lambda (x / lang lst)
                   (if (setq lang
                              (vl-registry-read
                                (strcat
                                  "HKEY_LOCAL_MACHINE"
                                  (apply (function strcat)
                                         (mapcar
                                           (function
                                             (lambda (a)
                                               (strcat "\\" a)
                                               ) ;_ end of lambda
                                             ) ;_ end of function
                                           (cdr (reverse (cddr (reverse (setq lst (_kpblc-conv-string-to-list x "\\"))))))
                                           ) ;_ end of mapcar
                                         ) ;_ end of apply
                                  ) ;_ end of strcat
                                "LangAbbrev"
                                ) ;_ end of vl-registry-read
                             ) ;_ end of setq
                     (list (cons "profile" x)
                           (cons "lang" lang)
                           (cons "menu" (vl-registry-read (strcat x "\\General Configuration") "MenuFile"))
                           (cons "paths" (vl-registry-read (strcat x "\\General") "ACAD"))
                           (cons "folder"
                                 (_kpblc-dir-create
                                   (strcat
                                     (vl-string-right-trim "\\" (getenv "AppData"))
                                     "\\Autodesk\\"
                                     (car
                                       (vl-remove
                                         nil
                                         (mapcar
                                           (function
                                             (lambda (a)
                                               (vl-registry-read
                                                 (strcat
                                                   "HKEY_LOCAL_MACHINE"
                                                   (apply
                                                     (function strcat)
                                                     (mapcar
                                                       (function
                                                         (lambda (a)
                                                           (strcat "\\" a)
                                                           ) ;_ end of lambda
                                                         ) ;_ end of function
                                                       (cdr
                                                         (reverse
                                                           (cddr (reverse
                                                                   (setq lst (_kpblc-conv-string-to-list x "\\"))
                                                                   ) ;_ end of reverse
                                                                 ) ;_ end of cddr
                                                           ) ;_ end of reverse
                                                         ) ;_ end of cdr
                                                       ) ;_ end of mapcar
                                                     ) ;_ end of apply
                                                   ) ;_ end of strcat
                                                 a
                                                 ) ;_ end of vl-registry-read
                                               ) ;_ end of lambda
                                             ) ;_ end of function
                                           '("ProductNameGlob"
                                             "ProductName"
                                             )
                                           ) ;_ end of mapcar
                                         ) ;_ end of vl-remove
                                       ) ;_ end of car
                                     "\\"
                                     (car
                                       (vl-remove-if-not (function (lambda (x) (wcmatch x "R##*"))) lst)
                                       ) ;_ end of car
                                     "\\"
                                     lang
                                     "\\Support\\Profiles\\"
                                     (_kpblc-get-profile-name (last lst))
                                     ;; И здесь имя профиля в файловой системе!
                                     ) ;_ end of strcat
                                   ) ;_ end of _kpblc-dir-create
                                 ) ;_ end of cons
                           ) ;_ end of list
                     ) ;_ end of if
                   ) ;_ end of lambda
                 ) ;_ end of function
               (get-all-reg-hives "HKEY_CURRENT_USER\\Software\\Autodesk\\AutoCAD")
               ) ;_ end of mapcar
             ) ;_ end of vl-remove
    (foreach file (vl-directory-files
                    (vl-filename-directory (cdr (assoc "menu" profile)))
                    (strcat (vl-filename-base (cdr (assoc "menu" profile))) ".*")
                    1
                    ) ;_ end of vl-directory-files
      (if (not (findfile (strcat (cdr (assoc "folder" profile)) "\\" file)))
        (vl-file-copy
          (strcat (vl-filename-directory (cdr (assoc "menu" profile))) "\\" file)
          (strcat (cdr (assoc "folder" profile)) "\\" file)
          ) ;_ end of vl-file-copy
        ) ;_ end of if
      ) ;_ end of foreach
    (vl-registry-write
      (strcat (cdr (assoc "profile" profile)) "\\General Configuration")
      "MenuFile"
      (strcat (vl-string-right-trim "\\" (cdr (assoc "folder" profile)))
              "\\"
              (vl-filename-base (cdr (assoc "menu" profile)))
              (cond
                ((vl-filename-extension (cdr (assoc "menu" profile))))
                (t "")
                ) ;_ end of cond
              ) ;_ end of strcat
      ) ;_ end of vl-registry-write
    (if
      (not
        (member (cdr (assoc "folder" profile))
                (vl-remove
                  ""
                  (_kpblc-conv-string-to-list
                    (strcase (vl-registry-read (setq hive (strcat (cdr (assoc "profile" profile)) "\\General")) "ACAD"))
                    ";"
                    ) ;_ end of _kpblc-conv-string-to-list
                  ) ;_ end of vl-remove
                ) ;_ end of member
        ) ;_ end of not
       (vl-registry-write
         hive
         "ACAD"
         (strcat (cdr (assoc "folder" profile)) ";" (vl-registry-read hive "ACAD"))
         ) ;_ end of vl-registry-write
       ) ;_ end of if
    ) ;_ end of foreach
  (alert "\nRestart AutoCAD!")
  (princ)
  ) ;_ end of defun
