;;;----------------------------------------------------------------------------
;;;
;;;   MODATT.LSP   Version 1.0
;;;
;;;   Copyright (C) 1998 by K. Blackie
;;;
;;;   Permission to use, copy, modify, and distribute this software
;;;   for any purpose and without fee is hereby granted, provided
;;;   that the above copyright notice appears in all copies and that
;;;   both that copyright notice and this permission notice appear in
;;;   all supporting documentation.
;;;
;;;   THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT EXPRESS OR IMPLIED
;;;   WARRANTY.  ALL IMPLIED WARRANTIES OF FITNESS FOR ANY PARTICULAR
;;;   PURPOSE AND OF MERCHANTABILITY ARE HEREBY DISCLAIMED.
;;;
;;;   6 September 1998
;;;   
;;;----------------------------------------------------------------------------
;;;   DESCRIPTION
;;;----------------------------------------------------------------------------
;;;   C:MODATT 
;;;
;;;   This function allows the user to select a block containing
;;;   attributes and modify the layer those attributes are on. The 
;;;   program prompts for an old layer name and a new layer name. 
;;;   If an attribute is found within that block that is on the  
;;;   old layer then it is changed to the new layer. All other
;;;   entities are ignored.
;;;
;;;----------------------------------------------------------------------------

(defun c:modatt( / atvalue atname atlayer atcolor elist dcl_id nlist atcol)
 (setq fpick(car(entsel)))
 (setq elist(entget(entnext fpick)))
  (if (/= "ATTRIB" (cdr(assoc 0 elist)))
       (princ "\nEntity does not contain any editable attributes.")
      (progn 
       (setq conslist (1- 0))
       (while (/= "SEQEND" (cdr(assoc 0 elist)))
        (setq conslist (1+ conslist))
        (if (= "ATTRIB" (cdr(assoc 0 elist)))
            (progn
             (setq atcol (cdr (assoc 62 elist)))
             (if (not atcol)(setq atcol 256 ))
             (setq atname (append atname(list(cons conslist(cdr(assoc 2 elist))))))
             (setq atcolor (append atcolor(list(cons conslist (citocs atcol)))))
             (setq atlayer (append atlayer(list(cons conslist (cdr(assoc 8 elist))))))
             (setq atvalue (append atvalue(list(cons conslist (cdr(assoc 1 elist))))))
             (setq nlist (append nlist(list(cons conslist (cdr(assoc -1 elist))))))
            )
        )
        (setq elist (entget(entnext (cdr(assoc -1 elist)))))
       )
      )
  )
  (if atname (call_dialog))
  (princ)
)

(defun call_dialog( / ddl )
 (setq index 0)
 (setq dcl_id (load_dialog "modatt"))
 (new_dialog "modatt" dcl_id)
 (set_tile_values)
 (action_tile "next" "(edit_list)(setq index(1+ index))(set_tile_values)")
 (action_tile "prev" "(edit_list)(setq index(1- index))(set_tile_values)")
 (action_tile "ok" "(edit_list)(setq ddl 0)(done_dialog)")
 (action_tile "help" "(acad_helpdlg \"MODATT.ahp\" \"\")")
 (start_dialog)
 (if (= ddl 0)
     (modallats)
 )
)
(defun set_tile_values()
 (if (= index (-(length atvalue)1))
 (mode_tile "next" 1)
 (mode_tile "next" 0)
 )
 (if (< index 1)
 (mode_tile "prev" 1)
 (mode_tile "prev" 0)
 )
 (set_tile "value_edit" (cdr(assoc index atvalue)))
 (set_tile "layer_edit" (cdr(assoc index atlayer)))
 (set_tile "color_edit" (cdr(assoc index atcolor)))
 (set_tile "tag_edit" (cdr(assoc index atname)))
)
(defun modallats( /  ecolor etag elayer)
 (setq index1 0)
 (foreach n atvalue
  (setq nn (cdr n))
  (setq evalue (subst (cons 1 nn)(assoc 1(entget(cdr(assoc index1 nlist))))(entget(cdr(assoc index1 nlist)))))
  (if (/= nil (assoc 62 evalue))
      (setq ecolor (subst (cons 62 (cstoci(cdr(assoc index1 atcolor))))(assoc 62 evalue) evalue))
      (setq ecolor (append evalue (list(cons 62 (cstoci(cdr(assoc index1 atcolor)))))))
  )
  (setq testent ecolor)
  (setq etag (subst (cons 2 (cdr(assoc index1 atname)))(assoc 2 ecolor) ecolor))
  (setq elayer (subst (cons 8 (cdr(assoc index1 atlayer)))(assoc 8 etag) etag))
  (entmod elayer)
  (setq index1 (1+ index1))
 )
 (entupd fpick)
)
(defun edit_list( / va la co ta )
 (setq va (get_tile "value_edit" ))
 (setq la (strcase(get_tile "layer_edit" )))
 (setq co (strcase(get_tile "color_edit" )))
 (setq ta (get_tile "tag_edit" ))
 (setq atvalue (subst (cons index va)(assoc index atvalue) atvalue))
 (setq atcolor (subst (cons index co)(assoc index atcolor) atcolor))
 (setq atlayer (subst (cons index la)(assoc index atlayer) atlayer))
 (setq atname (subst (cons index ta)(assoc index atname) atname))
)
(defun cstoci( val )
 (cond
      ((= val "BYBLOCK")(setq colint 0))
      ((= val "BYLAYER")(setq colint 256))
      ((= val "RED")(setq colint 1))
      ((= val "YELLOW")(setq colint 2))
      ((= val "GREEN")(setq colint 3))
      ((= val "CYAN")(setq colint 4))
      ((= val "BLUE")(setq colint 5))
      ((= val "MAGENTA")(setq colint 6))
      ((= val "WHITE")(setq colint 7))
      ((= val "BLACK")(setq colint 8))
      ((= val "GRAY")(setq colint 9))
      ((= val nil)(setq colint 256))
      (T (setq colint (atoi val)))
 )
)
(defun citocs( val )
 (cond
      ((= val 0 )(setq colstr "BYBLOCK"))
      ((= val 256 )(setq colint "BYLAYER"))
      ((= val 1 )(setq colint "RED"))
      ((= val 2 )(setq colint "YELLOW"))
      ((= val 3 )(setq colint "GREEN"))
      ((= val 4 )(setq colint "CYAN"))
      ((= val 5 )(setq colint "BLUE"))
      ((= val 6 )(setq colint "MAGENTA"))
      ((= val 7 )(setq colint "WHITE"))
      ((= val 8 )(setq colint "BLACK"))
      ((= val 9 )(setq colint "GRAY"))
      ((= val nil )(setq colint "BYLAYER"))
      (T (setq colint (rtos 5 (fix val))))
 )
)
(princ "\n-- Modify Attribute Utility Ver 1.0 -- start command with --> MODATT")
(princ "\n-- Copyright (C) 1998 by K.E. Blackie ")
(princ)
