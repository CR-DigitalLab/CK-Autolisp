;;;     REVCLOUD.LSP
;;;     Copyright (C) 1997 by Autodesk, Inc.
;;;
;;;     Permission to use, copy, modify, and distribute this software
;;;     for any purpose and without fee is hereby granted, provided
;;;     that the above copyright notice appears in all copies and 
;;;     that both that copyright notice and the limited warranty and 
;;;     restricted rights notice below appear in all supporting 
;;;     documentation.
;;;
;;;     AUTODESK PROVIDES THIS PROGRAM "AS IS" AND WITH ALL FAULTS.  
;;;     AUTODESK SPECIFICALLY DISCLAIMS ANY IMPLIED WARRANTY OF 
;;;     MERCHANTABILITY OR FITNESS FOR A PARTICULAR USE.  AUTODESK, INC. 
;;;     DOES NOT WARRANT THAT THE OPERATION OF THE PROGRAM WILL BE 
;;;     UNINTERRUPTED OR ERROR FREE.
;;;
;;;     Use, duplication, or disclosure by the U.S. Government is subject to 
;;;     restrictions set forth in FAR 52.227-19 (Commercial Computer 
;;;     Software - Restricted Rights) and DFAR 252.227-7013(c)(1)(ii) 
;;;     (Rights in Technical Data and Computer Software), as applicable. 
;;;  
;;;     Last revision 3/14/97 1:28 PM Greg Robinson
;;; 
;;; 
;;;     Credits: Original Code, idea and concept by David Harrington 
;;;              Bill Kramer, Q.C.
;;;              Phil Kreiker, Q.C.
;;;              Dominic Panholzer, Q.C.
;;;              Randy Kinsley, Error Control
;;;              Greg Robinson
;;; 
;;; 

(Defun C:REVCLOUD (/
     ARC_DIST   ;;radius of included arc
     INC_ANGLE  ;;included angle in degrees
     LAST_PT    ;;the last point just entered/shown
     START_PT   ;;where the cloud began
     NEXT_PT    ;;where we are going next
     TMP        ;;tempory holder for radius of bulge
     )

   (init_bonus_error
      (List
         (List "cmdecho" 0
               "blipmode" 0
               "osmode" 0
         )
         T     ;flag. True means use undo for error clean up.  
      ) ;list 
   ) ;init_bonus_error



   ;;--------real program starts here!

   (Setq INC_ANGLE 110)
   
   (if (and
         (/= ""  (getcfg "AppData/AC_Bonus/Revcld_Bulge"))
         (/= nil (getcfg "AppData/AC_Bonus/Revcld_Bulge"))
       )
     (setq ARC_DIST (atof (getcfg "AppData/AC_Bonus/Revcld_Bulge")))
     (if (= (getvar "DIMSCALE") 0)
       (setq ARC_DIST 0.375)
       (setq ARC_DIST (* 0.375 (getvar "DIMSCALE")))
     )
   );end if

   (prompt (strcat "\nArc length set at " (rtos ARC_DIST 2 3)))

   (initget "Arc")
   (setq LAST_PT (GetPoint "\nArc length/<Pick cloud starting point>: "))

   (if (= LAST_PT "Arc")
     (progn
       (initget 6)
       (setq TMP (getdist (strcat "\nArc length <" (rtos ARC_DIST 2 3) ">: ")))
       (if TMP 
         (Progn
           (setq ARC_DIST TMP)
                ;R14 method of saving variable values
           (setcfg "AppData/AC_Bonus/Revcld_Bulge" (rtos ARC_DIST)) 
         )
       )
       (setq LAST_PT (getpoint "\nPick cloud start point: "))
     ) ;;end STR "RADIUS" test
   )

   (if LAST_PT (progn  ;;start up the cloud generator...
     (setq START_PT LAST_PT
           SAVED_EN (entlast))
     (Prompt "\nGuide crosshairs along cloud path...")
     (Command
        "_.pline"     ;draw cloud as a polyline on current layer
        LAST_PT
        "_a"         ;specify arc option
        "_a"         ;specify angle option
        INC_ANGLE    ;included angle
     )
   )) ;end IF LAST_PT

   (While LAST_PT  ;;as long as we have a last point value,

      (Setq NEXT_PT (GrRead 1)     ;;real time read
            READTYP (car NEXT_PT)
      )
      (if (or (=  5 READTYP) (= READTYP 3)) ;;read a position or a pick?
         (progn
           (setq NEXT_PT (cadr NEXT_PT))
           (If (or (> (Distance LAST_PT NEXT_PT) ARC_DIST) (= READTYP 3))
             (Progn
               (Command NEXT_PT "_a" INC_ANGLE)
               (Setq LAST_PT NEXT_PT)
             )
           )
           (If (>
               (Distance LAST_PT NEXT_PT)
               (Distance START_PT NEXT_PT)
               )
             (Progn
               (Command START_PT "_cl")
               (Setq LAST_PT Nil)
               (prompt "\nCloud finished.")
             )
           )
         )
         (prompt "\nMove the pointer to draw the cloud")
      );End if
   );End while
   (restore_old_error)
   (Princ)
) ;end cloud.lsp

(Defun c:RCHELP (/)
(prompt "   The Revision Cloud program draws a user specified bulge pline\n")
(prompt "   along the path of the crosshairs. To close the cloud, \n")
(prompt "   simply return to the starting point\n")
(prompt "   The cloud arc length can be specified in the beginning, with keyboard input\n")
(prompt "   by specifying A for Arc, entering a length, or picking two pts.\n")
(textscr)
(princ)
)

(Prompt "   REVCLOUD loaded. Type REVCLOUD to draw Revision Cloud,\n")
(prompt "   to close, return to starting point. For additional Help - RCHELP")
(Princ)
