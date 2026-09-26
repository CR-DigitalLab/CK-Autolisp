(defun _kpblc-progress-start (msg range) ;|
*    Инициализирует прогресс-бар
*    Параметры вызова:
  msg    показываемое сообщение
  range  общая длина прогресс-бара
|;
  (setq *kpblc-progress-range*
         (list (cons "progress" (min 32000 range)))
        range (cdr (assoc "progress" *kpblc-progress-range*))
        ) ;_ end of setq
  (cond ((and msg progressbar) (progressbar msg range))
        ((and (not msg) progressbar) (progressbar range))
        ((and msg acet-ui-progress) (acet-ui-progress msg range))
        ((and (not msg) acet-ui-progress) (acet-ui-progress range))
        (t (_kpblc-progress-cmd msg range))
        ) ;_ end of cond
  ) ;_ end of defun

(defun _kpblc-progress-continue (msg pos) ;|
*    Заполняет прогресс-бар
*    Параметры вызова:
  msg    выводимое сообщение
  pos    текущая позиция
|;
  (if (and (cdr (assoc "progress" *kpblc-progress-range*))
           (> 0 (cdr (assoc "progress" *kpblc-progress-range*)))
           (> pos (cdr (assoc "progress" *kpblc-progress-range*)))
           ) ;_ end of and
    (while (> pos (cdr (assoc "progress" *kpblc-progress-range*)))
      (setq pos (- pos (cdr (assoc "progress" *kpblc-progress-range*))))
      ) ;_ end of while
    ) ;_ end of if
  (cond (progressbar (progressbar (rem pos 32000)))
        (acet-ui-progress (acet-ui-progress (rem pos 32000)))
        (t (_kpblc-progress-cmd msg pos))
        ) ;_ end of cond
  ) ;_ end of defun

(defun _kpblc-progress-cmd (msg pos / lst) ;|
*    Выводит в ком.строку сообщение с "прогрессом"
*    Параметры вызова:
  msg    строковое сообщение
  pos    счетчик выполняемых действий
|;
  (if msg
    (princ (strcat "\r" msg " : " (nth (rem pos 4) '("-" "\\" "|" "/"))))
    (princ (strcat "\n" msg " закончено"))
    ) ;_ end of if
  ) ;_ end of defun

(defun _kpblc-progress-end ();|
*    Завершение прогресс-бара
|;
  (setq *kpblc-progress-range* nil)
  (cond (progressbar (progressbar))
        (acet-ui-progress (acet-ui-progress))
        (t (princ))
        ) ;_ end of cond
  ) ;_ end of defun

(defun test-progress (/ pos len msg)
  (setq len 33600
        pos 0
        msg "Проверка прогресс-бара"
        ) ;_ end of setq
  (_kpblc-progress-start msg len)
  (while (< pos len) (_kpblc-progress-continue msg (setq pos (1+ pos))))
  (_kpblc-progress-end)
  ) ;_ end of defun
