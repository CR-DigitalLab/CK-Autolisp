(vl-load-com)
((lambda (/ hive) 
   (setq hive (strcat "HKEY_CURRENT_USER\\" 
                      (vlax-product-key)
                      "\\Profiles\\"
                      (getvar "cprofile")
                      "\\Commands\\Plot"
              )
   )
   (vl-registry-delete hive "CPageSetupDlg Size")

   (setq hive (strcat "HKEY_CURRENT_USER\\" 
                      (vlax-product-key)
                      "\\"
                      (cond 
                        ((= (getvar "cconfiguration") "")
                         "nCAD"
                        )
                        (t (getvar "cconfiguration"))
                      )
                      "\\MechCtl"
              )
   )
   (vl-registry-delete hive "ObjectSearcher_FindReplaceDialog")

   (princ)
 ) 
)
