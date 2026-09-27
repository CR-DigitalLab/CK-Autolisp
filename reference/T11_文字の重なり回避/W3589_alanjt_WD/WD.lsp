;;; Change width of selected MText and MultiLeader objects
;;; Alan J. Thompson, 11.05.09
(defun c:WD (/ #SS #Width)
 (cond
   ((and (setq #SS (ssget "_:L" '((0 . "MTEXT,MULTILEADER"))))
         (not (initget 4))
         (or (setq #Width (getdist "\nWidth <0.0>: ")) (setq #Width 0.))
    ) ;_ and
    (or *AcadDoc* (setq *AcadDoc* (vla-get-activedocument (vlax-get-acad-object))))
    (vlax-for x (setq #SS (vla-get-activeselectionset *AcadDoc*))
      (cond
        ((eq (vla-get-objectname x) "AcDbMText")
         (vl-catch-all-apply 'vla-put-width (list x #Width))
        )
        ((eq (vla-get-objectname x) "AcDbMLeader")
         (vl-catch-all-apply 'vla-put-textwidth (list x #Width))
        )
      ) ;_ cond
    ) ;_ vlax-for
    (vl-catch-all-apply 'vla-delete (list #SS))
   )
 ) ;_ cond
 (princ)
) ;_ defun
