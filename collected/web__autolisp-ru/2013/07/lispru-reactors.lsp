(vl-load-com)

(setq *lispru-adoc* (vla-get-activedocument (vlax-get-acad-object)))

(if *vlr-cmd*
  (progn
    (setq *vlr-cmd* nil)
    (vlr-remove-all :vlr-command-reactor)
    ) ;_ end of progn
  ) ;_ end of if

(if (not *vlr-cmd*)
  (setq *vlr-cmd*
         (vlr-command-reactor
           "lena-command-reactor"
           '(
             (:vlr-commandwillstart . _lispru-vlr-command-start)
             (:vlr-commandended . _lispru-vlr-command-end)
             (:vlr-commandcancelled . _lispru-vlr-command-cancel)
             (:vlr-commandfailed . _lispru-vlr-command-fail)
             )
           ) ;_ end of VLR-Command-Reactor
        ) ;_ end of setq
  ) ;_ end of if

(defun _lispru-vlr-command-start (react cmd)
  (setq cmd (strcase (car cmd) t))
  (cond
    ((member cmd '("qsave" "save" "saveas"))
     (_lispru-vlr-command-start-save)
     )
    ((= cmd "audit")
     (setq *lispru-audit-sysvar* (_lispru-error-sysvar-save-by-list '(("dimpost" . ""))))
     )
    ) ;_ end of cond
  ) ;_ end of defun

(defun _lispru-vlr-command-cancel (react cmd)
  (_lispru-error-sysvar-restore-by-list *lispru-audit-sysvar*)
  (setq *lispru-audit-sysvar* nil)
  ) ;_ end of defun

(defun _lispru-vlr-command-end (react cmd / ext old_menu loc_menu)
  (setq cmd (vl-string-trim "_." (strcase (car cmd) t)))
  (cond
    ((= cmd "audit")
     (_lispru-error-sysvar-restore-by-list *lispru-audit-sysvar*)
     (setq *lispru-audit-sysvar* nil)
     )
    ) ;_ end of cond
  ) ;_ end of defun

(defun _lispru-vlr-command-fail (react cmd)
  (_lispru-error-sysvar-restore-by-list *lispru-audit-sysvar*)
  (setq *lispru-audit-sysvar* nil)
  ) ;_ end of defun

(defun _lispru-vlr-command-start-save (/ hive lst)
  ;; Реактор на команду сохранения файла

  ;; Очистка от пустых групп. Выполняется без разговоров.
  (vlax-for gr (vla-get-groups *lispru-adoc*)
    (if (= (vla-get-count gr) 0)
      (vl-catch-all-apply
        (function
          (lambda ()
            (vla-delete gr)
            ) ;_ end of lambda
          ) ;_ end of function
        ) ;_ end of vl-catch-all-apply
      ) ;_ end of if
    ) ;_ end of vlax-for

  (repeat 3 (vla-purgeall *lispru-adoc*))
  (vlax-for item (vla-get-registeredapplications *lispru-adoc*)
    (vl-catch-all-apply
      (function
        (lambda ()
          (vla-delete item)
          ) ;_ end of lambda
        ) ;_ end of function
      ) ;_ end of vl-catch-all-apply
    ) ;_ end of vlax-for
  (_lispru-dwg-audit)

  ) ;_ end of defun

(defun _lispru-dwg-audit (/ sysvars)
  (setq sysvars (_lispru-error-sysvar-save-by-list
                  '(("cmdecho" . 0) ("nomutt" . 1) ("menuecho" . 0) ("dimpost" . ""))
                  ) ;_ end of _lispru-error-sysvar-save-by-list
        ) ;_ end of setq
  (vl-catch-all-apply
    (function
      (lambda ()
        (vla-auditinfo *lispru-adoc* :vlax-true)
        ) ;_ end of lambda
      ) ;_ end of function
    ) ;_ end of vl-catch-all-apply
  (_lispru-error-sysvar-restore-by-list sysvars)
  ) ;_ end of defun

(defun _lispru-error-sysvar-restore-by-list (lst)
                                           ;|
*    Восстановление состояния системных переменных.
*    Параметры вызова:
	lst	список системных переменных, значения которых надо
		восстаналивать вида:
      '((<sysvar> . <value>) <...>)
|;
  (foreach item lst
    (if (getvar (car item))
      (setvar (car item) (cdr item))
      ) ;_ end of if
    ) ;_ end of foreach
  ) ;_ end of defun

(defun _lispru-error-sysvar-save-by-list (lst / res)
                                        ;|
*    Сохранение состояния системных переменных для документа. Возможна
* одновременная установка
*    Параметры вызова:
	lst	список системных переменных вида
      '((<sysvar> <value>) <...>)
*    Возвращает список 
|;
  (foreach item lst
    (if (getvar (car item))
      (progn
        (setq res (cons (cons (car item) (getvar (car item))) res))
        (if (cdr item)
          (setvar (car item)
                  (if (= (type (cdr item)) 'list)
                    (cadr item)
                    (cdr item)
                    ) ;_ end of if
                  ) ;_ end of setvar
          ) ;_ end of if
        ) ;_ end of progn
      ) ;_ end of if
    ) ;_ end of foreach
  res
  ) ;_ end of defun
