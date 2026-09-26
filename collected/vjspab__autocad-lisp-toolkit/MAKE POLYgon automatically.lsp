;;; Command: MAKEPOLY
;;; Description: Rapidly creates closed polylines from intersecting lines.
;;; Automatically places the new polygons on a specific layer.

(defun c:MAKEPOLY ( / pt oldLayer targetLayer ent)
  (vl-load-com)
  
  ;; --- USER SETTINGS ---
  (setq targetLayer "Plot_Boundaries") ; The layer where new polygons will go
  ;; ---------------------

  (setvar "CMDECHO" 0)

  ;; Save current active layer
  (setq oldLayer (getvar "CLAYER"))

  ;; Create the target layer if it doesn't exist, and set it as current
  (if (not (tblsearch "LAYER" targetLayer))
    (command "_.-layer" "_M" targetLayer "_C" "4" "" "") ; "4" is Cyan color
    (setvar "CLAYER" targetLayer)
  )

  ;; Continuous loop: keeps asking for points until you press Enter or Spacebar
  (while (setq pt (getpoint "\nPick internal point to create polygon (or press Enter to exit): "))
    
    ;; Use AutoCAD's boundary engine to trace the intersecting lines
    ;; "_P" ensures it creates a Polyline (use "_R" if you prefer Regions)
    (vl-catch-all-apply 
      'vl-cmdf 
      (list "_.-boundary" "_A" "_O" "_P" "" pt "")
    )
    
    ;; Visual confirmation for the user
    (setq ent (entlast))
    (if ent
      (princ "\nPolygon created.")
      (princ "\nBoundary not found. Make sure the area is completely enclosed on screen.")
    )
  )

  ;; Restore original active layer
  (setvar "CLAYER" oldLayer)
  (setvar "CMDECHO" 1)
  
  (princ "\n--- MAKEPOLY command finished. ---")
  (princ)
)

(princ "\n--- Auto-Polygon LISP loaded. ---")
(princ "\n--- Type 'MAKEPOLY' to execute the command. ---")
(princ)