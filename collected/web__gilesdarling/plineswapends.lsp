; PLINESWAPENDS_ERRORMSG
; ======================

; Description:
; ============
; Handle error messages

; Global Variables:
; =================
; plineswapends_olderr = pointer to old error message handler

; Internal Variables:
; ===================
; ps_t1 = error message passed to error message handler
; ps_o1 = old value of CMDECHO in plineswapends_errormsg

(defun plineswapends_errormsg (ps_t1 / ps_o1)

; restore pointer to old error message handler and display error message
 (setq *error* plineswapends_olderr)
 (setq plineswapends_olderr nil)
 (princ (strcat "\nCommand stopped due to error: " ps_t1))

; end UNDO group command
 (setq ps_o1 (getvar "CMDECHO"))
 (setvar "CMDECHO" 0)
 (command "UNDO" "E")
 (setvar "CMDECHO" ps_o1)
 (princ)
)

; =======================================================================================================
; OOOO  O     OOOOO O   O OOOOO  OOOO O   O   O   OOOO  OOOOO O   O OOOO   OOOO
; O   O O       O   OO  O O     O     O   O  O O  O   O O     OO  O O   O O
; OOOO  O       O   O O O OOOO   OOO  O O O O   O OOOO  OOOO  O O O O   O  OOO
; O     O       O   O  OO O         O OO OO OOOOO O     O     O  OO O   O     O
; O     OOOOO OOOOO O   O OOOOO OOOO  O   O O   O O     OOOOO O   O OOOO  OOOO
; =======================================================================================================

; PLINESWAPENDS
; =============

; Description:
; ============
; This command swaps the direction in which a lightweight polyline is drawn.
; The end result should look the same, but results for other measurement commands will be different.

; Scope for improvement:
; ======================
; Current version of this command doesn't check for closed polylines and it ignores variable line widths.

; Internal Variables List:
; ========================
; o1 = initial value of CMDECHO system variable
; e1 = source polyline entity
; d1 = source polyline data list
; c1 = count through source polyline data list
; d2 = destination polyline data list
; l2 = destination polyline list of points and bulges
; i1 = individual item in source polyline data list
; n1 = code value of item i1

(defun C:PLINESWAPENDS (/ o1 e1 d1 c1 d2 l2 i1 n1)

; set error message handler pointer to new error message handler
 (setq plineswapends_olderr *error*)
 (setq *error* plineswapends_errormsg)

; begin UNDO group command
 (setq o1 (getvar "CMDECHO"))
 (setvar "CMDECHO" 0)
 (command "UNDO" "BE")
 (setvar "CMDECHO" o1)

; user selects lightweight polyline - errors if nothing selected or object selected is not correct type
 (if (= (setq e1 (entsel "Select a lightweight polyline")) nil)
  (princ "\nNo object selected. Command terminating")
  (if (/= (cdr (assoc 0 (setq d1 (entget (car e1))))) "LWPOLYLINE")
   (princ "\nObject is not a lightweight polyline. Command terminating")
   (progn

; set counter and create data list and points list for new polyline to be created
    (setq c1 0 d2 (list (cons 0 "LWPOLYLINE")) l2 (list (cons 42 0.0)))
    (repeat (length d1)

; get code and values for each item in source polyline data list
     (setq n1 (car (setq i1 (nth c1 d1))))

; copy across linetype, layer, elevation, thickness, constant width, and colour values
     (if (or (= n1 6) (= n1 8) (= n1 38) (= n1 39) (= n1 43) (= n1 62))  
      (setq d2 (append d2 (list i1)))

; add vertex position to start of destination polyline points list
      (if (= n1 10)
       (setq l2 (append (list i1) l2))

; add bulge value (sign reversed) to start of destination polyline points list
       (if (= n1 42)
        (setq l2 (append (list (cons 42 (* (cdr i1) -1.0))) l2))
       )
      )
     )
     (setq c1 (1+ c1))
    )

; remove bulge value if at start of destination polyline points list
    (if (= (car (nth 0 l2)) 42)
     (setq l2 (cdr l2))
    )

; combine destination polyline data list and points list
    (setq d2 (append d2 l2))

; create new object - if successful delete source polyline
    (if (= (entmake d2) nil)
     (princ "\nFailed to swap polyline ends. Command terminating")
     (progn
      (entdel (car e1))
      (princ "\nPolyline ends swapped successfully. Command completed")
     )
    )
   )
  )
 )

; end UNDO group command
 (setvar "CMDECHO" 0)
 (command "UNDO" "E")
 (setvar "CMDECHO" o1)

; restore pointer to old error message handler
 (setq *error* plineswapends_olderr)
 (setq plineswapends_olderr nil)

 (princ)
)
(princ "\nType PLINESWAPENDS to use (Version 1.00 GD 30-Jul-2013)")
(princ)
