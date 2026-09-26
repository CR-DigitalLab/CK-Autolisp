(vl-load-com)

(defun c:chh-vla (/ adoc hatch base)
  (vla-startundomark (setq adoc (vla-get-activedocument (vlax-get-acad-object))))
  (if (and (= (type (setq hatch (vl-catch-all-apply
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
      (vla-put-origin (setq hatch (vlax-ename->vla-object hatch))
                      (vlax-make-variant
                        (vlax-safearray-fill
                          (vlax-make-safearray vlax-vbdouble '(0 . 1))
                          (list (car base) (cadr base))
                          ) ;_ end of vlax-safearray-fill
                        ) ;_ end of vlax-make-variant
                      ) ;_ end of vla-put-origin
      (vla-evaluate hatch)
      (vla-update hatch)
      (vla-regen adoc acactiveviewport)
      ) ;_ end of progn
    ) ;_ end of if
  (vla-endundomark adoc)
  (princ)
  ) ;_ end of defun