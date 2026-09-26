(vl-load-com)

(defun c:pt2file (/                adoc
                  file             handle
                  pt               lst
                  count            blk_name
                  blk_def          blk_ref
                  _kpblc-list-assoc
                  _lispru-acad-version
                  _lispru-ent-make-annotative
                  *error*
                  )

  (defun *error* (msg)
    (vla-endundomark (vla-get-activedocument (vlax-get-acad-object)))
    (princ msg)
    (princ)
    ) ;_ end of defun

  (defun _lispru-acad-version ()
                              ;|
*    Возвращает номер сборки AutoCAD'a. Для 2005 вернет 16.1, для 2006 - 16.2
* и т.д.
|;
    (atof (getvar "acadver"))
    ) ;_ end of defun

  (defun _lispru-ent-make-annotative (ent make / res)
                                     ;|
http://autolisp.ru/2011/03/17/howto-create-annotative-style-or-block/
*    Добавление аннотативности объекту
*    Параметры вызова:
  ent     ename-указатель на объект
  make    делать аннотативным или снимать аннотативность
|;
    (if
      (and (> (_lispru-acad-version) 17.0)
           (not
             (assoc "AcadAnnotative" (cdr (assoc -3 (entget ent '("*")))))
             ) ;_ end of not
           ) ;_ end of and
       (if make
         (progn
           (regapp "AcadAnnotative")
           (setq
             res (entmod
                   (list (cons -1 ent)
                         '(-3
                           ("AcadAnnotative"
                            (1000 . "AnnotativeData")
                            (1002 . "{")
                            (1070 . 1)
                            (1070 . 1)
                            (1002 . "}")
                            )
                           )
                         ) ;_ end of list
                   ) ;_ end of entmod
             ) ;_ end of setq
           ) ;_ end of progn
         (setq res
                (entmod
                  (append
                    (entget ent)
                    (list
                      (cons
                        -3
                        (append '(("AcadAnnotative"))
                                (vl-remove-if
                                  (function
                                    (lambda (x)
                                      (= (car x "AcadAnnotative"))
                                      ) ;_ end of lambda
                                    ) ;_ end of function
                                  (cdr (assoc -2 (entget ent '("*"))))
                                  ) ;_ end of vl-remove-if
                                ) ;_ end of append
                        ) ;_ end of cons
                      ) ;_ end of list
                    ) ;_ end of append
                  ) ;_ end of entmod
               ) ;_ end of setq
         ) ;_ end of if
       ) ;_ end of if
    ) ;_ end of defun

  (defun _kpblc-list-assoc (key lst)
                           ;|
*    Замена стандартному assoc
*    Параметры вызова:
	key	ключ
	lst	обрабатываеымй список
|;
    (if (= (type key) 'str)
      (setq key (strcase key))
      ) ;_ end of if
    (car (vl-remove-if-not
           (function
             (lambda (a / b)
               (and (setq b (car a))
                    (or (and (= (type b) 'str) (= (strcase b) key)) (equal b key))
                    ) ;_ end of and
               ) ;_ end of lambda
             ) ;_ end of function
           lst
           ) ;_ end of vl-remove-if-not
         ) ;_ end of car
    ) ;_ end of defun

  (if (not *kpblc-app-settings*)
    (c:pt2file_options)
    ) ;_ end of if
  (if (/= (type (setq count (vl-catch-all-apply
                              (function
                                (lambda ()
                                  (initget 6)
                                  (getint "\nВведите начальный номер точки <1> : ")
                                  ) ;_ end of lambda
                                ) ;_ end of function
                              ) ;_ end of vl-catch-all-apply
                      ) ;_ end of setq
                ) ;_ end of type
          'int
          ) ;_ end of /=
    (setq count 1)
    ) ;_ end of if
  (vla-startundomark (setq adoc (vla-get-activedocument (vlax-get-acad-object))))
  (if
    (/= (type
          (setq
            blk_def (vl-catch-all-apply
                      (function
                        (lambda ()
                          (vla-item (vla-get-blocks adoc) (setq blk_name (strcat "inoe.kpblc.point" *kpblc-app-ver*)))
                          ) ;_ end of lambda
                        ) ;_ end of function
                      ) ;_ end of vl-catch-all-apply
            ) ;_ end of setq
          ) ;_ end of type
        'vla-object
        ) ;_ end of /=
     ((lambda (/ circle att)
        (setq blk_def (vla-add (vla-get-blocks adoc) (vlax-3d-point '(0. 0. 0.)) blk_name)
              circle  (if (= 1 (cdr (_kpblc-list-assoc "UseCircle" *kpblc-app-settings*)))
                        (vla-addcircle blk_def (vlax-3d-point '(0. 0. 0.)) 1.)
                        (vla-addpoint blk_def (vlax-3d-point '(0. 0. 0.)))
                        ) ;_ end of if
              att     (vla-addattribute
                        blk_def
                        (atof (cdr (_kpblc-list-assoc "TextHeight" *kpblc-app-settings*)))
                        acattributemodepreset
                        "Номер точки"
                        (vlax-3d-point
                          (list (atof (cdr (_kpblc-list-assoc "TextX" *kpblc-app-settings*)))
                                (atof (cdr (_kpblc-list-assoc "TextY" *kpblc-app-settings*)))
                                0.
                                ) ;_ end of list
          ;'(1. 1. 0.))
                          ) ;_ end of vlax-3d-point
                        "PointNumber"
                        "-"
                        ) ;_ end of vla-AddAttribute
              ) ;_ end of setq
        (vlax-for ent blk_def
          (vla-put-color ent 0)
          (vla-put-lineweight ent aclnwtbyblock)
          (vla-put-linetype ent "Continuous")
          (vla-put-layer ent "0")
          ) ;_ end of vlax-for
        (vla-put-color circle 1)
        (_lispru-ent-make-annotative
          (vlax-vla-object->ename blk_def)
          (= 1 (cdr (_kpblc-list-assoc "Scale" *kpblc-app-settings*)))
          ) ;_ end of _lispru-ent-make-annotative
        ) ;_ end of lambda
      )
     ) ;_ end of if

  (while (= (type (setq pt (vl-catch-all-apply
                             (function
                               (lambda ()
                                 (trans (getpoint "\nУкажите точку <Хватит> : ") 1 0)
                                 ) ;_ end of lambda
                               ) ;_ end of function
                             ) ;_ end of vl-catch-all-apply
                        ) ;_ end of setq
                  ) ;_ end of type
            'list
            ) ;_ end of =
    (setq blk_ref (vla-insertblock (vla-get-modelspace adoc) (vlax-3d-point pt) blk_name 1. 1. 1. 0.))
    (vla-put-textstring
      (car (vlax-safearray->list (vlax-variant-value (vla-getattributes blk_ref))))
      (itoa count)
      ) ;_ end of vla-put-textstring
    (if (= 0 (cdr (_kpblc-list-assoc "Scale" *kpblc-app-settings*)))
      (vla-scaleentity blk_ref (vla-get-insertionpoint blk_ref) (getvar "dimscale"))
      ) ;_ end of if
    (setq lst   (cons (cons count pt) lst)
          count (1+ count)
          ) ;_ end of setq
    ) ;_ end of while
  (if (and (setq file (getfiled "Укажите файл для сохранения результатов"
                                (vl-filename-base (getvar "dwgname"))
                                "txt;csv"
                                1
                                ) ;_ end of getfiled
                 ) ;_ end of setq
           (/= file "")
           ) ;_ end of and
    (progn
      (vl-catch-all-apply
        (function
          (lambda ()
            (setq handle (open file "w"))
            (write-line "№;x;y" handle)
            (foreach item (reverse lst)
              (write-line
                (strcat (rtos (car item) 2 0) ";" (rtos (cadr item) 2 3) ";" (rtos (caddr item) 2 3))
                handle
                ) ;_ end of write-line
              ) ;_ end of foreach
            ) ;_ end of lambda
          ) ;_ end of function
        ) ;_ end of vl-catch-all-apply
      (vl-catch-all-apply (function (lambda () (close handle))))
      ) ;_ end of progn
    ) ;_ end of if
  (vla-endundomark adoc)
  (princ)
  ) ;_ end of defun

(defun c:pt2file_options (/ hive dcl_file dcl_handle _kpblc-list-add-or-subst callback callback-by-key settings)

  (defun _kpblc-list-add-or-subst (lst key value)
    (cond
      ((and key value (cdr (assoc key lst)))
       (cons (cons key value) (vl-remove-if (function (lambda (x) (= (car x) key))) lst))
          ;(subst (cons key value) (assoc key lst) lst)
       )
      ((and key value (not (cdr (assoc key lst))))
       (cons (cons key value) lst)
       )
      ((and key (not value) (cdr (assoc key lst)))
       (vl-remove-if (function (lambda (x) (= (car x) key))) lst)
       )
      (t lst)
      ) ;_ end of cond
    ) ;_ end of defun


  (defun callback ()
    (callback-by-key $key $value)
    ) ;_ end of defun

  (defun callback-by-key (key value)
    (cond
      ((= key "chk_circle")
       (mode_tile "circle_rad" 0)
       (set_tile "chk_point" "0")
       (setq *kpblc-app-settings* (_kpblc-list-add-or-subst *kpblc-app-settings* "UseCircle" 1))
       )
      ((= key "chk_point")
       (mode_tile "circle_rad" 1)
       (set_tile "chk_circle" "0")
       (setq *kpblc-app-settings* (_kpblc-list-add-or-subst *kpblc-app-settings* "UseCircle" 0))
       )
      ((= key "txt_height")
       (setq *kpblc-app-settings* (_kpblc-list-add-or-subst *kpblc-app-settings* "TextHeight" (atof value)))
       )
      ((= key "txt_x")
       (setq *kpblc-app-settings* (_kpblc-list-add-or-subst *kpblc-app-settings* "TextX" (atof value)))
       )
      ((= key "txt_y")
       (setq *kpblc-app-settings* (_kpblc-list-add-or-subst *kpblc-app-settings* "TextY" (atof value)))
       )
      ((= key "dimscale")
       (setq *kpblc-app-settings* (_kpblc-list-add-or-subst *kpblc-app-settings* "Scale" 0))
       )
      ((= key "anno")
       (setq *kpblc-app-settings* (_kpblc-list-add-or-subst *kpblc-app-settings* "Scale" 1))
       )
      ) ;_ end of cond
    ) ;_ end of defun

  (setq *kpblc-reg-hive*
         "HKEY_CURRENT_USER\\Software\\kpblc\\inoe\\pt2file"
        *kpblc-app-name*
         "Point to file"
        *kpblc-app-ver*
         "0.2"
        *kpblc-app-settings*
         (mapcar (function (lambda (x)
                             (cons x (vl-registry-read *kpblc-reg-hive* x))
                             ) ;_ end of LAMBDA
                           ) ;_ end of function
                 (vl-registry-descendents *kpblc-reg-hive* t)
                 ) ;_ end of mapcar
        dcl_file (strcat (vl-string-right-trim "\\" (getenv "TEMP")) "\\dlg.dcl")
        dcl_handle
         (open dcl_file "w")
        ) ;_ end of setq
  (foreach item (list (strcat "dlg: dialog{label=\"" *kpblc-app-name* " v." *kpblc-app-ver* "\";")
                      "	:column{label=\"Обозначение точки\";"
                      "		:row{"
                      "			:radio_button{key=\"chk_circle\";label=\"Окружность\";}"
                      "			:edit_box{key=\"circle_rad\";label=\"Радиус окружности\";}"
                      "			}"
                      "		:row{"
                      "			:radio_button{key=\"chk_point\";label=\"Точка\";}"
                      "			}"
                      "		}"
                      "	:column{label=\"Текст\";"
                      "		:edit_box{key=\"txt_height\";label=\"Высота текста\";}"
                      "		:edit_box{key=\"txt_x\";label=\"Смещение по оси Х\";}"
                      "		:edit_box{key=\"txt_y\";label=\"Смещение по очи Y\";}"
                      "		}"
                      "	:radio_column{label=\"Масштабирование\";"
                      "		:radio_button{key=\"dimscale\";label=\"Масштаб вставки зависит от dimscale\";}"
                      "		:radio_button{key=\"anno\";label=\"Блок аннотативный\";}"
                      "		}"
                      "	ok_cancel;"
                      "	}"
                      ) ;_ end of list
    (write-line item dcl_handle)
    ) ;_ end of foreach
  (close dcl_handle)
  (foreach item '(("UseCircle" . 1)
                  ("CircleRadius" . "1.")
                  ("TextHeight" . "2.5")
                  ("TextX" . "1.")
                  ("TextY" . "1.")
                  ("Scale" . 0)
                  )
    (if (not (assoc (car item) *kpblc-app-settings*))
      (setq *kpblc-app-settings*
             (_kpblc-list-add-or-subst
               *kpblc-app-settings*
               (car item)
               (vl-registry-write *kpblc-reg-hive* (car item) (cdr item))
               ) ;_ end of _kpblc-list-add-or-subst
            ) ;_ end of setq
      ) ;_ end of if
    ) ;_ end of foreach
  (setq dcl_id (load_dialog dcl_file))
  (new_dialog "dlg" dcl_id "(callback)")
  (action_tile "accept" "(done_dialog 1)")
  (action_tile "cancel" "(done_dialog 0)")
  (foreach item (setq settings (mapcar
                                 (function
                                   (lambda (x)
                                     (cons (strcase (car x)) (cdr x))
                                     ) ;_ end of lambda
                                   ) ;_ end of function
                                 *kpblc-app-settings*
                                 ) ;_ end of mapcar
                      ) ;_ end of setq
    (cond
      ((and (= (car item) "USECIRCLE")
            (= (cdr item) 1)
            ) ;_ end of and
       (set_tile "chk_circle" "1")
       (set_tile "circle_rad" (cdr (assoc "CIRCLERADIUS" settings)))
       (callback-by-key "chk_circle" (get_tile "chk_circle"))
       )
      ((and (= (car item) "USECIRCLE")
            (= (cdr item) 0)
            ) ;_ end of and
       (set_tile "chk_point" "1")
       (callback-by-key "chk_point" (get_tile "chk_point"))
       )
      ((= (car item) "TEXTHEIGHT") (set_tile "txt_height" (vl-princ-to-string (cdr item))))
      ((= (car item) "TEXTX") (set_tile "txt_x" (vl-princ-to-string (cdr item))))
      ((= (car item) "TEXTY") (set_tile "txt_y" (vl-princ-to-string (cdr item))))
      ((and (= (car item) "SCALE") (= (cdr item) 0))
       (set_tile "dimscale" "1")
       (callback-by-key "dimscale" (get_tile "dimscale"))
       )
      ((and (= (car item) "SCALE") (= (cdr item) 1))
       (set_tile "anno" "1")
       (callback-by-key "anno" (get_tile "anno"))
       )
      ) ;_ end of cond
    ) ;_ end of foreach
  (setq dcl_res (start_dialog))
  (unload_dialog dcl_id)
  (if (= dcl_res 1)
    ;; Надо сохранить настройки
    (foreach item *kpblc-app-settings*
      (vl-registry-write *kpblc-reg-hive* (car item) (cdr item))
      ) ;_ end of foreach
    ) ;_ end of if
  (princ)
  ) ;_ end of defun

(princ "\nType pt2file to run command")
(princ "\nType pt2file_options to set all settings")
(princ)