;;; Elevation label helpers and command.
;;; SPDX-License-Identifier: GPL-3.0-or-later

(defun ACT:elevation-label-at (point / set index entity entity-point found)
  (setq set (ssget "X" (list '(0 . "TEXT") '(8 . "ACT-ELEV") (cons 410 (getvar "CTAB")))) index 0 found nil)
  (if set
    (repeat (sslength set)
      (setq entity (ssname set index) entity-point (ACT:entity-point-wcs entity))
      (if (and entity-point (equal entity-point point 0.000001))
        (setq found entity)
      )
      (setq index (1+ index))
    )
  )
  found
)

(defun ACT:write-elevation-label (point text layer / existing data)
  (setq existing (ACT:elevation-label-at point))
  (if existing
    (progn
      (setq data (entget existing))
      (setq data (subst (cons 1 text) (assoc 1 data) data))
      (entmod data)
      "Updated"
    )
    (if (ACT:make-text point text layer 2.5) "Added" "Failed")
  )
)

(defun C:CTELEV (/ *error* document entity point elevation layer text)
  (defun *error* (message) (ACT:report-error message document))
  (setq document (ACT:undo-start))
  (setq entity (car (entsel "\nSelect a POINT for elevation: ")))
  (cond
    ((not entity) (ACT:message "Nothing selected."))
    ((/= (ACT:entity-kind entity) "POINT") (ACT:message "Select a POINT entity."))
    ((not (setq elevation (getreal "\nElevation: "))) (ACT:message "Elevation was cancelled."))
    (T
      (setq point (ACT:entity-point-wcs entity) layer (ACT:ensure-layer "ACT-ELEV" 1) text (strcat "EL=" (ACT:number elevation)))
      (ACT:message (strcat (ACT:write-elevation-label point text layer) " " text "."))
    )
  )
  (ACT:undo-end document)
  (setq document nil)
  (princ)
)

(princ)
