(defun _lispru-odbx (/)
                    ;|
*    функция возвращает интерфейс IAxDbDocument (для работы с файлами DWG без
* их открытия). Если интерфейс не поддерживается, возвращает nil. Проверено
* на ACAD 2002, 2004, 2005, 2006, 2007, 2008, 2010
*    Автор - Fatty aka Олег jr. Моего только адаптация под общую систему и
* переименование
*    Параметры вызова:
*	нет
*    Примеры вызова:
(_lispru-odbx)
|;
  (cond
    ((< (_lispru-acad-version) 15.06)
     (alert
       "ObjectDBX method not applicable\nin this AutoCAD version"
       ) ;_ end of KPBLC-MSG-ALERT
     nil
     )
    ((= (fix (_lispru-acad-version)) 15)
     (if (not (vl-registry-read
                "HKEY_CLASSES_ROOT\\ObjectDBX.AxDbDocument\\CLSID"
                ) ;_ end of vl-registry-read
              ) ;_ end of not
       (startapp "regsvr32.exe"
                 (strcat "/s \"" (findfile "axdb15.dll") "\"")
                 ) ;_ end of startapp
       ) ;_ end of if
     (vla-getinterfaceobject
       (vlax-get-acad-object)
       "ObjectDBX.AxDbDocument"
       ) ;_ end of vla-getinterfaceobject
     )
    (t
     (vla-getinterfaceobject
       (vlax-get-acad-object)
       (strcat "ObjectDBX.AxDbDocument." (itoa (fix (_lispru-acad-version))))
       ) ;_ end of vla-getinterfaceobject
     )
    ) ;_ end of cond
  ) ;_ end of defun
