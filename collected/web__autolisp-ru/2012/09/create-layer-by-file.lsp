(defun c:create-layer-by-file (/              *error*        _kpblc-conv-string-to-list    file
                               handle         adoc           str            lst            layer
                               answer
                               )

                              ;|
*   Функция создания слоев в текущем файле по файлу-описанию.
*   Файл описания должен быть в формате csv или txt, кодировка Windows
* (никаких UTF)
*   В качестве разделителя столбцов допускается применение знаков
* табуляции или символа ";"
*   Если первым символов в файле описания используется символ ";",
* то строка исключается из обработки и рассматривается как комментарий
*   Структура столбцов определена изначально и для ее модификации потребуется
* менять код.
*    Столбцы (для удобства восприятия показаны вертикально, после ; указаны
* возможные варианты данных
<ИмяСлоя>          ; Имя создаваемого слоя. Должно отвечать требованиям AutoCAD
; создания слоев. Строка, обрамления символами " (двойные
; кавычки) не выполнять
<Разделитель>
<Исключен>        ; Любые данные. Если поставить подряд 2 символа разделителя,
; то ничего страшного не будет
<Разделитель>
<Исключен>        ; То же
<Разделитель>
<Исключен>        ; То же
<Разделитель>
<Цвет>            ; Цвет слоя. Целое число из диапазона 1..255
<Разделитель>
<Тип линии>        ; Тип линии слоя. Если не указано, принимается Непрерывный
; (Continuous). Если тип линии не загружен, применяется
; Непрерывный (Continuous). Не учитывает варианты локализации
<Разделитель>
<Вес линии>        ; Вес линии слоя. Допускается применение строки с символами
; def (т.е. "по умолчанию") либо чисел. 0,25 мм -> указывать
; 25
<Разделитель>
<Исключен>
<Разделитель>
<Печатается>      ; Число. "0" -> слой не печатается. Любое другое значение -
; слой печатается. При пропущенном значении приравнивается
; к "0".
Остальные столбцы исключаются из обработки
*    Вариант вызова:
create-layer-by-file
|;

  (defun _kpblc-conv-string-to-list (string separator / i)
                                    ;|
*    Функция разбора строки. Возвращает список либо точечную пару.
*    Параметры вызова:
*  string    разбираемая строка
*  separator  символ, используемый в качестве разделителя частей
*    Примеры вызова:
(_kpblc-conv-string-to-list "1;2;3;4;5;6" ";")  ;'(1 2 3 4 5 6)
(_kpblc-conv-string-to-list "1;2" ";")    ;'(1 2)
*    За основу взяты уроки Евгения Елпанова по рекурсиям
|;
    (cond
      ((= string "") nil)
      ((setq i (vl-string-search separator string))
       (cons (substr string 1 i)
             (_kpblc-conv-string-to-list
               (substr string (+ (strlen separator) 1 i))
               separator
               ) ;_ end of _kpblc-conv-string-to-list
             ) ;_ end of cons
       )
      (t (list string))
      ) ;_ end of cond
    ) ;_ end of defun

  (defun *error* (msg)
    ;; Локальный обработчик ошибок
    (vl-catch-all-apply
      (function
        (lambda ()
          (close handle)
          ) ;_ end of lambda
        ) ;_ end of function
      ) ;_ end of vl-catch-all-apply
    (if adoc
      (vla-endundomark adoc)
      ) ;_ end of if
    (princ msg)
    (princ)
    ) ;_ end of defun

  (vl-load-com)
  (vla-startundomark
    (setq adoc (vla-get-activedocument (vlax-get-acad-object)))
    ) ;_ end of vla-startundomark
  (if (and (setq file (getfiled "Файл txt или csv с описанием слоев" "" "" 2))
           (wcmatch (strcase (vl-filename-extension file)) "*CSV,*TXT")
           ) ;_ end of and
    (progn
      (setq answer ((lambda ()
                      (initget "Да Нет Yes No _ Y N Y N")
                      (cond
                        ((getkword
                           "\nПри наличии слоя выполнять его настройку по стандарту [Да/Нет] <Да> : "
                           ) ;_ end of getkword
                         )
                        (t "Y")
                        ) ;_ end of cond
                      ) ;_ end of LAMBDA
                    )
            handle (open file "r")
            ) ;_ end of setq
      (while (setq str (read-line handle))
        (setq lst (cons str lst))
        ) ;_ end of while
      (close handle)
      (setq lst
             (mapcar
               (function
                 (lambda (x)
                   (list
                     (cons "name" (nth 0 x))
                     (cons "color" (read (nth 4 x)))
                     (cons "linetype"
                           (cond ((nth 5 x))
                                 (t "Continuous")
                                 ) ;_ end of cond
                           ) ;_ end of cons
                     (cons "lineweight"
                           (cond
                             ((wcmatch (strcase (nth 6 x)) "*DEFA*")
                              aclnwtbylwdefault
                              )
                             (t (read (nth 6 x)))
                             ) ;_ end of cond
                           ) ;_ end of cons
                     (cons "plottable"
                           (if (or (not (nth 8 x))
                                   (= (nth 8 x) "0")
                                   ) ;_ end of Or
                             :vlax-false
                             :vlax-true
                             ) ;_ end of if
                           ) ;_ end of cons
                     ) ;_ end of list
                   ) ;_ end of lambda
                 ) ;_ end of function
               (mapcar
                 (function
                   (lambda (x)
                     (apply
                       (function append)
                       (mapcar
                         (function (lambda (a) (_kpblc-conv-string-to-list a ";"))
                                   ) ;_ end of function
                         x
                         ) ;_ end of mapcar
                       ) ;_ end of apply
                     ) ;_ end of lambda
                   ) ;_ end of function
                 (mapcar
                   (function
                     (lambda (x)
                       (_kpblc-conv-string-to-list x "\t")
                       ) ;_ end of lambda
                     ) ;_ end of function
                   (vl-remove-if
                     (function
                       (lambda (x)
                         (wcmatch x ";*")
                         ) ;_ end of lambda
                       ) ;_ end of function
                     (reverse lst)
                     ) ;_ end of vl-remove-if
                   ) ;_ end of mapcar
                 ) ;_ end of mapcar
               ) ;_ end of mapcar
            ) ;_ end of setq
      (foreach item lst
        (if (= (type
                 (setq layer
                        (vl-catch-all-apply
                          (function
                            (lambda ()
                              (vla-item
                                (vla-get-layers adoc)
                                (cdr (assoc "name" item))
                                ) ;_ end of vla-item
                              ) ;_ end of lambda
                            ) ;_ end of function
                          ) ;_ end of vl-catch-all-apply
                       ) ;_ end of setq
                 ) ;_ end of type
               'vla-object
               ) ;_ end of =
          (if (= answer "Y")
            (foreach prop (cdr item)
              (vl-catch-all-apply
                (function
                  (lambda ()
                    (vlax-put-property layer (car prop) (cdr prop))
                    ) ;_ end of lambda
                  ) ;_ end of function
                ) ;_ end of vl-catch-all-apply
              ) ;_ end of foreach
            ) ;_ end of if
          (vl-catch-all-apply
            (function
              (lambda ()
                (setq layer (vla-add (vla-get-layers adoc)
                                     (cdr (assoc "name" item))
                                     ) ;_ end of vla-add
                      ) ;_ end of setq
                (foreach prop (cdr item)
                  (vl-catch-all-apply
                    (function
                      (lambda ()
                        (vlax-put-property layer (car prop) (cdr prop))
                        ) ;_ end of lambda
                      ) ;_ end of function
                    ) ;_ end of vl-catch-all-apply
                  ) ;_ end of foreach
                ) ;_ end of lambda
              ) ;_ end of function
            ) ;_ end of vl-catch-all-apply
          ) ;_ end of if
        ) ;_ end of foreach
      ) ;_ end of progn
    ;; Выводим сообщение об ошибке в ком.строку, если вообще был выбран файл
    (if file
      (princ (strcat "\nУ выбранного файла недопустимое расширение"))
      ) ;_ end of if
    ) ;_ end of if
  (vla-endundomark adoc)
  (princ)
  ) ;_ end of defun