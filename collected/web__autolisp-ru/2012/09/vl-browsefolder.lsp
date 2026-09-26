(defun vl-browsefolder (caption / shlobj folder fldobj outval)
                       ;|
http://www.autocad.ru/cgi-bin/f1/board.cgi?t=21054YY    
*    Без отображения файлов
*    Параметры вызова:
	caption		показываемый заголовок (пояснение) окна
(setq Folder (vlax-invoke-method ShlObj 'BrowseForFolder 0 "" 16384))
|;
  (setq shlobj (vla-getinterfaceobject (vlax-get-acad-object) "Shell.Application") ;_ end of vla-getInterfaceObject
        folder (vlax-invoke-method shlobj 'browseforfolder 0 caption 0)
        ) ;_ end of setq
  (vlax-release-object shlobj)
  (if folder
    (progn (setq fldobj (vlax-get-property folder 'self)
                 outval (vlax-get-property fldobj 'path)
                 ) ;_ end of setq
           (vlax-release-object folder)
           (vlax-release-object fldobj)
           ) ;_ end of progn
    ) ;_ end of if
  outval
  ) ;_ end of defun