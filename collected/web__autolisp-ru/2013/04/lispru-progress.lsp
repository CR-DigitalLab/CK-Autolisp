(defun _lispru-progress-start (msg range)
                             ;|
*    Инициализирует прогресс-бар
*    Параметры вызова:
	msg		показываемое сообщение
	range	общая длина прогресс-бара
|;
  (cond
    ((and msg acet-ui-progress)
     (acet-ui-progress msg (min 32000 range))
     )
    ((and (not msg) acet-ui-progress)
     (acet-ui-progress (min 32000 range))
     )
    ((and msg progressbar)
     (progressbar msg (min 32000 range))
     )
    ((and (not msg) progressbar)
     (progressbar (min 32000 range))
     )
    (t
     (_lispru-progress-cmd msg range)
     )
    ) ;_ end of cond
  ) ;_ end of defun

(defun _lispru-progress-cmd (msg pos / lst)
                           ;|
*    Выводит в ком.строку сообщение с "прогрессом"
*    Параметры вызова:
	msg		строковое сообщение
	pos		счетчик выполняемых действий
|;
  (if msg
    (princ (strcat "\r" msg " : " (nth (rem pos 4) '("-" "\\" "|" "/"))))
    (princ "\n" msg " закончено")
    ) ;_ end of if
  ) ;_ end of defun

(defun _lispru-progess-continue (msg pos)
                               ;|
*    Заполняет прогресс-бар
*    Параметры вызова:
  msg    выводимое сообщение
  pos    текущая позиция
|;
  (cond
    (acet-ui-progress
     (acet-ui-progress (rem pos 32000))
     )
    (progressbar
     (progressbar (rem pos 32000))
     )
    (t
     (_lispru-progress-cmd msg pos)
     )
    ) ;_ end of cond
  ) ;_ end of defun

(defun _lispru-progress-end ()
                           ;|
*    Завершение прогресс-бара
|;
  (cond
    (acet-ui-progress
     (acet-ui-progress)
     )
    (progressbar
     (progressbar)
     )
    (t (princ))
    ) ;_ end of cond
  ) ;_ end of defun
