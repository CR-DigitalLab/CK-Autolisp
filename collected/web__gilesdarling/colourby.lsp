; COLOURBY_ERRORMSG, COLOURBY_ATSTART and COLOURBY_ATEND
; ======================================================

; Description:
; ============
; Handle error messages, set-up and restore point to error message handler, and being/end UNDO loop

; Global Variables:
; =================
; colourby_olderr = pointer to old error message handler

; Internal Variables:
; ===================
; em_t1 = error message passed to error message handler
; em_o1 = old value of CMDECHO in colourby_errormsg
; as_o1 = old value of CMDECHO in colourby_atstart
; ae_o1 = old value of CMDECHO in colourby_atend

(defun colourby_errormsg (em_t1 / em_o1)

; restore pointer to old error message handler and display error message
 (setq *error* colourby_olderr)
 (setq colourby_olderr nil)
 (princ (strcat "\nCommand stopped due to error: " em_t1))

; end UNDO group command
 (setq em_o1 (getvar "CMDECHO"))
 (setvar "CMDECHO" 0)
 (command "UNDO" "E")
 (setvar "CMDECHO" em_o1)
 (princ)
)

(defun colourby_atstart ( / as_o1)

; set error message handler pointer to new error message handler
 (setq colourby_olderr *error*)
 (setq *error* colourby_errormsg)

; begin UNDO group command
 (setq as_o1 (getvar "CMDECHO"))
 (setvar "CMDECHO" 0)
 (command "UNDO" "BE")
 (setvar "CMDECHO" as_o1)
)

(defun colourby_atend ( / ae_o1)

; end UNDO group command
 (setq ae_o1 (getvar "CMDECHO"))
 (setvar "CMDECHO" 0)
 (command "UNDO" "E")
 (setvar "CMDECHO" ae_o1)

; restore pointer to old error message handler
 (setq *error* colourby_olderr)
 (setq colourby_olderr nil)
)

; =============================================================================================

; COLOURBY_GETGOBALVAL
; ====================

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

(defun colourby_getglobalval (gv_t1 gv_g1 gv_d1 gv_b1 / gv_v1)
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

; COLOURBY_MAX
; ============

; Description:
; ============
; Returns maximum value or nil if one or both inputs are nil
; Inputs: two values
; Output: maximum value (or nil)

; Internal Variables:
; ===================
; mi_v1 = first input value
; mi_v2 = second input value
; mi_v3 = output value

(defun colourby_max (mi_v1 mi_v2 / mi_v3)

; set output value as nil if either input values are nil
 (if (or (= mi_v1 nil) (= mi_v2 nil))
  (setq mi_v3 nil)

; otherwise calculate output value ("max" function creates error if nil is passed to it)
  (setq mi_v3 (max mi_v1 mi_v2))
 )

; set output value to itself - return value from this function
 (setq mi_v3 mi_v3)
)

; =============================================================================================

; COLOURBY_GETTRIASLOPE
; =====================

; Description:
; ============
; Returns slope from a 3D polyline triangle object (closed polyline with only three vertices)
; Inputs: entity name for a 3D polyline triangle object
; Output: slope (or nil if not available)
; FUNCTION NO LONGER REQUIRED (Version 1.05) BUT RETAINED IN CASE NEEDED IN FUTURE VERSION

; Internal Variables:
; ===================
; ts_e1 = 3D polyline triangle object's entity name
; ts_c1 = count of corners of triangle found
; ts_d1 = 3D polyline triangle object's entity data
; ts_e1, ts_d1 = entity name and data for subsequent polyline vertices
; ts_p1 = location point of VERTEX object within polyline definition (i.e. a triangle corner)
; ts_x1, ts_y1, ts_z1, ts_x2, ts_y2, ts_z2, ts_x3, ts_y3, ts_z3 = x,y,z at corners
; ts_v1 = slope value
; ts_f1, ts_f2 = gradients of slope in x and y directions

(defun colourby_gettriaslope (ts_e1 / ts_c1 ts_d1 ts_p1 ts_x1 ts_y1 ts_z1 ts_x2 ts_y2
                                      ts_z2 ts_x3 ts_y3 ts_z3 ts_v1 ts_f1 ts_f2)

; set number of corners found as zero, in case polyline is not a closed 3D triangle
 (setq ts_c1 0)

; continue if can read 3D POLYLINE's data and if it is closed
 (if (/= (setq ts_d1 (entget ts_e1)) nil)
  (if (/= (assoc 70 ts_d1) nil)
   (if (= (cdr (assoc 70 ts_d1)) 9)
    (progn

; look through subsequent entity objects
     (setq ts_e1 (entnext ts_e1))
     (while (and (< ts_c1 4) (/= ts_e1 nil))

; if a 3D POLYLINE vertex, get its x,y,z coordinates
      (if (/= (setq ts_d1 (entget ts_e1)) nil)
       (if (= (cdr (assoc 0 ts_d1)) "VERTEX")
        (progn
         (if (/= (assoc 70 ts_d1) nil)
          (if (= (cdr (assoc 70 ts_d1)) 32)
           (progn

; get point of current vertex and then assign x,y,z values depending on corner counter
            (setq ts_p1 (cdr (assoc 10 ts_d1)))
            (if (= ts_c1 0)
             (setq ts_x1 (car ts_p1) ts_y1 (cadr ts_p1) ts_z1 (caddr ts_p1))
             (if (= ts_c1 1)
              (setq ts_x2 (car ts_p1) ts_y2 (cadr ts_p1) ts_z2 (caddr ts_p1))
              (if (= ts_c1 2)
               (setq ts_x3 (car ts_p1) ts_y3 (cadr ts_p1) ts_z3 (caddr ts_p1))
              )
             )
            )

; increase corner counter (even if more than 3 corners have been found)
            (setq ts_c1 (1+ ts_c1))
           )
          )
         )

; if finished processing VERTEX, look at next entity object after it
         (setq ts_e1 (entnext ts_e1))
        )

; if entity object found was not a VERTEX (e.g. SEQEND) exit while loop
        (setq ts_e1 nil)
       )

; also exit while loop if unable to get entity's data (but should always get data)
       (setq ts_e1 nil)
      )
     )
    )
   )
  )
 )

; if more or less than 3 corners have been found, return nil slope value
 (if (/= ts_c1 3)
  (setq ts_v1 nil)
  (progn

; otherwise calculate denominator of gradients of slope in x and y directions
   (setq ts_f1 (- (* (- (* ts_x1 ts_y3) (* ts_x3 ts_y1)) (- ts_y1 ts_y2))
                  (* (- (* ts_x1 ts_y2) (* ts_x2 ts_y1)) (- ts_y1 ts_y3))))
   (setq ts_f2 (- (* (- (* ts_x1 ts_y2) (* ts_x2 ts_y1)) (- ts_x1 ts_x3))
                  (* (- (* ts_x1 ts_y3) (* ts_x3 ts_y1)) (- ts_x1 ts_x2))))

; if either denominator is zero, then cannot calculate slope
   (if (or (= ts_f1 0.0) (= ts_f2 0.0))
    (setq ts_v1 nil)

; otherwise finish calculation of gradients
    (progn
     (setq ts_f1 (/ (- (* (- (* ts_y1 ts_z2) (* ts_y2 ts_z1)) (- ts_y1 ts_y3))
                       (* (- (* ts_y1 ts_z3) (* ts_y3 ts_z1)) (- ts_y1 ts_y2))) ts_f1))
     (setq ts_f2 (/ (- (* (- (* ts_x1 ts_z2) (* ts_x2 ts_z1)) (- ts_x1 ts_x3))
                       (* (- (* ts_x1 ts_z3) (* ts_x3 ts_z1)) (- ts_x1 ts_x2))) ts_f2))

; calculate slope value (as a percentage)
     (setq ts_v1 (* 100.0 (sqrt (+ (* ts_f1 ts_f1) (* ts_f2 ts_f2)))))
    )
   )
  )
 )

; set output value to itself - return value from this function
 (setq ts_v1 ts_v1)
)

; =============================================================================================

; COLOURBY_GETINITLIST
; ====================

; Description:
; ============
; Returns list of entity/value pairs and min/max values from a selection set, and search-for value
; Input: selection set, type of value to look for
; Output: list, min value, max value

; Internal Variables:
; ===================
; il_s1 = selection set of objects
; il_b1 = what to look for: 1=POINT x-val, 2=POINT y-val, 3=POINT z-val,
;                           4=LWPOLYLINE z-val, 5=LINE z-val, 6=SOLID z-val, 7=SOLID y-val
; il_c1 = count through il_s1
; il_l1 = output list (pairs of entity names and values)
; il_m1 = minimum value
; il_m2 = maximum value
; il_d1 = entity data of each object in il_s1
; il_e1 = entity name of each object in il_s1
; il_v1 = search value from entity data

(defun colourby_getinitlist (il_s1 il_b1 / il_c1 il_l1 il_m1 il_m2 il_d1 il_e1 il_v1)

; initiate counter, set output list to empty, and min and max values to undefined
 (setq il_c1 0 il_l1 nil il_m1 nil il_m2 nil)

; go through each object in selection set
 (repeat (sslength il_s1)

; get that object's data and entity name, and set search value as 'none' in case cannot find a value
  (setq il_d1 (entget (setq il_e1 (ssname il_s1 il_c1))) il_v1 nil)

; get search value, based on what to look for (e.g. POINT's x,y or z coordinate)
  (if (= il_b1 1)
   (setq il_v1 (car (cdr (assoc 10 il_d1))))
   (if (= il_b1 2)
    (setq il_v1 (cadr (cdr (assoc 10 il_d1))))
    (if (= il_b1 3)
     (setq il_v1 (caddr (cdr (assoc 10 il_d1))))

; or elevation of LWPOLYLINE object
     (if (= il_b1 4)
      (setq il_v1 (cdr (assoc 38 il_d1)))

; or elevation of LINE object (only if line has same z coordinate at each end of line)
      (if (and (= il_b1 5) (= (caddr (cdr (assoc 10 il_d1))) (caddr (cdr (assoc 11 il_d1)))))
       (setq il_v1 (caddr (cdr (assoc 10 il_d1))))

; or z coordinate of SOLID object (assume all corners have same z coordinate)
       (if (= il_b1 6)
        (setq il_v1 (caddr (cdr (assoc 10 il_d1))))

; or y coordinate of SOLID object (first corner) (for COLOURBYSET command only)
        (if (= il_b1 7)
         (setq il_v1 (cadr (cdr (assoc 10 il_d1))))
        )
       )
      )
     )
    )
   )
  )

; if value was obtained (i.e. no longer 'none')
  (if (/= il_v1 nil)
   (progn

; create/add entity name/value pair to output list
    (if (= il_l1 nil)
     (setq il_l1 (list (list il_e1 il_v1)))
     (setq il_l1 (append il_l1 (list (list il_e1 il_v1))))
    )

; set/update minimum and maximum values
    (if (= il_m1 nil)
     (setq il_m1 il_v1 il_m2 il_v1)
     (setq il_m1 (min il_m1 il_v1) il_m2 (max il_m2 il_v1))
    )
   )
  )

; increase counter to look at next object in il_s1
  (setq il_c1 (1+ il_c1))
 )

; create list of output list, min and max values - returned by this function (can all be nil)
 (list il_l1 il_m1 il_m2)
)

; =============================================================================================

; COLOURBY_REORDERLIST
; ====================

; Description:
; ============
; Returns list reordered by values of entity/value pairs (low to high)
; Inputs: list, min value, max value
; Output: re-ordered list

; Internal Variables:
; ===================
; rl_l1 = input list (pairs of entity names/values, not in any particular order)
; rl_m1 = input minimum value, then comparison value to decide if to add item to output list
; rl_m2 = input maximum value
; rl_l2 = re-ordered output list created by this function
; rl_c1 = count through list rl_l1
; rl_n1 = next value for deciding whether to add items to list, after current comparison
; rl_p1 = entity name/value pair in input list

(defun colourby_reorderlist (rl_l1 rl_m1 rl_m2 / rl_l2 rl_c1 rl_n1 rl_p1)
; set output list as empty
 (setq rl_l2 nil)

; keep going through list until comparison value is more than maximum value
 (while (<= rl_m1 rl_m2)

; initiate counter through list, and set next comparison value to more than maximum value
  (setq rl_c1 0 rl_n1 (+ rl_m2 1.0))

; go through input list
  (while (< rl_c1 (length rl_l1))

; get individual pair from input list, and add to output list if value matches comparison value
   (setq rl_p1 (nth rl_c1 rl_l1))
   (if (= (cadr rl_p1) rl_m1)

; create output list if doesn't exist yet, otherwise add pair to end of output list
    (if (= rl_l2 nil)
     (setq rl_l2 (list rl_p1))
     (setq rl_l2 (append rl_l2 (list rl_p1)))
    )

; if pair value is above current comparison and below next comparison, set next to pair's value
    (if (and (> (cadr rl_p1) rl_m1) (< (cadr rl_p1) rl_n1))
     (setq rl_n1 (cadr rl_p1))
    )
   )

; increase counter to look at next pair in input list
   (setq rl_c1 (1+ rl_c1))
  )

; set comparison value to next comparison (will be above maximum value if nothing left to add)
  (setq rl_m1 rl_n1)
 )

; set output list to itself - so list is returned by this function
 (setq rl_l2 rl_l2)
)

; =============================================================================================

; COLOURBY_GETGLOBALCOLOUR
; ========================

; Description:
; ============
; Returns global colour value based on current band and total number of bands
; Inputs: current band number, total number of bands
; Output: colour value (pair of standard and custom numbers)

; Global Variables:
; =================
; colourby_colour1 to colourby_colour7 = colour for each band (max. seven bands)

; Internal Variables:
; ===================
; gc_c1 = current band number (0 based)
; gc_n1 = total number of bands (2 to 7)
; gc_v1 = pair of colour values

; Useful Information:
; ===================
; Table below shows how seven global variables are shared for different numbers of bands:
; Global varible: No. of bands: 2 3 4 5 6 7 (x = colour variable in use)
; colourby_colour1              x x x x x x
; colourby_colour2                      x x
; colourby_colour3                  x x x x
; colourby_colour4                x   x   x
; colourby_colour5                  x x x x
; colourby_colour6                      x x
; colourby_colour7              x x x x x x
; "interval" uses same colours as 5 bands, "limits" uses same colours as 3 bands 

(defun colourby_getglobalcolour (gc_c1 gc_n1 / gc_v1)

; if current band number, or total number of bands are out of range, return nil value
 (if (or (< gc_c1 0) (>= gc_c1 gc_n1) (< gc_n1 2) (> gc_n1 7))
  (setq gc_v1 nil)

; get colour values depending on how many colours in band
  (if (= gc_n1 7)
   (setq gc_v1 (nth gc_c1 (list colourby_colour1 colourby_colour2 colourby_colour3
                           colourby_colour4 colourby_colour5 colourby_colour6 colourby_colour7)))
   (if (= gc_n1 6)
    (setq gc_v1 (nth gc_c1 (list colourby_colour1 colourby_colour2 colourby_colour3
                            colourby_colour5 colourby_colour6 colourby_colour7)))
    (if (= gc_n1 5)
     (setq gc_v1 (nth gc_c1 (list colourby_colour1 colourby_colour3 colourby_colour4
                             colourby_colour5 colourby_colour7)))
     (if (= gc_n1 4)
      (setq gc_v1 (nth gc_c1 (list colourby_colour1 colourby_colour3 colourby_colour5
                              colourby_colour7)))
      (if (= gc_n1 3)
       (setq gc_v1 (nth gc_c1 (list colourby_colour1 colourby_colour4 colourby_colour7)))
       (setq gc_v1 (nth gc_c1 (list colourby_colour1 colourby_colour7)))
      )
     )
    )
   )
  )
 )

; set output value to itself - return value from this function
 (setq gc_v1 gc_v1)
)

; =============================================================================================

; COLOURBY_APPLYCOLOURS
; =====================

; Description:
; ============
; Applies colours in bands to selected objects
; Inputs: list of object (entity name/value) pairs, minimum and maximum values
; Outputs: 0 if command terminated, > 0 if colours were changed

; Global variables:
; =================
; colourby_bands = number of colour bands to display
; colourby_lowerlimit = lower limit value when colouring by limits
; colourby_upperlimit = upper limit value when colouring by limits
; colourby_interval = interval value when colouring by interval
; colourby_intorigin = interval origin when colouring by interval

; Internal Variables:
; ===================
; ac_l1 = list of objects
; ac_m1 = minimum x-value
; ac_m2 = maximum x-value
; ac_h1 = how to assign colours
; ac_n1 = number of colour bands (= 0 when error occurs)
; ac_w1 = width of values for each band (when colouring by values or quantity)
; ac_c1 = count through bands
; ac_w2 = offset to object at start of next band (when colouring by quantity)
; ac_w3 = current band (when colouring by quantity)
; ac_c2 = number of objects per band
; ac_m3 = lower limit value (when colouring by limits)
; ac_m4 = upper limit value (when colouring by limits)
; ac_n2 = swap value
; ac_r1 = interval value (when colouring by interval)
; ac_r2 = interval origin value (when colouring by interval)
; ac_c1 = count through list of objects
; ac_p1 = individual entity name/value pair in list ac_l1
; ac_v1 = object's value for individual entity in list ac_l1
; ac_d1, ac_d2 = entity data for individual entity in list ac_l1 (two copies)
; ac_c2 = new colour pair (or nil if none applied)
; ac_d3 = copy of entity data containing new colour values
; ac_p2 = data pair of each data item in ac_d1
; ac_f1 = flag: T if failed to update colour so need to delete and recreate object(s)
; ac_n2 = data number of each data pair ac_p2

(defun colourby_applycolours (ac_l1 ac_m1 ac_m2 / ac_h1 ac_n1 ac_w1 ac_c1 ac_w2 ac_w3 ac_c2
                                                  ac_m3 ac_m4 ac_n2 ac_r1 ac_r2 ac_p1 ac_v1
                                                  ac_d1 ac_d2 ac_d3 ac_p2 ac_f1)

; select how to assign colours to points
 (initget 1 "value quantity limits interval")
 (setq ac_h1 (getkword "\nSelect how to assign colours to selected objects :"))

; if drawing by value or quantity, ask for number of colour bands
 (if (or (= ac_h1 "value") (= ac_h1 "quantity"))
  (progn
   (setq ac_n1 (colourby_getglobalval "Enter number of bands (2 to 7)" colourby_bands 7 T))

; ensure number of bands is between 2 and 7, and store value in global variable
   (if (< ac_n1 2)
    (setq ac_n1 2)
    (if (> ac_n1 7)
     (setq ac_n1 7)
    )
   )
   (setq colourby_bands ac_n1)

; if drawing by quantity, create ordered list of pairs by value
   (if (= ac_h1 "quantity")
    (progn
     (setq ac_l1 (colourby_reorderlist ac_l1 ac_m1 ac_m2))

; if not enough objects for this number of bands, show error
     (if (< (length ac_l1) ac_n1)
      (progn
       (princ "\nNot enough objects for this number of bands. Command terminating")
       (setq ac_n1 0)
      )

; otherwise check if no. of bands possible (i.e. values are different at each band boundary)
      (progn

; calculate width of band (average number of objects per band)
       (setq ac_w1 (/ (float (length ac_l1)) (float ac_n1)))

; check each band, begin with start of 2nd band (0 based) and set empty list of band boundaries
       (setq ac_c1 1 ac_w2 nil)
       (while (< ac_c1 ac_n1)

; calculate which data pair is at start of this band and add to list of band boundaries
        (setq ac_w3 (fix (+ (* ac_w1 ac_c1) 0.5)))
        (if (= ac_w2 nil)
         (setq ac_w2 (list ac_w3))
         (setq ac_w2 (append ac_w2 (list ac_w3)))
        )

; if values of data pair at start of this band are same as at end of previous band, show error
        (if (and (> ac_w3 0) (< ac_w3 (length ac_l1)))
         (if (= (cadr (nth (1- ac_w3) ac_l1)) (cadr (nth ac_w3 ac_l1)))
          (progn
           (princ "\nObjects are too flat for this number of bands. Command terminating")
           (setq ac_n1 0)         
          )
         )
        )

; increase counter to check at start of next band
        (setq ac_c1 (1+ ac_c1))
       )

; if still ok to change colours, set variable used in main loop below
       (if (> ac_n1 0)
        (progn
         (setq ac_w3 0)

; and display item count per band
         (setq ac_c1 (1- (length ac_w2)) ac_c2 (length ac_l1))
         (while (>= ac_c1 -1)
          (princ (strcat "\nBand " (itoa (- ac_n1 ac_c1 1)) ": "))
          (if (>= ac_c1 0)
           (progn
            (princ (itoa (- ac_c2 (nth ac_c1 ac_w2))))
            (setq ac_c2 (nth ac_c1 ac_w2))
           )
           (princ (itoa ac_c2))
          )
          (princ " objects")
          (setq ac_c1 (1- ac_c1))
         )
        )
       )
      )
     )
    )

; if drawing by value, calculate width of each band
    (progn
     (setq ac_w1 (/ (- ac_m2 ac_m1) (float ac_n1)))

; if width of band is too low show error message
     (if (< ac_w1 0.001)
      (progn
       (princ "\nObjects are too flat for this number of bands. Command terminating")
       (setq ac_n1 0)
      )

; otherwise display values for each band
      (progn
       (setq ac_c1 (1- ac_n1))
       (while (>= ac_c1 0)
        (princ (strcat "\nBand " (itoa (- ac_n1 ac_c1)) ": "
                                 (rtos (+ (* ac_w1 ac_c1) ac_m1) 2 3) " to "
                                 (rtos (+ (* ac_w1 (1+ ac_c1)) ac_m1) 2 3)))
        (setq ac_c1 (1- ac_c1))
       )
      )
     )
    )
   )
  )

; if drawing by limits get lower and upper limit values
  (if (= ac_h1 "limits")
   (progn
    (setq ac_m3 (colourby_getglobalval "Enter lower limit" colourby_lowerlimit 0.5 nil))
    (setq ac_m4 (colourby_getglobalval "Enter upper limit" colourby_upperlimit 5.0 nil))

; switch round if upper is less than lower
    (if (< ac_m4 ac_m3)
     (progn
      (princ "\nUpper limit is less than lower limit. Switching limit values round")
      (setq ac_n2 ac_m3)
      (setq ac_m3 ac_m4)
      (setq ac_m4 ac_n2)
     )
    )

; store successful limit values in global variables, and no. of bands = 3
    (setq colourby_lowerlimit ac_m3 colourby_upperlimit ac_m4 ac_n1 3)
   )

; if drawing by interval, get interval value (always positive) and interval origin value
   (progn
    (setq ac_r1 (abs (colourby_getglobalval "Enter interval value" colourby_interval 5.0 nil)))
    (setq ac_r2 (colourby_getglobalval "Enter interval origin value" colourby_intorigin 0.0 nil))

; error if zero interval value entered
    (if (= ac_r1 0.0)
     (progn
      (princ "\nZero interval value not permitted. Command terminating")
      (setq ac_n1 0)
     )

; otherwise store successful interval values in global variables, and no. of bands = 5
     (setq colourby_interval ac_r1 colourby_intorigin ac_r2 ac_n1 5)
    )
   )
  )
 )

; if number of bands > 0 apply colours to objects in list ac_l1
 (if (> ac_n1 0)
  (progn

; initiate counter and apply colours to each object in list ac_l1
   (setq ac_c1 0)
   (repeat (length ac_l1)
    (setq ac_p1 (nth ac_c1 ac_l1))

; get value for each object, and set new colour as nil (in case not set below)
    (setq ac_v1 (cadr ac_p1) ac_c2 nil)

; if drawing by value, set colour by value bands
    (if (= ac_h1 "value")
     (setq ac_c2 (colourby_getglobalcolour 
                 (- (- ac_n1 1) (min (fix (/ (- ac_v1 ac_m1) ac_w1)) (- ac_n1 1))) ac_n1))

; if drawing by quantity, set colour by quantity bands (list of item count when to change colour)
     (if (= ac_h1 "quantity")
      (progn
       (if (= ac_c1 (nth ac_w3 ac_w2))
        (setq ac_w3 (1+ ac_w3))
       )
       (setq ac_c2 (colourby_getglobalcolour (- ac_n1 ac_w3 1) ac_n1))
      )

; if drawing by limits, set colour by upper and lower limits
      (if (= ac_h1 "limits")
       (progn
        (setq ac_v1 (atof (rtos ac_v1 2 3)))
        (if (< ac_v1 ac_m3)
         (setq ac_c2 (colourby_getglobalcolour 0 3))
         (if (> ac_v1 ac_m4)
          (setq ac_c2 (colourby_getglobalcolour 2 3))
          (setq ac_c2 (colourby_getglobalcolour 1 3))
         )
        )
       )

; if drawing by interval, set colour by interval value and origin
       (progn
        (setq ac_v1 (atof (rtos ac_v1 2 3)))
        (if (= ac_v1 ac_r2)
         (setq ac_c2 (colourby_getglobalcolour 2 5))
         (if (> ac_v1 ac_r2)
          (if (= (rem (- ac_v1 ac_r2) ac_r1) 0.0)
           (setq ac_c2 (colourby_getglobalcolour 0 5))
           (setq ac_c2 (colourby_getglobalcolour 1 5))
          )
          (if (= (rem (- ac_v1 ac_r2) ac_r1) 0.0)
           (setq ac_c2 (colourby_getglobalcolour 4 5))
           (setq ac_c2 (colourby_getglobalcolour 3 5))
          )
         )
        )
       )
      )
     )
    )

; if new colour value exists, update colour value in entity data
    (if (/= ac_c2 nil)
     (progn

; get entity data for each object (make two copies - use ac_d2 if updating ac_d1 fails)
      (setq ac_d1 (setq ac_d2 (entget (car ac_p1))))

; add or substitute main colour value, depending on whether object already has a main colour value
      (if (= (assoc 62 ac_d1) nil)
       (setq ac_d1 (append ac_d1 (list (cons 62 (car ac_c2)))))
       (setq ac_d1 (subst (cons 62 (car ac_c2)) (assoc 62 ac_d1) ac_d1))
      )

; if object doesn't already have a custom colour defined, add it if custom colour required
      (if (= (assoc 420 ac_d1) nil)
       (if (/= (cadr ac_c2) nil)
        (setq ac_d1 (append ac_d1 (list (cons 420 (cadr ac_c2)))))
       )

; if object already has a custom colour, substitue new custom colour if required
       (if (/= (cadr ac_c2) nil)
        (setq ac_d1 (subst (cons 420 (cadr ac_c2)) (assoc 420 ac_d1) ac_d1))

; or if no custom colour is required, remove existing custom colour from object
        (progn

; create a copy list for object - initially an empty list
         (setq ac_d3 nil)
         (foreach ac_p2 ac_d1

; for each item in object list, add it to new list if item isn't custom colour value
          (if (/= (car ac_p2) 420)
           (if (= ac_d3 nil)
            (setq ac_d3 (list ac_p2))
            (setq ac_d3 (append ac_d3 (list ac_p2)))
           )
          )
         )

; replace object list with copy of object list (no longer includes custom colour value)
         (setq ac_d1 ac_d3)
        )
       )
      )

; modify object with new colour value(s)
      (entmod ac_d1)
      (entupd (car ac_p1))

; get object data again and set failure flag to false
      (setq ac_d1 (entget (car ac_p1)) ac_f1 nil)

; set failure flag to true if no main colour set, or main colour not new value
      (if (= (assoc 62 ac_d1) nil)
       (setq ac_f1 T)
       (if (/= (cdr (assoc 62 ac_d1)) (car ac_c2))
        (setq ac_f1 T)
       )
      )

; set failure flag to true if no custom colour set when meant to be set
; (don't 'and' these two 'if' statements - otherwise subsequent 'if' statement won't work)
      (if (= (assoc 420 ac_d1) nil)
       (if (/= (cadr ac_c2) nil)
        (setq ac_f1 T)
       )

; set failure flag to true if custom colour not new value (including new value = nil)
       (if (/= (cdr (assoc 420 ac_d1)) (cadr ac_c2))
        (setq ac_f1 T)
       )
      )

; if failure flag is set, create copy of object then delete original
      (if (= ac_f1 T)
       (progn

; create copy of data for object (start with an empty data list) using 2nd original copy
        (setq ac_d3 nil)
        (foreach ac_p2 ac_d2

; for each item in object list, add it to new list if item isn't handle, name, or colour
         (setq ac_n2 (car ac_p2))
         (if (and (/= ac_n2 -2) (/= ac_n2 -1) (/= ac_n2 5) (/= ac_n2 330)
                  (/= ac_n2 62) (/= ac_n2 420))
          (if (= ac_d3 nil)
           (setq ac_d3 (list ac_p2))
           (setq ac_d3 (append ac_d3 (list ac_p2)))
          )
         )
        )

; if copy of data has been created
        (if (/= ac_d3 nil)
         (progn

; add new colour value(s) to copy of object data
          (setq ac_d3 (append ac_d3 (list (cons 62 (car ac_c2)))))
          (if (/= (cadr ac_c2) nil)
           (setq ac_d3 (append ac_d3 (list (cons 420 (cadr ac_c2)))))
          )

; delete old entity data
          (entdel (car ac_p1))

; create new entity using new data with correct colour values
          (entmake ac_d3)
         )
        )
       )
      )
     )
    )

; increase counter to look at next entity data/value pair in list ac_l1
    (setq ac_c1 (1+ ac_c1))
   )
  )
 )

; returns 0 if command terminated, > 0 if colours were changed
 (setq ac_n1 ac_n1)
)

; =============================================================================================
;  OOOO  OOO  O      OOO  O   O OOOO  OOOO  O   O O   O
; O     O   O O     O   O O   O O   O O   O O   O  O O
; O     O   O O     O   O O   O OOOO  OOOO   OOO    O
; O     O   O O     O   O O   O O   O O   O   O    O O
;  OOOO  OOO  OOOOO  OOO   OOO  O   O OOOO    O   O   O
; =============================================================================================

; COLOURBYX
; =========

; Description:
; ============
; Applies colours to POINT objects, depending on their horizontal position (x coordinate)

; Internal Variables:
; ===================
; s1 = selection set of POINT objects
; l1 = list of objects
; m1 = minimum x-value
; m2 = maximum x-value

(defun C:COLOURBYX ( / s1 l1 m1 m2)
 (colourby_atstart)

; get selection set
 (princ "\nSelect POINT objects...")
 (if (= (setq s1 (ssget (list (cons 0 "POINT")))) nil)
  (princ "\nNo POINTs selected. Command terminating")
  (progn

; get minimum and maximum x values of points in selection set and list of entity/x-value pairs
   (setq l1 (colourby_getinitlist s1 1))
   (setq m1 (cadr l1) m2 (caddr l1))
   (setq l1 (car l1))

; discard selection set as no longer needed (and frees computer memory allocated to it)
   (setq s1 nil)

; apply colours to objects (returns 0 if error occurred, > 0 if no error)
   (if (/= l1 nil)
    (if (> (colourby_applycolours l1 m1 m2) 0)
     (princ "\nCommand finished")
    )
   )
  )
 )
 (colourby_atend)
 (princ)
)

; =============================================================================================
;  OOOO  OOO  O      OOO  O   O OOOO  OOOO  O   O O   O
; O     O   O O     O   O O   O O   O O   O O   O  O O
; O     O   O O     O   O O   O OOOO  OOOO   OOO    O
; O     O   O O     O   O O   O O   O O   O   O     O
;  OOOO  OOO  OOOOO  OOO   OOO  O   O OOOO    O     O
; =============================================================================================

; COLOURBYY
; =========

; Description:
; ============
; Applies colours to POINT objects, depending on their vertical position (y coordinate)

; Internal Variables:
; ===================
; s1 = selection set of POINT objects
; l1 = list of objects
; m1 = minimum y-value
; m2 = maximum y-value

(defun C:COLOURBYY ( / s1 l1 m1 m2)
 (colourby_atstart)

; get selection set
 (princ "\nSelect POINT objects...")
 (if (= (setq s1 (ssget (list (cons 0 "POINT")))) nil)
  (princ "\nNo POINTs selected. Command terminating")
  (progn

; get minimum and maximum y values of points in selection set and list of entity/y-value pairs
   (setq l1 (colourby_getinitlist s1 2))
   (setq m1 (cadr l1) m2 (caddr l1))
   (setq l1 (car l1))

; discard selection set as no longer needed (and frees computer memory allocated to it)
   (setq s1 nil)

; apply colours to objects (returns 0 if error occurred, > 0 if no error)
   (if (/= l1 nil)
    (if (> (colourby_applycolours l1 m1 m2) 0)
     (princ "\nCommand finished")
    )
   )
  )
 )
 (colourby_atend)
 (princ)
)

; =============================================================================================
;  OOOO  OOO  O      OOO  O   O OOOO  OOOO  O   O OOOOO
; O     O   O O     O   O O   O O   O O   O O   O    O
; O     O   O O     O   O O   O OOOO  OOOO   OOO    O
; O     O   O O     O   O O   O O   O O   O   O    O
;  OOOO  OOO  OOOOO  OOO   OOO  O   O OOOO    O   OOOOO
; =============================================================================================

; COLOURBYZ
; =========

; Description:
; ============
; Applies colours to POINT, PLINE, LINE and SOLID objects, depending on their elevation/z coords

; Internal Variables:
; ===================
; t1 = which type of object to select
; s1 = selection set of POINT, lightweight polyline, LINE or SOLID objects
; l1 = list of objects
; m1 = minimum z-value
; m2 = maximum z-value

(defun C:COLOURBYZ ( / t1 s1 l1 m1 m2)
 (colourby_atstart)

; get what type of object to select
 (initget 1 "point pline line solid")
 (setq t1 (getkword "\nSelect type of objects to which to assign colours :"))

; get selection set of POINTS (error if nothing selected)
 (if (= t1 "point")
  (progn
   (princ "\nSelect POINT objects...")
   (if (= (setq s1 (ssget (list (cons 0 "POINT")))) nil)
    (princ "\nNo POINTs selected. Command terminating")

; if successful, get list of object data
    (setq l1 (colourby_getinitlist s1 3))
   )
  )

; get selection set of lightweight polylines (error if nothing selected)
  (if (= t1 "pline")
   (progn
    (princ "\nSelect lightweight polyline (PLINE) objects...")
    (if (= (setq s1 (ssget (list (cons 0 "LWPOLYLINE")))) nil)
     (princ "\nNo lightweight polylines selected. Command terminating")

; if successful, get list of object data
     (setq l1 (colourby_getinitlist s1 4))
    )
   )

; get selection set of LINEs (error if nothing selected)
   (if (= t1 "line")
    (progn
     (princ "\nSelect LINE objects...")
     (if (= (setq s1 (ssget (list (cons 0 "LINE")))) nil)
      (princ "\nNo LINEs selected. Command terminating")

; if successful, get list of object data
      (setq l1 (colourby_getinitlist s1 5))
     )
    )

; get selection set of SOLIDs (error if nothing selected)
    (progn
     (princ "\nSelect SOLID objects...")
     (if (= (setq s1 (ssget (list (cons 0 "SOLID")))) nil)
      (princ "\nNo SOLIDs selected. Command terminating")

; if successful, get list of object data
      (setq l1 (colourby_getinitlist s1 6))
     )
    )
   )
  )
 )

; if a selection set exists
 (if (/= s1 nil)
  (progn

; get minimum and maximum z values of objects in selection set and list of entity/z-value pairs
   (setq m1 (cadr l1) m2 (caddr l1))
   (setq l1 (car l1))

; discard selection set as no longer needed (and frees computer memory allocated to it)
   (setq s1 nil)

; apply colours to objects (returns 0 if error occurred, > 0 if no error)
   (if (/= l1 nil)
    (if (> (colourby_applycolours l1 m1 m2) 0)
     (princ "\nCommand finished")
    )
   )
  )
 )
 (colourby_atend)
 (princ)
)

; =============================================================================================
;  OOOO  OOO  O      OOO  O   O OOOO  OOOO  O   O  OOOO O   O   O   OOOO  OOOOO
; O     O   O O     O   O O   O O   O O   O O   O O     O   O  O O  O   O   O
; O     O   O O     O   O O   O OOOO  OOOO   OOO  O     OOOOO O   O OOOO    O
; O     O   O O     O   O O   O O   O O   O   O   O     O   O OOOOO O   O   O
;  OOOO  OOO  OOOOO  OOO   OOO  O   O OOOO    O    OOOO O   O O   O O   O   O
; =============================================================================================

; Description:
; ============
; Draws colour chart using global variable colour bands

; Global variables:
; =================
; colourby_bands = number of colour bands to display

; Internal Variables:
; ===================
; h1 = chart type (first text, then a number)
; n1 = number of bands
; p1 = insertion point for drawing text and solid rectangles
; x1, y1, z1 = x,y,z coordinates of p1
; s1 = text size
; t1 = text output or colour list output
; c1 = counter through each band
; v1 = colour value pair (standard and custom)

(defun C:COLOURBYCHART ( / h1 n1 p1 x1 y1 z1 s1 t1 c1 v1)
 (colourby_atstart)

; select which chart type to draw
 (initget 1 "value quantity limits interval")
 (setq h1 (getkword "\nSelect which chart type to draw:"))

; if by value or quantity bands, ask how many bands to display
 (if (or (= h1 "value") (= h1 "quantity"))
  (progn
   (setq n1 (colourby_getglobalval "Enter number of bands (2 to 7)" colourby_bands 7 T))

; ensure number of bands is between 2 and 7, and store value in global variable
   (if (< n1 2)
    (setq n1 2)
    (if (> n1 7)
     (setq n1 7)
    )
   )
   (setq colourby_bands n1)

; reset text to numerical value (0, 1, 2 or 3) and number of bands for chart types 2 and 3
   (if (= h1 "value")
    (setq h1 0)
    (setq h1 1)
   )
  )
  (if (= h1 "limits")
   (setq n1 3 h1 2)
   (setq n1 5 h1 3)
  )
 )

; get insertion point to draw chart
 (if (= (setq p1 (getpoint "\nSelect insertion point: ")) nil)
  (princ "\nNo insertion point selected. Command terminating")
  (progn

; convert point to its x,y,z components, and get text size value
   (setq x1 (car p1) y1 (cadr p1) z1 (caddr p1) s1 (getvar "TEXTSIZE"))

; draw title text (underlined) for chart, and move vertical coordinate down a bit
   (setq t1 (nth h1 (list "Value Bands" "Quantity Bands" "Minimum and Maximum Limits"
                          "Regular Intervals")))
   (entmake (list (cons 0 "TEXT") (cons 100 "AcDbEntity") (cons 100 "AcDbText")
                  (list 10 x1 y1 z1) (cons 50 0.0) (cons 40 s1)
                  (cons 1 (strcat "%%UColour by " t1 "%%U"))))
   (setq y1 (- y1 (* s1 2.0)))

; initiate counter before drawing each colour band
   (setq c1 0)
   (while (< c1 n1)

; get the colour, and convert to list (two items if it's a custom colour)
    (setq v1 (colourby_getglobalcolour c1 n1))
    (setq t1 (list (cons 62 (car v1))))
    (if (/= (cadr v1) nil)
     (setq t1 (append t1 (list (cons 420 (cadr v1)))))
    )

; draw solid rectangle of colour, and move vertical coordinate down a bit
    (entmake (append (list (cons 0 "SOLID") (cons 100 "AcDbEntity") (cons 100 "AcDbTrace")
                           (list 10 x1 y1 z1)
                           (list 11 (+ x1 (* s1 6.0)) y1 z1) (list 12 x1 (- y1 (* s1 3.0)) z1)
                           (list 13 (+ x1 (* s1 6.0)) (- y1 (* s1 3.0)) z1)) t1))
    (setq y1 (- y1 (* s1 2.0)))

; for chart types 0 and 1 show band number, otherwise show particular text
    (if (< h1 2)
     (setq t1 (strcat "Band " (itoa (1+ c1))))
     (if (= h1 2)
      (setq t1 (nth c1 (list "Above Maximum" "Within Range" "Below Minimum")))
      (setq t1 (nth c1 (list "On Interval (+ve)" "Off Interval (+ve)" "Origin"
                             "Off Interval (-ve)" "On Interval (-ve)")))
     )
    )

; draw text, and move vertical coordinate down a bit more
    (entmake (list (cons 0 "TEXT") (cons 100 "AcDbEntity") (cons 100 "AcDbText")
                   (list 10 (+ x1 (* s1 8.0)) y1 z1)
                   (cons 50 0.0) (cons 40 s1) (cons 1 t1))) 
    (setq y1 (- y1 (* s1 2.0)))

; increase counter to look at next band
    (setq c1 (1+ c1))
   )
  )
 )
 (colourby_atend)
 (princ)
)

; =============================================================================================
;  OOOO  OOO  O      OOO  O   O OOOO  OOOO  O   O  OOOO OOOOO OOOOO
; O     O   O O     O   O O   O O   O O   O O   O O     O       O
; O     O   O O     O   O O   O OOOO  OOOO   OOO   OOO  OOOO    O
; O     O   O O     O   O O   O O   O O   O   O       O O       O
;  OOOO  OOO  OOOOO  OOO   OOO  O   O OOOO    O   OOOO  OOOOO   O
; =============================================================================================

; COLOURBYSET
; ===========

; Description:
; ============
; Set new colour values for global variable colour bands

; Global Variables:
; =================
; colourby_colour1 to colourby_colour7 = colour for each band (max. seven bands)

; Internal Variables:
; ===================
; s1 = selection set of SOLID objects
; l1 = list of objects
; m1 = minimum x-value
; m2 = maximum x-value
; n1 = number of bands
; c1 = count through list l1
; d1 = entity data for each SOLID object in list l1
; d2 = standard colour value, then list of both colour values
; d3 = custom colour value

(defun C:COLOURBYSET ( / s1 l1 m1 m2 n1 c1 d1 d2 d3)
 (colourby_atstart)

; get selection set - errors if none, too few or too many objects selected
 (princ "\nSelect SOLID objects (typically drawn using COLOURBYCHART command)...")
 (if (= (setq s1 (ssget (list (cons 0 "SOLID")))) nil)
  (princ "\nNo SOLIDs selected. Command terminating")
  (if (or (< (sslength s1) 2) (> (sslength s1) 7))
   (progn
    (princ "\nToo many or too few SOLIDs selected. Command terminating")
    (setq s1 nil)
   )
   (progn

; get minimum and maximum y values of solids in selection set and list of entity/y-value pairs
    (setq l1 (colourby_getinitlist s1 7))
    (setq m1 (cadr l1) m2 (caddr l1))
    (setq l1 (car l1))

; set number of bands (from 2 to 7)
    (setq n1 (sslength s1))

; discard selection set as no longer needed (and frees computer memory allocated to it)
    (setq s1 nil)

; reorder list, and initiate counter through list of objects
    (setq l1 (colourby_reorderlist l1 m1 m2) c1 0)

; go through list, assigning colours to global variables
    (while (< c1 (length l1))

; get object's data, then colour values for that object
     (setq d1 (entget (car (nth c1 l1))))
     (setq d2 (assoc 62 d1) d3 (assoc 420 d1))

; if colour data is available (i.e. not set to "bylayer")
     (if (/= d2 nil)
      (progn
       (setq d2 (cdr d2))
       (if (/= d3 nil)
        (setq d3 (cdr d3))
       )
       (setq d2 (list d2 d3))

; set colours depending on count and total number of bands selected
; start with first and last colours (independent of number of bands)
       (if (= c1 0)
        (setq colourby_colour7 d2)
        (if (= c1 (1- n1))
         (setq colourby_colour1 d2)

; then second colour (depends on number of bands)
         (if (= c1 1)
          (if (> n1 5)
           (setq colourby_colour6 d2)
           (if (> n1 3)
            (setq colourby_colour5 d2)
            (setq colourby_colour4 d2)
           )
          )

; then third colour (depends on number of bands)
          (if (= c1 2)
           (if (> n1 5)
            (setq colourby_colour5 d2)
            (if (> n1 4)
             (setq colourby_colour4 d2)
             (setq colourby_colour3 d2)
            )
           )

; then fourth colour (depends on number of bands)
           (if (= c1 3)
            (if (> n1 6)
             (setq colourby_colour4 d2)
             (setq colourby_colour3 d2)
            )

; then fifth colour (depends on number of bands)
            (if (= c1 4)
             (if (> n1 6)
              (setq colourby_colour3 d2)
              (setq colourby_colour2 d2)
             )

; then sixth colour (only one situation left)
             (setq colourby_colour2 d2)
            )
           )
          )
         )
        )
       )
      )
     )

; increase counter to look at next object in list
     (setq c1 (1+ c1))
    )
    (princ "\nCommand finished")
   )
  )
 )
 (colourby_atend)
 (princ)
)

; =============================================================================================

; COLOURBY_RESETDEFCOLOURS
; ========================

; Description:
; ============
; Resets colour values for global variable colour bands to default values

; Global Variables:
; =================
; colourby_colour1 to colourby_colour7 = colour for each band (max. seven bands)

(defun colourby_resetdefcolours ( / )

; set pairs of standard colour value and custom colour value (= nil if undefined)
 (setq colourby_colour1 (list 1 nil)
       colourby_colour2 (list 30 nil)
       colourby_colour3 (list 2 nil)
       colourby_colour4 (list 3 nil)
       colourby_colour5 (list 4 nil)
       colourby_colour6 (list 150 nil)
       colourby_colour7 (list 5 nil))
)

; =============================================================================================
;  OOOO  OOO  O      OOO  O   O OOOO  OOOO  O   O OOOO  OOOOO  OOOO OOOOO OOOOO
; O     O   O O     O   O O   O O   O O   O O   O O   O O     O     O       O
; O     O   O O     O   O O   O OOOO  OOOO   OOO  OOOO  OOOO   OOO  OOOO    O
; O     O   O O     O   O O   O O   O O   O   O   O   O O         O O       O
;  OOOO  OOO  OOOOO  OOO   OOO  O   O OOOO    O   O   O OOOOO OOOO  OOOOO   O
; =============================================================================================

; COLOURBYRESET
; ===========

; Description:
; ============
; Resets colour values for global variable colour bands to default values

(defun C:COLOURBYRESET ( / )
 (colourby_resetdefcolours)
 (princ "\nColour bands reset to default colours")
 (princ)
)

; =============================================================================================
; Set initial colour values as global variables when loading this lisp file:
(colourby_resetdefcolours)

; =============================================================================================
; Output to screen when this lisp file is uploaded:

(princ "\nCOLOURBY.LSP loaded (Version 1.05 GD 13-Aug-2015) including the following commands:")
(princ "\n COLOURBYX - colours POINTs according to x coordinate")
(princ "\n COLOURBYY - colours POINTs according to y coordinate")
(princ "\n COLOURBYZ - colours POINTs, LINEs, SOLIDs or lightweight polylines according to z coordinates")
(princ "\n COLOURBYCHART - draws chart of colours used in above commands")
(princ "\n COLOURBYSET - set new colour values for use in above commands")
(princ "\n COLOURBYRESET - resets colours to default values")
(princ)

; =============================================================================================
; Revision information:
; 1.01 - COLOURBY_GETSOLIDSLOPE rewritten as COLOURBY_GETTRIASLOPE
; 1.01 - COLOURBY_GETINITLIST - il_b1: purpose 6 changed, purpose 8 added
; 1.01 - COLOURBY_APPLYCOLOURS - only codes 62 and 420 removed from ac_e2, and
;                                entdel/entmake replaced by entmod
; 1.01 - COLOURBYZ - SOLID option added
; 1.01 - COLOURBYSLOPE - references to SOLIDs replaced by 3D polyline triangles
; 1.01 - "Output to screen" descriptions for COLOURBYZ and COLOURBYSLOPE changed
; 1.02 - text height included in entmake when drawing single line text in COLOURBYCHART (required for AutoCAD)
; 1.02 - COLOURBY_APPLYCOLOURS - changed how new colours are applied to entities: first tries entmod, then
;                                if unsucessful, creates copy of data with new colours, then entdels original
;                                and entmakes new copy
; 1.02 - COLOURBYRESET - message added saying reset to default colours
; 1.03 - variable lists audited and updated
; 1.04 - '100' group codes included in entmake data lists in COLOURBYCHART for compatibility with newer
;        versions of AutoCAD
; 1.04 - '100' group codes no longer omitted when creating copy of object data in COLOURBY_APPLYCOLOURS
; 1.05 - COLOURBYSLOPE - removed as cannot change 3D polyline colours consistently in both CorelCAD and AutoCAD
; 1.05 - COLOURBY_GETTRIASLOPE - no longer used, but kept in lisp file in case needed again in the future
; 1.05 - COLOURBY_GETINITLIST - il_b1: purpose 8 (by slope) removed from description and from within lisp file
; 1.05 - COLOURBY_APPLYCOLOURS - removed code relating to 3D polylines, and VERTEX and SEQEND subentities
