; CHAINAGE_ERRORMSG, CHAINAGE_ATSTART and CHAINAGE_ATEND
; ======================================================

; Description:
; ============
; Handle error messages, set-up and restore point to error message handler, and being/end UNDO loop

; Global Variables:
; =================
; chainage_olderr = pointer to old error message handler

; Internal Variables:
; ===================
; ce_t1 = error message passed to error message handler
; ce_o1 = old value of CMDECHO in chainage_errormsg
; cs_o1 = old value of CMDECHO in chainage_atstart
; ca_o1 = old value of CMDECHO in chainage_atend

(defun chainage_errormsg (ce_t1 / ce_o1)

; restore pointer to old error message handler and display error message
 (setq *error* chainage_olderr)
 (setq chainage_olderr nil)
 (princ (strcat "\nCommand stopped due to error: " ce_t1))

; end UNDO group command
 (setq ce_o1 (getvar "CMDECHO"))
 (setvar "CMDECHO" 0)
 (command "UNDO" "E")
 (setvar "CMDECHO" ce_o1)
 (princ)
)

(defun chainage_atstart ( / cs_o1)

; set error message handler pointer to new error message handler
 (setq chainage_olderr *error*)
 (setq *error* chainage_errormsg)

; begin UNDO group command
 (setq cs_o1 (getvar "CMDECHO"))
 (setvar "CMDECHO" 0)
 (command "UNDO" "BE")
 (setvar "CMDECHO" cs_o1)
)

(defun chainage_atend ( / ca_o1)

; end UNDO group command
 (setq ca_o1 (getvar "CMDECHO"))
 (setvar "CMDECHO" 0)
 (command "UNDO" "E")
 (setvar "CMDECHO" ca_o1)

; restore pointer to old error message handler
 (setq *error* chainage_olderr)
 (setq chainage_olderr nil)
)

; =======================================================================================================

; CHAINAGE_GETGLOBALVAL
; =====================

; Description:
; ============
; Asks user for a value, using global value if available as default
; Inputs: text, global variable value, default value
; Output: value

; Internal Variables:
; ===================
; cg_t1 = text to display when asking for value
; cg_g1 = value of global variable (nil if variable not defined yet)
; cg_d1 = default value if global variable is nil and user doesn't enter a value
; cg_b1 = flag: T for integers, nil for real values
; cg_v1 = value returned from function

(defun chainage_getglobalvalue (cg_t1 cg_g1 cg_d1 cg_b1 / cg_v1)

; append default value (by type) to question text if global variable is nil
 (setq cg_t1 (strcat cg_t1 ": <"))
 (if (= cg_g1 nil)
  (if (= cg_b1 T)
   (setq cg_t1 (strcat cg_t1 (itoa cg_d1)))
   (setq cg_t1 (strcat cg_t1 (rtos cg_d1 2 3)))
  )

; otherwise append global value provided (by type) if it is provided
  (if (= cg_b1 T)
   (setq cg_t1 (strcat cg_t1 (itoa cg_g1)))
   (setq cg_t1 (strcat cg_t1 (rtos cg_g1 2 3)))
  )
 )
 (setq cg_t1 (strcat cg_t1 "> "))

; ask user for value
 (if (= cg_b1 T)
  (setq cg_v1 (getint cg_t1))
  (setq cg_v1 (getreal cg_t1))
 )

; if user doesn't enter a value, use global variable value (if defined) or default value (if global not defined yet)
 (if (= cg_v1 nil)
  (if (= cg_g1 nil)
   (setq cg_v1 cg_d1)
   (setq cg_v1 cg_g1)
  )
 )

; set output value to itself, so that this is the output from this function
 (setq cg_v1 cg_v1)
)

; =======================================================================================================

; PARSE_POLYLINE
; ==============

; Description:
; ============
; Creates an easier-to-use list of lines and arc elements in a lightweight polyline
; Input: data list for lightweight polyline (e.g. from entget)
; Output: list of line and arc segments in format
;         LINE (start point) (end point) distance
;         ARC (start point) (end point) circumference (centre point) radius start-angle end-angle

; Scope for improvement:
; ======================
; Current version of this command doesn't check for closed polylines

; Internal Variables:
; ===================
; pp_d1 = lightweight polyline data list passed to function
; pp_c1 = count through polyline data list
; pp_p1 = start point for line or arc segment
; pp_l2 = output list of line and arc data - output from function
; pp_z1 = z coordinate for lightweight polyline
; pp_n1 = code value of item pp_i1
; pp_i1 = individual item in polyline data list
; pp_b1 = bulge factor for arc segment (= 0.0 for line segment)
; pp_p2 = end point for line or arc segment
; pp_i2 = individual item to be added to output list
; pp_x1, pp_y1 = x and y coordinates of pp_p1
; pp_x2, pp_y2 = x and y coordinates of pp_p2
; pp_x3, pp_y3 = x and y coordinates for mid-point between pp_p1 and pp_p2, then x and y coordinates for centre of arc
; pp_x4, pp_y4 = x and y coordinates for mid-point along arc segment
; pp_f1, pp_f2 = numerators for calculating arc centre-point
; pp_f3 = denominator for calculating arc centre-point
; pp_p3 = arc centre-point
; pp_a1 = start angle (in radians) for arc segment
; pp_a2 = end angle (in radians) for arc segment
; pp_r1 = radius of arc segment

(defun parse_polyline (pp_d1 / pp_c1 pp_p1 pp_l2 pp_z1 pp_n1 pp_i1 pp_b1 pp_p2 pp_i2 pp_x1 pp_y1 pp_x2
                               pp_y2 pp_x3 pp_y3 pp_x4 pp_y4 pp_f1 pp_f2 pp_f3 pp_p3 pp_a1 pp_a2 pp_r1)

; set counter, undefined start point, and empty output list
 (setq pp_c1 0 pp_p1 nil pp_l2 nil)

; get z coordinate for lightweight polyline (or set to 0 if no z coordinate available)
 (if (= (assoc 38 pp_d1) nil)
  (setq pp_z1 0.0)
  (setq pp_z1 (cdr (assoc 38 pp_d1)))
 )

; go through each item in lightweight polyline data list
 (repeat (length pp_d1)

; get code and values for each item in source polyline data list
  (setq pp_n1 (car (setq pp_i1 (nth pp_c1 pp_d1))))

; store bulge factor
  (if (= pp_n1 42)
   (setq pp_b1 (cdr pp_i1))

; point at start/end of segment
   (if (= pp_n1 10)

; store start point, adding z coordinate if only a 2D point
    (if (= pp_p1 nil)
     (progn
      (setq pp_p1 (cdr pp_i1))
      (if (= (length pp_p1) 2)
       (setq pp_p1 (append pp_p1 (list pp_z1)))
      )
     )

; store end point, adding z coordinate if only a 2D point
     (progn
      (setq pp_p2 (cdr pp_i1))
      (if (= (length pp_p2) 2)
       (setq pp_p2 (append pp_p2 (list pp_z1)))
      )

; create new item for adding to output list
      (if (= pp_b1 0.0)
       (setq pp_i2 (list "LINE"))
       (setq pp_i2 (list "ARC"))
      )
      (setq pp_i2 (append pp_i2 (list pp_p1) (list pp_p2)))

; if line segment add length of line to output item
      (if (= pp_b1 0.0)
       (setq pp_i2 (append pp_i2 (list (distance pp_p1 pp_p2))))

; if arc segment...
       (progn
        (setq pp_x1 (car pp_p1) pp_y1 (cadr pp_p1) pp_x2 (car pp_p2) pp_y2 (cadr pp_p2))

; calculate point mid-way between arc segment start and end points (in straight line)
        (setq pp_x3 (/ (+ pp_x1 pp_x2) 2.0) pp_y3 (/ (+ pp_y1 pp_y2) 2.0))

; calculate point mid-way along arc segment (so have three points to calculate arc centre-point)
        (setq pp_x4 (+ pp_x3 (* pp_b1 (- pp_y3 pp_y1))) pp_y4 (+ pp_y3 (* pp_b1 (- pp_x1 pp_x3))))

; calculate numerators and denominators for calculating arc centre-point
        (setq pp_f1 (- (+ (* pp_x1 pp_x1) (* pp_y1 pp_y1)) (* pp_x2 pp_x2) (* pp_y2 pp_y2)))
        (setq pp_f2 (- (+ (* pp_x1 pp_x1) (* pp_y1 pp_y1)) (* pp_x4 pp_x4) (* pp_y4 pp_y4)))
        (setq pp_f3 (- (* (- pp_x1 pp_x2) (- pp_y1 pp_y4)) (* (- pp_x1 pp_x4) (- pp_y1 pp_y2))))

; calculate arc centre-point
        (setq pp_x3 (/ (- (* (- pp_y1 pp_y4) pp_f1) (* (- pp_y1 pp_y2) pp_f2)) (* pp_f3 2.0)))
        (setq pp_y3 (/ (- (* (- pp_x1 pp_x2) pp_f2) (* (- pp_x1 pp_x4) pp_f1)) (* pp_f3 2.0)))
        (setq pp_p3 (list pp_x3 pp_y3 (caddr pp_p1)))

; calculate arc start and end angles (increasing if -ve bulge/anti-clockwise, decreasing if +ve/clockwise) and radius
        (setq pp_a1 (angle pp_p3 pp_p1) pp_a2 (angle pp_p3 pp_p2) pp_r1 (distance pp_p3 pp_p1))
        (if (and (< pp_b1 0.0) (<= pp_a1 pp_a2))
         (setq pp_a1 (+ pp_a1 chainage_twopi))
        )
        (if (and (> pp_b1 0.0) (<= pp_a2 pp_a1))
         (setq pp_a2 (+ pp_a2 chainage_twopi))
        )

; add length of arc segment to output item
        (if (< pp_b1 0.0)
         (setq pp_i2 (append pp_i2 (list (* (- pp_a1 pp_a2) pp_r1))))
         (setq pp_i2 (append pp_i2 (list (* (- pp_a2 pp_a1) pp_r1))))
        )

; add centre-point, radius, start-angle and end-angle to output item
        (setq pp_i2 (append pp_i2 (list pp_p3 pp_r1 pp_a1 pp_a2)))
       )
      )

; only add line or arc segment to list if it has length (ignore it otherwise)
      (if (> (nth 3 pp_i2) 0.0)

; create output list if doesn't exist yet, otherwise add output item to output list
       (if (= pp_l2 nil)
        (setq pp_l2 (list pp_i2))
        (setq pp_l2 (append pp_l2 (list pp_i2)))
       )
      )

; start point of next segment = end point of current segment 
      (setq pp_p1 pp_p2)
     )
    )
   )
  )

; increase counter to look at next item in source lightweight polyline data list
  (setq pp_c1 (1+ pp_c1))
 )

; set output list to itself, so that this is the output from this function
 (setq pp_l2 pp_l2)
)

; =======================================================================================================

; PARSE_POLYLINE_GETLEN
; =====================

; Description:
; ============
; Gets length of polyline list parsed using parse_polyline function
; Input: list of line and arc segments in parse_polyline format
; Output: total length of all segments

; Internal Variables:
; ===================
; pg_l1 = list of line and arc data - outputted from parse_polyline function
; pg_c1 = count through list of data
; pg_n2 = total length value (output)

(defun parse_polyline_getlen (pg_l1 / pg_c1 pg_n2)

; initiate counter and length to zero
 (setq pg_c1 0 pg_n2 0.0)

; go through each element in list
 (repeat (length pg_l1)

; add up length values in each element in list
  (setq pg_n2 (+ pg_n2 (nth 3 (nth pg_c1 pg_l1))))

; increase counter to look at next element in list
  (setq pg_c1 (1+ pg_c1))
 )

; set output length to itself, so that this is the output from this function
 (setq pg_n2 pg_n2)
)

; =======================================================================================================

; CHAINAGE_SELECTPLINE
; ====================

; Description:
; ============
; Gets user to select a lightweight polyline
; Output: polyline parse data (using parse_polyline) or nil if nothing selected

; Internal Variables:
; ===================
; cp_l1 = output polyline parsed list
; cp_e1 = selected polyline entity
; cp_d1 = selected polyline data list

(defun chainage_selectpline ( / cp_l1 cp_e1 cp_d1)

; set default output to nil (nothing selected yet) 
 (setq cp_l1 nil)

; user selects lightweight polyline - error if nothing selected
 (if (= (setq cp_e1 (entsel "Select a lightweight polyline")) nil)
  (princ "\nNo object selected. Command terminating")

; or error if object selected is not correct type
  (if (/= (cdr (assoc 0 (setq cp_d1 (entget (car cp_e1))))) "LWPOLYLINE")
   (princ "\nObject is not a lightweight polyline. Command terminating")

; otherwise parse source polyline
   (setq cp_l1 (parse_polyline cp_d1))
  )
 )

; set output list to itself, so that this is the output from this function
 (setq cp_l1 cp_l1)
)

; =======================================================================================================

; CHOFFSET_MATHS
; ==============

; Description:
; ============
; Calculates chainage and offset values for CHOFFSET and CHOFFSETS commands
; Inputs: list of lines and arcs, location for which to get information
; Output: list of coordinates (x,y), chainages, offsets and levels for each point
;         (list can be more than one item long)

; Internal Variables:
; ===================
; cm_l1 = source polyline parsed list
; cm_n1 = chainage at start of polyline - then running chainage
; cm_p1 = location for which to get information
; cm_c1 = count through cm_l1
; cm_x1, cm_y1 = coordinates of point cm_p1
; cm_l2 = output list of coordinates (x,y), chainage(s), offset(s) and level(s)
; cm_n2 = length of item cm_i1
; cm_i1 = item in list cm_l1
; cm_i2 = individual group of coordinates (x,y), chainage(s), offset(s) and level(s)
; cm_p2, cm_p3 = start and end points in cm_i1
; cm_x2, cm_y2 = coordinates at start of line
; cm_x3, cm_y3 = coordinates at end of line
; cm_f1 = fraction of distance between cm_p2 and cm_p3, then chainage of point cm_p1
; cm_n3 = chainage of point cm_p1
; cm_f2 = offset fraction from line to point cm_p1
; cm_p2 = centre of arc in cm_i1
; cm_a1 = angle from centre of arc to point cm_p1
; cm_a2, cm_a3 = start and end angles in cm_i1

(defun choffset_maths (cm_l1 cm_n1 cm_p1 / cm_c1 cm_x1 cm_y1 cm_l2 cm_n2 cm_i1 cm_i2 cm_p2 cm_p3 cm_x2
                                           cm_y2 cm_x3 cm_y3 cm_f1 cm_n3 cm_f2 cm_a1 cm_a2 cm_a3)

; initiate counter, and get coordinates of search location
 (setq cm_c1 0 cm_x1 (car cm_p1) cm_y1 (cadr cm_p1) cm_l2 nil)

; look at each line and arc in source polyline
 (repeat (length cm_l1)

; get length of line or arc and check if this item is line or arc. Also set empty of group for segment
  (setq cm_n2 (nth 3 (setq cm_i1 (nth cm_c1 cm_l1))) cm_i2 nil) 
  (if (= (car cm_i1) "LINE")

; maths for line segment
   (progn

; get points at each end of line segment, and x,y coordinates of each point
    (setq cm_p2 (nth 1 cm_i1) cm_p3 (nth 2 cm_i1))
    (setq cm_x2 (car cm_p2) cm_y2 (cadr cm_p2) cm_x3 (car cm_p3) cm_y3 (cadr cm_p3))

; calculate fraction along line for intersection with perpendicular line to search location
    (setq cm_f1 (/ (+ (* (- cm_x1 cm_x2) (- cm_x3 cm_x2)) (* (- cm_y1 cm_y2) (- cm_y3 cm_y2)))
                   (+ (* (- cm_x3 cm_x2) (- cm_x3 cm_x2)) (* (- cm_y3 cm_y2) (- cm_y3 cm_y2)))))

; if fraction is >=0 (for first segment) or >0 (for other segments) and <=1.0 (for all segments)
    (if (and (or (and (= cm_c1 0) (>= cm_f1 0.0)) (and (> cm_c1 0) (> cm_f1 0.0))) (<= cm_f1 1.0))
     (progn

; calculate chainage
      (setq cm_n3 (+ cm_n1 (* cm_n2 cm_f1)))

; calculate offset from line to search point (two options to avoid division by zero error)
      (if (/= cm_x3 cm_x2)
       (setq cm_f2 (* cm_n2 (/ (+ (- cm_y2 cm_y1) (* cm_f1 (- cm_y3 cm_y2))) (- cm_x3 cm_x2))))
       (if (/= cm_y3 cm_y2)
        (setq cm_f2 (* cm_n2 (/ (+ (- cm_x2 cm_x1) (* cm_f1 (- cm_x3 cm_x2))) (- cm_y2 cm_y3))))

; or nil="undefined" if unable to calculate offset (for example if line has zero length)
        (setq cm_f2 nil)
       )
      )

; create group of search point coordinates (x,y), chainage, offset and level
      (setq cm_i2 (list cm_x1 cm_y1 cm_n3 cm_f2 (caddr cm_p1))) 
     )
    )
   )

; maths for arc segment
   (progn

; get angles to search location (recreate cm_p1 with same z value as cm_p2) and start and end of arc
    (setq cm_a1 (angle (setq cm_p2 (nth 4 cm_i1)) (list cm_x1 cm_y1 (caddr cm_p2)))
          cm_a2 (nth 6 cm_i1) cm_a3 (nth 7 cm_i1))

; ensure search location angle will be within arc angle values greater than 360 degrees
    (if (< cm_a1 (min cm_a2 cm_a3))
     (setq cm_a1 (+ cm_a1 chainage_twopi))
    )

; if arc has range (i.e. avoid division by zero error) calculate fraction of way along arc
    (if (/= cm_a3 cm_a2)
     (progn
      (setq cm_f1 (/ (- cm_a1 cm_a2) (- cm_a3 cm_a2)))

; if fraction is >=0 (for first segment) or >0 (for other segments) and <=1.0 (for all segments)
      (if (and (or (and (= cm_c1 0) (>= cm_f1 0.0)) (and (> cm_c1 0) (> cm_f1 0.0))) (<= cm_f1 1.0))
       (progn

; calculate chainage
      (setq cm_n3 (+ cm_n1 (* cm_n2 cm_f1)))

; calculate offset from arc to search point (reverse sign if clockwise arc segment)
; (recreate cm_p1 using same z coordinates as cm_p2 so distance is in 2D plane)
        (setq cm_f2 (- (distance (list cm_x1 cm_y1 (caddr cm_p2)) cm_p2) (nth 5 cm_i1)))
        (if (> cm_a2 cm_a3)
         (setq cm_f2 (* cm_f2 -1.0))
        )

; create group of search point coordinates (x,y), chainage, offset and level
        (setq cm_i2 (list cm_x1 cm_y1 cm_n3 cm_f2 (caddr cm_p1))) 
       )
      )
     )
    )      
   )
  )

; if group of coordinates, chainage and offset exist, add them to output list
  (if (/= cm_i2 nil)
   (if (= cm_l2 nil)
    (setq cm_l2 (list cm_i2))
    (setq cm_l2 (append cm_l2 (list cm_i2)))
   )
  )

; update segment counter and running chainage
  (setq cm_c1 (1+ cm_c1) cm_n1 (+ cm_n1 (nth 3 cm_i1)))
 )

; set output list to itself, so that this is the output from this function
 (setq cm_l2 cm_l2)
)

; =======================================================================================================

; CHOFFSET_OUTPUT
; ===============

; Description:
; ============
; Displays list of coordinates, chainage(s), offset(s) and level(s) from CHOFFSET and CHOFFSETS commands
; Input: list of coordinates (x,y), chainages, offsets and levels for each point
;        (list can be more than one item long)
; Output: None

; Internal Variables:
; ===================
; co_l1 = input list of coordinates (x,y), chainage(s), offset(s) and level(s)
; co_c1 = count through co_l1
; co_i1 = item in list co_l1

(defun choffset_output (co_l1 / co_c1 co_i1)

; initiate count to zero
 (setq co_c1 0)

; message if empty list
 (if (= (length co_l1) 0)
  (princ "\nNo result")

; look at each group of data in list
  (repeat (length co_l1)

; get item in list
   (setq co_i1 (nth co_c1 co_l1))

; output data to screen, including "not calculated" if offset not available
   (princ (strcat "\nCoords. " (rtos (nth 0 co_i1) 2 3) "," (rtos (nth 1 co_i1) 2 3)
                  " ch. " (rtos (nth 2 co_i1) 2 3) " offset "))
   (if (= (nth 3 co_i1) nil)
    (princ " not calculated")
    (princ (rtos (nth 3 co_i1) 2 3))
   )
   (princ (strcat " level " (rtos (nth 4 co_i1) 2 3)))

; update counter in list
   (setq co_c1 (1+ co_c1))
  )
 )
)

; =======================================================================================================

; CHOFFSET_DRAWDATA
; =================

; Description:
; ============
; Draw coordinates, chainages and offsets as MTEXTs
; Input: list of groups of coordinates (x,y,z), chainage(s) and offset(s)
; Output: none

; Internal Variables:
; ===================
; cd_l1 = list of groups of coordinates (x,y), chainage(s), offset(s) and level(s)
; cd_z1 = value of DIMZIN at start of function
; cd_h1 = current text height
; cd_c1 = count through cd_l1
; cd_l2 = copy of list cd_l1 but with chainages and offsets rounded to 3 decimal places
; cd_i1 = item in list cd_l1 or cd_l2
; cd_v1 = item's chainage
; cd_v2 = item's offset
; cd_m1 = minimum chainage at start of comparison
; cd_m2 = minimum offset at start of comparison
; cd_m3 = maximum chainage
; cd_m4 = maximum offset
; cd_t1, cd_t2, cd_t3, cd_t4, cd_t5 = text for each MTEXT object
; cd_n1 = next comparison chainage
; cd_n2 = next comparison offset
; cd_p1 = point at which to draw MTEXT objects
; cd_x1 = horizontal offset between each MTEXT object

(defun choffset_drawdata (cd_l1 / cd_z1 cd_h1 cd_c1 cd_l2 cd_i1 cd_v1 cd_v2 cd_m1 cd_m2 cd_m3
                                  cd_m4 cd_t1 cd_t2 cd_t3 cd_t4 cd_t5 cd_n1 cd_n2 cd_p1 cd_x1)

; only continue if list contains data
 (if (> (length cd_l1) 0)
  (progn

; give user choice of whether to continue or not
   (initget 1 "yes no")
   (if (= (getkword "\nDraw data in MTEXT blocks? (Yes/No): ") "yes")
    (progn

; remember initial value of DIMZIN and get current text height
     (setq cd_z1 (getvar "DIMZIN") cd_h1 (getvar "TEXTSIZE"))

; create copy of list with chainages and offsets rounded to 3 decimal places
; (avoids offsets being listed in the wrong order when 10.500 not seen as equal to 10.500001)
     (setq cd_c1 0 cd_l2 nil)
     (repeat (length cd_l1)

; replace each item with copy of itself, with chainages and offsets rounded up/down to 3 d.p.
      (setq cd_i1 (nth cd_c1 cd_l1))
      (setq cd_i1 (list (nth 0 cd_i1) (nth 1 cd_i1) (atof (rtos (nth 2 cd_i1) 2 3))
                        (atof (rtos (nth 3 cd_i1) 2 3)) (nth 4 cd_i1)))

; add copy of item to new list
      (if (= cd_l2 nil)
       (setq cd_l2 (list cd_i1))
       (setq cd_l2 (append cd_l2 (list cd_i1)))
      )
      (setq cd_c1 (1+ cd_c1))
     )

; replace original list with new list
     (setq cd_l1 cd_l2)

; get minimum and maximum chainages and offsets (not necessarily from same items) in list
     (setq cd_c1 0)
     (repeat (length cd_l1)
      (setq cd_i1 (nth cd_c1 cd_l1))
      (setq cd_v1 (nth 2 cd_i1) cd_v2 (nth 3 cd_i1))

; store values if first item in list, otherwise compare to maintain minimum and maximum
      (if (= cd_c1 0)
       (setq cd_m1 cd_v1 cd_m2 cd_v2 cd_m3 cd_v1 cd_m4 cd_v2)
       (setq cd_m1 (min cd_m1 cd_v1) cd_m2 (min cd_m2 cd_v2)
             cd_m3 (max cd_m3 cd_v1) cd_m4 (max cd_m4 cd_v2))
      )
      (setq cd_c1 (1+ cd_c1))
     )

; create initial text for each MTEXT object
     (setq cd_t1 "{Easting\\P" cd_t2 "{Northing\\P" cd_t3 "{Chainage\\P" cd_t4 "{Offset\\P"
           cd_t5 "{Level\\P")

; keep going until no more item data is found - puts data ordered by chainage then offset into MTEXTs
     (while (<= cd_m1 cd_m3)

; set initial flags, and "next" comparison values to more than maximum values
      (setq cd_c1 0 cd_n1 (+ cd_m3 1.0) cd_n2 (+ cd_m4 1.0))

; loop through each item in data list, getting its chainage and offset
      (while (< cd_c1 (length cd_l1))
       (setq cd_i1 (nth cd_c1 cd_l1))
       (setq cd_v1 (nth 2 cd_i1) cd_v2 (nth 3 cd_i1))

; item's chainage matches current minimum chainage
       (if (= cd_v1 cd_m1)

; and item's offset also matches current minimum offset, add item's data to MTEXTs
        (if (= cd_v2 cd_m2)
         (progn

; set DIMZIN to zero so trailing and leading zeros are NOT truncated
          (setvar "DIMZIN" 0)
          (setq cd_t1 (strcat cd_t1 (rtos (nth 0 cd_i1) 2 3) "\\P")
                cd_t2 (strcat cd_t2 (rtos (nth 1 cd_i1) 2 3) "\\P")
                cd_t3 (strcat cd_t3 (rtos (nth 2 cd_i1) 2 3) "\\P")
                cd_t4 (strcat cd_t4 (rtos (nth 3 cd_i1) 2 3) "\\P")
                cd_t5 (strcat cd_t5 (rtos (nth 4 cd_i1) 2 3) "\\P"))

; restore initial value to DIMZIN
          (setvar "DIMZIN" cd_z1)
         )

; if item's chainage matches current min chainage, but offset is more than current min offset
         (if (> cd_v2 cd_m2)

; update next chainage and offset, if item's chainage is less than next, or equal and offset is less
          (if (or (< cd_v1 cd_n1) (and (= cd_v1 cd_n1) (< cd_v2 cd_n2)))
           (setq cd_n1 cd_v1 cd_n2 cd_v2)
          )
         )
        )

; otherwise if item's chainage is more than current minimum chainage
        (if (> cd_v1 cd_m1)

; update next chainage and offset, if item's chainage is less than next, or equal and offset is less
         (if (or (< cd_v1 cd_n1) (and (= cd_v1 cd_n1) (< cd_v2 cd_n2)))
          (setq cd_n1 cd_v1 cd_n2 cd_v2)
         )
        )
       )

; increase counter to look at next item in list cd_l1
       (setq cd_c1 (1+ cd_c1))
      )

; make new minimum chainage and offset equal next chainage and offset
      (setq cd_m1 cd_n1 cd_m2 cd_n2)
     )

; add "end formatting" to text for each MTEXT object
     (setq cd_t1 (strcat cd_t1 "}") cd_t2 (strcat cd_t2 "}") cd_t3 (strcat cd_t3 "}")
           cd_t4 (strcat cd_t4 "}") cd_t5 (strcat cd_t5 "}"))

; get location on screen where to draw MTEXT objects, and calculate separation between each MTEXT object
     (if (= (setq cd_p1 (getpoint "\nSelect insertion point for MTEXT objects: ")) nil)
      (princ "\nNo insertion point selected. Command terminating")
      (progn
       (setq cd_x1 (* cd_h1 10.0))

; draw data on screen
       (entmake (list (cons 0 "MTEXT") (cons 100 "AcDbEntity") (cons 100 "AcDbMText")
                      (append (list 10) cd_p1) (cons 40 cd_h1) (cons 1 cd_t1) (cons 71 3) (cons 73 2)))
       (setq cd_p1 (list (+ (car cd_p1) cd_x1) (cadr cd_p1) (caddr cd_p1)))
       (entmake (list (cons 0 "MTEXT") (cons 100 "AcDbEntity") (cons 100 "AcDbMText")
                      (append (list 10) cd_p1) (cons 40 cd_h1) (cons 1 cd_t2) (cons 71 3) (cons 73 2)))
       (setq cd_p1 (list (+ (car cd_p1) cd_x1) (cadr cd_p1) (caddr cd_p1)))
       (entmake (list (cons 0 "MTEXT") (cons 100 "AcDbEntity") (cons 100 "AcDbMText")
                      (append (list 10) cd_p1) (cons 40 cd_h1) (cons 1 cd_t3) (cons 71 3) (cons 73 2)))
       (setq cd_p1 (list (+ (car cd_p1) cd_x1) (cadr cd_p1) (caddr cd_p1)))
       (entmake (list (cons 0 "MTEXT") (cons 100 "AcDbEntity") (cons 100 "AcDbMText")
                      (append (list 10) cd_p1) (cons 40 cd_h1) (cons 1 cd_t4) (cons 71 3) (cons 73 2)))
       (setq cd_p1 (list (+ (car cd_p1) cd_x1) (cadr cd_p1) (caddr cd_p1)))
       (entmake (list (cons 0 "MTEXT") (cons 100 "AcDbEntity") (cons 100 "AcDbMText")
                      (append (list 10) cd_p1) (cons 40 cd_h1) (cons 1 cd_t5) (cons 71 3) (cons 73 2)))
      )
     )
    )
   )
  )
 )
)

; =======================================================================================================
;  OOOO O   O  OOO  OOOOO OOOOO  OOOO OOOOO OOOOO
; O     O   O O   O O     O     O     O       O
; O     OOOOO O   O OOOO  OOOO   OOO  OOOO    O
; O     O   O O   O O     O         O O       O
;  OOOO O   O  OOO  O     O     OOOO  OOOOO   O
; =======================================================================================================

; CHOFFSET
; ========

; Description:
; ============
; Return coordinates, chainage, offset and level of individually picked location(s) relative to source polyline

; Global Variables:
; =================
; chainage_chatstart = chainage value at start of polyline

; Internal Variables:
; ===================
; l1 = source polyline parsed list
; n1 = chainage value at start of polyline
; o2 = output list of all coordinates (x,y), chainage(s), offset(s) and level(s) for all location(s) selected
; p1 = location for which to get information
; l2 = list of coordinates (x,y), chainage(s), offset(s) and level(s) for each location selected

(defun C:CHOFFSET (/ l1 n1 o2 p1 l2)
 (chainage_atstart)

; get user to select lightweight polyline (nil if polyline not selected)
 (if (/= (setq l1 (chainage_selectpline)) nil)
  (progn

; get chainage value at start of polyline, setting it to global value (or zero) if no value entered
   (setq n1 (chainage_getglobalvalue "\nEnter chainage value at start of polyline"
             chainage_chatstart 0.0 nil))
   (setq chainage_chatstart n1)

; initialise output list as empty
   (setq o2 nil)

; keep looking for locations until user doesn't pick one
   (while (/= (setq p1 (getpoint "\nPick a location: ")) nil)

; output chainage and offset for location selected
    (choffset_output (setq l2 (choffset_maths l1 n1 p1)))

; add output to list of all locations selected
    (if (/= l2 nil)
     (if (= o2 nil)
      (setq o2 l2)
      (setq o2 (append o2 l2))
     )
    )
   )

; when user doesn't pick another location, ask if wants to draw data on screen in MTEXT blocks
   (choffset_drawdata o2)
   (princ "\nCommand finished")
  )
 )
 (chainage_atend)
 (princ)
)

; =======================================================================================================
;  OOOO O   O  OOO  OOOOO OOOOO  OOOO OOOOO OOOOO  OOOO
; O     O   O O   O O     O     O     O       O   O
; O     OOOOO O   O OOOO  OOOO   OOO  OOOO    O    OOO
; O     O   O O   O O     O         O O       O       O
;  OOOO O   O  OOO  O     O     OOOO  OOOOO   O   OOOO
; =======================================================================================================

; CHOFFSETS
; =========

; Description:
; ============
; Return coordinates, chainages, offsets and levels of selection of POINT objects relative to source polyline

; Global Variables:
; =================
; chainage_chatstart = chainage value at start of polyline

; Internal Variables:
; ===================
; l1 = source polyline parsed list
; n1 = chainage value at start of polyline
; s1 = selection set of point objects
; c1 = count through s1
; o2 = output list of all coordinates (x,y), chainage(s), offset(s) and level(s) for points in s1
; p1 = location of each point about which to get information
; l2 = list of coordinates (x,y), chainage(s), offset(s) and level(s) for each point p1

(defun C:CHOFFSETS (/ l1 n1 s1 c1 o2 p1 l2)
 (chainage_atstart)

; get user to select lightweight polyline (nil if polyline not selected)
 (if (/= (setq l1 (chainage_selectpline)) nil)
  (progn

; get chainage value at start of polyline, setting it to global value (or zero) if no value entered
   (setq n1 (chainage_getglobalvalue "\nEnter chainage value at start of polyline"
             chainage_chatstart 0.0 nil))
   (setq chainage_chatstart n1)

; select group of point objects
   (princ "\nSelect POINT objects... ")
   (if (= (setq s1 (ssget (list (cons 0 "POINT")))) nil)
    (princ "\nNo POINTs selected. Command terminating")
    (progn

; initiate counter and empty final output list
     (setq c1 0 o2 nil)

; look at each point in selection set
     (repeat (sslength s1)

; get coordinates of point and output chainage and offset for that point
      (setq p1 (cdr (assoc 10 (entget (ssname s1 c1)))))
      (choffset_output (setq l2 (choffset_maths l1 n1 p1)))

; if chainage and offset available, add them to final output list
      (if (/= l2 nil)
       (if (= o2 nil)
        (setq o2 l2)
        (setq o2 (append o2 l2))
       )
      )

; increase counter for next point in selection set
      (setq c1 (1+ c1))
     )

; discard selection set as no longer needed
     (setq s1 nil)

; ask if wants to draw data on screen in MTEXT blocks
     (choffset_drawdata o2)
     (princ "\nCommand finished")
    )
   )
  )
 )
 (chainage_atend)
 (princ)
)

; =======================================================================================================

; CHMARK_DRAW
; ===========

; Description:
; ============
; Draw chainage mark (or section) line and text (not for sections) at given chainage
; Inputs: polyline segments list, start chainage, requested chainage, chainage mark number style
; Output: None

; Internal Variables:
; ===================
; ck_l1 = source polyline parsed list
; ck_n1 = chainage at start of polyline
; ck_n2 = chainage where chainage mark is to be drawn
; ck_b1 = chainage mark number style (nil for CHXSECT and CHXSECTS)
; ck_s1 = chainage mark line length (bigger for CHXSECT and CHXSECTS)
; ck_c1 = count through ck_l1
; ck_n3 = chainage at start of segment
; ck_z1 = initial value of DIMZIN
; ck_h1 = current text height
; ck_i1 = item in ck_l1
; ck_n4 = length of segment
; ck_p1 = mid-point of chainage mark, then start point for text
; ck_a1 = angle along line or arc, then angle for chainage mark
; ck_t1 = text output
; ck_b2 = flag: T if text output is negative, nil if positive

(defun chmark_draw (ck_l1 ck_n1 ck_n2 ck_b1 ck_s1 / ck_c1 ck_n3 ck_z1 ck_h1 ck_i1 ck_n4 ck_p1 ck_a1 ck_t1 ck_b2)

; initiate counter and set chainage at start of segment to chainage at start of polyline
 (setq ck_c1 0 ck_n3 ck_n1)

; remember initial value of DIMZIN and get current text height
 (setq ck_z1 (getvar "DIMZIN") ck_h1 (getvar "TEXTSIZE"))

; keep looking until counter equals number of segments in polyline
 (while (< ck_c1 (length ck_l1))

; look at individual segment, and get its length
  (setq ck_i1 (nth ck_c1 ck_l1))
  (setq ck_n4 (nth 3 ck_i1))

; see if chainage mark chainage is within this segment
  (if (and (>= ck_n2 ck_n3) (<= ck_n2 (+ ck_n3 ck_n4)) (> ck_n4 0.0))
   (progn

; calculate position and angle of chainage mark along a line segment
    (if (= (car ck_i1) "LINE")
     (progn
      (setq ck_p1 (nth 1 ck_i1))
      (setq ck_a1 (angle ck_p1 (nth 2 ck_i1)))
      (setq ck_p1 (polar ck_p1 ck_a1 (- ck_n2 ck_n3)))
      (setq ck_a1 (+ ck_a1 chainage_halfpi))
     )

; calculate position and angle of chainage mark along an arc segment
     (progn
      (setq ck_a1 (+ (nth 6 ck_i1) (* (- (nth 7 ck_i1) (nth 6 ck_i1)) (/ (- ck_n2 ck_n3) ck_n4))))
      (setq ck_p1 (polar (nth 4 ck_i1) ck_a1 (nth 5 ck_i1)))
     )
    )

; draw chainage mark (or section line for CHXSECT and CHXSECTS)
    (entmake (list (cons 0 "LINE") (cons 100 "AcDbEntity") (cons 100 "AcDbLine")
                   (append (list 10) (polar ck_p1 ck_a1 ck_s1))
                   (append (list 11) (polar ck_p1 (+ ck_a1 chainage_pi) ck_s1))))

; if chainage mark number style exists, draw chainage text
    (if (/= ck_b1 nil)
     (progn

; set DIMZIN to zero so that trailing and leading zeros are NOT truncated by 'rtos'
      (setvar "DIMZIN" 0)

; simple n.nnn style
      (if (= ck_b1 1)
       (setq ck_t1 (rtos ck_n2 2 3))

; either n+nn or n+nn.nn styles
       (progn

; create initial text string without the + sign
        (if (= ck_b1 2)
         (setq ck_t1 (rtos ck_n2 2 0))
         (setq ck_t1 (rtos ck_n2 2 2))
        )

; set flag if output text string is negative, and strip - sign from start of string
        (if (= (substr ck_t1 1 1) "-")
         (setq ck_b2 T ck_t1 (substr ck_t1 2))
         (setq ck_b2 nil)
        )

; add preceeding zeros so 1 becomes 001, 23 becomes 023, 1.23 becomes 001.23 or 45.67 becomes 045.67
        (while (or (and (= ck_b1 2) (< (strlen ck_t1) 3)) (and (= ck_b1 3) (< (strlen ck_t1) 6)))
         (setq ck_t1 (strcat "0" ck_t1))
        )

; insert a + sign so 001 becomes 0+01, or 001.23 becomes 0+01.23
        (if (= ck_b1 2)
         (setq ck_t1 (strcat (substr ck_t1 1 (- (strlen ck_t1) 2)) "+" (substr ck_t1 (- (strlen ck_t1) 1))))
         (setq ck_t1 (strcat (substr ck_t1 1 (- (strlen ck_t1) 5)) "+" (substr ck_t1 (- (strlen ck_t1) 4))))
        )

; add preceeding - sign if output text is negative number
        (if (= ck_b2 T)
         (setq ck_t1 (strcat "-" ck_t1))
        )
       )
      )

; reset DIMZIN to initial value
      (setvar "DIMZIN" ck_z1)

; rotate text if between 90 and 270 degrees, by 180 degrees so text is always shown left-to-right or down-to-up
      (if (and (> ck_a1 chainage_halfpi) (< ck_a1 chainage_oneandahalfpi))
       (setq ck_a1 (+ ck_a1 chainage_pi))
      )

; move insertion point (1.75 determines the gap between mark and text) ready for drawing the text
      (setq ck_p1 (polar ck_p1 ck_a1 (* ck_s1 1.75)))

; insertion point is in (11 ..) and (10 ..) is bottom left corner of text (rotate 90 degrees and offset by half text height)
      (entmake (list (cons 0 "TEXT") (cons 100 "AcDbEntity") (cons 100 "AcDbText")
                     (append (list 10) (polar ck_p1 (- ck_a1 chainage_halfpi) (/ ck_h1 2.0)))
                     (cons 72 0) (cons 73 2) (append (list 11) ck_p1)
                     (cons 50 ck_a1) (cons 40 ck_h1) (cons 1 ck_t1)))
     )
    )

; set counter to equal number of segments in order to exit while lopp and exit this function
    (setq ck_c1 (length ck_l1))
   )

; if segment not found yet, increase counter to next segement and increase chainage to start of next segment
   (setq ck_c1 (1+ ck_c1) ck_n3 (+ ck_n3 ck_n4))
  )
 )
)

; =======================================================================================================
;  OOOO O   O O   O   O   OOOO  O   O
; O     O   O OO OO  O O  O   O O  O
; O     OOOOO O O O O   O OOOO  OOO
; O     O   O O   O OOOOO O   O O  O
;  OOOO O   O O   O O   O O   O O   O
; =======================================================================================================

; CHMARK
; ======

; Description:
; ============
; Draw chainage mark (e.g. "100.000 -") at selected location(s) on source polyline

; Global Variables:
; =================
; chainage_chatstart = chainage value at start of polyline
; chainage_markstyle = how to display chainage 1 = n.nnn 2 = n+nn 3 = n+nn.nn

; Internal Variables:
; ===================
; l1 = source polyline parsed list
; n1 = chainage value at start of polyline
; n2 = chainage mark line length
; s1 = chainage mark number style
; p1 = location on polyline for chainage mark
; c1 = count through list l2
; l2 = list of chainages and offsets for point p1
; i1 = item in list l2

(defun C:CHMARK (/ l1 n1 n2 s1 p1 c1 l2 i1)
 (chainage_atstart)

; get user to select lightweight polyline (nil if polyline not selected)
 (if (/= (setq l1 (chainage_selectpline)) nil)
  (progn

; get chainage value at start of polyline, setting it to global value (or zero) if no value entered
   (setq n1 (chainage_getglobalvalue "\nEnter chainage value at start of polyline"
             chainage_chatstart 0.0 nil))
   (setq chainage_chatstart n1)

; set chainage mark line length
   (setq n2 (getvar "TEXTSIZE"))

; get chainage mark number style
   (setq s1 (chainage_getglobalvalue "\nEnter chainage mark style (1=n.nnn 2=n+nn 3=n+nn.nn)"
             chainage_markstyle 1 T))
   (if (or (< s1 1) (> s1 3))
    (setq s1 1)
   )
   (setq chainage_markstyle s1)

; keep looking for locations until user doesn't pick one
   (while (/= (setq p1 (getpoint "\nPick a location on polyline: ")) nil)

; get list of chainage(s) and offset(s) for location on polyline
    (setq c1 0)
    (if (/= (setq l2 (choffset_maths l1 n1 p1)) nil)

; go through list
     (repeat (length l2)
      (setq i1 (nth c1 l2))

; draw chainage mark for location selected if offset is at or nearly zero (i.e. location is on polyline)
      (if (and (< (nth 3 i1) 0.001) (> (nth 3 i1) -0.001))
       (chmark_draw l1 n1 (nth 2 i1) s1 n2)
      )

; increase coiunter to look at next chainage/offset pair in list
      (setq c1 (1+ c1))
     )
    )
   )
   (princ "\nCommand finished")
  )
 )
 (chainage_atend)
 (princ)
)

; =======================================================================================================
;  OOOO O   O O   O   O   OOOO  O   O  OOOO
; O     O   O OO OO  O O  O   O O  O  O
; O     OOOOO O O O O   O OOOO  OOO    OOO
; O     O   O O   O OOOOO O   O O  O      O
;  OOOO O   O O   O O   O O   O O   O OOOO
; =======================================================================================================

; CHMARKS
; =======

; Description:
; ============
; Draw chainage marks (e.g. "100.000 -") at regular intervals along source polyline

; Global Variables:
; =================
; chainage_chatstart = chainage value at start of polyline
; chainage_reginterval = regular interval between chainage marks
; chainage_markstyle = how to display chainage 1 = n.nnn 2 = n+nn 3 = n+nn.nn

; Internal Variables:
; ===================
; l1 = source polyline parsed list
; n1 = chainage value at start of polyline
; n2 = chainage mark line length
; r1 = regular interval between chainage marks
; s1 = chainage mark number style
; n3 = chainage of initial and then current chainage mark
; n4 = chainage at end of polyline

(defun C:CHMARKS (/ l1 n1 n2 r1 s1 n3 n4)
 (chainage_atstart)

; get user to select lightweight polyline (nil if polyline not selected)
 (if (/= (setq l1 (chainage_selectpline)) nil)
  (progn

; get chainage value at start of polyline, setting it to global value (or zero) if no value entered
   (setq n1 (chainage_getglobalvalue "\nEnter chainage value at start of polyline"
             chainage_chatstart 0.0 nil))
   (setq chainage_chatstart n1)

; set chainage mark line length
   (setq n2 (getvar "TEXTSIZE"))

; get regular interval between chainage marks (ensure it's not less than 1.0)
   (setq r1 (chainage_getglobalvalue "\nEnter interval between chainage marks (min. interval of 1.0)"
             chainage_reginterval 10.0 nil))
   (if (< r1 1.0)
    (setq r1 1.0)
   )
   (setq chainage_reginterval r1)

; get chainage mark number style
   (setq s1 (chainage_getglobalvalue "\nEnter chainage mark style (1=n.nnn 2=n+nn 3=n+nn.nn)"
             chainage_markstyle 1 T))
   (if (or (< s1 1) (> s1 3))
    (setq s1 1)
   )
   (setq chainage_markstyle s1)

; calculate start chainage to next regular interval after start of polyline
   (setq n3 (- n1 (rem n1 r1)))
   (if (< n3 n1)
    (setq n3 (+ n3 r1))
   )

; get overall length of polyline
   (setq n4 (+ n1 (parse_polyline_getlen l1)))

; keep looking until past end of polyline
   (while (<= n3 n4)

; draw chainage mark
    (chmark_draw l1 n1 n3 s1 n2)

; increase chainage by regular interval
    (setq n3 (+ n3 r1))
   )
   (princ "\nCommand finished")
  )
 )
 (chainage_atend)
 (princ)
)

; =======================================================================================================
;  OOOO O   O O   O  OOOO OOOOO  OOOO OOOOO
; O     O   O  O O  O     O     O       O
; O     OOOOO   O    OOO  OOOO  O       O
; O     O   O  O O      O O     O       O
;  OOOO O   O O   O OOOO  OOOOO  OOOO   O
; =======================================================================================================

; CHXSECT
; =======

; Description:
; ============
; Draw section line at selected location(s) on source polyline

; Global Variables:
; =================
; chainage_sectlinelen = length of section line(s)

; Internal Variables:
; ===================
; l1 = source polyline parsed list
; n1 = overall section line length
; p1 = location on polyline for chainage mark
; c1 = count through list l2
; l2 = list of chainages and offsets for point p1
; i1 = item in list l2

(defun C:CHXSECT (/ l1 n1 p1 c1 l2 i1)
 (chainage_atstart)

; get user to select lightweight polyline (nil if polyline not selected)
 (if (/= (setq l1 (chainage_selectpline)) nil)
  (progn

; get section line length (divide result by 2 because chmark_draw draws this length either side of polyline)
   (setq n1 (chainage_getglobalvalue "\nEnter section line length (min. length of 1.0)"
             chainage_sectlinelen 20.0 nil))
   (if (< n1 1.0)
    (setq n1 1.0)
   )
   (setq chainage_sectlinelen n1)
   (setq n1 (/ n1 2.0))

; keep looking for locations until user doesn't pick one
   (while (/= (setq p1 (getpoint "\nPick a location on polyline: ")) nil)

; get list of chainage(s) and offset(s) for location on polyline
; (don't need to know actual start chainage, so can assume it's 0.0)
    (setq c1 0)
    (if (/= (setq l2 (choffset_maths l1 0.0 p1)) nil)

; go through list
     (repeat (length l2)
      (setq i1 (nth c1 l2))

; draw section line for location selected if offset is at or nearly zero (i.e. location is on polyline)
      (if (and (< (nth 3 i1) 0.001) (> (nth 3 i1) -0.001))
       (chmark_draw l1 0.0 (nth 2 i1) nil n1)
      ) 

; increase coiunter to look at next chainage/offset pair in list
      (setq c1 (1+ c1))
     )
    )
   )
   (princ "\nCommand finished")
  )
 )
 (chainage_atend)
 (princ)
)

; =======================================================================================================
;  OOOO O   O O   O  OOOO OOOOO  OOOO OOOOO  OOOO
; O     O   O  O O  O     O     O       O   O
; O     OOOOO   O    OOO  OOOO  O       O    OOO
; O     O   O  O O      O O     O       O       O
;  OOOO O   O O   O OOOO  OOOOO  OOOO   O   OOOO
; =======================================================================================================

; CHXSECTS
; ========

; Description:
; ============
; Draw section lines at regular intervals along source polyline

; Global Variables:
; =================
; chainage_chatstart = chainage value at start of polyline
; chainage_reginterval = regular interval between chainage marks
; chainage_sectlinelen = length of section line(s)

; Internal Variables:
; ===================
; l1 = source polyline parsed list
; n1 = chainage value at start of polyline
; r1 = regular interval between chainage marks
; n2 = section line length
; n3 = chainage of initial and then current chainage mark
; n4 = chainage at end of polyline

(defun C:CHXSECTS (/ l1 n1 r1 n2 n3 n4)
 (chainage_atstart)

; get user to select lightweight polyline (nil if polyline not selected)
 (if (/= (setq l1 (chainage_selectpline)) nil)
  (progn

; get chainage value at start of polyline, setting it to global value (or zero) if no value entered
   (setq n1 (chainage_getglobalvalue "\nEnter chainage value at start of polyline"
             chainage_chatstart 0.0 nil))
   (setq chainage_chatstart n1)

; get regular interval between chainage marks (ensure it's not less than 1.0)
   (setq r1 (chainage_getglobalvalue "\nEnter interval between chainage marks (min. interval of 1.0)"
             chainage_reginterval 10.0 nil))
   (if (< r1 1.0)
    (setq r1 1.0)
   )
   (setq chainage_reginterval r1)

; get section line length (divide result by 2 because chmark_draw draws this length either side of polyline)
   (setq n2 (chainage_getglobalvalue "\nEnter section line length (min. length of 1.0)"
             chainage_sectlinelen 20.0 nil))
   (if (< n2 1.0)
    (setq n2 1.0)
   )
   (setq chainage_sectlinelen n2)
   (setq n2 (/ n2 2.0))

; calculate start chainage to next regular interval after start of polyline
   (setq n3 (- n1 (rem n1 r1)))
   (if (< n3 n1)
    (setq n3 (+ n3 r1))
   )

; get overall length of polyline
   (setq n4 (+ n1 (parse_polyline_getlen l1)))

; keep looking until past end of polyline
   (while (<= n3 n4)

; draw chainage mark
    (chmark_draw l1 n1 n3 nil n2)

; increase chainage by regular interval
    (setq n3 (+ n3 r1))
   )
   (princ "\nCommand finished")
  )
 )
 (chainage_atend)
 (princ)
)

; =======================================================================================================
;  OOOO O   O   O   O   O  OOOO OOOOO O   O OOOOO
; O     O   O  O O  OO  O O     O     OO  O   O
; O     OOOOO O   O O O O O  OO OOOO  O O O   O
; O     O   O OOOOO O  OO O   O O     O  OO   O
;  OOOO O   O O   O O   O  OOO  OOOOO O   O   O
; =======================================================================================================

; CHANGENT
; ========

; Description:
; ============
; Draw tangent marks where segments join (but not at start or end of polyline)

; Internal Variables:
; ===================
; l1 = source polyline parsed list
; c1 = count through list l1
; n1 = size of tangent mark
; i1 = item in list l1
; a1 = angle at end of segment
; a2 = angle at start of next segment
; p1 = position of tangent mark on polyline

(defun C:CHANGENT ( / l1 c1 n1 i1 a1 a2 p1)
 (chainage_atstart)

; get user to select lightweight polyline (nil if polyline not selected)
 (if (/= (setq l1 (chainage_selectpline)) nil)
  (progn

; initiate counter and set size of tangent mark (3/4 text size) so chainage mark can extend into tangent mark circles
   (setq c1 0 n1 (* (getvar "TEXTSIZE") 0.75))

; go through each segment in polyline
   (repeat (length l1)

; get individual segment
    (setq i1 (nth c1 l1))

; don't draw start of first segment
    (if (> c1 0)
     (progn

; calculate angle for line segment
      (if (= (car i1) "LINE")
       (setq a2 (+ (angle (nth 1 i1) (nth 2 i1)) chainage_halfpi))

; calculate angle at start of arc segment, rotating it 180 degrees if anti-clockwise segment
       (progn
        (setq a2 (nth 6 i1))
        (if (< a2 (nth 7 i1))
         (setq a2 (+ a2 chainage_pi))
        )
       )
      )

; take average of angle at end of previous segment and at start of this segment, and get point on polyline
      (setq a1 (/ (+ a1 a2) 2.0) p1 (nth 1 i1))

; draw tangent mark (a line with a circle at each end)
      (entmake (list (cons 0 "LINE") (cons 100 "AcDbEntity") (cons 100 "AcDbLine")
                     (append (list 10) (polar p1 a1 n1))
                     (append (list 11) (polar p1 (+ a1 chainage_pi) n1))))
      (entmake (list (cons 0 "CIRCLE") (cons 100 "AcDbEntity") (cons 100 "AcDbCircle")
                     (append (list 10) (polar p1 a1 (* n1 1.35)))
                     (cons 40 (* n1 0.35))))
      (entmake (list (cons 0 "CIRCLE") (cons 100 "AcDbEntity") (cons 100 "AcDbCircle")
                     (append (list 10) (polar p1 (+ a1 chainage_pi) (* n1 1.35)))
                     (cons 40 (* n1 0.35))))
     )
    )

; calculate angle at end of this line segment (including if first segment in list)
    (if (= (car i1) "LINE")
     (setq a1 (+ (angle (nth 1 i1) (nth 2 i1)) chainage_halfpi))

; calculate angle at end of this arc segment (including if first segment in list) and rotate if anti-clockwise
     (progn
      (setq a1 (nth 7 i1))
      (if (< (nth 6 i1) a1)
       (setq a1 (+ a1 chainage_pi))
      )
     )
    )

; increase counter to look at next segment (which will use a1 just calculated)
    (setq c1 (1+ c1))
   )
   (princ "\nCommand finished")
  )
 )
 (chainage_atend)
 (princ)
)

; =======================================================================================================

; CHAINAGE_MAKE2DPOINT
; ====================

; Description:
; ============
; Returns a 2D point if input is a 2D or 3D point

; Internal Variables:
; ===================
; mp_p1 = input and output: 2D or 3D point

(defun chainage_make2dpoint (mp_p1 / )

; if input point is 3D, create new 2D point from input's x and y coordinates
 (if (= (length mp_p1) 3)
  (setq mp_p1 (list (car mp_p1) (cadr mp_p1)))
 )

; set point to itself, so point is output from this function
 (setq mp_p1 mp_p1)
)

; =======================================================================================================
;  OOOO O   O OOOOO  OOOO O   O OOOOO O   O OOOOO
; O     O   O O     O     OO OO O     OO  O   O
; O     OOOOO OOOO  O  OO O O O OOOO  O O O   O
; O     O   O O     O   O O   O O     O  OO   O
;  OOOO O   O OOOOO  OOO  O   O OOOOO O   O   O
; =======================================================================================================

; CHEGMENT
; ========

; Description:
; ============
; Draw "ST" next to straight segments and "Rnn.nnn" next to arc segments along polyline

; Global Variables:
; =================
; chainage_radstyle = how to display radius 1 = value on polyline, 2 = value on line from centre to segment mid-point

; Internal Variables:
; ===================
; l1 = source polyline parsed list
; s1 = how to display radius style (as chainage_radstyle)
; c1 = count through list l1
; n1 = text height
; z1 = initial value of DIMZIN 
; i1 = item in list l1
; p1, p2 = positions at each end of line segment
; a1 = angle mid-way along segment
; t1 = text output
; r1 = arc radius
; p2 = centre point of arc
; p1 = position of text mid-way along segment (or mid-way along line from arc centre to mid-way along segment)
; p3 = point defining width and height of text bounding box

(defun C:CHEGMENT ( / l1 s1 c1 n1 z1 i1 p1 p2 a1 t1 r1 p3)
 (chainage_atstart)

; get user to select lightweight polyline (nil if polyline not selected)
 (if (/= (setq l1 (chainage_selectpline)) nil)
  (progn

; get chainage mark number style
   (setq s1 (chainage_getglobalvalue "\nEnter how to display radius (1=on arc, 2=on line from arc centre)"
             chainage_radstyle 1 T))
   (if (or (< s1 1) (> s1 2))
    (setq s1 1)
   )
   (setq chainage_radstyle s1)

; initiate counter, get text height and get initial DIMZIN value
   (setq c1 0 n1 (getvar "TEXTSIZE") z1 (getvar "DIMZIN"))

; go through each segment in polyline
   (repeat (length l1)

; get individual segment
    (setq i1 (nth c1 l1))

; calculate angle and text location for line segment
    (if (= (car i1) "LINE")
     (progn
      (setq p1 (nth 1 i1) p2 (nth 2 i1))
      (setq a1 (angle p1 p2))
      (setq p1 (list (/ (+ (car p1) (car p2)) 2.0) (/ (+ (cadr p1) (cadr p2)) 2.0) (caddr p1)))
      (setq t1 "ST")
     )

; calculate angle, get arc radius, and calculate text location for arc segment
     (progn
      (setq a1 (/ (+ (nth 6 i1) (nth 7 i1)) 2.0) r1 (nth 5 i1) p2 (nth 4 i1))
      (setq p1 (polar p2 a1 r1))

; if radius text on arc segment, rotate it by 90 degrees
      (if (= s1 1)
       (setq a1 (+ a1 chainage_halfpi))

; if radius text mid way between arc centre and arc segment...
       (progn

; if radius line is short, just draw a line 
        (if (< (distance p1 p2) (* n1 2.0))
         (entmake (list (cons 0 "LINE") (cons 100 "AcDbEntity") (cons 100 "AcDbLine")
                        (append (list 10) p2) (append (list 11) p1)))

; otherwise draw a lwpolyline with arrow head (easier than trying to draw a LEADER)
         (entmake (list (cons 0 "LWPOLYLINE") (cons 100 "AcDbEntity") (cons 100 "AcDbPolyline")
                        (cons 90 3) (cons 70 0) (cons 38 0.0)
                        (append (list 10) (chainage_make2dpoint p2))
                        (cons 40 0.0) (cons 41 0.0) (cons 42 0.0) (cons 91 0)
                        (append (list 10) (chainage_make2dpoint (polar p2 a1 (- r1 n1))))
                        (cons 40 (/ n1 3.0)) (cons 41 0.0) (cons 42 0.0) (cons 91 0)
                        (append (list 10) (chainage_make2dpoint p1))
                        (cons 40 0.0) (cons 41 0.0) (cons 42 0.0) (cons 91 0)))
        )

; calculate text location mid-way along line/polyline
        (setq p1 (polar p2 a1 (/ r1 2.0)))
       )
      )

; create radius text string
      (setvar "DIMZIN" 0)
      (setq t1 (strcat "R=" (rtos r1 2 3)))
      (setvar "DIMZIN" z1)
     )
    )

; rotate text if between 90 and 270 degrees, by 180 degrees so text is always shown left-to-right or down-to-up
    (if (and (> a1 chainage_halfpi) (< a1 chainage_oneandahalfpi))
     (setq a1 (+ a1 chainage_pi))
    )

; offset text so it's not over the polyline (or arc radius line)
    (setq p1 (polar p1 (+ a1 chainage_halfpi) n1))

; get point defining width and height of text bounding box (text to be drawn as middle-centre alignent)
    (setq p3 (cadr (textbox (list (cons 40 n1) (cons 1 t1)))))

; draw text (11 ..) is insertion point, (10 ..) is bottom left corner of text (rotated by angle a1)
    (entmake (list (cons 0 "TEXT") (cons 100 "AcDbEntity") (cons 100 "AcDbText")
                   (append (list 10) (polar p1 (+ a1 (angle p3 (list 0.0 0.0 0.0)))
                                               (/ (distance p3 (list 0.0 0.0 0.0)) 2.0)))
                   (cons 72 1) (cons 73 2) (append (list 11) p1)
                   (cons 50 a1) (cons 40 n1) (cons 1 t1)))

; increase counter to look at next segment
    (setq c1 (1+ c1))
   )
   (princ "\nCommand finished")
  )
 )
 (chainage_atend)
 (princ)
)

; =======================================================================================================
;  OOOO O   O  OOOO OOOOO OOOOO  OOO  O   O OOOOO
; O     O   O O     O       O   O   O O   O   O
; O     OOOOO  OOO  OOOO    O   O   O O   O   O
; O     O   O     O O       O   O   O O   O   O
;  OOOO O   O OOOO  OOOOO   O    OOO   OOO    O
; =======================================================================================================

; CHSETOUT
; ========

; Description:
; ============
; Create set-out table of polyline, listing start, end, tangent, and arc-centre points, and regular chainage points

; Global Variables:
; =================
; chainage_chatstart = chainage value at start of polyline
; chainage_reginterval = regular interval between chainage points

; Internal Variables:
; ===================
; l1 = source polyline parsed list
; n1 = chainage value at start of polyline
; r1 = regular interval between chainage marks
; c1 = count through list l1
; n2 = current chainage
; l2 = list of SP, TP, CP and EP points
; i1 = item in list l1
; r2 = current regular chainage
; l3 = list of points at regular chainage
; n3 = chainage at end of segment
; p1 = polar start point
; p2 = polar angle
; p3 = polar length
; i2 = output item for adding to l3
; z1 = initial value of DIMZIN
; h1 = current text height
; t1, t2, t3, t4, t5 = columns of text containing setting-out information
; c1, c2 = count through lists l2 and l3
; i1, i2 = items in lists l2 and l3
; p1 = position of MTEXT objects
; x1 = horizontal offset between each MTEXT object

(defun C:CHSETOUT ( / l1 n1 r1 c1 n2 l2 i1 r2 l3 n3 p1 p2 p3 i2 z1 h1 t1 t2 t3 t4 t5 c2 x1)
 (chainage_atstart)

; get user to select lightweight polyline (nil if polyline not selected)
 (if (/= (setq l1 (chainage_selectpline)) nil)
  (progn

; get chainage value at start of polyline, setting it to global value (or zero) if no value entered
   (setq n1 (chainage_getglobalvalue "\nEnter chainage value at start of polyline"
             chainage_chatstart 0.0 nil))
   (setq chainage_chatstart n1)

; get regular interval between chainage marks (ensure it's not less than 1.0)
   (setq r1 (chainage_getglobalvalue "\nEnter interval between regular chainage points (min. interval of 1.0)"
             chainage_reginterval 10.0 nil))
   (if (< r1 1.0)
    (setq r1 1.0)
   )
   (setq chainage_reginterval r1)

; initiate counter, set current chainage to chainage at start of polyline, and set empty output list
   (setq c1 0 n2 n1 l2 nil)

; go through each segment in polyline
   (repeat (length l1)

; get individual segment
    (setq i1 (nth c1 l1))

; if looking at first segment, add "start point" to output list, otherwise add "tangent point"
; (atof/rtos to chainage n2 to round number to 3 d.p so e.g. 10.500 and 10.500001 are treated as equal)
    (if (= c1 0)
     (setq l2 (list (list "SP" (atof (rtos n2 2 3)) (nth 1 i1))))
     (setq l2 (append l2 (list (list "TP" (atof (rtos n2 2 3)) (nth 1 i1)))))
    )

; if element is an arc add "centre point" element to list (chainage rounded to 3 d.p.)
    (if (= (car i1) "ARC")
     (setq l2 (append l2 (list (list "CP" (+ (atof (rtos n2 2 3)) (/ (nth 3 i1) 2.0))
                                          (nth 4 i1) (nth 5 i1)))))
    )

; increase counter to look at next segment and chainage to start of next segment
    (setq c1 (1+ c1) n2 (+ n2 (nth 3 i1)))
   )

; if reached end of polyline (and output list exists) add "end point" element (chainage rounded to 3 d.p.)
   (if (/= l2 nil)
    (setq l2 (append l2 (list (list "EP" (atof (rtos n2 2 3)) (nth 2 i1)))))
   )

; re-initiate counter, reset chainage to start and rounded to regular chainage, and set empty output list
   (setq c1 0 n2 n1 r2 (- n1 (rem n1 r1)) l3 nil)

; go through each segment in polyline
   (repeat (length l1)

; get individual segment
    (setq i1 (nth c1 l1))

; increase regular chainage if value is lower than chainage at start of this segment
    (while (< r2 n2)
     (setq r2 (+ r2 r1))
    )

; get chainage to end of this segment
    (setq n3 (+ n2 (nth 3 i1)))

; add points on this segment at regular chainage to out list
    (while (<= r2 n3)

; calculate point along line to add to output list
     (if (= (car i1) "LINE")
      (setq p1 (nth 1 i1)                     ; start of line
            p2 (angle (nth 1 i1) (nth 2 i1))  ; angle of line
            p3 (- r2 n2))                     ; distance along line

; calculate point along arc to add to output list
      (setq p1 (nth 4 i1)                     ; centre of arc
                                              ; angle along arc:
                                              ; [start ang + (end ang - start ang) * dist / circumf]
            p2 (+ (nth 6 i1) (* (- (nth 7 i1) (nth 6 i1)) (/ (- r2 n2) (nth 3 i1))))
            p3 (nth 5 i1))                    ; arc radius
     )

; create item and add it to output list (atof/rtos round chainage to 3 decimal places)
     (setq i2 (list (atof (rtos r2 2 3)) (polar p1 p2 p3)))
     (if (= l3 nil)
      (setq l3 (list i2))
      (setq l3 (append l3 (list i2)))
     )

; increase regular chainage until past end of this segment
     (setq r2 (+ r2 r1))
    )

; increase counter to look at next segment and chainage to start of next segment
    (setq c1 (1+ c1) n2 n3)
   )

; get initial value of DIMZIN and get current text height
   (setq z1 (getvar "DIMZIN") h1 (getvar "TEXTSIZE"))

; create initial text for each MTEXT object
   (setq t1 "{Point\\P" t2 "{Chainage\\P" t3 "{Easting\\P" t4 "{Northing\\P" t5 "{Radius\\P")

; initialise counters through lists l2 and l3
   (setq c1 0 c2 0 n2 n1)

; look through each element of list l2 (which contains overall first element (SP) and last element (EP))
   (while (< c1 (length l2))
    (setq i1 (nth c1 l2))

; get next element in list l3 (or if at end of list, create an element that skips next while loop)
    (if (< c2 (length l3))
     (setq i2 (nth c2 l3))
     (setq i2 (list (+ (nth 1 i1) 1.0)))
    )

; set DIMZIN to zero (so e.g. .5 appears as 0.500)
    (setvar "DIMZIN" 0)

; keep looking through list l3 until element in list l3 has chainage above element from list l2
    (while (<= (nth 0 i2) (nth 1 i1))

; if i2 has chainage below (or equal (+/- a bit) if element i1 is a centre-point CP) add element's detail to output text
     (if (or (< (nth 0 i2) (nth 1 i1)) (and (= (nth 0 i2) (nth 1 i1)) (= (car i1) "CP")))
      (setq t1 (strcat t1 "\\P")
            t2 (strcat t2 (rtos (nth 0 i2) 2 3) "\\P")
            t3 (strcat t3 (rtos (car (nth 1 i2)) 2 3) "\\P")
            t4 (strcat t4 (rtos (cadr (nth 1 i2)) 2 3) "\\P")
            t5 (strcat t5 "\\P"))
     )

; increase counter in list l3, and get next element (or create element as before to exit current while loop)
     (setq c2 (1+ c2))
     (if (< c2 (length l3))
      (setq i2 (nth c2 l3))
      (setq i2 (list (+ (nth 1 i1) 1.0)))
     )
    )

; add details for element from list l2 to output text (add point type to t1)
    (setq t1 (strcat t1 (car i1) "\\P"))

; centre-point details - don't add chainage to t2, but do add radius to t5
    (if (= (car i1) "CP")
     (setq t2 (strcat t2 "\\P") t5 (strcat t5 (rtos (nth 3 i1) 2 3) "\\P"))

; start, tangent and end points - add chainage to t2, but no radius to add to t5
     (setq t2 (strcat t2 (rtos (nth 1 i1) 2 3) "\\P") t5 (strcat t5 "\\P"))
    )

; add easting and northing coordinates to t3 and t4
    (setq t3 (strcat t3 (rtos (car (nth 2 i1)) 2 3) "\\P")
          t4 (strcat t4 (rtos (cadr (nth 2 i1)) 2 3) "\\P"))

; restore initial value to DIMZIN
    (setvar "DIMZIN" z1)

; increase counter in list l2
    (setq c1 (1+ c1))
   )

; add "end formatting" to text for each MTEXT object
   (setq t1 (strcat t1 "}") t2 (strcat t2 "}") t3 (strcat t3 "}") t4 (strcat t4 "}") t5 (strcat t5 "}"))

; get location on screen where to draw MTEXT objects, and calculate separation between each MTEXT object
   (if (= (setq p1 (getpoint "\nSelect insertion point for MTEXT objects: ")) nil)
    (princ "\nNo insertion point selected. Command terminating")
    (progn
     (setq x1 (* h1 10.0))

; draw data on screen
     (entmake (list (cons 0 "MTEXT") (cons 100 "AcDbEntity") (cons 100 "AcDbMText")
                    (append (list 10) p1) (cons 40 h1) (cons 1 t1) (cons 71 3) (cons 73 2)))
     (setq p1 (list (+ (car p1) x1) (cadr p1) (caddr p1)))
     (entmake (list (cons 0 "MTEXT") (cons 100 "AcDbEntity") (cons 100 "AcDbMText")
                    (append (list 10) p1) (cons 40 h1) (cons 1 t2) (cons 71 3) (cons 73 2)))
     (setq p1 (list (+ (car p1) x1) (cadr p1) (caddr p1)))
     (entmake (list (cons 0 "MTEXT") (cons 100 "AcDbEntity") (cons 100 "AcDbMText")
                    (append (list 10) p1) (cons 40 h1) (cons 1 t3) (cons 71 3) (cons 73 2)))
     (setq p1 (list (+ (car p1) x1) (cadr p1) (caddr p1)))
     (entmake (list (cons 0 "MTEXT") (cons 100 "AcDbEntity") (cons 100 "AcDbMText")
                    (append (list 10) p1) (cons 40 h1) (cons 1 t4) (cons 71 3) (cons 73 2)))
     (setq p1 (list (+ (car p1) x1) (cadr p1) (caddr p1)))
     (entmake (list (cons 0 "MTEXT") (cons 100 "AcDbEntity") (cons 100 "AcDbMText")
                    (append (list 10) p1) (cons 40 h1) (cons 1 t5) (cons 71 3) (cons 73 2)))
    )
   )
   (princ "\nCommand finished")
  )
 )
 (chainage_atend)
 (princ)
)

; =======================================================================================================
; Set PI variables used by various routines in CHAINAGE.lsp
(setq chainage_pi            3.1415926535897932384626433832795
      chainage_halfpi        1.5707963267948966192313216916398
      chainage_twopi         6.2831853071795864769252867665590
      chainage_oneandahalfpi 4.7123889803846898576939650749193)

; =======================================================================================================
; Output to screen when this lisp file is uploaded:

(princ "\nCHAINAGE.lsp loaded (Version 1.05 GD 21-Jul-2015) including the following commands:")
(princ "\n CHOFFSET - returns coordinates, chainage and offset of point relative to polyline")
(princ "\n CHOFFSETS - returns coordinates, chainages and offsets for selection of points relative to polyline")
(princ "\n CHMARK - draws chainage marks at selected points along a polyline")
(princ "\n CHMARKS - draws chainage marks at regular chainages along a polyline")
(princ "\n CHANGENT - draws tangent marks at ends of polyline lines and arcs")
(princ "\n CHEGMENT - draws ST and radius values alongside polyline lines and arcs")
(princ "\n CHXSECT - draws section lines at selected points at right angles to polyline")
(princ "\n CHXSECTS - draws section lines at regular chainages along a polyline")
(princ "\n CHSETOUT - returns a polyline's setting out information (chainages, coordinates, radii etc.)")
(princ)

; =======================================================================================================
; Revision information:
; 1.01 - spelling mistake in "output to screen" section corrected
; 1.01 - CHAINAGE_GETGLOBALVAL updated to handle both integers and real (i.e. floating point) numbers
; 1.01 - Level MTEXT column added to CHOFFSET and CHOFFSETS supporting functions
; 1.01 - sorting algorithm re-written in CHOFFSET_DRAWDATA to cope with identical points
; 1.01 - comparison of lists algorithm re-written in CHSETOUT
; 1.02 - PI numerical-typed values replaced with chainage_... variables
; 1.02 - 'LIST' in parse_polyline description text changed to 'LINE'
; 1.02 - parse_polyline add z coordinate if LWPOLYLINE points pp_p1 or pp_p2 are 2D (for AutoCAD LWPOLYLINEs)
; 1.03 - text height included in entmake when drawing MTEXT in CHOFFSET_DRAWDATA (required for AutoCAD)
; 1.03 - text height included in entmake when drawing single line text in CHMARK_DRAW (required for AutoCAD)
; 1.03 - text height included in entmake when drawing single line text in CHEGMENT (required for AutoCAD)
; 1.03 - text height included in entmake when drawing MTEXT in CHSETOUT (required for AutoCAD)
; 1.04 - variable lists audited and updated
; 1.05 - '100' group codes included in entmake data lists in CHMARK_DRAW, CHANGENT and CHEGMENT for
;        compatibility with newer versions of AutoCAD
; 1.05 - '91' vertex code included in LWPOLYLINE entmake data lists in CHEGMENT for compatibility with
;        newer versions of AutoCAD
; 1.05 - '38' elevation code included in LWPOLYLINE entmake data list in CHEGMENT
; 1.05 - CHAINAGE_MAKE2DPOINT function added to ensure all points in LWPOLYLINE data lists are 2D, not 3D.
;        Function used in CHEGMENT
