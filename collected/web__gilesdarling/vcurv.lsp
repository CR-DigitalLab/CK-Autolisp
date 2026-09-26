; Global Variables:
; =================
; vcurv_startgrad = start gradient (in %)
; vcurv_endgrad = end gradient (in %)
; vcurv_fromrad = radius at start of range
; vcurv_torad = radius at end of range
; vcurv_radstep = radius step size within range
; vcurv_korrad = "k" if K value entered, "r" if radius value entered
; vcurv_hozstep = max horizontal step size for drawing smoother curve
; vcurv_vertexag = vertical exaggeration factor
; vcurv_showtps = "yes" show TP dumbells, "no" don't
; vcurv_showmaxmin = "yes" show maximum or minimum markers, "no" don't
; vcurv_showtext = "yes" show curve parameters as text next to curve, "no" don't
; vcurv_vertoffset = vertical offset for insertion point between multiple curves
; vcurv_blocknum = number of last vertical curve block created (starts at 1000 so always 4+ digits)
; vcurv_creatingblock = flag: T = part way through creating block, nil = not creating block

; =======================================================================================================

; VCURV_ERRORMSG, VCURV_ATSTART and VCURV_ATEND
; =============================================

; Description:
; ============
; Handle error messages, set-up and restore point to error message handler, and begin/end UNDO loop

; Global Variables:
; =================
; vcurv_olderr = pointer to old error message handler

; Internal Variables:
; ===================
; ve_t1 = error message passed to error message handler
; ve_o1 = old value of CMDECHO in chainage_errormsg
; vs_o1 = old value of CMDECHO in chainage_atstart
; va_o1 = old value of CMDECHO in chainage_atend

(defun vcurv_errormsg (ve_t1 / ve_o1)

; restore pointer to old error message handler and display error message
 (setq *error* vcurv_olderr)
 (setq vcurv_olderr nil)
 (princ (strcat "\nCommand stopped due to error: " ve_t1))

; if part way through creating a block: finish creating block otherwise subsequent
; new drawing objects will be added to block being created rather than to drawing
 (if (= vcurv_creatingblock T)
  (progn
   (entmake (list (cons 0 "ENDBLK") (cons 100 "AcDbEntity") (cons 8 "0") (cons 100 "AcDbBlockEnd")))
   (setq vcurv_creatingblock nil)
  )
 )

; end UNDO group command
 (setq ve_o1 (getvar "CMDECHO"))
 (setvar "CMDECHO" 0)
 (command "UNDO" "E")
 (setvar "CMDECHO" ve_o1)
 (princ)
)

(defun vcurv_atstart ( / vs_o1)

; set error message handler pointer to new error message handler
 (setq vcurv_olderr *error*)
 (setq *error* vcurv_errormsg)

; set flag to say not part way through creating a block
 (setq vcurv_creatingblock nil)

; begin UNDO group command
 (setq vs_o1 (getvar "CMDECHO"))
 (setvar "CMDECHO" 0)
 (command "UNDO" "BE")
 (setvar "CMDECHO" vs_o1)
)

(defun vcurv_atend ( / va_o1)

; end UNDO group command
 (setq va_o1 (getvar "CMDECHO"))
 (setvar "CMDECHO" 0)
 (command "UNDO" "E")
 (setvar "CMDECHO" va_o1)

; restore pointer to old error message handler
 (setq *error* vcurv_olderr)
 (setq vcurv_olderr nil)
)

; =======================================================================================================

; VCURV_GETGLOBALVALUE
; ====================

; Description:
; ============
; Asks user for a value, using global value if available as default
; Inputs: text, global variable value, default value
; Output: value

; Internal Variables:
; ===================
; vv_t1 = text to display when asking for value
; vv_g1 = value of global variable (nil if variable not defined yet)
; vv_d1 = default value if global variable is nil and user doesn't enter a value
; vv_v1 = value returned from function

(defun vcurv_getglobalvalue (vv_t1 vv_g1 vv_d1 / vv_v1)

; append default value (if global variable is nil) or global value to question text
 (setq vv_t1 (strcat "\n" vv_t1 ": <"))
 (if (= vv_g1 nil)
  (setq vv_t1 (strcat vv_t1 (rtos vv_d1 2 3)))
  (setq vv_t1 (strcat vv_t1 (rtos vv_g1 2 3)))
 )
 (setq vv_t1 (strcat vv_t1 "> "))

; ask user for value
 (setq vv_v1 (getreal vv_t1))

; if user doesn't enter a value, use global variable value (if defined) or default value
 (if (= vv_v1 nil)
  (if (= vv_g1 nil)
   (setq vv_v1 vv_d1)
   (setq vv_v1 vv_g1)
  )
 )

; set output value to itself, so that this is the output from this function
 (setq vv_v1 vv_v1)
)

; =======================================================================================================

; VCURV_GETGLOBALOPTION
; =====================

; Description:
; ============
; Asks user to select from options, using global value if available as default
; Inputs: text, global variable value, default value
; Output: value

; Internal Variables:
; ===================
; vo_t1 = text to display when asking for value
; vo_g1 = value of global variable (nil if variable not defined yet)
; vo_d1 = default value if global variable is nil and user doesn't enter a value
; vo_v1 = value returned from function

(defun vcurv_getglobaloption (vo_t1 vo_g1 vo_d1 / vo_v1)

; append default value (if global variable is nil) or global value to question text
 (setq vo_t1 (strcat "\n" vo_t1 ": <"))
 (if (= vo_g1 nil)
  (setq vo_t1 (strcat vo_t1 vo_d1))
  (setq vo_t1 (strcat vo_t1 vo_g1))
 )
 (setq vo_t1 (strcat vo_t1 "> "))

; ask user for option (allow user to enter nothing)
 (initget 0 "yes no")
 (setq vo_v1 (getkword vo_t1))

; if user doesn't enter an option, use global variable value (if defined) or default value
 (if (= vo_v1 nil)
  (if (= vo_g1 nil)
   (setq vo_v1 vo_d1)
   (setq vo_v1 vo_g1)
  )
 )

; set output value to itself, so that this is the output from this function
 (setq vo_v1 vo_v1)
)

; =======================================================================================================

; VCURV_GETGRADIENT
; =================

; Description:
; ============
; Asks user either to enter value for vertical curve's start or end gradient
; or to select reference object
; Inputs: flag: T = asking for start gradient, nil = asking for end gradient
; Output: gradient value (in %) or list of points defining gradient line
;         or nil if nothing selected/entered or error occurred

; Internal Variables:
; ===================
; vt_f1 = input flag: T = start gradient, nil = end gradient
; vt_v1 = value within question text if user enters nothing
; vt_t1 = question text
; vt_l1 = output gradient or list of points defining gradient line (or nil if nothing selected/entered)
; vt_d1 = entity data for object selected
; vt_p1 = selection point on object selected
; vt_d2 = entity data type (LINE or POLYLINE)
; vt_r1 = half size of pick box in drawing units
; vt_x1, vt_y1 = x,y coordinates of point vt_p1
; vt_c1 = count through polyline entity data
; vt_x2, vt_y2 = x,y coordinates at start of polyline segment
; vt_b1 = polyline segment bulge factor (= 0.0 for line segments)
; vt_i1 = individual item in polyline entity data
; vt_n1 = code number for item vt_i1
; vt_p2 = number or point for item vt_i1
; vt_x3, vt_y3 = x,y coordinates at end of polyline segment
; vt_m1 = polyline segment length squared, then length
; vt_m2 = fraction along polyline segment (0 = at start, 1 = at end) then offset

(defun vcurv_getgradient (vt_f1 / vt_v1 vt_t1 vt_l1 vt_d1 vt_p1 vt_d2 vt_r1 vt_x1 vt_y1 vt_c1 vt_x2 vt_y2 vt_b1
                                  vt_i1 vt_n1 vt_p2 vt_x3 vt_y3 vt_m1 vt_m2)

; get value to show in question text, value to be used if user enters nothing
 (if (= vt_f1 T)
  (if (= vcurv_startgrad nil)
   (setq vt_v1 2.5)
   (setq vt_v1 vcurv_startgrad)
  )
  (if (= vcurv_endgrad nil)
   (setq vt_v1 -2.5)
   (setq vt_v1 vcurv_endgrad)
  )
 )

; create string asking user for input and ask user for gradient or reference object
 (setq vt_t1 (strcat "\nEnter " (if (= vt_f1 T) "START" "END") " gradient <"
             (rtos vt_v1 2 3) ">/Reference:"))
 (initget 0 "reference")
 (setq vt_l1 (getreal vt_t1))

; if user entered nothing, use default value
 (if (= vt_l1 nil)
  (setq vt_l1 vt_v1)

; if user entered "reference" ask user to select line or polyline line segment
  (if (= vt_l1 "reference")
   (progn
    (setq vt_l1 (entsel "\nSelect line or 2D polyline line segment: "))

; if user entered nothing, end program
    (if (= vt_l1 nil)
     (princ "\nNo object selected. Command terminating")

; if user has selected an object get object data, and selection point
     (progn
      (setq vt_d1 (entget (car vt_l1)) vt_p1 (cadr vt_l1))

; get type of object
      (setq vt_d2 (cdr (assoc 0 vt_d1)))

; if object is a line, ouput its end points
      (if (= vt_d2 "LINE")
       (setq vt_l1 (list (cdr (assoc 10 vt_d1)) (cdr (assoc 11 vt_d1))))

; if object is a polyline
       (if (= vt_d2 "LWPOLYLINE")
        (progn

; by default, set output to nothing until find which segment is under the pick box
         (setq vt_l1 nil)

; calculate size of pick box in drawing units
; (from centre to corner: 1.4142 = roughly square root of 2)
         (setq vt_r1 (/ (* 1.4142 (getvar "PICKBOX") (getvar "VIEWSIZE"))
                        (cadr (getvar "SCREENSIZE"))))

; get x and y coordinates of selection point
         (setq vt_x1 (car vt_p1) vt_y1 (cadr vt_p1))

; go through polyline's data item by item
; starting with no segment point defined, and segment line default
         (setq vt_c1 0 vt_x2 nil vt_y2 nil vt_b1 0.0)
         (while (< vt_c1 (length vt_d1))

; get each data item, its number code and data section
          (setq vt_i1 (nth vt_c1 vt_d1))
          (setq vt_n1 (car vt_i1) vt_p2 (cdr vt_i1))

; found the bulge factor for current segment (= 0 for a line, <> 0 for an arc)
          (if (= vt_n1 42)
           (setq vt_b1 vt_p2)
          )

; found a point
          (if (= vt_n1 10)

; if the first point store it
           (if (= vt_x2 nil)
            (setq vt_x2 (car vt_p2) vt_y2 (cadr vt_p2))

; if not first point check if segment is under selection point
            (progn
             (setq vt_x3 (car vt_p2) vt_y3 (cadr vt_p2))

; only check line segments
             (if (= vt_b1 0.0)
              (progn

; calculate fraction along segment (in two steps to avoid divide by zero errors)
               (setq vt_m1 (+ (* (- vt_x3 vt_x2) (- vt_x3 vt_x2))
                              (* (- vt_y3 vt_y2) (- vt_y3 vt_y2))))
               (if (/= vt_m1 0.0)
                (progn
                 (setq vt_m2 (/ (+ (* (- vt_x1 vt_x2) (- vt_x3 vt_x2))
                                   (* (- vt_y1 vt_y2) (- vt_y3 vt_y2))) vt_m1))

; if within extents of segment (assume 0.001 rounding error)
                 (if (and (>= vt_m2 -0.001) (<= vt_m2 1.001))
                  (progn

; make vt_m1 = segment line length (necessary for calculating offset)
                   (setq vt_m1 (sqrt vt_m1))

; calculate offset from selection point to segment line
                   (if (/= vt_x2 vt_x3)
                    (setq vt_m2 (* vt_m1 (/ (+ (- vt_y2 vt_y1) (* vt_m2 (- vt_y3 vt_y2)))
                                            (- vt_x3 vt_x2))))
                    (if (/= vt_y3 vt_y2)
                     (setq vt_m2 (* vt_m1 (/ (+ (- vt_x2 vt_x1) (* vt_m2 (- vt_x3 vt_x2)))
                                             (- vt_y2 vt_y3))))

; if line has no length force this segment to fail
                     (setq vt_m2 vt_r1)
                    )
                   )

; if line is under selection point store its start and end points
; and raise counter to quit while loop
                   (if (< (abs vt_m2) vt_r1)
                    (setq vt_l1 (list (list vt_x2 vt_y2 0.0) (list vt_x3 vt_y3 0.0))
                          vt_c1 (length vt_d1))
                   )
                  )
                 )
                )
               )
              )
             )

; look at next segment (its start point is current segment's end point)
               (setq vt_x2 vt_x3 vt_y2 vt_y3)
            )
           )
          )

; increase counter to look at next data item in polyline's data list
          (setq vt_c1 (1+ vt_c1))
         )

; if went through polyline data, but didn't find line (maybe user clicked on arc segment)
         (if (= vt_l1 nil)
          (princ "\nCould not find line segment at pick location. Command terminating")
         )
        )

; user selected an object which is neither a line nor a polyline
        (progn
         (setq vt_l1 nil)
         (princ "\nObject is not a line or 2D polyline. Command terminating")
        )
       )
      )
     )
    )
   )
  )
 )

; if a line segment has been found
 (if (and (/= vt_l1 nil) (= (listp vt_l1) T))
  (progn

; get the points at each end of line
   (setq vt_p1 (car vt_l1) vt_p2 (cadr vt_l1))

; swap ends if start x-coordinate is higher than end x-coordiante
   (if (> (car vt_p1) (car vt_p2))
    (setq vt_l1 (list vt_p2 vt_p1))

; cannot use line if it is vertical
    (if (= (car vt_p1) (car vt_p2))
     (progn
      (princ "\nCannot calculate gradient from vertical line. Command terminating")
      (setq vt_l1 nil)
     )
    )
   )
  )
 )

; return list or gradient value
 (setq vt_l1 vt_l1)                
)

; =======================================================================================================

; VCURV_CALCGRADIENT
; ==================

; Description:
; ============
; Calculates gradient for reference line (pair of points) defining gradient

; Internal Variables:
; ===================
; vc_a1 = input: pair of points defining line
; vc_p1 = first point in vc_a1
; vc_p2 = second point in vc_a1
; vc_x1, vc_y1 = x,y coordinates of vc_p1
; vc_x2, vc_y2 = x,y coordinates of vc_p2
; vc_g1 = output: gradient (in %) or nil if unavailable

(defun vcurv_calcgradient (vc_a1 / vc_p1 vc_p2 vc_x1 vc_y1 vc_x2 vc_y2 vc_g1)

; get points at each end of line 
 (setq vc_p1 (car vc_a1) vc_p2 (cadr vc_a1))

; get x,y coordinates for each point
 (setq vc_x1 (car vc_p1) vc_y1 (cadr vc_p1) vc_x2 (car vc_p2) vc_y2 (cadr vc_p2))

; if line is vertical (i.e. x coordinates same at each end) then return error
 (if (= vc_x1 vc_x2)
  (setq vc_g1 nil)

; otherwise calculate gradient (in %)
  (setq vc_g1 (* 100.0 (/ (- vc_y2 vc_y1) (- vc_x2 vc_x1))))
 )

; return gradient value (or nil if unavailable)
 (setq vc_g1 vc_g1)
)

; =======================================================================================================

; VCURV_GETRADII
; ==============

; Description:
; ============
; Asks user for curve radius, or range of radii, entered as radius or K values
; Output: list of k/radius flag and radius value
;         or list of k/radius flag and start/end radii and radius step size within range

; Internal Variables:
; ===================
; vr_k1 = flag: T = use k value, nil = use radius
; vr_v1 = default radius and step values
; vr_r1 = radius or start radius
; vr_t1 = question text
; vr_r2 = end radius
; vr_r3 = radius step size

(defun vcurv_getradii ( / vr_k1 vr_v1 vr_r1 vr_t1 vr_r2 vr_r3)

; determine if user initially enters K value or radius
 (if (= vcurv_korrad nil)
  (setq vr_k1 "r")
  (setq vr_k1 vcurv_korrad)
 )

; get start radius value to show in question text, used if user enters nothing
 (if (= vcurv_fromrad nil)
  (setq vr_v1 2000.0)
  (setq vr_v1 vcurv_fromrad)
 )

; create string asking user for initial K value or radius, plus options 
 (if (= vr_k1 "k")
  (progn
   (setq vr_t1 (strcat "\nEnter curve K value <" (rtos (/ vr_v1 100.0) 2 3)
                       ">/Radius/Multiple: "))
   (initget 0 "radius multiple")
  )
  (progn
   (setq vr_t1 (strcat "\nEnter curve radius <" (rtos vr_v1 2 3)
                       ">/Kvalue/Multiple: "))
   (initget 0 "kvalue multiple")
  )
 )

; ask user to enter value, or select options
 (setq vr_r1 (getreal vr_t1))

; if user entered nothing, use default value
 (if (= vr_r1 nil)
  (setq vr_r1 vr_v1)

; if user entered K value convert it to radius
  (if (and (= vr_k1 "k") (= (numberp vr_r1) T))
   (setq vr_r1 (* vr_r1 100.0))

; if user entered K value or radius options
   (if (or (= vr_r1 "kvalue") (= vr_r1 "radius"))
    (progn

; create string asking user for initial K value or radius, plus multiple option only
; and set K value/radius flag accordingly
     (if (= vr_r1 "kvalue")
      (setq vr_t1 (strcat "\nEnter curve K value <" (rtos (/ vr_v1 100.0) 2 3)
                          ">/Multiple: ") vr_k1 "k")
      (setq vr_t1 (strcat "\nEnter curve radius <" (rtos vr_v1 2 3)
                          ">/Multiple: ") vr_k1 "r")
     )
     (initget 0 "multiple")

; ask user to enter value, or select multiple option
     (setq vr_r1 (getreal vr_t1))

; if user entered nothing, use default value
     (if (= vr_r1 nil)
      (setq vr_r1 vr_v1)

; if user entered K value convert it to radius
      (if (and (= vr_k1 "k") (= (numberp vr_r1) T))
       (setq vr_r1 (* vr_r1 100.0))
      )
     )
    )
   )
  )
 )

; user wants to enter range of multiple radius or K values
 (if (= vr_r1 "multiple")
  (progn

; create string asking user for start K value or radius, no options this time
   (if (= vr_k1 "k")
    (setq vr_t1 (strcat "\nEnter start K value <" (rtos (/ vr_v1 100.0) 2 3) ">: "))
    (setq vr_t1 (strcat "\nEnter start radius <" (rtos vr_v1 2 3) ">: "))
   )

; ask user to enter value
   (setq vr_r1 (getreal vr_t1))

; if user entered nothing, use default value
   (if (= vr_r1 nil)
    (setq vr_r1 vr_v1)

; if user entered K value convert it to radius
    (if (= vr_k1 "k")
     (setq vr_r1 (* vr_r1 100.0))
    )
   )

; get end radius value to show in question text, used if user enters nothing
   (if (= vcurv_torad nil)
    (setq vr_v1 1000.0)
    (setq vr_v1 vcurv_torad)
   )

; create string asking user for end K value or radius
   (if (= vr_k1 "k")
    (setq vr_t1 (strcat "\nEnter end K value <" (rtos (/ vr_v1 100.0) 2 3) ">: "))
    (setq vr_t1 (strcat "\nEnter end radius <" (rtos vr_v1 2 3) ">: "))
   )

; ask user to enter value
   (setq vr_r2 (getreal vr_t1))

; if user entered nothing, use default value
   (if (= vr_r2 nil)
    (setq vr_r2 vr_v1)

; if user entered K value convert it to radius
    (if (= vr_k1 "k")
     (setq vr_r2 (* vr_r2 100.0))
    )
   )

; get radius step size value to show in question text, used if user enters nothing
   (if (= vcurv_radstep nil)
    (setq vr_v1 100.0)
    (setq vr_v1 vcurv_radstep)
   )

; create string asking user for K value or radius step size
   (if (= vr_k1 "k")
    (setq vr_t1 (strcat "\nEnter K value step size <" (rtos (/ vr_v1 100.0) 2 3) ">: "))
    (setq vr_t1 (strcat "\nEnter radius step size <" (rtos vr_v1 2 3) ">: "))
   )

; ask user to enter value
   (setq vr_r3 (getreal vr_t1))

; if user entered nothing, use default value
   (if (= vr_r3 nil)
    (setq vr_r3 vr_v1)

; if user entered K value convert it to radius
    (if (= vr_k1 "k")
     (setq vr_r3 (* vr_r3 100.0))
    )
   )
  )

; if user didn't select multiple option, set end radius and step size to nothing
  (setq vr_r2 nil vr_r3 nil)
 )

; output list of K value/radius flag and radius values
 (if (and (/= vr_r2 nil) (/= vr_r3 nil))

; output list includes end radius and step size if defined
  (list vr_k1 vr_r1 vr_r2 vr_r3)

; otherwise just start radius if end radius and step size not defined
  (list vr_k1 vr_r1)
 )
)

; =======================================================================================================

; VCURV_GETINSERTPOINT
; ====================

; Description:
; ============
; Asks user for insertion point for first curve, or whether to fit curves to gradient lines
; Output: insertion point or "fit" it fitting curves to lines

; Internal Variables:
; ===================
; vi_a1 = input: first gradient value or pair of points defining line
; vi_a2 = input: second gradient value or pair of points defining line
; vi_t1 = question text, shown when asking for user input
; vi_p1 = output: insertion point or "fit", or nil if no point nor option selected

(defun vcurv_getinsertpoint (vi_a1 vi_a2 / vi_t1 vi_p1)

; create string asking user for insertion point, with fit option if two lines provided
 (setq vi_t1 "\nSelect insertion point for curve(s)")
 (if (and (= (listp vi_a1) T) (= (listp vi_a2) T))
  (progn
   (setq vi_t1 (strcat vi_t1 "/Fit: "))
   (initget 0 "fit")
  )
  (setq vi_t1 (strcat vi_t1 ": "))
 )

; ask user for insertion point or "fit" option
 (setq vi_p1 (getpoint vi_t1))

; if user entered nothing and selected no point, show error message
 (if (= vi_p1 nil)
  (princ "\nNo insertion point selected. Command terminating")
 )

; set insertion point, or option, to itself as output from function
 (setq vi_p1 vi_p1)
)

; =======================================================================================================

; VCURV_GETDIMS
; =============

; Description:
; ============
; Calculates vertical curve signed radius, length, far endpoint vertical position, max/min coordinates
; Output: list of signed radius, x,y coordinates of far endpoint, max/min x,y coordinates

; Internal Variables:
; ===================
; vd_r1 = input: unsigned radius (always positive)
; vd_g1 = input: start gradient (in %)
; vd_g2 = input: end gradient (in %)
; vd_x1, vd_y1 = curve length and end level (x and y coordinates of far end)
; vd_x2, vd_y2 = x,y coordinates of maximum or minimum point on curve

(defun vcurv_getdims (vd_r1 vd_g1 vd_g2 / vd_x1 vd_y1 vd_x2 vd_y2)

; make radius negative if curve is a sag curve (end gradient > start gradient)
 (if (> vd_g2 vd_g1)
  (setq vd_r1 (- vd_r1))
 )

; get x,y coordinates of far end of curve
 (setq vd_x1 (/ (* vd_r1 (- vd_g1 vd_g2)) 100.0))
 (setq vd_y1 (- (/ (* vd_g1 vd_x1) 100.0) (/ (* vd_x1 vd_x1) 2.0 vd_r1)))

; get x,y coordinates of maximum or minimum point on curve (even if outside curve extents)
 (setq vd_x2 (/ (* vd_g1 vd_x1) (- vd_g1 vd_g2)))
 (setq vd_y2 (- (/ (* vd_g1 vd_x2) 100.0) (/ (* vd_x2 vd_x2) 2.0 vd_r1)))

; output list of data
 (list vd_r1 vd_x1 vd_y1 vd_x2 vd_y2) 
)

; =======================================================================================================

; VCURV_FITCURVETOLINES
; =====================

; Description:
; ============
; Calculates insertion point so that vertical curve fits smoothly with gradient (reference) lines
; Output: x,y coordinates list of insertion point for vertical curve

; Internal Variables:
; ===================
; vf_a1 = start gradient line (list of pair of coordinates for each end of line)
; vf_a2 = end gradient line (list of pair of coordinates for each end of other line)
; vf_v1 = vertical exaggeration factor
; vf_l1 = list of curve details (including length and vertical offset between ends)
; vf_p1, vf_p2 = points at ends of gradient line
; vf_x1, vf_y1, vf_x2, vf_y2 = x,y coordinates at each end of first gradient line
; vf_x3, vf_y3, vf_x4, vf_y4 = x,y coordinates at each end of second gradient line
; vf_x5, vf_y5 = x,y coordinates at far end of curve, assuming it starts at x1,y1
; vf_f1 = fraction along first gradient line to start of curve
; vf_p1 = insertion point, or nil if no point found

(defun vcurv_fitcurvetolines (vf_a1 vf_a2 vf_v1 vf_l1 / vf_p1 vf_p2 vf_x1 vf_y1 vf_x2 vf_y2
                              vf_x3 vf_y3 vf_x4 vf_y4 vf_x5 vf_y5 vf_f1)

; get x,y coordinates for each end of each gradient line
; (divide y values by vertical exaggeration factor)
 (setq vf_p1 (car vf_a1) vf_p2 (cadr vf_a1))
 (setq vf_x1 (car vf_p1) vf_y1 (/ (cadr vf_p1) vf_v1)
       vf_x2 (car vf_p2) vf_y2 (/ (cadr vf_p2) vf_v1))
 (setq vf_p1 (car vf_a2) vf_p2 (cadr vf_a2))
 (setq vf_x3 (car vf_p1) vf_y3 (/ (cadr vf_p1) vf_v1)
       vf_x4 (car vf_p2) vf_y4 (/ (cadr vf_p2) vf_v1))

; get x,y coordinates for far end of vertical curve, assuming it starts at
; start of first gradient line
 (setq vf_x5 (+ vf_x1 (nth 1 vf_l1)) vf_y5 (+ vf_y1 (nth 2 vf_l1)))

; calculate denominator of fraction to move curve along first gradient line
 (setq vf_f1 (- (* (- vf_x2 vf_x1) (- vf_y4 vf_y3))
                (* (- vf_y2 vf_y1) (- vf_x4 vf_x3))))

; if zero cannot find point (otherwise divide by zero error)
 (if (= vf_f1 0.0)
  (setq vf_p1 nil)

; if not zero, calculate fraction along first gradient line to curve insertion point
  (progn
   (setq vf_f1 (/ (- (* (- vf_y5 vf_y3) (- vf_x4 vf_x3))
                     (* (- vf_x5 vf_x3) (- vf_y4 vf_y3))) vf_f1))

; create curve insertion point as list (multiply y value by vertical exaggeration)
   (setq vf_p1 (list (+ vf_x1 (* vf_f1 (- vf_x2 vf_x1)))
                  (* (+ vf_y1 (* vf_f1 (- vf_y2 vf_y1))) vf_v1) 0.0))
  )
 )

; return list containing insertion point for vertical curve, or nil if none found
 (setq vf_p1 vf_p1)
)

; =======================================================================================================

; VCURV_DRAWPLINE
; ===============

; Description:
; ============
; Draws vertical curve as 2D polyline

; Internal Variables:
; ===================
; vp_p1 = curve insertion point
; vp_g1 = start gradient (in %)
; vp_g2 = end gradient (in %)
; vp_v1 = vertical exaggeration factor
; vp_d1 = maximum horizontal step size
; vp_l1 = list of curve details (including overall length and min/max x,y coordinates)
; vp_f1 = flag: T = polyline will be inside a block
; vp_x1, vp_y1 = x,y coordinates at start of vertical curve
; vp_r1 = vertical curve radius
; xp_x2 = vertical curve overall length (in x direction)
; vp_x3 = distance (in x direction) to min/max level on vertical curve
; vp_n1, vp_n2 = number of steps either side of min/max level
; vp_d2, vp_d3 = step size either side of min/max level
; vp_x4, vp_y4 = current point along vertical curve
; vp_e1 = entity data for lightweight polyline being created
; vp_d4 = current step size

(defun vcurv_drawpline (vp_p1 vp_g1 vp_g2 vp_v1 vp_d1 vp_l1 vp_f1 / vp_x1 vp_y1 vp_r1 vp_x2 vp_x3
                        vp_n1 vp_n2 vp_d2 vp_d3 vp_x4 vp_y4 vp_e1 vp_d4)

; get start x,y coordinates for curve
 (setq vp_x1 (car vp_p1) vp_y1 (cadr vp_p1))

; get curve radius and x distance to other end and to min/max level from start point
 (setq vp_r1 (nth 0 vp_l1) vp_x2 (nth 1 vp_l1) vp_x3 (nth 3 vp_l1))

; if min/max point is within curve extents
 (if (and (> vp_x3 0.0) (< vp_x3 vp_x2))
  (progn

; calculate number of points either side of min/max point
   (setq vp_n1 (/ vp_x3 vp_d1) vp_n2 (/ (- vp_x2 vp_x3) vp_d1))
   (if (= (- vp_n1 (float (fix vp_n1))) 0.0)
    (setq vp_n1 (fix vp_n1))
    (setq vp_n1 (1+ (fix vp_n1)))
   )
   (if (= (- vp_n2 (float (fix vp_n2))) 0.0)
    (setq vp_n2 (fix vp_n2))
    (setq vp_n2 (1+ (fix vp_n2)))
   )

; calculate x distance between points either side of min/max point
   (setq vp_d2 (/ vp_x3 vp_n1) vp_d3 (/ (- vp_x2 vp_x3) vp_n2))
  )

; if min/max point is not within curve extents
  (progn

; calculate number of points within curve (set second points number as 0 i.e. none)
   (setq vp_n1 (/ vp_x2 vp_d1) vp_n2 0)
   (if (= (- vp_n1 (float (fix vp_n1))) 0.0)
    (setq vp_n1 (fix vp_n1))
    (setq vp_n1 (1+ (fix vp_n1)))
   )

; calculate x distance between points within curve
   (setq vp_d2 (/ vp_x2 vp_n1) vp_d3 0.0)
  )
 )

; start at left end of curve
 (setq vp_x4 0.0)

; create initial polyline entity data list (zero thickness, zero elevation)
 (setq vp_e1 (list (cons 0 "LWPOLYLINE") (cons 100 "AcDbEntity") (cons 100 "AcDbPolyline")
                   (cons 90 (+ vp_n1 vp_n2 1)) (cons 43 0.0) (cons 38 0.0)))

; if polyline will be inside a block, set its layer to layer 0 (otherwise use default layer)
 (if (= vp_f1 T)
  (setq vp_e1 (append vp_e1 (list (cons 8 "0"))))
 )

; keep going while still got some points to draw
 (while (>= (+ vp_n1 vp_n2) 0)

; calculate y coordinate for each point and append as 2D point to polyline entity (no bulge factor)
  (setq vp_y4 (- (/ (* vp_g1 vp_x4) 100.0) (/ (* vp_x4 vp_x4) (* 2.0 vp_r1))))
  (setq vp_e1 (append vp_e1 (list (list 10 (+ vp_x1 vp_x4) (+ vp_y1 (* vp_y4 vp_v1)))
                                  (cons 42 0.0) (cons 91 0))))

; increase x distance between points depending on which side of min/max point or within curve
  (if (> vp_n1 0)
   (setq vp_d4 vp_d2 vp_n1 (1- vp_n1))
   (setq vp_d4 vp_d3 vp_n2 (1- vp_n2))
  )

; increase distance along curve to calculate next point
  (setq vp_x4 (+ vp_x4 vp_d4))
 )

; create polyline (vcurv_drawpline returns nil if entmake fails)
 (entmake vp_e1)
)

; =======================================================================================================

; VCURV_DRAWEXTRA
; ===============

; Description:
; ============
; Draws TP dumbells, max/min marker and/or curve parameters
; Ouput: T if something was drawn, nil if nothing drawn

; Internal Variables:
; ===================
; vx_p1 = curve insertion point
; vx_g1 = start gradient (in %)
; vx_g2 = end gradient (in %)
; vx_v1 = vertical exaggeration factor
; vx_l1 = list of curve details
; vx_f1 = flag: "yes" = show TP dumbells
; vx_f2 = flag: "yes" = show maximum or minimum marker
; vx_f3 = flag: "yes" = show curve parameters as text next to curve
; vx_k1 = flag: "k" show k value or "r" show radius value
; vx_f4 = output: flag: T if something has been drawn, nil if nothing drawn
; vx_f5 = flag: found available block number
; vx_b1 = block number
; vx_h1 = text height
; vx_x1, vx_y1 = x,y coordinates for drawing lines, circles etc.
; vx_x2, vx_y2 = more x,y coordinates for drawing lines, circles etc.
; vx_e1 = entity data for min/max marker
; vx_z1 = old DIMZIN value
; vx_t1 = text to display beside vertical curve

(defun vcurv_drawextra (vx_p1 vx_g1 vx_g2 vx_v1 vx_l1 vx_f1 vx_f2 vx_f3 vx_k1 / vx_f4 vx_f5
                        vx_b1 vx_h1 vx_x1 vx_y1 vx_x2 vx_y2 vx_e1 vx_z1 vx_t1)

; check if anything needs drawing
 (if (or (= vx_f1 "yes") (= vx_f2 "yes") (= vx_f3 "yes"))

; if so set flag returned by function and create new block
  (progn
   (setq vx_f4 T vx_f5 nil)

; search for first free block number, starting with global variable
   (if (= vcurv_blocknum nil)
    (setq vx_b1 1000)
    (setq vx_b1 vcurv_blocknum)
   )

; keep going until find a free block number
   (while (= vx_f5 nil)
    (if (= (tblsearch "block" (strcat "VCURV" (itoa vx_b1))) nil)

; found free block number
     (setq vx_f5 T)

; if not found one, increase number and search again
     (setq vx_b1 (1+ vx_b1))
    )
   )

; store found number in global variable (will need this to draw vertical curve)
   (setq vcurv_blocknum vx_b1)

; create block, if fails change flag so no dumbells etc are shown (on layer 0)
   (if (= (entmake (list (cons 0 "BLOCK") (cons 100 "AcDbEntity") (cons 8 "0")
                         (cons 100 "AcDbBlockBegin")
                         (cons 2 (strcat "VCURV" (itoa vx_b1))) (cons 70 0)
                         (append (list 10) vx_p1))) nil)
    (setq vx_f4 nil)

; if succeed to start creating block, set flag to say part way through creating block
    (setq vcurv_creatingblock T)
   )
  )

; if nothing needs drawing set flag accordingly
  (setq vx_f4 nil)
 )

; draw items if block created OK
 (if (/= vx_f4 nil)
  (progn

; get current text height
   (setq vx_h1 (getvar "TEXTSIZE"))

; draw TP dumbells at each end of vertical curve
   (if (= vx_f1 "yes")
    (progn

; get x,y coordinates at left end of curve
     (setq vx_x1 (car vx_p1) vx_y1 (cadr vx_p1))
     (repeat 2

; draw line and two circles (on layer 0)
      (entmake (list (cons 0 "LINE") (cons 100 "AcDbEntity") (cons 8 "0")
                     (cons 100 "AcDbLine")
                     (list 10 vx_x1 (- vx_y1 (/ vx_h1 2.0)) 0.0)
                     (list 11 vx_x1 (+ vx_y1 (/ vx_h1 2.0)) 0.0)))
      (entmake (list (cons 0 "CIRCLE") (cons 100 "AcDbEntity") (cons 8 "0")
                     (cons 100 "AcDbCircle") 
                     (list 10 vx_x1 (- vx_y1 (* 0.75 vx_h1)) 0.0)
                     (cons 40 (/ vx_h1 4.0))))
      (entmake (list (cons 0 "CIRCLE") (cons 100 "AcDbEntity") (cons 8 "0")
                     (cons 100 "AcDbCircle") 
                     (list 10 vx_x1 (+ vx_y1 (* 0.75 vx_h1)) 0.0)
                     (cons 40 (/ vx_h1 4.0))))

; get x,y coordinates to other end of curve
      (setq vx_x1 (+ vx_x1 (nth 1 vx_l1))
            vx_y1 (+ vx_y1 (* (nth 2 vx_l1) vx_v1)))
     )
    )
   )

; draw min/max marker if within extents of vertical curve
   (if (= vx_f2 "yes")
    (progn
     (setq vx_x1 (nth 1 vx_l1) vx_x2 (nth 3 vx_l1))
     (if (and (> vx_x2 0.0) (< vx_x2 vx_x1))
      (progn

; create initial polyline entity data list (zero thickness, zero elevation, layer 0)
       (setq vx_e1 (list (cons 0 "LWPOLYLINE") (cons 100 "AcDbEntity") (cons 100 "AcDbPolyline")
                         (cons 90 3) (cons 43 0.0) (cons 38 0.0) (cons 8 "0")))

; get x,y coordinates for marker tip
       (setq vx_x2 (+ vx_x2 (car vx_p1)))
       (setq vx_x1 (- vx_x2 (* vx_h1 0.375)) vx_y1 (+ (cadr vx_p1) (* (nth 4 vx_l1) vx_v1)))

; if crest curve marker points upwards, if sag curve marker points downwards
       (if (< vx_g2 vx_g1)
        (setq vx_y2 (- vx_y1 (* vx_h1 0.75)))
        (setq vx_y2 (+ vx_y1 (* vx_h1 0.75)))
       )

; add three sets of coordinates to polyline entity data list
       (setq vx_e1 (append vx_e1 (list (list 10 vx_x1 vx_y2) (cons 42 0) (cons 91 0))
                                 (list (list 10 vx_x2 vx_y1) (cons 42 0) (cons 91 0))))
       (setq vx_x1 (+ vx_x1 (* vx_h1 0.75)))
       (setq vx_e1 (append vx_e1 (list (list 10 vx_x1 vx_y2) (cons 42 0) (cons 91 0))))

; create the polyline
       (entmake vx_e1)
      )
     )
    )
   )

; draw mtext containing curve parameters below mid-point of vertical curve
   (if (= vx_f3 "yes")
    (progn

; get x,y coordinates of mid-point along vertical curve
     (setq vx_x1 (/ (nth 1 vx_l1) 2.0))
     (setq vx_y1 (- (/ (* vx_g1 vx_x1) 100.0)
                    (/ (* vx_x1 vx_x1) (* 2.0 (nth 0 vx_l1)))))

; calculate text insertion point (lower it by 1.5 times text height)
     (setq vx_p1 (list (+ (car vx_p1) vx_x1)
                       (- (+ (cadr vx_p1) (* vx_y1 vx_v1)) (* vx_h1 1.5)) 0.0))

; remember old DIMZIN and set it so zeros after decimal point are shown
     (setq vx_z1 (getvar "DIMZIN"))
     (setvar "DIMZIN" 0)

; create text output, depends on whether K value or radius is being used
     (if (= vx_k1 "k")
      (setq vx_t1 (strcat "{K=" (rtos (/ (nth 0 vx_l1) 100.0) 2 3) "\\P"))
      (setq vx_t1 (strcat "{R=" (rtos (nth 0 vx_l1) 2 3) "\\P"))
     )

; add rest of text output to output string
     (setq vx_t1 (strcat vx_t1 "L=" (rtos (nth 1 vx_l1) 2 3) "\\P"
                               "a=" (rtos vx_g1 2 3) "%\\P"
                               "b=" (rtos vx_g2 2 3) "%\\P"
                               "VE=" (rtos vx_v1 2 3) "}"))

; reset DIMZIN to previous value
     (setvar "DIMZIN" vx_z1)

; create text object, centre-aligned below vertical curve mid-point
     (entmake (list (cons 0 "MTEXT") (cons 100 "AcDbEntity") (cons 8 "0")
                    (cons 100 "AcDbMText")
                    (append (list 10) vx_p1) (cons 40 vx_h1)
                    (cons 1 vx_t1) (cons 71 2) (cons 73 2)))
    )
   )
  )
 )

; return flag showing whether anything was drawn (= T)
 (setq vx_f4 vx_f4)
)

; =======================================================================================================

; VCURV_ENDBLOCK
; ==============

; Description:
; ============
; Ends creating block containing curve polyline and TP dumbells, max/min marker and/or curve parameters

; Internal Variables:
; ===================
; vb_p3 = input: curve insertion point
; vb_b1 = block number

(defun vcurv_endblock (vb_p3 / vb_b1)

; end block definition
 (entmake (list (cons 0 "ENDBLK") (cons 100 "AcDbEntity") (cons 8 "0") (cons 100 "AcDbBlockEnd")))

; set global flag to say no longer part way through creating block
 (setq vcurv_creatingblock nil)

; get latest block number used
 (setq vb_b1 vcurv_blocknum)

; insert block containing vertical curve
 (entmake (list (cons 0 "INSERT") (cons 100 "AcDbEntity") (cons 100 "AcDbBlockReference")
                (cons 2 (strcat "VCURV" (itoa vb_b1)))
                (append (list 10) vb_p3)))
)

; =======================================================================================================
; O   O  OOOO O   O OOOO  O   O
; O   O O     O   O O   O O   O
; O   O O     O   O OOOO  O   O
;  O O  O     O   O O   O  O O
;   O    OOOO  OOO  O   O   O
; =======================================================================================================

; VCURV
; =====

; Description:
; ============
; Draws vertical curve(s) either with start/end gradients or fitting to reference line or polyline objects

; Internal Variables:
; ===================
; a1 = start gradient (in %) or pair of points of line defining start gradient
; a2 = end gradient (in %) or pair of points of line defining end gradient
; k1 = flag: T = display k value, nil = display radius value
; r1 = start radius value
; r2 = end radius value (nil if no range)
; r3 = radius step size in range (nil if no range)
; r4 = swap radius value
; d1 = horizontal step size
; v1 = vertical exaggeration factor
; g1, g2 = start and end gradients (in %)
; f1 = flag: "yes" = show TP dumbells
; f2 = flag: "yes" = show maximum or minimum marker
; f3 = flag: "yes" = show curve parameters as text next to curve
; p1 = insertion point for drawing curve(s) or "fit" if fitting curves to gradient lines
; x1, x2 = x coordinates of start of gradient lines, then storage if swapping gradients
; p2 = vertical offset above insertion point for multiple curves
; l1 = list of vertical curve dimensions data (x,y coordinates etc.)
; p3 = insertion point for vertical curve
; f4 = flag: T if extra curve items are drawn (e.g. TP dumbells, min/max marker, text)
; r4 = current radius value when drawing multiple curves

(defun C:VCURV ( / a1 a2 k1 r1 r2 r3 r4 d1 v1 g1 g2 f1 f2 f3 p1 x1 x2 p2 l1 p3 f4)
 (vcurv_atstart)

; get start and end gradients, or list of point pairs defining gradients
 (if (/= (setq a1 (vcurv_getgradient T)) nil)
  (if (/= (setq a2 (vcurv_getgradient nil)) nil)
   (progn

; get radii and whether to display radii or K values
    (setq k1 (car (setq r1 (vcurv_getradii))))
    (setq r1 (cdr r1))

; if radius list provided divide it into 3 radius values (start, end, step size)
    (if (= (length r1) 3)
     (setq r2 (abs (cadr r1)) r3 (abs (caddr r1)))

; if no radius list provided, set end radius and step size as nothing
     (setq r2 nil r3 nil)
    )

; get start radius (store as positive value)
    (setq r1 (abs (car r1)))

; swap radius values if end radius is less than start radius
    (if (/= r2 nil)
     (if (< r2 r1)
      (progn
       (setq r4 r1)
       (setq r1 r2)
       (setq r2 r4)
      )
     )
    )

; check all radius values aren't zero
    (if (or (= r1 0.0) (= r2 0.0) (= r3 0.0))
     (progn
      (princ "\nRadius value(s) and/or step size cannot be zero. Command terminating")
      (setq a1 nil a2 nil)
     )
    )
   )
  )
 )


; get horizontal step size (error if zero or negative)
 (if (and (/= a1 nil) (/= a2 nil))
  (progn
   (setq d1 (vcurv_getglobalvalue "Enter maximum horizontal step size" vcurv_hozstep 5.0))
   (if (<= d1 0.0)
    (progn
     (princ "\nCannot have zero or negative horizontal step size. Command terminating")
     (setq a1 nil a2 nil)
    )
   )
  )
 )

; get vertical exaggeration (error if zero)
 (if (and (/= a1 nil) (/= a2 nil))
  (progn
   (setq v1 (vcurv_getglobalvalue "Enter vertical exaggeration factor" vcurv_vertexag 10.0))
   (if (= v1 0.0)
    (progn
     (princ "\nCannot have zero vertical exaggeration. Command terminating")
     (setq a1 nil a2 nil)
    )
   )
  )
 )

; get start and end gradient values for all situations and check aren't the same
; (divide reference line gradients by vertical exaggeration factor)
 (if (and (/= a1 nil) (/= a2 nil))
  (progn
   (if (= (listp a1) T)
    (setq g1 (/ (vcurv_calcgradient a1) v1))
    (setq g1 a1)
   )
   (if (= (listp a2) T)
    (setq g2 (/ (vcurv_calcgradient a2) v1))
    (setq g2 a2)
   )
   (if (= g1 g2)
    (progn
     (princ "\nStart and end gradients are the same. Command terminating")
     (setq a1 nil a2 nil)
    )
   )
  )
 )

; get flag on whether to show TP dumbells
 (if (and (/= a1 nil) (/= a2 nil))
  (progn
   (setq f1 (vcurv_getglobaloption "Show TP dumbells at each end of curve?"
             vcurv_showtps "yes"))

; get flag on whether to show minimum/maximum markers
   (setq f2 (vcurv_getglobaloption "Show maximum or minimum markers?"
             vcurv_showmaxmin "yes"))

; get flag on whether to show curve parameters as text next to curve
   (setq f3 (vcurv_getglobaloption "Show curve parameters next to curve?"
             vcurv_showtext "yes"))

; get insertion point or "fit" if curves to be fitted to gradient lines
   (if (= (setq p1 (vcurv_getinsertpoint a1 a2)) nil)

; if no insertion point nor "fit", set gradients to nil to avoid drawing anything
    (setq a1 nil a2 nil)

; if fitting to gradient lines, make sure left hand line is start gradient
    (if (= p1 "fit")
     (progn

; get start x coordinate for each gradient line start
      (setq x1 (car (car a1)) x2 (car (car a2)))

; swap them round if start gradient line is to the right of end gradient line
      (if (> x1 x2)
       (progn
        (setq x1 a1 x2 g1)
        (setq a1 a2 g1 g2)
        (setq a2 x1 g2 x2)
       )

; if lines have same start x coordinate, show error message and quit command
       (if (= x1 x2)
        (progn
         (princ "\nCannot tell which line segment is start or end. Command terminating")
         (setq a1 nil a2 nil)
        )
       )
      )
     )
    )
   )
  )
 )

 (if (and (/= a1 nil) (/= a2 nil))
  (progn
   (setq p2 nil)

; get vertical offset between multiple curves (not fitted to lines)
   (if (and (/= r2 nil) (= (listp p1) T))
    (setq p2 (vcurv_getglobalvalue "Enter vertical offset between each curve"
              vcurv_vertoffset 10.0))
   )

; store global values
   (setq vcurv_startgrad g1)
   (setq vcurv_endgrad g2)
   (setq vcurv_fromrad r1)
   (if (/= r2 nil)
    (setq vcurv_torad r2)
   )
   (if (/= r3 nil)
    (setq vcurv_radstep r3)
   )
   (setq vcurv_korrad k1)
   (setq vcurv_hozstep d1)
   (setq vcurv_vertexag v1)
   (setq vcurv_showtps f1)
   (setq vcurv_showmaxmin f2)
   (setq vcurv_showtext f3)
   (if (/= p2 nil)
    (setq vcurv_vertoffset p2)
   )

; if drawing a single vertical curve create range of one curve with arbitrary increments
   (if (= r2 nil)
    (setq r2 r1 r3 1.0 p2 1.0)
   )

; start with initial radius, and initial insertion point
   (setq r4 r1 p3 p1)

; keep drawing until past end radius
   (while (<= r4 r2)

; get curve dimensions
    (setq l1 (vcurv_getdims r4 g1 g2))

; get insertion point if fitting it to two gradient lines
    (if (= p1 "fit")
     (setq p3 (vcurv_fitcurvetolines a1 a2 v1 l1))
    )

; draw curve and, if required, TP dumbells, min/max data, and/or curve parameters
    (setq f4 (vcurv_drawextra p3 g1 g2 v1 l1 f1 f2 f3 k1))
    (vcurv_drawpline p3 g1 g2 v1 d1 l1 f4)
    (if (= f4 T)
     (vcurv_endblock p3)
    )

; if not fitting curves to gradient lines, increase insertion point by vertical offset
    (if (= (listp p1) T)
     (setq p3 (list (car p3) (+ (cadr p3) p2) (caddr p3)))
    )

; if next radius is past end radius use end radius, otherwise increase radius by step size
    (if (and (< r4 r2) (> (+ r4 r3) r2))
     (setq r4 r2)
     (setq r4 (+ r4 r3))
    )
   )
   (princ "\nCommand finished")
  )
 )
 (vcurv_atend)
 (princ)
)

; =======================================================================================================
; Output to screen when this lisp file in uploaded:

(princ "\nType VCURV to use (Version 1.03 GD 10-11-2015)")
(princ "\n(VCURV draws vertical, longitudinal or railway curve(s) for given start/end")
(princ "\n gradients and radius or K values. Curve(s) can also be fitted to existing lines")
(princ "\n or line segments of 2D polylines")
(princ)

; =======================================================================================================
; Revision information:

; 1.01 - add 'vcurv_creatingblock' global variable
; 1.01 - include missing definitions of local variables in function headers
; 1.01 - change 'output to screen' text displayed when lisp file is uploaded
; 1.02 - default radius value increased
; 1.02 - correcting spelling mistakes and incorrect words in comments sections
; 1.02 - equations in VCURV_FITCURVETOLINES rearranged to match equations in website PDF
; 1.02 - size and proportion of min/max marker changed, positioning of parameters text changed
; 1.03 - 3D points in polyline data list in VCURV_DRAWPLINE changed to 2D points to comply with AutoCAD
