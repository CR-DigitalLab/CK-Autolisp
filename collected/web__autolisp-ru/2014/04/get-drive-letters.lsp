(defun get-drive-letters (/ lst)
  (vlax-for drive
                  (vlax-get
                    (vlax-get-or-create-object "Scripting.FileSystemObject")
                    'drives
                    ) ;_ end of vlax-get
    (setq lst (cons (vlax-get drive 'driveletter) lst))
    ) ;_ end of vlax-for
  (vl-sort lst '<)
  ) ;_ end of defun