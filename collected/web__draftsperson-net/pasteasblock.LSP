;;;
;;;    Copyright (C) 2006 by M. Good Architectural Designs
;;;
;;;    Permission to use, copy, modify, and distribute this software
;;;    for any purpose and without fee is hereby granted, provided
;;;    that the above copyright notice appears in all copies and
;;;    that both that copyright notice and the limited warranty and
;;;    restricted rights notice below appear in all supporting
;;;    documentation.
;;;
;;;    M. GOOD ARCHITECTURAL DESIGNS PROVIDES THIS PROGRAM "AS IS" 
;;;    AND WITH ALL FAULTS. M. GOOD ARCHITECTURAL DESIGNS SPECIFICALLY
;;;    DISCLAIMS ANY IMPLIED WARRANTY OF MERCHANTABILITY OR FITNESS   
;;;    FOR A PARTICULAR USE.  M. GOOD ARCHITECTURAL DESIGNS DOES NOT  
;;;    WARRANT THAT THE OPERATION OF THE PROGRAM WILL BE UNINTERRUPTED 
;;;    OR ERROR FREE.
;;;
;;;    Use, duplication, or disclosure by the U.S. Government is subject to
;;;    restrictions set forth in FAR 52.227-19 (Commercial Computer
;;;    Software - Restricted Rights) and DFAR 252.227-7013(c)(1)(ii) 
;;;    (Rights in Technical Data and Computer Software), as applicable.
;;;
;;;
;;; DESCRIPTION: 
;;;  Paste as block function. Rather than doing a copybase and then erasing it after
;;;  simply type in pab, select the objects wanted, select a base point and select an
;;;  insertion point.


(defun c:pab (/ ob bp bpt);select an object or objects select a basepoint select a destination point and 
(princ "Select objects: ");this lisp will take the object or objects, paste them as a block and erase the original
(setq ob(ssget))
(princ "Select basepoint: ")
(setq bp(getpoint))
(setq bpt(getpoint))
(command "_copybase" bp ob "")
(command "_erase" ob "")
(command "_pasteblock" bpt)
(princ))