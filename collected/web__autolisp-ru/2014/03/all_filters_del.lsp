;; Удаление лишних фильтров слоев из чертежа
;; имена фильтров, которые требуется оставить передаются списком
;; Функция переписана с учетом особенностей версии 2005, где появился новый словарь
(defun all_filters_del (lstnames / vla:lrs vla:xdic vla:dic vla:xrec name datatype datavalue num)
  (setq vla:lrs (vla-get-layers (vla-get-activedocument (vlax-get-acad-object))))
  (if (= (vla-get-hasextensiondictionary vla:lrs) :vlax-true)
    ;; при наличии словаря требуется детальная проверка
    (progn (setq lstnames (mapcar 'strcase lstnames))
           (setq vla:xdic (vla-getextensiondictionary vla:lrs))
           (setq num 0)
           ;; поиск и удаление фильтров версий пре-2005
           (if (progn (vlax-for item vla:xdic
                        (if (= (vla-get-name item) "ACAD_LAYERFILTERS")
                          (setq vla:dic item)
                          ) ;_  if
                        ) ;_  vlax-for
                      vla:dic
                      ) ;_  progn
             (progn (vlax-for vla:xrec vla:dic
                      (if (not (member (strcase (setq name (vla-get-name vla:xrec))) lstnames))
                        (progn (vla-remove vla:dic name) (vlax-release-object vla:xrec) (setq num (1+ num)))
                        ) ;_  if
                      ) ;_  vlax-for
                    (vlax-release-object vla:dic)
                    (if (zerop num)
                      (princ "\nЛишних фильтров 2002 в рисунке не обнаружено.")
                      (princ "\nЛишние фильтры 2002 из рисунка удалены.")
                      ) ;_  if
                    ) ;_ progn
             ) ;_ if
           (setq vla:dic nil)
           (setq num 0)
           ;; поиск и удаление фильтров версии 2005
           (if (progn (vlax-for item vla:xdic
                        (if (= (vla-get-name item) "ACLYDICTIONARY")
                          (setq vla:dic item)
                          ) ;_  if
                        ) ;_  vlax-for
                      vla:dic
                      ) ;_  progn
             (progn (vlax-for vla:xrec vla:dic
                      (if (progn (setq name (vla-get-name vla:xrec))
                                 (vla-getxrecorddata vla:xrec 'datatype 'datavalue)
                                 (not
                                   (member (strcase (vlax-variant-value
                                                      (vlax-safearray-get-element datavalue (vl-position 300 (vlax-safearray->list datatype))) 
                                                      ) ;_  vlax-variant-value
                                                    ) ;_  strcase
                                           lstnames
                                           ) ;_  member
                                   ) ;_  not
                                 ) ;_  progn
                        (progn (vla-remove vla:dic name) (vlax-release-object vla:xrec) (setq num (1+ num))) ;_  progn
                        ) ;_  if
                      ) ;_  vlax-for
                    (vlax-release-object vla:dic)
                    (if (zerop num)
                      (princ "\nЛишних фильтров 2005 в рисунке не обнаружено.")
                      (princ "\nЛишние фильтры 2005 из рисунка удалены.")
                      ) ;_  if
                    ) ;_ progn
             ) ;_ if
           (vlax-release-object vla:xdic)
           ) ;_  progn
    (princ "\nФильтров в рисунке не обнаружено.")
    ) ;_  if
  (vlax-release-object vla:lrs)
  (princ)
  ) ;_ defun
(vl-load-com)
;;; (all_filters_del '("MyFilter1" "MyFilter2" "MyFilter3")) ;_ автозапуск программы для удаления только лишних
;;; (all_filters_del '()) ;_ автозапуск программы для удаления ВСЕХ фильтров