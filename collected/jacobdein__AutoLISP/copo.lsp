; ----- COPO
; Copy an object (or entity) to the current layer
; including nested objects (e.g., objects in XREFs)
;
;   local variables
;     clay: current layer
;     en: selected entity
;     end: selected entity definition
(defun C:COPO (/ clay en end)
  ; select an entity to copy with the NCOPY command
  (command "._NCOPY" pause "" "D" "")
  ; get the current layer
  (setq clay (getvar "clayer"))
  ; change the copied entity to the current layer
  (setq en (entlast)
	end (entget en))
  (setq end (subst (cons 8 clay) (assoc 8 end) end ))
  (entmod end)
  (princ)
) ;defun