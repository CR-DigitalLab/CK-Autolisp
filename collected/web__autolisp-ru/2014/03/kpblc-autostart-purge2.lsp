(vl-load-com)

(defun _kpblc-autostart-purge (bit                         /                           fun_conv-list-to-string
                               _kpblc-error-sysvar-restore-by-list                     _kpblc-error-sysvar-save-by-list
                               _kpblc-cmd-silence          _kpblc-error-catch          _kpblc-conv-list-to-string
                               adoc                        layer_status                ent_lst
                               err
                               )
                              ;|
*    Очистка текущего документа (файла) dwg.
*    Параметры вызова:
  bit   сумма чисел, определяющая объем выполняемых действий:
    1    очищать графический и неграфический мусор (аналог обычного _purge)
    2    очищать зарегистрированные приложения
    4    проверка файла с исправлением ошибок (аналог _.audit _y)
    8    очищать фильтры слоев
   16    удалять историю создания твердых тел, включая вхождения в блоки (аналог команды _.brep)
   32    удаление параметрических зависимостей, включая вхождения в блоки (аналог _.delconstrain)
   64    при загруженном ExplodeAllProxy, demandload = 2, proxyshow = 1: разбиение графических прокси-
         объектов (автоматически добавляются биты 1, 2, 4)
  128    при загруженном ExplodeAllProxy, demandload = 2, proxyshow = 1: удаление неграфических и
         неразбиваемых прокси-объектов (автоматически добавляются биты 1, 2, 4)
  256    очистить следы VBA в файле
|;

  (defun fun_conv-list-to-string (lst sep)
                                 ;|
*    Преобразование списка в строку
*    Параметры вызова:
  lst  обрабатываемй список
  sep  разделитель. nil -> " "
|;
    (if (and lst
             (setq sep (if sep
                         sep
                         " "
                         ) ;_ end of if
                   ) ;_ end of setq
             ) ;_ end of and
      (strcat (car lst)
              (apply (function strcat)
                     (mapcar
                       (function
                         (lambda (x)
                           (strcat sep x)
                           ) ;_ end of lambda
                         ) ;_ end of function
                       (cdr lst)
                       ) ;_ end of mapcar
                     ) ;_ end of apply
              ) ;_ end of strcat
      ""
      ) ;_ end of if
    ) ;_ end of defun

  (defun _kpblc-error-sysvar-restore-by-list (lst)
                                             ;|
*    Восстановление состояния системных переменных.
*    Параметры вызова:
  lst  список системных переменных, значения которых надо
    восстаналивать вида:
      '((<sysvar> . <value>) <...>)
|;
    (foreach item lst
      (if (getvar (car item))
        (setvar (car item) (cdr item))
        ) ;_ end of if
      ) ;_ end of foreach
    ) ;_ end of defun

  (defun _kpblc-error-sysvar-save-by-list (lst)
                                          ;|
*    Сохранение состояния системных переменных для документа. Возможна
* одновременная установка
*    Параметры вызова:
  lst  список системных переменных вида
      '((<sysvar> . <value>) <...>)
*    Возвращает список 
|;
    (mapcar
      (function
        (lambda (x / tmp)
          (if (setq tmp (getvar (car x)))
            (progn
              (if (cdr x)
                (vl-catch-all-apply
                  (function
                    (lambda ()
                      (setvar (car x) (cdr x))
                      ) ;_ end of lambda
                    ) ;_ end of function
                  ) ;_ end of vl-catch-all-apply
                ) ;_ end of if
              (cons (car x) tmp)
              ) ;_ end of progn
            ) ;_ end of if
          ) ;_ end of lambda
        ) ;_ end of function
      lst
      ) ;_ end of mapcar
    ) ;_ end of defun

  (defun _kpblc-cmd-silence (cmd / sysvar res)
                            ;|
*    Выполнение команды в "скрытом" режиме
*    Параметры вызова:
  cmd   исполняемая команда - строка или список
*    Возвращает t в случае успеха выполнения команды или nil в случае ошибки.
*    Примеры использования:
(_kpblc-cmd-silence "_.regenall")
(_kpblc-cmd-silence (list "_.wssave" (getvar "wscurrent") "_y"))
(_kpblc-cmd-silence (list "_.circle" pause pause))
|;
    (if (not (member (type cmd) (list 'str 'list)))
      (princ "\nНевозможно выполнить команду " (vl-princ-to-string cmd) " : неопознанный тип")
      (_kpblc-error-catch
        (function
          (lambda ()
            (setq sysvar (_kpblc-error-sysvar-save-by-list
                           '(("cmdecho" . 0)
                             ("nomutt" . 1)
                             ("menuecho" . 0)
                             )
                           ) ;_ end of _kpblc-error-sysvar-save-by-list
                  ) ;_ end of setq
            (cond
              ((= (type cmd) 'str)
               (setq res (vl-cmdf cmd))
               )
              ((= (type cmd) 'list)
               (setq res (apply (function and)
                                (list (vl-cmdf (car cmd))
                                      (apply (function vl-cmdf)
                                             (cdr cmd)
                                             ) ;_ end of apply
                                      ) ;_ end of list
                                ) ;_ end of apply
                     ) ;_ end of setq
               )
              ) ;_ end of cond
            ) ;_ end of lambda
          ) ;_ end of function
        '(lambda (x)
           (setq res nil)
           (_kpblc-error-sysvar-restore-by-list sysvar)
           (princ (strcat "\n")
                  (cond
                    ((= (type cmd) 'str) (strcat "\nОшибка выполнения команды " cmd))
                    ((= (type cmd) 'list)
                     (strcat "\nОшибка выполнения последовательности команд "
                             (_kpblc-conv-list-to-string cmd " ")
                             ) ;_ end of strcat
                     )
                    (t "\nОшибка выполнения команды: неопознанный тип команды")
                    ) ;_ end of cond
                  ) ;_ end of princ
           ) ;_ end of lambda
        ) ;_ end of _kpblc-error-catch
      ) ;_ end of if
    (_kpblc-error-sysvar-restore-by-list sysvar)
    res
    ) ;_ end of defun

  (defun _kpblc-error-catch (protected-function
                             on-error-function
                             /
                             catch_error_result
                             )
                            ;|
*** Функция взята из книжной версии ruCAD'a без каких бы то ни было переделок,
*** кроме переименования.
*    Оболочка отлова ошибок.
*    Параметры вызова:
*  protected-function  - "защищаемая" функция
*  on-error-function  - функция, выполняемая в случае ошибки
|;
    (setq catch_error_result (vl-catch-all-apply protected-function))
    (if (and (vl-catch-all-error-p catch_error_result)
             on-error-function
             ) ;_ end of and
      (apply on-error-function
             (list (vl-catch-all-error-message catch_error_result))
             ) ;_ end of apply
      catch_error_result
      ) ;_ end of if
    ) ;_ end of defun

  (vla-startundomark (setq adoc (vla-get-activedocument (vlax-get-acad-object))))
  (setq bit (cond
              ((= (type bit) 'int) bit)
              ((= (type bit) 'real) (fix bit))
              ((= (type bit) 'str) (atoi bit))
              ) ;_ end of cond
        ) ;_ end of setq
  (if (apply (function or)
             (mapcar (function (lambda (x)
                                 (/= 0 (logand bit x))
                                 ) ;_ end of lambda
                               ) ;_ end of function
                     '(16 32)
                     ) ;_ end of mapcar
             ) ;_ end of apply
    (vlax-for item (vla-get-layers adoc)
      (setq layer_status
             (cons (list item
                         (mapcar
                           (function
                             (lambda (x / tmp)
                               (setq tmp (vlax-get-property item x))
                               (vl-catch-all-apply
                                 (function
                                   (lambda ()
                                     (vlax-put-property item x :vlax-false)
                                     ) ;_ end of lambda
                                   ) ;_ end of function
                                 ) ;_ end of vl-catch-all-apply
                               (cons x tmp)
                               ) ;_ end of lambda
                             ) ;_ end of function
                           '("lock" "freeze")
                           ) ;_ end of mapcar
                         ) ;_ end of list
                   layer_status
                   ) ;_ end of cons
            ) ;_ end of setq
      ) ;_ end of vlax-for
    ) ;_ end of if
  (if (/= (logand bit 1) 0)
    ;; _purge _a
    (repeat 3 (vla-purgeall adoc))
    ) ;_ end of if
  (if (/= (logand bit 2) 0)
    ;; _-purge _r
    (vlax-for item (vla-get-registeredapplications adoc)
      (vl-catch-all-apply
        (function
          (lambda ()
            (vla-delete item)
            ) ;_ end of lambda
          ) ;_ end of function
        ) ;_ end of vl-catch-all-apply
      ) ;_ end of vlax-for
    ) ;_ end of if
  (if (/= (logand bit 4) 0)
    ;; _audit _y
    ((lambda (/ sysvar)
       (setq sysvar (_kpblc-error-sysvar-save-by-list '(("dimpost" . ""))))
       (vla-auditinfo adoc :vlax-true)
       (_kpblc-error-sysvar-restore-by-list sysvar)
       ) ;_ end of lambda
     )
    ) ;_ end of if
  (if (/= (logand bit 8) 0)
    ;; layer filters
    ((lambda (/ vla:lrs vla:xdic vla:dic vla:xrec name datatype datavalue)
       (setq vla:lrs (vla-get-layers adoc))
       (if (equal (vla-get-hasextensiondictionary vla:lrs) :vlax-true)
         ;; при наличии словаря требуется детальная проверка
         (progn
           (setq lstnames (mapcar 'strcase lstnames))
           (setq vla:xdic (vla-getextensiondictionary vla:lrs))
           ;; поиск и удаление фильтров версий пре-2005
           (if (progn (vlax-for item vla:xdic
                        (if (= (vla-get-name item) "ACAD_LAYERFILTERS")
                          (setq vla:dic item)
                          ) ;_ end of if
                        ) ;_ end of vlax-for
                      vla:dic
                      ) ;_ end of progn
             (progn
               (vlax-for vla:xrec vla:dic
                 (vla-remove vla:dic name)
                 (vlax-release-object vla:xrec)
                 ) ;_ end of vlax-for
               (vlax-release-object vla:dic)
               ) ;_ end of progn
             ) ;_ end of if
           (setq vla:dic nil)
           ;; поиск и удаление фильтров версии 2005
           (if (progn (vlax-for item vla:xdic
                        (if (= (vla-get-name item) "ACLYDICTIONARY")
                          (setq vla:dic item)
                          ) ;_ end of if
                        ) ;_ end of vlax-for
                      vla:dic
                      ) ;_ end of progn
             (progn
               (vlax-for vla:xrec vla:dic
                 (if (progn
                       (setq name (vla-get-name vla:xrec))
                       (vla-getxrecorddata vla:xrec 'datatype 'datavalue)
                       ) ;_ end of progn
                   (progn
                     (vla-remove vla:dic name)
                     (vlax-release-object vla:xrec)
                     ) ;_ end of progn
                   ) ;_ end of if
                 ) ;_ end of vlax-for
               (vlax-release-object vla:dic)
               ) ;_ end of progn
             ) ;_ end of if
           (vlax-release-object vla:xdic)
           ) ;_ end of progn
         ) ;_ end of if
       (vlax-release-object vla:lrs)
       ) ;_ end of lambda
     )
    ) ;_ end of if
  (if (/= (logand bit 16) 0)
    ;; _brep _a
    (progn
      (vlax-for blk_def (vla-get-blocks adoc)
        (if (equal (vla-get-isxref blk_def) :vlax-false)
          (vlax-for subent blk_def
            (if (= (vla-get-objectname subent) "AcDb3dSolid")
              (setq ent_lst (cons (vlax-vla-object->ename subent) ent_lst))
              ) ;_ end of if
            ) ;_ end of vlax-for
          ) ;_ end of if
        ) ;_ end of vlax-for
      (foreach ent ent_lst
        (if (and (cdr (assoc 350 (entget ent)))
                 (not (vl-catch-all-error-p
                        (vl-catch-all-apply
                          (function
                            (lambda () (entget (cdr (assoc 350 (entget ent)))))
                            ) ;_ end of function
                          ) ;_ end of vl-catch-all-apply
                        ) ;_ end of vl-catch-all-error-p
                      ) ;_ end of not
                 (entget (cdr (assoc 350 (entget ent))))
                 ) ;_ end of and
          (entdel (cdr (assoc 350 (entget ent))))
          ) ;_ end of if
        ) ;_ end of foreach
      (setq ent_lst nil)
      ) ;_ end of progn
    ) ;_ end of if
  (if (/= (logand bit 32) 0)
    ;; _delconstraint
    (progn
      (vlax-for blk_def (vla-get-blocks adoc)
        (if (equal (vla-get-isxref blk_def) :vlax-false)
          (vlax-for subent blk_def
            (foreach item (vl-remove-if-not
                            (function
                              (lambda (x)
                                (and (= (type x) 'ename)
                                     (= (cdr (assoc 0 (entget x))) "ACDBASSOCGEOMDEPENDENCY")
                                     ) ;_ end of and
                                ) ;_ end of lambda
                              ) ;_ end of function
                            (member "{ACAD_REACTORS"
                                    (mapcar
                                      (function cdr)
                                      (entget (vlax-vla-object->ename subent))
                                      ) ;_ end of mapcar
                                    ) ;_ end of member
                            ) ;_ end of vl-remove-if-not
              (_kpblc-error-catch
                (function
                  (lambda ()
                    (if (and (entdel item)
                             (entget item)
                             ) ;_ end of and
                      (vla-delete (vlax-ename->vla-object item))
                      ) ;_ end of if
                    ) ;_ end of lambda
                  ) ;_ end of function
                '(lambda (x)
                   (princ (strcat "\n" (vla-get-objectname subent) " : " (vl-catch-all-error-message x)))
                   ) ;_ end of lambda
                ) ;_ end of _kpblc-error-catch
              ) ;_ end of foreach
            ) ;_ end of vlax-for
          ) ;_ end of if
        ) ;_ end of vlax-for
      ) ;_ end of progn
    ) ;_ end of if

  (if (and explodeproxyentity
           (= (getvar "demandload") 2)
           (= (getvar "proxyshow") 1)
           ) ;_ end of and
    (progn
      (if (apply (function or)
                 (mapcar (function (lambda (x)
                                     (/= 0 (logand bit x))
                                     ) ;_ end of lambda
                                   ) ;_ end of function
                         '(64 128)
                         ) ;_ end of mapcar
                 ) ;_ end of apply
        (progn
          (_kpblc-cmd-silence (list "_.wipeout"))
          (foreach item '("ctextapp" "rtext")
            (if (and (findfile (strcat item ".arx"))
                     (not (member item (mapcar (function (lambda (x) (strcase (vl-filename-base x) t))) (arx))))
                     ) ;_ end of and
              (arxload (findfile (strcat item ".arx")))
              ) ;_ end of if
            ) ;_ end of foreach
          (foreach item '(1 2 4)
            (if (= (logand bit item) 0)
              (setq bit (+ bit item))
              ) ;_ end of if
            ) ;_ end of foreach
          ) ;_ end of progn
        ) ;_ end of if
      (if (/= (logand bit 64) 0)
        (_kpblc-cmd-silence (list "_.explodeallproxy"))
        ) ;_ end of if
      (if (/= (logand bit 128) 0)
        (_kpblc-cmd-silence (list "_.removeallproxy"))
        ) ;_ end of if
      ) ;_ end of progn
    ) ;_ end of if
  (if (/= (logand bit 256) 0)
    ((lambda (/ dict)
       (if (not (vl-catch-all-error-p
                  (setq dict
                         (vl-catch-all-apply
                           (function
                             (lambda ()
                               (vla-item
                                 (vla-get-dictionaries
                                   (vla-get-activedocument (vlax-get-acad-object))
                                   ) ;_ end of vla-get-Dictionaries
                                 "ACAD_VBA"
                                 ) ;_ end of vla-item
                               ) ;_ end of lambda
                             ) ;_ end of function
                           ) ;_ end of vl-catch-all-apply
                        ) ;_ end of setq
                  ) ;_ end of vl-catch-all-error-p
                ) ;_ end of not
         (vlax-for item dict
           (vl-catch-all-apply
             (function
               (lambda ()
                 (vla-delete item)
                 ) ;_ end of lambda
               ) ;_ end of function
             ) ;_ end of vl-catch-all-apply
           ) ;_ end of vl-catch-all-error-p
         ) ;_ end of if
       ) ;_ end of lambda
     )
    ) ;_ end of if
  (if (/= (logand bit 1) 0)
    ;; _purge _a
    (repeat 3 (vla-purgeall adoc))
    ) ;_ end of if
  (if (/= (logand bit 2) 0)
    ;; _-purge _r
    (vlax-for item (vla-get-registeredapplications adoc)
      (vl-catch-all-apply
        (function
          (lambda ()
            (vla-delete item)
            ) ;_ end of lambda
          ) ;_ end of function
        ) ;_ end of vl-catch-all-apply
      ) ;_ end of vlax-for
    ) ;_ end of if
  (if (/= (logand bit 4) 0)
    ;; _audit _y
    ((lambda (/ sysvar)
       (setq sysvar (_kpblc-error-sysvar-save-by-list '(("dimpost" . ""))))
       (vla-auditinfo adoc :vlax-true)
       (_kpblc-error-sysvar-restore-by-list sysvar)
       ) ;_ end of lambda
     )
    ) ;_ end of if
  (foreach item layer_status
    (mapcar
      (function
        (lambda (x)
          (vl-catch-all-apply
            (function
              (lambda ()
                (vlax-put-property (car item) (car x) (cdr x))
                ) ;_ end of lambda
              ) ;_ end of function
            ) ;_ end of vl-catch-all-apply
          ) ;_ end of lambda
        ) ;_ end of function
      (cdr item)
      ) ;_ end of mapcar
    ) ;_ end of foreach
  (vla-endundomark adoc)
  (princ)
  ) ;_ end of defun

(_kpblc-autostart-purge 511)