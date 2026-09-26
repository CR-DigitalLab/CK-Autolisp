(vl-load-com)

(defun _kpblc-acad-scalelist-clear-and-restore (lst                    /                      scalelist
                                                item                   pos                    dict
                                                lasthandle             n                      dn
                                                err_lst                err                    _kpblc-ent-modify
                                                _kpblc-ent-modify-autoregen                   _kpblc-conv-ent-to-ename
                                                _kpblc-conv-list-to-string
                                                _kpblc-conv-value-to-string                   _kpblc-eval-value-round
                                                _kpblc-error-catch     _kpblc-error-print
                                                )
                                               ;|
*    Очищает список масштабов и восстанавливает стандартный
*    Параметры вызова
  lst  список масштабов. nil -> просто очистка, без создания новых. Формат списка:
    '(("Имя масштаба" "Масштаб единицы листа" "Масштаб единицы чертежа")
      <...>
    )
*    Примеры вызова:
(_kpblc-acad-scalelist-clear-and-restore '(("1:1" 1. 1.) ("1:200" 1. 200.) ("1:500" 1. 500.) ("1:2 000" 1. 2000.)))
|;



  (defun _kpblc-ent-modify (ent bit value / ent_list old_dxf new_dxf)
                           ;|
*    Функция модификации указанного бита примитива
*    Параметры вызова:
*  entity  - примитив, полученный через (entsel), (entlast) etc
*  bit  - dxf-код, значение которого надо установить
*  value  - новое значение
*    Примеры вызова:
(_kpblc-ent-modify (entlast) 8 "0")  ; перенести последний примитив на слой 0
(_kpblc-ent-modify (entsel) 62 10)  ; установить выбранному примитиву цвет 10
*    Возвращаемое значение:
*  примитив с модифицированным dxf-списком. Примитив автоматически 
* перерисовывается.
|;
    (_kpblc-ent-modify-autoregen ent bit value t)
    ) ;_ end of defun

  (defun _kpblc-ent-modify-autoregen (ent bit value ext_regen / ent_list old_dxf new_dxf layer_dxf70)
                                     ;|
*    Функция модификации указанного бита примитива
*    Параметры вызова:
*  entity  - примитив, полученный через (entsel), (entlast) etc
*  bit  - dxf-код, значение которого надо установить
*  value  - новое значение
*  regen  - выполнять или нет регенерацию примитива сразу. t/ nil
*    Примеры вызова:
(_kpblc-ent-modify-autoregen (entlast) 8 "0" t)  ; перенести последний примитив на слой 0
(_kpblc-ent-modify-autoregen (entsel) 62 10 nil)  ; установить выбранному примитиву цвет 10
*    Возвращаемое значение:
*  примитив с модифицированным dxf-списком. Примитив перерисовывается в
* зависимости от значения ключа ext_regen
|;
    (setq ent (_kpblc-conv-ent-to-ename ent))
    (if (not
          (and
            (or
              (= (strcase (cdr (assoc 0 (entget ent))) nil) "STYLE")
              (= (strcase (cdr (assoc 0 (entget ent))) nil) "DIMSTYLE")
              (= (strcase (cdr (assoc 0 (entget ent))) nil) "LAYER")
              ) ;_ end of or 
            (= bit 100)
            ) ;_ end of and 
          ) ;_ end of not 
      (progn
        (setq ent_list (entget ent)
              new_dxf  (cons bit
                             (if (and (= bit 62) (= (type value) 'str))
                               (if (= (strcase value) "BYLAYER")
                                 256
                                 0
                                 ) ;_ end of if 
                               value
                               ) ;_ end of if 
                             ) ;_ end of cons 
              ) ;_ end of setq 
        (if (not (equal new_dxf (setq old_dxf (assoc bit ent_list))))
          (progn
            (entmod (if old_dxf
                      (subst new_dxf old_dxf ent_list)
                      (append ent_list (list new_dxf))
                      ) ;_ end of if 
                    ) ;_ end of entmod
            (if ent_regen
              (entupd ent)
              (redraw ent)
              ) ;_ end of if
            ) ;_ end of progn 
          ) ;_ end of if 
        ) ;_ end of progn 
      ) ;_ end of if 
    ent
    ) ;_ end of defun

  (defun _kpblc-conv-list-to-string (lst sep)
                                    ;|
*    Преобразование списка в строку
*    Параметры вызова:
  lst  обрабатываемй список
  sep  разделитель. nil -> " "
|;
    (if (and lst
             (setq lst (mapcar (function _kpblc-conv-value-to-string) lst))
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

  (defun _kpblc-conv-value-to-string (value /)
                                     ;|
*    конвертация значения в строку.
|;
    (cond
      ((= (type value) 'str) value)
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

  (defun _kpblc-eval-value-round (value to)
                                 ;|
;; http://forum.dwg.ru/showthread.php?p=301275
*    Выполняет округление числа до указанной точности
*    Примеры вызова:
(_kpblc-eval-value-round 16.365 0.01) ; 16.37
|;
    (if (zerop to)
      value
      (* (atoi (rtos (/ (float value) to) 2 0)) to)
      ) ;_ end of if
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

  (defun _kpblc-error-print (func-name msg / res)
                            ;|
*    Функция вывода сообщения об ошибке для (_kpblc-error-catch)
*    Параметры вызова:
*  func-name  имя функции, в которой возникла ошибка
*  msg    сообщение об ошибке
|;
    (princ (setq res (strcat "\n ** "
                             (vl-string-trim "][ :\n<>"
                                             (vl-string-subst
                                               ""
                                               "error"
                                               (strcase (_kpblc-conv-value-to-string func-name) t)
                                               ) ;_ end of vl-string-subst
                                             ) ;_ end of vl-string-trim
                             " ERROR #"
                             (if msg
                               (strcat
                                 (_kpblc-conv-value-to-string (getvar "errno"))
                                 ": "
                                 (_kpblc-conv-value-to-string msg)
                                 ) ;_ end of strcat
                               ": undefined"
                               ) ;_ end of if
                             ) ;_ end of strcat
                 ) ;_ end of setq
           ) ;_ end of princ
    (princ)
    ) ;_ end of defun

  (defun _kpblc-conv-ent-to-ename (ent_value / _lst)
                                  ;|
*    Функция преобразования полученного значения в ename
*    Параметры вызова:
*  ent_value  значение, которое надо преобразовать в примитив. Может
*      быть именем примитива, vla-указателем или просто
*      списком.
*      Если не принадлежит ни одному из указанных типов,
*      возвращается nil
*    Примеры вызова:
(_kpblc-conv-ent-to-ename (entlast))
(_kpblc-conv-ent-to-ename (vlax-ename->vla-object (entlast)))
|;
    ;; "_kpblc-conv-ent-to-ename")
    (cond
      ((= (type ent_value) 'vla-object)
       (vlax-vla-object->ename ent_value)
       )
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


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (foreach scale (mapcar (function cdr)
                         (vl-remove-if-not
                           (function (lambda (x) (= (car x) 350)))
                           (dictsearch (namedobjdict) "acad_scalelist")
                           ) ;_ end of vl-remove-if-not
                         ) ;_ end of mapcar
    (if (not (member (cdr (assoc 300 (entget scale))) (mapcar (function car) lst)))
      (vl-catch-all-apply
        (function
          (lambda ()
            (vla-delete (vlax-ename->vla-object scale))
            ) ;_ end of lambda
          ) ;_ end of function
        ) ;_ end of vl-catch-all-apply
      ) ;_ end of if
    ) ;_ end of foreach

  (setq scalelist (mapcar (function cdr)
                          (vl-remove-if-not
                            (function (lambda (x) (= (car x) 350)))
                            (setq dict (dictsearch (namedobjdict) "acad_scalelist"))
                            ) ;_ end of vl-remove-if-not
                          ) ;_ end of mapcar
        n         (atoi
                    (chr
                      (1+
                        (apply 'max
                               (apply 'append
                                      (mapcar '(lambda (x) (vl-remove-if '(lambda (a) (> a 57)) (vl-string->list (cdr x))))
                                              (vl-remove-if-not '(lambda (x) (= (car x) 3)) dict)
                                              ) ;_ end of mapcar
                                      ) ;_ end of apply
                               ) ;_ end of apply
                        ) ;_ end of 1+
                      ) ;_ end of chr
                    ) ;_ end of atoi
        dn        (chr
                    (+
                      (if (= n 9)
                        (progn (setq n 0) 1)
                        0
                        ) ;_ end of if
                      (apply 'max
                             (apply 'append
                                    (mapcar '(lambda (x) (vl-remove-if '(lambda (a) (< a 65)) (vl-string->list (cdr x))))
                                            (vl-remove-if-not '(lambda (x) (= (car x) 3)) dict)
                                            ) ;_ end of mapcar
                                    ) ;_ end of apply
                             ) ;_ end of apply
                      ) ;_ end of 1+
                    ) ;_ end of chr
        ) ;_ end of setq

  (foreach scale scalelist
    (cond
      ((setq pos (vl-position (cdr (assoc 300 (entget scale))) (mapcar (function car) lst)))
       (_kpblc-ent-modify scale 140 (cadr (nth pos lst)))
       (_kpblc-ent-modify scale 141 (caddr (nth pos lst)))
       (setq lst (vl-remove (nth pos lst) lst))
       )
      ((and (member (cons (cdr (assoc 140 (entget scale))) (cdr (assoc 141 (entget scale))))
                    (mapcar (function cdr) lst)
                    ) ;_ end of member
            (setq pos (- (length lst)
                         (member (cons (cdr (assoc 140 (entget scale))) (cdr (assoc 141 (entget scale))))
                                 (mapcar (function cdr) lst)
                                 ) ;_ end of member
                         ) ;_ end of -
                  ) ;_ end of setq
            ) ;_ end of and
       (_kpblc-ent-modify scale 300 (car (nth pos lst)))
       (_kpblc-ent-modify scale 140 (cadr (nth pos lst)))
       (_kpblc-ent-modify scale 141 (caddr (nth pos lst)))
       (setq lst (vl-remove (nth pos lst) lst))
       )
      (t
       (if (and (vl-catch-all-error-p
                  (setq err (vl-catch-all-apply
                              (function
                                (lambda ()
                                  (entdel scale)
                                  ) ;_ end of lambda
                                ) ;_ end of function
                              ) ;_ end of vl-catch-all-apply
                        ) ;_ end of setq
                  ) ;_ end of vl-catch-all-error-p
                (/= (type err) 'ename)
                ) ;_ end of and
         (setq err_lst (cons (cons (cdr (assoc 300 (entget scale))) (vl-catch-all-error-message err)) err_lst))
         ) ;_ end of if
       )
      ) ;_ end of cond
    ) ;_ end of foreach

  (if err_lst
    (progn
      (princ (strcat "Ошибки удаления масштабов\n"
                     (_kpblc-conv-list-to-string
                       (mapcar
                         (function
                           (lambda (x)
                             (strcat (car x) " : " (cdr x))
                             ) ;_ end of lambda
                           ) ;_ end of function
                         err_lst
                         ) ;_ end of mapcar
                       "\n"
                       ) ;_ end of _kpblc-conv-list-to-string
                     ) ;_ end of strcat
             ) ;_ end of princ
      (setq err nil
            err_lst nil
            ) ;_ end of setq
      ) ;_ end of progn
    ) ;_ end of if


  ;; Теперь добавление отсутствующих масштабов
  (if (setq dict (dictsearch (namedobjdict) "acad_scalelist"))
    (foreach item lst
      (_kpblc-error-catch
        (function
          (lambda (/ tmp)
            (dictadd (cdr (assoc -1 dict))
                     (setq tmp (strcat
                                 (if (= n 9)
                                   (setq n  -1
                                         dn (chr (1+ (ascii dn)))
                                         ) ;_ end of setq
                                   dn
                                   ) ;_ end of if
                                 (itoa (setq n (1+ n)))
                                 ) ;_ end of strcat
                           ) ;_ end of setq
                     (entmakex (list '(0 . "SCALE")
                                     '(100 . "AcDbScale")
          ; '(102 . "{ACAD_REACTORS")
          ; (cons 330 (cdr (assoc -1 dict)))
          ; '(102 . "}")
          ; (cons 330 (cdr (assoc -1 dict)))
                                     (cons 300 (car item))
                                     '(70 . 0)
                                     (cons 140 (cadr item))
                                     (cons 141 (caddr item))
                                     '(290 . 1)
                                     ) ;_ end of list
                               ) ;_ end of entmakex
                     ) ;_ end of dictadd
            ) ;_ end of lambda
          ) ;_ end of function
        '(lambda (x)
           (_kpblc-error-print (strcat "Не удалось добавить масштаб " (car item)) x)
           ) ;_ end of lambda
        ) ;_ end of _kpblc-error-catch
      ) ;_ end of foreach
    ) ;_ end of if
  ) ;_ end of defun
