(defun _lispru-ini-datas-read (file / handle str group res)
                              ;|
*    Чтение данных из ini-файла.
*    Параметры вызова:
	file		полное имя файла, включая расширение.
|;
  (if (findfile file)
    (progn
      (setq handle (open file "r"))
      (while (setq str (read-line handle))
        (setq str (vl-string-trim "\t " str))
        (cond
          ((or (< (strlen str) 2) (wcmatch str ";*")))
          ((wcmatch str "`[*")
           (setq group (strcase (vl-string-trim "[]" str) t)
                 res   (append res (list (list group)))
                 ) ;_ end of setq
           )
          (group
           (setq res (subst
                       (cons
                         group
                         (vl-remove
                           'nil
                           (append
                             (cdr (assoc group res))
                             (list
                               (cons
                                 (strcase (substr str 1 (vl-string-search "=" str))
                                          t
                                          ) ;_ end of strcase
                                 (read (substr str
                                               (+ 2 (vl-string-search "=" str))
                                               ) ;_ end of substr
                                       ) ;_ end of read
                                 ) ;_ end of cons
                               ) ;_ end of list
                             ) ;_ end of append
                           ) ;_ end of vl-remove
                         ) ;_ end of cons
                       (assoc group res)
                       res
                       ) ;_ end of subst
                 ) ;_ end of setq
           )
          ) ;_ end of cond
        ) ;_ end of while
      (close handle)
      ) ;_ end of progn
    ) ;_ end of if
  (vl-remove-if-not 'cdr res)
  ) ;_ end of defun
