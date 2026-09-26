(vl-load-com)

(defun c:hatch-no-assoc (/ adoc layer count err_count)
  (vla-startundomark (setq adoc (vla-get-activedocument (vlax-get-acad-object))))
  (setq count     0
        err_count 0
        layer     (mapcar (function
                            (lambda (x)
                              (cons x
                                    (mapcar (function (lambda (prop / tmp)
                                                        (setq tmp (vlax-get-property x (car prop)))
                                                        (vl-catch-all-apply (function (lambda () (vlax-put-property x (car prop) (cdr prop)))))
                                                        (cons (car prop) tmp)
                                                        ) ;_ end of lambda
                                                      ) ;_ end of function
                                            (list (cons "freeze" :vlax-false) (cons "lock" :vlax-false))
                                            ) ;_ end of mapcar
                                    ) ;_ end of cons
                              ) ;_ end of lambda
                            ) ;_ end of function
                          ((lambda (/ lst)
                             (vlax-for item (vla-get-layers adoc)
                               (if (not (wcmatch (vla-get-name item) "*|*"))
                                 (setq lst (cons item lst))
                                 ) ;_ end of if
                               ) ;_ end of vlax-for
                             lst
                             ) ;_ end of lambda
                           )
                          ) ;_ end of mapcar
        ) ;_ end of setq
  (vlax-for blk_def (vla-get-blocks adoc)
    (if (equal (vla-get-isxref blk_def) :vlax-false)
      (vlax-for ent blk_def
        (if (wcmatch (strcase (vla-get-objectname ent)) "*HATCH*")
          (if (vl-catch-all-error-p
                (vl-catch-all-apply (function (lambda () (vla-put-associativehatch ent :vlax-false))))
                ) ;_ end of vl-catch-all-error-p
            (setq err_count (1+ err_count))
            (setq count (1+ count))
            ) ;_ end of if
          ) ;_ end of if
        ) ;_ end of vlax-for
      ) ;_ end of if
    ) ;_ end of vlax-for
  (foreach item layer
    (foreach prop (cdr item)
      (vl-catch-all-apply (function (lambda () (vlax-put-property (car item) (car prop) (cdr prop)))))
      ) ;_ end of foreach
    ) ;_ end of foreach
  (princ (strcat "\nСнята ассоциативность у "
                 (itoa count)
                 " штриховок"
                 "\nОшибка снятия ассоциативности: "
                 (itoa err_count)
                 " штриховок"
                 ) ;_ end of strcat
         ) ;_ end of princ
  (vla-endundomark adoc)
  (princ)
  ) ;_ end of defun

(princ "\nНаберите hatch-no-assoc для запуска команды")
(princ)