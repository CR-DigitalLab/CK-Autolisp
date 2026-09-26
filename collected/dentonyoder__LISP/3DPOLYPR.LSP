
(defun get_next(ent_name)
   (entget (entnext (dxf -1 ent_name)))
)

(defun dxf(ass_code ass_name)
   (cdr (assoc ass_code ass_name))
)

(defun c:3dpolypr()
    ;;; updated for profile only - DY 2-23-2022
   ;;; Program by: Denton Yoder  1-17-94 (c)copyright E.D.S.Inc.
   ;;; Revised by: Denton Yoder 12-2-97 (c)copyright E.D.S.Inc. for R-14 & S8
   ;;; Program to build profile data without a tin.
   ;;; Builds a datafile named 'Profile.dat'
   (princ "\nCreating . . . Profile.dat")

   (SETQ f1 (getfiled "Profile Output Filename:" "profile" "txt" 1))
   (SETQ f1 (open f1 "w"))

   ;(SETQ f2 "sewer.dat")
   ;(SETQ f2 (open f2 "w"))
   ;(setq line2 "SEWER")
   ;(write-line line2 f2)

   ;(setq f3 "water.dat")
   ;(setq f3 (open f3 "w"))

   (setq e1 nil)
   (while (= e1 nil)
      (princ "\nPick the 3D poly for EG of profile:")
      (setq e1 (entsel))
   )
   (setq e1 (entget (car e1)))
   
   (setq e2 nil)
   (while (= e2 nil)
      (princ "\nPick the 2D poly for Stationing of profile:")
      (setq e2 (entsel))
   )
   (setq e2 (entget (car e2)))

   ;(princ "\nCoordinates for the 2d-poly .....\n")

;;;;   (setq e2 (get_next e2)) ;;;; for LWpoly no need to skip the header.
   (setq e1 (get_next e1))

	(setq statot (getreal "\nPlease enter starting station value:"))
	(setq station statot)

	;;;;;   (setq statot 0)
	;;;;;   (setq station 0)

   ; Read the eg to get the elevation
   (setq eg (dxf 10 e1))

	(setq e3 nil)
	(foreach n e2 (if (= (car n) 10) (setq e3 (append e3 (list (cdr n))))))
	(setq p2 (car e3))
	(setq e3 (cdr e3))

   (foreach n e3 (progn

      ;;;;(setq p1 (dxf 10 e2)) ;;; remmed in r14
	(setq p1 p2)
	(setq p2 n)
	      ;;;;;(setq e2 (get_next e2))
	      ;;;;;(setq p2 (dxf 10 e2))
      (setq slope (/ (- (cadr p2) (cadr p1)) (- (car p2) (car p1))))
      
      (setq line2 
         (strcat (rtos (cadr eg) 2 4) "," 
         (rtos (car eg) 2 4) "," 
         (rtos (caddr eg) 2 4) ",0,0,pvc,48,pvc,12,mh,0"))
      ;(write-line line2 f2)

      (while (and (/= (car p2) (car eg)) (/= (cadr p2) (cadr eg)))
         ; Calculate the station
         (setq p3 (list (car eg) (cadr eg) 0.0))
         (setq p4 (polar p3 (+ (angle p1 p2) (/ pi 2.0)) 1.0))
         (setq p4 (inters p1 p2 p3 p4 nil))
         (setq station (+ statot (distance p1 p4)))

         (setq outputvar (strcat (rtos station 2 4) " " (rtos (caddr eg) 2 4)))
         (write-line OUTPUTVAR f1)

         (setq line3 (strcat (rtos station 2 4) " " (rtos (- (caddr eg) 3.0) 2 4)))
         ;(write-line line3 f3)
         
         (setq e1 (get_next e1))
         (setq eg (dxf 10 e1))
      )

      (setq output (strcat "\nAngle =" (angtos (angle p1 p2) 4 2)))
      (princ output)
      (setq statot (+ statot (distance p1 p2)))
      (setq output (strcat "\nDist =" (rtos (distance p1 p2) 2 2)))
      (princ output)
   ))
   (princ (strcat "\nTotal length =" (rtos statot)))
   (setq outputvar (strcat (rtos statot 2 4) " " (rtos (caddr eg) 2 4)))
   (write-line OUTPUTVAR f1)
   
   (setq line3 (strcat (rtos statot 2 4) " " (rtos (- (caddr eg) 3.0) 2 4)))
   ;(write-line line3 f3)
   
   (close f1)
   ;(close f3)

   (setq line2 
      (strcat (rtos (cadr eg) 2 4) "," 
      (rtos (car eg) 2 4) "," 
      (rtos (caddr eg) 2 4) ",0,0,pvc,48,pvc,12,mh,0"))
   ;(write-line line2 f2)
   ;(close f2)

   (princ)
)

