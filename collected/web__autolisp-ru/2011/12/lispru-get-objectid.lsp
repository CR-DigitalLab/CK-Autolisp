(defun _lispru-get-objectid (obj)
  (vlax-get-property obj
                     (strcat "ObjectID"
                             (if (> (vl-string-search "x64" (getvar "platform")) 0)
                               "32"
                               ""
                               ) ;_ end of if
                             ) ;_ end of strcat
                     ) ;_ end of vlax-get-property
  ) ;_ end of defun