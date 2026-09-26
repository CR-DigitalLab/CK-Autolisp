(defun get-ent-trans-ename (ent / res)
                           ;|
*    Получение прозрачности слоя / примитива
*    Параметры вызова:
  ent  - ename-указатель на примитив
|;
  (cond
    ((and (setq res (cdr (assoc 440 (entget ent))))
          (= res 16777216)
          ) ;_ end of and
     "byblock"
     )
    ((or (setq res (cdr (assoc 440 (entget ent))))
         (setq res (cdr
                     (assoc
                       1071
                       (cdar
                         (cdr
                           (assoc -3
                                  (entget ent '("AcCmTransparency"))
                                  ) ;_ end of assoc
                           ) ;_ end of cdr
                         ) ;_ end of cdar
                       ) ;_ end of assoc
                     ) ;_ end of cdr
               ) ;_ end of setq
         ) ;_ end of or
     (fix (- 100 (/ (logand res -33554433) 2.55)))
     )
    ) ;_ end of cond
  ) ;_ end of defun
