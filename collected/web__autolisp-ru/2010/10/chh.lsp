(vl-load-com)

(defun c:chh (/ adoc hatch elist base)
  (vla-startundomark (setq adoc (vla-get-activedocument (vlax-get-acad-object))))
  (if (and (= (type (setq hantch (vl-catch-all-apply
                                   (function
                                     (lambda ()
                                       (ssname (ssget "_+.:S:E:L" '((0 . "HATCH"))) 0)
                                       ) ;_ end of lambda
                                     ) ;_ end of function
                                   ) ;_ end of vl-catch-all-apply
                          ) ;_ end of setq
                    ) ;_ end of type
              'ename
              ) ;_ end of =
           (= (type (setq base (vl-catch-all-apply
                                 (function
                                   (lambda ()
                                     (getpoint "\nSelect new base point <Cancel> : ")
                                     ) ;_ end of lambda
                                   ) ;_ end of function
                                 ) ;_ end of vl-catch-all-apply
                          ) ;_ end of setq
                    ) ;_ end of type
              'list
              ) ;_ end of =
           base
           ) ;_ end of and
    (progn
      (setq elist (entget hantch))
      (foreach item (list (cons 43 (car base))
                          (cons 44 (cadr base))
                          ) ;_ end of list
        (setq elist (subst item
                           (assoc (car item) elist)
                           elist
                           ) ;_ end of subst
              ) ;_ end of setq
        ) ;_ end of foreach
      (entmod elist)
      (entupd hantch)
      ) ;_ end of progn
    ) ;_ end of if
  (vla-endundomark adoc)
  (princ)
  ) ;_ end of defun