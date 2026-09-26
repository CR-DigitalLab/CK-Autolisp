; ----- TWIST
; Rotate the drawing to the specified axis
; (creates a new UCS and rotates the PLAN view)
(defun C:TWIST ()
  (command "._ucs" pause pause "")
  (command "._plan" "C")
  (princ)
) ;defun