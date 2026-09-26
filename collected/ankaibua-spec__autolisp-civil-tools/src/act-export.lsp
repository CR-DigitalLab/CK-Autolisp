;;; WCS CSV export command.
;;; SPDX-License-Identifier: GPL-3.0-or-later

(defun ACT:entity-note (entity / data)
  (setq data (entget entity))
  (if (= (cdr (assoc 0 data)) "TEXT")
    (ACT:safe-text (cdr (assoc 1 data)))
    ""
  )
)

(defun C:CTEXPORT (/ *error* document set file handle entities entity point kind index rows)
  (defun *error* (message)
    (if handle (progn (close handle) (setq handle nil)))
    (ACT:report-error message document)
  )
  (setq document (ACT:undo-start))
  (setq set (ssget '((0 . "POINT,TEXT"))))
  (cond
    ((not set) (ACT:message "No POINT or TEXT entities selected."))
    ((not (setq file (getfiled "Export ACT CSV (WCS)" "act-points.csv" "csv" 1))) (ACT:message "Export was cancelled."))
    ((not (setq handle (open file "w"))) (ACT:message "Unable to write the selected file."))
    (T
      (write-line "id,type,x,y,z,note" handle)
      (setq entities (ACT:selection-list set) index 1 rows 0)
      (foreach entity entities
        (setq point (ACT:entity-point-wcs entity) kind (ACT:entity-kind entity))
        (if point
          (progn
            (write-line (strcat (itoa index) "," kind "," (ACT:number (car point)) "," (ACT:number (cadr point)) "," (ACT:number (caddr point)) "," (ACT:csv-quote (ACT:entity-note entity))) handle)
            (setq index (1+ index) rows (1+ rows))
          )
        )
      )
      (close handle)
      (setq handle nil)
      (ACT:message (strcat "Exported " (itoa rows) " WCS rows to " file "."))
    )
  )
  (ACT:undo-end document)
  (setq document nil)
  (princ)
)

(princ)
