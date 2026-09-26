(defun _kpblc-ini-datas-write (file datas / handle exist)
                              ;|
*    Запись списка в ini-файл
*    Параметры вызова:
*	file	имя файла. Если файла не существует, то он создается
*	datas	список вида ((group (key . value) (key . value)) <...>)
*    Примеры вызова:
(_kpblc-ini-datas-write "c:\\temp.ini" '(("gr1" ("Key1" . "Val1") ("Key2" . "Val2"))
					 ("gr2" ("key1" . "Val1") ("Key2" . "Val2"))))
|;
  (_kpblc-error-catch
    (function
      (lambda ()
        (or (findfile (setq file
                             (strcat
                               (_kpblc-dir-path-and-splash (vl-filename-directory file))
                               (strcat (vl-filename-base file) ".ini")
                               ) ;_ end of strcat
                            ) ;_ end of setq
                      ) ;_ end of findfile
            ((lambda ()
               (vl-mkdir (vl-filename-directory file))
               (setq handle (open file "w"))
               (close handle)
               ) ;_ end of lambda
             )
            ) ;_ end of or
        (if (not (findfile file))
          (progn
            (if (/= "" (vl-filename-directory file))
              (vl-catch-all-apply
                '(lambda ()
                   (vl-mkdir
                     (_kpblc-dir-path-no-splash (vl-filename-directory file))
                     ) ;_ end of vl-mkdir
                   ) ;_ end of lambda
                ) ;_ end of vl-catch-all-apply
              ) ;_ end of if
            (setq handle (open file "w")
                  ) ;_ end of setq
            (close handle)
            ) ;_ end of progn
          ) ;_ end of if
        ;; Объединяем списки datas и имеющиеся данные:
        (setq datas  (mapcar
                       '(lambda (x)
                          (cons
                            (strcase (car x) t)
                            (mapcar '(lambda (y) (cons (strcase (car y) t) (cdr y)))
                                    (cdr x)
                                    ) ;_ end of mapcar
                            ) ;_ end of cons
                          ) ;_ end of LAMBDA
                       datas
                       ) ;_ end of mapcar
              exist  (_kpblc-ini-datas-read file)
              datas  ((lambda (/)
                        (foreach item datas
                          (if (setq gr (cdr (assoc (car item) exist)))
                            (progn
                              (foreach key (cdr item)
                                (if (cdr (assoc (car key) gr))
                                  (setq gr
                                         (subst key
                                                (assoc (car key) gr)
                                                gr
                                                ) ;_ end of subst
                                        ) ;_ end of setq
                                  (setq gr (append gr (list key)))
                                  ) ;_ end of if
                                ) ;_ end of foreach
                              (setq exist (subst (cons (car item) gr)
                                                 (assoc (car item) exist)
                                                 exist
                                                 ) ;_ end of subst
                                    ) ;_ end of setq
                              ) ;_ end of progn
                            (setq exist (append exist (list item)))
                            ) ;_ end of if
                          ) ;_ end of foreach
                        exist
                        ) ;_ end of lambda
                      )
              handle (open file "w")
              ) ;_ end of setq
        (foreach item datas
          (write-line
            (strcat "[" (_kpblc-conv-value-to-string (car item)) "]")
            handle
            ) ;_ end of write-line
          (foreach val (cdr item)
            (write-line
              (strcat
                (vl-string-trim " " (_kpblc-conv-value-to-string (car val)))
                "="
                (vl-string-trim " " (_kpblc-conv-value-to-string (cdr val)))
                ) ;_ end of strcat
              handle
              ) ;_ end of write-line
            ) ;_ end of foreach
          ) ;_ end of foreach
          ;	(close handle)
        ) ;_ end of lambda
      ) ;_ end of function
    (function
      (lambda (x)
          ;	(vl-catch-all-apply '(lambda () (close handle)))
        (_kpblc-error-print "_kpblc-ini-datas-write" x)
        ) ;_ end of lambda
      ) ;_ end of function
    ) ;_ end of _kpblc-error-catch
  (vl-catch-all-apply '(lambda () (close handle)))
  ) ;_ end of defun
