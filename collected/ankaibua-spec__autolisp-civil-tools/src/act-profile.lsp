;;; Chainage/elevation table command.
;;; SPDX-License-Identifier: GPL-3.0-or-later

(defun ACT:profile-row (curve entity / point station)
  (setq point (ACT:entity-point-wcs entity))
  (if point (setq station (ACT:curve-station curve point)))
  (if station (list (car station) point (caddr station)))
)

(defun C:CTPROFILE (/ *error* document curve set origin-ucs rows row layer index insertion text)
  (defun *error* (message) (ACT:report-error message document))
  (setq document (ACT:undo-start))
  (setq curve (car (entsel "\nSelect alignment curve: ")))
  (cond
    ((not curve) (ACT:message "No alignment selected."))
    ((not (ACT:curve-p curve)) (ACT:message "Selected entity is not a supported curve."))
    ((not (setq set (ssget '((0 . "POINT"))))) (ACT:message "No POINT entities selected."))
    ((not (setq origin-ucs (getpoint "\nSelect table insertion point: "))) (ACT:message "Table placement was cancelled."))
    (T
      (setq rows nil)
      (foreach entity (ACT:selection-list set)
        (if (setq row (ACT:profile-row curve entity)) (setq rows (cons row rows)))
      )
      (setq rows (ACT:sort-by-first rows) layer (ACT:ensure-layer "ACT-PROFILE" 5) index 1)
      (ACT:make-text (ACT:ucs-to-wcs origin-ucs) "CHAINAGE,ELEVATION,X,Y,ABS_OFFSET" layer 2.5)
      (foreach row rows
        (setq insertion (list (car origin-ucs) (- (cadr origin-ucs) (* index 3.5)) (if (caddr origin-ucs) (caddr origin-ucs) 0.0))
              text (strcat (ACT:number (car row)) "," (ACT:number (caddr (cadr row))) "," (ACT:number (car (cadr row))) "," (ACT:number (cadr (cadr row))) "," (ACT:number (caddr row))))
        (ACT:make-text (ACT:ucs-to-wcs insertion) text layer 2.5)
        (setq index (1+ index))
      )
      (ACT:message (strcat "Created a chainage profile table with " (itoa (1- index)) " rows."))
    )
  )
  (ACT:undo-end document)
  (setq document nil)
  (princ)
)

(princ)
