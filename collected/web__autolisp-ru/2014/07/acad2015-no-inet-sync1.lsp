(vl-load-com)

(defun no-online-sync (/ hive key)
  (if (getvar "onlinedocmode")
    (setvar "onlinedocmode" 0)
    ) ;_ end of if
  (if (vl-registry-read
        (setq hive (strcat "HKEY_CURRENT_USER\\"
                           (vlax-product-key)
                           "\\Variables"
                           ) ;_ end of strcat
              ) ;_ end of setq
        (setq key "ONLINESETTINGSSYNC")
        ) ;_ end of vl-registry-read
    (progn
      (vl-registry-delete hive key)
      (foreach subhive (vl-registry-descendents
                         (setq hive (strcat "HKEY_CURRENT_USER\\"
                                            (vlax-product-key)
                                            "\\WebUsers"
                                            ) ;_ end of strcat
                               ) ;_ end of setq
                         nil
                         ) ;_ end of vl-registry-descendents
        (if (vl-registry-read (strcat hive "\\" subhive) "OnlineSettingsSync")
          (vl-registry-write (strcat hive "\\" subhive) "OnlineSettingsSync" 0)
          ) ;_ end of if
        ) ;_ end of foreach
      ) ;_ end of progn
    ) ;_ end of if
  ) ;_ end of defun

(no-online-sync)