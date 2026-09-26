(defun _kpblc-get-path-appdata-current-user (/)
                                            ;|
*    Получение пути установок, хранимых на локальной машине. (CurrUser)
|;
  (strcat (_kpblc-dir-path-and-splash
            (cond
              ((not (wcmatch (getenv "AppData") "*~*"))
               (getenv "AppData")
               )
              (t
               (_kpblc-dir-path-and-splash
                 (vl-registry-read
                   "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders"
                   "AppData"
                   ) ;_ end of vl-registry-read
                 ) ;_ end of _kpblc-dir-path-and-splash
               )
              ) ;_ end of cond
            ) ;_ end of _kpblc-dir-path-and-splash
          "kpblc"
          ) ;_ end of strcat
  ) ;_ end of defun