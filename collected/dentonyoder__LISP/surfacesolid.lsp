(defun c:surfacesolid()
  (princ "\n Program by Denton Yoder for BSE.")
  (princ "\n   - wblock surface to a temp drawing.")
  (princ "\n   - Open the surface drawing and determine elevation range, then view in iso mode to show triangle")
  (princ "\n   - Explode 2 times; 1st it becomes a block, then it is a group of 3dfaces")
  (princ "\n   - Execution will create solids for each triagle from the minimum to maximum elevation you specify")
  (princ "\n   - Then it will slice the solid on the 3d face...")
  (princ "\n   - Union the bottom half to form a solid of the bottom surface")
  (princ "\n   - Union the top half to form a solid above the surface")
  (princ "\n   - Trim the top to match a flood elevation using Intersect over the solid or subtract above the elevation")
  (princ "\n\n")

  ; ssget retrieves a selection set.
  ; sslength reads the length of the selection set)
  ; loop getting the ssname to process all selected objects.

  (princ "\n Please select all the 3d faces:")
  (setq ss (ssget))
  (setq sslen (sslength ss))
  (setq i 0)
  (setvar "osmode" 0)
  (setvar "cmdecho" 0)

  (setq z1 (getdist "\nWhat is the lower boundary elevation:"))
  (setq z2 (getdist "\nWhat is the upper boundary elevation:"))
  (setq z2 (- z2 z1)) ; store range instead of elevation
  (setq x1 (getint "\nWhat is the exaggeration factor?"))
  
  (while (< i sslen) (progn
		(setq e1 (entget (ssname ss i)))
		(princ (strcat "\n Processing#" (itoa i)))

		(setq p1 (cdr (assoc 10 e1)))
		(setq p2 (cdr (assoc 11 e1)))
		(setq p3 (cdr (assoc 12 e1)))
		
		(command "pline" (list (car p1) (cadr p1) z1) (list (car p2) (cadr p2) z1) (list (car p3) (cadr p3) z1) "c")
		(command "extrude" "l" "" (* z2 x1)) ; extrude triangle to desired height times extrusion factor
		(command "slice" "l" "" "" (list (car p1) (cadr p1) (+ (* (- (caddr p1) z1) x1) z1)) (list (car p2) (cadr p2) (+ (* (- (caddr p2) z1) x1) z1)) (list (car p3) (cadr p3) (+ (* (- (caddr p3) z1) x1) z1)) "b")
			 
		(vl-cmdf ".redraw")
		
		(setq i (+ i 1))
	))

  (princ)
  )