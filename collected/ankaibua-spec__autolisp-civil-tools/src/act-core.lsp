;;; Shared helpers. All functions are original for this project.
;;; SPDX-License-Identifier: GPL-3.0-or-later

(defun ACT:message (text)
  (prompt (strcat "\nACT: " text))
)

(defun ACT:number (value)
  (if (numberp value) (rtos value 2 3) "0.000")
)

(defun ACT:point-3d (point)
  (if (and (listp point) (numberp (car point)) (numberp (cadr point)))
    (list (car point) (cadr point) (if (numberp (caddr point)) (caddr point) 0.0))
  )
)

(defun ACT:point-text (point)
  (strcat "X=" (ACT:number (car point)) ", Y=" (ACT:number (cadr point)) ", Z=" (ACT:number (caddr point)))
)

(defun ACT:safe-call (function arguments / result)
  (setq result (vl-catch-all-apply function arguments))
  (if (vl-catch-all-error-p result) nil result)
)

(defun ACT:ensure-layer (name color / data)
  (if (not (tblsearch "LAYER" name))
    (entmake (list (cons 0 "LAYER") (cons 100 "AcDbSymbolTableRecord") (cons 100 "AcDbLayerTableRecord") (cons 2 name) (cons 70 0) (cons 62 color) (cons 6 "Continuous")))
  )
  name
)

(defun ACT:selection-list (set / index result)
  (setq index 0 result nil)
  (if set
    (repeat (sslength set)
      (setq result (cons (ssname set index) result))
      (setq index (1+ index))
    )
  )
  (reverse result)
)

(defun ACT:entity-kind (entity)
  (if entity (cdr (assoc 0 (entget entity))))
)

(defun ACT:entity-point-wcs (entity / data raw)
  (setq data (entget entity) raw (cdr (assoc 10 data)))
  (if (and raw (member (cdr (assoc 0 data)) '("POINT" "TEXT" "MTEXT")))
    (ACT:point-3d (ACT:safe-call 'trans (list raw entity 0)))
  )
)

(defun ACT:ucs-to-wcs (point)
  (ACT:point-3d (ACT:safe-call 'trans (list (ACT:point-3d point) 1 0)))
)

(defun ACT:make-point (point layer)
  (entmakex (list (cons 0 "POINT") (cons 8 layer) (cons 10 (ACT:point-3d point))))
)

(defun ACT:make-text (point text layer height)
  (entmakex
    (list
      (cons 0 "TEXT")
      (cons 8 layer)
      (cons 10 (ACT:point-3d point))
      (cons 40 height)
      (cons 1 text)
      (cons 7 (getvar "TEXTSTYLE"))
      (cons 50 0.0)
    )
  )
)

(defun ACT:undo-start (/ application document)
  (setq application (ACT:safe-call 'vlax-get-acad-object nil))
  (if application
    (setq document (ACT:safe-call 'vla-get-ActiveDocument (list application)))
  )
  (if document (ACT:safe-call 'vla-StartUndoMark (list document)))
  document
)

(defun ACT:undo-end (document)
  (if document (ACT:safe-call 'vla-EndUndoMark (list document)))
  nil
)

(defun ACT:cancelled-error-p (message)
  (or
    (not message)
    (= message "Function cancelled")
    (= message "quit / exit abort")
    (= message "console break")
  )
)

(defun ACT:report-error (message document)
  (ACT:undo-end document)
  (if (not (ACT:cancelled-error-p message))
    (ACT:message (strcat "Error: " message))
  )
  (princ)
)

(defun ACT:csv-quote (text / clean index character)
  (setq text (if text text "") clean "" index 1)
  (while (<= index (strlen text))
    (setq character (substr text index 1))
    (setq clean (strcat clean (if (= character "\"") "\"\"" character)))
    (setq index (1+ index))
  )
  (strcat "\"" clean "\"")
)

(defun ACT:csv-parse-line (line / index length character field row quoted)
  (setq index 1 length (strlen line) field "" row nil quoted nil)
  (while (<= index length)
    (setq character (substr line index 1))
    (cond
      ((= character "\"")
        (if (and quoted (< index length) (= (substr line (1+ index) 1) "\""))
          (setq field (strcat field "\"") index (+ index 2))
          (setq quoted (not quoted) index (1+ index))
        )
      )
      ((and (= character ",") (not quoted))
        (setq row (cons field row) field "" index (1+ index))
      )
      (T
        (setq field (strcat field character) index (1+ index))
      )
    )
  )
  (if quoted nil (reverse (cons field row)))
)

(defun ACT:trim (text)
  (vl-string-trim " \t\r\n" (if text text ""))
)

(defun ACT:header-index (name row / index found)
  (setq index 0 found nil)
  (while (and row (not found))
    (if (= (strcase (ACT:trim (car row))) (strcase name))
      (setq found index)
      (setq index (1+ index) row (cdr row))
    )
  )
  found
)

(defun ACT:nth-safe (index values)
  (if (and (numberp index) (>= index 0) (< index (length values)))
    (nth index values)
  )
)

(defun ACT:parse-number (text / clean result)
  (setq clean (ACT:trim text))
  (if (> (strlen clean) 0)
    (progn
      (setq result (vl-catch-all-apply 'distof (list clean 2)))
      (if (or (vl-catch-all-error-p result) (not (numberp result))) nil result)
    )
  )
)

(defun ACT:curve-p (entity)
  (and entity (numberp (ACT:safe-call 'vlax-curve-getEndParam (list entity))))
)

(defun ACT:curve-station (curve point / closest station)
  (setq closest (ACT:safe-call 'vlax-curve-getClosestPointTo (list curve point)))
  (if closest
    (setq station (ACT:safe-call 'vlax-curve-getDistAtPoint (list curve closest)))
  )
  (if (numberp station) (list station closest (distance point closest)))
)

(defun ACT:insert-by-first (item items)
  (cond
    ((not items) (list item))
    ((<= (car item) (caar items)) (cons item items))
    (T (cons (car items) (ACT:insert-by-first item (cdr items))))
  )
)

(defun ACT:sort-by-first (items / result)
  (setq result nil)
  (foreach item items (setq result (ACT:insert-by-first item result)))
  result
)

(defun ACT:clamp (value minimum maximum)
  (max minimum (min maximum value))
)

(defun ACT:safe-text (value)
  (if (= (type value) 'STR) value "")
)

(princ)
