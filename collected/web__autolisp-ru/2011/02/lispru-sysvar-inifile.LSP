(setq *lispru-sysvar-inifile*
       (strcat
         (_lispru-dir-create (strcat (vl-string-right-trim "\\" (getenv "APPDATA")) "\\LispRu\\Datas"))
         "\\sysvar.ini"
         ) ;_ end of strcat
      ) ;_ end of setq