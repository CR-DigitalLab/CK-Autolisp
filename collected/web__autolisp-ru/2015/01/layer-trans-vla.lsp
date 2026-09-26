(defun layer-trans-vla (name tr / ent xd xt adoc err)
  ;; name : имя слоя
  ;; tr : прозрачность. До 1 расценивается как %
  (setq adoc (vla-get-activedocument (vlax-get-acad-object)))
  (vla-add adoc "AcCmTransparency")
  (if (vl-catch-all-error-p
        (setq err (vl-catch-all-apply
                    (function
                      (lambda ()
                        (setq ent (vla-item (vla-get-layers (vla-get-activedocument (vlax-get-acad-object))) name))
                        (vla-getxdata ent "AcCmTransparency" 'xt 'xd)
                        (setq xt (if xt
                                   (vlax-safearray->list xt)
                                   (list 1001 1071)
                                   ) ;_ end of if
                              xd (if xd
                                   (mapcar (function vlax-variant-value) (vlax-safearray->list xd))
                                   (list "AcCmTransparency" 0)
                                   ) ;_ end of if
                              xd (mapcar (function cons) xt xd)
                              xd (subst (cons 1071
                                              (cond
                                                ((= tr acbylayer) 0)
                                                ((= tr acbyblock) 16777216)
                                                ((< tr 1.) (+ 33554431 (fix (* (- 1. tr) 256))))
                                                (t (+ 33554431 (- 256 tr)))
                                                ) ;_ end of cond
                                              ) ;_ end of cons
                                        (assoc 1071 xd)
                                        xd
                                        ) ;_ end of subst
                              ) ;_ end of setq
                        (vla-setxdata
                          ent
                          (vlax-safearray-fill
                            (vlax-make-safearray
                              vlax-vbinteger
                              (cons 0 (1- (length xd)))
                              ) ;_ end of vlax-make-safearray
                            (mapcar (function car) xd)
                            ) ;_ end of vlax-safearray-fill
                          (vlax-safearray-fill
                            (vlax-make-safearray
                              vlax-vbvariant
                              (cons 0 (1- (length xd)))
                              ) ;_ end of vlax-make-safearray
                            (mapcar
                              (function
                                (lambda (x)
                                  (vlax-make-variant (cdr x))
                                  ) ;_ end of lambda
                                ) ;_ end of function
                              xd
                              ) ;_ end of mapcar
                            ) ;_ end of vlax-safearray-fill
                          ) ;_ end of vla-setxdata
                        ) ;_ end of lambda
                      ) ;_ end of function
                    ) ;_ end of vl-catch-all-apply
              ) ;_ end of setq
        ) ;_ end of vl-catch-all-error-p
    (princ (strcat "\nError : " (vl-catch-all-error-message err)))
    ) ;_ end of if
  (command "_.regenall")
  ) ;_ end of defun
