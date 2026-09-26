;; ver. 0.1

(vl-load-com)

(defun rename-copypaste (/ adoc name pref res_name err)
  (vla-startundomark (setq adoc (vla-get-activedocument (vlax-get-acad-object))))
  (setq pref "kpblc_")
  ;; тот самый префикс
  (vlax-for blk_def (vla-get-blocks adoc)
    (if (and (setq name (vla-get-name blk_def)) (tblobjname "block" name) (wcmatch name "A$C*"))
      (if (vl-catch-all-error-p
            (setq err (vl-catch-all-apply
                        (function (lambda ()
                                    (vla-put-name
                                      blk_def
                                      (strcat (setq res_name (strcat pref name))
                                              "_"
                                              ;; И добавляем счетчик. Скорее всего, тут постоянно будет
                                              ;; только "0", но чем шут не чертит...
                                              (itoa ((lambda (/ res)
                                                       (setq res 0)
                                                       (vlax-for item (vla-get-blocks adoc)
                                                         (if (wcmatch (vla-get-name item) (strcat res_name "_*"))
                                                           (setq res (1+ res))
                                                           ) ;_ end of if
                                                         ) ;_ end of vlax-for
                                                       res
                                                       ) ;_ end of lambda
                                                     )
                                                    ) ;_ end of itoa
                                              ) ;_ end of strcat
                                      ) ;_ end of vla-put-name
                                    ) ;_ end of lambda
                                  ) ;_ end of function
                        ) ;_ end of vl-catch-all-apply
                  ) ;_ end of setq
            ) ;_ end of vl-catch-all-error-p
        (princ (strcat "\nОшибка переименования блока " name " : " (vl-catch-all-error-message err)))
        ) ;_ end of if
      ) ;_ end of if
    ) ;_ end of vlax-for
  (vla-endundomark adoc)
  (princ)
  ) ;_ end of defun
