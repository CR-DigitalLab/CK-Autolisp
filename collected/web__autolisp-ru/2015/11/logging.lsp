(vl-load-com)

(defun _kpblc-dir-create (path / tmp)
                         ;|
*    Гарантированное создание каталога.
*    Параметры вызова:
  path  создаваемый каталог
|;
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

(defun _kpblc-get-file-log (/ path file handle)
                           ;|
*    Возвращает имя файла лога. Если файл существует и его размер больше 2Mb,
* то файл автоматически копируется и пересоздается
|;
  (setq path (_kpblc-dir-create (strcat (vl-string-right-trim "\\" (getenv "appdata")) "\\kpblc\\")))
  (cond
    ((not
       (findfile
         (setq file (strcat path
                            (getenv "userdomain")
                            "-"
                            (getenv "computername")
                            "-"
                            (getenv "username")
                            ".log"
                            ) ;_ end of strcat
               ) ;_ end of setq
         ) ;_ end of findfile
       ) ;_ end of not
     file
     )
    ((and (findfile file)
          (> (vl-file-size file) (* 2 (expt 2 20)))
          ) ;_ end of and
     (vl-file-copy
       file
       (strcat (_kpblc-dir-path-no-splash (vl-filename-directory file))
               "\\"
               (vl-filename-base file)
               "_"
               (rtos (getvar "cdate") 2 6)
               ) ;_ end of strcat
       ) ;_ end of vl-file-copy
     (setq handle (open file "w"))
     (close handle)
     file
     )
    (t file)
    ) ;_ end of cond
  ) ;_ end of defun

(defun _kpblc-log-toggle (param)
                         ;|
*    Функция включения или отключения процедуры лога
*    Параметры вызова:
  param   включить лог (t) или отключить (nil)
|;
  (vl-bb-set '*kpblc-settings*
             (_kpblc-list-add-or-subst (vl-bb-ref '*kpblc-settings*) "log" param)
             ) ;_ end of vl-bb-set
  (princ (strcat "\nЛог "
                 (if param
                   "запущен"
                   "остановлен"
                   ) ;_ end of if
                 ) ;_ end of strcat
         ) ;_ end of princ
  (princ)
  ) ;_ end of defun

(defun _kpblc-list-add-or-subst (lst key value)
                                ;|
*    Производит замену или дополнение элемента списка новым
*    Параметры вызова:
  lst      обрабатываемый список
  key      ключ
  value    устанавливаемое значение
|;
  (if (not value)
    (vl-remove-if (function (lambda (x) (= (car x) key))) lst)
    (if (cdr (assoc key lst))
      (subst (cons key value) (assoc key lst) lst)
      (cons (cons key value)
            (vl-remove-if
              (function
                (lambda (x)
                  (= (car x) key)
                  ) ;_ end of lambda
                ) ;_ end of function
              lst
              ) ;_ end of vl-remove-if
            ) ;_ end of cons
      ) ;_ end of if
    ) ;_ end of if
  ) ;_ end of defun

(defun _kpblc-log (lst / handle sep)
                  ;|
*    выполняет запись сообщения в лог
*    Параметр вызова:
 lst    список дополнительных параметров
  '(("time" . <Указывать время>)
    ("cmd" . <Указывается имя функции>)
    ("req" . <Лог выполнять в любом случае>)
    ("msg" . <Дополнительное пояснение>)
    )
|;
  (if (or (cdr (assoc "req" lst))
          (cdr (assoc "log" (vl-bb-ref '*kpblc-settings*)))
          ) ;_ end of or
    (progn
      (setq sep    "\t"
            handle (open (_kpblc-get-file-log) "a")
            ) ;_ end of setq
      (write-line
        (strcat
          (if (= (vla-get-fullname (vla-get-activedocument (vlax-get-acad-object))) "")
            "Файл не сохранен"
            (strcat (vl-string-right-trim "\\" (getvar "dwgprefix")) "\\" (getvar "dwgname"))
            ) ;_ end of if
          sep
          (cond ((cdr (assoc "cmd" lst)))
                (t "Имя lisp не указано")
                ) ;_ end of cond
          sep
          (if (cdr (assoc "time" lst))
            (_kpblc-conv-date-to-string)
            ""
            ) ;_ end of if
          (if (cdr (assoc "msg" lst))
            (strcat sep (cdr (assoc "msg" lst)))
            ""
            ) ;_ end of if
          ) ;_ end of strcat
        handle
        ) ;_ end of write-line
      (close handle)
      ) ;_ end of progn
    ) ;_ end of if
  ) ;_ end of defun

(defun _kpblc-conv-date-to-string (/ date sdate stime)
                                  ;|
*    Преобразовывает текущую дату и время в строковое представление
|;
  (setq date  (getvar "cdate")
        sdate (fix date)
        stime (- date sdate)
        sdate (itoa sdate)
        stime (itoa (fix (* stime 1e6)))
        ) ;_ end of setq
  (while (< (strlen stime) 6)
    (setq stime (strcat "0" stime))
    ) ;_ end of while
  (strcat (substr sdate 1 4)
          "-"
          (substr sdate 5 2)
          "-"
          (substr sdate 7)
          " "
          (substr stime 1 2)
          ":"
          (substr stime 3 2)
          ":"
          (substr stime 5)
          ) ;_ end of strcat
  ) ;_ end of defun

(defun _kpblc-log-show (/ file)
                       ;|
*    Выводит окно лога в отдельном приложении (блокнот)
|;
  (if (setq file (findfile (_kpblc-get-file-log)))
    (startapp "notepad.exe"
              (_kpblc-get-file-log)
              ) ;_ end of startapp
    (alert "Файл лога не обнаружен!")
    ) ;_ end of if
  (princ)
  ) ;_ end of defun