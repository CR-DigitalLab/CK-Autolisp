(setq *lispru-sysvar-datfile*
       (strcat
         (_lispru-dir-create (strcat (vl-string-right-trim "\\" (getenv "APPDATA")) "\\LispRu\\Datas"))
         "\\sysvar.dat"
         ) ;_ end of strcat
      ) ;_ end of setq