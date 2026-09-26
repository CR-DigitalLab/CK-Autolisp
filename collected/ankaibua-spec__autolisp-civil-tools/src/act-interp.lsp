;;; Linear elevation interpolation between two control points.
;;; SPDX-License-Identifier: GPL-3.0-or-later

(defun ACT:interpolated-elevation (start-point end-point target-point / dx dy denominator ratio)
  (setq dx (- (car end-point) (car start-point))
        dy (- (cadr end-point) (cadr start-point))
        denominator (+ (* dx dx) (* dy dy)))
  (if (> denominator 0.000000000001)
    (progn
      (setq ratio (/ (+ (* (- (car target-point) (car start-point)) dx)
                        (* (- (cadr target-point) (cadr start-point)) dy))
                     denominator))
      (setq ratio (ACT:clamp ratio 0.0 1.0))
      (+ (caddr start-point) (* ratio (- (caddr end-point) (caddr start-point))))
    )
  )
)

(defun C:CTINTERP (/ *error* document first second first-point second-point set layer count entity point elevation label)
  (defun *error* (message) (ACT:report-error message document))
  (setq document (ACT:undo-start))
  (setq first (car (entsel "\nSelect first control POINT: ")))
  (cond
    ((not first) (ACT:message "First control point was not selected."))
    ((/= (ACT:entity-kind first) "POINT") (ACT:message "First control must be a POINT entity."))
    ((not (setq second (car (entsel "\nSelect second control POINT: ")))) (ACT:message "Second control point was not selected."))
    ((/= (ACT:entity-kind second) "POINT") (ACT:message "Second control must be a POINT entity."))
    (T
      (setq first-point (ACT:entity-point-wcs first) second-point (ACT:entity-point-wcs second))
      (cond
        ((not (ACT:interpolated-elevation first-point second-point first-point))
          (ACT:message "Control points must have different plan coordinates."))
        ((not (setq set (ssget '((0 . "POINT"))))) (ACT:message "No target POINT entities selected."))
        (T
          (setq layer (ACT:ensure-layer "ACT-ELEV" 1) count 0)
          (foreach entity (ACT:selection-list set)
            (setq point (ACT:entity-point-wcs entity)
                  elevation (if point (ACT:interpolated-elevation first-point second-point point)))
            (if (numberp elevation)
              (progn
                (setq label (strcat "EL=" (ACT:number elevation)))
                (ACT:write-elevation-label point label layer)
                (setq count (1+ count))
              )
            )
          )
          (ACT:message (strcat "Interpolated " (itoa count) " elevation labels; values are clamped between controls."))
        )
      )
    )
  )
  (ACT:undo-end document)
  (setq document nil)
  (princ)
)

(princ)
