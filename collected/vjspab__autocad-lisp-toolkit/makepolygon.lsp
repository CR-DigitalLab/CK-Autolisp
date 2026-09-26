;;; Command: MAKEPOLY
;;; Description: Rapidly creates closed polylines from intersecting lines.
;;; Automatically places the new polygons on a Pink, 0.20mm layer.

(defun c:MAKEPOLY ( / pt oldLayer targetLayer lastEnt newEnt)
  (vl-load-com)
  
  ;; --- USER SETTINGS ---
  (setq targetLayer "Plot_Boundaries") ; Layer for new polygons
  ;; ---------------------

  (setvar "CMDECHO" 0)

  ;; Save current active layer
  (setq oldLayer (getvar "CLAYER"))

  ;; Create or Modify the target layer: Pink (Color 6) and 0.20mm Lineweight, set as current
  (command "_.-layer" "_M" targetLayer "_C" "6" "" "_LW" "0.20" "" "")

  ;; Continuous loop: keeps asking for points until you press Enter or Spacebar
  (while (setq pt (getpoint "\nPick internal point to create polygon (or press Enter to exit): "))
    
    ;; Record the very last object drawn BEFORE we attempt to make a boundary
    (setq lastEnt (entlast)) 
    
    ;; Use AutoCAD's boundary engine to trace the intersecting lines into a Polyline
    (vl-catch-all-apply 
      'vl-cmdf 
      (list "_.-boundary" "_A" "_O" "_P" "" pt "")
    )
    
    ;; Record the very last object drawn AFTER the command
    (setq newEnt (entlast))
    
    ;; Compare the two to see if a new polygon was actually created
    (if (not (eq lastEnt newEnt))
      (princ "\nPolygon created successfully.")
      (princ "\nError: Boundary not found. Make sure the area is completely enclosed and visible on your screen.")
    )
  )

  ;; Restore original active layer so you can continue drafting normally
  (setvar "CLAYER" oldLayer)
  (setvar "CMDECHO" 1)
  
  (princ "\n--- MAKEPOLY command finished. ---")
  (princ)
)

(princ "\n--- Auto-Polygon LISP loaded (Pink, 0.2mm). ---")
(princ "\n--- Type 'MAKEPOLY' to execute the command. ---")
(princ)