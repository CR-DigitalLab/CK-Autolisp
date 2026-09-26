(vl-load-com)

;; Mathematical Point-in-Polygon Function (Ray-Casting Algorithm)
(defun PtInPoly (pt polyPts / i j c pti ptj dy dx crossX)
  (setq c nil j (1- (length polyPts)) i 0)
  (while (< i (length polyPts))
    (setq pti (nth i polyPts) ptj (nth j polyPts))
    (if (or (and (<= (cadr pti) (cadr pt)) (< (cadr pt) (cadr ptj)))
            (and (<= (cadr ptj) (cadr pt)) (< (cadr pt) (cadr pti))))
      (progn
        (setq dy (- (cadr ptj) (cadr pti)))
        (if (not (zerop dy))
          (progn
            (setq dx (- (car ptj) (car pti)))
            (setq crossX (+ (car pti) (* (/ (- (cadr pt) (cadr pti)) dy) dx)))
            (if (< (car pt) crossX)
              (setq c (not c))
            )
          )
        )
      )
    )
    (setq j i i (1+ i))
  )
  c
)

;; Main Command
(defun c:ExportPlotData ( / fn f ss i ent obj entType polyList textList minPt maxPt centerPt txtStr area pts foundText outData polyCenter polyX polyY)
  
  (setq fn (getfiled "Save Plot Data" "PlotData.csv" "csv" 1))
  (if (not fn) (exit))

  (princ "\nSelect Plots and the Plot Number Texts inside them: ")
  
  (if (setq ss (ssget '((0 . "LWPOLYLINE,POLYLINE,TEXT,MTEXT"))))
    (progn
      (setq i 0 polyList nil textList nil)
      
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (setq obj (vlax-ename->vla-object ent))
        (setq entType (cdr (assoc 0 (entget ent))))

        (cond
          ;; Gather Polygons - ALL CHECKS REMOVED. WE ACCEPT ALL POLYLINES.
          ((wcmatch entType "*POLYLINE")
             (setq polyList (cons obj polyList))
          )
          ;; Gather Text
          ((wcmatch entType "*TEXT")
           (vla-GetBoundingBox obj 'minPt 'maxPt)
           (setq minPt (vlax-safearray->list minPt))
           (setq maxPt (vlax-safearray->list maxPt))
           (setq centerPt (list (/ (+ (car minPt) (car maxPt)) 2.0) (/ (+ (cadr minPt) (cadr maxPt)) 2.0)))
           
           (setq txtStr (vla-get-TextString obj))
           (setq textList (cons (list txtStr centerPt) textList))
          )
        )
        (setq i (1+ i))
      )

      (setq outData nil)
      
      (foreach polyObj polyList
        ;; Safely grab the area (AutoCAD calculates this even if open)
        (setq area (vl-catch-all-apply 'vla-get-Area (list polyObj)))
        (if (vl-catch-all-error-p area)
            (setq area "0.000") ; Fallback if the shape is corrupted
            (setq area (rtos area 2 3))
        )
        
        ;; Calculate the Center Coordinates
        (vla-GetBoundingBox polyObj 'minPt 'maxPt)
        (setq minPt (vlax-safearray->list minPt))
        (setq maxPt (vlax-safearray->list maxPt))
        (setq polyCenter (list (/ (+ (car minPt) (car maxPt)) 2.0) (/ (+ (cadr minPt) (cadr maxPt)) 2.0)))
        
        (setq polyX (rtos (car polyCenter) 2 3))
        (setq polyY (rtos (cadr polyCenter) 2 3))
        
        ;; Extract Vertex coordinates
        (setq pts (mapcar 'cdr (vl-remove-if-not '(lambda (x) (= (car x) 10)) (entget (vlax-vla-object->ename polyObj)))))

        ;; SMART FIX: Virtually "Close" the points array for the mathematics if it's an open shape
        (if (> (distance (car pts) (last pts)) 0.0001)
          (setq pts (append pts (list (car pts))))
        )

        (setq foundText "UNNAMED_PLOT")
        
        ;; Test which text center falls within this polygon
        (foreach txtItem textList
          (if (PtInPoly (cadr txtItem) pts)
            (setq foundText (car txtItem))
          )
        )
        
        (setq outData (cons (list foundText area polyX polyY) outData))
      )

      (setq outData (vl-sort outData '(lambda (a b) (< (car a) (car b)))))

      (setq f (open fn "w"))
      (write-line "Plot Number,Area,Center X,Center Y" f)
      (foreach row outData
        (write-line (strcat (car row) "," (cadr row) "," (caddr row) "," (cadddr row)) f)
      )
      (close f)
      
      (princ (strcat "\nSuccess: Exported " (itoa (length outData)) " plots with coordinates to " fn))
    )
    (princ "\nCommand cancelled or no valid objects selected.")
  )
  (princ)
)

(princ "\nType 'ExportPlotData' to load and run the extraction command.")
(princ)