;*************************************************************************
;
;  DTWALL.LSP           Copyright (c) 1994 - DesignTec
;  Version 1.0                               255 Celia St.
;                                            Boaz, AL 35957
;                                            (205) 593-7789
;
;  LAST REVISION:  8-17-94
;
;  for Palm Harbor Homes - Boaz Plant - Robert Denardo, Plant Engineer
;
;  Permission to use, copy, modify, and distribute this software
;  for any purpose and without fee is hereby granted, provided
;  that the above copyright notice appears in all copies and that
;  both that copyright notice and this permission notice appear in
;  all supporting documentation.
;
;  THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT EXPRESSED OR IMPLIED
;  WARRANTY.  ALL IMPLIED WARRANTIES OF FITNESS FOR ANY PARTICULAR
;  PURPOSE AND OF MERCHANTABILITY ARE HEREBY DISCLAIMED.
;
;*************************************************************************
;
;  DESCRIPTION
;
;
;*************************************************************************
;
;  ACCOMPANYMENTS
;
;
;*************************************************************************

;;
;;
;;

(defun init_stuff ()

(setq what_next 8)

;;  This routine creates a list for the "Wall Names" list box.  
  
  (if (= nil (setq WALL_LIST (ai_table "block" 2)))
    (setq WALL_LIST (list "New-Wall..."))
  )
      
;;  This function makes sure that the layers FP, W1, W2, W3, W4, and W5
;;  exist, then freezes all but the appropriate floor plan (FP) layers.
;;  If any of the above layers don't exist, this routine creates them.     

    (if (= nil (tblsearch "layer" "fp"))
          (command "layer" "m" "fp" "c" "7" "" "")
    )
    (if (= nil (tblsearch "layer" "w1"))
          (command "layer" "m" "w1" "c" "7" "" "")
    )   
    (if (= nil (tblsearch "layer" "w2"))
          (command "layer" "m" "w2" "c" "7" "" "")
    )   
    (if (= nil (tblsearch "layer" "w3"))
          (command "layer" "m" "w3" "c" "7" "" "")
    )   
    (if (= nil (tblsearch "layer" "w4"))
          (command "layer" "m" "w4" "c" "7" "" "")
    )   
    (if (= nil (tblsearch "layer" "w5"))
          (command "layer" "m" "w5" "c" "7" "" "")
    )
    (command "layer" "u" "*" "t" "fp" "s" "fp" "f" "*"
      "t" "fpd,fr,opt,pw,tb,xx" "")
)

;;
;;
;;

(defun tile_setup ()
  
 (start_list "wall_fram")
 (mapcar 'add_list WALL_LIST)
 (end_list)
 (set_tile "wall_fram" wall_fram)

)

;;
;;

(defun rs_error ()
  (set_tile "error" "")
)
;;
;;
;;

(defun create_init_stuf ()
  (setq what_next1 13)
)

(defun create_wall ()
  (create_init_stuf)
  (new_dialog "CREATE_WALL" DCL_ID)
  (create_tile_setup)
  (create_get_actions)
  (if (= what_next1 1) (start_dialog))
)

(defun create_tile_setup ()
  (setq WALL_TYPE_LIST (list "Perpendicular to Ext. Wall" "Parallel to Ext. Wall" "At an Angle to Ext. Wall"))

)

(defun create_get_actions ()
  (action_tile "wall_name" "(setq WALL_NAME $value)")
  (action_tile "wall_type" "(setq WALL_TYPE $value)")
  (action_tile "pick_pnt1" "(done_dialog 9)")
  (action_tile "pick_pnt2" "(done_dialog 10)")
  (action_tile "pick_pnt3" "(done_dialog 11)")
  (action_tile "side_wall" "(done_dialog 12)")
  (action_tile "new_layer" "(setq NEW_LAYER $value)")
  (action_tile "pnt1_x" "(rs_error) (setq PNT1_X $value)")
  (action_tile "pnt1_y" "(rs_error) (setq PNT1_Y $value)")
  (action_tile "pnt2_x" "(rs_error) (setq PNT2_X $value)")
  (action_tile "pnt2_y" "(rs_error) (setq PNT2_Y $value)")
  (action_tile "pnt3_x" "(rs_error) (setq PNT3_X $value)")
  (action_tile "pnt3_y" "(rs_error) (setq PNT3_Y $value)")

  (setq what_next1 (start_dialog))
  (cond
    ((= what_next1 9)
      (setq PNT1 (getpoint "\nPlease pick point #1 :"))
    )
    ((= what_next1 10)
      (setq PNT2 (getpoint "\nPlease pick point #2 :"))
    )
    ((= what_next1 11)
      (setq PNT3 (getpoint "\nPlease pick point #3 :"))
    )
    ((= what_next1 12)
      (setq SIDE_WALL (car (entsel "\nPlease select the inside face
         of the Ext. Wall :")))
    )
  )
)  
     
;;
;;
;;

(defun get_actions ()
  (action_tile "wall_fram" "(rs_error)(setq WALL_NAME $value)")
  (action_tile "create" "(create_wall)")
  (action_tile "delete" "(done_dialog)")
  (action_tile "chng_lyr" "(done_dialog)")
  (action_tile "move" "(done_dialog)")
  (action_tile "fp" "(done_dialog 2)")
  (action_tile "w1" "(done_dialog 3)")
  (action_tile "w2" "(done_dialog 4)")
  (action_tile "w3" "(done_dialog 5)")
  (action_tile "w4" "(done_dialog 6)")    
  (action_tile "w5" "(done_dialog 7)")
 
  (setq what_next (start_dialog))
  (cond
    ((= 2 what_next)
      (command "layer" "u" "*" "t" "fp" "s" "fp" "f" "*"
      "t" "fpd,fr,opt,pw,tb,xx" "")
    )
    ((= 3 what_next)
      (command "layer" "u" "*" "t" "w1" "s" "w1" "f" "*" "")
    )
    ((= 4 what_next)
      (command "layer" "u" "*" "t" "w2" "s" "w2" "f" "*" "") 
    )
    ((= 5 what_next)
      (command "layer" "u" "*" "t" "w3" "s" "w3" "f" "*" "")
    )
    ((= 6 what_next)
      (command "layer" "u" "*" "t" "w4" "s" "w4" "f" "*" "")
    )
    ((= 7 what_next)
      (command "layer" "u" "*" "t" "w5" "s" "w5" "f" "*" "")
    )
  )
)    

;;
;;	MAIN ROUTINE
;;

(defun C:WALL_MAIN ()
  (init_stuff)
  (while (> what_next 1)
    (setq DCL_ID (load_dialog "DTWALL.DCL"))
    (if (not (new_dialog "DTWALL" DCL_ID)) (exit))
;    (tile_setup)
    (get_actions)
  )  
  (if (= 1 what_next) (start_dialog))
  (unload_dialog DCL_ID)
)

;;; END OF CODE
