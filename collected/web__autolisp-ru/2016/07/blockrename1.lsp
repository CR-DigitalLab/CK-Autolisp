(vl-load-com)

(defun c:blockrename (/ adoc mask postfix err err_lst name)
  (if (and (= (type
                (setq mask (vl-catch-all-apply (function (lambda () (getstring "\nМаска имени блока <Отмена> : ")))))
                ) ;_ end of type
              'str
              ) ;_ end of =
           (/= mask "")
           (= (type
                (setq postfix (vl-catch-all-apply
                                (function (lambda () (getstring "\nДобавляемые в конец имени символы <Отмена> : ")))
                                ) ;_ end of vl-catch-all-apply
                      ) ;_ end of setq
                ) ;_ end of type
              'str
              ) ;_ end of =
           (/= postfix "")
           ) ;_ end of and
    (progn (vla-startundomark (setq adoc (vla-get-activedocument (vlax-get-acad-object))))
           (vlax-for blk_def (vla-get-blocks adoc)
             (if (and (equal (vla-get-isxref blk_def) :vlax-false)
                      (equal (vla-get-islayout blk_def) :vlax-false)
                      (not (wcmatch (setq name (vla-get-name blk_def)) "*|*"))
                      (wcmatch (strcase name) (strcase mask))
                      ) ;_ end of and
               (if (vl-catch-all-error-p
                     (setq err (vl-catch-all-apply (function (lambda () (vla-put-name blk_def (strcat name postfix))))))
                     ) ;_ end of vl-catch-all-error-p
                 (setq err_lst (cons name err_lst))
                 ) ;_ end of if
               ) ;_ end of if
             ) ;_ end of vlax-for
           (if err_lst
             (progn (setq err_lst (vl-sort err_lst '<))
                    (princ
                      (strcat "\nНе удалось переназначить имена блокам: "
                              (car err_lst)
                              (apply (function strcat) (mapcar (function (lambda (x) (strcat "; " x))) (cdr err_lst)))
                              ) ;_ end of strcat
                      ) ;_ end of princ
                    ) ;_ end of progn
             ) ;_ end of if
           (vla-endundomark adoc)
           ) ;_ end of progn
    ) ;_ end of if
  (princ)
  ) ;_ end of defun

(princ "\nType \"blockrename\" to start command")
(princ)