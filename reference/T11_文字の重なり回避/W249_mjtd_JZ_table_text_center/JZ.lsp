(vl-load-com)
(defun c:JZ(/ err)
(defun algion (msg /       ss      lst     i       vlalst  boxlst  x
               cor1    cor2    findboxpt       newboxpt               en1
               en      enlst   y       y2
              )
  (princ msg)
  (setq ss (ssget '((0 . "text"))))
  (setq lst nil)
  (setq i 0)
  (repeat (sslength ss)
    (setq lst (cons (ssname ss i) lst))
    (setq i (1+ i))
  )
  (setq vlalst (mapcar 'vlax-ename->vla-object lst))
  (setq        boxlst (mapcar '(lambda        (x / cor1 cor2)
                          (vla-GetBoundingBox x 'cor1 'cor2)
                          (list        (vlax-safearray->list cor1)
                                (vlax-safearray->list cor2)
                          )
                        )
                       vlalst
               )
  )
  (setq
    findboxpt (mapcar '(lambda (x)
                         (polar        (car x)
                                (angle (car x) (cadr x))
                                (/ (DISTANCE (car x) (cadr x)) 2.0)
                         )
                       )
                      boxlst
              )
  )
  (setq        newboxpt (mapcar '(lambda (x)
                            (setq en1 (entlast))
                            (vl-cmdf "_boundary" x "")
                            (setq en (entlast))
                            (if        (not (equal en1 en))
                              (progn
                                (setq enlst (entget en))
                                (setq lst (vl-remove-if-not
                                            '(lambda (y) (= (car y) 10))
                                            enlst
                                          )
                                )
                                (setq cor1 (vl-remove 10 (car lst))
                                      cor2 (vl-remove 10 (nth 2 lst))
                                )
                                (entdel en)
                                (polar cor1
                                       (angle cor1 cor2)
                                       (/ (DISTANCE cor1 cor2) 2.0)
                                )
                              )
                            )
                          )
                         findboxpt
                 )
  )

  (mapcar '(lambda (x y y2)
             (vla-move x (vlax-3d-point y) (vlax-3d-point y2))
           )
          vlalst
          findboxpt
          newboxpt
  )

)
(setq err(VL-CATCH-ALL-APPLY 'algion (list "\n 请选择单行文字: ")))
  (princ)
  )
