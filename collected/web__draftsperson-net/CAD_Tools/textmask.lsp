;;;     TEXTMASK.LSP
;;;     Copyright (C) 1997 by Autodesk, Inc.
;;;
;;;     Created 3/12/97 by Dominic Panholzer
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
;;;     TEXTMASK works in conjunction with WIPEOUT.ARX to hide all
;;;     entities behind the selected text or mtext. The text object
;;;     is then grouped together with the wipeout object such that
;;;     they move, copy, erase, etc. together. To update after editing
;;;     text, run TEXTMASK again and select the text item to be updated.
;;;     The the previous wipeout object will be erased and a new one
;;;     will be created.
;;;     
;;;
;;;
;;;  External Functions:
;;;
;;;     INIT_BONUS_ERROR  --> AC_BONUS.LSP   Intializes bonus error routine
;;;     RESTORE_OLD_ERROR --> AC_BONUS.LSP   Restores old error routine
;;;     B_LAYER_LOCKED    --> AC_BONUS.LSP   Checks to see if layer is locked
;;;     UCS_2_ENT         --> AC_BONUS.LSP   sets current ucs to extrusion vector 
;;;

(defun c:textmask ( / grplst getgname getgmem ucs_2_mtext makgrp mtextbox drawbox
                      WIPOUT CNT GLST OSET TMP SS ENT PNTLST ZM LOCKED GDICT 
                      GNAM GRP MLST TXT TOS TXTLAY TXLCK
                  )

; --------------------- Error initialization ---------------------

  (init_bonus_error 
    (list
      (list "cmdecho"   0
            "plinewid"  0
            "highlight" 1
            "osmode"    0
            "clayer"    (getvar "clayer")
      )
      
      T     ;flag. True means use undo for error clean up.  
      
    );list  
  );init_bonus_error

; --------------------- GROUP LIST FUNCTION ----------------------
;   This function will return a list of all the group names in the
;   drawing and their entity names in the form:
;   (<ename of "ACAD_GROUP"> (<ename1> . <name1>) (<ename2> . <name2>))
; ----------------------------------------------------------------

  (defun grplst (/ GRP MSTR ITM NAM ENT GLST)

    (setq GRP  (dictsearch (namedobjdict) "ACAD_GROUP"))
    (while (setq ITM (car GRP))       ; While edata item is available
      (if (= (car ITM) 3)             ; if the item is a group name
        (setq NAM (cdr ITM)           ; get the name
              GRP (cdr GRP)           ; shorten the edata
              ITM (car GRP)           ; get the next item
              ENT (cdr ITM)           ; which is the ename
              GRP (cdr GRP)           ; shorten the edata
              GLST                    ; store the ename and name
                  (if GLST
                    (append GLST (list (cons ENT NAM)))
                    (list (cons ENT NAM))
                  )
        )
        (setq GRP (cdr GRP))          ; else shorten the edata
      )
    )
    GLST                              ; return the list
  )

; ------------------- GET GROUP NAME FUNCTION --------------------
;   This function returns a list of all the group names in GLST
;   where ENT is a member. The list has the same form as GLST
; ----------------------------------------------------------------

  (defun getgname (ENT GLST / MSTR GRP GDATA ITM NAM NLST)
    (if (and GLST (listp GLST))
      (progn
        (foreach GRP GLST
          (setq GDATA (entget (car GRP)))
          (foreach ITM GDATA                   ; step through the edata
            (if (and
                  (= (car ITM) 340)            ; if the item is a entity name
                  (eq (setq NAM (cdr ITM)) ENT) ; and the ename being looked for
                )
              (setq NLST                       ; store the ename and name
                      (if NLST
                        (append NLST (list (cons (car GRP) (cdr GRP))))
                        (list (cons (car GRP) (cdr GRP)))
                      )
              )
            )
          )
        )
      )
    )
    NLST
  )

; --------------------- GROUP MEMBER FUNCTION ----------------------
;   This function returns a list of all the entity names of the
;   members of group GNAM. GNAM is a list (<ename1> . <name1>).
; ----------------------------------------------------------------

  (defun getgmem (GNAM / GRP GDATA ITM NLST)

    (if GNAM
      (progn
        (setq GDATA (entget (car GNAM)))
        (foreach ITM GDATA                    ; step through the edata
          (if (= (car ITM) 340)               ; if the item is a entity name
            (setq NLST  (cons (cdr ITM) NLST) ; store the ename
            )
          )
        )
      )
    )
    NLST
  )

; ---------------------- MAKGROUP FUNCTION -----------------------
;   This will create a selectable unnamed group using the entities 
;   in the list LST, and give it the description DESC. 
; ----------------------------------------------------------------

  (defun makgrp (LST DESC / NAM EN LST GDICT GDATA)
    (setq NAM (strcat "ZZ_BNS" (substr (rtos (getvar "CDATE") 2 8) 10)))
    (command "_.-group" "_create" NAM DESC)
    (foreach EN LST (command EN))
    (command "")
    (setq GDICT (dictsearch (namedobjdict) "ACAD_GROUP")
          GDATA (dictsearch (cdr (assoc -1 GDICT)) NAM)
          GDATA (subst (cons 70 1) (assoc 70 GDATA) GDATA)
    )
    (dictrename (cdr (assoc -1 GDICT)) NAM "*A")
    (entmod GDATA)
  )

; ------------------- SET MTEXT UCS FUNCTION ---------------------
;   AutoCAD does not accept mtext as a valid object for setting
;   the ucs. This function will set the current ucs to the 
;   mtext entity name ENT.
; ----------------------------------------------------------------

  (defun ucs_2_mtext (ENT / PT)

    (setq PT (cdr (assoc 210 (entget ENT)))
          PT (strcat "*"
               (rtos (car PT) 2 8) ","
               (rtos (cadr PT) 2 8) ","
               (rtos (caddr PT) 2 8)
             );strcat
    );setq
    (command "_.ucs" "_za" "*0.0,0.0,0.0" PT)
    (command "_.ucs" "_or" (trans (cdr (assoc 10 (entget ENT))) 0 1))
  )


; --------------------- MTEXTBOX FUNCTION ------------------------
;   This function returns a list of four points describing the 
;   bounding box of the mtext (MTXT).
; ----------------------------------------------------------------

  (defun mtextbox (MTXT / WDTH HGHT INS JUST ANG P1 P2 P3 P4)
    (if (and (listp MTXT) (= "MTEXT" (cdr (assoc 0 MTXT))))
      (progn
        (setq WDTH (cdr (assoc 42 MTXT))
              HGHT (cdr (assoc 43 MTXT))
              INS  (trans (cdr (assoc 10 MTXT)) 0 1)
              JUST (cdr (assoc 71 MTXT))
              ANG  (cdr (assoc 50 MTXT))
        )
        (cond
          ((= JUST 1)
            (setq P1 (polar INS (- ANG (* Pi 0.5)) HGHT) ; lower-left
                  P2 (polar P1 ANG WDTH)                 ; lower-right
                  P3 (polar INS ANG WDTH)                ; upper-right
                  p4 INS                                 ; upper-left
            )
          )
          ((= JUST 2)
            (setq P3 (polar INS ANG (/ WDTH 2))
                  P4 (polar INS (+ ANG Pi) (/ WDTH 2))
                  P1 (polar P4 (- ANG (* Pi 0.5)) HGHT)
                  P2 (polar P1 ANG WDTH)
            )
          )
          ((= JUST 3)
            (setq P3 INS
                  P4 (polar INS (+ ANG Pi) WDTH)
                  P1 (polar P4 (- ANG (* Pi 0.5)) HGHT)
                  P2 (polar P1 ANG WDTH)
            )
          )
          ((= JUST 4)
            (setq P4 (polar INS (+ ANG (* Pi 0.5)) (/ HGHT 2))
                  P3 (polar P4 ANG WDTH)
                  P1 (polar P4 (- ANG (* Pi 0.5)) HGHT)
                  P2 (polar P1 ANG WDTH)
            )
          )
          ((= JUST 5)
            (setq P4 (polar INS (- ANG Pi) (/ WDTH 2))
                  P4 (polar P4 (+ ANG (* Pi 0.5)) (/ HGHT 2))
                  P3 (polar P4 ANG WDTH)
                  P1 (polar P4 (- ANG (* Pi 0.5)) HGHT)
                  P2 (polar P1 ANG WDTH)
            )
          )
          ((= JUST 6)
            (setq P3 (polar INS (+ ANG (* Pi 0.5)) (/ HGHT 2))
                  P4 (polar P3 (+ ANG Pi) WDTH)
                  P1 (polar P4 (- ANG (* Pi 0.5)) HGHT)
                  P2 (polar P1 ANG WDTH)
            )
          )
          ((= JUST 7)
            (setq P1 INS
                  P2 (polar P1 ANG WDTH)
                  P3 (polar P2 (+ ANG (* Pi 0.5)) HGHT)
                  P4 (polar P1 (+ ANG (* Pi 0.5)) HGHT)
            )
          )
          ((= JUST 8)
            (setq P1 (polar INS (+ ANG Pi) (/ WDTH 2))
                  P2 (polar P1 ANG WDTH)
                  P3 (polar P2 (+ ANG (* Pi 0.5)) HGHT)
                  P4 (polar P1 (+ ANG (* Pi 0.5)) HGHT)
            )
          )
          ((= JUST 9)
            (setq P2 INS
                  P1 (polar INS (+ ANG Pi) WDTH)
                  P3 (polar P2 (+ ANG (* Pi 0.5)) HGHT)
                  P4 (polar P1 (+ ANG (* Pi 0.5)) HGHT)
            )
          )
        )
      )
      (prompt "\nEntity Not Mtext!")
    )
    (list P1 P2 P3 P4)
  )


; ---------------------- DRAWBOX FUNCTION ------------------------
;   Function to draw the pline bounding box with the specified
;   offset (DIST) around text or mtext (TXT).    
; ----------------------------------------------------------------


  (defun drawbox (TXT DIST / TBX PT ORGBND)

    (if (= TXTYP "TEXT")
      (progn
        (setq TBX (textbox TXT))    ; normal text
        (command "_.pline" (car TBX) (list (caadr TBX)(cadar TBX))
                 (cadr TBX) (list (caar TBX)(cadadr TBX)) "_close"
        )
      )
      (progn
        (setq TBX (mtextbox TXT))   ; Mtext
        (command "_.pline")
        (foreach PT TBX (command PT))
        (command "_c")
      )
    )

    (setq ORGBND (entlast))

    (command "_.offset" DIST (entlast))
    (if (= TXTYP "TEXT")
      (command "-1,-1" "")
      (command (polar 
                 (cdr (assoc 10 TXT))
                 (cdr (assoc 50 TXT))
                 (* 2 (cdr (assoc 42 TXT)))
               )
               ""
      ) 
    )

    (entdel ORGBND)

  );end defun

; ----------------------------------------------------------------
;                          MAIN PROGRAM
; ----------------------------------------------------------------


  (if (member "wipeout.arx" (arx))
    (setq WIPOUT T)
    (progn
      (princ "\nLoading WIPEOUT for use with TEXTMASK...")
      (if (arxload "wipeout.arx" nil)
        (setq WIPOUT T)
        (progn
          (prompt "\nWIPEOUT.ARX, an AutoCAD Bonus Tool needed for this application")
          (prompt "\ncould not be found. Operation aborted.")
        )
      )
    )
  )
  
  (if WIPOUT                                           ; if wipeout.arx is loaded
    (progn

      (setq CNT   0                                    ; Initilize the counter.
            GLST  (grplst)                             ; Get all the groups in drawing
            GDICT (if GLST
                      (dictsearch (namedobjdict) "ACAD_GROUP")
                    )
            FLTR   '( (-4 . "<OR")                     ; Filter for ssget.
                          (0 . "MTEXT")
                          (0 . "TEXT")
                      (-4 . "OR>")
                    )
      )

; ------------------ Set the offset value to use ----------------- 
    
      (setq OSET (getcfg "AppData/AC_Bonus/Txtmsk_Offset"))

      (if (not (and OSET
                 (type (setq OSET (read OSET)) "REAL") ; If no prior valid setting
               )
          )
        (setq OSET 0.35 )                              ; use 0.35 as default.
      )
          

      (initget 4)                                      ; No negative values allowed
      (setq TMP
        (getdist (strcat "\nEnter offset factor relative to text height <" (rtos OSET 2 2) ">: "))
      )

      (if TMP (setq OSET TMP))
      (setcfg "AppData/AC_Bonus/Txtmsk_Offset" (rtos OSET 2 2))

; ---------------------- get text to mask ------------------------

      (Princ "\nSelect Text to MASK...")
      
      (if (setq SS (ssget FLTR))                       ; Select text and mtext
        (progn

          (command "_.wipeout" "_frame" "_off")        ; Turn off wipeout frames

          (if (b_layer_locked (getvar "clayer"))       ; if current layer is locked
            (progn
              (command "_.layer" "_unl" (getvar "clayer") "")  ; unlock it
              (setq LOCKED T)
            )
          )

; ----------------- Step through each and mask -------------------

          (While (setq ENT (ssname SS CNT))            ; step through each object in set

            (and
              GLST                                     ; if groups are present in the drawing
              (setq GNAM (getgname ENT GLST))          ; and the text item is in one or more
              (foreach GRP GNAM                        ; step through those groups
                (and
                  (setq MLST (getgmem GRP))            ; Get the members of the group.
                  (= (length MLST) 2)                  ; If the group has two members
                  (if (eq (car MLST) ENT)              ; get the member which is not
                    (setq MLST (cadr MLST))            ; the text.
                    (setq MLST (car MLST))
                  )
                  (= "WIPEOUT" (cdr (assoc 0 (entget MLST))))   ; If it is a wipeout entity
                  (dictremove (cdr (assoc -1 GDICT)) (cdr GRP)) ; explode the group
                  (entdel MLST)                                 ; and delete the wipeout
                )
              )
            )
                  
            (setq TXT   (entget ENT (list "*"))
                  TXTYP (cdr (assoc 0 TXT))            ; Text or Mtext
            )

            (if (= TXTYP "TEXT")
              (command "_.ucs" "_object" ENT) ; set UCS to object
               (ucs_2_mtext ENT)
            )

            (setq TXTLAY (cdr (assoc 8 TXT))           ; Get the layer of the text
                  TOS    (* (cdr (assoc 40 TXT)) OSET) ; Set the offset for the text
            )

            (drawbox TXT TOS)                          ; Draw pline around text

            (command "_.ucs" "_previous")              ; reset the ucs

            (if (= TXTYP "MTEXT")
              (command "_.ucs" "_previous")         ; second previous needed for ucs_2_mtext
            )
            
            (command "_.wipeout" "_new" (entlast) "_yes")  ; create wipeout entity

            (setq WIPOUT (entlast))

            (command "_.change" WIPOUT "" "_Prop" "_Layer" TXTLAY "") ; and set its layer

            (if (setq TXLCK (b_layer_locked TXTLAY))   ; If text layer is locked
              (command "_.layer" "_unl" TXTLAY "")     ; unlock it
            )

            (entmake TXT)                              ; recreate text
            (setq TXT (entlast))                       ; such that it's on top

            (makgrp (list WIPOUT TXT) "In use by TEXTMASK") ; make the text and wipeout a group
        
            (entdel ENT)                               ; delete original text

            (if TXLCK (command "_.layer" "_lock" TXTLAY "")) : relock if needed

            (setq CNT (1+ CNT))                        ; get the next text item
          ); while

          (if LOCKED (command "_.layer" "_lock" (getvar "clayer") "")) : relock if needed

        );progn
        (prompt "\nNothing selected.")
      );if SS
    );progn
  );if wipeout

  (restore_old_error)                                  ; Retsore values

)

