;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; File:    DDIMFIT.LSP
;; Created: Aug. 98
;; Author:  Herman Mayfarth
;; Purpose: Change DIMFIT value for a selection set 
;; Version: 1.0
;; Uses:    DDIMFIT.DCL
;; Local Symbols:
;;                   dd1 : dialog pointer
;;                 dlgst : dialog return status
;;                   tag : value of DIMFIT passed to modify_dims
;; Local Functions:
;;          dcl_load_chk : function to check dcl load
;;          dlg_load_chk : function to check dialog initialize
;;          modify_dims  : function to change value of dimfit
;; Returns: nil
;;-----------------------------------------------------------------------
;;Copyright (c) 1998 by Herman Mayfarth
;;Program provided "as is" and with all faults. No warranty of any kind.
;;License hereby granted to freely use and redistribute without fee.
;;-----------------------------------------------------------------------
   (defun C:DDIMFIT ( / dd1 dlgst tag 
                        dcl_load_chk dlg_load_chk modify_dims)
;;------------------------------------------------------------------------
;; Local Function :  dcl_load_chk
;; Purpose  :  exit abnormal if dcl cannot load
;; Args     :  DL :  dcl file handle           
;;-------------------------------------------------------------------------                                                
   (defun dcl_load_chk (DL)                    
      (if (minusp DL) 
            ((alert "Unable to Load .DCL File") 
             (exit)
            )
      )
   (princ)
   ); end dcl_load_chk
;;------------------------------------------------------------------------
;; Local Function :  dlg_load_chk
;;       Purpose  :  exit abnormal if dialog cannot load
;;       Args     :  dlg : dialog name
;;       Uses     :  dd1 : dialog pointer
;;-------------------------------------------------------------------------
  (defun dlg_load_chk (dlg / )
      (if (not (new_dialog dlg dd1)) 
         ((alert (strcat "Unable to Initialize" dlg " dialog"))
          (exit)
         )
      )
  );end dlg_load_chk
;;------------------------------------------------------------------------- 
;; Local Function  : modify_dims
;;       Purpose   : changes DIMFIT value of selection set
;;       Args      :  tag :  integer specifies new value of DIMFIT
;;       Locals    :  ss1 :  picked selection set of dimensions
;;       Returns   :  nil
;;----------------------------------------------------------------------
(defun modify_dims (tag / ss1)
  (princ "\nSelect dimensions to change.")
  (setq ss1 (ssget  '((0 . "DIMENSION"))))
  (command "_.DIMOVERRIDE"  "DIMFIT" tag "" ss1 "")
);modify_dims
;;----------------------------------------------------------------------
;; Main Program

;initialize file scope variables  
      (setq tag 0)
;load dialog file
      (setq dd1 (load_dialog "ddimfit.dcl"))
      (dcl_load_chk dd1)
;initialize main dialog
     (dlg_load_chk "dimfit")
;define tile actions
      (action_tile "one"    "(setq tag 1) (done_dialog 2)")
      (action_tile "two"    "(setq tag 2) (done_dialog 2)")
      (action_tile "three"  "(setq tag 3) (done_dialog 2)")
      (action_tile "four"   "(setq tag 4) (done_dialog 2)")
      (action_tile "five"   "(setq tag 5) (done_dialog 2)")
      (action_tile "accept" "(done_dialog 1)")
      (setq dlgst (start_dialog))
      (cond
        ((= dlgst 2)
           (modify_dims tag)
        )
      );cond
      
      (unload_dialog dd1)
      (princ "\nDialog Unloaded.")
      (princ)
   ); end C:DDIMFIT
;;------------------------------------------------------------------------
;; load prompts
   (princ "\nDDIMFIT (c) 1998 Herman Mayfarth")
   ;(princ "\nType DDIMFIT to run..")
   (princ)
;;; end file
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

