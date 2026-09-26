(defun fun_find-font-file (dwg font / ext res)
                          ;|
*    Поиск файла шрифта.
*    Параметры вызова:
	dwg		vla-указатель на обрабатываемый документ либо путь к нему
	font	имя файла шрифта
*    Примеры вызова:
|;
  (cond
    ((not dwg)
     (setq res (fun_find-font-file (vla-get-activedocument (vlax-get-acad-object)) font))
     )
    ((= (type dwg) 'str)
     (setq ext (vl-filename-extension font))
     (cond
       ((and (= (type ext) 'str)
             (= (strcase ext) ".SHX")
             ) ;_ end of and
        (setq res (cond
                    ((findfile (strcat (vl-filename-base font) ext)))
                    ((findfile (strcat font ext)))
                    ((findfile (strcat (vl-string-right-trim "\\" (vl-filename-directory dwg))
                                       "\\"
                                       (vl-filename-base font)
                                       ext
                                       ) ;_ end of strcat
                               ) ;_ end of findfile
                     )
                    ((findfile (strcat (vl-string-right-trim "\\" (vl-filename-directory dwg))
                                       "\\"
                                       font
                                       ext
                                       ) ;_ end of strcat
                               ) ;_ end of findfile
                     )
                    ) ;_ end of cond
              ) ;_ end of setq
        )
       ((and (= (type ext) 'str)
             (= (strcase ext) ".TTF")
             ) ;_ end of and
        (setq res (findfile (strcat windows_fonts_placement "\\" (vl-filename-base font) ".ttf")))
        )
       (t
        (setq res (cond
                    ((fun_find-font-file dwg (strcat font ".shx")))
                    (t (fun_find-font-file dwg (strcat font ".ttf")))
                    ) ;_ end of cond
              ) ;_ end of setq
        )
       ) ;_ end of cond
     )
    ((and (= (type dwg) 'vla-object)
          (vlax-property-available-p dwg 'fullname)
          ) ;_ end of and
     (setq res (fun_find-font-file (vla-get-fullname dwg) font))
     )
    ) ;_ end of cond
  res
  ) ;_ end of defun
