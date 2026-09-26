(defun c:lbytxt (/ *error* _kpblc-conv-string-to-list adoc ent file handle item lst prop str)

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

  (defun _kpblc-conv-string-to-list (string separator / i)
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

  (vl-load-com)
  (vla-startundomark
    (setq adoc (vla-get-activedocument (vlax-get-acad-object)))
    ) ;_ end of vla-startundomark
  (if (and (setq file (getfiled "Файл txt или csv с описанием слоев" "" "" 2))
           (wcmatch (strcase (vl-filename-extension file)) "*CSV,*TXT")
           ) ;_ end
    (progn
      (setq handle (open file "r"))
      (while (setq str (read-line handle))
        (setq lst (cons str lst))
        ) ;_ end of while
      (close handle)
      (foreach item (mapcar
                      (function
                        (lambda (x)
                          (list
                            (cons "name" (cadr x))
                            (cons "description" (car x))
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
        (if (/= (type (setq ent (vl-catch-all-apply
                                  (function
                                    (lambda ()
                                      (vla-item (vla-get-layers adoc) (cdr (assoc "name" item)))
                                      ) ;_ end of lambda
                                    ) ;_ end of function
                                  ) ;_ end of VL-CATCH-ALL-APPLY
                            ) ;_ end of setq
                      ) ;_ end of type
                'vla-object
                ) ;_ end of /=
          (progn
            (setq ent (vla-add (vla-get-layers adoc) (cdr (assoc "name" item))))
            (foreach prop '("color" "lineweight" "linetype" "plottable")
              (vl-catch-all-apply
                (function
                  (lambda ()
                    (vlax-put-property ent
                                       prop
                                       (vlax-get-property (vla-item (vla-get-layers adoc) "0")
                                                          prop
                                                          ) ;_ end of vlax-get-property
                                       ) ;_ end of vlax-put-property
                    ) ;_ end of lambda
                  ) ;_ end of function
                ) ;_ end of vl-catch-all-apply
              ) ;_ end of foreach
            (vla-put-description ent (cdr (assoc "description" item)))
            ) ;_ end of progn
          ) ;_ end of if
        ) ;_ end of foreach
      ) ;_ end of progn
    ) ;_ end of if
  (vla-endundomark adoc)
  (princ)
  ) ;_ end of defun

