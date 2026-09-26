; ----- PJOIN
; Joins all connected objects to the selected entity
; resulting in a single connected polyline
;
;   local variables
;     selected: selected entity
;     props: selected entity properties list
;     enttype: entity type of selected entity
(defun C:PJOIN (/ selected props enttype)
  ; prompt user to select an entity
  (setq selected (ssget))
  ; get properties of the selected entity
  (setq props (entget (ssname selected 0)))
  ; check if the selected entity is a polyline
  (setq enttype (cdr (assoc 0 props)))
  (cond	((equal enttype "LWPOLYLINE")
	 ; use the PEDIT command to join all elements to the selected polyline
	 (command-s "._PEDIT" selected "Join" "all" "" "")
	)
	(t
	 ; use the PEDIT command to first convert the selected entity into a polyline
	 ; and then join all elements
	 (command-s "._PEDIT" selected "Y" "Join" "all" "" "")
	)
  )
  (princ)
) ;defun