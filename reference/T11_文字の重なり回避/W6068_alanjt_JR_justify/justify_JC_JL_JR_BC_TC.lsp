;;;justification macros (center, left, right)
;;;created by: alan thompson, 3.21.08
;;;updated by: alan thompson, 3.6.09 (fixed ssget to ignore objects on locked layers)
;;;updated by: alan thompson, 3.16.09 (added Top & Bottom Center)


;;; Justify Text "MIDDLE CENTER"
(defun c:JC (/ ss)
 (princ "\nSelect Text to Middle Center Justify: ")
 (if
   (setq ss (ssget ":L" '((0 . "*TEXT,ATTDEF"))))
    (vl-cmdf "_.justifytext" ss "" "_mc")
    (princ "\nMissed, try again.")
 ) ;_ if
 (princ)
) ;_ defun

;;; Justify Text "MIDDLE LEFT"
(defun c:JL (/ ss)
 (princ "\nSelect Text to Middle Left Justify: ")
 (if
   (setq ss (ssget ":L" '((0 . "*TEXT,ATTDEF"))))
    (vl-cmdf "_.justifytext" ss "" "_ml")
    (princ "\nMissed, try again.")
 ) ;_ if
 (princ)
) ;_ defun

;;; Justify Text "MIDDLE RIGHT"
(defun c:JR (/ ss)
 (princ "\nSelect Text to Middle Right Justify: ")
 (if
   (setq ss (ssget ":L" '((0 . "*TEXT,ATTDEF"))))
    (vl-cmdf "_.justifytext" ss "" "_mr")
    (princ "\nMissed, try again.")
 ) ;_ if
 (princ)
) ;_ defun


;;; Justify Text "BOTTOM CENTER"
(defun c:BC (/ ss)
 (princ "\nSelect Text to Bottom Center Justify: ")
 (if
   (setq ss (ssget ":L" '((0 . "*TEXT,ATTDEF"))))
    (vl-cmdf "_.justifytext" ss "" "_bc")
    (princ "\nMissed, try again.")
 ) ;_ if
 (princ)
) ;_ defun


;;; Justify Text "TOP CENTER"
(defun c:TC (/ ss)
 (princ "\nSelect Text to Top Center Justify: ")
 (if
   (setq ss (ssget ":L" '((0 . "*TEXT,ATTDEF"))))
    (vl-cmdf "_.justifytext" ss "" "_tc")
    (princ "\nMissed, try again.")
 ) ;_ if
 (princ)
) ;_ defun
