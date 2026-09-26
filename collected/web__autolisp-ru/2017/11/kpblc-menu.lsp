(defun _kpblc-menu-update (/                               _kpblc-conv-value-to-string     _kpblc-conv-value-to-bool       _kpblc-conv-list-to-string      _kpblc-conv-string-to-list
                           _kpblc-string-replace           _kpblc-find-file-or-dir         _kpblc-browse-files-in-directory                                _kpblc-conv-ent-to-ename
                           _kpblc-conv-ent-to-vla          _kpblc-dir-create               _kpblc-conv-vla-to-list         _kpblc-get-profile-name         _kpblc-dir-path-and-splash
                           _kpblc-dir-path-no-splash       _kpblc-error-print              _kpblc-acad-version-with-bit    _kpblc-acad-version-with-bit-and-loc
                           _kpblc-list-add-or-subst        _kpblc-get-acad-application-name                                _kpblc-get-registry-hive        _kpblc-error-catch
                           _kpblc-error-sysvar-restore-by-list                             _kpblc-error-sysvar-save-by-list                                _kpblc-get-path-root-appdata
                           _kpblc-file-delete              _kpblc-file-copy                _kpblc-get-path-local-menu      *kpblc-acad*                    log_msg
                           menus                           main_menu_file                  gu_add_menus                    key                             net_menu
                           loc_menu                        err                             sysvar
                           )
  (defun _kpblc-conv-value-to-string (value /)
    (cond ((= (type value) 'str) value)
          ((= (type value) 'int) (itoa value))
          ((and (= (type value) 'real)
                (equal value (_kpblc-eval-value-round value 1.) 1e-6)
                (equal value (fix value) 1e-6)
                ) ;_ end of and
           (itoa (fix value))
           )
          ((and (= (type value) 'real)
                (equal value (_kpblc-eval-value-round value 1.) 1e-6)
                (not (equal value (fix value) 1e-6))
                ) ;_ end of and
           (rtos value 2)
           )
          ((= (type value) 'real) (rtos value 2 14))
          ((not value) "")
          (t (vl-princ-to-string value))
          ) ;_ end of cond
    ) ;_ end of defun
  (defun _kpblc-conv-value-to-bool (value)
    (cond ((= (type value) 'str) (not (member (strcase value t) '("" "0" "n" "н" "false" "f"))))
          ((= (type value) 'vl-catch-all-apply-error) nil)
          (t (not (member value '(0 nil :vlax-false))))
          ) ;_ end of cond
    ) ;_ end of defun
  (defun _kpblc-conv-list-to-string (lst sep)
    (if (and lst
             (setq sep (if sep
                         sep
                         " "
                         ) ;_ end of if
                   ) ;_ end of setq
             ) ;_ end of and
      (strcat (car lst)
              (apply (function strcat) (mapcar (function (lambda (x) (strcat sep x))) (cdr lst)))
              ) ;_ end of strcat
      ""
      ) ;_ end of if
    ) ;_ end of defun
  (defun _kpblc-conv-string-to-list (string separator / i)
    (cond ((= string "") nil)
          ((= separator "") (list string))
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
  (defun _kpblc-string-replace (str old new)
    (_kpblc-conv-list-to-string (_kpblc-conv-string-to-list str old) new)
    ) ;_ end of defun
  (defun _kpblc-find-file-or-dir (path / fso res)
    (setq path (vl-string-translate "/" "\\" path))
    (cond ((or (findfile path)
               (findfile (vl-string-right-trim "\\" path))
               (findfile (strcat (vl-string-right-trim "\\" path) "\\"))
               ) ;_ end of or
           (setq res (vl-string-right-trim "\\" path))
           )
          ((vl-file-directory-p path)
           (if (vl-catch-all-error-p
                 (setq res (vl-catch-all-apply
                             (function (lambda (/ fso)
                                         (setq fso (vlax-get-or-create-object "Scripting.FileSystemObject"))
                                         (vlax-invoke-method fso 'getfolder path)
                                         ) ;_ end of lambda
                                       ) ;_ end of function
                             ) ;_ end of vl-catch-all-apply
                       ) ;_ end of setq
                 ) ;_ end of vl-catch-all-error-p
             (setq res nil)
             (setq res (vl-string-right-trim "\\" path))
             ) ;_ end of if
           (vl-catch-all-apply (function (lambda () (vlax-release-object fso))))
           )
          ) ;_ end of cond
    res
    ) ;_ end of defun
  (defun _kpblc-browse-files-in-directory (lst / res)
    (cond ((not (cdr (assoc "path" lst)))
           (setq res (apply (function append)
                            (mapcar (function (lambda (x) (_kpblc-browse-files-in-directory (cons (cons "path" x) lst))))
                                    (cons (vla-get-path *kpblc-adoc*) (vl-remove "" (_kpblc-conv-string-to-list (getenv "ACAD") ";")))
                                    ) ;_ end of mapcar
                            ) ;_ end of apply
                 ) ;_ end of setq
           )
          ((not (cdr (assoc "mask" lst)))
           (setq res (_kpblc-browse-files-in-directory (cons (cons "mask" "*.*") lst)))
           )
          ((_kpblc-find-file-or-dir (cdr (assoc "path" lst)))
           (setq lst (_kpblc-list-add-or-subst
                       lst
                       "mask"
                       (strcase (_kpblc-string-replace (cdr (assoc "mask" lst)) ";" ","))
                       ) ;_ end of _kpblc-list-add-or-subst
                 res (vl-remove-if
                       (function
                         (lambda (x)
                           (or (vl-file-directory-p x)
                               (not
                                 (wcmatch (strcase (strcat (_kpblc-conv-value-to-string (vl-filename-base x))
                                                           "."
                                                           (vl-string-left-trim "." (_kpblc-conv-value-to-string (vl-filename-extension x)))
                                                           ) ;_ end of strcat
                                                   ) ;_ end of strcase
                                          (cdr (assoc "mask" lst))
                                          ) ;_ end of wcmatch
                                 ) ;_ end of not
                               ) ;_ end of or
                           ) ;_ end of lambda
                         ) ;_ end of function
                       (if (_kpblc-conv-value-to-bool (cdr (assoc "nested" lst)))
                         (_kpblc-browsefiles-in-directory-nested (cdr (assoc "path" lst)) "*.*")
                         (mapcar (function (lambda (x) (strcat (_kpblc-dir-path-and-splash (cdr (assoc "path" lst))) x)))
                                 (vl-directory-files
                                   (cdr (assoc "path" lst))
                                   (if (and (cdr (assoc "mask" lst)) (not (wcmatch (cdr (assoc "mask" lst)) "*;*,*`,*")))
                                     (cdr (assoc "mask" lst))
                                     "*.*"
                                     ) ;_ end of if
                                   1
                                   ) ;_ end of vl-directory-files
                                 ) ;_ end of mapcar
                         ) ;_ end of if
                       ) ;_ end of vl-remove-if
                 ) ;_ end of setq
           )
          ) ;_ end of cond
    res
    ) ;_ end of defun
  (defun _kpblc-conv-ent-to-ename (ent_value / _lst)
    (cond ((= (type ent_value) 'vla-object) (vlax-vla-object->ename ent_value))
          ((= (type ent_value) 'ename) ent_value)
          ((and (= (type ent_value) 'str) (handent ent_value) (entget (handent ent_value)))
           (handent ent_value)
           )
          ((and (= (type ent_value) 'str) (handent ent_value) (tblobjname "style" ent_value))
           (tblobjname "style" ent_value)
           )
          ((and (= (type ent_value) 'str) (handent ent_value) (tblobjname "dimstyle" ent_value))
           (tblobjname "dimstyle" ent_value)
           )
          ((and (= (type ent_value) 'str) (handent ent_value) (tblobjname "block" ent_value))
           (tblobjname "block" ent_value)
           )
          ((and (= (type ent_value) 'list) (cdr (assoc -1 ent_value))) (cdr (assoc -1 ent_value)))
          (t nil)
          ) ;_ end of cond
    ) ;_ end of defun
  (defun _kpblc-conv-ent-to-vla (ent_value / res)
    (cond ((= (type ent_value) 'vla-object) ent_value)
          ((= (type ent_value) 'ename) (vlax-ename->vla-object ent_value))
          ((setq res (_kpblc-conv-ent-to-ename ent_value)) (vlax-ename->vla-object res))
          ) ;_ end of cond
    ) ;_ end of defun
  (defun _kpblc-dir-create (path / tmp)
    (cond ((vl-file-directory-p path) path)
          ((setq tmp (_kpblc-dir-create (vl-filename-directory path)))
           (vl-mkdir (strcat tmp
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
  (defun _kpblc-conv-vla-to-list (value / res)
    (cond ((listp value) (mapcar (function _kpblc-conv-vla-to-list) value))
          ((= (type value) 'variant) (_kpblc-conv-vla-to-list (vlax-variant-value value)))
          ((= (type value) 'safearray)
           (if (>= (vlax-safearray-get-u-bound value 1) 0)
             (_kpblc-conv-vla-to-list (vlax-safearray->list value))
             ) ;_ end of if
           )
          ((and (member (type value) (list 'ename 'str 'vla-object))
                (= (type (_kpblc-conv-ent-to-vla value)) 'vla-object)
                (vlax-property-available-p (_kpblc-conv-ent-to-vla value) 'count)
                ) ;_ end of and
           (vlax-for sub (_kpblc-conv-ent-to-vla value) (setq res (cons sub res)))
           )
          (t value)
          ) ;_ end of cond
    ) ;_ end of defun
  (defun _kpblc-get-profile-name ()
    (vl-list->string
      (vl-remove-if-not
        (function
          (lambda (x) (or (<= 48 x 57) (<= 65 x 90) (<= 97 x 122) (= x 32) (<= 224 x 255) (<= 192 x 223)))
          ) ;_ end of function
        (vl-string->list (getvar "cprofile"))
        ) ;_ end of vl-remove-if
      ) ;_ end of vl-list->string
    ) ;_ end of defun
  (defun _kpblc-dir-path-and-splash (path) (strcat (vl-string-right-trim "\\" path) "\\"))
  (defun _kpblc-dir-path-no-splash (path) (vl-string-right-trim "\\" path))
  (defun _kpblc-error-print (func-name msg / res)
    (princ (setq res (strcat "\n ** "
                             (vl-string-trim "][ :\n<>" (vl-string-subst "" "error" (strcase func-name t)))
                             " ERROR #"
                             (if msg
                               (strcat (itoa (getvar "errno")) ": " msg)
                               ": undefined"
                               ) ;_ end of if
                             ) ;_ end of strcat
                 ) ;_ end of setq
           ) ;_ end of princ
    (princ)
    ) ;_ end of defun
  (defun _kpblc-acad-version-with-bit ()
    (strcat (itoa (atoi (vl-string-trim "VISUALP " (strcase (ver)))))
            "x"
            (if (and (getvar "platform") (wcmatch (strcase (getvar "platform")) "*X64*"))
              "64"
              "32"
              ) ;_ end of if
            ) ;_ end of strcat
    ) ;_ end of defun
  (defun _kpblc-acad-version-with-bit-and-loc ()
    (strcat (_kpblc-acad-version-with-bit)
            "-"
            (vl-registry-read (strcat "HKEY_LOCAL_MACHINE\\" (vlax-product-key)) "LocaleID")
            ) ;_ end of strcat
    ) ;_ end of defun
  (defun _kpblc-list-add-or-subst (lst key value)
    (if (not value)
      (vl-remove-if (function (lambda (x) (= (car x) key))) lst)
      (if (cdr (assoc key lst))
        (subst (cons key value) (assoc key lst) lst)
        (cons (cons key value) (vl-remove-if (function (lambda (x) (= (car x) key))) lst))
        ) ;_ end of if
      ) ;_ end of if
    ) ;_ end of defun
  (defun _kpblc-get-acad-application-name (/ tmp lst f)
    (setq tmp (vl-registry-read (strcat "HKEY_LOCAL_MACHINE\\" (vlax-product-key)) "ProductNameGlob"))
    (foreach item (vl-string->list tmp)
      (cond ((and (not f) (not (<= 48 item 57))) (setq lst (cons item lst)))
            ((<= 48 item 57) (setq f t))
            ) ;_ end of cond
      ) ;_ end of foreach
    (vl-string-trim " " (vl-list->string (reverse lst)))
    ) ;_ end of defun
  (defun _kpblc-get-registry-hive (/ key tmp lst f)
    (cond ((cdr (assoc (setq key "reghive") (vl-bb-ref '*kpblc-settings*))))
          (t
           (vl-bb-set '*kpblc-settings*
                      (_kpblc-list-add-or-subst
                        (vl-bb-ref '*kpblc-settings*)
                        key
                        (setq tmp (strcat "HKEY_CURRENT_USER\\Software\\kpblc\\"
                                          (_kpblc-get-acad-application-name)
                                          "\\"
                                          (_kpblc-acad-version-with-bit-and-loc)
                                          "\\"
                                          (_kpblc-get-profile-name)
                                          ) ;_ end of strcat
                              ) ;_ end of setq
                        ) ;_ end of _kpblc-list-add-or-subst
                      ) ;_ end of vl-bb-set
           tmp
           )
          ) ;_ end of cond
    ) ;_ end of defun
  (defun _kpblc-error-catch (protected-function on-error-function / catch_error_result)
    (setq catch_error_result (vl-catch-all-apply protected-function))
    (if (and (vl-catch-all-error-p catch_error_result) on-error-function)
      (apply on-error-function (list (vl-catch-all-error-message catch_error_result)))
      catch_error_result
      ) ;_ end of if
    ) ;_ end of defun
  (defun _kpblc-error-sysvar-restore-by-list (lst)
    (foreach item lst
      (if (getvar (car item))
        (setvar (car item) (cadr item))
        ) ;_ end of if
      ) ;_ end of foreach
    ) ;_ end of defun
  (defun _kpblc-error-sysvar-save-by-list (lst / res)
    (vl-remove nil
               (mapcar (function (lambda (x / tmp)
                                   (if (setq tmp (getvar (car x)))
                                     (progn (if (cdr x)
                                              (setvar (car x) (cdr x))
                                              ) ;_ end of if
                                            (cons (car x) tmp)
                                            ) ;_ end of progn
                                     ) ;_ end of if
                                   ) ;_ end of lambda
                                 ) ;_ end of function
                       lst
                       ) ;_ end of mapcar
               ) ;_ end of vl-remove
    ) ;_ end of defun
  (defun _kpblc-get-path-root-appdata ()
    (_kpblc-dir-create
      (strcat (_kpblc-dir-path-no-splash
                (vl-string-right-trim
                  "\\"
                  (vl-registry-read
                    "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders"
                    "AppData"
                    ) ;_ end of vl-registry-read
                  ) ;_ end of vl-string-right-trim
                ) ;_ end of _kpblc-dir-path-no-splash
              "\\kpblc"
              ) ;_ end of strcat
      ) ;_ end of vl-string-right-trim
    ) ;_ end of defun
  (defun _kpblc-file-delete (file / fso)
    (if (findfile file)
      (if (not (vl-file-delete file))
        (progn (_kpblc-error-catch
                 (function (lambda ()
                             (setq fso (vlax-create-object "Scripting.FileSystemObject"))
                             (vlax-invoke-method fso 'deletefile file :vlax-true)
                             ) ;_ end of lambda
                           ) ;_ end of function
                 nil
                 ) ;_ end of _kpblc-error-catch
               (if (and fso (not (vlax-object-released-p fso)))
                 (vlax-release-object fso)
                 ) ;_ end of if
               ) ;_ end of progn
        ) ;_ end of if
      ) ;_ end of if
    (not (findfile file))
    ) ;_ end of defun
  (defun _kpblc-file-copy (source dest lst /)
    (if (and source (findfile source))
      (progn
        (cond ((cdr (assoc "req" lst))
               (_kpblc-file-delete dest)
               (if (not (findfile dest))
                 (vl-file-copy
                   source
                   (strcat (_kpblc-dir-path-and-splash (_kpblc-dir-create (vl-filename-directory dest)))
                           (vl-filename-base dest)
                           (vl-filename-extension dest)
                           ) ;_ end of strcat
                   ) ;_ end of vl-file-copy
                 ) ;_ end of if
               )
              ((and (cdr (assoc "update" lst))
                    (or (not (findfile dest))
                        (and (findfile dest)
                             (or (and gunipc-get-md5 (/= (gunipc-get-md5 dest) (gunipc-get-md5 source)))
                                 (< (_kpblc-get-file-date dest) (_kpblc-get-file-date source))
                                 ) ;_ end of or
                             ) ;_ end of and
                        ) ;_ end of or
                    ) ;_ end of and
               (_kpblc-file-copy source dest (_kpblc-list-add-or-subst lst "req" t))
               )
              ) ;_ end of cond
        ) ;_ end of progn
      ) ;_ end of if
    (findfile dest)
    ) ;_ end of defun
  (defun _kpblc-get-path-local-menu (/ key res _tmp _path)
    (setq key  "Menu"
          _tmp (strcat "LocalPath" key)
          res  (strcat (_kpblc-dir-path-and-splash
                         (cond ((vl-registry-read (_kpblc-get-registry-hive) _tmp))
                               (t
                                (vl-registry-write
                                  (_kpblc-get-registry-hive)
                                  _tmp
                                  (strcat (_kpblc-dir-path-and-splash (_kpblc-get-path-root-appdata))
                                          (_kpblc-get-acad-application-name)
                                          "\\"
                                          key
                                          "\\"
                                          (_kpblc-acad-version-with-bit-and-loc)
                                          "\\"
                                          (_kpblc-get-profile-name)
                                          ) ;_ end of strcat
                                  ) ;_ end of vl-registry-write
                                )
                               ) ;_ end of cond
                         ) ;_ end of _kpblc-dir-path-and-splash
                       ) ;_ end of strcat
          ) ;_ end of setq
    (_kpblc-dir-create res)
    ) ;_ end of defun
  (if (/= (strcase
            (vl-string-right-trim
              "\\"
              (vl-filename-directory
                (vla-get-menufile (vla-get-files (vla-get-preferences (setq *kpblc-acad* (vlax-get-acad-object)))))
                ) ;_ end of vl-filename-directory
              ) ;_ end of vl-string-right-trim
            ) ;_ end of strcase
          (strcase (vl-string-right-trim "\\" (_kpblc-get-path-local-menu)))
          ) ;_ end of /=
    (progn (setq menus  (mapcar (function
                                  (lambda (x / tmp path filename loc)
                                    (if (setq tmp (= (strcase
                                                       (setq filename (vl-filename-base (vla-get-menufile (vla-get-files (vla-get-preferences *kpblc-acad*)))))
                                                       ) ;_ end of strcase
                                                     (strcase (vl-filename-base (vla-get-menufilename x)))
                                                     ) ;_ end of =
                                              ) ;_ end of setq
                                      ;; Копирование основного файла меню в отдельный каталог
                                      (progn (setq path (_kpblc-dir-path-and-splash
                                                          (vl-filename-directory (vla-get-menufile (vla-get-files (vla-get-preferences *kpblc-acad*))))
                                                          ) ;_ end of _kpblc-dir-path-and-splash
                                                   loc  (_kpblc-dir-path-and-splash (_kpblc-get-path-local-menu))
                                                   ) ;_ end of setq
                                             (foreach file (mapcar (function (lambda (x) (strcat path x)))
                                                                   (vl-remove-if
                                                                     (function (lambda (x)
                                                                                 (or (wcmatch (strcase x) "*.BAK.*,*.BAK")
                                                                                     (not (wcmatch (strcase (vl-filename-extension x)) ".CUI,.CUIX,.DLL,.MN[USL]"))
                                                                                     ) ;_ end of or
                                                                                 ) ;_ end of lambda
                                                                               ) ;_ end of function
                                                                     (vl-directory-files
                                                                       (vl-filename-directory (vla-get-menufile (vla-get-files (vla-get-preferences *kpblc-acad*))))
                                                                       (strcat (vl-filename-base (vla-get-menufile (vla-get-files (vla-get-preferences *kpblc-acad*))))
                                                                               ".*"
                                                                               ) ;_ end of strcat
                                                                       1
                                                                       ) ;_ end of VL-DIRECTORY-FILES
                                                                     ) ;_ end of vl-remove-if
                                                                   ) ;_ end of mapcar
                                               (_kpblc-file-copy
                                                 file
                                                 (strcat loc (vl-filename-base file) (vl-filename-extension file))
                                                 '(("req" . t))
                                                 ) ;_ end of _kpblc-file-copy
                                               ) ;_ end of foreach
                                             ) ;_ end of progn
                                      ) ;_ end of if
                                    (_kpblc-list-add-or-subst
                                      (mapcar (function (lambda (prop) (cons prop (vlax-get-property x prop)))) '("name" "menufilename"))
                                      "main"
                                      tmp
                                      ) ;_ end of _kpblc-list-add-or-subst
                                    ) ;_ end of lambda
                                  ) ;_ end of function
                                (_kpblc-conv-vla-to-list (vla-get-menugroups *kpblc-acad*))
                                ) ;_ end of mapcar
                 sysvar (_kpblc-error-sysvar-save-by-list '(("wsautosave" . 1) ("wscurrent")))
                 ) ;_ end of setq
           (if (setq main_menu_file
                      ((lambda (/ tmp)
                         (car
                           (_kpblc-browse-files-in-directory
                             (list (cons "path" (_kpblc-get-path-local-menu))
                                   (cons "mask"
                                         (strcat (vl-filename-base
                                                   (setq tmp (cdr
                                                               (assoc "menufilename" (car (vl-remove-if-not (function (lambda (x) (cdr (assoc "main" x)))) menus)))
                                                               ) ;_ end of cdr
                                                         ) ;_ end of setq
                                                   ) ;_ end of vl-filename-base
                                                 (vl-filename-extension tmp)
                                                 ) ;_ end of strcat
                                         ) ;_ end of cons
                                   ) ;_ end of list
                             ) ;_ end of _kpblc-browse-files-in-directory
                           ) ;_ end of _kpblc-browse-files-in-directory
                         ) ;_ end of lambda
                       )
                     ) ;_ end of setq
             (progn (vla-load (vla-get-menugroups *kpblc-acad*) main_menu_file :vlax-true)
                    (princ)
                    (alert
                      (_kpblc-conv-list-to-string
                        (append '("Обновление файла меню!" "После окончания загрузки" "перезапустите AutoCAD")
                                (if (not (getvar "wsautosave"))
                                  '("" "Не забудьте предварительно установить" "опцию автосохранения рабочего пространства!")
                                  ) ;_ end of if
                                ) ;_ end of append
                        "\n"
                        ) ;_ end of _kpblc-conv-list-to-string
                      ) ;_ end of alert
                    (_kpblc-error-sysvar-restore-by-list sysvar)
                    (if (or (member "EXPRESS"
                                    (mapcar (function (lambda (x) (strcase (vla-get-name x))))
                                            (_kpblc-conv-vla-to-list (vla-get-menugroups *kpblc-acad*))
                                            ) ;_ end of mapcar
                                    ) ;_ end of member
                            (findfile "acettest.fas")
                            ) ;_ end of or
                      (progn (load "acettest.fas") (c:expresstools))
                      ) ;_ end of if
                    ) ;_ end of progn
             (progn (alert "Не удается определить основной файл меню!")
                    (_kpblc-log
                      (strcat "Не удалось определить основной файл меню. ACAD"
                              (_kpblc-acad-version-with-bit-and-loc)
                              "; профиль "
                              (getvar "cprofile")
                              ) ;_ end of strcat
                      log_msg
                      ) ;_ end of _kpblc-log
                    ) ;_ end of progn
             ) ;_ end of if
           ) ;_ end of progn
    ) ;_ end of if
  ;; Проверка основного файла меню завершена. Проверяем дополнительные меню
  (princ)
  ) ;_ end of defun
(defun c:kpblc-menu () (_kpblc-menu-update))