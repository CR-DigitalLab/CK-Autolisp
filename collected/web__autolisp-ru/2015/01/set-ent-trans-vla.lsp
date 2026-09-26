(defun set-ent-trans-vla (ent tr / err res)
                     ;|
*    Установка прозрачности для примитива
*    Параметры вызова:
  ent - vla-указатель на графический примитив. Не контролируется
  tr  - устанавливаемое значение прозрачности. Строка или число
|;
  (cond
    ((not (vlax-property-available-p ent 'entitytransparency t))
     (princ "\nEntityTRansparency not available")
     )
    ((vl-catch-all-error-p
       (setq err (vl-catch-all-apply
                   (function
                     (lambda ()
                       (vla-put-entitytransparency ent tr)
                       ) ;_ end of lambda
                     ) ;_ end of function
                   ) ;_ end of vl-catch-all-apply
             ) ;_ end of setq
       ) ;_ end of vl-catch-all-error-p
     (princ (strcat "\nError set EntityTransparency property : " (vl-catch-all-error-message err)))
     )
    (t
     (vla-get-entitytransparency ent)
     )
    ) ;_ end of cond
  ) ;_ end of defun
