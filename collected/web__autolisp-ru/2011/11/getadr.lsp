(apply
  (function
    (lambda (/)
      (defun kpblc-lispru ()
        (alert
          (strcat "МаilТо\t: "
                  (vl-list->string (apply (function append)
                                          (mapcar (function (lambda (x)
                                                              (if (listp x)
                                                                (vl-remove 32 x)
                                                                x
                                                                ) ;_ end of if
                                                              ) ;_ end of lambda
                                                            ) ;_ end of function
                                                  '((107 112 98 108 99)
                                                    (50 48 48 48 32)
                                                    (32 64 32 32 103)
                                                    (32 109 32 97 32)
                                                    (105 32 108 32 46)
                                                    (32 99 32 111 32)
                                                    (109)
                                                    )
                                                  ) ;_ end of mapcar
                                          ) ;_ end of apply
                                   ) ;_ end of apply
                  "\nSkyре\t: "
                  "почта до знака собачки"
                  ) ;_ end of strcat
          ) ;_ end of alert
        ) ;_ end of defun

      (defun c:lispru ()
        (kpblc-lispru)
        ) ;_ end of defun

      (defun c:kpblc ()
        (kpblc-lispru)
        ) ;_ end of defun
      ) ;_ end of lambda
    ) ;_ end of function
  '()
  ) ;_ end of apply
