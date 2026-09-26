;;;   FIXPLINE.lsp

;;;   Copyright (C) 1991 by Autodesk, Inc.

;;;  

;;;   Permission to use, copy, modify, and distribute this software and its

;;;   documentation for any purpose and without fee is hereby granted.  

;;;

;;;   THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT EXPRESS OR IMPLIED WARRANTY. 

;;;   ALL IMPLIED WARRANTIES OF FITNESS FOR ANY PARTICULAR PURPOSE AND OF 

;;;   MERCHANTABILITY ARE HEREBY DISCLAIMED.

;;; 

;;;   by Carl B. Bethea

;;;   18 Jun 1991

;;;    8 Oct 1991  Revised: added check for bulge of +/- 1e+99

;;;

;;;---------------------------------------------------------

;;;   DESCRIPTION

;;;

;;;   Some application programs create complex polylines which have vertices 

;;;   with extremely small bulge factors, ie less than 1E-6; these segments 

;;;   are essentially straight. These very small bulge factors (group 42)

;;;   create problems during the calculations for the TRIM and OFFSET 

;;;   commands. To eliminate the problem, FixPline searches the vertices of 

;;;   selected polylines and replaces very small bulge factors with 0.

;;;   In other words, FixPline makes those segments straight. 

;;;

;;;   As the program executes, it displays its current status in the screen 

;;;   menu area. It displays three numbers: the total number of entities 

;;;   selected (Total); the number of entities remaining to be processed 

;;;   (Remain); and the number of vertices which have been straightened 

;;;   (Vertices Fixed). This information is useful for giving the operator 

;;;   feedback while editing large files which may require more than a 

;;;   few minutes to process.

;;;

;;;   Sometimes, polylines can have a bulge factor that approaches

;;;   infinity (1e+99).  The bulge factor is (2*h/d) where d is the chord

;;;   distance and h is the height at the midpoint (p.560 RM).  A bulge near

;;;   1e+99 usually means that the chord has nearly no length, it's a corner.

;;;   The very extreme bulge factors create problems for the OSNAP functions.  

;;;   FixPline changes the bulge factor for these vertices to +/- 1.0e+98. 

;;;

;;;

;;;-- ckbulge ----------------------------------------------

;;;   if the bulge is less than 1E-6, 

;;;   then make group 42 0

;;;   (ckbulge <polyline entity name>)

;;;

(defun ckbulge (poly / ent i data)

   (setq ent poly

           i 0

   )

   (while 

      (and

         (setq ent (entnext ent)) 

         (setq data (entget ent))

         (= "VERTEX" (dxf 0))

      )

      (cond

         ((< (abs (dxf 42)) 0.000001)

             (setq i (1+ i))

             (entmod

                 (subst 

                    (cons 42 0.0)

                    (assoc 42 data)

                    data

                 )

             )

         )   

         ((> (dxf 42) 1.0e+98)

             (setq i (1+ i))

             (entmod

                 (subst 

                    (cons 42 1e+98)

                    (assoc 42 data)

                    data

                 )

             )

         )   

         ((< (dxf 42) -1.0e+98)

             (setq i (1+ i))

             (entmod

                 (subst 

                    (cons 42 -1e+98)

                    (assoc 42 data)

                    data

                 )

             )

         )   

         (T nil)

      )

   )

   (if (< 0 i)(entupd poly))          ; if vertex changed, update pline

   i                                  ; return the number of fixed vertices

)

;;;

;;;-- c:fixpline -------------------------------------------

;;;   gather entities, send plines to ckbulge

;;;   print feedback in screen menu 

;;;

(defun c:fixpline (/ dxf ss i j v poly data) 



   (defun dxf (code)(cdr(assoc code data)))



   (command "undo" "group")

   (prompt "\nSelect plines to fix. ")

   (cond

   ((setq ss (ssget))

      (setq i (sslength ss)

            j i

            v 0

      )

      (prompt "Working ... ")

      (menucmd "S=X")                 ; clear the screen menu

      (grtext 2 "FixPline")

      (grtext 3 "Total:")

      (grtext 4 (itoa i))

      (grtext 6 "Remain:")

      (grtext 9 "Vertices")

      (grtext 10 "Fixed: ")

      (grtext 11 "0")

      (while (< 0 i)   

         (grtext 7 (itoa i))          ; remaining entities

         (setq  i (1- i)              ; start at end of sel-set

             poly (ssname ss i)

             data (entget poly)

         )

         (if (= "POLYLINE" (dxf 0))

             (setq v (+ v (ckbulge poly)))         

         )

         (grtext 11 (itoa v))         ; print the fixed vertices

      )

   )

   (T (prompt " none found."))

   )

   (command "undo" "end")

   (grtext 7 "0")                     ; no remaining entities

   (princ)

)   

;;;

;;;--- end of file -----------------------------------------

