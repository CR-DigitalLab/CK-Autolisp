;;; Coordinate labelling command.
;;; SPDX-License-Identifier: GPL-3.0-or-later

(defun C:CTCOORD (/ *error* document set index entity point number layer label created)
  (defun *error* (message) (ACT:report-error message document))
  (setq document (ACT:undo-start))
  (setq set (ssget '((0 . "POINT"))))
  (if (not set)
    (ACT:message "No POINT entities selected.")
    (progn
      (setq layer (ACT:ensure-layer "ACT-COORD" 3) index 0 number 1 created 0)
      (repeat (sslength set)
        (setq entity (ssname set index) point (ACT:entity-point-wcs entity))
        (if point
          (progn
            (setq label (strcat "P" (itoa number) " " (ACT:point-text point)))
            (if (ACT:make-text point label layer 2.5) (setq created (1+ created)))
            (setq number (1+ number))
          )
        )
        (setq index (1+ index))
      )
      (ACT:message (strcat "Created " (itoa created) " coordinate labels in WCS."))
    )
  )
  (ACT:undo-end document)
  (setq document nil)
  (princ)
)

(princ)
