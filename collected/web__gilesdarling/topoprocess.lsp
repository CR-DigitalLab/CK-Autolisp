; TPOP_ERRORMSG, TPOP_ATSTART and TPOP_ATEND
; ==========================================

; Description:
; ============
; Handle error messages, set-up and restore point to error message handler, and being/end UNDO loop

; Global Variables:
; =================
; tpop_olderr = pointer to old error message handler

; Internal Variables:
; ===================
; em_t1 = error message passed to error message handler
; em_o1 = old value of CMDECHO in tpop_errormsg
; as_o1 = old value of CMDECHO in tpop_atstart
; ae_o1 = old value of CMDECHO in tpop_atend

(defun tpop_errormsg (em_t1 / em_o1)

; restore pointer to old error message handler and display error message
 (setq *error* tpop_olderr)
 (setq tpop_olderr nil)
 (princ (strcat "\nCommand stopped due to error: " em_t1))

; end UNDO group command
 (setq em_o1 (getvar "CMDECHO"))
 (setvar "CMDECHO" 0)
 (command "UNDO" "E")
 (setvar "CMDECHO" em_o1)
 (princ)
)

(defun tpop_atstart ( / as_o1)

; set error message handler pointer to new error message handler
 (setq tpop_olderr *error*)
 (setq *error* tpop_errormsg)

; begin UNDO group command
 (setq as_o1 (getvar "CMDECHO"))
 (setvar "CMDECHO" 0)
 (command "UNDO" "BE")
 (setvar "CMDECHO" as_o1)
)

(defun tpop_atend ( / ae_o1)

; end UNDO group command
 (setq ae_o1 (getvar "CMDECHO"))
 (setvar "CMDECHO" 0)
 (command "UNDO" "E")
 (setvar "CMDECHO" ae_o1)

; restore pointer to old error message handler
 (setq *error* tpop_olderr)
 (setq tpop_olderr nil)
)

; =============================================================================================

; TPOP_GETGOBALVAL
; ================

; Description:
; ============
; Ask user for a value, using global value if available as default
; Inputs: text, global variable value, default value, flag for integer/real number
; Output: value

; Internal Variables:
; ===================
; gv_t1 = text to display when asking for value
; gv_g1 = value of global variable (nil if variable not defined yet)
; gv_d1 = default value if global variable is nil and user doesn't enter a value
; gv_b1 = flag: T for integers, nil for real values
; gv_v1 = value returned from function

(defun tpop_getglobalval (gv_t1 gv_g1 gv_d1 gv_b1 / gv_v1)
 (setq gv_t1 (strcat gv_t1 ": <"))

; append default value (by type) to question text if no global value provided
 (if (= gv_g1 nil)
  (if (= gv_b1 T)
   (setq gv_t1 (strcat gv_t1 (itoa gv_d1)))
   (setq gv_t1 (strcat gv_t1 (rtos gv_d1 2 3)))
  )

; otherwise append global value provided (by type) if it is provided
  (if (= gv_b1 T)
   (setq gv_t1 (strcat gv_t1 (itoa gv_g1)))
   (setq gv_t1 (strcat gv_t1 (rtos gv_g1 2 3)))
  )
 )
 (setq gv_t1 (strcat gv_t1 "> "))

; ask user for value
 (if (= gv_b1 T)
  (setq gv_v1 (getint gv_t1))
  (setq gv_v1 (getreal gv_t1))
 )

; if user didn't enter a value use default value, or global value if provided
 (if (= gv_v1 nil)
  (if (= gv_g1 nil)
   (setq gv_v1 gv_d1)
   (setq gv_v1 gv_g1)
  )
 )

; set output value to itself - return value from this function
 (setq gv_v1 gv_v1)
)

; =============================================================================================

; TPOP_ADDTOLIST
; ==============

; Description:
; ============
; Adds item to list, creating list if initially empty

; Internal Variables:
; ===================
; al_l1 = input: list to add to
; al_i1 = input: item to add to list al_l1
; al_l2 = output: updated list

(defun tpop_addtolist (al_l1 al_i1 / al_l2)

; if list doesn't exist yet, create it - otherwise add item to list
 (if (= al_l1 nil)
  (setq al_l2 (list al_i1))
  (setq al_l2 (append al_l1 (list al_i1)))
 )

; set updated list to itself, so updated list is output from this function
 (setq al_l2 al_l2)
)

; =============================================================================================

; TPOP_GETPOINTLIST
; =================

; Description:
; ============
; Creates ordered list of x,y,z data groups from POINT objects in a selection set

; Internal Variables:
; ===================
; pl_s1 = input: selection set list
; pl_c1 = counter through list pl_s1
; pl_l1 = output: list of x,y,z coordinate groups
; pl_d1 = data for each object in list pl_s1
; pl_p1 = coordinate of each object
; pl_x1 = x coordinate of point pl_p1
; pl_y1 = y coordinate of point pl_p1
; pl_m1 = minimum x coordinate, then current comparison x coordinate
; pl_m2 = minimum y coordinate, then current comparison y coordinate
; pl_m3 = maximum x coordinate
; pl_m4 = maximum y coordinate
; pl_n1 = next comparison x coordinate
; pl_n2 = next comparison y coordinate
; pl_f1 = flag: T before first object added at current x,y coordinates, nil thereafter
; pl_z1 = z coordinate of point pl_p1

(defun tpop_getpointlist (pl_s1 / pl_c1 pl_l1 pl_d1 pl_p1 pl_x1 pl_y1 pl_m1
                                  pl_m2 pl_m3 pl_m4 pl_n1 pl_n2 pl_f1 pl_z1)

; calculate min and max x,y coordinates for objects in data set
 (setq pl_c1 0 pl_l1 nil)
 (repeat (sslength pl_s1)
  (setq pl_d1 (entget (ssname pl_s1 pl_c1)))

; continue if object has x,y coordinate values
  (if (/= (assoc 10 pl_d1) nil)
   (progn
    (setq pl_p1 (cdr (assoc 10 pl_d1)))
    (setq pl_x1 (car pl_p1) pl_y1 (cadr pl_p1))

; if first item, set min/max values to item's x,y coordinates, otherwise calculate min/max
    (if (= pl_c1 0)
     (setq pl_m1 pl_x1 pl_m2 pl_y1 pl_m3 pl_x1 pl_m4 pl_y1)
     (setq pl_m1 (min pl_m1 pl_x1) pl_m2 (min pl_m2 pl_y1)
           pl_m3 (max pl_m3 pl_x1) pl_m4 (max pl_m4 pl_y1))
    )
   )
  )
  (setq pl_c1 (1+ pl_c1))
 )

; create ordered list (first by x coordinate, then by y coordinate for points with same x)
 (while (<= pl_m1 pl_m3)

; set max comparison values to just beyond actual maximum values, and first-time flag to T
  (setq pl_c1 0 pl_n1 (+ pl_m3 1.0) pl_n2 (+ pl_m4 1.0) pl_f1 T)
  (repeat (sslength pl_s1)
   (setq pl_d1 (entget (ssname pl_s1 pl_c1)))

; continue if object has x,y coordinate values
   (if (/= (assoc 10 pl_d1) nil)
    (progn
     (setq pl_p1 (cdr (assoc 10 pl_d1)))
     (setq pl_x1 (car pl_p1) pl_y1 (cadr pl_p1) pl_z1 (caddr pl_p1))

; object has same x coordinate as current comparison value
     (if (= pl_x1 pl_m1)

; object has same y coordinate as current comparison value
      (if (= pl_y1 pl_m2)

; if first object found at this x,y coordinate, add it to list and set flag to "not 1st"
       (if (= pl_f1 T)
        (setq pl_l1 (tpop_addtolist pl_l1 (list pl_x1 pl_y1 pl_z1)) pl_f1 nil)

; if not first object, show message saying duplicate point is being ignored
        (princ (strcat "\nDuplicate point at coordinates " (rtos pl_x1 2 3) ","
                       (rtos pl_y1 2 3) "," (rtos pl_z1 2 3) " ignored"))
       )

; object has same x coordinate, by y coordinate is more than current comparison value
       (if (> pl_y1 pl_m2)

; if x,y coordinates are less than next comparison value, set next to current
        (if (or (< pl_x1 pl_n1) (and (= pl_x1 pl_n1) (< pl_y1 pl_n2)))
         (setq pl_n1 pl_x1 pl_n2 pl_y1)
        )
       )
      )

; object has x coordinate more than current comparison value
      (if (> pl_x1 pl_m1)

; if x,y coordinates are less than next comparison value, set next to current
       (if (or (< pl_x1 pl_n1) (and (= pl_x1 pl_n1) (< pl_y1 pl_n2)))
        (setq pl_n1 pl_x1 pl_n2 pl_y1)
       )
      )
     )
    )
   )

; incease counter to see if next item in selection set has current x,y coordinates
   (setq pl_c1 (1+ pl_c1))
  )

; set new current comparison values equal to next comparison values
  (setq pl_m1 pl_n1 pl_m2 pl_n2)
 )

; set ordered list to itself, so list is output from this function
 (setq pl_l1 pl_l1)
)

; =============================================================================================

; TPOP_GETLINELIST
; ================

; Description:
; ============
; Creates list of 2D lines (x,y-x,y groups) from LWPOLYINE objects in selection set

; Internal Variables:
; ===================
; ll_s1 = input: selection set list
; ll_f1 = input: flag: T = only add closed polylines to list, nil = open or closed OK
; ll_c1 = counter through list ll_s1
; ll_l1 = output: list of x,y-x,y line groups
; ll_d1 = data list for each object in list pl_s1
; ll_c2 = counter through list ll_d1
; ll_f2 = flag: T if polyline contains an arc
; ll_n1 = code and data pair of item in polyline data list
; ll_f2 = flag: T if polyline is a closed polyline
; ll_x1, ll_y1 = x,y coordinates of first vertex in polyline
; ll_x2, ll_y2 = x,y coordinates at start of line
; ll_b1 = bulge factor
; ll_n1 = code of item in polyline data list
; ll_n2 = item in polyline data list (without code)
; ll_x3, ll_y3 = x,y coordinates at end of line

(defun tpop_getlinelist (ll_s1 ll_f1 / ll_c1 ll_l1 ll_d1 ll_c2 ll_f2 ll_n1 ll_x1
                                       ll_x2 ll_b1 ll_n2 ll_y1 ll_y2 ll_x3 ll_y3)
; go through each object in selection set
 (setq ll_c1 0 ll_l1 nil)
 (repeat (sslength ll_s1)

; get object's data list
  (setq ll_d1 (entget (ssname ll_s1 ll_c1)))

; if only closed polylines allowed see if current polyline contains any arcs
  (if (= ll_f1 T)
   (progn

; look at each item in polyine data list until has bulge flag is set
    (setq ll_c2 0 ll_f2 nil)
    (while (and (= ll_f2 nil) (< ll_c2 (length ll_d1)))
     (setq ll_n1 (nth ll_c2 ll_d1))

; set flag if find arc bulge factor (= 0.0 for a line)
     (if (and (= (car ll_n1) 42) (/= (cdr ll_n1) 0.0))
      (setq ll_f2 T)
     )
     (setq ll_c2 (1+ ll_c2))
    )

; if flag has been set, discard this item's data list and show message to user
    (if (= ll_f2 T)
     (progn
      (setq ll_d1 nil)
      (princ "\nA polyline has been ignored because it contains arc(s)")
     )
    )
   )
  )

; set default values and go through each item in data list if still available 
  (setq ll_c2 0 ll_f2 nil ll_x1 nil ll_x2 nil ll_b1 0.0)
  (repeat (length ll_d1)

; get code of each item in data list, and rest of item (after the code)
   (setq ll_n1 (car (setq ll_n2 (nth ll_c2 ll_d1))))
   (setq ll_n2 (cdr ll_n2))

; set flag if polyline is a closed polyline
   (if (and (= ll_n1 70) (= (boole 1 ll_n2 1) 1))
    (setq ll_f2 T)

; get latest bulge factor
    (if (= ll_n1 42)
     (setq ll_b1 ll_n2)

; process a vertex x,y coordinates
     (if (= ll_n1 10)
      (progn

; if first vertex in data list, remember its coordinates (in case polyline is closed)
       (if (= ll_x1 nil)
        (setq ll_x1 (car ll_n2) ll_y1 (cadr ll_n2))
       )

; if first vertex in data list, store its coordinates as start of line
       (if (= ll_x2 nil)
        (setq ll_x2 (car ll_n2) ll_y2 (cadr ll_n2))

; otherwise use coordinates as end of line and consider adding line to output list
        (progn
         (setq ll_x3 (car ll_n2) ll_y3 (cadr ll_n2))

; cannot add an arc, so show message to notify user
         (if (/= ll_b1 0.0)
          (princ (strcat "\nArc between " (rtos ll_x2 2 3) "," (rtos ll_y2 2 3)
                         " and " (rtos ll_x3 2 3) "," (rtos ll_y3 2 3) "ignored"))

; add line to output list if closed and closed required, or open or closed if both allowed
          (if (or (and (= ll_f1 T) (= ll_f2 T)) (= ll_f1 nil))
           (setq ll_l1 (tpop_addtolist ll_l1 (list (list ll_x2 ll_y2) (list ll_x3 ll_y3))))
          )
         )

; set start of next line as end of this line, and set next bulge factor to zero (default)
         (setq ll_x2 ll_x3 ll_y2 ll_y3 ll_b1 0.0)
        )
       )
      )
     )
    )
   )

; increase counter to look at next item in current polyline's data list
   (setq ll_c2 (1+ ll_c2))
  )

; if current polyline is a closed polyline, consider adding closing line to output list
  (if (and (= ll_f2 T) (/= ll_x1 nil) (/= ll_x2 nil))
   (if (/= ll_b1 0.0)

; but not if it's an arc
    (princ (strcat "\nArc between " (rtos ll_x2 2 3) "," (rtos ll_y2 2 3)
                   " and " (rtos ll_x1 2 3) "," (rtos ll_y1 2 3) " ignored"))
    (setq ll_l1 (tpop_addtolist ll_l1 (list (list ll_x2 ll_y2) (list ll_x1 ll_y1))))
   )
  )

; if only closed polylines allowed show message if current polyline isn't closed
  (if (and (= ll_f1 T) (= ll_f2 nil) (/= ll_d1 nil))
   (princ "\nA polyline has been ignored because it isn't closed")
  )

; increase counter to look at next polyline in selection set
  (setq ll_c1 (1+ ll_c1))
 )

; set line list to itself, so list is output from this function
 (setq ll_l1 ll_l1)
)

; =============================================================================================

; TPOP_POINTINBOUNDARY
; ====================

; Description:
; ============
; Check if point is within boundary lines

; Internal Variables:
; ===================
; pb_p1 = input: point to check
; pb_l1 = input: list of lines forming boundary
; pb_m1 = input: minimum x value of lines forming boundary
; pb_f1 = input: fuzz value
; pb_f2 = output: flag: T if within boundary or on edge of boundary, nil if not
; pb_c1 = count through list pb_l1
; pb_x1, pb_y1 = x,y coordinates of point pb_p1
; pb_i1 = individual line in list pb_l1
; pb_p2, pb_p3 = points at each end of pb_i1
; pb_x2, pb_y2, pb_x3, pb_y3 = x,y coordinates of point pb_p2 and pb_p3
; pb_d1 = distance/ratios from/along lines when comparing points/lines and lines

(defun tpop_pointinboundary (pb_p1 pb_l1 pb_m1 pb_f1 / pb_f2 pb_c1 pb_x1 pb_y1 pb_i1 pb_p2
                                                       pb_p3 pb_x2 pb_y2 pb_x3 pb_y3 pb_d1)

; if min x value or list of lines not available (i.e. no boundary), return T so point is OK
 (if (or (= pb_m1 nil) (= pb_l1 nil))
  (setq pb_f2 T)
  (progn

; set flag to "outside boundary", set counter to start of boundary lines list
; reduce min x so always start search line outside boundary, get x,y of search point
   (setq pb_f2 nil pb_c1 0 pb_m1 (- pb_m1 1.0) pb_x1 (car pb_p1) pb_y1 (cadr pb_p1))
   (while (< pb_c1 (length pb_l1))

; get x,y coordinates at start and end of each line on boundary/boundaries
    (setq pb_i1 (nth pb_c1 pb_l1))
    (setq pb_p2 (nth 0 pb_i1) pb_p3 (nth 1 pb_i1))
    (setq pb_x2 (car pb_p2) pb_y2 (cadr pb_p2) pb_x3 (car pb_p3) pb_y3 (cadr pb_p3))

; if boundary line is horizontal - see if same y values and x within min/max values
    (if (= pb_y2 pb_y3)
     (if (and (= pb_y2 pb_y1) (>= pb_x1 (- (min pb_x2 pb_x3) pb_f1))
                              (<= pb_x1 (+ (max pb_x2 pb_x3) pb_f1)))
      (setq pb_f2 T pb_c1 (length pb_l1))
     )

; if search line crosses non-horiz boundary (if ratio = 0 then at min x, so outside)
     (progn
      (setq pb_d1 (* (- pb_m1 pb_x1) (- pb_y3 pb_y2)))
      (if (/= pb_d1 0.0)
       (progn
        (setq pb_d1 (/ (- (* (- pb_m1 pb_x2) (- pb_y3 pb_y2))
                          (* (- pb_x3 pb_x2) (- pb_y1 pb_y2))) pb_d1))

; if point is on boundary line (i.e. ratio = 1.0) set flag and exit loop
        (if (and (>= pb_d1 (- 1.0 pb_f1)) (<= pb_d1 (+ pb_f1 1.0)))
         (setq pb_f2 T pb_c1 (length pb_l1))

; if intersection is within search line extents
         (if (and (>= pb_d1 (- pb_f1)) (<= pb_d1 (+ pb_f1 1.0)))
          (progn

; also see if intersection is within extents of boundary line
           (setq pb_d1 (/ (- pb_y2 pb_y1) (- pb_y2 pb_y3)))

; to avoid double counting line ends, upward lines exclude far end, downward exclude start
           (if (or (and (< pb_y2 pb_y3) (>= pb_d1 (- pb_f1)) (< pb_d1 (- 1.0 pb_f1)))
                   (and (> pb_y2 pb_y3) (> pb_d1 pb_f1) (<= pb_d1 (+ pb_f1 1.0))))

; if both lines cross, flip "within boundary" flag from T to nil, or nil to T
            (setq pb_f2 (not pb_f2))
           )
          )
         )
        )
       )
      )
     )
    )

; increase counter to look at next boundary line
    (setq pb_c1 (1+ pb_c1))
   )
  )
 )

; set "within boundary" flag to itself, so flag is output from this function
 (setq pb_f2 pb_f2)
)

; =============================================================================================

; TPOP_TRIAINBOUNDARY
; ===================

; Description:
; ============
; Check if triangle mid-point is within boundary lines

; Internal Variables:
; ===================
; tb_p1, tb_p2, tb_p3 = input: three corners of triangle
; tb_l1 = input: list of lines forming boundary
; tb_m1 = input: minimum x value of lines forming boundary
; tb_f1 = input: fuzz value
; tb_p4 = triangle mid-point
; tb_f2 = output: flag: T if within boundary or on edge of boundary, nil if not

(defun tpop_triainboundary (tb_p1 tb_p2 tb_p3 tb_l1 tb_m1 tb_f1 / tb_p4 tb_f2)

; calculate triangle mid-point
 (setq tb_p4 (list (/ (+ (car tb_p1) (car tb_p2) (car tb_p3)) 3.0)
                   (/ (+ (cadr tb_p1) (cadr tb_p2) (cadr tb_p3)) 3.0)
                   (/ (+ (caddr tb_p1) (caddr tb_p2) (caddr tb_p3)) 3.0)))

; return value directly form point in boundary function
 (setq tb_f2 (tpop_pointinboundary tb_p4 tb_l1 tb_m1 tb_f1))
)

; =============================================================================================

; TPOP_EQPOINT
; ============

; Description:
; ============
; Check if x,y of two 3D points are equal

; Internal Variables:
; ===================
; ep_p1 = input: first point
; ep_p2 = input: second point
; ep_f1 = output: T if equal, nil if not

(defun tpop_eqpoint (ep_p1 ep_p2 / ep_f1)

; set flag to T if x and y coordinates for each point are the same
 (if (and (= (car ep_p1) (car ep_p2)) (= (cadr ep_p1) (cadr ep_p2)))
  (setq ep_f1 T)
  (setq ep_f1 nil)
 )

; set flag to itself, so flag value is output from this function
 (setq ep_f1 ep_f1)
)

; =============================================================================================

; TPOP_EQLINE
; ===========

; Description:
; ============
; Check if two lines are the same (but ends could be swapped round)

; Internal Variables:
; ===================
; el_p1, el_p2 = input: each end of first line
; el_p3, el_p4 = input: each end of second line
; el_f1 = output: T if same, nil if not

(defun tpop_eqline (el_p1 el_p2 el_p3 el_p4 / el_f1)

; set flag to T if lines are the same, whichever the order of the ends 
 (if (or (and (= (tpop_eqpoint el_p1 el_p3) T) (= (tpop_eqpoint el_p2 el_p4) T))
         (and (= (tpop_eqpoint el_p1 el_p4) T) (= (tpop_eqpoint el_p2 el_p3) T)))
  (setq el_f1 T)
  (setq el_f1 nil)
 )

; set flag to itself, so flag value is output from this function
 (setq el_f1 el_f1)
)

; =============================================================================================

; TPOP_LINECLASH
; ==============

; Description:
; ============
; Check if two lines clash (in 2D plane only)

; Internal Variables:
; ===================
; lc_p1 = input: start of first line
; lc_p2 = input: end of first line
; lc_p3 = input: start of second line
; lc_p4 = input: end of second line
; lc_z1 = input: fuzz value
; lc_x1, lc_y1 = x,y coordinates of point lc_p1
; lc_x2, lc_y2 = x,y coordinates of point lc_p2
; lc_x3, lc_y3 = x,y coordinates of point lc_p3
; lc_x4, lc_y4 = x,y coordinates of point lc_p4
; lc_d1 = denominator for calculating clash (= 0 when lines are parallel)
; lc_f1 = output: T if no clash, nil if clash found
; lc_n1 = ratio along first line to intersection point
; lc_n2 = ratio along second line to intersection point

(defun tpop_lineclash (lc_p1 lc_p2 lc_p3 lc_p4 lc_z1 / lc_x1 lc_y1 lc_x2 lc_y2 lc_x3 lc_y3
                                                       lc_x4 lc_y4 lc_d1 lc_f1 lc_n1 lc_n2)

; get x and y coordinates for each point
 (setq lc_x1 (car lc_p1) lc_y1 (cadr lc_p1) lc_x2 (car lc_p2) lc_y2 (cadr lc_p2)
       lc_x3 (car lc_p3) lc_y3 (cadr lc_p3) lc_x4 (car lc_p4) lc_y4 (cadr lc_p4))

; calculate denominator and return "no clash" if lines are parallel
 (setq lc_d1 (- (* (- lc_x2 lc_x1) (- lc_y4 lc_y3)) (* (- lc_x4 lc_x3) (- lc_y2 lc_y1))))
 (if (= lc_d1 0.0)
  (setq lc_f1 T)

; if lines are not parallel, calculate ratio along each line to intersection point
  (progn
   (setq lc_n1 (/ (- (* (- lc_x4 lc_x3) (- lc_y1 lc_y3)) (* (- lc_x1 lc_x3) (- lc_y4 lc_y3))) lc_d1)
         lc_n2 (/ (- (* (- lc_x3 lc_x1) (- lc_y2 lc_y1)) (* (- lc_x2 lc_x1) (- lc_y3 lc_y1))) lc_d1))

; if ratios are within line length for both lines return "clash" otherwise return "no clash"
; (use fuzz value to allow for rounding errors)
   (if (and (> lc_n1 lc_z1) (< lc_n1 (- 1.0 lc_z1)) (> lc_n2 lc_z1) (< lc_n2 (- 1.0 lc_z1)))
    (setq lc_f1 nil)
    (setq lc_f1 T)
   )
  )
 )

; set flag to itself, so flag value is output from this function
 (setq lc_f1 lc_f1)
)

; =============================================================================================

; TPOP_TRIANGLECLASH
; ==================

; Description:
; ============
; Check if possible triangle clashes with existing triangles in list provided

; Internal Variables:
; ===================
; tc_p1 = input: first corner of possible 3D triangle
; tc_p2 = input: second corner of possible 3D triangle
; tc_p3 = input: third corner of possible 3D triangle
; tc_l1 = input: list of 3D triangles ((x,y)(x,y)(x,y) format)
; tc_z1 = input: fuzz value
; tc_f1 = output: T if no clash, nil if clash found
; tc_c1 = counter through list tc_l1
; tc_l2 = list of corner comparison arrangements to see if triangles are identical
; tc_i1 = individual 3D triangle in list tc_l1
; tc_c2 = count through list tc_l2
; tc_i2 = individual item from list tc_l2
; tc_c2 = count through three sides of possible 3D triangle
; tc_e1, tc_e2 = each end of current side of possible 3D triangle
; tc_c3 = count through three sides of 3D triangle tc_i1
; tc_e3, tc_e4 = each end of current side of 3D triangle in tc_i1

(defun tpop_triangleclash (tc_p1 tc_p2 tc_p3 tc_l1 tc_z1 / tc_f1 tc_c1 tc_l2 tc_i1 tc_c2 tc_i2
                                                           tc_e1 tc_e2 tc_c3 tc_e3 tc_e4)

; set output flag to "no clash" and counter to start of list of 3D triangles
 (setq tc_f1 T tc_c1 0)

; create list of possible arrangements of comparison points for comparing triangles
 (setq tc_l2 (list (list 0 1 2) (list 0 2 1) (list 1 0 2)
                   (list 1 2 0) (list 2 0 1) (list 2 1 0)))

; go through list of 3D triangles, and get each individual 3D triangle
 (while (and (= tc_f1 T) (< tc_c1 (length tc_l1)))
  (setq tc_i1 (nth tc_c1 tc_l1))

; see if possible 3D triangle is identical to individual 3D triangle
  (setq tc_c2 0)
  (while (and (= tc_f1 T) (< tc_c2 6))
   (setq tc_i2 (nth tc_c2 tc_l2))
   (if (and (= (tpop_eqpoint tc_p1 (nth (nth 0 tc_i2) tc_i1)) T)
            (= (tpop_eqpoint tc_p2 (nth (nth 1 tc_i2) tc_i1)) T)
            (= (tpop_eqpoint tc_p3 (nth (nth 2 tc_i2) tc_i1)) T))

; set flag to nil if it is identical
    (setq tc_f1 nil)
   )
   (setq tc_c2 (1+ tc_c2))
  )

; look at each side of possible 3D triangle, getting each end point
  (setq tc_c2 0)
  (while (and (= tc_f1 T) (< tc_c2 3))
   (setq tc_e1 (nth tc_c2 (list tc_p1 tc_p2 tc_p3))
         tc_e2 (nth tc_c2 (list tc_p2 tc_p3 tc_p1)))

; look at each side of individual 3D triangle from list
   (setq tc_c3 0)
   (while (and (= tc_f1 T) (< tc_c3 3))
    (setq tc_e3 (nth (nth tc_c3 (list 0 1 2)) tc_i1)
          tc_e4 (nth (nth tc_c3 (list 1 2 0)) tc_i1))

; see if lines clash (cross each other) (= nil if they do)
    (setq tc_f1 (tpop_lineclash tc_e1 tc_e2 tc_e3 tc_e4 tc_z1))

; increase counters for each while loop
    (setq tc_c3 (1+ tc_c3))        
   )
   (setq tc_c2 (1+ tc_c2))
  )
  (setq tc_c1 (1+ tc_c1))
 )

; set flag to itself, so flag value is output from this function
 (setq tc_f1 tc_f1)
)

; =============================================================================================

; TPOP_POINTSINCIRCLE
; ===================

; Description:
; ============
; Check if any points are in circle formed by three points provided

; Internal Variables:
; ===================
; ic_c1 = input: count in list ic_l1 of point ic_p1
; ic_c2 = input: count in list ic_l1 of point ic_p2
; ic_c3 = input: count in list ic_l1 of point ic_p3
; ic_p1 = input: first corner of possible 3D triangle
; ic_p2 = input: second corner of possible 3D triangle
; ic_p3 = input: third corner of possible 3D triangle
; ic_l1 = input: list of 3D points to check if any are inside circle
; ic_z1 = input: fuzz value
; ic_f1 = output: T if no points are inside circle formed by three points provided
; ic_x1, ic_y1 = x,y coordinates of point ic_p1
; ic_x2, ic_y2 = x,y coordinates of point ic_p2
; ic_x3, ic_y3 = x,y coordinates of point ic_p3
; ic_d1 = denominator for calculating centre of circle created by three points provided
; ic_n1, ic_n2 = numerators for calculating centre of circle
; ic_x4, ic_y4 = x,y coordinates at centre of circle
; ic_r1 = circle radius
; ic_x1, ic_y1 = minimum x,y coordinates of square enclosing circle
; ic_x2, ic_y2 = maximum x,y coordinates of square enclosing circle
; ic_c4 = count through list ic_l1 seeing if other points are inside circle
; ic_i1 = item in list ic_l1
; ic_x3, ic_y3 = x,y coordinates of point when checking if inside circle
; ic_d1 = 2D distance from circle centre to point being checked

(defun tpop_pointsincircle (ic_c1 ic_c2 ic_c3 ic_p1 ic_p2 ic_p3 ic_l1 ic_z1 / ic_f1 ic_x1 ic_y1 ic_x2
                                                                              ic_y2 ic_x3 ic_y3 ic_d1
                                                                              ic_n1 ic_n2 ic_x4 ic_y4
                                                                              ic_r1 ic_c4 ic_i1)
; set flag to "no points inside circle"
 (setq ic_f1 T)

; get x,y coordinates for each corner of possible triangle
 (setq ic_x1 (car ic_p1) ic_y1 (cadr ic_p1) ic_x2 (car ic_p2) ic_y2 (cadr ic_p2)
       ic_x3 (car ic_p3) ic_y3 (cadr ic_p3))

; calculate denominator and return "fail" if 0 (points form a single line, no circle possible)
 (setq ic_d1 (- (* (- ic_x1 ic_x2) (- ic_y1 ic_y3)) (* (- ic_x1 ic_x3) (- ic_y1 ic_y2))))
 (if (= ic_d1 0.0)
  (setq ic_f1 nil)
  (progn

; otherwise calculate numerators and then circle centre-point, radius, and bounding square
   (setq ic_n1 (- (+ (* ic_x1 ic_x1) (* ic_y1 ic_y1)) (* ic_x2 ic_x2) (* ic_y2 ic_y2))
         ic_n2 (- (+ (* ic_x1 ic_x1) (* ic_y1 ic_y1)) (* ic_x3 ic_x3) (* ic_y3 ic_y3)))
   (setq ic_x4 (/ (- (* (- ic_y1 ic_y3) ic_n1) (* (- ic_y1 ic_y2) ic_n2)) (* ic_d1 2.0))
         ic_y4 (/ (- (* (- ic_x1 ic_x2) ic_n2) (* (- ic_x1 ic_x3) ic_n1)) (* ic_d1 2.0)))
   (setq ic_r1 (sqrt (+ (* (- ic_x1 ic_x4) (- ic_x1 ic_x4))
                        (* (- ic_y1 ic_y4) (- ic_y1 ic_y4)))))
   (setq ic_x1 (- ic_x4 ic_r1) ic_y1 (- ic_y4 ic_r1)
         ic_x2 (+ ic_x4 ic_r1) ic_y2 (+ ic_y4 ic_r1))

; set counter to start of list of 3D points and check if any points inside circle
   (setq ic_c4 0)
   (while (and (= ic_f1 T) (< ic_c4 (length ic_l1)))

; don't double-check points if already used to create circle
    (if (and (/= ic_c4 ic_c1) (/= ic_c4 ic_c2) (/= ic_c4 ic_c3))
     (progn

; get x,y coordinates of point being checked
      (setq ic_i1 (nth ic_c4 ic_l1))
      (setq ic_x3 (car ic_i1) ic_y3 (cadr ic_i1))

; can ignore points outside bounding square (avoids further time consuming calculations)
      (if (and (>= ic_x3 (- ic_x1 ic_z1)) (>= ic_y3 (- ic_y1 ic_z1))
               (<= ic_x3 (+ ic_x2 ic_z1)) (<= ic_y3 (+ ic_y2 ic_z1)))

; otherwise check if point is inside circle
       (progn
        (setq ic_d1 (sqrt (+ (* (- ic_x3 ic_x4) (- ic_x3 ic_x4))
                             (* (- ic_y3 ic_y4) (- ic_y3 ic_y4)))))

; set flag to "fail" if distance to point is less than radius (fuzz for rounding errors)
        (if (> (- ic_r1 ic_d1) ic_z1)
         (setq ic_f1 nil)
        )
       )
      )
     )
    )

; increase counter to look at next 3D point in list ic_l1
    (setq ic_c4 (1+ ic_c4))
   )
  )
 )

; set flag to itself, so flag value is output from this function
 (setq ic_f1 ic_f1)
)

; =============================================================================================

; TPOP_LINECROSSBREAK
; ===================

; Description:
; ============
; Check if line clashes with any breaklines

; Internal Variables:
; ===================
; lb_p1, lb_p2 = input: each end of line
; lb_l1 = input: list of 2D breaklines
; lb_z1 = input: fuzz value
; lb_f1 = output: T if no clash, nil if clash (lines crossing) found
; lb_c1 = count through list of breaklines
; lb_i1 = individual breakline from list lb_l1
; lb_p3, lb_p4 = each end of lb_i1

(defun tpop_linecrossbreak (lb_p1 lb_p2 lb_l1 lb_z1 / lb_f1 lb_c1 lb_i1 lb_p3 lb_p4)

; set flag to "no clash" and look through list of breaklines
 (setq lb_f1 T lb_c1 0)
 (while (and (= lb_f1 T) (< lb_c1 (length lb_l1)))

; get individual breakline and each end point, then see if lines clash (or cross)
  (setq lb_i1 (nth lb_c1 lb_l1))
  (setq lb_p3 (car lb_i1) lb_p4 (cadr lb_i1))
  (setq lb_f1 (tpop_lineclash lb_p1 lb_p2 lb_p3 lb_p4 lb_z1))

; increase counter to look at next breakline
  (setq lb_c1 (1+ lb_c1))
 )

; set flag to itself, so flag value is output from this function
 (setq lb_f1 lb_f1)
)

; =============================================================================================

; TPOP_TRIACROSSBREAK
; ===================

; Description:
; ============
; Check if possible triangle clashes with any breaklines

; Internal Variables:
; ===================
; tk_p1 = input: first corner of possible 3D triangle
; tk_p2 = input: second corner of possible 3D triangle
; tk_p3 = input: third corner of possible 3D triangle
; tk_l1 = input: list of 2D breaklines
; tk_z1 = input: fuzz value
; tk_f1 = output: T if no clash, nil if clash (lines crossing) found
; tk_c1 = count through three sides of possible 3D triangle
; tk_e1, tk_e2 = each end of current side of possible 3D triangle

(defun tpop_triacrossbreak (tk_p1 tk_p2 tk_p3 tk_l1 tk_z1 / tk_f1 tk_c1 tk_e1 tk_e2)

; set flag to "no clash" and look at each side of possible triangle
 (setq tk_f1 T tk_c1 0)
 (while (and (= tk_f1 T) (< tk_c1 3))
  (setq tk_e1 (nth tk_c1 (list tk_p1 tk_p2 tk_p3))
        tk_e2 (nth tk_c1 (list tk_p2 tk_p3 tk_p1)))

; see if this side clashes with any breaklines
  (setq tk_f1 (tpop_linecrossbreak tk_e1 tk_e2 tk_l1 tk_z1))

; increase counter to look at next side of possible triangle
  (setq tk_c1 (1+ tk_c1))
 )

; set flag to itself, so flag value is output from this function
 (setq tk_f1 tk_f1)
)

; =============================================================================================

; TPOP_VALUEINLIST
; ================

; Description:
; ============
; Check if value is in list provided

; Internal Variables:
; ===================
; vl_v1 = input: value to look for
; vl_l1 = input: list to look in
; vl_f1 = output: flag: T if in list, nil if not in list
; vl_c1 = count through list vl_l1

(defun tpop_valueinlist (vl_v1 vl_l1 / vl_f1 vl_c1)

; set flag output to "not found" and go through list until item found
 (setq vl_f1 nil vl_c1 0)
 (while (and (= vl_f1 nil) (< vl_c1 (length vl_l1)))

; set flag to "found" if matching item found
  (if (= vl_v1 (nth vl_c1 vl_l1))
   (setq vl_f1 T)
  )

; increase counter to look at next item in list
  (setq vl_c1 (1+ vl_c1))
 )

; set flag to itself, so flag value is output from this function
 (setq vl_f1 vl_f1)
)

; =============================================================================================

; TPOP_DRAW3DTRIA
; ===============

; Description:
; ============
; Draw a 3D triangle

; Internal Variables:
; ===================
; dt_p1, dt_p2, dt_p3 = inputs: three corners of the 3D triangle

(defun tpop_draw3dtria (dt_p1 dt_p2 dt_p3 / )

; draw 3D closed polyline (straight edges)
 (entmake (list (cons 0 "POLYLINE") (cons 100 "AcDbEntity") (cons 100 "AcDb3dPolyline")
                (cons 70 9) (list 10 0.0 0.0 0.0)))
 (entmake (list (cons 0 "VERTEX")
                (cons 100 "AcDbEntity") (cons 100 "AcDbVertex") (cons 100 "AcDb3dPolylineVertex")
                (cons 70 32) (append (list 10) dt_p1) (cons 42 0.0)))
 (entmake (list (cons 0 "VERTEX")
                (cons 100 "AcDbEntity") (cons 100 "AcDbVertex") (cons 100 "AcDb3dPolylineVertex")
                (cons 70 32) (append (list 10) dt_p2) (cons 42 0.0)))
 (entmake (list (cons 0 "VERTEX")
                (cons 100 "AcDbEntity") (cons 100 "AcDbVertex") (cons 100 "AcDb3dPolylineVertex")
                (cons 70 32) (append (list 10) dt_p3) (cons 42 0.0)))
 (entmake (list (cons 0 "SEQEND") (cons 100 "AcDbEntity")))
)

; =============================================================================================

; TPOP_GETFUZZVALUE
; =================

; Description:
; ============
; Return fuzz value from user input and global variable

; Global Variables:
; =================
; tpop_fuzzfactor = fuzz/blur factor to allow for rounding errors (0 = none, 1 = small, 9 = big)

; Internal Variables:
; ===================
; gf_z1 = output: fuzz value

(defun tpop_getfuzzvalue ( / gf_z1)

; set fuzz factor to default value if it hasn't been defined yet
 (if (= tpop_fuzzfactor nil)
  (setq tpop_fuzzfactor 5)
 )

; calculate fuzz value
 (if (= tpop_fuzzfactor 0)
  (setq gf_z1 0.0)
  (setq gf_z1 (expt 10.0 (- tpop_fuzzfactor 12.0)))
 )

; set fuzz value to itself, so fuzz value is output from this function
 (setq gf_z1 gf_z1)
)

; =============================================================================================
; OOOOO OOOO   OOO  OOOO  OOOOO OOOO  OOOOO   O
;   O   O   O O   O O   O   O   O   O   O    O O
;   O   OOOO  O   O OOOO    O   OOOO    O   O   O
;   O   O     O   O O       O   O   O   O   OOOOO
;   O   O      OOO  O       O   O   O OOOOO O   O
; =============================================================================================

; TPOPTRIA
; ========

; Description:
; ============
; Draw best-fit triangles on a selection of POINT objects, not crossing LWPOLYLINE objects

; Internal Variables:
; ===================
; z1 = fuzz value
; s1 = selection set (POINTs first, then LWPOLYLINES)
; l1 = ordered list of groups of x,y,z data from selected POINTs
; x1 = minimum x value of all boundary lines
; l2 = list of x,y-x,y boundary lines from selected LWPOLYLINEs
; c1 = count through list l2
; i1 = item in list l2
; p1, p2 = points at each end of line in list l2
; l3 = replacement list of l1 points only inside boundary list l2
; c1 = count through list l1
; p1 = individual point in list l1
; l3 = list of x,y-x,y breaklines from selected LWPOLYLINEs
; l4 = list of 3D triangles (3D POLYLINEs) not crossing breaklines
; l5 = list of 3D triangles (3D POLYLINEs) which do cross breaklines
; c1, c2, c3 = counts through list l1
; p1, p2, p3 = 3D points in list l1
; c1 = count of how many times list l5 has been processed (limit to avoid function hanging)
; c2 = count through list l5
; l6 = list of post-processed l5 triangles which still cross breaklines (later becomes l5)
; l7 = list of counter for triangles added to list l6 so far
; f1 = flag: T if matching pair of triangles has been found and swapped round
; c3 = count through sides of each triangle in list l5
; i1 = item in list l5
; p1, p2, p3 = 3D points in item i1
; c4 = count through triangles after c2 in list l5
; i2 = item (from c4) in list l5
; c5 = count through sides of triangle i2
; p4, p5, p6 = 3D points in item i2

(defun C:TPOPTRIA ( / z1 s1 l1 x1 l2 c1 i1 p1 p2 l3 l4 l5 c2 c3 p3 l6 l7 f1 c4 i2 c5 p4 p5 p6)
 (tpop_atstart)

; get fuzz value
 (setq z1 (tpop_getfuzzvalue))

; ask user to select POINT objects
 (princ "\nSelect POINT objects...")
 (if (= (setq s1 (ssget (list (cons 0 "POINT")))) nil)
  (princ "\nNo POINTs selected. Command terminating")
  (progn

; get ordered list from selected POINT objects (and discard selection set, as no longer needed)
   (setq l1 (tpop_getpointlist s1))
   (setq s1 nil)

; set min x on boundary line(s) to "not set"
   (setq x1 nil)

; ask user to select LWPOLYLINE objects (can continue if none selected)
   (princ "\nSelect lightweight closed PLINE boundary objects (if any)...")
   (if (= (setq s1 (ssget (list (cons 0 "LWPOLYLINE")))) nil)
    (setq l2 nil)
    (progn

; get list of boundary lines from closed LWPOLYLINE objects (discard this selection set too)
     (setq l2 (tpop_getlinelist s1 T))
     (setq s1 nil)

; if boundary lines exist
     (if (/= l2 nil)
      (progn

; get minimum x value of all boundary lines
       (setq c1 0)
       (while (< c1 (length l2))
        (setq i1 (nth c1 l2))

; get points at each end of each boundary line
        (setq p1 (nth 0 i1) p2 (nth 1 i1))
        (if (= c1 0)
         (setq x1 (min (car p1) (car p2)))
         (setq x1 (min x1 (car p1) (car p2)))
        )
        (setq c1 (1+ c1))
       )

; reduce point list to only those inside the boundary lines - start with empty new list
       (setq l3 nil c1 0)
       (while (< c1 (length l1))
        (setq p1 (nth c1 l1))

; only adding point to new list if point is inside boundary
        (if (= (tpop_pointinboundary p1 l2 x1 z1) T)
         (setq l3 (tpop_addtolist l3 p1))
        )
        (setq c1 (1+ c1))
       )

; replace original point list with new point list (new list could be empty)
       (setq l1 l3)
      )
     )
    )
   )

; if user has selected more than 50 points advise them it'll take a while, and confirm
   (if (>= (length l1) 50)
    (progn
     (princ (strcat "\n*** NOTE: It could take many minutes to process "
                    (itoa (length l1)) " points ***"))
     (princ (strcat "\nIt might be quicker to draw 2D polylines as boundaries around groups"
                    " of points (up to about 50 points per group) and rerun TPOPTRIA on"
                    " each group of points in turn (boundaries can pass through points"
                    " where groups are adjacent to each other, or away from points around"
                    " the edge of the point sample)"))
     (initget "yes no")
     (if (= (getkword "\nDo you want to continue anyway? ") "no")
      (progn
       (setq l1 nil)
       (princ "\nCommand terminating")
      )
     )
    )
   )

; keep going if list of points still exist   
   (if (/= l1 nil)
    (progn

; ask user to select LWPOLYLINE objects (can continue if none selected)
     (princ "\nSelect lightweight PLINE breakline objects (if any)...")
     (if (= (setq s1 (ssget (list (cons 0 "LWPOLYLINE")))) nil)
      (setq l3 nil)
      (progn

; get list of breaklines from (open/closed) LWPOLYLINE objects (discard this selection set)
       (setq l3 (tpop_getlinelist s1 nil))
       (setq s1 nil)
      )
     )

; add boundary lines list to breaklines list (as boundary is a special type of breakline)
     (if (/= l2 nil)
      (if (= l3 nil)
       (setq l3 l2)
       (setq l3 (append l3 l2))
      )
     )

; go through all possible triangles in points list, set empty triangle lists
     (setq c1 0 l4 nil l5 nil)
     (while (< c1 (length l1))

; display progress message (but not 0% progress)
; (10 is a balance between lower number = slower command, higher number = less info)
      (if (and (> c1 0) (= (rem c1 10) 0))
       (princ (strcat "\n" (rtos (/ (* 100.0 c1) (length l1)) 2 0)
                      "% of points processed"))
      )

; get first corner of possible triangle
      (setq p1 (nth c1 l1))
      (setq c2 (1+ c1))
      (while (< c2 (length l1))

; get second corner of possible triangle
       (setq p2 (nth c2 l1))
       (setq c3 (1+ c2))
       (while (< c3 (length l1))

; get third corner of possible triangle
        (setq p3 (nth c3 l1))

; continue if possible triangle doesn't cross any existing triangles
        (if (and (= (tpop_triangleclash p1 p2 p3 l4 z1) T)
                 (= (tpop_triangleclash p1 p2 p3 l5 z1) T))

; continue if no other points found within circle created by three points
         (if (= (tpop_pointsincircle c1 c2 c3 p1 p2 p3 l1 z1) T)

; draw/add new 3D triangle to triangles lists, depending on if crosses breaklines or not
          (if (= (tpop_triacrossbreak p1 p2 p3 l3 z1) T)
           (progn

; but only draw triangle if it's centre is inside boundary line (still add it to list)
            (if (= (tpop_triainboundary p1 p2 p3 l2 x1 z1) T)
             (tpop_draw3dtria p1 p2 p3)
            )
            (setq l4 (tpop_addtolist l4 (list p1 p2 p3)))
           )
           (setq l5 (tpop_addtolist l5 (list p1 p2 p3)))
          )
         )
        )

; increase counters for each corner
        (setq c3 (1+ c3))
       )
       (setq c2 (1+ c2))
      )
      (setq c1 (1+ c1))
     )

; display progress message
     (princ "\n100% of points processed")

; display progress message if triangles are crossing breaklines
     (if (/= l5 nil)
      (progn
       (princ "\nProcessing triangles affected by breaklines/boundary")

; process list of triangles that cross breaklines until list contains < 2 triangles
; or list length remains unchanged for more times than the list length + 12
; (this can occur for example when breaklines cross or cross boundary lines resulting in
; individual pairs of triangles flipping back and forth on each iteration of loop)
; (12 is a guess - if triangles are missing by breaklines/boundaries, then try higher no.)
       (setq c1 0)
       (while (and (> (length l5) 1) (< c1 (+ 12 (length l5))))

; create empty lists and go through each triangle in current triangle list
        (setq l6 nil l7 nil c2 0)
        (while (< c2 (length l5))

; if triangle not already been swapped in this loop, look for triangle with matching side
         (if (= (tpop_valueinlist c2 l7) nil)
          (progn
           (setq i1 (nth c2 l5) c3 0 f1 T)

; go through each side of triangle and if crosses breakline, look for match on that side
           (while (and (= f1 T) (< c3 3))
            (setq p1 (nth (nth c3 (list 0 1 2)) i1)
                  p2 (nth (nth c3 (list 1 2 0)) i1)
                  p3 (nth (nth c3 (list 2 0 1)) i1))
            (if (= (tpop_linecrossbreak p1 p2 l3 z1) nil)
             (progn

; find subsequent triangle that shares the side p1-p2 (skip triangles already changed)
              (setq c4 (1+ c2))
              (while (and (= f1 T) (< c4 (length l5)))
               (if (= (tpop_valueinlist c4 l7) nil)
                (progn
                 (setq i2 (nth c4 l5) c5 0)

; look at each side of each subsequent triangle
                 (while (and (= f1 T) (< c5 3))
                  (setq p4 (nth (nth c5 (list 0 1 2)) i2)
                        p5 (nth (nth c5 (list 1 2 0)) i2)
                        p6 (nth (nth c5 (list 2 0 1)) i2))

; found subsequent triangle with matching side
                  (if (= (tpop_eqline p1 p2 p4 p5) T)

; check line between points not on matching side crosses line along matching side
; (this ensures triangles only switched if combined outline/shape remains the same)
                   (if (= (tpop_lineclash p3 p6 p1 p2 z1) nil)

; and check both swapped triangles do not clash with existing triangles
                    (if (and (= (tpop_triangleclash p3 p1 p6 l4 z1) T)
                             (= (tpop_triangleclash p3 p1 p6 l6 z1) T)
                             (= (tpop_triangleclash p3 p2 p6 l4 z1) T)
                             (= (tpop_triangleclash p3 p2 p6 l6 z1) T))
                     (progn

; add counter of matching triangles to list, so they're not looked at again in current loop
                      (setq l7 (tpop_addtolist l7 c2))
                      (setq l7 (tpop_addtolist l7 c4))

; draw/add 1st swapped triangle to triangles lists, depending on if crosses breaklines or not
                      (if (= (tpop_triacrossbreak p3 p1 p6 l3 z1) T)
                       (progn

; but only draw triangle if it's centre is inside boundary line (still add it to list)
                        (if (= (tpop_triainboundary p3 p1 p6 l2 x1 z1) T)
                         (tpop_draw3dtria p3 p1 p6)
                        )
                        (setq l4 (tpop_addtolist l4 (list p3 p1 p6)))
                       )
                       (setq l6 (tpop_addtolist l6 (list p3 p1 p6)))
                      )

; draw/add 2nd swapped triangle to triangles lists, depending on if crosses breaklines or not
                      (if (= (tpop_triacrossbreak p3 p2 p6 l3 z1) T)
                       (progn

; but only draw triangle if it's centre is inside boundary line (still add it to list)
                        (if (= (tpop_triainboundary p3 p2 p6 l2 x1 z1) T)
                         (tpop_draw3dtria p3 p2 p6)
                        )
                        (setq l4 (tpop_addtolist l4 (list p3 p2 p6)))
                       )
                       (setq l6 (tpop_addtolist l6 (list p3 p2 p6)))
                      )

; set flag to nil to stop checking current triangle (as it's been swapped, so no longer valid)
                      (setq f1 nil)
                     )
                    )
                   )
                  )

; increase counters for sides of and count of match triangle, and initial comparison triangle
                  (setq c5 (1+ c5))
                 )
                )
               )
               (setq c4 (1+ c4))
              )
             )
            )
            (setq c3 (1+ c3))
           )

; if triangle hasn't been changed (couldn't find triangle with matching sides) add it to new list
           (if (= f1 T)
            (progn
             (setq p1 (nth 0 i1) p2 (nth 1 i1) p3 (nth 2 i1))
             (setq l6 (tpop_addtolist l6 (list p1 p2 p3)))
            )
           )
          )
         )
         (setq c2 (1+ c2))
        )

; if new list has same length as old list, increase repetition counter to avoid hanging
        (if (= (length l5) (length l6))
         (setq c1 (1+ c1))

; otherwise reset repetition counter
         (setq c1 0)
        )

; replace current list of triangles crossing breaklines with new list of such triangles
        (setq l5 l6)
       )
      )
     )

; tell user command has finished (command can take a while if lots of points selected)
     (princ "\nCommand finished")
    )
   )
  )
 )
 (tpop_atend)
 (princ)
)

; =============================================================================================

; TPOP_GETTRIALIST
; ================

; Description:
; ============
; Create list of 3D triangles ((x,y,z)(x,y,z)(x,y,z) groups) from 3D POLYINEs in selection set

; Internal Variables:
; ===================
; tl_s1 = input: selection set list
; tl_f1 = input: T = output to include both tl_l1 and tl_l2, nil = just tl_l1
; tl_c1 = counter through list ll_s1
; tl_l1 = output: list of (x,y,z)(x,y,z)(x,y,z) triangle groups
; tl_l2 = output: list of entity names for each group in list tl_l1
; tl_d1 = entity data for object in selection set
; tl_e1 = entity name for object in selection set
; tl_i1 = list of (x,y,z) groups from tl_d1
; tl_e2 = entity name for subsequent objects (e.g. vertices etc.)

(defun tpop_gettrialist (tl_s1 tl_f1 / tl_c1 tl_l1 tl_l2 tl_d1 tl_e1 tl_i1 tl_e2)

; go through each object in selection set
 (setq tl_c1 0 tl_l1 nil tl_l2 nil)
 (repeat (sslength tl_s1)

; get object's data list, and process if it's a closed 3D polyline, and set empty x,y,z list
  (setq tl_d1 (entget (setq tl_e1 (ssname tl_s1 tl_c1))) tl_i1 nil)
  (if (= (cdr (assoc 70 tl_d1)) 9)
   (progn

; keep getting next entity name and data until none available or non-vertex found
    (setq tl_e2 (entnext tl_e1))
    (while (/= tl_e2 nil)
     (setq tl_d1 (entget tl_e2))
     (if (/= (cdr (assoc 0 tl_d1)) "VERTEX")
      (setq tl_e2 nil)
      (progn
       (setq tl_e2 (entnext tl_e2))

; add x,y,z data to list if no bulge factor or if bulge factor is zero (i.e. straight line)
       (if (= (assoc 42 tl_d1) nil)
        (setq tl_i1 (tpop_addtolist tl_i1 (cdr (assoc 10 tl_d1))))
        (if (= (cdr (assoc 42 tl_d1)) 0.0)
         (setq tl_i1 (tpop_addtolist tl_i1 (cdr (assoc 10 tl_d1))))
        )
       )
      )
     )
    )

; if collated x,y,z data for this object contains three items, add it to output list
; (also add entity name of parent object to second list)
    (if (= (length tl_i1) 3)
     (setq tl_l1 (tpop_addtolist tl_l1 tl_i1)
           tl_l2 (tpop_addtolist tl_l2 tl_e1))
    )
   )
  )

; increase counter to look at next object in selection set
  (setq tl_c1 (1+ tl_c1))
 )

; if input flag is true, combine output lists (if they exist), otherwise discard second list
 (if (and (= tl_f1 T) (/= tl_l1 nil))
  (setq tl_l1 (list tl_l1 tl_l2))
 )

; set triangle (+ entity name) list to itself, so list is output from this function
 (setq tl_l1 tl_l1)
)

; =============================================================================================

; TPOP_GETTRIANGLES
; =================

; Description:
; ============
; Ask user to select 3D triangles (3D POLYLINES) and convert to list of x,y,z groups

; Internal Variables:
; ===================
; gt_f1 = input: flag: T = output to include entity names, nil = output just x,y,z data
; gt_t1 = input: name of layer to search on, or ignore layers if = nil
; gt_l1 = output: list of groups of x,y,z (+ entity name) data for each 3D triangle
; gt_s1 = selection set of 3D POLYLINEs

(defun tpop_gettriangles (gt_f1 gt_t1 / gt_l1 gt_s1)

; set output as "no list" by default
 (setq gt_l1 nil)

; ask user to select POLYLINE objects, on particular layer if layer name provided
 (if (= gt_t1 nil)
  (progn
   (princ "\nSelect 3D POLYLINE triangles...")
   (setq gt_s1 (ssget (list (cons 0 "POLYLINE"))))
  )
  (progn
   (princ (strcat "\nSelect 3D POLYLINE triangles on layer " gt_t1 "..."))
   (setq gt_s1 (ssget (list (cons 0 "POLYLINE") (cons 8 gt_t1))))
  )
 )

; display error message if no POLYLINEs selected
 (if (= gt_s1 nil)
  (princ "\nNo 3D POLYLINEs selected. Command terminating")
  (progn

; get groups of x,y,z data (+ entity names if gt_f1=T) for each 3D triangle selected
   (setq gt_l1 (tpop_gettrialist gt_s1 gt_f1))

; discard selection set as no longer needed (and frees computer memory)
   (setq gt_s1 nil)

; error message if none of the 3D POLYLINEs selected had 3 vertices and were closed
   (if (= gt_l1 nil)
    (princ "\nNone of these 3D POLYLINEs are closed triangles. Command terminating")
   )
  )
 )

; set triangle (+ entity name) list to itself, so list is output from this function
 (setq gt_l1 gt_l1)
)

; =============================================================================================
; OOOOO OOOO   OOO  OOOO   OOOO O   O   O   OOOO
;   O   O   O O   O O   O O     O   O  O O  O   O
;   O   OOOO  O   O OOOO   OOO  O O O O   O OOOO
;   O   O     O   O O         O OO OO OOOOO O
;   O   O      OOO  O     OOOO  O   O O   O O
; =============================================================================================

; TPOPSWAP
; ========

; Description:
; ============
; Swap shared edges two adjacent 3D POLYLINE triangles

; Internal Variables:
; ===================
; l1 = list of groups of ((x,y,z)(x,y,z)(x,y,z)) data from each 3D triangle
; l2 = list of entity names for each object in list l1
; z1 = fuzz value
; i1 = ((x,y,z)(x,y,z)(x,y,z)) data for first triangle
; i2 = ((x,y,z)(x,y,z)(x,y,z)) data for second triangle
; f1 = flag: T = keep on comparing triangle sides
; c1 = count through sides of first triangle
; p1, p2, p3 = 3D points at corners of first triangle
; c2 = count through sides of second triangle
; p4, p5, p6 = 3D points at corners of second triangle

(defun C:TPOPSWAP ( / l1 l2 z1 i1 i2 f1 c1 p1 p2 p3 c2 p4 p5 p6)
 (tpop_atstart)

; get lists of x,y,z groups and entity names from user-selected POLYLINE objects
 (if (/= (setq l1 (tpop_gettriangles T nil)) nil)
  (progn
   (setq l2 (cadr l1))
   (setq l1 (car l1))

; error message if less or more than two 3D polylines selected
   (if (/= (length l1) 2)
    (princ "\nLess or more than two 3D POLYLINEs selected. Command terminating")
    (progn

; get fuzz value
     (setq z1 (tpop_getfuzzvalue))

; get x,y,z lists for each triangle, and set counter for first triangle
     (setq i1 (nth 0 l1) i2 (nth 1 l1) f1 T c1 0)

; go through each side of first triangle (until a match is found)
     (while (and (= f1 T) (< c1 3))
      (setq p1 (nth (nth c1 (list 0 1 2)) i1) p2 (nth (nth c1 (list 1 2 0)) i1)
            p3 (nth (nth c1 (list 2 0 1)) i1))

; set counter for second triangle and go through each side of second triangle
      (setq c2 0)
      (while (and (= f1 T) (< c2 3))
       (setq p4 (nth (nth c2 (list 0 1 2)) i2) p5 (nth (nth c2 (list 1 2 0)) i2)
             p6 (nth (nth c2 (list 2 0 1)) i2))

; if found shared side
       (if (= (tpop_eqline p1 p2 p4 p5) T)
        (progn

; set flag to nil so stops comparing triangle sides
         (setq f1 nil)

; and check can swap triangles without changing overall combined shape/outline
         (if (= (tpop_lineclash p3 p6 p1 p2 z1) T)
          (princ (strcat "\nUnable to swap these triangles without changing combined outline."
                         " Command terminating"))
          (progn

; if all ok, delete selected 3D polylines, and draw two new ones
           (entdel (nth 0 l2))
           (entdel (nth 1 l2))
           (tpop_draw3dtria p3 p1 p6)
           (tpop_draw3dtria p3 p2 p6)
          )
         )
        )
       )

; increase counters to look at next sides on triangles
       (setq c2 (1+ c2))
      )
      (setq c1 (1+ c1))
     )

; show message if compared all sides but found no match
     (if (= f1 T)
      (princ "\nNo common edge found for two triangles selected. Command terminating")
     )
    )
   )
  )
 )
 (tpop_atend)
 (princ)
)

; =============================================================================================

; TPOP_GETRATIO
; =============

; Description:
; ============
; Return flatness ratio for 3D triangle

; Internal Variables:
; ===================
; gr_i1 = input: one ((x,y,z)(x,y,z)(x,y,z)) group of data for 3D triangle
; gr_c1 = count through sides of triangle
; gr_p1, gr_p2, gr_p3 = coordinates at corners of triangle
; gr_x1, gr_y1, gr_x2, gr_y2, gr_x3, gr_y3 = x,y values of gr_p1, gr_p2 and gr_p3
; gr_d1 = denominator for calculating ratio
; gr_r1 = running ratio for each side of triangle i1
; gr_r2 = output: maximum ratio value

(defun tpop_getratio (gr_i1 / gr_c1 gr_p1 gr_p2 gr_p3 gr_x1 gr_y1 gr_x2
                              gr_y2 gr_x3 gr_y3 gr_d1 gr_r1 gr_r2)

; calculate ratio for each side of triangle, remembering maximum ratio value
 (setq gr_c1 0)
 (while (< gr_c1 3)
  (setq gr_p1 (nth (nth gr_c1 (list 0 1 2)) gr_i1) gr_p2 (nth (nth gr_c1 (list 1 2 0)) gr_i1)
        gr_p3 (nth (nth gr_c1 (list 2 0 1)) gr_i1))
  (setq gr_x1 (car gr_p1) gr_y1 (cadr gr_p1) gr_x2 (car gr_p2) gr_y2 (cadr gr_p2)
        gr_x3 (car gr_p3) gr_y3 (cadr gr_p3))

; calculate denominator of ratio, and if 0 (should never happen) stop looking at triangle
  (setq gr_d1 (- (* (- gr_x3 gr_x1) (- gr_y2 gr_y1)) (* (- gr_x2 gr_x1) (- gr_y3 gr_y1))))
  (if (= gr_d1 0.0)
   (setq gr_r2 0.0 gr_c1 3)
   (progn

; calculate ratio, and if first side use it, otherwise use it if bigger than current max
    (setq gr_r1 (abs (/ (+ (* (- gr_x2 gr_x1) (- gr_x2 gr_x1))
                           (* (- gr_y2 gr_y1) (- gr_y2 gr_y1))) gr_d1)))
    (if (= gr_c1 0)
     (setq gr_r2 gr_r1)
     (setq gr_r2 (max gr_r2 gr_r1))
    )
   )
  )

; increase counter to look at next side of triangle
  (setq gr_c1 (1+ gr_c1))
 )

; set ratio  to itself, so ratio value is output from this function
 (setq gr_r2 gr_r2)
)

; =============================================================================================
; OOOOO OOOO   OOO  OOOO   OOO  OOOOO OOOOO OOOOO O   O OOOOO O   O
;   O   O   O O   O O   O O     O       O     O   O   O   O   OO  O
;   O   OOOO  O   O OOOO  O  OO OOOO    O     O   OOOOO   O   O O O
;   O   O     O   O O     O   O O       O     O   O   O   O   O  OO
;   O   O      OOO  O      OOO  OOOOO   O     O   O   O OOOOO O   O
; =============================================================================================

; TPOPGETTHIN
; ===========

; Description:
; ============
; List max/min flatness ratios for selection set of 3D triangles

; Internal Variables:
; ===================
; l1 = list of groups of ((x,y,z)(x,y,z)(x,y,z)) data from 3D triangles
; c1 = count through list l1
; r1 = flatness ratio for individual triangle in list l1
; m1, m2 = minimum/maximum ratio values

(defun C:TPOPGETTHIN ( / l1 c1 r1 m1 m2)
 (tpop_atstart)

; get list of x,y,z groups from user-selected 3D POLYLINE triangles
 (if (/= (setq l1 (tpop_gettriangles nil nil)) nil)
  (progn

; look through list of 3D triangles
   (setq c1 0)
   (while (< c1 (length l1))

; get flatness ratio for each one
    (setq r1 (tpop_getratio (nth c1 l1)))

; store minimum/maximum values
    (if (= c1 0)
     (setq m1 r1 m2 r1)
     (setq m1 (min m1 r1) m2 (max m2 r1))
    )

; increase counter to look at next 3D triangle
    (setq c1 (1+ c1))
   )

; display the results
   (princ (strcat "\nRatio of " (itoa (length l1)) " triangle(s) measured"
                  "\nminimum ratio = " (rtos m1 2 3)
                  " maximum ratio = " (rtos m2 2 3)))
  )
 )
 (tpop_atend)
 (princ)
)

; =============================================================================================
; OOOOO OOOO   OOO  OOOO  OOOO  OOOOO O     OOOOO O   O OOOOO O   O
;   O   O   O O   O O   O O   O O     O       O   O   O   O   OO  O
;   O   OOOO  O   O OOOO  O   O OOOO  O       O   OOOOO   O   O O O
;   O   O     O   O O     O   O O     O       O   O   O   O   O  OO
;   O   O      OOO  O     OOOO  OOOOO OOOOO   O   O   O OOOOO O   O
; =============================================================================================

; TPOPDELTHIN
; ===========

; Description:
; ============
; Delete 3D triangles that are so flat they're almost like lines (option for on edge only)

; Global Variables:
; =================
; tpop_thinratio = select 3D triangles where longest side:perpendicular are above this ratio
; tpop_edgetria = flag: T = select triangles on edge only (i.e. without 3 adjacent neighbours)

; Internal Variables:
; ===================
; l1 = list of groups of ((x,y,z)(x,y,z)(x,y,z)) data from 3D triangles
; l2 = list of entity names for each object in list l1
; r1 = comparison ratio determines whether to select triangle
; t1 = text to ask user whether to select triangles on edge of selection set only
; f1 = flag: T = only select triangles on edge of selection set (i.e. without 3 neighbours)
; f2 = flag: T = triangles have been deleted
; c1 = count of triangles deleted
; c2 = count through list l1
; l3 = list of groups of ((x,y,z)(x,y,z)(x,y,z)) data of triangles not deleted
; l4 = list of entity names of triangles not deleted (triangles in same order as l3)
; i1 = individual triangle in list l1
; f3 = flag: T = triangle has three neighbours
; c3 = count through each side of triangle i1
; p1, p2 = coordinates at each end of side of triangle i1 being looked at
; c4 = count through list l1 (counting triangles adjacent to i1)
; f4 = flag: T = keep looking for matching side
; i2 = individual comparison triangle
; c5 = count through each side of comparison triangle i2
; p3, p4 = coordinates at each end of side of comparison triangle i2

(defun C:TPOPDELTHIN ( / l1 l2 r1 t1 f1 f2 c1 c2 l3 l4 i1 f3 c3 p1 p2 c4 f4 i2 c5 p3 p4)
 (tpop_atstart)

; get lists of x,y,z groups and entity names from user-selected 3D POLYLINE triangles
 (if (/= (setq l1 (tpop_gettriangles T nil)) nil)
  (progn
   (setq l2 (cadr l1))
   (setq l1 (car l1))

; get ratio above which to select triangles (ratio of longest edge to perpendicular)
   (setq r1 (tpop_getglobalval "Enter ratio above which to select triangles (min 5.0)"
             tpop_thinratio 20.0 nil))
   (if (< r1 5.0)
    (setq r1 5.0)
   )
   (setq tpop_thinratio r1)

; get whether to select only triangles on edge of selection set
   (setq t1 "Select triangles on edge of selection set only?")
   (if (= tpop_edgetria nil)
    (setq t1 (strcat t1 " <No> "))
    (setq t1 (strcat t1 " <Yes> "))
   )
   (initget 0 "yes no")
   (if (= (setq f1 (getkword t1)) nil)
    (setq f1 tpop_edgetria)
    (if (= f1 "yes")
     (setq f1 T)
     (setq f1 nil)
    )
   )
   (setq tpop_edgetria f1)

; keep looking through list l1 until it's empty, or no longer deleting triangles
; also set count of number of triangles deleted to zero
   (setq f2 T c1 0)
   (while (and (= f2 T) (/= l1 nil))

; set counter to start of l1, empty lists of non-deleted triangles, no deleted triangles yet
    (setq c2 0 l3 nil l4 nil f2 nil)

; look at each 3D triangle in list
    (while (< c2 (length l1))
     (setq i1 (nth c2 l1))

; if triangle has ratio at or below threshold ratio add it to list of non-deleted triangles
     (if (<= (tpop_getratio i1) r1)
      (setq l3 (tpop_addtolist l3 (nth c2 l1)) l4 (tpop_addtolist l4 (nth c2 l2)))

; otherise if triangle has ratio above threshold ratio look for neighbours and/or delete it
      (progn

; if "on edge?" flag not set, set "has three neighbours flag" to nil
       (if (/= f1 T)
        (setq f3 nil)
        (progn

; otherwise look for neighbouring/adjacent triangles
; go through each side of triangle, set "has three neighbours" flag to T
         (setq f3 T c3 0)
         (while (and (= f3 T) (< c3 3))
          (setq p1 (nth (nth c3 (list 0 1 2)) i1) p2 (nth (nth c3 (list 1 2 0)) i1))

; go through all other triangles in list l1, set "keep looking" flag to T
          (setq c4 0 f4 T)
          (while (and (= f4 T) (< c4 (length l1)))

; don't compare main triangle to itself
           (if (/= c4 c2)
            (progn

; otherwise get data for each comparison triangle, and go through each of its sides
             (setq i2 (nth c4 l1) c5 0)
             (while (and (= f4 T) (< c5 3))
              (setq p3 (nth (nth c5 (list 0 1 2)) i2) p4 (nth (nth c5 (list 1 2 0)) i2))

; if found shared side set "keep looking" flag to nil
              (if (= (tpop_eqline p1 p2 p3 p4) T)
               (setq f4 nil)
              )

; increase counters for comparison triangle sides, and comparison triangles from list
              (setq c5 (1+ c5))
             )
            )
           )
           (setq c4 (1+ c4))
          )

; if didn't find a matching side, set "has 3 neighbours flag" to false to exit loop
          (if (= f4 T)
           (setq f3 nil)
          )
          (setq c3 (1+ c3))
         )
        )
       )

; if triangle is on edge of selection delete it
       (if (= f3 nil)
        (progn
         (entdel (nth c2 l2))

; increase "triangles deleted" counter and set "triangle has been deleted" flag to T
         (setq c1 (1+ c1) f2 T)
        )

; otherwise add it to list of non-deleted triangles
        (setq l3 (tpop_addtolist l3 (nth c2 l1)) l4 (tpop_addtolist l4 (nth c2 l2)))
       )
      )
     )

; increase counter to look at next triangle in selection set
     (setq c2 (1+ c2))
    )

; transfer lists of non-deleted triangles to main lists (only if f1 = T)
    (if (= f1 T)
     (setq l1 l3 l2 l4)
     (setq l1 nil l2 nil)
    )
   )

; display message of number of triangles deleted
   (princ (strcat "\n" (itoa c1) " triangle(s) deleted"))
  )
 )
 (tpop_atend)
 (princ)
)

; =============================================================================================

; TPOP_GETSLOPE
; =============

; Description:
; ============
; Get slope values in x and y directions for 3D triangle

; Internal Variables:
; ===================
; gs_i1 = input: one ((x,y,z)(x,y,z)(x,y,z)) group of data for 3D triangle
; gs_p1, gs_p2, gs_p3 = coordinates at corners of triangle gs_i1
; gs_x1, gs_y1, gs_z1 = x,y,z coordinates of point gs_p1
; gs_x2, gs_y2, gs_z2 = x,y,z coordinates of point gs_p2
; gs_x3, gs_y3, gs_z3 = x,y,z coordinates of point gs_p3
; gs_d1, gs_d2 = denominators to calculate slopes in x and y directions (then slope values)
; gs_l1 = output: list of pair of slope values in x and y directions (nil of vertical plane)

(defun tpop_getslope (gs_i1 / gs_p1 gs_p2 gs_p3 gs_x1 gs_y1 gs_z1 gs_x2 gs_y2
                              gs_z2 gs_x3 gs_y3 gs_z3 gs_d1 gs_d2 gs_l1)

; get x,y,z coordinates for each corner of triangle
 (setq gs_p1 (nth 0 gs_i1) gs_p2 (nth 1 gs_i1) gs_p3 (nth 2 gs_i1))
 (setq gs_x1 (car gs_p1) gs_y1 (cadr gs_p1) gs_z1 (caddr gs_p1)
       gs_x2 (car gs_p2) gs_y2 (cadr gs_p2) gs_z2 (caddr gs_p2)
       gs_x3 (car gs_p3) gs_y3 (cadr gs_p3) gs_z3 (caddr gs_p3))

; calculate denominators for getting slope values in x and y directions
 (setq gs_d1 (- (* (- (* gs_x1 gs_y3) (* gs_x3 gs_y1)) (- gs_y1 gs_y2))
                (* (- (* gs_x1 gs_y2) (* gs_x2 gs_y1)) (- gs_y1 gs_y3)))
       gs_d2 (- (* (- (* gs_x3 gs_y1) (* gs_x1 gs_y3)) (- gs_x1 gs_x2))
                (* (- (* gs_x2 gs_y1) (* gs_x1 gs_y2)) (- gs_x1 gs_x3))))

; if either are non-zero (i.e. a vertical plane) no answer is possible
 (if (or (= gs_d1 0.0) (= gs_d2 0.0))
  (setq gs_l1 nil)
  (progn

; otherwise calculate slopes in x and y directions and create list of slopes
   (setq gs_d1 (/ (- (* (- (* gs_y1 gs_z2) (* gs_y2 gs_z1)) (- gs_y1 gs_y3))
                     (* (- (* gs_y1 gs_z3) (* gs_y3 gs_z1)) (- gs_y1 gs_y2))) gs_d1)
         gs_d2 (/ (- (* (- (* gs_x1 gs_z2) (* gs_x2 gs_z1)) (- gs_x1 gs_x3))
                     (* (- (* gs_x1 gs_z3) (* gs_x3 gs_z1)) (- gs_x1 gs_x2))) gs_d2))
   (setq gs_l1 (list gs_d1 gs_d2))
  )
 )

; set slope list to itself, so list is output from this function
 (setq gs_l1 gs_l1)
)

; =============================================================================================
; OOOOO OOOO   OOO  OOOO   OOOO  OOO  O     OOOOO OOOO
;   O   O   O O   O O   O O     O   O O       O   O   O
;   O   OOOO  O   O OOOO   OOO  O   O O       O   O   O
;   O   O     O   O O         O O   O O       O   O   O
;   O   O      OOO  O     OOOO   OOO  OOOOO OOOOO OOOO
; =============================================================================================

; TPOPSOLID
; =========

; Description:
; ============
; Draw 3 point 2D SOLIDs over selected 3D triangles (copying any colour values)

; Global Variables:
; =================
; tpop_solidzaverage = flag: T = z coordinate is average of z values of each triangle
;                            nil = z coordinate is slope (%) of each triangle
; tpop_solidcopycolour = flag: T = copy colour of source triangle, nil = use default colour

; Internal Variables:
; ===================
; t1 = text to ask user which type of z value to use, and whether to copy triangle colours
; f1 = flag: T = use average z value, or copy triangle colours
; l1 = list of groups of ((x,y,z)(x,y,z)(x,y,z)) data from 3D triangles
; l2 = list of entity names of 3D triangles
; c1 = count through list l1
; i1 = individual triangle's x,y,z data in list l1
; e1 = entity data of triangle in list l1
; p1, p2, p3 = x,y,z coordiantes of each corner of triangle
; z1 = average z-coordinate of each corner of triangle
; d1 = data for creating SOLID object

(defun C:TPOPSOLID ( / t1 f1 l1 l2 c1 i1 e1 p1 p2 p3 z1 d1)
 (tpop_atstart)

; ask whether z coordinate of SOLID should be average z of triangle corners, or slope
 (setq t1 (strcat "Draw SOLIDs with z coordinate based on average of each triangle's "
                  "corner z values or based on each triangle's maximum slope value?"))
 (if (= tpop_solidzaverage T)
  (setq t1 (strcat t1 " <Average> "))
  (setq t1 (strcat t1 " <Slope> "))
 )
 (initget 0 "average slope")
 (if (= (setq f1 (getkword t1)) nil)
  (setq f1 tpop_solidzaverage)
  (if (= f1 "average")
   (setq f1 T)
   (setq f1 nil)
  )
 )
 (setq tpop_solidzaverage f1)

; ask whether to copy source triangle's colour value or not
 (setq t1 "Copy each triangle's colour?")
 (if (= tpop_solidcopycolour T)
  (setq t1 (strcat t1 " <Yes> "))
  (setq t1 (strcat t1 " <No> "))
 )
 (initget 0 "yes no")
 (if (= (setq f1 (getkword t1)) nil)
  (setq f1 tpop_solidcopycolour)
  (if (= f1 "yes")
   (setq f1 T)
   (setq f1 nil)
  )
 )
 (setq tpop_solidcopycolour f1)

; get list of entity names and x,y,z groups from user-selected 3D POLYLINE triangles
 (if (/= (setq l1 (tpop_gettriangles T nil)) nil)
  (progn
   (setq l2 (cadr l1))
   (setq l1 (car l1))

; look through lists, getting data for each triangle
   (setq c1 0)
   (while (< c1 (length l1))
    (setq i1 (nth c1 l1) e1 (entget (nth c1 l2)))

; get corner points for individual triangle
    (setq p1 (nth 0 i1) p2 (nth 1 i1) p3 (nth 2 i1))

; depending on flag either calculate average z-coordinate of triangle corners
    (if (= tpop_solidzaverage T)
     (setq z1 (/ (+ (caddr p1) (caddr p2) (caddr p3)) 3.0))

; or get slope of triangle (or 0.0 if no slope available)
     (progn
      (if (= (setq z1 (tpop_getslope (list p1 p2 p3))) nil)
       (setq z1 0.0)
       (setq z1 (* 100.0 (sqrt (+ (* (car z1) (car z1)) (* (cadr z1) (cadr z1))))))
      )
     )
    )

; update corners with new z value
    (setq p1 (list (car p1) (cadr p1) z1) p2 (list (car p2) (cadr p2) z1)
          p3 (list (car p3) (cadr p3) z1))

; create new SOLID object
    (setq d1 (list (cons 0 "SOLID") (cons 100 "AcDbEntity") (cons 100 "AcDbTrace")))

; first add colour data if available/required (62 = standard colour, 420 = custom colour)
    (if (= tpop_solidcopycolour T)
     (progn
      (if (/= (assoc 62 e1) nil)
       (setq d1 (append d1 (list (assoc 62 e1))))
      )
      (if (/= (assoc 420 e1) nil)
       (setq d1 (append d1 (list (assoc 420 e1))))
      )
     )
    )

; then add corners and make new SOLID object
    (setq d1 (append d1 (list (append (list 10) p1) (append (list 11) p2)
                              (append (list 12) p3) (append (list 13) p3))))    
    (entmake d1)

; increase counter to look at next triangle
    (setq c1 (1+ c1))
   )
  )
 )
 (tpop_atend)
 (princ)
)

; =============================================================================================

; TPOP_COMPPOINT
; ==============

; Description:
; ============
; Compare two points in x,y plane to see if they're the same (within fuzz value)

; Internal Variables:
; ===================
; cp_x1, cp_y1, cp_x2, cp_y2 = inputs: x,y coordinates of two points
; cp_f1 = input: fuzz value
; cp_f2 = output: T if equal, nil if not

(defun tpop_comppoint (cp_x1 cp_y1 cp_x2 cp_y2 cp_f1 / cp_f2)

; set flag to T if x and y coordinates for each point are within fuzz value distance
 (if (and (<= (abs (- cp_x1 cp_x2)) cp_f1) (<= (abs (- cp_y1 cp_y2)) cp_f1))
  (setq cp_f2 T)
  (setq cp_f2 nil)
 )

; set flag to itself, so flag value is output from this function
 (setq cp_f2 cp_f2)
)

; =============================================================================================

; TPOP_COMPLINE
; =============

; Description:
; ============
; Compare two lines to see if they're the same (ends could be swapped round) within fuzz value

; Internal Variables:
; ===================
; cl_l1 = input: list of x,y pairs at each end of first line
; cl_l2 = input: list of x,y pairs at each end of first line
; cl_f1 = input: fuzz value
; cl_p1, cl_p2 = points at each end of first line
; cl_x1, cl_y1, cl_x2, cl_y2 = x,y coordinates of points cl_p1 and cl_p2
; cl_f2 = output: T if same, nil if not
; cl_c1 = counter to look at line cl_l2 first one way round, then other way round
; cl_p3, cl_p4 = points at each end of first line
; cl_x3, cl_y3, cl_x4, cl_y4 = x,y coordinates of points cl_p3 and cl_p4

(defun tpop_compline (cl_l1 cl_l2 cl_f1 / cl_p1 cl_p2 cl_x1 cl_y1 cl_x2 cl_y2 cl_f2
                                          cl_c1 cl_p3 cl_p4 cl_x3 cl_y3 cl_x4 cl_y4)

; get x,y coordinates at each end of first line
 (setq cl_p1 (nth 0 cl_l1) cl_p2 (nth 1 cl_l1))
 (setq cl_x1 (car cl_p1) cl_y1 (cadr cl_p1) cl_x2 (car cl_p2) cl_y2 (cadr cl_p2))

; set "found match" flag to nil, counter to 0 to look at second line in two directions
 (setq cl_f2 nil cl_c1 0)
 (while (and (= cl_f2 nil) (< cl_c1 2))

; get x,y coordinates at each end of second line (first one way, then other way round)
  (setq cl_p3 (nth cl_c1 cl_l2) cl_p4 (nth (- 1 cl_c1) cl_l2))
  (setq cl_x3 (car cl_p3) cl_y3 (cadr cl_p3) cl_x4 (car cl_p4) cl_y4 (cadr cl_p4))

; set flag to T if points at each end of lines are the same (within fuzz value)
  (if (and (= (tpop_comppoint cl_x1 cl_y1 cl_x3 cl_y3 cl_f1) T)
           (= (tpop_comppoint cl_x2 cl_y2 cl_x4 cl_y4 cl_f1) T))
   (setq cl_f2 T)
  )

; increase counter to compare two lines but with second line other way round
  (setq cl_c1 (1+ cl_c1))
 )

; set flag to itself, so flag value is output from this function
 (setq cl_f2 cl_f2)
)

; =============================================================================================

; TPOP_MAKE2DPOINT
; ================

; Description:
; ============
; Returns a 2D point if input is a 2D or 3D point

; Internal Variables:
; ===================
; mp_p1 = input and output: 2D or 3D point

(defun tpop_make2dpoint (mp_p1 / )

; if input point is 3D, create new 2D point from input's x and y coordinates
 (if (= (length mp_p1) 3)
  (setq mp_p1 (list (car mp_p1) (cadr mp_p1)))
 )

; set point to itself, so point is output from this function
 (setq mp_p1 mp_p1)
)

; =============================================================================================

; TPOP_LINESTOPLINES ("lines to plines", not "line stop lines")
; ==================

; Description:
; ============
; Draw polyline(s) from list of lines provided, returns list of end-points on polylines

; Internal Variables:
; ===================
; lp_l1 = input: list of line segments e.g. ((x,y,z)(x,y,z)) 
; lp_u1 = input: fuzz value
; lp_e1 = input: z elevation for polyline
; lp_f1 = input: flag: if T then return list of end-points, if nil don't bother
; lp_l2 = output: list of x,y,z coordinates along polylines (drawn as 2D)
; lp_l3 = list of lines to form lightweight polyline for contour
; lp_c1 = count which direction to add lines to list lp_l3
; lp_p1 = first point of first line in list lp_l1
; lp_x1, lp_y1, lp_z1 = x,y,z coordinates of point lp_p1, then ends of lines added to lp_l3
; lp_l4 = list lp_l3 in reverse order
; lp_c2 = count through list lp_l3 to reverse its order
; lp_i1 = individual line in list lp_l3
; lp_p1, lp_p2 = points at each end of line lp_i1
; lp_f2 = flag: T when a line has been added to list lp_l3
; lp_c2 = count through list lp_l1
; lp_i1 = individual line in list lp_l1
; lp_c3 = count through each end of line lp_i1
; lp_p1 = point at one end of line lp_i1
; lp_x2, lp_y2, lp_z2 = x,y,z coordinates of point lp_p1
; lp_f3 = flag: T if line has already been added to list lp_l3
; lp_c4 = count through list lp_l3
; lp_i2 = individual line in list lp_l3
; lp_p1 = point at other end of line lp_i1
; lp_l4 = polyline entity data list
; lp_p1, lp_p2 = points at start and end of polyline (to see if it's a closed polyline)
; lp_x1, lp_y1, lp_x2, lp_y2 = x,y coordinates of points lp_p1 and lp_p2
; lp_c2 = number of lines to be added to list lp_l4
; lp_c1 = count through list lp_l3
; lp_i1 = individual line in list lp_l3
; lp_c1 = count through list lp_l1
; lp_l4 = list of contour lines not yet added to a polyline
; lp_i1 = individual line in list lp_l1
; lp_f2 = flag: T when line lp_i1 is found in polyline list lp_l3
; lp_c2 = count through list lp_l3
; lp_i2 = individual line in list lp_l3

(defun tpop_linestoplines (lp_l1 lp_u1 lp_e1 lp_f1 / lp_l2 lp_l3 lp_c1 lp_p1 lp_x1 lp_y1 lp_z1
                                                     lp_l4 lp_c2 lp_i1 lp_p2 lp_f2 lp_c3 lp_x2
                                                     lp_y2 lp_z2 lp_f3 lp_c4 lp_i2)

; set output list as empty
 (setq lp_l2 nil)

; continue looping through list of 2D or 3D lines until list is empty
 (while (/= lp_l1 nil)

; set polyline list of lines as empty, add lines to list l3 in two directions
  (setq lp_l3 nil lp_c1 0)
  (while (< lp_c1 2)

; get x,y,z coordinates of first point of first line in list lp_l1 (same for both directions)
   (setq lp_p1 (nth 0 (nth 0 lp_l1)))
   (setq lp_x1 (car lp_p1) lp_y1 (cadr lp_p1) lp_z1 (caddr lp_p1))

; if looking in second direction, need to reverse order of existing list lp_l3 (if exists)
   (if (and (= lp_c1 1) (/= lp_l3 nil))
    (progn
     (setq lp_l4 nil lp_c2 (1- (length lp_l3)))
     (while (>= lp_c2 0)
      (setq lp_i1 (nth lp_c2 lp_l3))
      (setq lp_p1 (nth 0 lp_i1) lp_p2 (nth 1 lp_i1))
      (setq lp_l4 (tpop_addtolist lp_l4 (list lp_p2 lp_p1)))
      (setq lp_c2 (1- lp_c2))
     )

; copy new reversed list as polyline list
     (setq lp_l3 lp_l4)
    )
   )

; set "line has been added" flag to T (keep going until no more lines are added)
   (setq lp_f2 T)
   (while (= lp_f2 T)

; set "line has been added" flag to nil and counter to start of list lp_l1
    (setq lp_f2 nil lp_c2 0)

; look through list of lines to add first one with matching x1,y1 end, but not already added
    (while (and (= lp_f2 nil) (< lp_c2 (length lp_l1)))
     (setq lp_i1 (nth lp_c2 lp_l1) lp_c3 0)

; look at each end of each line, getting x,y,z coordinates of each point
     (while (and (= lp_f2 nil) (< lp_c3 2))
      (setq lp_p1 (nth lp_c3 lp_i1))
      (setq lp_x2 (car lp_p1) lp_y2 (cadr lp_p1) lp_z2 (caddr lp_p1))

; found line with matching end
      (if (= (tpop_comppoint lp_x1 lp_y1 lp_x2 lp_y2 lp_u1) T)
       (progn

; check this line isn't already in polyline list
        (setq lp_f3 nil lp_c4 0)
        (while (and (= lp_f3 nil) (< lp_c4 (length lp_l3)))
         (setq lp_i2 (nth lp_c4 lp_l3))
         (setq lp_f3 (tpop_compline lp_i1 lp_i2 lp_u1)) 
         (setq lp_c4 (1+ lp_c4))
        )

; if this line isn't already in polyline list l3, add it to polyline list l3
        (if (= lp_f3 nil)
         (progn

; get other end of line's coordinates
          (setq lp_p1 (nth (- 1 lp_c3) lp_i1))
          (setq lp_x2 (car lp_p1) lp_y2 (cadr lp_p1) lp_z2 (caddr lp_p1))
          (setq lp_l3 (tpop_addtolist lp_l3
                      (list (list lp_x1 lp_y1 lp_z1) (list lp_x2 lp_y2 lp_z2))))

; set next x,y,z coords to find, and flag to T to exit loop looking for lines to add
          (setq lp_x1 lp_x2 lp_y1 lp_y2 lp_z1 lp_z2 lp_f2 T) 
         )
        )
       )
      )

; increase counters to look at other end of current line, then next line in list lp_l1
      (setq lp_c3 (1+ lp_c3))
     )
     (setq lp_c2 (1+ lp_c2))
    )
   )

; increase counter to add lines to polyline list but looking in opposite direction
   (setq lp_c1 (1+ lp_c1))
  )

; draw polyline from list lp_l3, and populate list lp_l2 if lp_f1 is T
  (if (/= lp_l3 nil)
   (progn

; set initial element of polyline entity data list
    (setq lp_l4 (list (cons 0 "LWPOLYLINE") (cons 100 "AcDbEntity") (cons 100 "AcDbPolyline")))

; get first and last point on polyline and see if they're the same (i.e. closed polyline)
    (setq lp_p1 (nth 0 (nth 0 lp_l3)) lp_p2 (nth 1 (last lp_l3)))
    (setq lp_x1 (car lp_p1) lp_y1 (cadr lp_p1) lp_x2 (car lp_p2) lp_y2 (cadr lp_p2))
    (if (= (tpop_comppoint lp_x1 lp_y1 lp_x2 lp_y2 lp_u1) T)

; if closed: set counter to number of lines minus one, add "closed polyline" to data list
     (setq lp_c2 (1- (length lp_l3)) lp_l4 (append lp_l4 (list (cons 70 1))))

; if not closed: set counter to same as number of lines
     (setq lp_c2 (length lp_l3))
    )

; add number of vertices (no. of lines + 1), zero width, and elevation to polyline data list
    (setq lp_l4 (append lp_l4 (list (cons 90 (1+ lp_c2)) (cons 43 0.0) (cons 38 lp_e1))))

; go through list of lines in polyline, adding points to polyline data list
    (setq lp_c1 0)
    (while (< lp_c1 lp_c2)

; add start of first line (reason why no. of vertices = no. of lines + 1)
     (if (= lp_c1 0)
      (progn
       (setq lp_i1 (car (nth lp_c1 lp_l3)))
       (setq lp_l4 (append lp_l4 (list (append (list 10) (tpop_make2dpoint lp_i1))
                                       (cons 42 0) (cons 91 0))))
       (if (= lp_f1 T)
        (setq lp_l2 (tpop_addtolist lp_l2 lp_i1))
       )
      )
     )

; add end of start and subsequent lines (but not of last line if closed polyline)
     (setq lp_i1 (cadr (nth lp_c1 lp_l3)))
     (setq lp_l4 (append lp_l4 (list (append (list 10) (tpop_make2dpoint lp_i1))
                                     (cons 42 0) (cons 91 0))))
     (if (= lp_f1 T)
      (setq lp_l2 (tpop_addtolist lp_l2 lp_i1))
     )
     (setq lp_c1 (1+ lp_c1))
    )

; create the lightweight polyline object
    (entmake lp_l4)
   )
  )

; create new list l4 from current list lp_l1 but not including lines added to list lp_l3
  (setq lp_c1 0 lp_l4 nil)
  (while (< lp_c1 (length lp_l1))
   (setq lp_i1 (nth lp_c1 lp_l1) lp_f2 nil lp_c2 0)

; go through list l3 until matching line found or reach end of list l3
   (while (and (= lp_f2 nil) (< lp_c2 (length lp_l3)))
    (setq lp_i2 (nth lp_c2 lp_l3))

; compare lines - set flag lp_f2 to T when a match is found
    (setq lp_f2 (tpop_compline lp_i1 lp_i2 lp_u1))
    (setq lp_c2 (1+ lp_c2))
   )

; if no matching line found in list lp_l3, add this line from list lp_l1 to list lp_l4
   (if (= lp_f2 nil)
    (setq lp_l4 (tpop_addtolist lp_l4 lp_i1))
   )

; increase counter to look at next line in list lp_l1
   (setq lp_c1 (1+ lp_c1))
  )

; copy the new list lp_l4 to the update current list lp_l1
  (setq lp_l1 lp_l4)
 )

; set points list to itself, so list is output from this function
 (setq lp_l2 lp_l2)
)

; =============================================================================================
; OOOOO OOOO   OOO  OOOO   OOOO  OOO  O   O OOOOO
;   O   O   O O   O O   O O     O   O OO  O   O
;   O   OOOO  O   O OOOO  O     O   O O O O   O
;   O   O     O   O O     O     O   O O  OO   O
;   O   O      OOO  O      OOOO  OOO  O   O   O
; =============================================================================================

; TPOPCONT
; ========

; Description:
; ============
; Draw 3 point 3D SOLIDs over selected 3D triangles

; Global Variables:
; =================
; tpop_continterval = contour interval value (+ve, cannot = 0)

; Internal Variables:
; ===================
; l1 = list of groups of ((x,y,z)(x,y,z)(x,y,z)) data from 3D triangles
; c1 = count through list l1
; i1 = individual triangle in list l1
; c2 = count through corners of triangle i1
; z1 = z value of each corner
; m1, m2 = minimum and maximum z values
; r1 = z interval value
; f1 = fuzz value
; l2 = unordered list of contour lines at current contour level
; i2 = list of points forming contour within current triangle
; p1, p2 = points at each end of single side of current triangle
; x1, y1, z1, x2, y2, z2 = x,y,z coordiantes of p1 and p2
; d1 = ratio along single side to where it intersects contour level
; x3, y3 = x,y coordinates of point along side where it intersects contour level
; c3 = count through points on contour line list i2
; f2 = flag: T if point is already on contour line
; i3 = individual point in i2

(defun C:TPOPCONT ( / l1 c1 i1 c2 z1 m1 m2 r1 f1 l2 i2 p1
                      p2 x1 y1 x2 y2 z2 d1 x3 y3 c3 f2 i3)
 (tpop_atstart)

; get list of x,y,z groups from user-selected 3D POLYLINE triangles
 (if (/= (setq l1 (tpop_gettriangles nil nil)) nil)
  (progn

; go through each triangle in list to get minimum and maximum z values
   (setq c1 0)
   (while (< c1 (length l1))
    (setq i1 (nth c1 l1) c2 0)

; go through each side of each triangle
    (while (< c2 3)
     (setq z1 (caddr (nth c2 i1)))

; if first side of first triangle, use z value, otherwise use if below/above min/max
     (if (and (= c1 0) (= c2 0))
      (setq m1 z1 m2 z1)
      (setq m1 (min m1 z1) m2 (max m2 z1))
     )

; increase counters to look at next side, then next triangle
     (setq c2 (1+ c2))
    )
    (setq c1 (1+ c1))
   )

; if min and max z values are equal, then triangles are flat, and cannot draw contours
   (if (= m1 m2)
    (princ "\nCannot draw contours as triangle(s) have same z values. Command terminating")
    (progn

; otherwise get z interval value, and store as global variable if non-zero
     (setq r1 (abs (tpop_getglobalval "Enter z interval value" tpop_continterval 5.0 nil)))
     (if (= r1 0.0)
      (princ "\nZero interval not permitted. Command terminating")
      (progn
       (setq tpop_continterval r1)

; get fuzz value
       (setq f1 (tpop_getfuzzvalue))

; if minimum z value is not on interval, increase value to adjacent interval value
       (if (/= (rem m1 r1) 0.0)
        (if (< m1 0.0)
         (setq m1 (- m1 (rem m1 r1)))
         (setq m1 (+ (- m1 (rem m1 r1)) r1))
        )
       )

; keep looking at current z value until reached (or above) maximum z value
       (while (<= m1 m2)

; go through each triangle in list, set list to contain contour lines as empty
        (setq c1 0 l2 nil)
        (while (< c1 (length l1))

; get individual triangle from list, set contour line empty, go through each triangle side
         (setq i1 (nth c1 l1) i2 nil c2 0)
         (while (< c2 3)

; get coordinates of each end of current triangle side
          (setq p1 (nth (nth c2 (list 0 1 2)) i1) p2 (nth (nth c2 (list 1 2 0)) i1))
          (setq x1 (car p1) y1 (cadr p1) z1 (caddr p1)
                x2 (car p2) y2 (cadr p2) z2 (caddr p2))

; if this triangle side intersects contour level (and side isn't flat)
          (if (and (>= m1 (min z1 z2)) (<= m1 (max z1 z2)) (/= z1 z2))
           (progn

; calculate where side intersects contour level and add point to individual contour line
            (setq d1 (/ (- m1 z1) (- z2 z1)))
            (setq x3 (+ x1 (* d1 (- x2 x1))) y3 (+ y1 (* d1 (- y2 y1))))

; compare with point(s) already added to single contour line (if any)
            (setq c3 0 f2 nil)
            (while (and (< c3 (length i2)) (= f2 nil))
             (setq i3 (nth c3 i2))

; set flag if current point is already on single contour line, so don't add it again
             (setq f2 (tpop_comppoint x3 y3 (car i3) (cadr i3) f1))
             (setq c3 (1+ c3))
            )

; if current point not already added to single contour line, add it (as 3D point)
            (if (= f2 nil)
             (setq i2 (tpop_addtolist i2 (list x3 y3 0.0)))
            )
           )
          )
          (setq c2 (1+ c2))
         )

; if contour line contains two points add it to list of contour lines
         (if (= (length i2) 2)
          (setq l2 (tpop_addtolist l2 i2))
         )
         (setq c1 (1+ c1))
        )

; join together list of contour lines and draw them as polyline(s)
        (tpop_linestoplines l2 f1 m1 nil)

; increase current z value by interval value before repeating loop (until at max z value)
        (setq m1 (+ m1 r1))
       )

; if command finished, show message, as command can take a while to complete
       (princ "\nCommand finished")
      )
     )
    )
   )
  )
 )
 (tpop_atend)
 (princ)
)

; =============================================================================================

; TPOP_CONTLABELLOOK
; ==================

; Description:
; ============
; See if contour label insertion point is on or near line segment

; Internal Variables:
; ===================
; lk_p1 = input: label insertion point
; lk_p2, lk_p3 = input: points at each end of line segment
; lk_z1 = input: fuzz value
; lk_x1, lk_y1, lk_x2, lk_y2, lk_x3, lk_y3 = x,y coordinates of points
; lk_d1 = denominator for calculating if point lk_p1 lies within line lk_p2 to lk_p3
; lk_l1 = output: list of distance from line, label insertion point on line, text angle
; lk_n1, lk_n2 = ratios along/perpendicular to line lk_p2-lk_p3 from point lk_p1
; lk_p4 = intersection point on line lk_p2-lk_p3 of perpendicular line from point lk_p1
; lk_a1 = contour label text angle

(defun tpop_contlabellook (lk_p1 lk_p2 lk_p3 lk_z1 / lk_x1 lk_y1 lk_x2 lk_y2 lk_x3 lk_y3
                                                     lk_d1 lk_l1 lk_n1 lk_n2 lk_p4 lk_a1)

; get x,y coordinates of point and ends of line segment
 (setq lk_x1 (car lk_p1) lk_y1 (cadr lk_p1) lk_x2 (car lk_p2) lk_y2 (cadr lk_p2)
       lk_x3 (car lk_p3) lk_y3 (cadr lk_p3))

; calculate denominator used for calculating ratios along lines, and output to nil if zero
 (setq lk_d1 (+ (* (- lk_x3 lk_x2) (- lk_x3 lk_x2)) (* (- lk_y3 lk_y2) (- lk_y3 lk_y2))))
 (if (= lk_d1 0.0)
  (setq lk_l1 nil)
  (progn

; otherwise calculate ratios along and perpendicular to line segment
   (setq lk_n1 (/ (+ (* (- lk_y1 lk_y2) (- lk_y3 lk_y2))
                     (* (- lk_x1 lk_x2) (- lk_x3 lk_x2))) lk_d1)
         lk_n2 (/ (- (* (- lk_x1 lk_x2) (- lk_y3 lk_y2))
                     (* (- lk_y1 lk_y2) (- lk_x3 lk_x2))) lk_d1))

; if perpendicular from point to line is outside extents of line, set output to nil
   (if (or (< lk_n1 (- lk_z1)) (> lk_n1 (+ lk_z1 1.0)))
    (setq lk_l1 nil)
    (progn

; otherwise calculate 2D intersection point on line of line perpendicular from point p1
     (setq lk_p4 (list (+ lk_x2 (* lk_n1 (- lk_x3 lk_x2)))
                       (+ lk_y2 (* lk_n1 (- lk_y3 lk_y2)))))

; and calculate text angle, rotate if between 90 and 270 degrees, so text always upright
     (setq lk_a1 (angle lk_p2 lk_p3))
     (if (and (> lk_a1 tpop_halfpi) (< lk_a1 tpop_oneandahalfpi))
      (setq lk_a1 (+ lk_a1 tpop_pi))
     )

; set output to list of distance from line, label insertion point on line, text angle
     (setq lk_l1 (list (abs lk_n2) lk_p4 lk_a1))
    )
   )
  )
 ) 

; set list to itself, so list is output from this function
 (setq lk_l1 lk_l1)
)

; =============================================================================================

; TPOP_DRAWMCTEXT
; ===============

; Description:
; ============
; Draw middle-centre aligned text

; Internal Variables:
; ===================
; mc_p1 = input: text insertion point
; mc_a1 = input: text angle
; mc_h1 = input: text height
; mc_t1 = input: text
; mc_p2 = point defining width and height of text bounding box

(defun tpop_drawmctext (mc_p1 mc_a1 mc_h1 mc_t1 / mc_p2)

; get point defining width and height of text bounding box (need this to calculate 2nd insertion point)
 (setq mc_p2 (cadr (textbox (list (cons 40 mc_h1) (cons 1 mc_t1)))))

; draw text (include text height so draws text in AutoCAD)
 (entmake (list (cons 0 "TEXT") (cons 100 "AcDbEntity") (cons 100 "AcDbText")
                (append (list 10) (polar mc_p1 (+ mc_a1 (angle mc_p2 (list 0.0 0.0 0.0)))
                                               (/ (distance mc_p2 (list 0.0 0.0 0.0)) 2.0)))
                (cons 72 1) (cons 73 2) (append (list 11) mc_p1)
                (cons 50 mc_a1) (cons 40 mc_h1) (cons 1 mc_t1)))
)

; =============================================================================================
; OOOOO OOOO   OOO  OOOO   OOOO  OOO  O   O OOOOO O       O   OOOO  OOOOO O
;   O   O   O O   O O   O O     O   O OO  O   O   O      O O  O   O O     O
;   O   OOOO  O   O OOOO  O     O   O O O O   O   O     O   O OOOO  OOOO  O
;   O   O     O   O O     O     O   O O  OO   O   O     OOOOO O   O O     O
;   O   O      OOO  O      OOOO  OOO  O   O   O   OOOOO O   O OOOO  OOOOO OOOOO
; =============================================================================================

; TPOPCONTLABEL
; =============

; Description:
; ============
; Draw text label of contour z value next to and aligned to selected lightweight polyline

; Global Variables:
; =================
; tpop_contlabeldp = number of decimal places (0 to 9) to display number in contour text label

; Internal Variables:
; ===================
; e1 = polyline entity name/insertion point pair, then just the entity name
; p1 = selection point when user clicked on e1
; d1 = entity data of e1
; r1 = number of decimal places to round label value up/down to
; z1 = fuzz value
; o1 = old value of system variable DIMZIN (how numbers are displayed)
; c1 = count through data list d1
; p2 = very first point on polyline (need this if it's a closed polyline)
; p3, p4 = points at each end of each segment in polyline
; l1 = list of possible contour label positions
; z2 = z value (elevation) of polyline
; b1 = bulge factor (= 0.0 when each segment is a line)
; f1 = flag: T if closed polyline, nil of not
; n1 = code value of individual data item in polyline
; i1 = individual data item in polyline
; l2 = result of function seeing if point p1 is within limits of line
; c1 = count through list l2
; c2 = count of label position found neares to polyline (-1 if none)
; n2 = distance of current label position to polyline
; n1 = shortest distance of label position to polyline
; i1 = individual item from l2, containing insertion position and text angle
; p2 = label insertion position from i1
; a1 = text angle from i1
; h1 = text height

(defun C:TPOPCONTLABEL ( / e1 p1 d1 r1 z1 o1 c1 p2 p3 p4 l1 z2 b1 f1 n1 i1 l2 c2 n2 a1 h1)
 (tpop_atstart)

; ask user to select location on lighweight polyline to insert contour label
 (if (= (setq e1 (entsel "Select location on contour polyline")) nil)
  (princ "\nNo object selected. Command terminating")
  (progn

; remember location user clicked, and get entity data list
   (setq p1 (cadr e1))
   (setq d1 (entget (setq e1 (car e1))))

; error if user selected object which is not a lightweight polyline
   (if (/= (cdr (assoc 0 d1)) "LWPOLYLINE")
    (princ "\nObject selected is not a lightweight polyline. Command terminating")
    (progn

; ask user for number of decimal places to show contour label, set in limits, store
     (setq r1 (tpop_getglobalval "Enter number of decimal places (0 to 9) for label"
               tpop_contlabeldp 3 T))
     (if (< r1 0)
      (setq r1 0)
      (if (> r1 9)
       (setq r1 9)
      )
     )
     (setq tpop_contlabeldp r1)

; get fuzz value and initial value of DIMZIN system variable
     (setq z1 (tpop_getfuzzvalue) o1 (getvar "DIMZIN"))

; set counter to start of data list, and default values for rest
     (setq c1 0 p2 nil p3 nil p4 nil l1 nil z2 0.0 b1 0.0 f1 nil)

; go through each item in data list, getting its code number and item data
     (while (< c1 (length d1))
      (setq n1 (car (setq i1 (nth c1 d1))))

; store polyline elevation z value to be displayed in label
      (if (= n1 38)
       (setq z2 (cdr i1))

; get bulge factor for current segment (0.0 = straight line)
       (if (= n1 42)
        (setq b1 (cdr i1))

; set flag it polyline is closed
        (if (= n1 70)
         (if (= (boole 1 (cdr i1) 1) 1)
          (setq f1 T)
         )

; if looking at a vertex, store points if first vertex encountered in list
         (if (= n1 10)
          (if (= p2 nil)
           (setq p2 (cdr i1) p3 (cdr i1))
           (progn

; otherwise store other end of segment, and process it if segment is a line
            (setq p4 (cdr i1))
            (if (= b1 0.0)
             (if (/= (setq l2 (tpop_contlabellook p1 p3 p4 z1)) nil)
              (setq l1 (tpop_addtolist l1 l2))
             )
            )

; store end of current segment as start of next segment
            (setq p3 p4)
           )
          )
         )
        )
       )
      )

; increase counter to look at next item in data list
      (setq c1 (1+ c1))
     )

; if closed polyline, process segment linking last and 1st points
     (if (and (= f1 T) (/= p2 nil) (/= p3 nil))
      (if (/= (setq l2 (tpop_contlabellook p1 p3 p2 z1)) nil)
       (setq l1 (tpop_addtolist l1 l2))
      )
     )

; show message if no positions for label have been found (should always be found)
     (if (= l1 nil)
      (princ "\nUnable to draw contour label. Command terminating")
      (progn

; otherwise find insertion point which is closest to contour polyline
       (setq c1 0 c2 -1)
       (while (< c1 (length l1))

; get distance of each insertion point, storing it if first point, or closest
        (setq n2 (nth 0 (nth c1 l1)))
        (if (= c1 0)
         (setq c2 c1 n1 n2)
         (if (< n2 n1)
          (setq c2 c1 n1 n2)
         )
        )
        (setq c1 (1+ c1))
       )

; if found closest insertion point, get its coordinates and text angle
       (if (> c2 -1)
        (progn
         (setq i1 (nth c2 l1))
         (setq p2 (nth 1 i1) a1 (nth 2 i1))

; convert elevation z value to text and get text height
         (setvar "DIMZIN" 0)
         (setq z2 (rtos z2 2 r1))
         (setvar "DIMZIN" o1)
         (setq h1 (getvar "TEXTSIZE"))

; offset text insertion point so it's above the line segment
         (setq p2 (polar p2 (+ a1 tpop_halfpi) h1))

; draw contour text label
         (tpop_drawmctext p2 a1 h1 z2)
        )
       )
      )
     )
    )
   )
  )
 )
 (tpop_atend)
 (princ)
)

; =============================================================================================

; TPOP_DRAWSLOPE
; ==============

; Description:
; ============
; Draw slope arrow and text at specified point and angle

; Internal Variables:
; ===================
; ds_p1 = input: mid-point of slope arrow
; ds_a1 = input: angle of arrow and text
; ds_t1 = input: text
; ds_h1 = input: text height

(defun tpop_drawslope (ds_p1 ds_a1 ds_t1 ds_h1 / )

; draw arrow pointing in direction of slope (draw polyline as easier than LEADER)
 (entmake (list (cons 0 "LWPOLYLINE") (cons 100 "AcDbEntity") (cons 100 "AcDbPolyline")
                (cons 90 3) (cons 70 0) (cons 38 0.0)
                (append (list 10) (tpop_make2dpoint (polar ds_p1 ds_a1 (* ds_h1 3.0))))
                (cons 40 0.0) (cons 41 0.0) (cons 42 0.0) (cons 91 0)
                (append (list 10) (tpop_make2dpoint (polar ds_p1 (+ ds_a1 tpop_pi) (* ds_h1 2.0))))
                (cons 40 (/ ds_h1 3.0)) (cons 41 0.0) (cons 42 0.0) (cons 91 0)
                (append (list 10) (tpop_make2dpoint (polar ds_p1 (+ ds_a1 tpop_pi) (* ds_h1 3.0))))
                (cons 40 0.0) (cons 41 0.0) (cons 42 0.0) (cons 91 0)))

; rotate text if between 90 and 270 degrees, by 180 degrees so text is always upright
 (if (and (> ds_a1 tpop_halfpi) (< ds_a1 tpop_oneandahalfpi))
  (setq ds_a1 (+ ds_a1 tpop_pi))
 )

; offset text so it's above the pointing arrow
 (setq ds_p1 (polar ds_p1 (+ ds_a1 tpop_halfpi) ds_h1))

; draw slope text
 (tpop_drawmctext ds_p1 ds_a1 ds_h1 ds_t1)
)

; =============================================================================================
; OOOOO OOOO   OOO  OOOO   OOOO O      OOO  OOOO  OOOOO O   O   O   O   O
;   O   O   O O   O O   O O     O     O   O O   O O     OO OO  O O   O O
;   O   OOOO  O   O OOOO   OOO  O     O   O OOOO  OOOO  O O O O   O   O
;   O   O     O   O O         O O     O   O O     O     O   O OOOOO  O O
;   O   O      OOO  O     OOOO  OOOOO  OOO  O     OOOOO O   O O   O O   O
; =============================================================================================

; TPOPSLOPEMAX
; ============

; Description:
; ============
; Draw maximum slope value and arrow in direction of slope within selected 3D triangles

; Internal Variables:
; ===================
; l1 = list of groups of ((x,y,z)(x,y,z)(x,y,z)) data from 3D triangles
; o1 = initial value of DIMZIN system variable
; c1 = count through list l1
; h1 = text height
; i1 = individual triangle in list l1
; d1, d2 = slopes values in x and y directions
; p1, p2, p3 = coordinates at corners of triangle i1
; p4 = point at middle of triangle i1
; t1 = maximum slope value text
; a1 = angle (direction) of slope

(defun C:TPOPSLOPEMAX ( / l1 o1 c1 h1 i1 d1 d2 p1 p2 p3 p4 t1 a1)
 (tpop_atstart)

; get list of x,y,z groups from user-selected 3D POLYLINE triangles
 (if (/= (setq l1 (tpop_gettriangles nil nil)) nil)
  (progn

; get initial DIMZIN system variable, set counter to 0, get text height
   (setq o1 (getvar "DIMZIN") c1 0 h1 (getvar "TEXTSIZE"))

; look through list of 3D triangles, getting data for each triangle
   (while (< c1 (length l1))
    (setq i1 (nth c1 l1))

; get slope values for triangle, and continue if not vertical slope
    (if (/= (setq d1 (tpop_getslope i1)) nil)
     (progn
      (setq d2 (cadr d1))
      (setq d1 (car d1))

; get x,y,z coordinates for each corner of triangle to calculate middle of triangle
      (setq p1 (nth 0 i1) p2 (nth 1 i1) p3 (nth 2 i1))
      (setq p4 (list (/ (+ (car p1) (car p2) (car p3)) 3.0)
                     (/ (+ (cadr p1) (cadr p2) (cadr p3)) 3.0) 0.0))

; set slope value as text (setting DIMZIN to 0 so that 2.5 appears as 2.500)
      (setvar "DIMZIN" 0)
      (setq t1 (rtos (* 100.0 (sqrt (+ (* d1 d1) (* d2 d2)))) 2 3))
      (setvar "DIMZIN" o1)

; if flat horizontal slope (to 3 d.p.) draw 0.0% at insertion point and no arrow
      (if (= (atof t1) 0.0)
       (tpop_drawmctext p4 0.0 h1 (strcat t1 "%"))

; otherwise calculate angle (direction) and draw slope arrow and text
       (progn
        (setq a1 (angle (list 0.0 0.0 0.0) (list d1 d2 0.0)))
        (tpop_drawslope p4 a1 (strcat t1 "%") h1)
       )
      )
     )
    )

; increase counter to look at next 3D triangle
    (setq c1 (1+ c1))
   )
  )
 )
 (tpop_atend)
 (princ)
)

; =============================================================================================

; TPOP_POINTINTRIA
; ================

; Description:
; ============
; Return T if point is inside individual triangle or on triangle edge, nil if neither

; Internal Variables:
; ===================
; it_p1 = input: point to look for
; it_i1 = input: list of three (x,y,z) groups forming 3D triangle
; it_z1 = input: fuzz value
; it_x1, it_y1 = x,y coordinates of point it_p1
; it_f1 = output: T point is inside triangle or on triangle edge, nil if neither
; it_c1 = count through sides of triangle it_i1
; it_n1 = number of sides point is to the left or right, or on the line
; it_p2, it_p3 = points at each end of side of triangle
; it_x2, it_y2, it_x3, it_y3 = x,y coordinates of points it_p2 and it_p3
; it_d1, it_d2 = denominator and ratios along/perpendicular to side it_p2-it_p3 to it_p1

(defun tpop_pointintria (it_p1 it_i1 it_z1 / it_x1 it_y1 it_f1 it_c1 it_n1 it_p2 it_p3
                                             it_x2 it_y2 it_x3 it_y3 it_d1 it_d2)

; get x,y coordinates for search point, set flag to "not inside" and counters to 0
 (setq it_x1 (car it_p1) it_y1 (cadr it_p1) it_f1 nil it_c1 0 it_n1 0)

; look at each side of triangle, getting ends and x,y coordinates of ends
 (while (< it_c1 3)
  (setq it_p2 (nth (nth it_c1 (list 0 1 2)) it_i1)
        it_p3 (nth (nth it_c1 (list 1 2 0)) it_i1))
  (setq it_x2 (car it_p2) it_y2 (cadr it_p2) it_x3 (car it_p3) it_y3 (cadr it_p3))

; get denominator for calculating ratios along/perpendicular to side of triangle
  (setq it_d1 (+ (* (- it_x3 it_x2) (- it_x3 it_x2))
                 (* (- it_y3 it_y2) (- it_y3 it_y2))))

; only continue if denominator is non-zero (i.e. line has length)
  (if (/= it_d1 0.0)
   (progn

; calculate offset perpependicular to side to search point
    (setq it_d2 (/ (- (* (- it_x1 it_x2) (- it_y3 it_y2)) 
                      (* (- it_x3 it_x2) (- it_y1 it_y2))) it_d1))

; if 0 (within fuzzy range), search point is on the side so calculate ratio along side
    (if (and (>= it_d2 (- it_z1)) (<= it_d2 it_z1))
     (progn
      (setq it_d2 (/ (- (* (- it_y1 it_y2) (- it_y3 it_y2))
                        (* (- it_x1 it_x2) (- it_x3 it_x2))) it_d1))

; if ratio is within limits of line (between 0 and 1 +/- fuzz) set counts to exit loop
      (if (and (>= it_d2 (- it_z1)) (<= it_d2 (+ 1.0 it_z1)))
       (setq it_n1 3 it_c1 3)
      )
     )

; if search point is left or right of side add/subtract 1 to side counter
     (if (< it_d2 0.0)
      (setq it_n1 (1- it_n1))
      (if (> it_d2 0.0)
       (setq it_n1 (1+ it_n1))
      )
     )
    )
   )
  )

; increase counter to look at next triangle side
  (setq it_c1 (1+ it_c1))
 )

; set flag to T if search point is within triangle (on same side of each side) or on side
 (if (= (abs it_n1) 3)
  (setq it_f1 T)
 )

; set flag to itself, so flag is output from this function
 (setq it_f1 it_f1)
)

; =============================================================================================

; TPOP_POINTINTRIAS
; =================

; Description:
; ============
; Return list of triangle coordinates from list around a point, or nil outside all triangles

; Internal Variables:
; ===================
; pt_p1 = input: point to look for
; pt_l1 = input: list of 3D triangles
; pt_z1 = input: fuzz value
; pt_i1 = output: individual triangle in it_l1 enclosing point it_p1 (nil if none)
; pt_c1 = count through list pt_l1

(defun tpop_pointintrias (pt_p1 pt_l1 pt_z1 / pt_i1 pt_c1)

; set triangle list to "not found", and go through list
 (setq pt_i1 nil pt_c1 0)
 (while (and (= pt_i1 nil) (< pt_c1 (length pt_l1)))
  (setq pt_i1 (nth pt_c1 pt_l1))

; see if point is inside individual triangle from list pt_l1 (nil if not)
  (if (= (tpop_pointintria pt_p1 pt_i1 pt_z1) nil)
   (setq pt_i1 nil)
  )

; increase counter to look at next triangle in list it_l1
  (setq pt_c1 (1+ pt_c1))
 )

; set list of triangle found (or not) to itself, so triangle list is output from this function
 (setq pt_i1 pt_i1)
)

; =============================================================================================
; OOOOO OOOO   OOO  OOOO   OOOO O      OOO  OOOO  OOOOO OOOO  OOOOO OOOO
;   O   O   O O   O O   O O     O     O   O O   O O     O   O   O   O   O
;   O   OOOO  O   O OOOO   OOO  O     O   O OOOO  OOOO  O   O   O   OOOO
;   O   O     O   O O         O O     O   O O     O     O   O   O   O   O
;   O   O      OOO  O     OOOO  OOOOO  OOO  O     OOOOO OOOO  OOOOO O   O
; =============================================================================================

; TPOPSLOPEDIR
; ============

; Description:
; ============
; Draw slope value and arrow in selected position and direction within selected 3D triangles

; Internal Variables:
; ===================
; l1 = list of groups of ((x,y,z)(x,y,z)(x,y,z)) data from 3D triangles
; o1 = initial value of DIMZIN system variable
; h1 = text height
; z1 = fuzz value
; p1 = picked point
; i1 = individual triangle in list l1
; d1, d2 = slopes values in x and y directions
; p2 = point defining direction of slope to measure
; p3 = point at corner of triangle around selected location
; d3 = z value at x,y origin (third value needed to calculate level on slope)
; a1 = angle of slope direction
; d4 = distance, then slope between points p1 and p2
; t1 = slope value text

(defun C:TPOPSLOPEDIR ( / l1 o1 h1 z1 p1 i1 d1 d2 p2 p3 d3 a1 d4 t1)
 (tpop_atstart)

; get list of x,y,z groups from user-selected 3D POLYLINE triangles
 (if (/= (setq l1 (tpop_gettriangles nil nil)) nil)
  (progn

; get initial DIMZIN system variable, text height, and fuzz value
   (setq o1 (getvar "DIMZIN") h1 (getvar "TEXTSIZE") z1 (tpop_getfuzzvalue))

; keep looking for points until user doesn't pick one (remove z value from point)
   (while (/= (setq p1 (getpoint "\nPick a location: ")) nil)
    (setq p1 (list (car p1) (cadr p1) 0.0))

; see if point is within 3D triangles
    (if (= (setq i1 (tpop_pointintrias p1 l1 z1)) nil)
     (princ "\nLocation picked not within 3D triangle. Try again...")
     (progn

; if so, get slopes in x and y direction for triangle around point picked by user
      (if (= (setq d1 (tpop_getslope i1)) nil)
       (princ "\nValue not available due to vertical slope at this location. Try again...")
       (progn
        (setq d2 (cadr d1))
        (setq d1 (car d1))

; if horizontal plane, don't get second point as slope is same in all directions, draw 0%
        (if (and (= d1 0.0) (= d2 0.0))
         (tpop_drawmctext p1 0.0 h1 "0.000%")

; otherwise ask user for second point to define direction of slope (error text if none)
         (if (= (setq p2 (getpoint p1 "\nPick direction of slope: ")) nil)
          (princ "\nNo direction selected")

; if second point picked, remove its z value
          (progn
           (setq p2 (list (car p2) (cadr p2) 0.0))

; get one corner of triangle to calculate z value at x,y origin of slope
           (setq p3 (nth 0 i1))
           (setq d3 (- (caddr p3) (* d1 (car p3)) (* d2 (cadr p3))))

; continue if two points are different (if same cannot get angle or distance)
           (if (= (tpop_eqpoint p1 p2) nil)
            (progn

; calculate angle between points and distance between points
             (setq a1 (angle p2 p1) d4 (distance p1 p2))
             (if (/= d4 0.0)
              (progn

; if distance is non-zero (should always be so here) calculate slope and draw slope
               (setq d4 (/ (- (+ d3 (* d1 (car p1)) (* d2 (cadr p1)))
                              (+ d3 (* d1 (car p2)) (* d2 (cadr p2)))) d4))
               (setvar "DIMZIN" 0)
               (setq t1 (strcat (rtos (* 100.0 d4) 2 3) "%"))
               (setvar "DIMZIN" o1)
               (tpop_drawslope p1 a1 t1 h1)
              )
             )
            )
           )
          )
         )
        )
       )
      )
     )
    )
   )
  )
 )
 (tpop_atend)
 (princ)
)

; =============================================================================================
; OOOOO OOOO   OOO  OOOO  O     OOOOO O   O OOOOO O
;   O   O   O O   O O   O O     O     O   O O     O
;   O   OOOO  O   O OOOO  O     OOOO  O   O OOOO  O
;   O   O     O   O O     O     O      O O  O     O
;   O   O      OOO  O     OOOOO OOOOO   O   OOOOO OOOOO
; =============================================================================================

; TPOPLEVEL
; =========

; Description:
; ============
; Draw spot level values at picked points within selected 3D triangles

; Internal Variables:
; ===================
; l1 = list of groups of ((x,y,z)(x,y,z)(x,y,z)) data from 3D triangles
; o1 = initial value of DIMZIN system variable
; h1 = text height
; z1 = fuzz value
; p1 = picked point
; i1 = individual triangle in list l1
; d1, d2 = slopes values in x and y directions
; p2 = point at corner of triangle around selected location
; d3 = z value at x,y origin (third value needed to calculate level on slope)
; z2 = z value within triangle at point p1

(defun C:TPOPLEVEL ( / l1 o1 h1 z1 p1 i1 d1 d2 p2 d3 z2)
 (tpop_atstart)

; get list of x,y,z groups from user-selected 3D POLYLINE triangles
 (if (/= (setq l1 (tpop_gettriangles nil nil)) nil)
  (progn

; get initial DIMZIN system variable, text height and fuzz value
   (setq o1 (getvar "DIMZIN") h1 (getvar "TEXTSIZE") z1 (tpop_getfuzzvalue))

; keep looking for points until user doesn't pick one
   (while (/= (setq p1 (getpoint "\nPick a location: ")) nil)

; see if point is within 3D triangles
    (if (= (setq i1 (tpop_pointintrias p1 l1 z1)) nil)
     (princ "\nLocation picked not within 3D triangle. Try again...")
     (progn

; if so, get slopes in x and y direction for triangle around point picked by user
      (if (= (setq d1 (tpop_getslope i1)) nil)
       (princ "\nValue not available due to vertical slope at this location. Try again...")
       (progn
        (setq d2 (cadr d1))
        (setq d1 (car d1))

; get one corner of triangle to calculate z value at x,y origin of slope
        (setq p2 (nth 0 i1))
        (setq d3 (- (caddr p2) (* d1 (car p2)) (* d2 (cadr p2))))

; then calculate z value based on triangle's slope (planar) at picked point, and create point
        (setq z2 (+ d3 (* d1 (car p1)) (* d2 (cadr p1))))
        (setq p1 (list (car p1) (cadr p1) z2))

; draw POINT at picked point
        (entmake (list (cons 0 "POINT") (cons 100 "AcDbEntity") (cons 100 "AcDbPoint")
                       (append (list 10) p1)))

; move insertion point across and up a bit, and draw z value text
        (setq p1 (list (+ (car p1) h1) (+ (cadr p1) h1) (caddr p1)))
        (setvar "DIMZIN" 0)
        (entmake (list (cons 0 "TEXT") (cons 100 "AcDbEntity") (cons 100 "AcDbText")
                       (append (list 10) p1)
                       (cons 50 0.0) (cons 40 h1) (cons 1 (rtos z2 2 3))))
        (setvar "DIMZIN" o1)
       )
      )
     )
    )
   )
  )
 )
 (tpop_atend)
 (princ)
)

; =============================================================================================
; OOOOO OOOO   OOO  OOOO  O   O  OOO  O
;   O   O   O O   O O   O O   O O   O O
;   O   OOOO  O   O OOOO  O   O O   O O
;   O   O     O   O O      O O  O   O O
;   O   O      OOO  O       O    OOO  OOOOO
; =============================================================================================

; TPOPVOL
; =======

; Description:
; ============
; Return combined volume of selected 3D triangles from zero base-line
; (doesn't differentiate between triangles above, below or through zero base-line)
; (if user wants separate cut and fill volumes relative to base-line, create flat plane at z=level
;  (e.g. two large 3D triangles that enclose triangles)
;  then use TPOPINTERS to draw 2D polyline & 3D points where triangles intercept base-line triangles
;  then use TPOPTRIA with 3D points above base-line to create 3D triangles to calculate fill
;  and TPOPTRIA with 3D points below base-line to create 3D triangles to calculate cut)

; Internal Variables:
; ===================
; l1 = list of groups of ((x,y,z)(x,y,z)(x,y,z)) data from 3D triangles
; c1 = count through list of triangles l1
; v1 = accumulated volume
; i1 = individual triangle in list l1
; p1, p2, p3 = coordinates at corners of triangle i1
; x1, y1, z1, x2, y2, z2, x3, y3, z3 = x,y,z coordinates of points p1, p2 and p3
; a1 = area of individual triangle i1
; a2 = average of levels at corners of triangle

(defun C:TPOPVOL ( / l1 c1 v1 i1 p1 p2 p3 x1 y1 z1 x2 y2 z2 x3 y3 z3 a1 a2)
 (tpop_atstart)

; get list of x,y,z groups from user-selected 3D POLYLINE triangles
 (if (/= (setq l1 (tpop_gettriangles nil nil)) nil)
  (progn

; set count to start of list of triangles, set initial volume to zero, go through list
   (setq c1 0 v1 0)
   (while (< c1 (length l1))

; get individual triangle from list, corner points, and x,y,z coordinates of corners
    (setq i1 (nth c1 l1))
    (setq p1 (nth 0 i1) p2 (nth 1 i1) p3 (nth 2 i1))
    (setq x1 (car p1) y1 (cadr p1) z1 (caddr p1) x2 (car p2) y2 (cadr p2) z2 (caddr p2)
          x3 (car p3) y3 (cadr p3) z3 (caddr p3))

; calculate area of triangle in x,y plane, and z value at triangle mid point
; (note: area of triangle in x,y plane simplified from:
;        (length of line p1-p2 * length of perpendicular from p3 to line p1-p2) / 2
;        because length of perpendicular is a factor of length p1-p2, so length cancels out)
    (setq a1 (abs (/ (- (* (- x3 x1) (- y2 y1)) (* (- x2 x1) (- y3 y1))) 2.0))
          a2 (/ (+ z1 z2 z3) 3.0))

; multiply these together and add to volume value
    (setq v1 (+ v1 (* a1 a2)))

; increase counter to look at next triangle in list
    (setq c1 (1+ c1))
   )

; display volume result, using 10 to the power format for numbers > 10 to power of 6
   (princ (strcat "\nVolume of " (itoa (length l1)) " triangle(s) from base-line: "))
   (if (< v1 1000000.0)
    (princ (rtos v1 2 3))
    (princ (rtos v1 1 3))
   )
  )
 )
 (tpop_atend)
 (princ)
)

; =============================================================================================

; TPOP_GETLAYERNAME
; =================

; Description:
; ============
; Ask user for layer name and check layer exists

; Internal Variables:
; ===================
; ln_t1 = input: text to display when asking for layer name
; ln_t2 = output: layer name entered by user (or nil if nothing entered, or layer not found)

(defun tpop_getlayername (ln_t1 / ln_t2)

; ask user for layer name (can contain spaces), error message if nothing entered
 (if (= (setq ln_t2 (getstring T ln_t1)) nil)
  (princ "\nNo layer name entered. Command terminating")

; check layer exists with this layer name, error message if none found, set name to "none"
  (if (= (tblsearch "LAYER" ln_t2) nil)
   (progn
    (princ "\nNo layer with this name was found. Command terminating")
    (setq ln_t2 nil)
   )
  )
 )

; set layer name to itself, so layer name is output from this function
 (setq ln_t2 ln_t2)
)

; =============================================================================================

; TPOP_GETTRIASTATS
; =================

; Description:
; ============
; Get statistics for 3D triangle provided

; Internal Variables:
; ===================
; ts_l1 = input: list of three (x,y,z) coordinate groups forming 3D triangle
; ts_l2 = output: list of slope factors and min/max x,y,z values
; ts_p1, ts_p2, ts_p3 = points on each corner of triangle
; ts_x1, ts_y1, ts_z1, ts_x2, ts_y2, ts_z2, ts_x3, ts_y3, ts_z3 = x,y,z coordinates
; ts_f1 = slope factor in x direction
; ts_f2 = slope factor in y direction
; ts_f3 = slope z value when x and y = 0
; ts_c1 = counter through corners of triangle
; ts_p1 = point on each corner of triangle in turn
; ts_x1, ts_y1, ts_z1 = x,y,z coordinates of point ts_p1
; ts_x2, ts_y2, ts_z2 = minimum x,y,z values of triangle
; ts_x3, ts_y3, ts_z3 = maximum x,y,z values of triangle

(defun tpop_gettriastats (ts_l1 / ts_l2 ts_p1 ts_p2 ts_p3 ts_x1 ts_y1 ts_z1 ts_x2 ts_y2
                                  ts_z2 ts_x3 ts_y3 ts_z3 ts_f1 ts_f2 ts_f3 ts_c1)

; set output list to empty (for when some statistics aren't available)
 (setq ts_l2 nil)

; get x,y,z coordinates for all three corners of triangle
 (setq ts_p1 (nth 0 ts_l1) ts_p2 (nth 1 ts_l1) ts_p3 (nth 2 ts_l1))
 (setq ts_x1 (car ts_p1) ts_y1 (cadr ts_p1) ts_z1 (caddr ts_p1)
       ts_x2 (car ts_p2) ts_y2 (cadr ts_p2) ts_z2 (caddr ts_p2)
       ts_x3 (car ts_p3) ts_y3 (cadr ts_p3) ts_z3 (caddr ts_p3))

; calculate denominator of slope of 3D plane in x direction, only continue if non-zero
 (setq ts_f1 (- (* (- (* ts_x1 ts_y3) (* ts_x3 ts_y1)) (- ts_y1 ts_y2))
                (* (- (* ts_x1 ts_y2) (* ts_x2 ts_y1)) (- ts_y1 ts_y3))))
 (if (/= ts_f1 0.0)
  (progn

; finish calculation of slope in 3D plane in x direction
   (setq ts_f1 (/ (- (* (- (* ts_y1 ts_z2) (* ts_y2 ts_z1)) (- ts_y1 ts_y3))
                     (* (- (* ts_y1 ts_z3) (* ts_y3 ts_z1)) (- ts_y1 ts_y2))) ts_f1))

; calculate denominator of slope of 3D plane in y direction, only continue if non-zero
   (setq ts_f2 (- (* (- (* ts_x1 ts_y2) (* ts_x2 ts_y1)) (- ts_x1 ts_x3))
                  (* (- (* ts_x1 ts_y3) (* ts_x3 ts_y1)) (- ts_x1 ts_x2))))
   (if (/= ts_f2 0.0)
    (progn

; finish calculation of slope in 3D plane in y direction
     (setq ts_f2 (/ (- (* (- (* ts_x1 ts_z2) (* ts_x2 ts_z1)) (- ts_x1 ts_x3))
                       (* (- (* ts_x1 ts_z3) (* ts_x3 ts_z1)) (- ts_x1 ts_x2))) ts_f2))

; calculate z value of 3D plane at x,y origin
     (setq ts_f3 (- ts_z1 (* ts_f1 ts_x1) (* ts_f2 ts_y1)))

; count through each corner of triangle to get min/max x,y,z values
     (setq ts_c1 0)
     (while (< ts_c1 3)
      (setq ts_p1 (nth ts_c1 ts_l1))
      (setq ts_x1 (car ts_p1) ts_y1 (cadr ts_p1) ts_z1 (caddr ts_p1))

; if first corner, just use current x,y c,zoordinates, otherwise remember min/max only
      (if (= ts_c1 0)
       (setq ts_x2 ts_x1 ts_y2 ts_y1 ts_z2 ts_z1 ts_x3 ts_x1 ts_y3 ts_y1 ts_z3 ts_z1)
       (setq ts_x2 (min ts_x2 ts_x1) ts_y2 (min ts_y2 ts_y1) ts_z2 (min ts_z2 ts_z1)
             ts_x3 (max ts_x3 ts_x1) ts_y3 (max ts_y3 ts_y1) ts_z3 (max ts_z3 ts_z1))
      )

; increase counter to look at next corner of triangle
      (setq ts_c1 (1+ ts_c1))
     )

; create output list of 3 slope factors followed by min/max x,y,z values
     (setq ts_l2 (list ts_f1 ts_f2 ts_f3 ts_x2 ts_y2 ts_z2 ts_x3 ts_y3 ts_z3))
    )
   )
  )
 )

; set statistics list itself, so list is output from this function
 (setq ts_l2 ts_l2)
)

; =============================================================================================
; OOOOO OOOO   OOO  OOOO  OOOOO O   O OOOOO OOOOO OOOO   OOOO
;   O   O   O O   O O   O   O   OO  O   O   O     O   O O
;   O   OOOO  O   O OOOO    O   O O O   O   OOOO  OOOO   OOO
;   O   O     O   O O       O   O  OO   O   O     O   O     O
;   O   O      OOO  O     OOOOO O   O   O   OOOOO O   O OOOO
; =============================================================================================

; TPOPINTERS
; ==========

; Description:
; ============
; Draw lightweight polyline and 3D POINTS along where two sets of 3D triangles intersect

; Internal Variables:
; ===================
; t1, t2 = layer names of two layers containing each group of 3D points
; l1, l2 = lists of two groups of ((x,y,z)(x,y,z)(x,y,z)) data from 3D triangles
; l3 = (very briefly) swap value for swapping round l1 and l2
; u1 = fuzz value
; l3 = list of 3D line segments along intersection of two groups of 3D triangles
; c1 = count through list l1
; i1 = individual triangle in list l1
; x1, y1, z1 = minimum x,y,z coordinates for triangle i1
; x2, y2, z2 = maximum x,y,z coordinates for triangle i1
; e1, f1, g1 = slope constants for 3D plane of triangle i1 (equation: z=ex+fy+g)
; c2 = count through list l2
; i2 = individual triangle in list l2
; x3, y3, z3 = minimum x,y,z coordinates for triangle i2
; x4, y4, z4 = maximum x,y,z coordinates for triangle i2
; e2, f2, g2 = slope constants for 3D plane of triangle i2 (equation: z=ex+fy+g)
; x5, y5, x6, y6 = x,y coorindates on line where planes from i1 and i2 intersect
; m1, m2 = multipliers to calculate x or y slope intercept coordinates
; l4 = list of intersection points between planes intersection and triangle side
; c3 = count through two triangles
; i3, i4 = either triangle i1 or triangle i2 (or other way round)
; c4 = count through sides of triangle i3
; p1, p2 = points at each end of side of triangle
; x7, y7, z7, x8, y8, z8 = x,y,z coordinates of points p1 and p2
; r1 = ratio along line p1-p2 to interception point with planes intercept line
; x9, y9, z9 = x,y,z coordinates at interption point
; c5 = count through list l4
; b1 = flag: T if point x9,y9 already in list l4
; i5 = individual item in list l4
; l3 = list of 3D points along intersection polyline(s)
; c1 = count through list l3
; i1 = individual point in list l3
; f1 = flag: T = point has been found on triangle corner, nil if not yet
; c2 = count through lists of list l1 and l2
; l4 = either list l1 or list l2, depending on c2 value
; c3 = count through list l4
; i2 = individual triangle in list l4
; c4 = count through corners of triangle i2

(defun C:TPOPINTERS ( / t1 t2 l1 l2 l3 u1 c1 i1 e1 f1 g1 x1 y1 z1 x2 y2 z2 c2 i2 e2 f2 g2
                        x3 y3 z3 x4 y4 z4 x5 x6 m1 m2 y5 y6 l4 c3 i3 i4 c4 p1 p2 x7 y7 z7
                        x8 y8 z8 r1 x9 y9 z9 c5 b1 i5)
 (tpop_atstart)

; get layer names for each group of 3D triangles
 (if (/= (setq t1 (tpop_getlayername
                   "\nEnter layer name for first group of 3D triangles ")) nil)
  (if (/= (setq t2 (tpop_getlayername
                    "\nEnter layer name for second group of 3D triangles ")) nil)

; get lists of x,y,z groups from user-selected 3D POLYLINE triangles on each layer
   (if (/= (setq l1 (tpop_gettriangles nil t1)) nil)
    (if (/= (setq l2 (tpop_gettriangles nil t2)) nil)
     (progn

; swap lists if necessary so list l2 is not longer than list l1 (for quicker command)
      (if (< (length l1) (length l2))
       (progn
        (setq l3 l2)
        (setq l2 l1)
        (setq l1 l3)
       )
      )

; get fuzz value
      (setq u1 (tpop_getfuzzvalue))

; set empty list of 3D lines along intersection of triangles, look through list l1
      (setq l3 nil c1 0)
      (while (< c1 (length l1))

; get individual 3D triangle from list l1, and get its statistics
       (setq i1 (nth c1 l1))
       (if (/= (setq e1 (tpop_gettriastats i1)) nil)
        (progn

; only continue with this triangle if statistics are available (crosses x,y axes)
         (setq f1 (nth 1 e1) g1 (nth 2 e1)
               x1 (nth 3 e1) y1 (nth 4 e1) z1 (nth 5 e1)
               x2 (nth 6 e1) y2 (nth 7 e1) z2 (nth 8 e1))
         (setq e1 (nth 0 e1))

; compare triangle i1 with each triangle in list l2
         (setq c2 0)
         (while (< c2 (length l2))

; get individual 3D triangle from list l2, and get its statistics
          (setq i2 (nth c2 l2))
          (if (/= (setq e2 (tpop_gettriastats i2)) nil)
           (progn

; only continue with this triangle if statistics are available (crosses x,y axes)
            (setq f2 (nth 1 e2) g2 (nth 2 e2)
                  x3 (nth 3 e2) y3 (nth 4 e2) z3 (nth 5 e2)
                  x4 (nth 6 e2) y4 (nth 7 e2) z4 (nth 8 e2))
            (setq e2 (nth 0 e2))

; only look for intersection line between triangles if min/max cubes overlap
; and if planes formed by each triangle are not coplanar (but can be flat in one direction)
            (if (and (<= x1 x4) (>= x2 x3) (<= y1 y4) (>= y2 y3) (<= z1 z4) (>= z2 z3)
                     (or (/= e1 e2) (/= f1 f2)))
             (progn

; calculate x,y coordinates at each end of planes intersection line on min/max x,y rectangle
              (if (< (abs (- e1 e2)) (abs (- f1 f2)))
               (progn

; calculate x first if line is nearer the x axis (i.e. f1-f2 = not 0)
                (setq x5 (min x1 x3) x6 (max x2 x4))
                (setq m1 (/ (- e2 e1) (- f1 f2)) m2 (/ (- g2 g1) (- f1 f2)))
                (setq y5 (+ (* m1 x5) m2) y6 (+ (* m1 x6) m2))
               )
               (progn

; calculate y first if line is nearer the y axis (i.e. e1-e2 = not 0)
                (setq y5 (min y1 y3) y6 (max y2 y4))
                (setq m1 (/ (- f2 f1) (- e1 e2)) m2 (/ (- g2 g1) (- e1 e2)))
                (setq x5 (+ (* m1 y5) m2) x6 (+ (* m1 y6) m2))
               )
              )

; keep going if at least part of intersection line is within min/max x,y rectangle
              (if (and (<= (min x5 x6) (max x2 x4)) (>= (max x5 x6) (min x1 x3))
                       (<= (min y5 y6) (max y2 y4)) (>= (max y5 y6) (min y1 y3)))
               (progn

; set empty list of points on/in triangles on intersection line
                (setq l4 nil c3 0)
                (while (< c3 2)

; compare two triangles both ways round (edges of first, inside second)
                 (if (= c3 0)
                  (setq i3 i1 i4 i2)
                  (setq i3 i2 i4 i1)
                 )

; go through three sides of first triangle, calculating x,y,z of intersection points
                 (setq c4 0)
                 (while (< c4 3)

; get points (then x,y,z) of each side of first triangle in turn
                  (setq p1 (nth (nth c4 (list 0 1 2)) i3)
                        p2 (nth (nth c4 (list 1 2 0)) i3))
                  (setq x7 (car p1) y7 (cadr p1) z7 (caddr p1)
                        x8 (car p2) y8 (cadr p2) z8 (caddr p2))

; calculate distance along this side to intersection point
                  (setq r1 (- (* (- x8 x7) (- y6 y5)) (* (- x6 x5) (- y8 y7))))
                  (if (/= r1 0.0)
                   (progn
                    (setq r1 (/ (- (* (- x6 x5) (- y7 y5)) (* (- x7 x5) (- y6 y5))) r1))

; if intersection point is within extents of line, calculate intersection point
                    (if (and (>= r1 (- u1)) (<= r1 (+ 1.0 u1)))
                     (progn
                      (setq x9 (+ x7 (* r1 (- x8 x7)))
                            y9 (+ y7 (* r1 (- y8 y7)))
                            z9 (+ z7 (* r1 (- z8 z7))))

; see if intersection point is also within other triangle
                      (if (= (tpop_pointintria (list x9 y9 0.0) i4 u1) T)
                       (progn

; see if intersection point is already in intersection line list
                        (setq c5 0 b1 nil)
                        (while (and (< c5 (length l4)) (= b1 nil))
                         (setq i5 (nth c5 l4))

; set flag if intersection point is already on single contour line, so don't add it again
                         (setq b1 (tpop_comppoint x9 y9 (car i5) (cadr i5) u1))
                         (setq c5 (1+ c5))
                        )

; if it isn't in list, add it to list
                        (if (= b1 nil)
                         (setq l4 (tpop_addtolist l4 (list x9 y9 z9)))
                        )
                       )
                      )
                     )
                    )
                   )
                  )

; increase counters to look at next side of first triangle, then swap triangles around 
                  (setq c4 (1+ c4))
                 )
                 (setq c3 (1+ c3))
                )

; if two intersection points for these two triangles, add them to intersection line list
                (if (= (length l4) 2)
                 (setq l3 (tpop_addtolist l3 l4))
                )
               )
              )
             )
            )
           )
          )

; increase counters through lists l2 and l1
          (setq c2 (1+ c2))
         )
        )
       )
       (setq c1 (1+ c1))
      )

; if list of 3D lines along intersection of triangles exits, create 2D polyline
      (if (/= l3 nil)
       (progn
        (setq l3 (tpop_linestoplines l3 u1 0.0 T))

; and draw 3D points along polyline if points not at corners of 3D triangles
        (setq c1 0)
        (while (< c1 (length l3))
         (setq i1 (nth c1 l3) f1 nil c2 0)

; look at two lists of triangles
         (while (and (= f1 nil) (< c2 2))
          (if (= c2 0)
           (setq l4 l1)
           (setq l4 l2)
          )

; go through each list in turn, getting each individual triangle
          (setq c3 0)
          (while (and (= f1 nil) (< c3 (length l4)))
           (setq i2 (nth c3 l4) c4 0)

; go through corners of corners, setting flag if corner matching point is found
           (while (and (= f1 nil) (< c4 3))
            (setq f1 (tpop_eqpoint i1 (nth c4 i2)))
            (setq c4 (1+ c4))
           )

; increase counters for next triangle, next triangle list
           (setq c3 (1+ c3))
          )
          (setq c2 (1+ c2))
         )

; create point if no match found on corner of triangles in lists l1 or l2
         (if (= f1 nil)
          (entmake (list (cons 0 "POINT") (cons 100 "AcDbEntity") (cons 100 "AcDbPoint")
                         (append (list 10) i1)))
         )

; increase counter for next point on polyline
         (setq c1 (1+ c1))
        )
       )
      )

; if command finished, show message, as command can take a while to complete
      (princ "\nCommand finished")
     )
    )
   )
  )
 )
 (tpop_atend)
 (princ)
)

; =============================================================================================
; OOOOO OOOO   OOO  OOOO  O   O O   O O     OOOOO
;   O   O   O O   O O   O OO OO O   O O        O
;   O   OOOO  O   O OOOO  O O O O   O O       O
;   O   O     O   O O     O   O O   O O      O
;   O   O      OOO  O     O   O  OOO  OOOOO OOOOO
; =============================================================================================

; TPOPMULZ
; ========

; Description:
; ============
; Multiply (or divide) z-values of selected POINTs

; Global Variables:
; =================
; tpop_mulzfactor = multiplication factor (or division if between 1 and -1)

; Internal Variables:
; ===================
; s1 = selection set of 3D POINTs
; f1 = multiplication factor
; c1 = count through selection set s1
; d1 = entity data of each POINT in s1
; p1 = insertion point of POINT

(defun C:TPOPMULZ ( / s1 f1 c1 d1 p1)
 (tpop_atstart)

; ask user to select POINT objects
 (princ "\nSelect POINT objects...")
 (if (= (setq s1 (ssget (list (cons 0 "POINT")))) nil)
  (princ "\nNo POINTs selected. Command terminating")
  (progn

; get multiplcation factor, and store as global variable
   (setq f1 (tpop_getglobalval "Enter multiplication factor" tpop_mulzfactor 10.0 nil))
   (setq tpop_mulzfactor f1)

; set counter to start of selection set, go through it, get each object's data
   (setq c1 0)
   (repeat (sslength s1)
    (setq d1 (entget (ssname s1 c1)))

; continue if object has x,y,z insertion point
    (if (/= (assoc 10 d1) nil)
     (progn

; get insertion point of POINT, and multiply the z coordinate by multiplication factor
      (setq p1 (cdr (assoc 10 d1)))
      (setq p1 (list (car p1) (cadr p1) (* (caddr p1) f1)))

; update data list for POINT and update object in drawing
      (setq d1 (subst (append (list 10) p1) (assoc 10 d1) d1))
      (entmod d1)
     )
    )

; increase counter to look at next object in selection set
    (setq c1 (1+ c1))
   )

; discard selection set as no longer needed (and free computer memory)
   (setq s1 nil)
  )
 )
 (tpop_atend)
 (princ)
)

; =============================================================================================
; OOOOO OOOO   OOO  OOOO   OOOO OOOOO OOOOO OOOOO O   O OOOOO OOOOO
;   O   O   O O   O O   O O     O       O   O     O   O    O     O
;   O   OOOO  O   O OOOO   OOO  OOOO    O   OOOO  O   O   O     O
;   O   O     O   O O         O O       O   O     O   O  O     O
;   O   O      OOO  O     OOOO  OOOOO   O   O      OOO  OOOOO OOOOO
; =============================================================================================

; TPOPSETFUZZ
; ===========

; Description:
; ============
; Set fuzz factor to allow nearly equal numbers to be seen as equal (in other functions)

; Global Variables:
; =================
; tpop_fuzzfactor = fuzz/blur factor to allow for rounding errors (0 = none, 1 = small, 9 = big)

; Internal Variables:
; ===================
; sf_z1 = output: fuzz factor (0 = none, 1 = small to 9 = big), then fuzz value

(defun C:TPOPSETFUZZ ( / sf_z1)

; ask user for fuzz factor, using default value if user doesn't enter a value
 (setq sf_z1 (tpop_getglobalval "Enter fuzz factor (0 = none, 1 = small to 9 = big)"
              tpop_fuzzfactor 5 T))

; make sure fuzz factor is within desired limits
 (if (< sf_z1 0)
  (setq sf_z1 0)
  (if (> sf_z1 9)
   (setq sf_z1 9)
  )
 )

; store it as global variable
 (setq tpop_fuzzfactor sf_z1)
 (princ)
)

; =============================================================================================
; Set PI variables used by various routines in TOPOPROCESS.lsp

(setq tpop_pi            3.1415926535897932384626433832795
      tpop_halfpi        1.5707963267948966192313216916398
      tpop_oneandahalfpi 4.7123889803846898576939650749193)

; =============================================================================================
; Output to screen when this lisp file is uploaded:

(princ "\nTOPOPROCESS.lsp loaded (Version 1.05 GD 13-Aug-2015) including the following commands:")
(princ "\n TPOPTRIA - draws 3D triangles based on set of 3D points, boundaries and breaklines")
(princ "\n TPOPSWAP - swaps the shared edge between two adjacent 3D triangles")
(princ "\n TPOPGETTHIN - returns flatness ratio range for selected 3D triangles")
(princ "\n TPOPDELTHIN - deletes flat or near-flat 3D triangles (e.g. around the boundary)")
(princ "\n TPOPSOLID - draws SOLIDs based on a set of 3D triangle coordinates and colours")
(princ "\n TPOPCONT - draws contour polylines based on a set of 3D triangles")
(princ "\n TPOPCONTLABEL - draws text labels of contour z value next to selected contours")
(princ "\n TPOPSLOPEMAX - draws maximum slope values and directions on selected 3D triangles")
(princ "\n TPOPSLOPEDIR - draws slope value at particular point/direction on selected 3D triangles")
(princ "\n TPOPLEVEL - draws spot levels at locations picked within 3D triangles")
(princ "\n TPOPVOL - returns volume of 3D triangles from zero base-line")
(princ "\n TPOPINTERS - draws polyline where two sets of 3D triangles intersect")
(princ "\n TPOPMULZ - multiplies/divides z-coordinates of 3D points by a value")
(princ "\n TPOPSETFUZZ - set fuzz value for other commands (e.g. allows 0.0000000001 = 0.0)")
(princ)

; =============================================================================================
; Revision information:
; 1.01 - TPOPSOLID - changed to draw SOLIDs at average z-coordinate of three points and to
;                    copy colour of source triangle if it has colour other than bylayer
;                    (formally just copied x,y,z coordinates at corners of triangle, but a
;                    SOLID should have same z value for all corners to comply with AutoCAD)
; 1.01 - "Output to screen" description for TPOPSOLID changed
; 1.02 - "not yet" note removed from description comments for TPOP_LINESTOPLINES
; 1.02 - TPOP_DRAWMCTEXT added to draw middle-centre aligned text (includes height - required for AutoCAD)
; 1.02 - use TPOP_DRAWMCTEXT to draw text in TPOPCONTLABEL, TPOP_DRAWSLOPE, TPOPSLOPEMAX and TPOPSLOPEDIR 
; 1.02 - text height included in entmake when drawing single line text in TPOPLEVEL (required for AutoCAD)
; 1.02 - PI numerical-typed values replaced with tpop_... variables
; 1.03 - variable lists audited and updated
; 1.04 - TOPOCONT changed to TPOPCONT in TPOPCONT description notes
; 1.04 - '100' group codes included in entmake data lists in TPOP_DRAW3DTRIA, TPOPSOLID, TPOP_LINESTOPLINES,
;        TPOP_DRAWMCTEXT, TPOP_DRAWSLOPE, TPOPLEVEL and TPOPINTERS for compatibility with newer versions
;        of AutoCAD
; 1.04 - '91' vertex codes included in LWPOLYLINE entmake data lists in TPOP_LINESTOPLINES and TPOP_DRAWSLOPE
;        for compatibility with newer versions of AutoCAD
; 1.04 - '38' elevation code included in LWPOLYLINE entmake data list in TPOP_DRAWSLOPE
; 1.04 - '43' constant width code included in LWPOLYLINE entmake data list in TPOP_LINESTOPLINES
; 1.04 - TPOP_MAKE2DPOINT added to ensure all points in LWPOLYLINE data lists are 2D, not 3D. Function used
;        in TPOP_LINESTOPLINES and TPOP_DRAWSLOPE
; 1.05 - TPOPSOLID - option added to draw SOLID at either average z-coordinate value or at
;                    100 x max slope value (i.e. 2.5 for 1 in 40 max slope, or 0 for a flat triangle)
;                    and option added whether to copy colour of source triangle or not
; 1.05 - TPOP_GETSLOPE moved to just before TPOPSOLID so it can be used by TPOPSOLID
