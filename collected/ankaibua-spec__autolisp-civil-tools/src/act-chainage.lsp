;;; Chainage and absolute-offset labels along a curve.
;;; SPDX-License-Identifier: GPL-3.0-or-later

(defun C:CTCHAINAGE (/ *error* document curve set layer created entity point station label)
  (defun *error* (message) (ACT:report-error message document))
  (setq document (ACT:undo-start))
  (setq curve (car (entsel "\nSelect alignment curve: ")))
  (cond
    ((not curve) (ACT:message "No alignment selected."))
    ((not (ACT:curve-p curve)) (ACT:message "Selected entity is not a supported curve."))
    ((not (setq set (ssget '((0 . "POINT"))))) (ACT:message "No POINT entities selected."))
    (T
      (setq layer (ACT:ensure-layer "ACT-CHAINAGE" 4) created 0)
      (foreach entity (ACT:selection-list set)
        (setq point (ACT:entity-point-wcs entity) station (if point (ACT:curve-station curve point)))
        (if station
          (progn
            (setq label (strcat "CH=" (ACT:number (car station)) " OFF=" (ACT:number (caddr station))))
            (if (ACT:make-text point label layer 2.5) (setq created (1+ created)))
          )
        )
      )
      (ACT:message (strcat "Created " (itoa created) " chainage labels; offsets are absolute."))
    )
  )
  (ACT:undo-end document)
  (setq document nil)
  (princ)
)

(princ)
