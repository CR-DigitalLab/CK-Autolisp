;; ====================================================== 
;; Dimension Note - add a modifier note to an existing
;;                  associative dimension string.
;; 
;; Copyright 1999, Mike Lapinski
;;
;; Permission to use, copy, modify, and distribute this software
;; for any purpose and without fee is hereby granted, provided
;; that the above copyright notice appears in all copies and
;; that both that copyright notice and the limited warranty 
;; notice below appear in all supporting documentation.
;; 
;; D I S C L A I M E R   O F   W A R R A N T Y
;; ======================================================
;;
;; THIS PROGRAM IS MADE AVAILABLE ON AN "AS IS" BASIS WITHOUT 
;; WARRANTIES AS TO PERFORMANCE OF MERCHANTABILITY OR ANY 
;; OTHER WARRANTIES WHETHER EXPRESSED OR IMPLIED. I DO NOT 
;; WARRANT THAT THE OPERATION OF THE PROGRAM WILL BE
;; UNINTERRUPTED OR ERROR FREE.
;;
;; I SHALL UNDER NO CIRCUMSTANCE BE LIABLE FOR ANY DAMAGES, 
;; INCLUDING BUT NOT LIMITED TO; LOSS OF PROFITS, LOSS OF TIME, 
;; LOSS OF DATA OR BUSINESS INTERRUPTION RESULTING FROM THE USE 
;; OF THE INABILITY TO USE THIS SOFTWARE. THE USER MUST ASSUME 
;; THE ENTIRE RISK OF USING THE PROGRAM.
;;
;; C O P Y R I G H T   N O T I C E   A N D   T R A D E M A R K S
;; =============================================================
;;
;; This program is copyrighted with all rights reserved by 
;; Michael Lapinski. This program is for "PUBLIC DOMAIN" use 
;; and may not be marketed or offered for sale to others.
;;
;;======================================================
;; Function: DN_ShowNote
;; Purpose:  Show note selected from ListBox in EditBox
;;======================================================
(defun DN_ShowNote (/ lnum lnote)
(set_tile "error" "")
(setq lnum  (get_tile "lb_notes")
      lnote (nth (atoi lnum) dm_notes)
)
(set_tile "eb_note" lnote)
(princ)
)
;;======================================================
;; Function: DN_PlaceNote
;; Purpose:  If valid note is input, close dialog box 
;;======================================================
(defun DN_PlaceNote ()
(set_tile "error" "")
(setq dn_modifier (strcase (get_tile "eb_note")))
(if (= dn_modifier " ")
    (set_tile "error" "Invalid note string")
    (done_dialog 1)
)    
)
;;======================================================
;; Function: DN_AppendNote
;; Purpose:  Append note to selected dimension entity
;;======================================================
(defun DN_AppendDim (val placement / ent dval)
(setq ent (car (entsel "\nSelect dimension for note: " )))
(while (/= "DIMENSION" (cdr (assoc 0 (entget ent))))
       (princ "\nSelected entity is not a DIMENSION.")
       (setq ent (car (entsel "\nSelect dimension for note: ")))
);while
(setq ent  (entget ent)
      dval (cdr (assoc 1 ent))
)
(if (= dval "")
    (setq dval "<>")
)
(if (= placement 1) ;above line
     (setq val (strcat dval " " val))
     (progn
      (if (wcmatch dval "*\\X*")
          (setq val (strcat dval "\\P" val))
          (setq val (strcat dval "\\X" val))
      )
     )     
) 
(entmod (subst (cons 1 val)(assoc 1 ent) ent))
(princ)
)
;;======================================================
;; Main Function - Dimension NOTE
;;======================================================
(defun C:DNOTE (/ dcl_id dm_notes dn_above)
(setq dcl_id (load_dialog "dimnote.dcl"))
(if (not (new_dialog "dimnote" dcl_id))(exit))
(setq dm_notes '("CLR." "CLEAR" "M.O." "MIN." "MAX." 
                 "REF." "R.O." "TYP." "TYPICAL" "V.I.F."
                 "VERIFY IN FIELD"
                ) 
      dn_above   0
)
(set_tile "eb_note" "TYP.")
(set_tile "dn_below" "1") ; Set as default
(start_list "lb_notes")   
(mapcar 'add_list dm_notes)  
(end_list)
(set_tile "lb_notes" "7")
(action_tile "lb_notes" "(DN_ShowNote)")
(action_tile "dn_above" "(setq dn_above 1)")
(action_tile "dn_below" "(setq dn_above 0)")
(action_tile "accept" "(DN_PlaceNote)")
(action_tile "cancel" "(done_dialog 0)")
(if (eq (start_dialog) 1)
    (DN_AppendDim dn_modifier dn_above)
)
(unload_dialog dcl_id)
(princ)
)
(princ "\nDNOTE Loaded...")
(princ)
