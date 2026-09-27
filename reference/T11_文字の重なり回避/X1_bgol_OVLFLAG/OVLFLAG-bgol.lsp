;;; ---------------------------------------------------------------------
;;;  OVLFLAG-bgol.lsp
;;;  Command:  OVFX
;;;
;;;  PURPOSE
;;;  Scans TEXT (and MTEXT) entities in the current drawing (or a
;;;  user selection) and flags any pair whose insertion points are
;;;  coincident or nearly coincident within a small tolerance --
;;;  i.e. overlapping text that would render illegible when plotted.
;;;  Flagged text is recolored onto a dedicated layer so it stands
;;;  out for manual review/cleanup.
;;;
;;;  USAGE
;;;    1. Load this file (APPLOAD or drag-drop onto the drawing window).
;;;    2. Type   OVFX   at the command line and press Enter.
;;;    3. Select the text entities to check, or press Enter to scan
;;;       the whole drawing.
;;;    4. Enter the overlap tolerance distance (or accept the default).
;;;    5. Every text entity found overlapping another is moved onto
;;;       layer "BGOL-OVFX" and recolored cyan so it is easy to spot.
;;;
;;;  NOTES
;;;    - Overlap is detected purely by proximity of insertion points,
;;;      which is a practical approximation of "occupies the same
;;;      area" for typical single-line label text.
;;;    - This is an original, independently written implementation.
;;;      It is INSPIRED by the general idea of overlapping-text
;;;      detection utilities common in CAD/survey drafting workflows,
;;;      but the code, command name and file name here are new and are
;;;      NOT copied from, nor identical to, any specific third-party
;;;      product.
;;;
;;;  ---------------------------------------------------------------------
;;;  Developed and shared for the CAD community by:  BGol Community
;;;  Community website:                              https://bgol.in/
;;;  License:  Open-source & free to use, modify, and share for all.
;;;            Provided "as is", without warranty of any kind.
;;;  ---------------------------------------------------------------------

(vl-load-com)

(defun BGOL:OVFX-EnsureLayer (lname / )
  (if (not (tblsearch "LAYER" lname))
    (entmake (list '(0 . "LAYER")
                   '(100 . "AcDbSymbolTableRecord")
                   '(100 . "AcDbLayerTableRecord")
                   (cons 2 lname)
                   '(70 . 0)
                   '(62 . 4)          ; cyan
                   '(6 . "Continuous")))
  )
)

(defun BGOL:OVFX-GetTextSS (/ ss)
  (setq ss (ssget '((0 . "TEXT,MTEXT"))))
  (if (not ss) (setq ss (ssget "_X" '((0 . "TEXT,MTEXT")))))
  ss
)

(defun BGOL:OVFX-Flag (ent lname / edata)
  (setq edata (entget ent))
  (setq edata (subst (cons 8 lname) (assoc 8 edata) edata))
  (setq edata (subst (cons 62 4) (assoc 62 edata) edata))
  (entmod edata)
  (entupd ent)
)

(defun C:OVFX ( / ss n i j ei ej pi pj tol elist flagged cnt)
  (BGOL:OVFX-EnsureLayer "BGOL-OVFX")
  (setq ss (BGOL:OVFX-GetTextSS))
  (if ss
    (progn
      (setq tol (getreal "\nOverlap tolerance distance <0.05>: "))
      (if (not tol) (setq tol 0.05))
      (setq n (sslength ss))
      (setq elist '())
      (setq i 0)
      (while (< i n)
        (setq elist (append elist (list (ssname ss i))))
        (setq i (1+ i))
      )
      (setq flagged '())
      (setq cnt 0)
      (setq i 0)
      (while (< i n)
        (setq ei (nth i elist))
        (setq pi (cdr (assoc 10 (entget ei))))
        (setq j (1+ i))
        (while (< j n)
          (setq ej (nth j elist))
          (setq pj (cdr (assoc 10 (entget ej))))
          (if (and (<= (distance pi pj) tol)
                   (not (member ei flagged))
              )
            (progn
              (BGOL:OVFX-Flag ei "BGOL-OVFX")
              (setq flagged (append flagged (list ei)))
              (setq cnt (1+ cnt))
            )
          )
          (if (and (<= (distance pi pj) tol)
                   (not (member ej flagged))
              )
            (progn
              (BGOL:OVFX-Flag ej "BGOL-OVFX")
              (setq flagged (append flagged (list ej)))
              (setq cnt (1+ cnt))
            )
          )
          (setq j (1+ j))
        )
        (setq i (1+ i))
      )
      (princ (strcat "\nOVFX: " (itoa cnt) " overlapping text entity(ies) flagged on layer BGOL-OVFX."))
    )
    (princ "\nNo text entities found to check.")
  )
  (princ)
)

(princ "\nOVLFLAG-bgol.lsp loaded. Type OVFX to find and flag overlapping text.")
(princ "\n  -- Free & open-source, courtesy of BGol Community (https://bgol.in/) --")
(princ)
