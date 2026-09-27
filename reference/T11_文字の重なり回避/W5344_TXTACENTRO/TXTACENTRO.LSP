(defun c:TXTACENTRO (/ ssPolis i poly ent obj center texts j txt txtObj entType)
  (vl-load-com)
  (princ "\nSeleccione las polilíneas cerradas: ")
  
  ;; Selecciona polilíneas cerradas
  (setq ssPolis (ssget '((0 . "LWPOLYLINE") (-4 . "&=") (70 . 1))))
  
  (if ssPolis
    (progn
      (setq i 0)
      (repeat (sslength ssPolis)
        (setq poly (ssname ssPolis i)
              obj  (vlax-ename->vla-object poly))
        
        ;; Calculamos el centroide real de la polilínea (más preciso que bounding box)
        ;; Creamos una región temporal para sacar el centroide exacto
        (setq center (vlax-get (car (vlax-invoke (vla-get-ModelSpace (vla-get-ActiveDocument (vlax-get-acad-object))) 'AddRegion (list obj))) 'Centroid))
        
        ;; Buscamos textos que estén "cerca" o dentro del área de la polilínea
        (vla-getboundingbox obj 'minPt 'maxPt)
        (setq texts (ssget "_W" (vlax-safearray->list minPt) 
                                (vlax-safearray->list maxPt) 
                                '((0 . "*TEXT"))))

        (if texts
          (progn
            (setq j 0)
            (repeat (sslength texts)
              (setq txt    (ssname texts j)
                    txtObj (vlax-ename->vla-object txt)
                    entType (cdr (assoc 0 (entget txt))))
              
              ;; Manejo de errores según tipo de texto
              (if (= entType "TEXT")
                (vla-put-Alignment txtObj acAlignmentMiddleCenter)
                (vla-put-AttachmentPoint txtObj acAttachmentPointMiddleCenter)
              )

              ;; Movemos al centroide (coordenadas X e Y)
              (vlax-put-property txtObj 
                (if (= entType "TEXT") 'TextAlignmentPoint 'InsertionPoint) 
                (vlax-3d-point (list (car center) (cadr center) 0.0))
              )
              (setq j (1+ j))
            )
          )
        )
        (setq i (1+ i))
      )
      (princ (strcat "\nListo. Se procesaron " (itoa i) " polígonos."))
    )
    (princ "\nNo se seleccionó ninguna polilínea cerrada válida.")
  )
  (princ)
)