(vl-load-com)

(defun c:CopyClosedPolys ( / ss i ent obj newObj layerName oldCmd)
  ;; Save current command echo setting and turn it off for cleaner execution
  (setq oldCmd (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)

  ;; Define the new layer name
  (setq layerName "Closed_Polygons_Copied")

  ;; Create the layer, set TrueColor (RGB: 69, 84, 165), and set Lineweight to 0.09mm
  (command "_.-LAYER" 
           "_Make" layerName 
           "_Color" "_TrueColor" "69,84,165" "" 
           "_LWeight" "0.09" "" 
           "")

  ;; Select all closed LWPOLYLINEs in the drawing
  ;; Group code 70 bit 1 means "closed"
  (if (setq ss (ssget "_X" '((0 . "LWPOLYLINE") (-4 . "&") (70 . 1))))
    (progn
      (setq i 0)
      ;; Iterate through the selection set
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (setq obj (vlax-ename->vla-object ent))
        
        ;; Copy the object
        (setq newObj (vla-copy obj))
        
        ;; Move the copied object to the new layer
        (vla-put-layer newObj layerName)
        
        (setq i (1+ i))
      )
      (princ (strcat "\nSuccess: " (itoa (sslength ss)) " closed polygons were copied to the '" layerName "' layer."))
    )
    (princ "\nNotice: No closed polygons were found in the drawing.")
  )

  ;; Restore command echo
  (setvar "CMDECHO" oldCmd)
  (princ)
)

;; Print a load message to the command line
(princ "\nType 'CopyClosedPolys' to run the command.")
(princ)