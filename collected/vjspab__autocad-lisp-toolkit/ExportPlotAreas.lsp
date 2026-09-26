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
  
  ;; Prompt user to choose where to save the CSV
  (setq fn (getfiled "Save Plot Data" "PlotData.csv" "csv" 1))
  (if (not fn) (exit))

  (princ "\nSelect Plots (Closed Polylines) and the Plot Number Texts inside them: ")
  
  ;; Only allow selection of lines and text
  (if (setq ss (ssget '((0 . "LWPOLYLINE,POLYLINE,TEXT,MTEXT"))))
    (progn
      (setq i 0 polyList nil textList nil)
      
      ;; Separate selection into Polylines and Text lists
      (while (< i (sslength ss))
        (setq ent (ssname ss i))
        (setq obj (vlax-ename->vla-object ent))
        (setq entType (cdr (assoc 0 (entget ent))))

        (cond
          ;; Gather Polygons
          ((wcmatch entType "*POLYLINE")
           (if (= (vla-get-Closed obj) :vlax-true) ; Only keep it if it's closed
             (setq polyList (cons obj polyList))
           )
          )
          ;; Gather Text
          ((wcmatch entType "*TEXT")
           ;; Calculate center point of the text bounding box
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
      
      ;; Match Text to its enclosing Polygon and grab coordinates
      (foreach polyObj polyList
        ;; Get Area (Rounded to 3 decimal places)
        (setq area (rtos (vla-get-Area polyObj) 2 3)) 
        
        ;; Calculate the Center Coordinates of the Polygon for Export
        (vla-GetBoundingBox polyObj 'minPt 'maxPt)
        (setq minPt (vlax-safearray->list minPt))
        (setq maxPt (vlax-safearray->list maxPt))
        (setq polyCenter (list (/ (+ (car minPt) (car maxPt)) 2.0) (/ (+ (cadr minPt) (cadr maxPt)) 2.0)))
        
        ;; Format X and Y coordinates to 3 decimal places
        (setq polyX (rtos (car polyCenter) 2 3))
        (setq polyY (rtos (cadr polyCenter) 2 3))
        
        ;; Extract Vertex coordinates of the Polyline for the inside/outside test
        (setq pts (mapcar 'cdr (vl-remove-if-not '(lambda (x) (= (car x) 10)) (entget (vlax-vla-object->ename polyObj)))))

        (setq foundText "UNNAMED_PLOT")
        
        ;; Test which text center falls within this polygon
        (foreach txtItem textList
          (if (PtInPoly (cadr txtItem) pts)
            (setq foundText (car txtItem))
          )
        )
        
        ;; Compile list with the new coordinate data
        (setq outData (cons (list foundText area polyX polyY) outData))
      )

      ;; Sort data alphabetically/numerically by Plot Number
      (setq outData (vl-sort outData '(lambda (a b) (< (car a) (car b)))))

      ;; Write to the chosen CSV file
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