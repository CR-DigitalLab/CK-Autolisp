(defun layer-trans-ename (name tr / ent xd value)
  ;; name : имя слоя
  ;; tr : прозрачность. До 1 расценивается как %
  (regapp "AcCmTransparency")
  (setq ent   (tblobjname "layer" name)
        ent   (entget ent '("*"))
        xd    (cdr (assoc -3 ent))
        value (cond
                ((= tr acbylayer) 0)
                ((= tr acbyblock) 16777216)
                ((< tr 1.) (+ 33554431 (fix (* (- 1. tr) 256))))
                (t (+ 33554431 (- 256 tr)))
                ) ;_ end of cond

        ) ;_ end of setq

  (setq xd (if xd
             (subst (cons "AcCmTransparency"
                          (subst (cons 1071 value)
                                 (assoc 1071 (cdr (assoc "AcCmTransparency" xd)))
                                 (cdr (assoc "AcCmTransparency" xd))
                                 ) ;_ end of subst
                          ) ;_ end of cons
                    (assoc "AcCmTransparency" xd)
                    xd
                    ) ;_ end of subst
             (cons "AcCmTransparency" (list (cons 1071 value)))
             ) ;_ end of if
        ) ;_ end of setq

  (entmod (if (assoc -3 ent)
            (subst (cons -3 xd) (assoc -3 ent) ent)
            (append ent (list (list -3 xd)))
            ) ;_ end of if
          ) ;_ end of entmod
  (entupd (cdr (assoc -1 ent)))
  (command "_.regenall")
  ) ;_ end of defun
