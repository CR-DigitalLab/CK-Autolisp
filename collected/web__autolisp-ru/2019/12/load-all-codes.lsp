(defun get-reg-hive (/ reg_key)
  (setq reg_key "RegisterHive")
  (if (not (cdr (assoc reg_key (vl-bb-ref '*kpblc-settings*))))
    (progn
      (vl-bb-set '*kpblc-settings*
                 (cons (cons reg_key
                             (strcat "HKEY_CURRENT_USER\\Software\\kpblc\\"
                                     (vl-registry-read (strcat "HKEY_LOCAL_MACHINE\\" (vlax-product-key)) "ProductNameGlob")
                                     "x"
                                     (if (and (getvar "platform") (wcmatch (strcase (getvar "platform")) "*X64*"))
                                       "64"
                                       "32"
                                       ) ;_ end of if
                                     ":"
                                     (vl-registry-read (strcat "HKEY_LOCAL_MACHINE\\" (vlax-product-key)) "LocaleID")
                                     "\\"
                                     (getvar "cprofile")
                                     ) ;_ end of strcat
                             ) ;_ end of cons
                       (vl-bb-ref '*kpblc-settings*)
                       ) ;_ end of cons
                 ) ;_ end of vl-bb-set
      ) ;_ end of progn
    ) ;_ end of if
  (cdr (assoc reg_key (vl-bb-ref '*kpblc-settings*)))
  ) ;_ end of defun
(defun get-all-datas (reg-key ask / dcl_id dcl_lst dcl_res handle)
                     ;|
*    Возвращает каталоги исходников
*    Параметры вызова:
  reg-key   ; имя узла реестра, откуда считывать данные. nil недопустим
  ask       ; независимо от того, есть или нет данные, выводится диалог
*    Примеры вызова:
(get-all-datas "HKEY_CURRENT_USER\\Software\\kpblc\\AutoCAD 2018x64:409\\<<Unnamed profile>>" nil)
(get-all-datas "HKEY_CURRENT_USER\\Software\\kpblc\\AutoCAD 2018x64:409\\<<Unnamed profile>>" t)
|;
  (defun fun_browsefolder (caption / shlobj folder fldobj outval)
                          ;|
http://www.autocad.ru/cgi-bin/f1/board.cgi?t=21054YY    
*    Без отображения файлов
*    Параметры вызова:
	caption		показываемый заголовок (пояснение) окна
(setq Folder (vlax-invoke-method ShlObj 'BrowseForFolder 0 "" 16384))
|;  (setq shlobj (vla-getinterfaceobject (vlax-get-acad-object) "Shell.Application")
          folder (vlax-invoke-method
                   shlobj
                   'browseforfolder
                   (vla-get-hwnd (vlax-get-acad-object))
                   caption
                   (+ 512 16)
                   ) ;_ end of vlax-invoke-method
          ) ;_ end of setq
    (vlax-release-object shlobj)
    (if folder
      (progn (setq fldobj (vlax-get-property folder 'self)
                   outval (vlax-get-property fldobj 'path)
                   ) ;_ end of setq
             (vlax-release-object folder)
             (vlax-release-object fldobj)
             ) ;_ end of progn
      ) ;_ end of if
    outval
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
  (defun fun_paths_callback (key value ref-list / temp)
    (cond ((= key "btn_arx")
           (if (and (setq temp (fun_browsefolder "Родительский каталог arx")) (/= temp ""))
             (progn (set_tile "txt_arx" temp)
                    (set ref-list (_kpblc-list-add-or-subst (eval ref-list) "arx" temp))
                    ) ;_ end of progn
             ) ;_ end of if
           )
          ((= key "txt_arx") (set ref-list (_kpblc-list-add-or-subst (eval ref-list) "arx" value)))
          ((= key "btn_vba")
           (if (and (setq temp (fun_browsefolder "Родительский каталог vba")) (/= temp ""))
             (progn (set_tile "txt_vba" temp)
                    (set ref-list (_kpblc-list-add-or-subst (eval ref-list) "vba" temp))
                    ) ;_ end of progn
             ) ;_ end of if
           )
          ((= key "txt_arx") (set ref-list (_kpblc-list-add-or-subst (eval ref-list) "arx" value)))
          ((= key "btn_net")
           (if (and (setq temp (fun_browsefolder "Родительский каталог .net")) (/= temp ""))
             (progn (set_tile "txt_net" temp)
                    (set ref-list (_kpblc-list-add-or-subst (eval ref-list) "net" temp))
                    ) ;_ end of progn
             ) ;_ end of if
           )
          ((= key "txt_net") (set ref-list (_kpblc-list-add-or-subst (eval ref-list) "net" value)))
          ((= key "btn_lsp")
           (if (and (setq temp (fun_browsefolder "Родительский каталог arlspx")) (/= temp ""))
             (progn (set_tile "txt_lsp" temp)
                    (set ref-list (_kpblc-list-add-or-subst (eval ref-list) "lsp" temp))
                    ) ;_ end of progn
             ) ;_ end of if
           )
          ((= key "txt_lsp") (set ref-list (_kpblc-list-add-or-subst (eval ref-list) "lsp" value)))
          ) ;_ end of cond
    ) ;_ end of defun
  (setq dcl_lst (mapcar (function (lambda (key) (cons key (vl-registry-read reg-key key))))
                        (vl-registry-descendents reg-key "")
                        ) ;_ end of mapcar
        ) ;_ end of setq
  (if (or (not dcl_lst) ask)
    (progn (setq dcl_file (strcat (vl-string-right-trim "\\" (getenv "TEMP")) "\\dlg.dcl")
                 handle   (open dcl_file "w")
                 ) ;_ end of setq
           (foreach item '("dlg:dialog{label=\"Каталоги исходников\";"
                           "	:row{label=\"ARX с версиями и разрядностями\";children_fixed_width=true;"
                           "		:edit_box{key=\"txt_arx\";width=60;}"             "		:button{key=\"btn_arx\";width=3;label=\"...\";}"
                           "		}"
                           "	:row{label=\"NET с версиями [и разрядностями]\";children_fixed_width=true;"
                           "		:edit_box{key=\"txt_net\";width=60;}"             "		:button{key=\"btn_net\";width=3;label=\"...\";}"
                           "		}"                                                "	:row{label=\"VBA\";children_fixed_width=true;"
                           "		:edit_box{key=\"txt_vba\";width=60;}"             "		:button{key=\"btn_vba\";width=3;label=\"...\";}"
                           "		}"                                                "	:row{label=\"LSP, VLX, FAS\";children_fixed_width=true;"
                           "		:edit_box{key=\"txt_lsp\";width=60;}"             "		:button{key=\"btn_lsp\";width=3;label=\"...\";}"
                           "		}"                                                "	ok_cancel;"
                           " }"
                           )
             (write-line item handle)
             ) ;_ end of foreach
           (close handle)
           (setq dcl_id (load_dialog dcl_file))
           (new_dialog "dlg" dcl_id "(fun_paths_callback $key $value 'dcl_lst)")
           (action_tile "accept" "(done_dialog 1)")
           (action_tile "cancel" "(done_dialog 0)")
           (foreach item dcl_lst
             (set_tile (strcat "txt_" (car item))
                       (cond ((cdr item))
                             (t "")
                             ) ;_ end of cond
                       ) ;_ end of set_tile
             (fun_paths_callback (strcat "txt_" (car item)) (cdr item) 'dcl_lst)
             ) ;_ end of foreach
           (setq dcl_res (start_dialog))
           (unload_dialog dcl_id)
           (if (= dcl_res 1)
             (progn (foreach item dcl_lst
                      (if (= (vl-string-trim " " (cdr item)) "")
                        (vl-registry-delete reg-key (car item))
                        (vl-registry-write reg-key (car item) (cdr item))
                        ) ;_ end of if
                      ) ;_ end of foreach
                    ) ;_ end of progn
             ) ;_ end of if
           ) ;_ end of progn
    ) ;_ end of if
  (mapcar (function (lambda (x) (cons x (vl-registry-read reg-key x))))
          (vl-registry-descendents reg-key "")
          ) ;_ end of mapcar
  ) ;_ end of defun

(defun load-all-codes (key-path-list / _kpblc-browsefiles-in-directory-nested bit ver_nobit ver_bit path sysvar err err_lst)
                      ;|
*    Собственно загрузка исходников (ну и не только их)
*    Параметры вызова:
  key-path-list  ; список как результат вызова get-all-datas
*    Примеры вызова:
(load-all-codes (get-all-datas "HKEY_CURRENT_USER\\Software\\kpblc\\AutoCAD 2018x64:409\\<<Unnamed profile>>" t))
|;
  (defun _kpblc-browsefiles-in-directory-nested (path mask)
                                                ;|
*    Функция возвращает список файлов указанной маски, находящихся в
* заданном каталоге
*    Параметры вызова:
  path  ; путь к корневому каталогу. nil недопустим
  mask  ; маска имени файла. nil или список недопустим
*    Примеры вызова:
(_kpblc-browsefiles-in-directory-nested "c:\\documents" "*.dwg")
|;  (apply (function append)
           (cons (if (vl-directory-files path mask 1)
                   (mapcar (function (lambda (x) (strcat (vl-string-right-trim "\\" path) "\\" x)))
                           (vl-directory-files path mask 1)
                           ) ;_ end of mapcar
                   ) ;_ end of if
                 (mapcar (function
                           (lambda (x)
                             (_kpblc-browsefiles-in-directory-nested (strcat (vl-string-right-trim "\\" path) "\\" x) mask)
                             ) ;_ end of lambda
                           ) ;_ end of function
                         (vl-remove ".." (vl-remove "." (vl-directory-files path nil -1)))
                         ) ;_ end of mapcar
                 ) ;_ end of cons
           ) ;_ end of apply
    ) ;_ end of defun
  (setq ver_nobit (itoa (atoi (vl-string-trim "VISUALP " (strcase (ver)))))
        bit       (strcat "x"
                          (if (and (getvar "platform") (wcmatch (strcase (getvar "platform")) "*X64*"))
                            "64"
                            "32"
                            ) ;_ end of if
                          ) ;_ end of strcat
        ver_bit   (strcat ver_nobit bit)
        sysvar    (vl-remove nil
                             (mapcar (function (lambda (item / temp)
                                                 (if (setq temp (getvar (car item)))
                                                   (progn (setvar (car item) (cdr item)) (cons (car item) temp))
                                                   ) ;_ end of if
                                                 ) ;_ end of lambda
                                               ) ;_ end of function
                                     '(("secureload" . 0) ("cmdecho" . 0) ("menuecho" . 0) ("nomutt" . 1))
                                     ) ;_ end of mapcar
                             ) ;_ end of vl-remove
        ) ;_ end of setq
  (foreach item (mapcar (function (lambda (x) (cons (strcase (car x) t) (vl-string-right-trim "\\ " (cdr x)))))
                        key-path-list
                        ) ;_ end of mapcar
    (cond ((= (car item) "arx")
           ;; Версия + разрядность
           (if (setq path (car (vl-sort (vl-remove-if
                                          (function (lambda (x) (or (member x '("." "..")) (> (atoi x) (atoi ver_nobit)))))
                                          (vl-directory-files (cdr item) (strcat "*" bit ".*") -1)
                                          ) ;_ end of vl-remove-if
                                        (function (lambda (a b) (> (atoi a) (atoi b))))
                                        ) ;_ end of vl-sort
                               ) ;_ end of car
                     ) ;_ end of setq
             (progn (setq path (strcat (cdr item) "\\" path))
                    (foreach file (mapcar (function (lambda (x) (strcat path "\\" x))) (vl-directory-files path "*.*" 1))
                      (if (vl-catch-all-error-p (setq err (vl-catch-all-error-p (function (lambda () (arxload file))))))
                        (setq err_lst (cons (cons file (vl-catch-all-error-message err)) err_lst))
                        ) ;_ end of if
                      ) ;_ end of foreach
                    ) ;_ end of progn
             ) ;_ end of if
           )
          ((= (car item) "net")
           (if (setq path (car (vl-sort (vl-remove-if
                                          (function (lambda (x) (or (member x '("." "..")) (> (atoi x) (atoi ver_nobit)))))
                                          (vl-directory-files (cdr item) (strcat "*" bit ".*") -1)
                                          ) ;_ end of vl-remove-if
                                        (function (lambda (a b) (> (atoi a) (atoi b))))
                                        ) ;_ end of vl-sort
                               ) ;_ end of car
                     ) ;_ end of setq
             (progn (setq path (strcat (cdr item) "\\" path))
                    (foreach file (mapcar (function (lambda (x) (strcat path "\\" x))) (vl-directory-files path "*.*" 1))
                      (if (vl-catch-all-error-p
                            (setq err (vl-catch-all-apply (function (lambda () (vl-cmdf "_.netload" file)))))
                            ) ;_ end of vl-catch-all-error-p
                        (setq err_lst (cons (cons file (vl-catch-all-error-message err)) err_lst))
                        ) ;_ end of if
                      ) ;_ end of foreach
                    ) ;_ end of progn
             ) ;_ end of if
           (if (setq path (car (vl-sort (vl-remove-if
                                          (function (lambda (x) (or (not (wcmatch x "####")) (> (atoi x) (atoi ver_nobit)))))
                                          (vl-directory-files (cdr item) "*" -1)
                                          ) ;_ end of vl-remove-if
                                        (function (lambda (a b) (> (atoi a) (atoi b))))
                                        ) ;_ end of vl-sort
                               ) ;_ end of car
                     ) ;_ end of setq
             (progn (setq path (strcat (cdr item) "\\" path))
                    (foreach file (mapcar (function (lambda (x) (strcat path "\\" x))) (vl-directory-files path "*.*" 1))
                      (if (vl-catch-all-error-p
                            (setq err (vl-catch-all-apply (function (lambda () (vl-cmdf "_.netload" file)))))
                            ) ;_ end of vl-catch-all-error-p
                        (setq err_lst (cons (cons file (vl-catch-all-error-message err)) err_lst))
                        ) ;_ end of if
                      ) ;_ end of foreach
                    ) ;_ end of progn
             ) ;_ end of if
           )
          ((= (car item) "vba")
           (foreach file (mapcar (function (lambda (x) (strcat (cdr item) "\\" x))) (vl-directory-files (cdr item) "*.dvb"))
             (if (vl-catch-all-error-p (setq err (vl-catch-all-apply (function (lambda () (vl-vbaload file))))))
               (setq err_lst (cons (cons file (vl-catch-all-error-message err)) err_lst))
               ) ;_ end of if
             ) ;_ end of foreach
           )
          ((= (car item) "lsp")
           (foreach file (vl-remove-if-not
                           (function (lambda (x) (member (strcase (vl-filename-extension x)) '(".LSP" ".FAS" ".VLX"))))
                           (_kpblc-browsefiles-in-directory-nested (cdr item) "*.*")
                           ) ;_ end of vl-remove-if-not
             (if (vl-catch-all-error-p (setq err (vl-catch-all-apply (function (lambda () (load file))))))
               (setq err_lst (cons (cons file (vl-catch-all-error-message err)) err_lst))
               ) ;_ end of if
             ) ;_ end of foreach
           )
          ) ;_ end of cond
    ) ;_ end of foreach
  (foreach item sysvar (setvar (car item) (cdr item)))
  (if err_lst
    (princ (strcat "\nОшибки загрузки : "
                   (apply (function strcat)
                          (mapcar (function (lambda (x) (strcat "\n" (car x) " : " (cdr x)))) err_lst)
                          ) ;_ end of apply
                   ) ;_ end of strcat
           ) ;_ end of princ
    ) ;_ end of if
  ) ;_ end of defun
(defun c:path-settings (/ reg)
  (if (setq reg (get-reg-hive))
    (get-all-datas reg t)
    (alert "Невозможно получить название раздела реестра")
    ) ;_ end of if
  ) ;_ end of defun
(defun c:load-all-codes (/ reg)
  (if (setq reg (get-reg-hive))
    (load-all-codes (get-all-datas reg nil))
    (alert "Невозможно получить название раздела реестра")
    ) ;_ end of if
  ) ;_ end of defun
(princ (strcat "\nНаберите path-settings для настройки каталогов"
               "\nНаберите load-all-codes для загрузки кодов"
               ) ;_ end of strcat
       ) ;_ end of princ
(princ)