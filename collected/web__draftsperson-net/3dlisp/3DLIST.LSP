;;; AutoLISP File for
;;; Maximizing AutoLISP - IL DISK (c) 1987, '88, '89, '91, '92 New Riders Publ.
;;;                Version 12.00 for Release 12 PC-DOS/MS-DOS                 
;;;       Developed by Rustin Gesner, Joseph Smith, and Patrick Haessly       
;;;
;;;       Permission to use, copy, modify, and distribute this software       
;;;       for any purpose is hereby granted, provided that no fees are        
;;;       collected directly or indirectly and that the above copyright       
;;;       notice and this permission notice appear in all copies and in       
;;;       all supporting documentation. See IL DISK DISCLAIMER.TXT file.
;;;
(if (not dxf)                                           ;Test subroutines   
  (prompt "\nRequires  functions. Load aborted. ")            
  (progn                                                ;Else load OK

;;;* 3DLIST includes functions to extracts all entity data for polylines,
;;;* and extract all block table entity data, including extended entity data 
;;;* for AME entities. Requires DXF subroutine.
;;;*
;;;* PLIST returns a list of polyline head, vertex subentity and seqend data lists.
;;;* Enter (plist (car (entsel "Pick polyline: "))) to use interactively.
;;;*
(defun plist (ename / dlist edata)
  (while (and ename 
              (setq edata (entget ename)
                    dlist (append dlist (list edata))
              )
              (/= "SEQEND" (dxf 0 edata))
              (setq ename (entnext ename))
  ) )
  dlist
);defun PLIST

;;;* AMELIST returns a list of the block head and subentity data lists for the
;;;* specified block name, including extended entity data for AME entities.
;;;* It is similar to the BLIST function in TBLIST.LSP.
;;;* Enter (amelist (car (entsel "Pick polyline: "))) to use interactively.
;;;*
(defun amelist (blname / tblist tdata ename)
  (setq tblist (list (setq tdata (tblsearch "block" blname)))
        ename (dxf -2 tdata)
  )
  (while (setq tblist (append tblist (list (entget ename) '("AME_SOL")))
               ename (entnext ename)
  )      )
tblist
);defun AMELIST

(princ)
;;;*end of 3DLIST.LSP
) );test subroutines                                                  
