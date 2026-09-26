(defun _kpblc-create-united-lisp (ref-list file / file handle count)
                                 ;|
*    Собирает все lsp в одну кучу
*    Параметры вызова:
  ref-list   список объединяемых файлов
  file       результирующий файл. Полный путь. Каталог файла уже должен существовать
|;
  (setq count  0
        handle (open file "w")
        ) ;_ end of setq
  (close handle)
  (foreach item (vl-sort ref-list
                         (function (lambda (a b) (< (strcase (vl-filename-base a)) (strcase (vl-filename-base b)))))
                         ) ;_ end of vl-sort
    (setq handle (open file "a"))
    (write-line "\n\n" handle)
    (if (>= count 200)
      (progn (write-line ")\n(progn" handle) (setq count 0))
      ) ;_ end of if
    (close handle)
    (vl-file-copy item file t)
    (setq count (1+ count))
    ) ;_ end of foreach
  file
  ) ;_ end of defun
