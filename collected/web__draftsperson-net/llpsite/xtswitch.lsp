;***************************** XTSWITCH.LSP ***********************************
;     Purpose:  Switches Extension Lines On and Off 
;     Created:  7/24/97
;     Modified: 11/25/97  added error handler
;     Author:  Herman Mayfarth
;              Tekton Construction Services
;              h_mayfarth@compuserve.com
;     Copyright (c) 1997 Herman Mayfarth. Permission granted to freely use
;	  and redistribute without fee so long as copyright notice remains intact. 	
;     Provided "as is" and with all faults. No warranty express or implied.
;
;******************************************************************************
;; error handler
(defun tcserr(msg)
	(exitsw)
	(if
	  (or
	    (= msg "Function cancelled")
		(= msg "quit / exit abort")
	  )
	  (princ)
	  (princ (strcat "\nError: msg"))
	);end if
	(princ)
);end tcserr
;;----------------------------------------------------------------------------
;; startup function
(defun strtsw()
	(command "_.UNDO" "BEGIN")
	(setq olderr *error*
	      *error* tcserr)
    (setq oldecho (getvar "cmdecho"))
    (setvar "cmdecho" 0)
	(princ)
);end strtsw
;;---------------------------------------------------------------------------
;; exit function
(defun exitsw()
	(setvar "cmdecho" oldecho)
	(setq *error olderr
	      olderr nil)
	(command "_.UNDO" "END")
	(princ)
);end exitsw
;;---------------------------------------------------------------------------
;; basic switch function
(defun tcs_xtln_switch (val / s a e1 pt d1 d2 which switchval)
;; initialize variables
(setq s T)      
(setq which nil)
(setq switchval val)
;; get dimension to change
(while s 
   (setq a (entsel "\nSelect Dimension Near Extension Line to Change:\n"))
   (setq pt (trans(cadr a) 1 0))
   (setq e1 (entget (car a)))
   (if (= "DIMENSION" (cdr(assoc 0 e1))) 
   (setq s nil) 
   );end if 
);end while

;; evaluate distances to definition points
(setq d1 (distance pt (cdr(assoc 13 e1))))
(setq d2 (distance pt (cdr(assoc 14 e1))))

;; decide which extension line to toggle 
(cond
   ((> d1 d2) (setq which "DIMSE2"));toggle DIMSE2
   ((> d2 d1) (setq which "DIMSE1"));toggle DIMSE1
   (T nil)
);end cond
;; do it!
(command "_.dimoverride" which  switchval "" (car a) "")
(princ)
);end tcs_xtln_switch
;;----------------------------------------------------------------------------
;; turn on line
(defun C:XTLON( / oldecho olderr)
   (strtsw)
   (tcs_xtln_switch 0)
   (exitsw)
   (princ)
);end XTLON
;;--------------------------------------------------------------------------
;; turn off line
(defun C:XTLOFF( / oldecho olderr)
   (strtsw)
   (tcs_xtln_switch 1)
   (command "_.REDRAW")
   (exitsw)
   (princ)
);end XTLOFF
;;-------------------------------------------------------------------------
;; load prompts
(princ "\nXTSWITCH loaded....")
(princ "\nXTLON turns on extension line,XTLOFF turns it off")
(princ)
