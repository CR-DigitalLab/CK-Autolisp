; ------------------------------------------------------------------------- ;
; 2025 by kojacek                                                           ;
;                                                                           ;
(defun C:T-UNFOLD (/ %s %c %l)
  (prompt "\nRozmieść nakładające się teksty...")
  (cd:SYS_UndoBegin)
  (setq %c (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)
  (while
    (setq %s (ssget "_:L" '((0 . "TEXT"))))
    (progn
      (setq %l (entlast))
      (vl-cmdf "_TXT2MTXT" %s "")
      (if
        (/= %l (entlast))
        (vl-cmdf "_.EXPLODE" (entlast))
      )
    )
  )
  (setvar "CMDECHO" %c)
  (cd:SYS_UndoEnd)
  (princ)
)
; ------------------------------------------------------------------------- ;
