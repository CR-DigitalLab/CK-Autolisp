(defun _lispru-objectidtoobject (doc id)
  (vlax-invoke-method doc
                      (strcat "ObjectIDToObject"
                              (if (> (vl-string-search "x64" (getvar "platform")) 0)
                                "32"
                                ""
                                ) ;_ end of if
                              ) ;_ end of strcat
                      id
                      ) ;_ end of vlax-invoke-method
  ) ;_ end of defun