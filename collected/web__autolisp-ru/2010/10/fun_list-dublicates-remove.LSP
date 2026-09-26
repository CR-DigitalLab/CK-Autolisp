(defun fun_list-dublicates-remove (lst / result)
                                  ;|
*    Функция исключения дубликатов элементов списка 
*    Параметры вызова:
*	lst	обрабатываемый список
*    Возвращаемое значение: список без дубликатов соседних элементов
*    Примеры вызова:
(fun_list-dublicates-remove '((0.0 0.0 0.0) (10.0 0.0 0.0) (10.0 0.0 0.0) (0.0 0.0 0.0)) nil)
((0.0 0.0 0.0) (10.0 0.0 0.0) (0.0 0.0 0.0))
|;
  (foreach x lst
    (if (not (member x result))
      (setq result (cons x result))
      ) ;_ end of if
    ) ;_ end of foreach
  (reverse result)
  ) ;_ end of defun
