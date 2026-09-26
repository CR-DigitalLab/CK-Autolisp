;; MXPLODE.LSP    Training Department - 2/19/91  Release 11
;
;     Copyright (C) 1991-92 by Autodesk, Inc.
;
;     Permission to use, copy, modify, and distribute this software 
;     for any purpose and without fee is hereby granted, provided 
;     that the above copyright notice appears in all copies and that 
;     both that copyright notice and this permission notice appear in 
;     all supporting documentation.
;
;     THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT EXPRESS OR IMPLIED
;     WARRANTY.  ALL IMPLIED WARRANTIES OF FITNESS FOR ANY PARTICULAR
;     PURPOSE AND OF MERCHANTABILITY ARE HEREBY DISCLAIMED.
;     ****************************************************************
;; This routine explodes uniformly scaled blocks that have
;; been mirrored, or blocks inserted with both negative and
;; positive xyz scale factors (i.e. 1 -1 -1).
;; The steps taken are as follows:

;;  1)  Select enitity
;;  2)  Find x, y, & z scale factors
;;  3)  Check to see if selected entity is a block with or
;;      without uniform scale factors
;;  4)  Check to see if block has uniform absolute scale
;;      factors
;;  5)  Switch UCS to view
;;  6)  Copy block off screen
;;  7)  Switch to UCS of the the copied block insertion and
;;      modify (entmod) its scale factors
;;  8)  Explode block
;;  9)  Collect entities resulting from explode into a set
;; 10)  Reposition the selection set back into place
;; 11)  Erase originally selected block insertion
;; 12)  Switch back UCS back to view, and move entites into
;;      position
;; 13)  Switch back to original UCS

;; Step 5,6,11, & 12 are not necessary.  It is done so the 
;; user does not see the modified block being mirrored or
;; rotated into place.


(defun m-err (s) ;redefined error function
  (if (/= s "Function cancelled")
      (princ (strcat "\nError: " s))
  ) 
  (setvar "BLIPMODE" s-blip)
  (setvar "CMDECHO" s-echo)
  (setq *error* olderr)
  (princ)
) 

;; Functions that reposition exploded block into place
(defun -xyz ()
  (command ".mirror" ss "" '(0 0) '(0 1) "y")
)

(defun xy-z ()
  (command ".ucs" "y" "90")
  (command ".mirror" ss "" '(0 0) '(0 1) "y")
  (command ".ucs" "p")
)

(defun -xy-z ()
  (command ".ucs" "x" "90")
  (command ".rotate" ss "" '(0 0) "180")
  (command ".ucs" "p")
)

(defun x-yz ()
  (command ".mirror" ss "" '(0 0) '(1 0) "y")
)

(defun -x-yz ()
  (command ".mirror" ss "" '(0 0) '(1 0) "y")
  (command ".mirror" ss "" '(0 0) '(0 1) "y")
)

(defun x-y-z ()
  (command ".ucs" "y" "90")
  (command ".rotate" ss "" '(0 0) "180")
  (command ".ucs" "p")
)

;; Main function
(defun C:MXPLODE (/ s-echo s-blip e elist etype laste 
     xscl yscl zscl xsclist xoffset ss next old-err)
  (setq olderr *error*  *error* m-err) ;redefine error function
  (setq s-echo (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)
  (setq s-blip (getvar "BLIPMODE"))
  (setvar "BLIPMODE" 0)
  (setq xoffset (list (* (getvar "viewsize") 3) 0))
  (if (setq e (car (entsel)))                           ; STEP 1
   (progn
    (setq elist (entget e))
    (setq etype (cdr (assoc 0 elist)))
    (setq xscl (cdr (setq xsclist (assoc 41 elist))))   ; STEP 2
    (setq yscl (cdr (setq ysclist (assoc 42 elist))))
    (setq zscl (cdr (setq zsclist (assoc 43 elist))))
    (if (and (equal etype "INSERT")
             (not (and (= xscl yscl) (= xscl zscl)))    ; STEP 3
        )
        (progn
          (if (and (equal (abs xscl) (abs yscl))        ; STEP 4
                   (equal (abs xscl) (abs zscl))
              )
              (progn
                (princ " Exploding block . . .")
                (setq ss (ssadd))
                (setq laste (entlast))
                (command ".ucs" "v")                    ; STEP 5
                (command "copy" e "" '(0 0) xoffset)    ; STEP 6
                (setq elist (entget (entlast)))
                (command ".ucs" "e" (entlast))          ; STEP 7
           (setq elist (subst (cons 41 (abs xscl)) xsclist elist))
           (setq elist (subst (cons 42 (abs yscl)) ysclist elist))
           (setq elist (subst (cons 43 (abs zscl)) zsclist elist))
                (entmod elist)
                (command ".explode" (entlast))          ; STEP 8
                (while (setq next (entnext laste))      ; STEP 9
                       (ssadd next ss)
                       (setq laste next)
                )
                (cond ((and (minusp xscl)               ; STEP 10
                            (not (minusp yscl))
                            (not (minusp zscl))
                       ) (-xyz)
                      )
                      ((and (not (minusp xscl))
                            (not (minusp yscl))
                            (minusp zscl)
                       ) (xy-z)
                      )
                      ((and (minusp xscl)
                            (not (minusp yscl))
                            (minusp zscl)
                       ) (-xy-z)
                      )
                      ((and (not (minusp xscl))
                            (minusp yscl)
                            (not (minusp zscl))
                       ) (x-yz)
                      )
                      ((and (minusp xscl)
                            (minusp yscl)
                            (not (minusp zscl))
                       ) (-x-yz)
                      )
                      ((and (not (minusp xscl))
                            (minusp yscl)
                            (minusp zscl)
                       ) (x-y-z)
                      )
                      (T (princ "/nSomething went wrong."))
                )
                (command "erase" e "")                  ; STEP 11
                (command ".ucs" "p")                    ; STEP 12
                (command "move" ss "" xoffset '(0 0))
                (command ".ucs" "p")                    ; STEP 13
              )
              (command ".explode" e) ;if not mirrored, explode
          )
        )
        (command ".explode" e)       ;if not block, explode
    )
   )
   (princ " None found.")            ;if not found, say so
  )
  (setvar "CMDECHO" s-echo)
  (setvar "BLIPMODE" s-blip)
  (setq *error* olderr)            ;reset error function
  (princ)
)
