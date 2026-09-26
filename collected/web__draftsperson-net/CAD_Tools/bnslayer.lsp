;;;     BNSLAYER.LSP
;;;     Copyright (C) 1997 by Autodesk, Inc.
;;;
;;;     Created 2/21/97 by Dominic Panholzer
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
;;;  ----------------------------------------------------------------
;;;
;;;     This file contains a library of layer based routines. See individual
;;;     routines for descriptions.
;;;
;;;  External Functions:
;;;
;;;     INIT_BONUS_ERROR  --> AC_BONUS.LSP   Intializes bonus error routine
;;;     RESTORE_OLD_ERROR --> AC_BONUS.LSP   restores old error routine
;;;


; -------------------- ISOLATE LAYER FUNCTION --------------------
; Isolates selected object's layer by turning all other layers off
; ----------------------------------------------------------------

(Defun C:LAYISO (/ SS CNT LAY LAYLST VAL)

  (init_bonus_error 
    (list
      (list "cmdecho" 0
            "expert"  0
      )
      T     ;flag. True means use undo for error clean up.  
    );list  
  );init_bonus_error

  (if (not (setq SS (ssget "i")))
    (progn
      (prompt "\nSelect object(s) on the layer(s) to be ISOLATED: ")
      (setq SS (ssget))
    )
  )

  (if SS
    (progn

      (setq CNT 0)

      (while (setq LAY (ssname SS CNT))
        (setq LAY (cdr (assoc 8 (entget LAY))))
        (if (not (member LAY LAYLST))
          (setq LAYLST (cons LAY LAYLST))
        )
        (setq CNT (1+ CNT))
      )

      (if (member (getvar "CLAYER") LAYLST)
        (setq LAY (getvar "CLAYER"))
        (setvar "CLAYER" (setq LAY (last LAYLST)))
      )

      (command "_.-LAYER" "_OFF" "*" "_Y")
      (foreach VAL LAYLST (command "_ON" VAL))
      (command "")
      
      (if (= (length LAYLST) 1)
        (prompt (strcat "\nLayer " (car LAYLST) " has been isolated."))
        (prompt (strcat "\n" (itoa (length LAYLST)) " layers have been isolated. "
                        "Layer " LAY " is current."
                )
        )
      )
    )
  )

  (restore_old_error)

  (princ)
)

; -------------------- LAYER FREEZE FUNCTION ---------------------
; Freezes selected object's layer
; ----------------------------------------------------------------

(defun C:LAYFRZ ()
  (layproc "frz")
  (princ)
)

; ---------------------- LAYER OFF FUNCTION ----------------------
; Turns selected object's layer off
; ----------------------------------------------------------------

(defun C:LAYOFF ()
  (layproc "off")
  (princ)
)

; ------------- LAYER PROCESSOR FOR LAYOFF & LAYFRZ --------------
; Main program body for LAYOFF and LAYFRZ. Provides user with
; options for handling nested entities.
; ----------------------------------------------------------------

(defun LAYPROC ( TASK / NOEXIT OPT BLKLST CNT EN PMT ANS LAY NEST BLKLST)


; --------------------- Error initialization ---------------------

  (init_bonus_error 
    (list
      (list "cmdecho" 0
            "expert"  0
      )

      nil     ;flag. True means use undo for error clean up.  
    );list  
  );init_bonus_error

; -------------------- Variable initialization -------------------

  (setq NOEXIT T)

  (setq OPT (getcfg (strcat "AppData/AC_Bonus/Lay" TASK)))    ; get default option setting
  (if (not (or (null OPT) (= OPT ""))) (setq OPT (atoi OPT)))

  (setq CNT 0)                                                ; cycle counter


  (while NOEXIT

    (initget "Options Undo")
    (if (= TASK "off")
      (setq EN (nentsel "\nOptions/Undo/<Pick an object on the layer to be turned OFF>: "))
      (setq EN (nentsel "\nOptions/Undo/<Pick an object on the layer to be FROZEN>: "))
    )

; ------------------------- Set Options --------------------------

    (While (= EN "Options")
      (initget "No Block Entity")
      (cond
        ((= OPT 1)
          (setq PMT "\nBlock level nesting/Entity level nesting/<No nesting>: ")
        )
        ((= OPT 2)
          (setq PMT "\nBlock level nesting/No nesting/<Entity level nesting>: ")
        )
        (T
          (setq PMT "\nEntity level nesting/No nesting/<Block level nesting>: ")
        )
      )
      (setq ANS (getkword PMT))

      (cond
        ((null ANS)
          (if (or (null OPT) (= OPT ""))
            (progn
              (print ANS)
              (setq OPT 3)
              (setcfg (strcat "AppData/AC_Bonus/Lay" TASK) "3")
            )
          )
        )
        ((= ANS "No")
          (setq OPT 1)
          (setcfg (strcat "AppData/AC_Bonus/Lay" TASK) "1")
        )
        ((= ANS "Entity")
          (setq OPT 2)
          (setcfg (strcat "AppData/AC_Bonus/Lay" TASK) "2")
        )
        (T
          (setq OPT 3)
          (setcfg (strcat "AppData/AC_Bonus/Lay" TASK) "3")
        )
      )

      (initget "Options")
      (if (= TASK "off")
        (setq EN (nentsel "\nOptions/Undo/<Pick an object on the layer to be turned OFF>: "))
        (setq EN (nentsel "\nOptions/Undo/<Pick an object on the layer to be FROZEN>: "))
      )
    )

; ------------------------- Find Layer ---------------------------

    (if (and EN (not (= EN "Undo")))
      (progn

        (setq BLKLST (last EN))
        (setq NEST (length BLKLST))

        (cond

      ; If the entity is not nested or if the option for entity
      ; level nesting is selected.
    
          ((or (= OPT 2) (< (length EN) 3))
            (setq LAY (entget (car EN)))
          )
  
      ; If no nesting is desired

          ((= OPT 1)
            (setq LAY (entget (car (reverse BLKLST))))
          )

      ; All other cases (default)

          (T
            (setq BLKLST (reverse BLKLST))
            
            (while (and                         ; strip out xrefs
                ( > (length BLKLST) 0)
                (assoc 1 (tblsearch "BLOCK" (cdr (assoc 2 (entget (car BLKLST))))))
                   );and
              (setq BLKLST (cdr BLKLST))
            )
            (if ( > (length BLKLST) 0)          ; if there is a block present
              (setq LAY (entget (car BLKLST)))  ; use block layer
              (setq LAY (entget (car EN)))      ; else use layer of nensel
            )
          )
        )

; ------------------------ Process Layer -------------------------

        (setq LAY (cdr (assoc 8 LAY)))
  
        (if (= LAY (getvar "CLAYER"))
          (if (= TASK "off")
            (progn
              (prompt (strcat "\nReally want layer " LAY " (the CURRENT layer) off? <N>: "))
              (setq ANS (strcase (getstring)))
              (if (not (or (= ANS "Y") (= ANS "YES")))
                (setq LAY nil)
              )
            )
            (progn
              (prompt (strcat "\nCannot freeze layer " LAY".  It is the CURRENT layer."))
              (setq LAY nil)
            )
          )
          (setq ANS nil)
        )
  
        (if LAY
          (if (= TASK "off")
            (progn
              (if ANS
                (command "_.-LAYER" "_OFF" LAY "_Yes" "")
                (command "_.-LAYER" "_OFF" LAY "")
              )
              (prompt (strcat "\nLayer " LAY " has been turned off."))
              (setq CNT (1+ CNT))
            )
            (progn
              (command "_.-LAYER" "_FREEZE" LAY "")
              (prompt (strcat "\nLayer " LAY " has been frozen."))
              (setq CNT (1+ CNT))
            )
          )
        )
      )

; -------------- Nothing selected or Undo selected ---------------

      (progn
        (if (= EN "Undo")
          (if (> CNT 0)
            (progn
              (command "_.u")
              (setq CNT (1- CNT))
            )
            (prompt "\nEverything has been undone.")
          )
          (setq NOEXIT nil)
        )
      )
    )
  )

  (restore_old_error)

)

; --------------------- LAYER LOCK FUNCTION ----------------------
; Locks selected object's layer
; ----------------------------------------------------------------

(Defun C:LAYLCK (/ LAY)

  (init_bonus_error 
    (list
      (list "cmdecho" 0
            "expert"  0
      )

      T     ;flag. True means use undo for error clean up.  
    );list  
  );init_bonus_error

  (setq LAY (entsel "\nPick an object on the layer to be LOCKED: "))

  (if LAY
    (progn
      (setq LAY (cdr (assoc 8 (entget (car LAY)))))
      (Command "_.-LAYER" "_LOCK" LAY "")
      (prompt (strcat "\nLayer " LAY " has been locked."))
    )
  )

  (restore_old_error)

  (princ)
)

; -------------------- LAYER UNLOCK FUNCTION ---------------------
; Unlocks selected object's layer
; ----------------------------------------------------------------

(Defun C:LAYULK (/ LAY)

  (init_bonus_error 
    (list
      (list "cmdecho" 0
            "expert"  0
      )

      T     ;flag. True means use undo for error clean up.  
    );list  
  );init_bonus_error

  (setq LAY (entsel "\nPick an object on the layer to be UNLOCKED: "))

  (if LAY
    (progn
      (setq LAY (cdr (assoc 8 (entget (car LAY)))))
      (Command "_.-LAYER" "_UNLOCK" LAY "")
      (prompt (strcat "\nLayer " LAY " has been unlocked."))
    )
  )

  (restore_old_error)

  (princ)
)

; ---------------------- LAYER ON FUNCTION -----------------------
; Turns all layers on
; ----------------------------------------------------------------

(Defun C:LAYON ()

  (init_bonus_error 
    (list
      (list "cmdecho" 0)
      nil     ;flag. True means use undo for error clean up.  
    );list  
  );init_bonus_error

  (Command "_.-LAYER" "_ON" "*" "")
  (prompt "\nAll layers have been turned on.")

  (restore_old_error)

  (princ)
)


; --------------------- LAYER THAW FUNCTION ----------------------
; Thaws all layers 
; ----------------------------------------------------------------

(Defun C:LAYTHW ()

  (init_bonus_error 
    (list
      (list "cmdecho" 0)
      nil     ;flag. True means use undo for error clean up.  
    );list  
  );init_bonus_error

  (Command "_.-LAYER" "_THAW" "*" "")
  (prompt "\nAll layers have been thawed.")

  (restore_old_error)

  (princ)
)


; --------------------- LAYER MATCH FUNCTION ---------------------
; Changes the layer of selected object(s) to the layer of a
; selected destination object.
; ----------------------------------------------------------------

(Defun C:LAYMCH (/ SS CNT LOOP LAY ANS)

  (init_bonus_error 
    (list
      (list "cmdecho" 0)
      T     ;flag. True means use undo for error clean up.  
    );list  
  );init_bonus_error


  (if (not (setq SS (ssget "i")))
    (progn
      (prompt "\nSelect objects to be changed: ")
      (setq SS (ssget))
    )
  )

  (if SS
    (progn
      (setq CNT (sslength SS))
      (princ (strcat "\n" (itoa CNT) " found."))      ; Report number of items found

      (command "_.move" SS "")                         ; filter out objects on locked layers

      (if (> (getvar "cmdactive") 0)                   ; if there are still objects left
        (progn
          (command "0,0" "0,0")
          (setq SS  (ssget "p")
                CNT (- CNT (sslength SS))              ; count them
          )
        )
        (setq SS nil)                                  ; else abort operation
      ) 

      (if (> CNT 0)                                    ; if items where filtered out
        (if (= CNT 1)
          (princ (strcat "\n" (itoa CNT) " was on a locked layer."))   ; report it.
          (princ (strcat "\n" (itoa CNT) " were on a locked layer."))
        )
      )
    )
  )


  (if SS
    (progn
      (initget "Type")
      (setq LAY  (entsel "\nType name/Select entity on destination layer: ")
            LOOP T
      )
      
      (while LOOP
        (cond
          ((not LAY)
            (prompt "\nNothing selected.")
            (prompt "\nUse current layer? <Y> ")
            (setq ANS (strcase (getstring)))
            (if (or (= ANS "") (= ANS "Y") (= ANS "YES"))
              (setq LAY  (getvar "clayer")
                    LOOP nil
              )
            )
          )
          ((listp LAY)
            (setq LOOP nil)
          )
          ((= LAY "Type")
            (setq LAY (getstring "\nEnter layer name: "))
            (cond
              ((tblobjname "LAYER" LAY)
                (setq LOOP nil)
              )
              ((/= LAY "")
                (prompt "\nLayer does not exist. Would you like to create it? <Y>: ")
                (setq ANS (strcase (getstring)))
                (if (or (= ANS "") (= ANS "Y") (= ANS "YES"))
                  (if
                    (entmake (list
                              '(0 . "LAYER")
                              '(100 . "AcDbSymbolTableRecord")
                              '(100 . "AcDbLayerTableRecord")
                              '(6 . "CONTINUOUS")
                              '(62 . 7)
                              '(70 . 0)
                               (cons 2 LAY)
                             )
                    )
                    (setq LOOP nil)
                    (prompt "\nInvalid Layer name.")
                  )
                )
              )
            )
          )
        )
        (if LOOP
          (progn
            (initget "Type")
            (setq LAY (entsel "\nType name/Select entity on destination layer: "))
          )
        )
      ); while LOOP
        

      (if (listp LAY)
        (setq LAY (cdr (assoc 8 (entget (car LAY)))))
      )

      (command "_.change" SS "" "_p" "_la" LAY "")

      (if (= (sslength SS) 1)
        (prompt (strcat "\nOne object changed to layer " LAY ))
        (prompt (strcat "\n" (itoa (sslength SS)) " objects changed to layer " LAY ))
      )
      (if (= LAY (getvar "clayer"))
        (prompt " (the current layer).")
        (prompt ".")
      )
    )
  )

  (restore_old_error)

  (princ)
)

; --------------- CHANGE TO CURRENT LAYER FUNCTION ---------------
; Changes the layer of selected object(s) to the current layer
; ----------------------------------------------------------------

(Defun C:LAYCUR (/ SS CNT LAY)

  (init_bonus_error 
    (list
      (list "cmdecho" 0)
      T     ;flag. True means use undo for error clean up.  
    );list  
  );init_bonus_error


  (if (not (setq SS (ssget "i")))
    (progn
      (prompt "\nSelect objects to be CHANGED to the current layer: ")
      (setq SS (ssget))
    )
  )

  (if SS
    (progn
      (setq CNT (sslength SS))
      (princ (strcat "\n" (itoa CNT) " found."))      ; Report number of items found

      (command "_.move" SS "")                         ; filter out objects on locked layers

      (if (> (getvar "cmdactive") 0)                   ; if there are still objects left
        (progn
          (command "0,0" "0,0")
          (setq SS  (ssget "p")
                CNT (- CNT (sslength SS))              ; count them
          )
        )
        (setq SS nil)                                  ; else abort operation
      ) 

      (if (> CNT 0)                                    ; if items where filtered out
        (if (= CNT 1)
          (princ (strcat "\n" (itoa CNT) " was on a locked layer."))   ; report it.
          (princ (strcat "\n" (itoa CNT) " were on a locked layer."))
        )
      )
    )
  )

  (if SS
    (progn
      (setq LAY (getvar "CLAYER"))
      (command "_.change" SS "" "_p" "_la" LAY "")
      (if (= (sslength SS) 1)
        (prompt (strcat "\nOne object changed to layer " LAY " (the current layer)."))
        (prompt (strcat "\n" (itoa (sslength SS)) " objects changed to layer " LAY " (the current layer)."))
      )
    )
  )

  (restore_old_error)

  (princ)
)

(prompt "\nAutoCAD Bonus Layer Tools Loaded.")
(princ)
