;;; ---------------------------------------------------------------------
;;;  OVDIFF-bgol.lsp
;;;  Command:  OVDF
;;;
;;;  PURPOSE
;;;  Detects pairs of numeric TEXT entities that sit at (or very near)
;;;  the same insertion point -- e.g. an "initial level" and a "final
;;;  level" stacked on top of each other on different layers in an
;;;  earthwork drawing -- and creates a new text at that location
;;;  showing the signed numeric difference between the pair, in a
;;;  distinguishing color.
;;;
;;;  USAGE
;;;    1. Load this file (APPLOAD or drag-drop onto the drawing window).
;;;    2. Type   OVDF   at the command line and press Enter.
;;;    3. Select the numeric TEXT entities to scan for overlaps, press
;;;       Enter to finish.
;;;    4. The routine groups entities by matching insertion point (within
;;;       a small tolerance) and computes the signed difference
;;;       (second - first) for every overlapping pair found.
;;;    5. A new text is created next to each pair showing the difference,
;;;       colored green (62=3) for positive and red (62=1) for negative,
;;;       on layer "BGOL-OVDF".
;;;
;;;  NOTES
;;;    - This is an original, independently written implementation.
;;;      It is INSPIRED by the general idea of overlapping-text
;;;      difference utilities common in earthwork/survey CAD drafting
;;;      workflows, but the code, command name and file name here are
;;;      new and are NOT copied from, nor identical to, any specific
;;;      third-party product.
;;;
;;;  ---------------------------------------------------------------------
;;;  Developed and shared for the CAD community by:  BGol Community
;;;  Community website:                              https://bgol.in/
;;;  License:  Open-source & free to use, modify, and share for all.
;;;            Provided "as is", without warranty of any kind.
;;;  ---------------------------------------------------------------------

(vl-load-com)

(setq *bgol-ovdf-tol* 0.01)  ; coincidence tolerance for grouping overlaps

(defun BGOL:OVDF-EnsureLayer (lname / )
  (if (not (tblsearch "LAYER" lname))
    (entmake (list '(0 . "LAYER")
                   '(100 . "AcDbSymbolTableRecord")
                   '(100 . "AcDbLayerTableRecord")
                   (cons 2 lname)
                   '(70 . 0)
                   '(62 . 6)          ; magenta (layer default; text itself is colored per-sign)
                   '(6 . "Continuous")))
  )
)

(defun BGOL:OVDF-MakeDiffText (pt diffval h lname / colorcode txt)
  (setq colorcode (if (>= diffval 0.0) 3 1))  ; green if >=0, red if negative
  (setq txt (rtos diffval 2 4))
  (entmake (list '(0 . "TEXT")
                 (cons 8 lname)
                 (cons 10 (list (+ (car pt) (* h 1.2)) (cadr pt) (caddr pt)))
                 (cons 40 h)
                 (cons 1 txt)
                 (cons 62 colorcode)))
)

(defun C:OVDF ( / lname ss n i ent obj pt val entries e1 e2 diff used
                  paired)
  (setq lname "BGOL-OVDF")
  (BGOL:OVDF-EnsureLayer lname)
  (princ "\nSelect numeric TEXT entities to scan for overlaps: ")
  (setq ss (ssget '((0 . "TEXT"))))
  (if ss
    (progn
      ;; build list of (point value height) entries
      (setq entries '())
      (setq i 0)
      (repeat (sslength ss)
        (setq ent (ssname ss i))
        (setq obj (vlax-ename->vla-object ent))
        (setq pt (vlax-get obj 'InsertionPoint))
        (setq val (atof (vlax-get obj 'TextString)))
        (setq entries (cons (list pt val (vlax-get obj 'Height)) entries))
        (setq i (1+ i))
      )
      ;; find overlapping pairs (points within tolerance), avoid re-pairing
      (setq used '())
      (setq n 0)
      (foreach e1 entries
        (if (not (member e1 used))
          (progn
            (setq paired nil)
            (foreach e2 entries
              (if (and (not paired) (not (eq e1 e2)) (not (member e2 used))
                       (< (distance (car e1) (car e2)) *bgol-ovdf-tol*))
                (progn
                  (setq diff (- (cadr e2) (cadr e1)))
                  (BGOL:OVDF-MakeDiffText (car e1) diff (caddr e1) lname)
                  (setq used (cons e1 (cons e2 used)))
                  (setq paired T)
                  (setq n (1+ n))
                )
              )
            )
          )
        )
      )
      (princ (strcat "\nOVDF: " (itoa n) " overlapping pair(s) found; difference text created on layer " lname "."))
    )
    (princ "\nNo text selected.")
  )
  (princ)
)

(princ "\nOVDIFF-bgol.lsp loaded. Type OVDF to compute differences between overlapping text pairs.")
(princ "\n  -- Free & open-source, courtesy of BGol Community (https://bgol.in/) --")
(princ)
