;;;----------------------------------------------------------------------------
;;;
;;;  FLIPDIM.LSP   Version 1.0
;;;
;;;  Copyright (C) 1996 by Jay Garnett
;;;
;;;  Permission to use, copy, modify, and distribute this software
;;;  for any purpose and without fee is hereby granted, provided
;;;  that the above copyright notice appears in all copies and
;;;  that both that copyright notice and the limited warranty 
;;;  below appear in all supporting documentation.
;;;
;;;  JAY GARNETT PROVIDES THIS PROGRAM "AS IS" AND WITH ALL FAULTS.
;;;  JAY GARNETT SPECIFICALLY DISCLAIMS ANY IMPLIED WARRANTY OF
;;;  MERCHANTABILITY OR FITNESS FOR A PARTICULAR USE. JAY GARNETT
;;;  DOES NOT WARRANT THAT THE OPERATION OF THE PROGRAM WILL BE
;;;  UNINTERRUPTED OR ERROR FREE.
;;;
;;;
;;;----------------------------------------------------------------------------
;;;  DESCRIPTION
;;;
;;;  Flips text of dimensions that extend beyond extension lines to opposite side.
;;;  Dimension must be associative, any dimension notes will remain with dimension.
;;;
;;;  By Jay Garnett
;;;  Bolingbrook, IL
;;;  
;;;  E-Mail jgarnett@enteract.com
;;;  http://www.enteract.com/~jgarnett/lispfactory.htm
;;;

(defun c:FLIPDIM( / OBJ PT1 PT2 )
   (while (not OBJ)
      (setq OBJ(entsel "\nSelect dimension to FLIP :"))
      (if OBJ
         (progn      
            (setq OBJ(entget(car OBJ)))
            (if (and OBJ (/= (cdr(assoc 0 OBJ)) "DIMENSION"))(progn (prompt "\nSelect a dimension!")(setq OBJ nil)))
         )
      )
   )
   (command ".undo" "m")
   (setq PT1 (cdr(assoc 14 OBJ)) PT2(cdr(assoc 13 OBJ)))
   (setq OBJ (subst (cons 13 PT1)(assoc 13 OBJ) OBJ)
         OBJ (subst (cons 14 PT2)(assoc 14 OBJ) OBJ)
   )
   (entmod OBJ)
   (princ)
)