(load "acettest.fas" (princ))
;;deben agregarse archivos para pdf, smt
;;
(vmon)


(defun c:CB()(command "CHPROP""c" pause pause """C""BYLAYER"""))
(defun c:CLB()(command "CHPROP""c" pause pause """C""BYLAYER""LT""BYLAYER"""))
(DEFUN C:l๑ ()(COMMAND "lengthen""dy"))
(DEFUN C:ltt ()(COMMAND "lengthen""total"))
(defun c:SD()(command "ORTHO""OFF""STRETCH""C"))
(defun c:SF()(command "ORTHO""ON""STRETCH""C"))
(defun c:l0()(command "line"".z""0,0,0" pause ".z""0,0,0" pause ".z""0,0,0" pause ".z""0,0,0" pause ".z""0,0,0" pause ".z""0,0,0" pause ".z""0,0,0" pause ".z""0,0,0" pause ".z""0,0,0" pause ".z""0,0,0" pause ".z""0,0,0" pause ".z""0,0,0" pause ".z""0,0,0" pause ".z""0,0,0" pause ".z""0,0,0" pause ".z""0,0,0" pause ".z""0,0,0" pause ".z""0,0,0" pause ".z""0,0,0" pause ".z""0,0,0" pause ".z""0,0,0" pause ".z""0,0,0" pause ".z""0,0,0" pause ".z""0,0,0" pause ".z""0,0,0" pause ".z""0,0,0" pause ))
(defun c:au()(command "audit""y"))
(defun c:L1()(command "dimldrblk""."))
(defun c:L2()(command "dimldrblk""_dot"))
(defun c:L3()(command "dimldrblk""_dotsmall"))
(defun c:L4()(command "dimldrblk""_dotblank"))
(defun c:L5()(command "dimldrblk""_integral"))
(defun c:mon()(command "mview""on""all"""))
(defun c:mla()(command "mview""lock""on""all"""))
(defun c:mua()(command "mview""lock""off""all"""))
(defun c:won()(command "wipeout""frame""on"))
(defun c:wof()(command "wipeout""frame""off"))
(defun c:var()(command "ltscale""10.16""psltscale""1"))
(DEFUN C:pur ()(COMMAND "purge""a""""n"))
(defun c:U2 ()(command "insunits""0""insunitsdefsource""0""insunitsdeftarget""0""UNITS""2""2"""""""""))
(defun c:U3 ()(command "insunits""0""insunitsdefsource""0""insunitsdeftarget""0""UNITS""2""3"""""""""))
(defun c:U4 ()(command "insunits""0""insunitsdefsource""0""insunitsdeftarget""0""UNITS""2""4"""""""""))
(defun c:U5 ()(command "insunits""0""insunitsdefsource""0""insunitsdeftarget""0""UNITS""2""5"""""""""))
(defun c:U6 ()(command "insunits""0""insunitsdefsource""0""insunitsdeftarget""0""UNITS""2""6"""""""""))


;;


;;;   CALC.lsp
;;;   Copyright (C) 1990 by Autodesk, Inc.
;;;  
;;;   THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT EXPRESS OR IMPLIED WARRANTY. 
;;;   ALL IMPLIED WARRANTIES OF FITNESS FOR ANY PARTICULAR PURPOSE AND OF 
;;;   MERCHANTABILITY ARE HEREBY DISCLAIMED.
;;; 
;;;   by Jan S. Yoder
;;;   01 February 1990
;;;
;;;--------------------------------------------------------------------------;
;;; DESCRIPTION
;;;   This is a command line implementation of an TI type calculator.  It 
;;;   supports addition, subtraction, multiplication, division, square roots,
;;;   raising Y to the x power, and numerous memory functions.  There is no
;;;   built-in limit to the number of lisp variables that may be assigned -
;;;   this is limited by the user's memory.  Values may be stored to variables,
;;;   listed, deleted, and used in calculations as desired.
;;;
;;;   There is also support for sine, cosine, tangent and the Arc functions;
;;;   Arcsine, Arccosine, and Arctangent.  All angles are in degrees, radians 
;;;   and gradians are not supported.
;;;
;;;   This function tries to be understanding about unit types and precision,
;;;   but no claim is made that it is universally adequate about performing 
;;;   said task.   For instance, if the user does several multiplication 
;;;   sequences, the printed display will show first units, then square units,
;;;   cubic units, and finally revert back to units, as I don't quite know
;;;   what to call forth order dimensions - perhaps teracted units.  There is 
;;;   also no way to tell whether a number is a unit or unitless multiplier.
;;;--------------------------------------------------------------------------;
;;;
(defun myerror (s)                    ; If an error (such as CTRL-C) occurs
                                      ; while this command is active...
  (if (/= s "Function cancelled")
    (princ (strcat "\nError: " s))
  )
  (setvar "cmdecho" ocmd)             ; Restore saved modes
  (setvar "blipmode" oblp)
  (setq *error* olderr)               ; Restore old *error* handler
  (princ)
)
;;;
;;; Main control function.
;;;
(defun a:calc (task / calc_n calc_a calc_s temp sbtask save_m)
  (setvar "cmdecho" 0)
  (command "undo" "group")
  (setq calc_n 0)
  (menucmd "s=calc")
  (cond
    ;; The trig functions; sine, cosine, tangent, arctangent
    ((= task "Trig")                  
      (setq calc_c 1)
      (cal_tr)
    )
    ;; The square root of calc_m
    ((= task "Sq-rt")                 
      (setq calc_c 1)
      (cal_sq)
    )
    ;; calc_m to the x power.  Negative numbers used as x
    ;; result in fractions as such - (1/mt)^x
    ((= task "Y")       
      (setq calc_c 1)
      (cal_yx)
    )
    ;; Memory subfunctions
    ((= task "Mem")     
      (setq calc_c 1)
      (cal_mm)
    )
    ;; Add, subtract, multiply and divide
    (T
      (setq calc_n (getdist "Next number: "))
      (if calc_n 
        (cond
          ;; add the number to the display
          ((= task "+") 
           (setq calc_c 1
                  calc_m (+ calc_m calc_n)
                 calc_a (strcat (rtos calc_m) 
                          (if (= (getvar "lunits") 4) (strcat
                            ", or " (rtos calc_m 2)) "") " units. ")
            )
          )
          ;; subtract the number from the display
          ((= task "-") 
            (setq calc_c 1
                  calc_m (- calc_m calc_n)
                  calc_a (strcat (rtos calc_m) 
                          (if (= (getvar "lunits") 4) (strcat
                            ", or " (rtos calc_m 2)) "") " units. ")
            )
          )
          ;; multiply the display by the number
          ((= task "*") 
            ;; Take care of power to a number when multiplied
            (setq calc_c (1+ calc_c)) ; placed count here to 
            (cond                     ; figure out whether to put
              ((= calc_c 2) (setq calc_s " square")); square if 2 times
              ((= calc_c 3) (setq calc_s " cubic")) ; cubic if 3 times
              (T (setq calc_s ""))
            )
            (setq calc_m (* calc_m calc_n))
            (if (= (getvar "lunits") 4)
              (if (or (= calc_c 2) (= calc_c 3))
                (setq calc_a (strcat "\n" (rtos (/ calc_m 12) 2)
                                     calc_s "Feet or " 
                                     (rtos calc_m 2) calc_s " Inches" ))
                (setq calc_a (strcat (rtos calc_m) calc_s " units. "))
              )
              (setq calc_a (strcat (rtos calc_m 2) calc_s " units. "))
            )
          )
          ;; divide the display by the number
          ((= task "/") 
            (setq calc_c 1
                  calc_m (/ calc_m calc_n)
                  calc_a (strcat (rtos calc_m) 
                          (if (= (getvar "lunits") 4) (strcat
                            ", or " (rtos calc_m 2)) "") " units. ")
            )
          )
          (T                          ; error
            (exit)
          )
        )
      )
      ;; Display the result
      (if calc_n (princ (strcat "\n" calc_a)))
    )
  )
)
;;;
;;; Trig functions
;;;
(defun cal_tr ()
  (menucmd "s=calc3")
  (if (null sbtask) (setq sbtask "Exit"))
  (initget "ACosine ASine ATangent Sine Cosine Tangent Exit") 
  (setq temp (getkword (strcat 
    "\nTrig: ACosine ASine ATangent Cosine Sine Tangent <" sbtask ">: ")))
  (if temp (setq sbtask temp))
  (cond 
    ((= sbtask "ACosine")
      (cal_ac)
    )
    ((= sbtask "ASine")
      (cal_as)
    )
    ((= sbtask "ATangent")
      (setq save_m calc_m
            calc_m    (* (atan calc_m) (/ 180 pi))
      )
      (cal_pr "The arctangent of " save_m " is " calc_m " degrees. ")
    )
    ((= sbtask "Cosine")
      (setq save_m calc_m
            calc_m    (cos (/ calc_m (/ 180 pi)))
      )
      (cal_pr "The cosine of " save_m " degrees is " calc_m ". ")
    )
    ((= sbtask "Sine")
      (setq save_m calc_m
            calc_m    (sin (/ calc_m (/ 180 pi)))
      )
      (cal_pr "The sine of " save_m " degrees is " calc_m ". ")
    )
    ((= sbtask "Tangent")
      (setq save_m calc_m
            calc_m    (/ (sin (/ calc_m (/ 180 pi))) 
                         (cos (/ calc_m (/ 180 pi))))
      )
      (cal_pr "The tangent of " save_m " degrees is " calc_m ". ")
    )
    (T
      (princ)
    )
  )
)
;;;
;;; Arc-Cosine function.
;;; The function must be bound between the range -1 <= calc_m <= 1
;;; arc_cos(x) = arc_tan(x/sqrt(1-x^2))
;;;
(defun cal_ac ()
  (if (and (< calc_m 1.0) 
           (> calc_m -1.0))
    (progn
      (setq save_m calc_m
            calc_m (* (/ 180 pi) 
                      (atan (sqrt (- 1 (expt calc_m 2))) calc_m))
      )
      (cal_pr "The arccosine of " save_m " is " calc_m " degrees. ")
    )
    (cond
      ((= calc_m 1.0)
        (cal_pr "The arccosine of " calc_m " is " (eval 0.0) " degrees. ")
        (setq calc_m 0)
      )
      ((= calc_m -1.0)
        (cal_pr "The arccosine of " calc_m " is " (eval 180.0) " degrees. ")
        (setq calc_m 180)
      )
      (progn
        (cal_pr "The arccosine of " calc_m " is undefined. " nil "")
        (princ "\nValid range is (0 <= Input value < 1).")
      )
    )
  )
)
;;;
;;; Arc-Sine function.
;;; The function must be bound between the range -1 <= calc_m <= 1
;;; arc_sin(x) = PI/2 - arc_cos(x)
;;;
(defun cal_as ()
  (if (and (< calc_m 1.0) 
           (> calc_m -1.0))
    (progn
      (setq save_m calc_m
            calc_m (- 90.0 
                      (* (/ 180 pi) 
                         (atan (sqrt (- 1 (expt calc_m 2))) calc_m)))
      )
      (cal_pr "The arcsine of " save_m " is " calc_m " degrees. ")
    )
    (cond
      ((= calc_m 1.0)
        (cal_pr "The arcsine of " calc_m " is " (eval 90.0) " degrees. ")
        (setq calc_m 90)
      )
      ((= calc_m -1.0)
        (cal_pr "The arcsine of " calc_m " is " (eval -90.0) " degrees. ")
        (setq calc_m -90)
      )
      (progn
        (cal_pr "The arcsine of " calc_m " is undefined. " nil "")
        (princ "\nValid range is (0 <= Input value < 1).")
      )
    )
  )
)
;;;
;;; Print a concatenated string with a symbols value.
;;;
(defun cal_pr (str1 val1 str2 val2 str3)
  (princ (strcat "\n" 
                 str1 
                 (if val1 (rtos val1 2) "")
                 str2 
                 (if val2 (rtos val2 2) "")
                 str3 "\n"))
)
;;;
;;; Calculate the square of the number.
;;;
(defun cal_sq ()
  (setq save_m calc_m
        calc_m (sqrt calc_m)
  )
  (if (= (getvar "lunits") 4)
    (progn
      (princ (strcat "\nThe square root of " (rtos save_m) " is " 
                                     (rtos calc_m) ", or"))
      (princ (strcat "\nthe square root of " (rtos save_m 2) " is " 
                                     (rtos calc_m 2) ". "))
    )
    (cal_pr "The square root of " save_m " is " calc_m ". ")
  )
)
;;;
;;; Calculate the result of Y to the x power
;;;
(defun cal_yx ()
  (setq calc_a (getreal "\Enter the power of x: "))
  (if (= calc_a 0.0) 
    (princ "\nInvalid power of x. ")
    (progn
      (setq save_m calc_m
            calc_m    (expt calc_m calc_a))
      (princ (strcat "\n" (rtos save_m 2) 
                     " to the power of " (rtos calc_a 2) 
                     " is " (rtos calc_m 2)
                     (if (< calc_a 0)
                       (strcat " or 1/" (rtos (/ 1.0 calc_m) 2))
                       ""
                     )
                     ". \n"
            )
      )
    )
  )
)
;;;
;;; Memory functions -- main function
;;;
(defun cal_mm ()
  (menucmd "s=calc2")
  (if (null sbtask) (setq sbtask "Set"))
  (initget (strcat "+ - * / Delete Set Recall List Exit"
                   "ADd SUbtract MUltiply DIvide")) 
  (setq temp (getkword (strcat 
    "\nMem : Delete/Exit/List/Recall/Set or + - * / <" sbtask ">: ")))
  (if temp (setq sbtask temp))
  (cond 
    ;; List the non-nil declared variables in the calculator
    ((= sbtask "List") 
      (cal_ml) 
    )
    ((= sbtask "Exit")
      (princ)
    )
    (T
      (cal_mt)
    )
  )
)
;;;
;;; Memory list function.
;;;
(defun cal_ml ()
  (setq nwlist '())
  (if (null vlist)
    (princ "\nNo variables defined. ")
    (progn
      (foreach n vlist 
        (princ (if (or (= (type (eval (read n))) 'REAL)
                       (= (type (eval (read n))) 'INT))
                 (progn
                   (setq nwlist (append nwlist (list n)))
                   (if (= (getvar "lunits") 4)
                     (strcat "\n     " n " = " 
                             (rtos (eval (read n)))
                             ", or " 
                             (rtos (eval (read n)) 2)
                     )              
                     (strcat "\n     " n " = " 
                             (rtos (eval (read n)))
                     )              
                   )              
                 )
                 (princ)
               )
        )
      )
    )
  )
  (if nwlist 
    (progn
      (setq vlist  nwlist 
            nwlist nil
      )
    )
  )
)
;;;
;;; Memory operation functions.
;;;
(defun cal_mt ()
  (setq v_name (getstring (cond 
    ((= sbtask "+") (strcat "Add " (rtos calc_m 2) " to: "))
    ((= sbtask "-") (strcat "Subtract " (rtos calc_m 2) " from: "))
    ((= sbtask "*") (strcat "Multiply by "  (rtos calc_m 2) ": "))
    ((= sbtask "/") (strcat "Divide by " (rtos calc_m 2) ": "))
    ((= sbtask "Delete") "Delete (All = *C): ")
    ((= sbtask "Set") "Set: ")
    ((= sbtask "Recall") "Recall: ")
  )))
  (if (or (= v_name "") 
          (null v_name)
          (and (/= (ascii v_name) 42)
               (< (ascii v_name) 65)
          )
          (and (> (ascii v_name) 90)
               (< (ascii v_name) 97)
          )
          (> (ascii v_name) 122)
      )
    (progn 
      (setq v_name "")
    )
 
    ;; Set up list of variable names and avoid 
    ;; duplicate variable names on the list
 
    (progn 
      (if (= (strcase v_name) "*C")   ; if deleting all variables
         (progn                     
           (princ "\nSetting all variables nil.")
           (setq vlist nil)
         )
         (progn                       ; else
           (setq v_name (strcase v_name)
                 vlist  (if (null vlist)
                          (list v_name)
                          (progn
                            (if (not (member v_name vlist))
                              (append vlist (list v_name))
                              vlist
                            )
                          )
                        )
          )
          (cond
            ;; set the variable name to the number
            ((= sbtask "Set") 
              (set (read v_name) calc_m)
              (eval (read v_name))
            )
            ;; recall the value of the variable
            ((= sbtask "Recall")  
              (setq calc_m (eval (read v_name)))
              (print calc_m)
            )
            ;; delete the variable (set to nil)
            ((= sbtask "Delete")  
              (set (read v_name) nil)
            )
            ;; add the number to the variable
            ((= sbtask "+") 
              (set (read v_name) (+ (eval (read v_name)) calc_m))
              (setq calc_m (read v_name))
              (print (eval (read v_name)))
            )
            ;; subtract the number from the variable
            ((= sbtask "-") 
              (set (read v_name) (- (eval (read v_name)) calc_m))
              (setq calc_m (read v_name))
              (print (eval (read v_name)))
            )
            ;; multiply the value of the variable by the   number
            ((= sbtask "*") 
              (set (read v_name) (* (eval (read v_name)) calc_m))
              (setq calc_m (read v_name))
              (print (eval (read v_name)))
            )
            ;; divide the value of the variable by the n  umber
            ((= sbtask "/") 
              (set (read v_name) (/ (eval (read v_name)) calc_m))
              (setq calc_m (read v_name))
              (print (eval (read v_name)))
            )
            ((null (eval (read v_name)))
               (princ "\nNot a valid lisp symbol. ")
            )
          )
        )
      )
    )
  )
)
;;;
;;; C:calc definition
;;;
(defun c:++ (/ olderr ocmd oblp calver cal_er cal_oe s calc_m 
                 temp task calc_c hlf_pi nwlist)

  (setq calver "1.00")
  ;;
  ;; Body of CALC function
  ;;

  (setq olderr  *error*
        *error* myerror)
  (setq ocmd (getvar "cmdecho"))
  (setq oblp (getvar "blipmode"))
  (setvar "cmdecho" 0)
  (setq task "Clear" calc_c 1 hlf_pi (/ pi 2))
  (princ (strcat "\nCALC, Version " calver ", (c) 1990 by Autodesk, Inc. "))
  (setq calc_m (getdist "\nFirst number: "))
  (while (and calc_m (/= task "Exit"))
    (menucmd "s=calc")
    (initget (strcat "+ - * / Clear Mem Y Sq-rt Trig Exit "
                     " ADd SUbtract MUltiply DIvide")) 
    (setq temp (getkword (strcat    
      "\nCalc: Clear/Exit/Mem/Sq-rt/Trig/Y^x or + - * / <" task ">: ")))
    (if temp (setq task temp))   
    (if (= task "Clear")
      (setq calc_m (getdist "\nFirst number: "))
      (if (and calc_m (/= task "Exit"))
        (a:calc task)
      )
    )
  )
  ;; Delete all "nil" entries from the variable list when exiting
  (setq nwlist '())
  (foreach n vlist 
    (if (null (eval (read n)))
       (eval (read n))
       (setq nwlist (append nwlist (list n)))
    )
  )
  (if nwlist (setq vlist nwlist nwlist nil))
  (setvar "cmdecho" ocmd)
  (setvar "blipmode" oblp)
  (setq *error* olderr)               ; Restore old *error* handler
  (princ)
)
;;(princ "\n\tC:CALC.LSP loaded.  Start command with ++.")
(princ)

;;


;LAC.LSP:   CAMBIACOLORES.LSP    Cambia el color de Layers    (C)2003, Paulito Gil

(defun c:aac ()
     (setq lay (getvar "clayer")) 
     (prompt "Selecciona los layers a cambiar: ") (terpri)
        (setq ss (ssget)
              ss1(sslength ss)
              x   0
              s2 (cdr(assoc 8 (entget(ssname ss x)))) 
        )
     (setq color (getstring "\nQue color vas a querer para esos layers...?  "))
        (command "layer" "s" lay "")
        (repeat ss1
          (setq ssn (ssname ss x)
                a   (entget ssn)
                s1  (cdr(assoc 8 a))
          )
             (command "layer" "c" color s1 "")
             (setq x (+ x 1))
        )
        (command "layer" "c" color s2 "")
        (prompt"Ya estan cambiados los colores...")(terpri)
        (princ)
)


;;

;===============================================================================
;     LAYCHG - Change an entity's layer by picking another entity
;===============================================================================

(defun C:AC ()

   (prompt "\nLAYCHG - Change an entity's layer by picking another entity")

   (setq OLD_CMDECHO (getvar "CMDECHO"))
   (setvar "CMDECHO" 0)

   (setq TARGET_PICK (entsel "\nPick an entity on target layer : "))

   (if TARGET_PICK
       (progn
          (setq TARGET_ENTITY  (car TARGET_PICK))
          (setq TARGET_ENTLIST (entget TARGET_ENTITY))
          (setq TARGET_LAYER   (cdr (assoc 8 TARGET_ENTLIST)))

          (prompt (strcat "\nSelect objects to change to layer " TARGET_LAYER))
          (setq CHANGE_ENTITIES (ssget))

          (command ".CHPROP" CHANGE_ENTITIES "" "LA" TARGET_LAYER "")
       )
   )

   (setvar "CMDECHO" OLD_CMDECHO)

   (prompt "\nProgram complete.")
   (princ)
)


;;

;change object(s) to current layer

(defun c:acc ()
   (princ "Select objects to be changed to current layer...\n")
   (setq ss (ssget))
   (if ss (progn
      (setq lay (getvar"clayer"))
         (command "CHANGE" ss "" "PROP" "LAYER" lay "")
      ))
      (princ)
)

;;




;Turns on all layers except for frozen layers

(defun c:AD (/ OLDECH )

(SETQ OLDECH (GETVAR "CMDECHO") )
(SETVAR "CMDECHO" 0)
(COMMAND ".LAYER" "ON" "*" "")
(SETVAR "CMDECHO" OLDECH)
(PRINC))




;;





;;;     This file contains a library of layer based routines. See individual
;;;     routines for descriptions.
;;;
;;;  External Functions:
;;;
;;;     ACET-ERROR-INIT         --> ACETUTIL.FAS   Intializes bonus error routine
;;;     ACET-ERROR-RESTORE      --> ACETUTIL.FAS   Restores old error routine
;;;     ACET-STR-FORMAT         --> ACETUTIL.ARX   Alternate to strcat
;;;

; -------------------- LAYER FREEZE FUNCTION ---------------------
; Freezes selected object's layer
; ----------------------------------------------------------------

(defun C:AF ()
; --------------------- Error initialization ---------------------

  (acet-error-init
    (list
      (list "cmdecho" 0
            "expert"  0
      )

      nil     ;flag. True means use undo for error clean up.
    );list
  );acet-error-init

  (layproc "frz")

  (acet-error-restore)
  (princ)
)

; ------------- LAYER PROCESSOR FOR LAYOFF & LAYFRZ --------------
; Main program body for LAYOFF and LAYFRZ. Provides user with
; options for handling nested entities.
; ----------------------------------------------------------------

(defun LAYPROC ( TASK / NOEXIT OPT BLKLST CNT VPMODE EN PMT ANS LAY NEST BLKLST VPSS)



; -------------------- Variable initialization -------------------

  (setq NOEXIT T)

  (setq OPT (getenv (strcat "ACET_Lay" TASK)))    ; get default option setting
  (if (not (or (null OPT) (= OPT ""))) (setq OPT (atoi OPT)))

  (setq CNT 0)                                                ; cycle counter

  (if (and (= 0 (getvar "tilemode"))                          ; if in a paper space
           (/= 1 (getvar "cvport"))                           ; viewport
      )
    (setq VPMODE T)                                           ; set flag for freeze behavior
  )


; ----------------------- Selection Prompt -----------------------

  (while NOEXIT

    (setvar "errno" 7)
    (while (= (getvar "errno") 7)
      (setvar "errno" 0)
      (initget "Options Undo _Options Undo")
      (cond
        ((= TASK "off")
          (setq EN (nentsel "\nSelect an object on the layer to be turned off or [Options/Undo]: "))
        )
        ((= TASK "frz")
          (setq EN (nentsel "\nSelect an object on the layer to be frozen or [Options/Undo]: "))
        )
        ((= TASK "vpi")
          (setq EN (nentsel "\nSelect an object on the layer to be Isolated in viewport or [Options/Undo]: "))
        )
      )
      (if (= (getvar "errno") 7)
        (prompt "\nNothing selected.")
      )
    )

; ---------------------- Options  Selected -----------------------

    (cond
      ((= EN "Options")
        (initget "No Block Entity _No Block Entity")
        (cond
          ((= OPT 1)
            (setq PMT "\nEnter an option [Block level nesting/Entity level nesting/]<No nesting>: ")
          )
          ((= OPT 2)
            (setq PMT "\nEnter an option [Block level nesting/No nesting/]<Entity level nesting>: ")
          )
          (T
            (setq PMT "\nEnter an option [Entity level nesting/No nesting/]<Block level nesting>: ")
          )
        )
        (setq ANS (getkword PMT))

        (cond
          ((null ANS)
            (if (or (null OPT) (= OPT ""))
              (progn
                (setq OPT 3)
                (setenv (strcat "ACET_Lay" TASK) "3")
              )
            )
          )
          ((= ANS "No")
            (setq OPT 1)
            (setenv (strcat "ACET_Lay" TASK) "1")
          )
          ((= ANS "Entity")
            (setq OPT 2)
            (setenv (strcat "ACET_Lay" TASK) "2")
          )
          (T
            (setq OPT 3)
            (setenv (strcat "ACET_Lay" TASK) "3")
          )
        )
      )


; ---------------------- Undo selected ---------------------------

      ((= EN "Undo")
        (if (> CNT 0)
          (progn
            (command "_.u")
            (setq CNT (1- CNT))
          )
          (prompt "\nEverything has been undone.")
        )
      )

; ------------------------- Find Layer ---------------------------

    (EN

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
          (cond
            ((= TASK "off")
              (initget "Yes No _Yes No")
              (setq ANS (getkword (acet-str-format "\nReally want layer %1 (the CURRENT layer) off? [Yes/No] <No>: " LAY)))
              (setq ANS (if (null ANS) "No" ANS))
              (if (= ANS "No")
                (setq LAY nil)
              )
            )
            ((and (= TASK "frz") (not VPMODE))
              (prompt (acet-str-format "\nCannot freeze layer %1.  It is the CURRENT layer." LAY))
              (setq LAY nil)
            )
          )
          (setq ANS nil)
        )

        (if LAY
          (cond
            ((= TASK "off")
              (if ANS
                (command "_.-LAYER" "_OFF" LAY "_Yes" "")
                (command "_.-LAYER" "_OFF" LAY "")
              )
              (prompt (acet-str-format "\nLayer %1 has been turned off." LAY))
              (setq CNT (1+ CNT))
            )
            ((and (= TASK "frz") VPMODE)
              (command "_.VPLAYER" "_FREEZE" LAY "_current" "")
              (prompt (acet-str-format "\nLayer %1 has been frozen in this viewport." LAY))
              (setq CNT (1+ CNT))
            )
            ((= TASK "frz")
              (command "_.-LAYER" "_FREEZE" LAY "")
              (prompt (acet-str-format "\nLayer %1 has been frozen."  LAY ))
              (setq CNT (1+ CNT))
            )
            ((= TASK "vpi")
              (setq VPSS (ssget "_x" (list '(-4 . "<AND")
                                             '(0 . "VIEWPORT")                 ; get all viewports
                                             '(-4 . "<NOT")
                                                (cons 69 (getvar "cvport"))    ; except the current
                                             '(-4 . "NOT>")
                                             '(-4 . "<NOT")
                                                '(69 . 1)                      ; and the paperspace viewport (1)
                                             '(-4 . "NOT>")
                                           '(-4 . "AND>")
                                     )
                         )
              )
              (command "_.VPLAYER" "_FREEZE" LAY "_select" VPSS "" "")
              (prompt (acet-str-format "\nLayer %1 has been frozen in all viewports but the current one."  LAY ))
              (setq CNT (1+ CNT))
            )
          )
        )
      )

; ---------------------- Nothing  Selected -----------------------

      ((not EN)
        (setq NOEXIT nil)
      )
    )
  )
)

(princ)

;;


; ALL.LSP   Quick Line Dimensions   (c)1989, Ruben Rosado

(defun C:ALL(/ E D N P)
  (SetQ E (Car (EntSel "Pick line: ")))
  (TerPri)
  (SetQ D (GetPoint "Dim location: "))
  (TerPri)
  (If E
    (Progn
    (SetQ E (EntGet E))
    (SetQ N (Cdr (Assoc 10 E)))
    (SetQ P (Cdr (Assoc 11 E)))
    (Command "DIM1" "ALIGNED" N P D "")
    (princ)
)))




;;


;;; ARRANG by David Harrington
;;; Array objects at any angle at a giving distance
;;;
;;; Main Program
;;;
(defun c:ara (/ x ent ang num dist pt1 dist1 pt2 ang_error olcmdecho olosmode) 
	(defun ang_error (msg) 
		(if (or (= msg "Function cancelled") (/= msg "quit / exit abort")) 
			(princ (strcat "Error: " msg))
		) 
		(command "._UNDO" "E" "UNDO" "") 
		(setvar "CMDECHO" olcmdecho)
		(setvar "OSMODE" olosmode)
		(setq *error* old_err
			  old_err nil
		)
		(princ)
	) 
	(setq old_err *error* 
		  *error* ang_error
	) 
	(setq  olosmode (getvar "OSMODE")
		  olcmdecho (getvar "CMDECHO")
	)
	(setvar "CMDECHO" 0) 
	(command "._UNDO" "BE") 
	(prompt "\n Arrang - Array objects at an angle") 
	(setq x 1)
	(princ "\nSelect objects to Array: ") 
	(cond
		((setq ent (ssget))
			(initget 1)
			(setq ang (getangle "\nAngle to array objects: "))
			(initget 1)
			(setq num (getint "\nNumber of objects to array: "))
			(initget 1)
			(setq dist (getdist "\nDistance between objects: "))
			(setq pt1 (getvar "lastpoint"))
			(setq dist1 dist)
			(setq pt2 (polar pt1 ang dist1))
			(setvar "osmode" 0) 
			(while (/= num x) 
				(command "._COPY" ent "" pt1 pt2) 
				(setq dist1 (+ dist dist1))
				(setq pt2 (polar pt1 ang dist1))
				(setq x (+ x 1))
			)
		)
	)
	(command "._UNDO" "E") 
	(setvar "OSMODE" olosmode)
	(setvar "CMDECHO" olcmdecho)
	(setq *error* old_err)
	(princ)
) 
(princ) 



;;


;Tip1622:  ARCD.LSP    Arc Length             (c)2000, Bill Farmer

;; startup function
(defun START ()
   (UNDO_CHK)
   (setq SYSVARS (mapcar '(lambda (A B) (setq VAR (getvar A)) (setvar A B) (list A VAR))
                         '("cmdecho" "osmode")
                         '(0 512)
                 ) ;_ end of mapcar
   ) ;_ end of setq
   ;; save the existing error handler and substitute mine
   (setq OLD_ERROR *ERROR*
         *ERROR* MY_ERR
   ) ;_ end of setq
) ;_ end of defun

;;check undo function
(defun UNDO_CHK (/ CMDE)
   (setq CMDE (getvar "cmdecho"))
   (setvar "cmdecho" 0)
   (if (< (setq UNDOVAR (getvar "undoctl")) 5)
      (cond ((= UNDOVAR 0) (command "_.undo" "_A"))
            ((= UNDOVAR 4) (command "_.undo" "_C" "_A"))
      ) ;_ end of cond
   ) ;_ end of if
   (command "_.undo" "_end")
   (if (wcmatch (getvar "ACADVER") "13*")
      (command "_.undo" "_BEGIN")
      (command "_.undo" "_GROUP")
   ) ;_ end of if
   (setvar "cmdecho" CMDE)
) ;_ end of defun

;;Error handling
(defun MY_ERR (S)
   (if (not (member S '("Function cancelled" "console break")))
      (princ (strcat "\nError: " S))
   ) ;_ end of if
   (FINISH)
) ;_ end of defun
(defun ABORT (MSG)
   (if MSG
      (alert (strcat "Application error: [name of lsp that is running]\n\n" MSG " \n"))
   ) ;_ end of if
   (FINISH)
   (exit)
) ;_ end of defun
(defun FINISH ()
   (command "_.undo" "_END")
   (if (< UNDOVAR 5)
      (cond ((= UNDOVAR 0) (command "_.undo" "_C" "_N"))
            ((= UNDOVAR 4) (command "_.undo" "_C" "_0"))
      ) ;_ end of cond
   ) ;_ end of if
   (if SYSVARS
      (foreach VAR SYSVARS (apply 'setvar VAR))
   ) ;_ end of if
   (if OLD_ERROR
      (setq *ERROR* OLD_ERROR
            MY_ERR NIL
            OLD_ERROR NIL
      ) ;_ end of setq
   ) ;_ end of if
   (setq SYSVARS NIL
         UNDOVAR NIL
   ) ;_ end of setq
   (princ)
) ;_ end of defun

;; calculates arc length
(defun ARCL ()
   (setq ENAME (entsel))
   (setq ELIST (entget (car ENAME)))
   (setq RAD (cdr (assoc '40 ELIST))) ;RADIUS
   (cond ;;get arc info from a segment of a circle
         ((equal "CIRCLE" (cdr (assoc '0 ELIST)))
          (princ "\nDimensioning an Arc from a segment of a Circle!")
          (princ "  Arc end points MUST BE PICKED in a COUNTERCLOCKWISE Direction!")
          (setq CTR (cdr (assoc '10 ELIST))) ;Center Pt
          (setq P1 (getpoint "\nPick 1st Arc End Point: ") ;1st point
                P2 (getpoint "\nPick 2nd Arc End Point: ") ;2nd point
          ) ;_ end of SETQ
          (setq 1STA (angle CTR P1)) ;Calculates 1st ANGLE
          (setq 2NDA (angle CTR P2)) ;Calculates 2nd ANGLE
          (if (< 1STA 2NDA)
             (progn (setq RANG (- 2NDA 1STA)) ;ANGLE IN RADIANS
                    (setq ARL (* RAD RANG)) ;ARC LENGTH
                    (setq CARL (* RAD (+ (* 2 pi) (- 1STA 2NDA))))
 ;COMPLIMENTARY ARC LENGTH
             ) ;_ end of progn
             (progn (setq RANG (+ (* 2 pi) (- 2NDA 1STA))) ;ANGLE IN RADIANS
                    (setq ARL (* RAD RANG)) ;ARC LENGTH
                    (setq CARL (* RAD (- 1STA 2NDA))) ;COMPLIMENTARY ARC LENGTH
             ) ;_ end of progn
          ) ;_ end of IF
         )
         ;;get arc info from a entire arc
         ((equal "ARC" (cdr (assoc '0 ELIST)))
          (initget "All Part")
          (setq ASK (getkword "\nDimension All or Part of Arc? P/<A> "))
          (cond ((or (= ASK "All") (= ASK NIL))
                 (setq 1STA (cdr (assoc '50 ELIST))) ;1st ANGLE
                 (setq 2NDA (cdr (assoc '51 ELIST))) ;2nd ANGLE
                )
                ;; end all of arc
                ;;get arc info from segment of an arc
                ((= ASK "Part")
                 (setq CTR (cdr (assoc '10 ELIST))) ;Center Pt
                 (setq P1 (getpoint "\nPick 1st Arc End Point: ")) ;1st point
                 (setq P2 (getpoint "\nPick 2nd Arc End Point: ")) ;2nd point
                 (setq 1STA (angle CTR P1)) ;Calculates 1st ANGLE
                 (setq 2NDA (angle CTR P2)) ;Calculates 2nd ANGLE
                )
                ;;end part of arc
          ) ;_ end of cond
          (if (< 1STA 2NDA)
             (setq RANG (- 2NDA 1STA)) ;ANGLE IN RADIANS
             (setq RANG (+ (* 2 pi) (- 2NDA 1STA))) ;ANGLE IN RADIANS
          ) ;_ end of IF
          (setq ARL (* RAD RANG)) ;ARC LENGTH
         )
         ;;end arc info
   ) ;_ end of cond
   ;;end cond
) ;_ end of defun


(defun C:ARCD ()
   (START)
   (setq DIMMODE (getvar "lunits")) ;UNITS
   (setq DECPLS (getvar "dimdec")) ;DIMENSION DECIMAL PLACES
   (ARCL)
   (setq ARLT (rtos ARL DIMMODE DECPLS)) ;CONVERTS VALUE TO STRING
   (if (/= CARL NIL)
      (setq CARLT (rtos CARL DIMMODE DECPLS)) ;CONVERTS VALUE TO STRING
   ) ;_ end of if
   (cond ((equal "CIRCLE" (cdr (assoc '0 ELIST)))
          (initget "Yes No")
          (setq YESNO (getkword "\nDimension Complimentary Angle y/<N>? "))
          (if (or (= YESNO "No") (= YESNO NIL))
             (command "_.dim" "_.ang" "" CTR P1 P2 "_T" ARLT PAUSE "" "_.e")
             (progn ;text position for complimentary dim
                (setq TXTPOS (getpoint "\nPick Text Position.. "))
 ;dim compimentary arc segment
                (command "_.dim" "_.ang" "" CTR P1 P2 "_T" CARLT TXTPOS "" "_.e")
             ) ;_ end of progn
          ) ;_ end of if
         )
         ;;end circle/arc dim
         ((equal "ARC" (cdr (assoc '0 ELIST)))
          (if (= ASK "Part")
             (command "_.dim" "_.ang" "" CTR P1 P2 "_T" ARLT PAUSE "" "_.e")
 ;dim arc segment
             (command "_.dim" "_.ang" ENAME "_T" ARLT PAUSE "" "_.e") ;dim entire arc
          ) ;_ end of if
         )
         ;;end arc dim
   ) ;_ end of cond
   ;; end cond
   (if (equal "CIRCLE" (cdr (assoc '0 ELIST))) ;complimentary arc length display
      (if (= YESNO "Yes")
         (princ (strcat "\nComplimentary Arc Length = " (rtos ARL DIMMODE DECPLS)))
         (princ (strcat "\nComplimentary Arc Length = " (rtos CARL DIMMODE DECPLS)))
      ) ;_ end of if
   ) ;_ end of if
   (setq A NIL ;clear variables
         B NIL
         ARL NIL
         CARL NIL
         YESNO NIL
         ENAME NIL
         ELIST NIL
         DECPLS NIL
         DIMMODE NIL
         RANG NIL
         RAD NIL
         1STA NIL
         2NDA NIL
         P1 NIL
         P2 NIL
         ARLT NIL
         ASK NIL
         CTR NIL
         TXTPOS NIL
         OL_OSMODE NIL
   ) ;_ end of setq
   (FINISH)
   (princ)
) ;_ end of defun
(princ)



;;


;;; ARRDIST by David HArrington
;;; Array objects at any angle and divided between2 points
;;;
;;; Main program
;;;

(DEFUN C:ARD (/ pt1 pt2 ent num dist pt3 re str $error oldosmode olecho)
  (defun $error (msg /)
    (if (or (= msg "Function cancelled") (/= msg "quit / exit abort"))
      (princ (strcat "Error: " msg))
    )
    (command ".undo" "e" "undo" "")
    (command ".redraw")
	(setvar "cmdecho" olecho)
	(setvar "osmode" oldosmode)
    (setq *error* old_err
		  olecho nil
		  oldosmode nil
	)
    (princ)
  )
  (command ".undo" "be")
  (setq olecho (getvar "cmdecho")
  		oldosmode (getvar "osmode")
  		old_err *error*
        *error* $error
  )
  (setvar "cmdecho" 0)
  (prompt "\n   Arrdist - Array objects at any angle and divided between2 points")
  (setq pt1 (getpoint "\nSelect first point: ")
        pt2 (getpoint pt1 "\nSecond point: "))
  (prompt "\nSelect objects to array")
  (setq ent (ssget))
  (cond
  	(ent
      (setq num (getint "\nNumber of spaces: ")
            dist (/ (distance pt1 pt2) num)
            pt3 (polar pt1 (angle pt1 pt2) dist))
              (setvar "osmode" 0)
      (repeat (- num 1)
        (command ".copy" ent "" pt1 pt3)
        (setq pt3 (polar pt3 (angle pt1 pt2) dist))
      )
	  (initget "Yes")
      (setq str (getkword "\nCopy to end? <N> "))
      (if (= str "Yes")
        (command ".copy" ent "" pt1 pt2)
      )
      (command ".undo" "e")
      (command ".redraw")
      (setq *error* old_err
            old_err nil)
      (setvar "cmdecho" olecho)
      (setvar "osmode" oldosmode)
    )
	(T
	  (prompt "\nNo objects selected.")
	)
  )
  (princ)
)
(princ)



;;



;Functions to be used in your routines. By Alex Konieczka
;
; QUADRATIC CALS QV1 AND QV2 BY PASSING A,B, & C TO THE FUNCTION.
; GLAYLIST RETURNS A 'LAYLIST' OF SELECTED ITEMS
; D2R converts degree angle to radians
; R2D converts radians angle to degrees
; MIDPT returns the midpoint (mpt) of 2 points passed to it.
; PERPEN returns the perpendicular offset points (lpt rpt) of two points and distance (di) passed to it
; ASS returns the (cdr (assoc n)) of the the item. (ass 10) => (1 2 3)
; MODENT does an entmod on the item picked
; PRSET processes a selection set. Make and load a routine called (defun process () ..) then run prset
; LB locate bearing by p1 p2 dist and deg +=ccw
; APTXT will append text to picked text
; PRTXT will PREFIX text to picked text
; gent returns the entity name of the item picked
; nent returns the entity name of the item picked
; gents returns the entity name of the item passed to it from a selction set
; POLYPROP PUTS THE VERTICES AND BULGE FACTORS OF A PLINE INTO A LIST FOR USE.
; checklyr checks to see if a layer name exists and creates one if it does not.
; PV.LSP PLOT VIEW WILL WORK LIKE A SUB FUNCTION TO PLOT A VIEW AND WILL USE THE PC2 FILE FOR THE CURRENT DWG.  
; ang will return the angle between 3pts passed to it.  ang1 is internal angle and ang2 is the complementary.
; purgeblock X will purge blocks and cases of blocks in your drawing.  (purgeblocl "x")
; GSE  SELECTS ALL ITEMS VISIBLE ON THE SCREEN IN A PICKED LAYER of an entity type
; GSL  GETS ALL ITEMS VISIBLE ON THE SCREEN IN A PICKED LAYER
; GDL  GET ALL ITEMS IN A DRAWING IN A PICKED LAYER
; ELIST PUTS ALL SELECTED ENTITIES NAMES IN A LIST
; UCSTOG 0=GO TO WORLD  1=GO BACK TO UCS
; lastn  will put the last n items in dwg in a selection set called sset.

;///////////////////////////////////////////////////

; lln  will put the last n items in dwg in a selection set called sset.
(defun lln (n)
  (setq sset (ssadd) entlist nil)
(repeat n
(setq sset (ssadd (entlast) sset) entlist (append entlist (list (entlast)))) (entdel (entlast))
)
(foreach n entlist (entdel n))
(setq sset sset)  
)

;average  returns the average of a list of numbers passed to it.
(defun average ( avelist / avetot avecnt avelist) (setq avecnt 0 avetot 0) (foreach n avelist (progn (setq avetot (+ avetot n) avecnt (1+ avecnt)))) (/ avetot avecnt))

;///////////////////////////////////////////////////

;toggles ucs  from current to world coordinates.  0=world 1=current
(DEFUN UCSTOG (UCSVAL / UCSVAL)
(IF (= UCSVAL 0) 
(PROGN
(command "ucs" "d" "temp" )
(defun *error* ()(princ))
(command "ucs" "S" "temp" "UCS" "W"))
(PROGN
(command "ucs" "r" "temp" "ucs" "d" "temp" "redraw")
)))

;///////////////////////////////////////////////////

; GDL  GET ALL ITEMS IN A DRAWING IN A PICKED LAYER
(DEFUN GDL ()
(GENT)(SETQ FILTER (CONS 8 (ASS 8)) S (SSGET"X" (LIST FILTER)))
)

;///////////////////////////////////////////////////

; SELECTS ALL ITEMS VISIBLE ON THE SCREEN IN A PICKED LAYER of an entity type
(DEFUN C:GSE ()
(SETQ VCP (GETVAR "VIEWCTR") VVS (/ (GETVAR "VIEWSIZE") 2.0) VHS (* VVS 1.45) SET NIL)
(SETQ PT1 (LIST (- (CAR VCP) VHS) (- (CADR VCP) VVS) ) PT2 (LIST (+ (CAR VCP) VHS) (+ (CADR VCP) VVS)) )
(SETQ S (SSGET "C" PT1  PT2 ))
(PRINT "SELECT ITEM/LAYER YOU WANT in the DISPLAY: ")(GENT)
(setq len (sslength S))
(while (> len 0)
(setq n (entget (ssname S (- len 1))) NL (CDR (ASSOC 8 N)) Nt (CDR (ASSOC 0 N)) N (CDR (ASSOC -1 N)))
(IF (OR (/= (ASS 8) NL) (/= (ASS 0) Nt)) (SSDEL N S))
(SETQ LEN (1- LEN))
  )

)

;///////////////////////////////////////////////////

; GETS ALL ITEMS VISIBLE ON THE SCREEN IN A PICKED LAYER
(DEFUN C:GSL ()
(SETQ VCP (GETVAR "VIEWCTR") VVS (/ (GETVAR "VIEWSIZE") 2.0) VHS (* VVS 1.45) SET NIL)
(SETQ PT1 (LIST (- (CAR VCP) VHS) (- (CADR VCP) VVS) ) PT2 (LIST (+ (CAR VCP) VHS) (+ (CADR VCP) VVS)) )
(SETQ S (SSGET "C" PT1  PT2 ))
(PRINT "SELECT ITEM/LAYER YOU WANT in the DISPLAY: ")(GENT)
(setq len (sslength S))
(while (> len 0)
(setq n (entget (ssname S (- len 1))) NL (CDR (ASSOC 8 N)) N (CDR (ASSOC -1 N)))
(IF (/= (ASS 8) NL) (SSDEL N S))
(SETQ LEN (1- LEN))
  )
)

;///////////////////////////////////////////////////

; QUADRATIC CALS QV1 AND QV2 BY PASSING A,B, & C TO THE FUNCTION.
(DEFUN QUADRATIC (A B C / )
(SETQ QV1 (/ (+ (* B -1) (SQRT (- (* B B) (* 4 A C)))) (* 2 A))) 
(SETQ QV2 (/ (- (* B -1) (SQRT (- (* B B) (* 4 A C)))) (* 2 A))) 
(PRINC))

;///////////////////////////////////////////////////

; GLAYLIST RETURNS A STRING OF SELECTED ITEMS LAYERS 'LAYSTR'
(DEFUN C:GLAYLIST ( / )
(setq sset (ssget) laylist nil laystr nil)
(setq slen (sslength sset) clen 1)
(while (> slen (1- clen))
(setq entn (ssname sset (- clen 1)))
(gents entn)
(if (member (cdr (assoc 8 entcodes)) laylist)
(print)
(progn
(setq laylist (append laylist (list (cdr (assoc 8 entcodes)))))
))
(setq clen (1+ clen))
)
(foreach n laylist (progn
 (if (= laystr nil) 
  (progn (setq laystr n))
  (progn (setq laystr (strcat laystr "," n)))
 )))
(PRINC))

;///////////////////////////////////////////////////

; POLYPROP PUTS THE VERTICES AND BULGE FACTORS OF A PLINE INTO A LIST FOR USE.
(DEFUN POLYPROP ()
(PRINT "PICK POLYLINE: ")(GENT)
(setq a (car entn))
(setq b (entnext a))
(setq c (entget b))
(setq d (entnext c))
(setq e (entget d))
(setq f (entnext e))
(setq g (entget f))
(print "a:  ")(princ a)
(print "b:  ")(princ b)
(print "c:  ")(princ c)
(print "d:  ")(princ d)
(print "e:  ")(princ e)
(print "f:  ")(princ f)
(print "g:  ")(princ g)
(PRINC))

;///////////////////////////////////////////////////

; APTXT will append text to picked text
(DEFUN APtxt (ma / ma ne new old ff )
(WHILE (SETQ NE (ENTGET (CAR (ENTSEL " Pick Text to Change: "))))
(SETQ OLD (ASSOC 1 NE))
(SETQ OLD (CDR OLD))
(SETQ NEW (STRCAT OLD MA)) 
(SETQ NEW (CONS 1 NEW))
(setq old (cons 1 old))
(SETQ FF (SUBST NEW OLD NE))
(ENTMOD FF)
)
)

;///////////////////////////////////////////////////

; PRTXT will PREFIX text to picked text
(DEFUN PRtxt (ma / ma ne new old ff )
(WHILE (SETQ NE (ENTGET (CAR (ENTSEL " Pick Text to Change: "))))
(SETQ OLD (ASSOC 1 NE))
(SETQ OLD (CDR OLD))
(SETQ NEW (STRCAT MA OLD)) 
(SETQ NEW (CONS 1 NEW))
(setq old (cons 1 old))
(SETQ FF (SUBST NEW OLD NE))
(ENTMOD FF)
)
)

;///////////////////////////////////////////////////

; LLB locate bearing by p1 p2 dist and deg +=ccw
(defun llb (tpt1 tpt2 ang dis)
(polar tpt1 (+ (angle tpt1 tpt2) (d2r ang)) dis)
)

;///////////////////////////////////////////////////

; gent returns the entity name of the item picked
(defun gent ()
(setq entn (entsel))
(setq entcodes (entget (car entn)))
(setq entpt (cadr entn))
(setq entt (cdr (assoc 0 entcodes)))
)

;///////////////////////////////////////////////////

; nent returns the entity name of the item picked
(defun nent ()
(setq entn (nentsel))
(setq entcodes (entget (car entn)))
(setq entpt (cadr entn))
(setq entt (cdr (assoc 0 entcodes)))
)

;///////////////////////////////////////////////////

; gents returns the entity name of the item passed to it from a selction set
(defun gents (entname /)
(setq entn entname entcodes (entget entn) entpt nil)
(setq entt (cdr (assoc 0 entcodes)))
(princ))

;///////////////////////////////////////////////////

; modent does an entmod on the item picked
(defun modent (code newitem)
(IF (= (ass code) nil)
(PROGN (SETQ FF (APPEND ENTCODES (LIST (cons code newitem)))))
(PROGN (setq ff (subst (cons code newitem) (cons code (ass code)) entcodes)))
)
(entmod ff)
(if (listp entn)
(progn (entupd (CAR entn)))
(progn (entupd entn))
))

;///////////////////////////////////////////////////

; ass returns the (cdr (assoc n)) of the the item. (ass 10) => (10 . 1 2 3)
(defun ass (code / ) 
(cdr (assoc code entcodes))
)

;///////////////////////////////////////////////////

; perpen returns the perpendicular offset points (tpt3 tpt4 tpt5 tpt6) of two points and distance (di) passed to it
(defun perpen (tpt1 tpt2 offst / )
(setq tpt3 (polar tpt1 (+ (angle tpt1 tpt2) (/ pi 90)) offst))
(setq tpt4 (polar tpt2 (+ (angle tpt1 tpt2) (/ pi 90)) offst))
(setq tpt3 (polar tpt1 (- (angle tpt1 tpt2) (/ pi 2)) offst))
(setq tpt4 (polar tpt1 (+ (angle tpt1 tpt2) (/ pi 2)) offst))
(setq tpt5 (polar tpt2 (- (angle tpt2 tpt1) (/ pi 2)) offst))
(setq tpt6 (polar tpt2 (+ (angle tpt2 tpt1) (/ pi 2)) offst))
)

;///////////////////////////////////////////////////

; R2D converts radians angle to degrees
(defun r2d (rad / r2d) 
  (setq r2d (/ (* rad 180) pi))    ;rad times 180/pi
)

;///////////////////////////////////////////////////

; D2R converts degree angle to radians
(defun d2r (deg / d2r) 
  (setq d2r (/ (* deg pi) 180))    ;deg * pi /180
)

;///////////////////////////////////////////////////

; checklyr checks to see if a layer name exists and creates one if it does not.
(defun checklyr (chlay lcol ltyp/ )
(if (= lcol nil) (setq lcol 7))(if (= ltyp nil) (setq ltyp "continuous"))
(if (= (tblsearch "layer" chlay) nil)(progn 
(print (strcat chlay " was not found."))
(command "layer" "m" chlay "c" lcol "" "lt" ltyp "" "")
))
(print))

;///////////////////////////////////////////////////

; txt make
(defun txt (mytxt mypnt myang / mytxt mypnt myang)
(setq a '((0 . "TEXT") (10 123.205 163.634 0.0) (40 . 2.5) (41 . 1.0) (51 . 0.0) (71 . 0) (72 . 0) (11 0.0 0.0 0.0)  (210 0.0 0.0 1.0)) )
(UCSTOG 0)
(if (or (= mypnt nil) (= mypnt "")) (progn (setq mypnt (cadr (grread 1))) ) )
(if (numberp mytxt) (progn (setq mytxt (rtos mytxt 2 3)) ) )
(if (numberp myang) (progn (setq a (append a (list (cons 50 (d2r myang)))))))
(setq a (append a (list (cons 1 mytxt))))
(setq a (append a (list (cons 10 mypnt))))
(setq a (append a (list (cons 7 (getvar "textstyle")))))
(setq a (append a (list (cons 40 (getvar "textsize")))))
(entmake a)
(UCSTOG 1)
(princ))

;///////////////////////////////////////////////////

(defun purgeblock (pbname /)
  (setq flag nil flag (ssget "x" (list (cons 2 pbname))))
  (if (/= flag nil) (progn (command "erase" flag "")))
 (setq flag T)
  (while (setq entcodes (tblnext "block" flag))
    (setq flag nil)
    (if (= (strcase pbname) (ass 2))  (progn (command "purge" "B" pbname "n")))
  )
  (princ)
)

;///////////////////////////////////////////////////

(defun mlast () (COMMAND "MOVE" (entlast) "" (cadr (grread 1))) )

; getval, by alex konieczka
; used to get a number keeping default if old val is entered.
; can use like this:   (setq x (getval x "your msg"))
(DEFUN getval (val msg /)
(print)(princ msg)(setq oldval val)
(prompt " <")(princ val)(prompt ">: ")
(setq t (getstring))
  (if (= t "") (progn (setq newval oldval)) (progn (setq newval (atof t))) )
)

;///////////////////////////////////////////////////

; Midpt returns the midpoint of two points passed to it
(defun midpt (tpt1 tpt2 / )
(list (+ (car tpt1) (/ (- (car tpt2) (car tpt1)) 2.0)) (+ (cadr tpt1) (/ (- (cadr tpt2) (cadr tpt1)) 2.0)) (+ (caddr tpt1) (/ (- (caddr tpt2) (caddr tpt1)) 2.0)) )
)

;///////////////////////////////////////////////////

; list layer even if xref or block
(defun lil ()
(print "Pick Layer: ")
(setq ll nil n1 (nentsel) e1 (nth (1- (length n1)) n1))
(foreach n e1 (progn
(setq ll (append ll (list (cdr (assoc 8 (entget n))))))
))
(print)(print ll)(print)(setq n (getint "Select the item you want (e.g. 1 2 3 ...)"))
(setq l (nth (1- n) ll))
(nth (1- n) ll)
)

;///////////////////////////////////////////////////

; ELIST PUTS ALL SELECTED ENTITIES NAMES IN A LIST from list var called sset
(DEFUN C:ELIST ()
(setq cnt 0 ENTLIST NIL entvals nil)

(while (< cnt (sslength sset))
(gents (ssname sset cnt))
(SETQ ENTLIST (APPEND ENTLIST (LIST (ASS -1)  )))
(if (= (ass 0) "TEXT") (progn (SETQ ENTvals (APPEND ENTvals (LIST (atof (ASS 1)  )))  )))
(setq cnt (1+ cnt))
) ;end while
(princ))  

;///////////////////////////////////////////////////

;;


;===============================================================================
;     LAYSET - Set layer by picking an existing entity
;===============================================================================

(defun C:AS ()

   (prompt "\nLAYSET - Set layer by picking an existing entity")

   (setq OLD_CMDECHO (getvar "CMDECHO"))
   (setvar "CMDECHO" 0)

   (setq EXISTING_PICK (entsel "\nPick an entity on an existing layer : "))

   (if EXISTING_PICK
       (progn
          (setq EXISTING_ENTITY  (car EXISTING_PICK))
          (setq EXISTING_ENTLIST (entget EXISTING_ENTITY))
          (setq EXISTING_LAYER   (cdr (assoc 8 EXISTING_ENTLIST)))

          (command ".LAYER" "S" EXISTING_LAYER "")
          (prompt (strcat "\n" EXISTING_LAYER " is now the current layer."))
       )
   )

   (setvar "CMDECHO" OLD_CMDECHO)

   (princ)
)


;;

;Desconngela todos los layers
(defun c:AT (/ OLDECH )

(SETQ OLDECH (GETVAR "CMDECHO") )
(SETVAR "CMDECHO" 0)
(COMMAND ".LAYER" "T" "*" "")
(SETVAR "CMDECHO" OLDECH)
(PRINC))

;;


;Attribute Search and Replce Routine
;by William R. Kincaid
;Rev. 1       01/07/88
;Modified CHGTXT routine from AutoDesk
;Incorporating parts of REVISE routine
;also from AutoDesk Lisp Manual...
;------------------------------------------------------------------
(defun fld (num)
   (cdr (assoc num d))
)
;attribute search and replace routine
(defun C:ATEDIT (/ adj p l n e os as ns st s nsl osl sl si chf chm)
   (setq p (ssget))                  ; Select objects
   (if p (progn                      ; If any objects selected
      (setq osl (strlen (setq os (getstring "\nOld string: " t))))
      (setq nsl (strlen (setq ns (getstring "\nNew string: " t))))
      (setq l 0 chm 0 n (sslength p))
      (setq adj 
         (cond 
            ((/= osl nsl) (- nsl osl))
            (T nsl)
         )
      )
      (while (< l n)                   ; For each selected object...
         (setq d (entget (setq e (ssname p l))))
         (if (and (= (fld 0) "INSERT") ; Look for INSERT entity type (group 0)
                  (= (fld 66) 1))      ; With attributes
                  (progn
                     (setq e (entnext e));get subentities
                     (while e
                        (setq d (entget e))
                        (cond ((= (fld 0) "ATTRIB") ;is sub ent. an attribute
                           (setq chf nil si 1)
                           (setq s (cdr (setq as (assoc 1 d))))
                           (while (= osl (setq sl (strlen
                                         (setq st (substr s si osl)))))
                              (cond
                                 ((= st os)
                                    (setq s (strcat (substr s 1 (1- si)) ns
                                                    (substr s (+ si osl))))
                                    (setq chf t)    ; Found old string
                                    (setq si (+ si adj)))
                              )
                              (setq si (1+ si))
                           )
                           (if chf (progn        ; Substitute new string for old
                              (setq d (subst (cons 1 s) as d))
                              (entmod d)         ; Modify the ATTRIB entity
                              (entupd e)         ; update block
                              (setq chm (1+ chm))
                           ))
                        (setq e (entnext e))
                        )
                        ((= (fld 0) "SEQEND")
                           (setq e nil)) ; stop scan
                        (T (setq e (entnext e)))
                        );end cond
                     );end while
                  ) ;end progn
          ) ;end if
         (setq l (1+ l))
      );end while
   ))
   (princ "Changed ")                ; Print total lines changed
   (princ chm)
   (princ " attributes.")
   (terpri)
)


;;


; *******************************************************************
;                          ATTREDEF.LSP
;
; This program allows you to redefine a Block and update the
; Attributes associated with any previous insertions of that Block.
; All new Attributes are added to the old Blocks and given their
; default values. All old Attributes with equal tag values to the new
; Attributes are redefined but retain their old value. And all old
; Attributes not included in the new Block are deleted.
;
; Note that if handles are enabled, new handles will be assigned to
; each redefined block.
;
; Written by Karry Layden - May 1988
; *******************************************************************


; Oldatts sets "old" to the list of old Attributes for each Block.
; The list does not include constant Attributes.

(defun oldatts (/ an e)
   (setq an (entnext b1))
   (setq e (entget an))
   (while (and (= (cdr (assoc 0 e)) "ATTRIB")
               (member (cdr (assoc 70 e)) '(0 1 4 5 8 9 12 13)))
      (if old
         (setq old (cons e old))
         (setq old (list e))
      )
      (setq an (entnext an))
      (if an
         (setq e (entget an))
      )
      (setq count (1+ count))         ; count the number of old atts
   )
)

; Newatts sets "new" to the list of new Attributes in the new Block.
; The list does not include constant Attributes.

(defun newatts (ssetn l / i an e)
   (setq i 0)
   (while (<= i l)
      (setq an (ssname ssetn i))
      (setq e (entget an))
      (if (and (= (cdr (assoc 0 e)) "ATTDEF")
               (member (cdr (assoc 70 e)) '(0 1 4 5 8 9 12 13)))
            (progn
               (if new
                  (setq new (cons e new))
                  (setq new (list e))
               )
               (setq n (1+ n))        ; count the number of new atts
            )
      )
      (setq i (1+ i))
   )
)

; Compare the list of "old" to the list of "new" Attributes and make
; the two lists "same" and "preset". "Same" contains the old values of
; all the Attributes in "old" with equal tag values to some Attribute
; in "new" and the default values of all the other Attributes. "Preset"
; contains the preset Attributes in old with equal tag values to some
; Attribute in new.

(defun compare (/ i j)
   (setq i 0
         j 0
         eds 0
         same nil
         amount 0
         preset nil)
   (while (<= i (1- n))
      (cond ((= (cdr (assoc 2 (nth j old))) (cdr (assoc 2 (nth i new))))
                (if (member (cdr (assoc 70 (nth i new))) '(8 9 12 13))
                   (progn
                      (if preset
                         (setq preset (cons (nth j old) preset))
                         (setq preset (list (nth j old)))
                      )
                      (setq eds (1+ eds)) ; count equal preset atts
                   )
                   (if same
                      (setq same (cons (cdr (assoc 1 (nth j old))) same))
                      (setq same (list (cdr (assoc 1 (nth j old)))))
                   )
                )
                (if (member (cdr (assoc 70 (nth i new))) '(4 5))
                   (setq amount (+ 1 amount))
                )
                (setq i (1+ i))
                (setq j 0)
             )
             ((= j (1- count))
                (if (not (member (cdr (assoc 70 (nth i new))) '(8 9 12 13)))
                   (if same
                      (setq same (cons (cdr (assoc 1 (nth i new))) same))
                      (setq same (list (cdr (assoc 1 (nth i new)))))
                   )
                )
                (if (member (cdr (assoc 70 (nth i new))) '(4 5))
                   (setq amount (+ 1 amount))
                )
                (setq i (1+ i))
                (setq j 0)
             )
             (t
                (setq j (1+ j))
             )
      )
   )
)

; Find the entity for each of the "preset" Attributes in the newly
; inserted Block.

(defun findpt ()
   (setq test T)
   (setq en (entnext e1))
   (setq e (entget en))
   (while test
      (if (and (= (cdr (assoc 0 e)) "ATTRIB") (= (cdr (assoc 2 e)) tag))
         (setq test nil)
         (progn
            (setq ex en)
            (setq en (entnext ex))
            (if e
               (setq e (entget en))
            )
         )
      )
   )
)

; Insert a new Block on top of each old Block and set its new Attributes
; to their values in the list "same". Then replace each of the "preset"
; Attributes with its old value.

(defun redef (/ xsf ysf zsf ls i e1 v)
   (command "ucs" "e" b1)             ; define the block's UCS
   (setq xsf (cdr (assoc 41 (entget b1)))) ; find x scale factor
   (setq ysf (cdr (assoc 42 (entget b1)))) ; find y scale factor
   (setq zsf (cdr (assoc 43 (entget b1)))) ; find z scale factor
   (setq ls (1- (length same)))
   (setq i 0)
   (command "insert" bn "0.0,0.0,0.0" "XYZ" xsf ysf zsf "0.0")
   (while (<= i ls)                   ; set attributes to their values
      (command (nth i same))
      (setq i (1+ i))
   )
   (while (< 0 amount)
      (command "")                    ; at prompts, verify attributes
      (setq amount (1- amount))
   )
   (setq i 0)
   (setq e1 (entlast))
   (while (< 0 eds)                   ; edit each of the "preset" attributes
      (setq tag (cdr (assoc 2 (nth i preset))))
      (setq v (cdr (assoc 1 (nth i preset))))
      (findpt)                        ; find the entity to modify
      (setq e (subst (cons 1 v) (assoc 1 e) e))
      (entmod e)                      ; modify the entity's value
      (setq i (1+ i))
      (setq eds (1- eds))
   )
   (command "ucs" "p")                ; restore the previous UCS
)

; System variable save

(defun modes (a)
   (setq mlst '())
   (repeat (length a)
      (setq mlst (append mlst (list (list (car a) (getvar (car a))))))
      (setq a (cdr a)))
)

; System variable restore

(defun moder ()
   (repeat (length mlst)
      (setvar (caar mlst) (cadar mlst))
      (setq mlst (cdr mlst))
   )
)

; Internal error handler

(defun attrerr (s)                    ; If an error (such as CTRL-C) occurs
                                      ; while this command is active...
   (if (/= s "Function cancelled")
      (princ (strcat "\nError: " s))
   )
   (moder)                            ; restore saved modes
   (setq *error* olderr)              ; restore old *error* handler
   (princ)
)

; Main program

(defun C:ATRE (/ k n olderr bn sseto ssetn pt l new
                     old same presets b1 count amount)
   (setq k 0
         n 0
         test T
         olderr *error*
         *error* attrerr)

   (modes '("CMDECHO" "ATTDIA" "ATTREQ" "GRIDMODE" "UCSFOLLOW"))
   (setvar "cmdecho" 0)               ; turn cmdecho off
   (setvar "attdia" 0)                ; turn attdia off
   (setvar "attreq" 1)                ; turn attreq on
   (setvar "gridmode" 0)              ; turn gridmode off
   (setvar "ucsfollow" 0)             ; turn ucsfollow off

   (while test
      (setq bn (strcase (getstring "\nName of Block you wish to redefine: ")))
      (if (null (setq sseto (ssget "X" (list (cons 2 bn)))))
         (progn
            (princ "\nBlock ")
            (princ bn)
            (princ " is not defined. Please try again.")
         )
         (setq test nil)
      )
   )
   (setq test T)
   (while test
      (princ "\nSelect new Block... ")
      (if (null (setq ssetn (ssget)))
         (princ "\nNo new Block selected. Please try again.")
         (setq test nil)
      )
   )
   (initget 17)
   (setq pt (getpoint "\nInsertion base point of new Block: "))
   (setq l (1- (sslength sseto)))
   (newatts ssetn (1- (sslength ssetn))) ; find the list of new attributes
   (command "block" bn "Y" pt ssetn "")  ; redefine the block
   (while (<= k l)
      (setq b1 (ssname sseto k))      ; For each old block...
      (setq old nil)
      (setq count 0)
      (oldatts)                       ; find the list of old attributes,
      (compare)                       ; compare the old list with the new,
      (redef)                         ; and redefine its attributes.
      (entdel b1)                     ; delete the old block.
      (setq k (1+ k))
   )
   (moder)                            ; restore saved modes
   (command "regenall")
   (setq *error* olderr)              ; restore old *error* handler
   (princ)
)


;;


;;; BXY by David Harrington
;;; Edit block x,y and z values
;;;
;;; Main Program
;;;
(defun c:B1 (/ ss xs ys zs num x na lst editxyz_error olcmdecho old_err) 
	(defun editxyz_error (msg) 
		(if (or
				(= msg "Function cancelled")
				(/= msg "quit / exit abort")
			) 
			(princ (strcat "Error: " msg))
		) 
		(command ".UNDO" "E" "UNDO" "") 
		(setq *error*  old_err
			  old_err  nil
		)
		(setvar "CMDECHO" olcmdecho)
		(princ)
	) 
	(setq old_err *error* 
		  olcmdecho (getvar "CMDECHO")
		  *error* editxyz_error
	) 
	(setvar "CMDECHO" 0)
	(princ "\n   EDITXYZ - Edit block x, y and z values")
	(command ".UNDO" "BE") 	(prompt "\nSelect Xrefs or Blocks to rescale: ")
	(cond
		((setq ss (ssget '((0 . "INSERT"))))
			(setq num (sslength ss))
			(setq x 0)
			(repeat num 
				(setq na (ssname ss x))
				(setq lst (entget na))
				(setq lst (subst (cons 41 1) (assoc 41 lst) lst))
				(setq lst (subst (cons 42 1) (assoc 42 lst) lst))
				(setq lst (subst (cons 43 1) (assoc 43 lst) lst))
				(entmod lst) 
				(entupd na) 
				(setq x (+ x 1))
			)
		)
	)
	(command ".UNDO" "E") 
	(setq *error* old_err)
	(setvar "CMDECHO" olcmdecho)
	(princ)
)


;;


;;; BXY by David Harrington; Modified by Lee Mac, Paulo Gil
;;; Special thanks to 'awerning'
;;; http://discussion1.autodesk.com/forums/thread.jspa;jsessionid=HkgcLQcSyHPFQMjbGV18ST1VgVTWdRd2dQmhhHnbyn169P38Xn38!-2024303930?messageID=6232786&#6232786
;;; updates selected blocks x,y and z values to scale 1,1,1 even if any of their values is negative.
;;; This command will preserve negative values but change their scales to 1,1,1
;;;
;;; Main Program
;;;
(defun c:B1- (/ ss xs ys zs num x na lst editxyz_error olcmdecho old_err) 
	(defun editxyz_error (msg) 
		(if (or
				(= msg "Function cancelled")
				(/= msg "quit / exit abort")
			) 
			(princ (strcat "Error: " msg))
		) 
		(command ".UNDO" "E" "UNDO" "") 
		(setq *error*  old_err
			  old_err  nil
		)
		(setvar "CMDECHO" olcmdecho)
		(princ)
	) 
	(setq old_err *error* 
		  olcmdecho (getvar "CMDECHO")
		  *error* editxyz_error
	) 
	(setvar "CMDECHO" 0)
	(princ "\n   EDITXYZ - Edit block x, y and z values")
	(command ".UNDO" "BE") 	(prompt "\nSelect Xrefs or Blocks to rescale: ")
	(cond
		((setq ss (ssget '((0 . "INSERT"))))
			(setq num (sslength ss))
			(setq x 0)
			(repeat num 
				(setq na (ssname ss x)) 
				(setq lst (entget na))
                                (if (> 0 (cdr (assoc 41 lst)))
				  (setq lst (subst (cons 41 (* -1 1)) (assoc 41 lst) lst))
                                  (setq lst (subst (cons 41 1) (assoc 41 lst) lst))
                                )
                                (if (> 0 (cdr (assoc 42 lst)))
				  (setq lst (subst (cons 42 (* -1 1)) (assoc 42 lst) lst))
                                  (setq lst (subst (cons 42 1) (assoc 42 lst) lst))
                                )
                                (if (> 0 (cdr (assoc 43 lst)))
				  (setq lst (subst (cons 43 (* -1 1)) (assoc 43 lst) lst))
                                  (setq lst (subst (cons 43 1) (assoc 43 lst) lst))
                                )
				(entmod lst) 
				(entupd na) 
				(setq x (+ x 1))
			)
		)
	)
	(command ".UNDO" "E") 
	(setq *error* old_err)
	(setvar "CMDECHO" olcmdecho)
	(princ)
)


;;



;;; ;BA.lsp  -BACKGROUND FILL ALL 'LIGHT VERSION'-
;;; ;Made for M3 Mexicana. Coding Selected by Paulo Gil Soto. December 2009
;;; ;This routine will set a background color fill to all selected text, 
;;; ;mtext and dimensions, text objects will be converted to mtext with width=0
;;; ;and then will add their text box control points
;;; ;It will bring objects modified objects to front
;;; ;Reviewed and modified by: Alan J. Thompson. 'alanjt@gmail.com'
;;; ;And Marco Antonio Jacinto Perez 'mcoan001@hotmail.com'
;;; ;December 2009
;;; ; 'light version' Will skip draworder operations to make it faster.

(VL-LOAD-COM)
(DEFUN c:BA (/ *error* ttm2 ss elist sel1 sel3 dimt)

;;; error handler
  (DEFUN *error* (#Message)
    (AND dimt (SETVAR "dimtfill" dimt))
    (AND #Message
	 (NOT (WCMATCH (STRCASE #Message) "*BREAK*,*CANCEL*,*QUIT*"))
	 (PRINC (STRCAT "\nError: " #Message))
    ) ;_ and
  ) ;_ defun

;; Using code from Roberto Gonzalez -robierzogg- from HISPACAD
;; http://www.hispacad.com/foro/viewtopic.php?p=142823&sid=b23c3147d2a06a29d1dfd60078f79c08
;; This routine works only if Express tools are installed
;; Convert selected text into Mtext 


  (COMMAND "undo" "begin")		;beginning of undo group
  (DEFUN ttm2 (name_n / collect n name_n insertpt name_n1 newlist)
    (SETQ insertpt (ASSOC 10 (ENTGET name_n)))
					; Convert Text to Mtext, using the
					; EXPRESS
					; command
    (COMMAND "txt2mtxt" name_n "")
					; We set their original insertion point
					; here
;;;creo que esta parte mueve los nuevos mtextos de posicion hacia arriba
;;;no se por que lo pusieron?
    (SETQ name_n1 (ENTLAST))
    (SETQ newlist (SUBST insertpt
			 (ASSOC 10 (ENTGET name_n1))
			 (ENTGET name_n1)
		  )
    )
    (ENTMOD newlist)
    (SETQ newlist (SUBST '(71 . 7)
			 (ASSOC 71 (ENTGET name_n1))
			 (ENTGET name_n1)
		  )
    )
    (ENTMOD newlist)
    (SETQ newlist (SUBST '(46 . 0)
			 (ASSOC 46 (ENTGET name_n1))
			 (ENTGET name_n1)
		  )
    )
    (ENTMOD newlist)
    (SETQ newlist (SUBST '(41 . 0)
			 (ASSOC 41 (ENTGET name_n1))
			 (ENTGET name_n1)
		  )
    )
    (ENTMOD newlist)
  ) ;_ defun


;;; Aqui pongo la variable Mtexts como un parametro, el cual corresponde al ss
;;; que vas creando con los nuevos Mtextos
  (DEFUN mw5 (mtexts / mtexts idx ename EntData dxf42 dxf43 EntData1)
					;Reset Width - Mtext
    (IF	mtexts
;; Aqui se hace el cambio para que en lugar
;; de cambiar todos los mtextos, solo modifique los que recien creaste
;; (setq mtexts (ssget "_X" '((0 . "MTEXT"))))
;; Rogerio Brazil from an autodesk Discussion groups
;; http://discussion.autodesk.com/forums/thread.jspa?messageID=6339167&tstart=0
      (PROGN
	(SETQ idx 0)
	(REPEAT	(SSLENGTH mtexts)
	  (SETQ ename (SSNAME mtexts idx))
	  (SETQ EntData (ENTGET ename '("*")))
	  (SETQ dxf42 (* (CDR (ASSOC 42 EntData))1.07))
	  (SETQ dxf43 (CDR (ASSOC 43 EntData)))
	  (SETQ	EntData1
		 (ENTMOD (SUBST (CONS 41 dxf42) (ASSOC 41 EntData) EntData))
	  )
	  (ENTMOD (SUBST (CONS 46 dxf43) (ASSOC 46 EntData1) EntData1)
	  )
	  (SETQ idx (1+ idx))
	)				;progn
      )					;repeat
      (PRINC "\n Null Selection!")
    )					;if
    (PRINC)
  )


;;
;;
;;				; MAIN ROUTINE
;;
;;
;; Some part of code from Tom Beauford, from AUGI
;; http://forums.augi.com/showthread.php?t=77962
;; Set 'Border Offset Factor' to 1.15

  (SETQ dimt (GETVAR "dimtfill"))
  (SETVAR "dimtfill" 1)

  (PRINC
    "\nSelect Dimensions and text to apply the background fill and update...: "
  )
  (AND (SETQ ss (SSGET "_:L" '((0 . "MTEXT,*DIMENSION*,TEXT"))))
       (FOREACH	x (VL-REMOVE-IF 'LISTP (MAPCAR 'CADR (SSNAMEX ss)))
	 (COND
	   ((EQ "MTEXT" (CDR (ASSOC 0 (SETQ elist (ENTGET x)))))
	    (VLA-PUT-BACKGROUNDFILL
	      (VLAX-ENAME->VLA-OBJECT x)
	      :VLAX-TRUE
	    )
	    (SETQ elist	(SUBST (CONS 41 0.0) (ASSOC 41 elist) elist)
		  elist	(SUBST (CONS 46 0.0) (ASSOC 46 elist) elist)
		  elist	(SUBST (CONS 45 1.15) (ASSOC 45 elist) elist)
		  elist	(SUBST (CONS 421 256) (ASSOC 421 elist) elist)
	    ) ;_ setq
	    (ENTMOD elist)
	   )
	   ((EQ "TEXT" (CDR (ASSOC 0 (ENTGET x))))
	    (ttm2 x)
	    (SSDEL x ss)
	    (VLA-PUT-BACKGROUNDFILL
	      (VLAX-ENAME->VLA-OBJECT (SETQ elist (ENTLAST)))
	      :VLAX-TRUE
	    )
	    (SSADD elist ss)
	    (SETQ elist (ENTGET elist))
	    (SETQ elist	(SUBST (CONS 45 1.15) (ASSOC 45 elist) elist)
		  elist	(SUBST (CONS 421 256) (ASSOC 421 elist) elist)
	    ) ;_ setq
	    (ENTMOD elist)
	   )

	   (T T)
	 ) ;_ cond
       ) ;_ foreach
       (VL-CMDF "_.-dimstyle" "_apply" ss "")
       (VL-CMDF "_.draworder" ss "" "_f")
  ) ;_ and

  (SETVAR "dimtfill" dimt)

  (PRINC)
  (COMMAND "undo" "end")		;end of undo group

  (mw5 ss)
(setvar "orthomode" 0)
) ;_ defun



;|ซVisual LISPฉ Format Optionsป
(80 2 40 2 nil "end of " 60 9 2 0 0 T T T T)
;*** DO NOT add text below the comment! ***|;



;;


;;; ;BA.lsp  -BACKGROUND FILL ALL-
;;; ;Made for M3 Mexicana. Coding Selected by Paulo Gil. December 2009
;;; ;This routine will set a background color fill to all selected text, 
;;; ;mtext and dimensions, it will update dimensions to current Dimstyle
;;; with
;;; ;Dimtfill set to 1 temporarily for this purpose, so it works for current 
;;; ;Dimscale only, text objects will be converted to mtext with width=0
;;; ;and then will add their text box control points
;;; ;It will bring objects in layer 'Dims' to front at the end, as well as other
;;; ;Draworder operations according to M3 standards.
;;; ;Reviewed and modified by: Alan J. Thompson. 'alanjt@gmail.com'
;;; ;And Marco Antonio Jacinto Perez 'mcoan001@hotmail.com'
;;; ;December 2009

(VL-LOAD-COM)
(DEFUN c:BAD (/ *error* ttm2 ss elist sel1 sel3 dimt)
;;; error handler
  (DEFUN *error* (#Message)
    (AND dimt (SETVAR "dimtfill" dimt))
    (AND #Message
  (NOT (WCMATCH (STRCASE #Message) "*BREAK*,*CANCEL*,*QUIT*"))
  (PRINC (STRCAT "\nError: " #Message))
    ) ;_ and
  ) ;_ defun
;; Using code from Roberto Gonzalez -robierzogg- from HISPACAD
;; http://www.hispacad.com/foro/viewtopic.php?p=142823&sid=b23c3147d2a06a29d1dfd60078f79c08
;; This routine works only if Express tools are installed
;; Convert selected text into Mtext 
 
  (COMMAND "undo" "begin")  ;beginning of undo group
  (DEFUN ttm2 (name_n / collect n name_n insertpt name_n1 newlist)
    (SETQ insertpt (ASSOC 10 (ENTGET name_n)))
     ; Convert Text to Mtext, using the
     ; EXPRESS
     ; command
    (COMMAND "txt2mtxt" name_n "")
     ; We set their original insertion point
     ; here
;;;creo que esta parte mueve los nuevos mtextos de posicion hacia arriba
;;;no se por que lo pusieron?
    (SETQ name_n1 (ENTLAST))
    (SETQ newlist (SUBST insertpt
    (ASSOC 10 (ENTGET name_n1))
    (ENTGET name_n1)
    )
    )
    (ENTMOD newlist)
    (SETQ newlist (SUBST '(71 . 7)
    (ASSOC 71 (ENTGET name_n1))
    (ENTGET name_n1)
    )
    )
    (ENTMOD newlist)
    (SETQ newlist (SUBST '(46 . 0)
    (ASSOC 46 (ENTGET name_n1))
    (ENTGET name_n1)
    )
    )
    (ENTMOD newlist)
    (SETQ newlist (SUBST '(41 . 0)
    (ASSOC 41 (ENTGET name_n1))
    (ENTGET name_n1)
    )
    )
    (ENTMOD newlist)
  ) ;_ defun
 
;;; Aqui pongo la variable Mtexts como un parametro, el cual corresponde al ss
;;; que vas creando con los nuevos Mtextos
  (DEFUN mw5 (mtexts / mtexts idx ename EntData dxf42 dxf43 EntData1)
     ;Reset Width - Mtext
    (IF mtexts
;; Aqui se hace el cambio para que en lugar
;; de cambiar todos los mtextos, solo modifique los que recien creaste
;; (setq mtexts (ssget "_X" '((0 . "MTEXT"))))
;; Rogerio Brazil from an autodesk Discussion groups
;; http://discussion.autodesk.com/forums/thread.jspa?messageID=6339167&tstart=0
      (PROGN
 (SETQ idx 0)
 (REPEAT (SSLENGTH mtexts)
   (SETQ ename (SSNAME mtexts idx))
   (SETQ EntData (ENTGET ename '("*")))
   (SETQ dxf42 (* (CDR (ASSOC 42 EntData))1.07))
   (SETQ dxf43 (CDR (ASSOC 43 EntData)))
   (SETQ EntData1
   (ENTMOD (SUBST (CONS 41 dxf42) (ASSOC 41 EntData) EntData))
   )
   (ENTMOD (SUBST (CONS 46 dxf43) (ASSOC 46 EntData1) EntData1)
   )
   (SETQ idx (1+ idx))
 )    ;progn
      )     ;repeat
      (PRINC "\n Null Selection!")
    )     ;if
    (PRINC)
  )
 
;;
;;
;;    ; MAIN ROUTINE
;;
;;
;; Some part of code from Tom Beauford, from AUGI
;; http://forums.augi.com/showthread.php?t=77962
;; Set 'Border Offset Factor' to 1.15

  (SETQ dimt (GETVAR "dimtfill"))
  (SETVAR "dimtfill" 1)
  (PRINC
    "\nSelect Dimensions and text to apply the background fill and update...: "
  )
  (AND (SETQ ss (SSGET "_:L" '((0 . "MTEXT,*DIMENSION*,TEXT"))))
       (FOREACH x (VL-REMOVE-IF 'LISTP (MAPCAR 'CADR (SSNAMEX ss)))
  (COND
    ((EQ "DIMENSION" (CDR (ASSOC 0 (SETQ elist (ENTGET x)))))
     (VLA-PUT-TEXTFILL
       (VLAX-ENAME->VLA-OBJECT x)
       :VLAX-TRUE
     )
     (ENTMOD elist)
    )
    ((EQ "MTEXT" (CDR (ASSOC 0 (SETQ elist (ENTGET x)))))
     (VLA-PUT-BACKGROUNDFILL
       (VLAX-ENAME->VLA-OBJECT x)
       :VLAX-TRUE
     )
     (SETQ elist (SUBST (CONS 41 0.0) (ASSOC 41 elist) elist)
    elist (SUBST (CONS 46 0.0) (ASSOC 46 elist) elist)
    elist (SUBST (CONS 45 1.15) (ASSOC 45 elist) elist)
    elist (SUBST (CONS 421 256) (ASSOC 421 elist) elist)
     ) ;_ setq
     (ENTMOD elist)
    )
    ((EQ "TEXT" (CDR (ASSOC 0 (ENTGET x))))
     (ttm2 x)
     (SSDEL x ss)
     (VLA-PUT-BACKGROUNDFILL
       (VLAX-ENAME->VLA-OBJECT (SETQ elist (ENTLAST)))
       :VLAX-TRUE
     )
     (SSADD elist ss)
     (SETQ elist (ENTGET elist))
     (SETQ elist (SUBST (CONS 45 1.15) (ASSOC 45 elist) elist)
    elist (SUBST (CONS 421 256) (ASSOC 421 elist) elist)
     ) ;_ setq
     (ENTMOD elist)
    )
    (T T)
  ) ;_ cond
       ) ;_ foreach
       (VL-CMDF "_.-dimstyle" "_apply" ss "")
       (VL-CMDF "_.draworder" ss "" "_f")
  ) ;_ and
(setq 
    BkLst 
           '("CENTER LINE2"   "COLUMN ROW BUBBLE2"  "DETAIL BUBBLE 12" 
             "DETAIL BUBBLE2"     "DUST PICK UP POINT2"     "EQUIPMENT TAG2" 
             "FULL SECTION LR2"     "FULL SECTION UD2"     "FULL SECTION2"  
             "MATCH LINE SP2"     "MATCH LINE2"     "NORTH ARROW2"     
             "NOTE BOX2"     "NOTE ENCL2"     "PARTIAL SECTION T2"     
             "PARTIAL SECTION2"     "PLATE2"     "REVISION2"     
             "SAMPLE NUMBER2"     "SECTION CUT UD2"     "SECTION CUT2"     
             "STAMP BIG2"     "STAMP SMALL2"     "STREAM NUMBER2"     
             "STREAM SEQUENCE2"     "TAG2"     "TITLE 12"     
             "TITLE BUBBLE 12"     "TITLE BUBBLE2"     "TITLE2"     
             "WORK POINT2"     "ROOMTAG"     "ROOMTAG2"     "DOORTAG"     
             "WALLTAG"     "WINDOWTAG"     "MULTIPLE DETAIL"     
             "IND WALL CEIL 1"     "IND WALL UP 1"     "IND WALL L 1"  
             "IND WALL R 1"     "IND WALL DN 1"     "MULTIPLE DETAIL"
        ) 
    NomBloques (car BkLst) 
    BkName     (mapcar '(lambda    (x) 
              (setq NomBloques (strcat NomBloques "," x)) 
            ) 
               (cdr BkLst) 
           ) 
  ) 
  (if (setq sel5 (ssget "_X" (list '(-4 . "<OR") 
                    ; _Se seleccionan todos los bloques de 
                    ; usuario, despues se procesaran los 
                    ; nombres esto para poder procesar los 
                    ; bloques dinamicos 
                   '(-4 . "<AND") 
                   '(0 . "INSERT") 
                   (cons 2 (strcat NomBloques ",`*U*")) 
                   '(-4 . "AND>") 
                   '(-4 . "OR>") 
             ) 
          ) 
      ) 
 
    (VL-CMDF "_.draworder" sel5 "" "_f")
  ) ;_ if
  (IF (SETQ sel4
      (SSGET
        "_X"
        '((0
    .
    "line,lwpolyline,insert,polyline,arc,circle,spline,hatch,region"
   )
  )
      )
      )
    (VL-CMDF "_.draworder" sel4 "" "_b")
  ) ;_ if
  (IF (SETQ sel1 (SSGET "_X" '((0 . "leader,*Dimension*"))))
    (VL-CMDF "_.draworder" sel1 "" "_f")
  ) ;_ if
  (IF (SETQ sel3
      (SSGET "_X"
      '((0 . "line,lwpolyline,polyline")
        (8 . "Dims,Ar-Dims,G-Dims,M-Dims,E-Dims,S-Dims,P-Dims")
       )
      ) ;_ ssget
      ) ;_ setq
    (VL-CMDF "_.draworder" sel3 "" "_f")
  ) ;_ if
  (SETVAR "dimtfill" dimt)
  (PRINC)
  (COMMAND "undo" "end")  ;end of undo group
  (mw5 ss)
) ;_ defun
;;(PRINC
;;  "\Type \"BAD\" to mask all text, mtext and dimensions, adding mtext box"
;;)
;;(PRINC
;;  "\Remember to set dimscale according to selected dimensions before using it."
;;)
 
;|ซVisual LISPฉ Format Optionsป
(80 2 40 2 nil "end of " 60 9 2 0 0 T T T T)
;*** DO NOT add text below the comment! ***|;




;;


;;; ;BAL.lsp  -BACKGROUND FILL ALL 'LIGHT VERSION'-
;;; ;Made for M3 Mexicana. Coding Selected by Paulo Gil Soto. December 2009
;;; ;This routine will set a background color fill to all selected text, 
;;; ;mtext and dimensions, text objects will be converted to mtext with width=0
;;; ;and then will add their text box control points
;;; ;It will bring objects in layer 'Dims' to front at the end, as well as other
;;; ;Draworder operations according to M3 standards.
;;; ;Reviewed and modified by: Alan J. Thompson. 'alanjt@gmail.com'
;;; ;And Marco Antonio Jacinto Perez 'mcoan001@hotmail.com'
;;; ;December 2009
;;; ; 'light version' Will skip draworder operations to make it faster.

(VL-LOAD-COM)
(DEFUN c:BAL (/ *error* ttm2 ss elist sel1 sel3 dimt)

;;; error handler
  (DEFUN *error* (#Message)
    (AND dimt (SETVAR "dimtfill" dimt))
    (AND #Message
	 (NOT (WCMATCH (STRCASE #Message) "*BREAK*,*CANCEL*,*QUIT*"))
	 (PRINC (STRCAT "\nError: " #Message))
    ) ;_ and
  ) ;_ defun

;; Using code from Roberto Gonzalez -robierzogg- from HISPACAD
;; http://www.hispacad.com/foro/viewtopic.php?p=142823&sid=b23c3147d2a06a29d1dfd60078f79c08
;; This routine works only if Express tools are installed
;; Convert selected text into Mtext 


  (COMMAND "undo" "begin")		;beginning of undo group
  (DEFUN ttm2 (name_n / collect n name_n insertpt name_n1 newlist)
    (SETQ insertpt (ASSOC 10 (ENTGET name_n)))
					; Convert Text to Mtext, using the
					; EXPRESS
					; command
    (COMMAND "txt2mtxt" name_n "")
					; We set their original insertion point
					; here
;;;creo que esta parte mueve los nuevos mtextos de posicion hacia arriba
;;;no se por que lo pusieron?
    (SETQ name_n1 (ENTLAST))
    (SETQ newlist (SUBST insertpt
			 (ASSOC 10 (ENTGET name_n1))
			 (ENTGET name_n1)
		  )
    )
    (ENTMOD newlist)
    (SETQ newlist (SUBST '(71 . 7)
			 (ASSOC 71 (ENTGET name_n1))
			 (ENTGET name_n1)
		  )
    )
    (ENTMOD newlist)
    (SETQ newlist (SUBST '(46 . 0)
			 (ASSOC 46 (ENTGET name_n1))
			 (ENTGET name_n1)
		  )
    )
    (ENTMOD newlist)
    (SETQ newlist (SUBST '(41 . 0)
			 (ASSOC 41 (ENTGET name_n1))
			 (ENTGET name_n1)
		  )
    )
    (ENTMOD newlist)
  ) ;_ defun


;;; Aqui pongo la variable Mtexts como un parametro, el cual corresponde al ss
;;; que vas creando con los nuevos Mtextos
  (DEFUN mw5 (mtexts / mtexts idx ename EntData dxf42 dxf43 EntData1)
					;Reset Width - Mtext
    (IF	mtexts
;; Aqui se hace el cambio para que en lugar
;; de cambiar todos los mtextos, solo modifique los que recien creaste
;; (setq mtexts (ssget "_X" '((0 . "MTEXT"))))
;; Rogerio Brazil from an autodesk Discussion groups
;; http://discussion.autodesk.com/forums/thread.jspa?messageID=6339167&tstart=0
      (PROGN
	(SETQ idx 0)
	(REPEAT	(SSLENGTH mtexts)
	  (SETQ ename (SSNAME mtexts idx))
	  (SETQ EntData (ENTGET ename '("*")))
	  (SETQ dxf42 (* (CDR (ASSOC 42 EntData))1.07))
	  (SETQ dxf43 (CDR (ASSOC 43 EntData)))
	  (SETQ	EntData1
		 (ENTMOD (SUBST (CONS 41 dxf42) (ASSOC 41 EntData) EntData))
	  )
	  (ENTMOD (SUBST (CONS 46 dxf43) (ASSOC 46 EntData1) EntData1)
	  )
	  (SETQ idx (1+ idx))
	)				;progn
      )					;repeat
      (PRINC "\n Null Selection!")
    )					;if
    (PRINC)
  )


;;
;;
;;				; MAIN ROUTINE
;;
;;
;; Some part of code from Tom Beauford, from AUGI
;; http://forums.augi.com/showthread.php?t=77962
;; Set 'Border Offset Factor' to 1.15

  (SETQ dimt (GETVAR "dimtfill"))
  (SETVAR "dimtfill" 1)

  (PRINC
    "\nSelect Dimensions and text to apply the background fill and update...: "
  )
  (AND (SETQ ss (SSGET "_:L" '((0 . "MTEXT,*DIMENSION*,TEXT"))))
       (FOREACH	x (VL-REMOVE-IF 'LISTP (MAPCAR 'CADR (SSNAMEX ss)))
	 (COND
	   ((EQ "MTEXT" (CDR (ASSOC 0 (SETQ elist (ENTGET x)))))
	    (VLA-PUT-BACKGROUNDFILL
	      (VLAX-ENAME->VLA-OBJECT x)
	      :VLAX-TRUE
	    )
	    (SETQ elist	(SUBST (CONS 41 0.0) (ASSOC 41 elist) elist)
		  elist	(SUBST (CONS 46 0.0) (ASSOC 46 elist) elist)
		  elist	(SUBST (CONS 45 1.15) (ASSOC 45 elist) elist)
		  elist	(SUBST (CONS 421 256) (ASSOC 421 elist) elist)
	    ) ;_ setq
	    (ENTMOD elist)
	   )
	   ((EQ "TEXT" (CDR (ASSOC 0 (ENTGET x))))
	    (ttm2 x)
	    (SSDEL x ss)
	    (VLA-PUT-BACKGROUNDFILL
	      (VLAX-ENAME->VLA-OBJECT (SETQ elist (ENTLAST)))
	      :VLAX-TRUE
	    )
	    (SSADD elist ss)
	    (SETQ elist (ENTGET elist))
	    (SETQ elist	(SUBST (CONS 45 1.15) (ASSOC 45 elist) elist)
		  elist	(SUBST (CONS 421 256) (ASSOC 421 elist) elist)
	    ) ;_ setq
	    (ENTMOD elist)
	   )

	   (T T)
	 ) ;_ cond
       ) ;_ foreach
       (VL-CMDF "_.-dimstyle" "_apply" ss "")
       (VL-CMDF "_.draworder" ss "" "_f")
  ) ;_ and

  (SETVAR "dimtfill" dimt)

  (PRINC)
  (COMMAND "undo" "end")		;end of undo group

  (mw5 ss)
(setvar "orthomode" 0)
) ;_ defun



;|ซVisual LISPฉ Format Optionsป
(80 2 40 2 nil "end of " 60 9 2 0 0 T T T T)
;*** DO NOT add text below the comment! ***|;

;;

;;  Block Import Lisp  08/12/2008
;;  CAB at TheSwamp.org

  ;;  Get user selection of folder
  ;;  Get all DWG files in folder
  ;;  INSERT dwg as block @ 0,0
  ;;  get Bounding Box of block
  ;;  Move Insert to right w/ gap between blocks
  ;;  Next Insert

(defun c:BI (/ path LastDist gap space err newblk bname obj ll lr ur
               InsPt dist GetFolder)
  (vl-load-com)
  (defun GetFolder ( / DirPat msg)
   (setq msg "Open a folder and click on SAVE")
   (and
    (setq DirPat (getfiled "Browse for folder" msg " " 1))
    (setq DirPat (substr DirPat 1 (- (strlen DirPat) (strlen msg))))
   )
   DirPat
  )
  

  (defun activespace (doc)
    (if (or (= acmodelspace (vla-get-activespace doc))
            (= :vlax-true (vla-get-mspace doc)))
        (vla-get-modelspace doc)
        (vla-get-paperspace doc)
    )
  )

  (setq gap 5) ; this is the gap between blocks
  (setq LastDist 0.0) ; this is the cumulative distance
  
  (if (setq Path (GetFolder))
    (progn
      (setq space (activespace (vla-get-activeDocument (vlax-get-acad-object))))
      (prompt "\n***  Working, Please wait ......\n")
      (foreach bname (vl-directory-files Path "*.dwg" 1)
        ;;  OK, try & insert the Block
        (if (vl-catch-all-error-p
              (setq err (vl-catch-all-apply
                '(lambda () (setq newblk (vla-insertBlock space 
                                (vlax-3d-point '(0.0 0.0 0.0)) (strcat path bname) 1.0 1.0 1.0 0.0))
                   ))))
          ;;  Display the error message and block/file name
          (prompt (strcat "\n" bname " " (vl-catch-all-error-message err)))
          ;;  ELSE
          (progn ; INSERT was sucessful, move the block
            ;;  get bounding box
            (if (vl-catch-all-error-p
                  (setq err (vl-catch-all-apply 'vla-getboundingbox (list newblk 'll 'ur))))
               (prompt (strcat "\nBB Error - could not move " bname "\n  " (vl-catch-all-error-message err)))
               (progn
                 (setq ll (vlax-safearray->list ll)
                       ur (vlax-safearray->list ur)
                       lr (list (car ur) (cadr ll))
                       dist (distance ll lr)
                       )
                 ;;  MOVE the block
                 (setq ;InsPt  (vla-get-insertionpoint Newblk)
                       NewPt (polar '(0. 0. 0.) 0.0 (+ LastDist Gap (* dist 0.5)))
                       LastDist (+ LastDist Gap dist)
                       )
                 (vlax-put Newblk 'insertionpoint NewPt)
               )
            )
          )
         )
      )
    )
  )
  (princ)      
)
(princ)

;;


;BINCIRCLE.lsp 01/01/97 Jeff Foster
;
;OBJECTIVE***
;The purpose of this routine is to allow the user to enter
;a text item and place that same text in the center of a selection
;of circles
;
;TO RUN***
;At the command line, type (load "c:/lispdir/txtncirc")
;where c:/ is the drive where TXTNCIRC.lsp is contained
;where lispdir/ is the directory where TXTNCIRC.lsp is contained
;
;
;If you find this routine to be helpful, please give consideration
;to making a cash contribution of $10.00 to:
;         Jeff Foster

(DEFUN C:BINCIRCLE (/ SS EN ED AS)
  (SETQ DM (GETVAR "DIMSCALE"))
  (PRINC "SELECT CIRCLES TO PUT TEXT INTO")
  (SETQ SS (SSGET))
  (WHILE (> (SSLENGTH SS) 0)
    (PROGN
    (SETQ EN (SSNAME SS 0))
    (SETQ ED (ENTGET EN))
    (SETQ AS (CDR (ASSOC '0 ED)))
    (SETQ START (CDR (ASSOC '10 ED)))
    (IF (= AS "CIRCLE")
    (COMMAND "INSERT" "COLUMN ROW BUBBLE" START DM DM "0" "")
    )
    (PRIN1)
    (SSDEL EN SS)
  ))
  (PRIN1)
)



;;

;| c:chbkins = redefine block's insertpoint and keep the block reference place------------ok!!----lxx.2004.10
|;
(defun c:BIP ( / *doc e p000 p1e p1 p2 p2x bkobj ss lst)
(while (not(and (princ "\nselect a blockref:")
(setq s (ssget ":S:E" '((0 . "INSERT"))))
)))
(setq *doc (vla-get-activedocument(vlax-get-acad-object))
p000 (list 0. 0. 0.)
e (ssname s 0)
bkn (xdxf e 2) ;;blockname
p1e (xdxf e 10) ;;insertpoint of wcs.
p1 (trans p1e e 1) 
p2 (getpoint p1 "\nselect new insert point:")) 
(if p2
(progn
(setq p2x (x-inspttrans e (trans p2 1 0)) ;new insertpoint of wcs.
bkobj (vla-item (vla-get-blocks *doc) bkn) ;;get the objs in the block define.
ss (ssget "x" (list '(0 . "INSERT") (cons 2 (xdxf e 2))))
)
;;redefine insertpoint
(vlax-for i bkobj (setq lst (cons i lst)))
(mapcar '(lambda (x) (vla-move x (ptx p2x) (ptx p000))) lst);;ok!
;;move bak to old place
(mapcar '(lambda (x)(vla-move(x2o x)(ptx (xdxf x 10))(ptx (x-insptbak x p2x))))(xss2lst ss))
)
)
(princ)
)
;;************************************************************* *******************
;;(x-inspttrans e pt) = get the new insertpoint in a block define-----ok!
(defun x-inspttrans (e pt / obj atts attv p ang xs ys zs ) ;;for wcs
(setq p000 (list 0. 0. 0.)
obj (vlax-ename->vla-object e)
p (xdxf e 10)
atts '(rotation xscalefactor yscalefactor zscalefactor)
attv (mapcar '(lambda(x)(vlax-get obj x)) atts))
(mapcar 'set '(ang xs ys zs) attv)
(setq pt (polar p000 (- (angle p pt) ang) (distance p pt))
pt (mapcar '/ pt (list xs ys zs)))
)
;;*************************************************************** *****************
;;get the orignal insertpoint by pt wcs.------------------ok!
(defun x-insptbak (e pt / obj atts attv p ang xs ys zs) ;;for wcs
(setq p000 (list 0. 0. 0.)
p (xdxf e 10)
obj (vlax-ename->vla-object e)
atts '(rotation xscalefactor yscalefactor zscalefactor)
attv (mapcar '(lambda(x)(vlax-get obj x)) atts))
(mapcar 'set '(ang xs ys zs) attv)
(setq pt (mapcar '* pt (list xs ys zs))
pt (polar p (+ (angle p000 pt) ang) (distance p000 pt)))
)
;; trans point to vla point
(defun ptx (pt)
(if (= (type pt) 'variant)
pt
(vlax-3d-point pt)
)
)
;; get the dxf value
(defun xdxf (e id)
(cdr(assoc id (entget e)))
)
;;(xss2lst ss) = get the list of enames in the ssget
(defun xss2lst (ss / i lst)
(setq i -1)
(while (setq e (ssname ss (setq i (1+ i))))
(setq lst (cons (xdxf e -1) lst))
)(reverse lst)
)
;;
(defun x2o (eobj)
(if (= 'ENAME (type eobj))
(vlax-ename->vla-object eobj)
eobj
)
)


;;

;Made by ;kpblc  in Cadtutor.com
;http://www.cadtutor.net/forum/showthread.php?t=19161
;fixall will change selected blocks in current drawing 
;to layer 0, color, linetype & lineweight bylayer

(defun c:BL0 (/ *error* adoc lst_layer func_restore-layers)
(princ " Select blocks to redefine to layer 0, color and linetype Bylayer:") 
  (defun *error* (msg)
    (func_restore-layers)
    (vla-endundomark adoc)
    (princ msg)
    (princ)
    ) ;_ end of defun

  (defun func_restore-layers ()
    (foreach item lst_layer
      (vla-put-lock (car item) (cdr (assoc "lock" (cdr item))))
      (vl-catch-all-apply
        '(lambda ()
           (vla-put-freeze
             (car item)
             (cdr (assoc "freeze" (cdr item)))
             ) ;_ end of vla-put-freeze
           ) ;_ end of lambda
        ) ;_ end of vl-catch-all-apply
      ) ;_ end of foreach
    ) ;_ end of defun

  (vl-load-com)
  (vla-startundomark
    (setq adoc (vla-get-activedocument (vlax-get-acad-object)))
    ) ;_ end of vla-startundomark
  (if (and (not (vl-catch-all-error-p
                  (setq selset
                         (vl-catch-all-apply
                           (function
                             (lambda ()
                               (ssget '((0 . "INSERT")))
                               ) ;_ end of lambda
                             ) ;_ end of function
                           ) ;_ end of vl-catch-all-apply
                        ) ;_ end of setq
                  ) ;_ end of vl-catch-all-error-p
                ) ;_ end of not
           selset
           ) ;_ end of and
    (progn
      (vlax-for item (vla-get-layers adoc)
        (setq
          lst_layer (cons (list item
                                (cons "lock" (vla-get-lock item))
                                (cons "freeze" (vla-get-freeze item))
                                ) ;_ end of list
                          lst_layer
                          ) ;_ end of cons
          ) ;_ end of setq
        (vla-put-lock item :vlax-false)
        (vl-catch-all-apply
          '(lambda () (vla-put-freeze item :vlax-false))
          ) ;_ end of vl-catch-all-apply
        ) ;_ end of vlax-for
      (foreach blk_def
               (mapcar
                 (function
                   (lambda (x)
                     (vla-item (vla-get-blocks adoc) x)
                     ) ;_ end of lambda
                   ) ;_ end of function
                 ((lambda (/ res)
                    (foreach item (mapcar
                                    (function
                                      (lambda (x)
                                        (vla-get-name
                                          (vlax-ename->vla-object x)
                                          ) ;_ end of vla-get-name
                                        ) ;_ end of lambda
                                      ) ;_ end of function
                                    ((lambda (/ tab item)
                                       (repeat (setq tab  nil
                                                     item (sslength selset)
                                                     ) ;_ end setq
                                         (setq
                                           tab
                                            (cons
                                              (ssname selset
                                                      (setq item (1- item))
                                                      ) ;_ end of ssname
                                              tab
                                              ) ;_ end of cons
                                           ) ;_ end of setq
                                         ) ;_ end of repeat
                                       tab
                                       ) ;_ end of lambda
                                     )
                                    ) ;_ end of mapcar
                      (if (not (member item res))
                        (setq res (cons item res))
                        ) ;_ end of if
                      ) ;_ end of foreach
                    (reverse res)
                    ) ;_ end of lambda
                  )
                 ) ;_ end of mapcar
        (vlax-for ent blk_def
          (vla-put-layer ent "0")
          (vla-put-color ent 256)
          (vla-put-lineweight ent aclnwtbylayer)
          (vla-put-linetype ent "bylayer")
          ) ;_ end of vlax-for
        ) ;_ end of foreach
      (func_restore-layers)
      (vla-regen adoc acallviewports)
      ) ;_ end of progn
    ) ;_ end of if
  (vla-endundomark adoc)
  (princ)
  ) ;_ end of defun
---------

***************


;;


;;;   File Name: Layerfix.LSP 
;;;   Description:  Changes the block definitions to BYLAYER .  Will skip all
;;;                 XREF & XREF dependent blocks. 
;;;
;;;   Global Variables:  None
;;;
;;;   Local Variables:  Self-explanatory
;;;
;;;   Program Arguments:  None
;;;   Subroutines/Functions Defined or Called:  None
;;;
;;;***************************************************************************


(defun C:BL02 (/ BLKDATA NEWCOLOR NEWCOLOR NEWLAYER LAYER XREFFLAG XDEPFLAG BLKENTNAME
                     COUNT ENTDATA ENTNAME ENTTYPE OLDCOLOR OLDLAYER SSCOUNT SS)
   
   (command ".undo" "group")
   (setq BLKDATA (tblnext "BLOCK" t))
   (setq NEWCOLOR (cons 62 256))  ;this will set 62 (color) to bylayer
   (setq NEWLAYER (cons 8 "0"))  ;this will set 8 (layer) to 0
   ; While there is an entry in the block table to process, continue
   (while BLKDATA
      (prompt "\nRedefining colors for block: ")
      (princ (cdr (assoc 2 BLKDATA)))
      ; Check to see if block is an XREF or is XREF dependent
      (setq XREFFLAG (assoc 1 BLKDATA))
      (setq XDEPFLAG (cdr (assoc 70 BLKDATA)))
      ; If block is not XREF or XREF dependent, i.e., regular block, then proceed.
      (if (and (not XREFFLAG) (/= (logand XDEPFLAG 32) 32))
         (progn
            (setq BLKENTNAME (cdr (assoc -2 BLKDATA)))
            (setq COUNT 1)
            (terpri)
            ; As long as we haven't reached the end of the block's defintion, get the data
            ; for each entity and change its color assignment to BYLAYER.
            (while BLKENTNAME
               (princ COUNT)
               (princ "\r")
               (setq ENTDATA (entget BLKENTNAME)); get entities data 
               (setq OLDCOLOR (assoc 62 ENTDATA))  ;get entities old color value
               (if OLDCOLOR                         ; if value exist (null = bylayer)
                  (entmod (subst newcolor oldcolor ENTDATA)) ; substitute old color to byblock
                  (entmod (cons newcolor ENTDATA))      ; modify ent data w/ byblock values
               )
               (setq BLKENTNAME (entnext BLKENTNAME)) ;if attributes exist, then edit next one
               (setq COUNT (+ COUNT 1));
            ) ;end while for attribute trap
         ) ;progn
         (progn
            (princ "    XREF...skipping!")
         ) ;progn
      );end if not an Xref
      (setq BLKDATA (tblnext "BLOCK")) ;next block please
   ) ;end while loop of blk data available to edit
   (command ".undo" "end")
   (command ".regen")
   (PROMPT "\nDone... ")
   (princ)
)


;;


;;;   File Name: Layerfix.LSP 
;;;   Description:  Changes the block definitions to Layer 0, Other properties will remain .  Will skip all
;;;                 XREF & XREF dependent blocks. 
;;;
;;;   Global Variables:  None
;;;
;;;   Local Variables:  Self-explanatory
;;;
;;;   Program Arguments:  None
;;;   Subroutines/Functions Defined or Called:  None
;;;
;;;***************************************************************************


(defun C:BL03 (/ BLKDATA NEWCOLOR NEWCOLOR NEWLAYER LAYER XREFFLAG XDEPFLAG BLKENTNAME
                     COUNT ENTDATA ENTNAME ENTTYPE OLDCOLOR OLDLAYER SSCOUNT SS)
   
   (command ".undo" "group")
   (setq BLKDATA (tblnext "BLOCK" t))
   (setq NEWCOLOR (cons 62 256))  ;this will set 62 (color) to bylayer
   (setq NEWLAYER (cons 8 "0"))   ;this will set 8 (layer) to 0
   ; While there is an entry in the block table to process, continue
   (while BLKDATA
      (prompt "\nRedefining colors for block: ")
      (princ (cdr (assoc 2 BLKDATA)))
      ; Check to see if block is an XREF or is XREF dependent
      (setq XREFFLAG (assoc 1 BLKDATA))
      (setq XDEPFLAG (cdr (assoc 70 BLKDATA)))
      ; If block is not XREF or XREF dependent, i.e., regular block, then proceed.
      (if (and (not XREFFLAG) (/= (logand XDEPFLAG 32) 32))
         (progn
            (setq BLKENTNAME (cdr (assoc -2 BLKDATA)))
            (setq COUNT 1)
            (terpri)
            ; As long as we haven't reached the end of the block's defintion, get the data
            ; for each entity and change its color assignment to BYLAYER.
            (while BLKENTNAME
               (princ COUNT)
               (princ "\r")
               (setq ENTDATA (entget BLKENTNAME)); get entities data 
               (setq OLDCOLOR (assoc 62 ENTDATA))  ;get entities old color value
               (setq OLDLAYER (assoc 8 ENTDATA))  ;get entities old layer value
               (if OLDCOLOR                         ; if value exist (null = bylayer)
                  (entmod (subst NEWCOLOR oldcolor ENTDATA)) ; substitute old color to byblock
                  (entmod (cons NEWCOLOR ENTDATA))      ; modify ent data w/ byblock values
               )
               (if OLDLAYER                         ; if value exist (null = bylayer)
                  (entmod (subst newlayer oldlayer ENTDATA)) ; substitute old color to byblock
                  (entmod (cons newlayer ENTDATA))      ; modify ent data w/ byblock values
               )
               (setq BLKENTNAME (entnext BLKENTNAME)) ;if attributes exist, then edit next one
               (setq COUNT (+ COUNT 1));
            ) ;end while for attribute trap
         ) ;progn
         (progn
            (princ "    XREF...skipping!")
         ) ;progn
      );end if not an Xref
      (setq BLKDATA (tblnext "BLOCK")) ;next block please
   ) ;end while loop of blk data available to edit
   (command ".undo" "end")
   (command ".regen")
   (PROMPT "\nDone... ")
   (princ)
)


;;

;;; Replace multiple instances of selected blocks (can be different) with selected block
;;; Size and Rotation will be taken from original block and original will be deleted
;;; Required subroutines: AT:Entsel
;;; Alan J. Thompson, 02.09.10
(defun c:BRE (/ *error* #Block #SS #Temp)
  (setq *error* (lambda (x) (and *AcadDoc* (vla-endundomark *AcadDoc*))))
  (or *AcadDoc* (setq *AcadDoc* (vla-get-activedocument (vlax-get-acad-object))))
  (vla-startundomark *AcadDoc*)
  (cond
    ((and (setq #Block (AT:Entsel nil "\nSelect replacement block: " '("LV" (0 . "INSERT")) nil))
          (princ "\nSelect blocks to be replaced: ")
          (setq #SS (ssget "_:L" '((0 . "INSERT"))))
     ) ;_ and
     (vlax-for x (setq #SS (vla-get-activeselectionset *AcadDoc*))
       ;; copy original block
       (setq #Temp (vla-copy #Block))
       ;; put new values
       (mapcar '(lambda (p)
                  (vl-catch-all-apply 'vlax-put-property (list #Temp p (vlax-get-property x p)))
                ) ;_ lambda
               (list 'Insertionpoint 'Rotation 'XEffectiveScaleFactor 'YEffectiveScaleFactor
                     'ZEffectiveScaleFactor
                    ) ;_ list
       ) ;_ mapcar
       ;; delete old block
       (vl-catch-all-apply 'vla-delete (list x))
     ) ;_ vlax-for
     (vl-catch-all-apply 'vla-delete (list #SS))
    )
  ) ;_ cond
  (*error* nil)
  (princ)
) ;_ defun

;;; Entsel or NEntsel with options
;;; #Nested - Entsel or Nentsel (T for Nentsel, nil for Entsel)
;;; #Message - Selection message (if nil, "\nSelect object: " is used)
;;; #FilterList - DXF ssget style filtering (nil if not required)
;;;               "V" as first item in list to convert object to VLA-OBJECT (must be in list if no DXF filtering)
;;;               "L" as first item in list to ignore locked layers (must be in list if no DXF filtering)
;;; #Keywords - Keywords to match instead of object selection (nil if not required)
;;; Example: (AT:Entsel nil "\nSelect MText not on 0 layer [Settings]: " '("LV" (0 . "MTEXT")(8 . "~0")) "Settings")
;;; Example: (AT:Entsel T "\nSelect object [Settings]: " '("LV") "Settings")
;;; Alan J. Thompson, 04.16.09
;;; Updated: Alan J. Thompson, 06.04.09 (changed filter coding to work as ssget style dxf filtering)
;;; Updated: Alan J. Thompson, 09.07.09 (added option to ignore locked layers and convert object to VLA-OBJECT
;;; Updated: Alan J. Thompson, 09.18.09 (fixed 'missed pick' alert)
(defun AT:Entsel (#Nested #Message #FilterList #Keywords / #Count
                  #Message #Choice #Ent #VLA&Locked #FilterList
                 )
  (vl-load-com)
  (setvar "errno" 0)
  (setq #Count 0)
  ;; fix message
  (or #Message (setq #Message "\nSelect object: "))
  ;; set entsel/nentsel
  (if #Nested
    (setq #Choice nentsel)
    (setq #Choice entsel)
  ) ;_ if
  ;; check if option to convert to vla-object or ignore locked layers in #FilterList variable
  (and (vl-consp #FilterList)
       (eq (type (car #FilterList)) 'STR)
       (setq #VLA&Locked (car #FilterList)
             #FilterList (cdr #FilterList)
       ) ;_ setq
  ) ;_ and
  ;; select object
  (while (and (not #Ent) (/= (getvar "errno") 52))
    ;; if keywords
    (and #Keywords (initget #Keywords))
    (cond
      ((setq #Ent (#Choice #Message))
       ;; if ignore locked layers
       (and #VLA&Locked
            (vl-consp #Ent)
            (wcmatch (strcase #VLA&Locked) "*L*")
            (not
              (zerop
                (cdr (assoc 70
                            (entget (tblobjname
                                      "layer"
                                      (cdr (assoc 8 (entget (car #Ent))))
                                    ) ;_ tblobjname
                            ) ;_ entget
                     ) ;_ assoc
                ) ;_ cdr
              ) ;_ zerop
            ) ;_ not
            (setq #Ent nil
                  #Flag T
            ) ;_ setq
       ) ;_ and
       ;; #FilterList check
       (if (and #FilterList (vl-consp #Ent))
         ;; process filtering from #FilterList
         (or
           (not
             (member
               nil
               (mapcar '(lambda (x)
                          (wcmatch
                            (strcase
                              (vl-princ-to-string
                                (cdr (assoc (car x) (entget (car #Ent))))
                              ) ;_ vl-princ-to-string
                            ) ;_ strcase
                            (strcase (vl-princ-to-string (cdr x)))
                          ) ;_ wcmatch
                        ) ;_ lambda
                       #FilterList
               ) ;_ mapcar
             ) ;_ member
           ) ;_ not
           (setq #Ent nil
                 #Flag T
           ) ;_ setq
         ) ;_ or
       ) ;_ if
      )
    ) ;_ cond
    (and (or (= (getvar "errno") 7) #Flag)
         (/= (getvar "errno") 52)
         (not #Ent)
         (setq #Count (1+ #Count))
         (prompt (strcat "\nNope, keep trying!  "
                         (itoa #Count)
                         " missed pick(s)."
                 ) ;_ strcat
         ) ;_ prompt
    ) ;_ and
  ) ;_ while
  (if (and (vl-consp #Ent)
           #VLA&Locked
           (wcmatch (strcase #VLA&Locked) "*V*")
      ) ;_ and
    (vlax-ename->vla-object (car #Ent))
    #Ent
  ) ;_ if
);_ defun


;;

(defun c:bro ( / rot ss1 rpnt num)
  (WSD_sv)
  (command ".undo" "m")
  (setq rot (getreal "\nEnter rotation angle: ") num 0)
  (prompt "\nSelect blocks or text to rotate: ")
  (setq ss1 (ssget '((-4 . "<OR")(-4 . "<AND")
                       (0 . "TEXT")
                     (-4 . "AND>")(-4 . "<AND")
                       (0 . "INSERT")
                     (-4 . "AND>")(-4 . "<AND")
                       (0 . "MTEXT")
                     (-4 . "AND>")(-4 . "OR>"))
            )
  )
  (repeat (sslength ss1)
    (setq rpnt (cdr (assoc 10 (entget (ssname ss1 num)))))
    (command "._rotate" (ssname ss1 num) "" rpnt rot)
    (setq num (1+ num))
  )
  (command ".undo" "e")
  (WSD_rv)
)
(princ)
;;*******************************************************************************
;; (WSD_SV) Save vars and set error handler - Lisp initiation JRW
;;*******************************************************************************
(defun WSD_sv ()
  (command ".undo" "begin")
  (setq #dscl (getvar "dimscale"))
  (setq #bm (getvar "blipmode"))
					;(setq #os (getvar "osmode"))
  (setq #ce (getvar "cmdecho"))
  (setq #me (getvar "menuecho"))
  (setq	#oe	*error*
	*error*	JSD_err
  )
  (setvar "blipmode" 0)
					;(setvar "osmode" 0)
  (setvar "cmdecho" 0)
  (setvar "menuecho" 0)
  (graphscr)
) ;_ end of defun
;;*******************************************************************************
;; (WSD_RV) Reset vars and reset error handler - Lisp end JRW            
;;*******************************************************************************
(defun WSD_rv ()
  (command "undo" "end")
  (setvar "dimscale" #dscl)
  (setvar "blipmode" #bm)
					;(setvar "osmode" #os)
  (setvar "cmdecho" #ce)
  (setq	*error*	#oe
	#oe nil
  ) ;_ end of setq
					;(prompt "\n           Written by James R Wilson")
  (prompt "\n\nDone...  (C) Copyright 2004 WSD")
  (prompt "\n             All Rights Reserved")
  (princ)
) ;_ end of defun


;;


;BRR
;BREAKER.LSP                   *** VERSION 1.2 ***              (4/11/89)
;
;WILL BREAK A LINE AT AN INTERSECTION WITH ANOTHER LINE. AUTOMATICALLY SETS
;OSNAP TO "INTERSECT".                                              *[LL]  
;
(defun C:BRR (/ ln bkpt)
(setq om (getvar "osmode"))
(setvar "cmdecho" 0)
(setq ln (entsel "\nChoose Line to Break..."))
(setq bkpt (getpoint "\nPick Break Point.. "))
(command "break" ln "f" bkpt "@")
(setvar "osmode" om)
(setvar "cmdecho" 1)
(prin1)
)


;;


; ----------------------------------------------------------------------
;                       (Scale Blocks in Place)
;            Copyright (C) 1998 DotSoft, All Rights Reserved
;                      Website: www.dotsoft.com
; ----------------------------------------------------------------------
; DISCLAIMER:  DotSoft Disclaims any and all liability for any damages
; arising out of the use or operation, or inability to use the software.
; FURTHERMORE, User agrees to hold DotSoft harmless from such claims.
; DotSoft makes no warranty, either expressed or implied, as to the
; fitness of this product for a particular purpose.  All materials are
; to be considered ‘as-is’, and use of this software should be
; considered as AT YOUR OWN RISK.
; ----------------------------------------------------------------------

(defun c:BS ()
  (setq cmdecho (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)
  (command "_.UNDO" "_G")
  (setq sset (ssget '((0 . "INSERT"))))
  (if sset 
    (progn
      (setq sf (getreal "Scale Factor: "))
      (setq num (sslength sset) itm 0)
      (while (< itm num)
        (setq hnd (ssname sset itm))
        (setq ent (entget hnd))
        (setq pt (cdr (assoc 10 ent)))
        (command "_.SCALE" hnd "" pt sf)
        (setq itm (1+ itm))
      )
    )
  )
  (setq sset nil)
  (command "_.UNDO" "_E")
  (setvar "CMDECHO" cmdecho)
  (princ)
)


;;


;Bu.lsp Update selected blocks to current Dimscale, supports Normal, attributed and dynamic blocks
;by Lee Mac from Cadtutor, Sep. 2009
(defun c:bu (/ *error* doc oldc ss sel scl)
  (vl-load-com)
   (defun *error* (msg)
    (if doc (vla-EndUndoMark doc))
    (if oldc (setvar "CMDECHO" oldc))
    (if (not
          (wcmatch
            (strcase msg) "*BREAK,*CANCEL*,*EXIT*"))
      (princ (strcat "\n** Error: " msg " **")))
    (princ))
 
  (setq doc (vla-get-ActiveDocument
              (vlax-get-acad-object)))
  (setq oldc (getvar "CMDECHO") scl (getvar "DIMSCALE"))
  (setvar "CMDECHO" 0)
  (prompt "\nSelect Blocks to match current dimscale... ")
  (if (setq ss (ssget '((0 . "INSERT"))))
    (progn
      (vla-StartUndoMark doc)
      (command "_.-objectscale" ss "" "_add" "1:1" "")
      (setvar "CANNOSCALE" "1:1")
      (vlax-for Obj (setq sel (vla-get-ActiveSelectionSet doc))        
        (foreach x
          (if (eq :vlax-true
                (vla-get-IsDynamicBlock Obj))
            '(XEffectiveScaleFactor YEffectiveScaleFactor ZEffectiveScaleFactor)
            '(XScaleFactor YScaleFactor ZScaleFactor))
          (vlax-put-property Obj x scl))
        (if (eq :vlax-true (vla-get-HasAttributes Obj))
          (command "_.attsync" "_Name"
            (vlax-get-property Obj
              (if (eq :vlax-true
                    (vla-get-isDynamicBlock Obj)) 'EffectiveName 'Name)))))
      (vla-delete sel)
      (vla-EndUndoMark doc)))
 
  (setvar "CMDECHO" oldc)
  (princ))

;;

;;; BXY by David Harrington; Modified by Paulo Gil (added annotation scale reset to 1:1)
;;; updates selected blocks x,y and z values to current Dimscale
;;;
;;; Main Program
;;;
(defun c:Bu- (/ ss xs ys zs num x na lst editxyz_error olcmdecho old_err) 
	(defun editxyz_error (msg) 
		(if (or
				(= msg "Function cancelled")
				(/= msg "quit / exit abort")
			) 
			(princ (strcat "Error: " msg))
		) 
		(command ".UNDO" "E" "UNDO" "") 
		(setq *error*  old_err
			  old_err  nil
		)
		(setvar "CMDECHO" olcmdecho)
		(princ)
	) 
	(setq old_err *error* 
		  olcmdecho (getvar "CMDECHO")
		  *error* editxyz_error
	) 
	(setvar "CMDECHO" 0)
        (setq dms (getvar "dimscale"))
	(princ "\n   EDITXYZ - Edit block x, y and z values")
	(command ".UNDO" "BE") 	(prompt "\nSelect Xrefs or Blocks to rescale: ")
	(cond
		((setq ss (ssget '((0 . "INSERT"))))
	        (command "-objectscale" ss "" "add" "1:1" "" "cannoscale" "1:1") 
			(setq num (sslength ss))
			(setq x 0)
			(repeat num 
				(setq na (ssname ss x))
	                        (command "-objectscale" "p" "" "add" "1:1" "" "cannoscale" "1:1") 
				(setq lst (entget na))
                                (if (> 0 (cdr (assoc 41 lst)))
				  (setq lst (subst (cons 41 (* -1 dms)) (assoc 41 lst) lst))
                                  (setq lst (subst (cons 41 dms) (assoc 41 lst) lst))
                                )
                                (if (> 0 (cdr (assoc 42 lst)))
				  (setq lst (subst (cons 42 (* -1 dms)) (assoc 42 lst) lst))
                                  (setq lst (subst (cons 42 dms) (assoc 42 lst) lst))
                                )
                                (if (> 0 (cdr (assoc 43 lst)))
				  (setq lst (subst (cons 43 (* -1 dms)) (assoc 43 lst) lst))
                                  (setq lst (subst (cons 43 dms) (assoc 43 lst) lst))
                                )
				(entmod lst) 
				(entupd na) 
				(setq x (+ x 1))
			)
		)
	)
	(command "attsync" "name" "*")
	(command ".UNDO" "E") 
	(setq *error* old_err)
	(setvar "CMDECHO" olcmdecho)
	(princ)
)



;;


;cambia el color de objetos a 252.. .por paulo gil

(defun c:c8 ()
   (princ "Selecciona los objetos a cambiar el COLOR A 252...\n")
   (setq ss (ssget))
         (command "CHANGE" ss "" "PROP" "COLOR" "252" "")
      (princ)
)


;;

;copy multiple.. .por paulo gil
;
;(defun c:c ()
;   (princ "Select objects:...\n")
;   (setq ss (ssget))
;         (command "COPY" ss "" "M")
;      (princ)
;)


;;

; ----------------------------------------------------------------------
;               (Change layer of hard coded layer objects)
;            Copyright (C) 1997 DotSoft, All Rights Reserved
;                      Website: www.dotsoft.com
; ----------------------------------------------------------------------
; DISCLAIMER:  DotSoft Disclaims any and all liability for any damages
; arising out of the use or operation, or inability to use the software.
; FURTHERMORE, User agrees to hold DotSoft harmless from such claims.
; DotSoft makes no warranty, either expressed or implied, as to the
; fitness of this product for a particular purpose.  All materials are
; to be considered ‘as-is’, and use of this software should be
; considered as AT YOUR OWN RISK.
; ----------------------------------------------------------------------

(defun c:cco ()
  (setq cmdecho (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)
  (command "UNDO" "G")
  ;
  (setq sset (ssget))
  (if (/= sset nil)
    (progn
      (setq num (sslength sset) itm 0)
      (while (< itm num)
        (setq hnd (ssname sset itm))
        (setq ent (entget hnd))
        (setq col (cdr (assoc 62 ent)))
        (if (/= col nil)
          (if (and (> col 0)(< col 256))
            (progn
              (setq lay (strcat "M3-" (itoa col)))
              (if (= (tblsearch "LAYER" lay) nil)
                (command "_LAYER" "_N" lay "_C" col lay "")
              )
              (command "_CHPROP" hnd "" "_LA" lay "_C" "BYLAYER" "")
            )
          )
        )
        (setq itm (1+ itm))
      )
      (princ ", Done.")
    )
  )
  ;
  (setq sset nil)
  (command "UNDO" "E")
  (setvar "CMDECHO" cmdecho)
  (princ)
)



;;

;change layer of object(s) by picking... por paulito gil
(defun c:ccu ()
   (princ "Select objects to copy to current layer...\n")
   (setq ss (ssget))
   (if ss (progn
      (setq lay (getvar"clayer"))
         (command "copy" ss "" "0,0,0" "0,0,0")
         (command "CHANGE" ss "" "PROP" "LAYER" lay "")
      ))
      (princ)
)



;;

;CDA 	DEVUELVE EL TEXTO DE LAS DIMENSIONES AL QUE TIENE POR DEFAULT.. 	POR PAULITO GIL
(defun C:CDA (); (c) 2001 Andy Leisk
  (prompt "\nRESTAURA EL TEXTO DE LAS DIMENSIONES AL VALOR ORIGINAL\n")
  (princ "Selecciona las dimensiones a restaurar...\n")
  (setq ss (ssget))
   (command ".DIM1" "NEW" "<>" ss "")
      (princ)
)
(princ)


;;

;CDD 	SOBREESCRIBE EL TEXTO DE LAS DIMENSIONES  	POR PAULITO GIL
;	CON EL QUE TIENE ACTUALMENTE
;	PARA PODER SER MODIFICADAS SIN CAMBIAR EL TEXTO
(defun C:CDD (/ strdim); (c) 2001 Andy Leisk
  (prompt "\nSOBREESCRIBE EL TEXTO DE LAS DIMENSIONES")
  (setq cmdechostatus (getvar "cmdecho"))
  (setvar "cmdecho" 0)
  (setq x (ssget))
  (setq count 0)
  (setq changed 0)
  (command "undo" "begin")
  (if (/= x nil) 
    (repeat (sslength x)
      (progn
        (setq klaatu (entget (ssname x count)))
        (if (= (cdr(assoc 0 klaatu)) "DIMENSION")
          (progn
            (setq verada(tblsearch "BLOCK" (cdr(assoc 2 klaatu))))
            (setq niktu(entnext (cdr(assoc -2 verada))))
            (while (boundp 'niktu)
              (setq niktuent (entget niktu))
              (if (and(= (cdr(assoc 0 niktuent))"MTEXT")(> (strlen (cdr(assoc 1 niktuent)))0))
                (setq strdim (cdr(assoc 1 niktuent)))
              )
              (setq niktu(entnext niktu))
            )
            (if (/= strdim nil)
	      (progn
	        (COMMAND ".DIM1" "NEW" strdim (ssname x count) "")
		(setq changed (1+ changed))
	      )
            )
	    (setq strdim nil)
	  )
        )
        (setq count (1+ count))
      )
    )
  ;else
    (princ "No objects were selected. ")
  )
  (if (/= x nil)
    (progn
      (princ (sslength x))
      (if (= 1 (sslength x))
        (princ " object was selected. ")
        (princ " objects were selected. ")
      )
    )  
  )  
  (if (= 0 changed)
    (princ "No dimensions were overwritten.")
    (progn
      (princ changed)
      (if (= 1 changed)
        (princ " dimension was overwritten.")
        (princ " dimensions were overwritten.")
      )
    )
  )  
  (command "undo" "end")
  (setvar "cmdecho" cmdechostatus)
  (princ)
)
(princ)



;;


;===============================================================================
;     CHGWIDTH - Change the width of selected entities
;===============================================================================

(defun C:CHW ()

     (prompt "\nCHGWIDTH - Change the width of selected entities")

     (setq OLD_CMDECHO (getvar "CMDECHO"))
     (setvar "CMDECHO" 0)

     (setq SELECTION_SET (ssget))
     (setq NO_OF_ITEMS (sslength SELECTION_SET))

     (setq NEW_WIDTH (getdist "\nNew width for selected objects : "))

     (setq SSPOSITION 0)

     (repeat NO_OF_ITEMS

         (setq ENTITY_NAME (ssname SELECTION_SET SSPOSITION))
         (setq ENTITY_LIST (entget ENTITY_NAME))
         (setq ENTITY_TYPE (cdr (assoc 0 ENTITY_LIST)))

         (cond ((or (equal ENTITY_TYPE "LINE") (equal ENTITY_TYPE "ARC"))
                    (command ".PEDIT" ENTITY_NAME "Y" "W" NEW_WIDTH "")
               )

               ((equal ENTITY_TYPE "LWPOLYLINE")
                    (command ".PEDIT" ENTITY_NAME "W" NEW_WIDTH "")
               )

               ((equal ENTITY_TYPE "POLYLINE")
                    (command ".PEDIT" ENTITY_NAME "W" NEW_WIDTH "")
               )

               ((equal ENTITY_TYPE "CIRCLE")
                    (command ".BREAK" ENTITY_NAME "0,0" "0.00001,0")
                    (command ".PEDIT" ENTITY_NAME "Y" "W" NEW_WIDTH "")
               )
         )

         (setq SSPOSITION (1+ SSPOSITION))
     )

     (setvar "CMDECHO" OLD_CMDECHO)

     (prompt "\nProgram complete.")
     (princ)
)


;;


;;;   SQUARE.lsp
;;;   Copyright (C) 1990 by Autodesk, Inc.
;;;  
;;;   Permission to use, copy, modify, and distribute this software and its
;;;   documentation for any purpose and without fee is hereby granted.  
;;;
;;;   THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT EXPRESS OR IMPLIED WARRANTY. 
;;;   ALL IMPLIED WARRANTIES OF FITNESS FOR ANY PARTICULAR PURPOSE AND OF 
;;;   MERCHANTABILITY ARE HEREBY DISCLAIMED.
;;;   Creado por Marco V. Gil
;;;   April, 1990
;;;--------------------------------------------------------------------------
;;; DESCRIPCION
;;;
;;;   SQUARE.LSP
;;; 
;;;   Esta rutina de Lisp crea un Rectangulo o un cuadrado en el actual UCS.     ;;;   
;;;
;;;--------------------------------------------------------------------------


(defun myerror (s)                    ; If an error (such as CTRL-C) occurs
                                      ; while this command is active...
  (if (/= s "Function cancelled")
    (princ (strcat "\nError: " s))
  )
  (setvar "cmdecho" ocmd)             ; Restore saved modes
  (setvar "blipmode" oblp)
  (setq *error* olderr)               ; Restore old *error* handler
  (princ)
)

(defun c:cu (/ olderr ocmd oblp pt1 pt2 pt3 pt4 l w)
  (setq olderr  *error*
        *error* myerror)
  (setq ocmd (getvar "cmdecho"))
  (setq oblp (getvar "blipmode"))
  (setvar "cmdecho" 0)
  (setq om (getvar "osmode"))
  (initget 1)                         ;3D point can't be null
  (setq pt1 (getpoint (strcat "\nCorner of rectangle or square: ")))
  (setvar "ORTHOMODE" 1)
  (initget 7)                         ;Length can't be 0, neg, or null
  (setq l (getdist pt1 "\nLength: "))
  (setq pt2 (list (+ (car pt1) l) (cadr pt1) (caddr pt1)))
  (setq pt3 (list (car pt2) (+ (cadr pt2) l) (caddr pt2)))
  (setq pt4 (list (car pt1) (+ (cadr pt1) l) (caddr pt1)))
  (setvar "ORTHOMODE" 0)
  (setvar "OSMODE" 0)
  (command "pline" pt1 pt2 pt3 pt4 "close")
  (setvar "blipmode" oblp)
  (setvar "osmode" om)
  (setq *error* olderr)               ; Restore old *error* handler
  (princ)
)
(princ)


;;


;Sets dimscale according to selected text, mtext, dimension, leader or block

(defun c:dre (/ dxf ent)
 
  (defun dxf (code ent) (cdr (assoc code (entget ent))))
 
  (cond (  (setq ent (car (entsel)))
 
           (setvar 'DIMSCALE
 
             (cond (  (wcmatch (dxf 0 ent) "TEXT,MTEXT") (* 8. (dxf 40 ent)))
 
                   (  (eq "INSERT" (dxf 0 ent)) (abs (dxf 41 ent)))
  
                   (  (wcmatch (dxf 0 ent) "DIMENSION,*LEADER")

                      (cdr (assoc 40 (tblsearch "DIMSTYLE" (dxf 3 ent)))))

                   (  (getvar "DIMSCALE"))))))

  (princ (strcat "\n<<-- Dimscale has been set to: " (rtos (getvar 'DIMSCALE)) " -->>"))
  (princ))

;;


(vl-load-com) 
 ;| 
;Codigo original por Lee Mc Donell de Cadtutor 
;Codigo modificado por Marco Jacinto, para en una misma seleccion 
;cambiar los textos, Mtextos, bloques y dimensiones. 
;Se comento el codigo original, en donde el codigo es reduntante, y se 
;cambio para utilizar solo funciones ActiveX. 

;Marco Jacinto Puerto Vallarta Mexico Noviembre 2009  
;Post Original en HispaCAD  
;http://www.hispacad.com/foro/viewtopic.php?t=25876&highlight=  
; |; 

(defun c:du (/ DOC NEW_HEIGTH OLDERR ONAME SC SCL SEL S_SET NomBloques) 
   
  (setq olderr *error*) 

  (defun *error* (msg) 
    (if    (= 8 (logand (getvar "undoctl") 8)) 
      (vla-EndUndoMark doc) 
    ) 
    (if    (not 
      (wcmatch 
        (strcase msg) 
        "*BREAK,*CANCEL*,*EXIT*" 
      ) 
    ) 
      (princ (strcat "\n** Error: " msg " **")) 
    ) 
    (setq *error* olderr) 
    (princ) 
  ) 
  (setq    doc (vla-get-ActiveDocument 
          (vlax-get-acad-object) 
        ) 
  ) 
  (setq    scl       (getvar "DIMSCALE") 
  ) 
  (setq 
    BkLst 
           '("AFC*"    "AS BUILT*"   "ASBUILT*"        "ASTERISK" 
         "BLUESTAKE STICK"    "BREAK LINE"       "BREAK" 
         "CENTER LINE*"   "COLUMN ROW BUBBLE*"   "DETAIL BUBBLE*" 
         "DIRECTIONAL ARROW"  "DUST PICK UP POINT*"
         "DYNAMIC WELD SYMBOL"   "EQUIPMENT TAG*" 
         "FLOW ARROW"       "FULL SECTION LR*" "FULL SECTION UD*"
         "FULL SECTION*"   "GWE*"   "ISSUED FOR*"  
         "M3LOGO"    "MATCH LINE*"   "ML"  "NORTH ARROW*"
         "NOTE BOX*"    "NOTE ENCL*"  "OFF SHEET REFERENCE"
         "PARTIAL SECTION*"   "PLATE*"        "PRELIMINARY*"
         "REFERENCE"   "REVISION*"   "SAMPLE NUMBER*" 
         "SECTION CUT*"   "SECTION MARKER"   "TAG"         "TAG2"
         "STAMP BIG*"         "STAMP SMALL*"     "STREAM*"    
         "TITLE*"     "TITLE BUBBLE*"     "WORK POINT*"    "WORKER*"
         "GST00*"     "GST01*"            "GST02*"         "GST031"
         "GST032"     "GST033"            "GST034"         "GST035" 
         "GST036"     "GST037"            "GST039"         "GST04*"   
         "A2"   "A3"    "AEC ISO A0"    "BLDG SEC LEFT"   "BLDG SEC RIGHT"  
         "BST"    "KEYNOTE"
         "BUILDING SECTION BOTTOM"   "BUILDING SECTION TOP"   
         "M_AEC3_ROOM_TAG_P"   "M_AEC4_ROOM_TAG_HIDTL_P"  
         "M_AEC4_ROOM_TAG_LODTL_P"    "M_AEC4_ROOM_TAG_MEDDTL_P"  
         "AIRPORT"   "BARN"   "BLDG"   "BRIDGE"   "CAPITOL CITY"   
         "CEMETARY"   "CITY"   "CIVIL SECTION MARKER"   "CUT SLOPE1"  
         "FED HWY SIGN"   "FILL SLOPE1"   "GRAVEL PIT"   "HYDRANT"   
         "LIGHT"   "MATCH POINT"   "MEXICAN HWY"   "MINE ENTRANCE" 
         "NAT HWY SIGN"   "OPEN PIT MINE"   "PORT OF ENTRY"   
         "POST BARRICADE"   "SCHOOL"   "SEC HWY"   "SHAFT"   
         "SPIRIT LEVEL ELEV"   "SPOT ELEV"   "STATE HWY SIGN"   
         "STATION PROFILE"   "STATION"   "TANK"   "TREE"   "UTILITY POLE"
         "WATER WELL"   "WORK POINT"   
         "1 HOT 1 NEUT"    "2 HOT 1 NEUT"    "2 HOT"     "3 HOT 1 NEUT"
         "3 HOT 2 NEUT"   "3 HOT 3 NEUT"   "3 HOT"   "3 WAY SWITCH"   
         "4 WAY SWITCH"   "ABCD QUAD"   "ADJ CAPACITOR"   "AIR_TERMINAL"  
         "AM VOLTMETER SW"   "AMMETER"   "ANNUNCIATOR"   "ANSI DEVICE"
         "AUTO TRANS"   "BATTERY"   "BUS MOTOR"   "CAPACITOR"   
         "CB 600V LESS"   "CB 600V"   "CEILING REC LT"   
         "CLOCK"   "CLOSED CONTACT"   "CLOSED FLOAT SWITCH"   
         "CLOSED FLOW SWITCH"   "CLOSED PUSHBUTTON"   "CONNECTION POINT" 
         "CONTINUATION"   "CONTROL SWITCH"   "CURRENT TRANS"   
         "CUTOUT FUSED"   "DATA OUTLET"   "DELTA CONNECTION"   
         "DIMMER SWITCH"   "DIODE"   "DISCONNECT"   "DOOR HOLDER"
         "DRAWOUT CB 1"   "DRAWOUT CB 2"   "DRAWOUT FUSE"   
         "DUAL PUSHBUTTON"   "E1"   "E14"   "E16"   "E17"   "E19"   
         "E3"   "E4"   "E46"   "E55A"   "E6"   "EIND0*"
         "ELG011"   "ELG043"   "ELG044"   "ELG048"   "ELG049"   "ELG050"  
         "ELG055"   "ELG056"   "EMERG LT"   "EMS006"   "EMS009"   "EMS010"
         "EMS011"   "EMS012"   "EMS013"   "EMS014"   "EMS025 U OF A"   
         "EPO"   "EPW043"   "EQUIP CONNECTION"   "EQUIPT TAG 1"   
         "EQUIPT TAG 3"   "EQUIPT TAG 4"   "EQUIPT TAG"   "ESS019"   
         "ESS020"   "ESS025"   "EX_WELD"   "EXIT LIGHT ARROW"   
         "EXIT LIGHT DOUBLE WALL"   "EXIT LIGHT DOUBLE"   
         "EXIT LIGHT SINGLE WALL"   "EXIT LIGHT SINGLE"   
         "EXIT LIGHT"   "FIELD"   "FIREALARMCONTROLPANEL"   "FLEX 1"   
         "FLEX 2"   "FLEX 3"   "FLOOR DATA"   "FLOW SW"   
         "FOOT SW CLOSED"    "FOOT SW OPEN"   "FULLWARE RECTIFIER"   
         "FUSE"    "GND WYE"
         "FUSED DISCONNECT"   "GENERATOR"   "GND WYE SECT"   "GND" 
         "GROUND_ROD"   "GROUND_WELL"   "HALONFIREPANEL"    "HEAT DET" 
         "HOMERUN*"  "HORN STROBE*"    "HORN"      "IND WALL*" 
         "INDUST DOWN ELEV*"    "INDUST WALL*"
         "J BOX"   "LIGHT"   "LIGHTNING ARRESTOR"   "LIMIT SW*" 
         "MCC VERT SECT"   "MCC"   "MINI HORN"   "MOTOR CIRCUIT 1"  
         "MOTOR CIRCUIT 2"   "MOTOR ELEV"   "MOTOR SWITCH"   "MOTOR" 
         "OCCUPANCY SENSOR"   "OHM SYMBOL"   "OPEN CONTACT"   
         "OPEN FLOAT SWITCH"   "OPEN FLOW SWITCH"   "OPEN PUSHBUTTON"  
         "P22"   "PANEL"   "PIGTAIL"   "PLC INPUT"   "PLC OUTLET"   
         "PLC"   "POTENTIAL TRANS"   "PRESSURE SW CLOSED"   
         "PRESSURE SW OPEN"   "PST002"   "PULL CORD SW"   "PULL STATION" 
         "PUSHBUTTON"   "RECEPT +48"   "RECEPT HALF SWITCH"   
         "RECEPT QUAD"   "RECEPT SINGLE"   "RECEPT SPECIAL"   "RECEPT"
         "RECEPTACLE"   "RELAY SOLENOID COIL"   "RESISTER GND WYE" 
         "RESISTOR"   "SEAL OFF"   "SEQ CURRENT TRANS"   "SINGLE FLOOD" 
         "SINGLE POLE LT"   "SINGLE SWITCH"   "SMOKE DET"   "STAB PLUG"
         "STARTER"   "STROBE"   "SWITCH 600V LESS"   "SWITCH 600V"   
         "SWITCHED FUSE"   "SYNCH MOTOR"   "TAMPER SW"   "TELE OULET" 
         "TEMP SW CLOSED"   "TEMP SW OPEN"   "TERMINAL 1"   "TERMINAL 10"
         "TERMINAL 2"   "TERMINAL 3"   "TERMINAL 4"   "TERMINAL 5"   
         "TERMINAL 6"   "TERMINAL 7"   "TERMINAL 8"   "TERMINAL 9"  
         "TERMINAL BLOCK"   "THERMAL OVERLOAD"   "TIME DELAY*" 
         "TRACK LIGHT"   "TV OUTLET"   "TWIN FLOOD"   "VACUUM CONTACTOR"  
         "WALL MOUNT"   "WIRE CALLOUT"   "WIREMOLD"   "42BHC10TOP"  
         "42BHC12TOP"   "42BHC16TOP"   "AIRRETURN"   "ARROWB"   
         "BO_350MBH"   "CAPTHREADED"   "CAPWELDED"   "CH_35TON"
         "CONCENTRICREDUCER"   "DIFF-1_WAY"   "DIFF-EXHAUST"   
         "DIFF-EXHST"   "DIFF-RETURN"   "DIFF-RTN"   "DIFF-SUP" 
         "DIFF-SUPPLY"   "DIFF-WALL"   "DIFFUSERTAG"   "DRAIN"   
         "DUCTVPROBE"   "ECCENTRICREDUCER"   "EVAPCOOLERIUP701"  
         "EVC_MASTERCOOLSZ601FRONT"   "EVC_SZ601TOP"   "FAN" 
         "FANCOIL42CKFRONT"   "FANCOIL42CKTOP"   "FIREDAMPERHORIZ"  
         "FIREDAMPERVERT"   "FIREDEPARTCONN"   "FIREHYDRANT"  
         "FLANGESET"   "FLOOR PENETRATION 1ISO"   "FLOWSWITCH"  
         "HOSECONNECTION"   "HUMIDISTAT"   "KEYNOTE"   "P1"   "P2" 
         "PRESSURESWITCH"   "PUMPHORIZCENTRIFUGAL"   "PUMPSYMBOL"
         "REVISIONTAG"   "ROOFVENTILATOR"   "SAMPLECONNECTION"   
         "SMOKEDAMPERHORIZ"   "SMOKEDAMPERVERT"   "SMOKEDETECTOR"
         "SMOKEFIREDAMPERHORIZ"   "SMOKEFIREDAMPERVERT"   "SPININ" 
         "STATICPRESSSENSOR"   "STATICPRESSURE"   "SYSTEMRISER" 
         "THERMOSTAT"   "TRIPLEDUTYVALVE"   "TURNINGVANES"   "TUSZ12"
         "TUSZ14"   "TUSZ16"   "TUSZ5_8"   "TUSZ9_10"   "UNION"   
         "VALVEBALL"   "VALVEBUTTERFLY"   "VALVECHECK"   "VALVEFLOAT"
         "VALVEGATE"   "VALVEROTARY"   "VAV10"   "VAV12"   "VAV14"
         "VAV16"   "VAV22"   "YSTRAINER"   
         "A200400RWH PLC PANDUITS WITH*"   
         "A726024FSD TYPE 12 ENCLOSURE DOUBLE DOOR SINGLE ACCESS"
         "A727224FSD HOFFMAN ENCLOSURE"   
         "A727224FSD TYPE 12 ENCLOSURE DOUBLE DOOR SINGLE ACCESS"  
         "A72P60F1 ENCLOSURE SUBPANEL"   "A72P72F1 ENCLOSURE SUBPANEL"
         "ABCD QUAD"   "ADJ CAPACITOR"   
         "ALF16D18 FLOURESCENT LIGHT WITH DOOR ACTUATED SWITCH" 
         "AM VOLTMETER SW"   "AMMETER"   "AND"   "ANSI DEVICE"  
         "ARITHMETIC"   "ARROWHEAD"   "AUTO TRANS"   "AVE"  
         "BATTERY"   "BLOCK XFR READ"   "BLOCK XFR WRITE"   
         "BUS MOTOR"   "CAPACITOR"   "CB 600V LESS"   "CB 600V"  
         "CLEAR"   "CLOSED CONTACT"   "CLOSED FLOAT SWITCH"   
         "CLOSED FLOW SWITCH"   "CLOSED PUSHBUTTON"   "COMPARATORS" 
         "COMPARISON"   "COMPUTE"   "CONNECTION DOT"   
         "CONNECTION POINT"   "CONTROL SWITCH"   "COPY"   "COUNTER"  
         "CURRENT TRANS"   "CUTOUT FUSED"   "DELTA CONNECTION"   
         "DIODE"   "DRAWOUT CB 1"   "DRAWOUT CB 2"   "DRAWOUT FUSE"
         "ELECT"   "FAL"   "FBD INPUT"   "FIELD"   "FOOT SW CLOSED"
         "FOOT SW OPEN"   "FULLWARE RECTIFIER"   "FUSE"   
         "FUSED DISCONNECT"   "GENERATOR"   "GND WYE SECT"   
         "GND WYE"    "HORN"   "HP36NOD"   "ILC0*"   
         "INPUT"   "JSR"   "JUMP"   "LABEL"   "LATCH UNLATCH"   
         "LIGHT"   "LIGHTNING ARRESTOR"   "LIMIT SW CLOSED"   
         "LIMIT SW HELD CLOSED"   "LIMIT SW HELD OPEN"    
         "LIMIT SW OPEN"   "LOGIX5 FLOW CHART"   "LOGIX5000 FLOW CHART"
         "MASKED EQUAL"   "MCC VERT SECT"   "MCC"   "MESSAGE"   
         "MOTOR CIRCUIT 1"   "MOTOR CIRCUIT 2"   "MOVE"   "NOT"  
         "OHM SYMBOL"   "ONE SHOT"   "ONS"   "OPEN CONTACT"   
         "OPEN FLOAT SWITCH"   "OPEN FLOW SWITCH"   "OPEN PUSHBUTTON"
         "OUTPUT"   "P22"   "PANELVIEW_900"   "PHOENIX CONTACT*"   "PID"
         "PLC GROUND BUS"   "PLC INPUT"   
         "PLC OUTLET"   "PLC RECEPTACLE"   "PLC"   "PNLVIEW"   
         "POTENTIAL TRANS"   "PRESSURE SW CLOSED"   "PRESSURE SW OPEN" 
         "PULL CORD SW"   "RECEPTACLE"   "RELAY SOLENOID COIL"   "RESET"  
         "RESISTER GND WYE"   "RESISTOR"   "SBR"   "SCLANGINPT"   "SCP"   
         "SEQ CURRENT TRANS"   "STAB PLUG"   "SWITCH 600V LESS"   
         "SWITCH 600V"   "SWITCHED FUSE"   "SYNCH MOTOR"   "TB AC"  
         "TB AI"   "TB AO"   "TB DC"   "TB DI"   "TB DO"   "TB UPS"   
         "TEXT HEADER"    "TIMER"   "TRANSFORMER"   "VACUUM CONTACTOR"  
         "215 MOTOR OPERATOR"   "407 PITOT"   "417 SONARTRAC"   
         "418 INSERTION MAG"   "ACTUATOR PNEUMATIC"   "ACTUATOR"  
         "AIR OPERATED VALVE"   "AIR VACUUM RELIEF VALVE"   "ALTITUDE VALVE"
         "ANGLE VALVE"   "ARRESTOR DETONATION"   "ARRESTOR FLAME"  
         "BALL VALVE"   "BLANK"   "BLAST GATE VALVE"   "BLIND FIGURE 8 CLOSED"
         "BLIND FIGURE 8 OPEN"   "BREAK"   "BREATHER"   "BUTTERFLY VALVE"  
         "CAP 1"   "CAP"   "CHECK VALVE"   "COMPUTER FUNCTION"   
         "CONNECTION HOSE"   "CONNECTION PURGE"   "CONNECTION SAMPLE"  
         "CONTROL ROOM INSTRUMENT"   "CONTROL VALVE"   "CONV DATA"   "DAMPER" 
         "DART VALVE"   "DESUPERHEATER"   "DIAPHRAGM ACTUATOR"   
         "DIAPHRAGM PB"   "DIAPHRAGM SEAL"   "DIAPHRAGM VALVE"   
         "DIVERTER VALVE"   "DRAIN"   "EJECTOR EDUCTOR"   
         "ELECTRO HYDRAULIC ACTUATOR"   "EQUIPMENT NUMBER"  
         "EXCESS FLOW VALVE"   "EXHAUST HEAD"  "EXPANSION JOINT"   
         "FIELD INSTRUMENT"   "FILTER 1"   "FILTER 2"   "FIRE EXTINGUISHER"  
         "FIRE HOSE CABINET"   "FIRE HYDRANT"   "FLANGE"   "FLOAT VALVE"  
         "FLOW ARROW"   "FLOW CONDITIONING DEVICE"   "FLOW METER MAGNETIC"   
         "FLOW METER POSITIVE DISPLACEMENT"   "FLOW METER TARGET"  
         "FLOW METER TURBINE"   "FLOW METER ULTRASONIC"   "FLOW METER VORTEX" 
         "FLOW NOZZLE"   "FLOW SWITCH"   "FLUME"   "GATE VALVE NC"   
         "GATE VALVE"   "GENERAL DATA"   "GLOBE VALVE NC"   "GLOBE VALVE" 
         "IN AUX PANEL"   "IN LINE MIXER"   "INSPOINT"   
         "INSULATED HEAT TRACED PIPE"   "INSULATED PIPE"   "INTERLOCK"   
         "KNIFE GATE"   "LINE NUMBER"   "LONG LINE NUMBER"   "LUBRICATOR"   
         "MAIN PANEL"   "MANUAL"   "MOTOR OP ACTUATOR"   "MOTOR"   
         "NEEDLE VALVE"   "OFF PAGE CONNECTOR R"   "OFF SHEET CONNECTOR L"  
         "ON AUX PANEL"   "ORIFICE PLATE"   "ORIFICE QC FITTING"  
         "ORIFICE RESTRICTION"   "ORIFICE_PLATE"   "PINCH VALVE"   
         "PITOT TUBE AVERAGING"   "PITOT TUBE"   "PLC INTERLOCK"   "PLUG VALVE" 
         "PNEUMATIC"   "PRESSURE RELIEF VALVE"   "PULSATION DAMPENER"  
         "PUMP DATA"   "RADIOACTIVE"   "REDUCER CONCENTRIC"   "REDUCER ECCENTRIC"
         "REGULATOR"   "REMOTE LIGHT"   "ROTARY AIR LOCK FEEDER"   "ROTARY VALVE"
         "ROTOMETER"   "SAFETY SHOWER"  "SCALE WEIGHT INDICATOR"   
         "SILENCER IN LINE"   "SILENCER VENT"   "SOLENOID 3 WAY"   
         "SOLENOID 4 WAY"   "SOLENOID RESET"   "SOLENOID VALVE"   
         "SONIC LEVEL SIGNAL"   "SPACER"   "SPRAY NOZZLE"   
         "SPRING RETURN CYLINDER"   "STEAM TRAP"   "STRAINER BASKET"  
         "STRAINER CONE"   "STRAINER DUPLEX"   "STRAINER T"   "STRAINER TEMPORARY"
         "STRAINER Y"   "TANK DATA"   "TEST PORT"   "UNION"   "VENTURI"   
         "WAFER STYLE PRESSURE SENSOR"   "WARNING HORN"   "WEDGE METER"   "WEIR" 
         "WELDED CONNECTION"   "001 ARROW"   "002 BALL"   "003 BUTTERFLY"   
         "004 CHECK"   "005 GATE"   "006 CONTROL"   "007"   "008 KNIFE GATE"  
         "009 PLUG"   "010 REGULATOR"   "011 REDUCER"   "012 FLANGE"   "013 PUMP"
         "014 METERING PUMP"   "015 GLOBE"   "016 PINCH"   "017 RELIEF" 
         "018 NEEDLE"   "020 ACTUATOR"   "021 ACTUATOR"   "023 ALTITUDE" 
         "024 CONNECTION"   "025 BREAK"   "026 SONIC"   "215 MOTOR OPERATOR"   
         "301 LEFT"   "302 LEFT"   "303 RIGHT"   "304 RIGHT"   "305 LONG LINE" 
         "305 REG LINE"   "306 EQ NUMBER"   "307 LONG EQ NO"   "308 X LONG EQ NO"
         "309 PUMP DATA"   "310 CONV DATA"   "311 TANK DATA"   "312 GENERAL DATA" 
         "401 MAG"   "402 TURBINE"   "403 ULTRASONIC"   "404 VENTURI"  
         "405 VORTEX"   "406 WEDGE"   "407 PITOT"   "408 PITOT AVERAGING"   
         "409 ORIFICE"   "410 FLUME"   "411 TARGET"   "412 POS DISP"   "413 NOZZLE"
         "414 ORIFICE"   "415 WEIR"   "417 SONARTRAC"   "418 INSERTION MAG"  
         "419 ROTAMETER"   "420 ROTAMETER"   "421 ROTAMETER"   "501 SPRAY NOZZLE"
         "502 DIAPHRAGM SEAL"   "503 PRESSURE SENSOR"   "504 AIR RELEASE"   
         "505 HOSE CONNECTION"   "506 BLOWER"   "507 DRAIN"   "508 EXPANSION JOINT"
         "509 Y STRAINER"   "510 ROTARY VALVE"   "511 INLINE MIXER"   "512 CAP"
         "513 EYE WASH SHOWER"   "514 CONE STRAINER"   "515 T STRAINER"   
         "516 DUPLEX STRAINER"   "517 BASKET STRAINER"   "518 FILTER"   
         "519 FILTER2"   "520 LUBRICATOR"   "521 DET ARREST"   "522 FLAME ARREST"
         "523 STEAM TRAP"   "524 EDUCTOR"   "525 PULSATION DAMPENER"   
         "526 IN LINE SILENCER"   "527 VENT SILENCER"   "528 DESUPERHEATER"   
         "530 SAMPLE CONNECTION"   "531 INSULATION"   "532 HEAT TRACED"   
         "533 NUCLEAR"   "534 DBL SOL"   "ACTUATOR_MOTOR_OPERATED"   
         "ARRESTOR_DETONATION"   "EDUCTOR_EJECTOR"   "FILTER"   
         "FLOW_ELEMENT_WEIR"   "PST013"   "PST014"   "STRAINER_*"  
         "VALVE_SOLENOID_4_WAY"   "AIR VENT L"   "AIR VENT R"   "ANGLE VAL*"
         "ARRO*"   "BALL VAL*"   "BATHTUB R UP"   "BUTTERFLY VAL*"   
         "CAP*"   "CHECK VAL*"   "CLEAN OUT RH UP"   "CLEANOUT L DOWN" 
         "CLEANOUT*"   "CONTROL VAL*"  "DART VAL*"   "DOUBLE LATERAL*"   
         "ECC REDUCER VAL*"   "FIXTURE STACK*"   "FLANGE*"   "GATE VAL*"
         "GROUND FLOOR*"   "LATERAL*"   "NEEDLE VAL*"   "PINCH VAL*"   
         "PLUG VAL*"   "PST001"   "REDUCER VAL*"   "SOLENOID VAL*" 
         "UNION*"   "URINAL L*"   "URINAL R*"  "VTR L"   "VTR R"   
         "WATER CLOSET L*"    "WATER CLOSET R*"   "WHA L"   "WHA R"
         "CR1"         "A2"          "A3"       "ESS022"       "DOORTAG"
         "WINDOWTAG"         "WALLTAG"          "ROOMTAG"       "ROOMTAG2"
         "ROOMTAG3"        "MULTIPLE DETAIL"     "KEYNOTE1"     "KEYNOTE2"    
	 "KEYNOTES"          "EIND00842" 	
        ) 
    NomBloques (car BkLst) 
    BkName     (mapcar '(lambda    (x) 
              (setq NomBloques (strcat NomBloques "," x)) 
            ) 
               (cdr BkLst) 
           ) 
  ) 


  (princ "\n Selecciona todo el detalle a escalar :") 
  (if (setq s_set (ssget (list '(-4 . "<OR") 
                   '(0 . "TEXT") 
                   '(0 . "MTEXT") 
                   '(0 . "DIMENSION") 
                   '(0 . "LEADER") 
                    ; _Se seleccionan todos los bloques de 
                    ; usuario, despues se procesaran los 
                    ; nombres esto para poder procesar los 
                    ; bloques dinamicos 
                   '(-4 . "<AND") 
                   '(0 . "INSERT") 
                   (cons 2 (strcat NomBloques ",`*U*")) 
                   '(-4 . "AND>") 
                   '(-4 . "OR>") 
             ) 
          ) 
      ) 
    (progn 
      (vla-StartUndoMark doc) 
      (setq new_heigth (* (getvar 'DimScale)0.125)) 
;_ Mcoan Verificamos cada objeto en la seleccion para procesarlo 
      (vlax-for    Obj (setq sel (vla-get-ActiveSelectionSet doc)) 
    (cond 
      ((and 
         (=    (setq Oname (vla-get-Objectname Obj)) 
        "AcDbBlockReference" 
         ) 
         (wcmatch (strcase (vla-get-EffectiveName Obj)) NomBloques) 
       ) 
       ;;;Para evitar problemas al escalar bloques con atributos, mejor 
       ;;;escalamos los bloques con un metodo para el objeto y no  
       ;;;con la propiedad de escala del bloque. 
       (setq sc (/ 1 (/ (vla-get-XScaleFactor Obj) scl))) 
       ;;;Se usa el factor de escala del bloque sin signo, para evitar 
       ;;;errores al escalar un objeto con escala negativa 
       (vla-ScaleEntity obj (vla-get-InsertionPoint Obj) (abs sc)) 
      ) 
      ((wcmatch Oname "AcDbMText,AcDbText") 
       (vla-put-Height Obj new_heigth) 
       ;;;La propiedad ScaleFactor no esta presente en Mtextos 
       (if (vlax-property-available-p obj 'ScaleFactor) 
         (vla-put-ScaleFactor Obj 0.80) 
       ) 
      ) 
      ((wcmatch (strcase Oname) "*LEADER,*DIM*") 
        (vl-catch-all-apply 'vla-put-ScaleFactor (list Obj scl)) 
      ) 
    ) 
      ) 
      (vla-delete sel) 
      (vla-EndUndoMark doc) 
    ) 
  ) 
  (princ) 
 (command "_.-dimstyle" "_apply" "P" "")
) 
 ;|ซVisual LISPฉ Format Optionsป 
(80 2 40 2 nil "end of " 60 9 0 0 0 T T T T) 
;*** DO NOT add text below the comment! ***|; 


;;


; DVA.LSP

; Jim Nakazawa
; (415) 768-1234

; TO SET DVIEW TWIST ANGLE BY POINTING TO AN EXISTING LINE
; FIRST DRAW THE LINE FROM LEFT TO RIGHT THAT YOU WANT TO SET THE DVIEW
; TWIST ANGLE FROM

(defun C:DVA (/ rgm a b pt1 pt2 ang1 )
  (setq rgm (getvar "regenmode"))
  (command "setvar" "regenmode" 0)
  (setq a (entsel "Pick Line to Set DVIEW TWist Angle: "))
  (setq b (entget (car a)))
  (setq pt1 (cdr (assoc 10 b)))
  (setq pt2 (cdr (assoc 11 b)))
  (setq ang1 (angle pt1 pt2))
  (setq ang1 (/ (* ang1 180.0) pi))
  (setq ang1 (- ang1))
  (command "dview"  "" "tw" ang1 "")
  (command "setvar" "regenmode" rgm)
  (princ "Dview Twist Angle Set to ") (princ (+ 360.0 ang1)) (terpri)
;this should be modified to show angle in current angular units
  (princ)
) ;this routine seems to work



;;


; DVW.LSP Returns the model view to normal -world-

; Jim Nakazawa
; (415) 768-1234

; TO SET DVIEW TWIST ANGLE BY POINTING TO AN EXISTING LINE
; FIRST DRAW THE LINE FROM LEFT TO RIGHT THAT YOU WANT TO SET THE DVIEW
; TWIST ANGLE FROM

(defun C:DVW ()
  (setq rgm (getvar "regenmode"))
  (command "setvar" "regenmode" 0)
  (command "dview"  "all" "" "twist" "0" "")
  (command "setvar" "regenmode" rgm)
;this should be modified to show angle in current angular units
  (princ)
) ;this routine seems to work


;;


;Tip1823:   EAT.LSP            EDIT ATTRIBUTE TEXT            (C)2002, Theodorus Winata

;;; A function for changing attribute text angle, height, style, text and width
;;;
;;;********** Error Handler **********
(defun
   ERR (X)
  (if (= "Function Cancelled" X)
    (setq X "Ctrl+C or Esc key pressed.")
  ) ;_ end of if
  (setq *ERROR* OLDERR)
  (princ (strcat "\nError: " X))
  (princ)
) ;_ end of defun
;;ERR

;;;********** Main Program **********
(defun
   C:EAT (/ CE CN DT EN NA NE NH NS NT NW OLDERR OP SL SN SS)
  (setq
    OLDERR *ERROR*
    *ERROR* ERR
    CE (getvar "CMDECHO")
    SS (ssget '((0 . "INSERT")))
    CN 0
  ) ;_ end of setq
  ;;setq
  (setvar "CMDECHO" 0)
  (initget "A H S T W")
  (setq
    OP
     (getkword
       "\nChange Attribute (A)ngle/(H)eight/(S)tyle/(T)ext/(W)idth: "
     ) ;_ end of getkword
  ) ;_ end of setq
  (cond
    ((= OP "A")
     (setq NA (getangle "\nNew Text Angle for Attribute: "))
     (if (= NA NIL)
       (setq NA 0)
     ) ;_ end of if
     (if SS
       (repeat (setq SL (sslength SS))
         (setq
           SN (ssname SS CN)
           NE (entnext SN)
         ) ;_ end of setq
         ;;setq
         (while (and
                  NE
                  (/= (setq EN (cdr (assoc 0 (setq DT (entget NE)))))
                      "SEQEND"
                  ) ;_ end of /=
                ) ;_ end of and
           (if (= EN "ATTRIB")
             (progn
               (setq DT (subst (cons 50 NA) (assoc 50 DT) DT))
               (entmod DT)
               (entupd SN)
             ) ;_ end of progn
             ;;progn
           ) ;_ end of if
           ;;if
           (setq NE (entnext NE))
         ) ;_ end of while
         ;;while
         (setq CN (1+ CN))
         (repeat 25 (princ "\010"))
         (princ (strcat "Total " (itoa CN) " done of " (itoa SL)))
       ) ;_ end of repeat
       ;;repeat
       (princ "\nNo input")
     ) ;_ end of if
     ;;if
    )
    ;;A
    ((= OP "H")
     (setq NH (getreal "\nNew Text Height for Attribute: "))
     (if SS
       (repeat (setq SL (sslength SS))
         (setq
           SN (ssname SS CN)
           NE (entnext SN)
         ) ;_ end of setq
         ;;setq
         (while (and
                  NE
                  (/= (setq EN (cdr (assoc 0 (setq DT (entget NE)))))
                      "SEQEND"
                  ) ;_ end of /=
                ) ;_ end of and
           (if (= EN "ATTRIB")
             (progn
               (setq DT (subst (cons 40 NH) (assoc 40 DT) DT))
               (entmod DT)
               (entupd SN)
             ) ;_ end of progn
             ;;progn
           ) ;_ end of if
           ;;if
           (setq NE (entnext NE))
         ) ;_ end of while
         ;;while
         (setq CN (1+ CN))
         (repeat 25 (princ "\010"))
         (princ (strcat "Total " (itoa CN) " done of " (itoa SL)))
       ) ;_ end of repeat
       ;;repeat
       (princ "\nNo input")
     ) ;_ end of if
     ;;if
    )
    ;;H
    ((= OP "S")
     (setq NS (getstring "\nNew Text Style for Attribute: "))
     (if SS
       (repeat (setq SL (sslength SS))
         (setq
           SN (ssname SS CN)
           NE (entnext SN)
         ) ;_ end of setq
         ;;setq
         (while (and
                  NE
                  (/= (setq EN (cdr (assoc 0 (setq DT (entget NE)))))
                      "SEQEND"
                  ) ;_ end of /=
                ) ;_ end of and
           (if (= EN "ATTRIB")
             (progn
               (setq DT (subst (cons 7 NS) (assoc 7 DT) DT))
               (entmod DT)
               (entupd SN)
             ) ;_ end of progn
             ;;progn
           ) ;_ end of if
           ;;if
           (setq NE (entnext NE))
         ) ;_ end of while
         ;;while
         (setq CN (1+ CN))
         (repeat 25 (princ "\010"))
         (princ (strcat "Total " (itoa CN) " done of " (itoa SL)))
       ) ;_ end of repeat
       ;;repeat
       (princ "\nNo input")
     ) ;_ end of if
     ;;if
    )
    ;;S
    ((= OP "T")
     (setq NT (getstring "\nNew Text for Attribute: "))
     (if SS
       (repeat (setq SL (sslength SS))
         (setq
           SN (ssname SS CN)
           NE (entnext SN)
         ) ;_ end of setq
         ;;setq
         (while (and
                  NE
                  (/= (setq EN (cdr (assoc 0 (setq DT (entget NE)))))
                      "SEQEND"
                  ) ;_ end of /=
                ) ;_ end of and
           (if (= EN "ATTRIB")
             (progn
               (setq DT (subst (cons 1 NT) (assoc 1 DT) DT))
               (entmod DT)
               (entupd SN)
             ) ;_ end of progn
             ;;progn
           ) ;_ end of if
           ;;if
           (setq NE (entnext NE))
         ) ;_ end of while
         ;;while
         (setq CN (1+ CN))
         (repeat 25 (princ "\010"))
         (princ (strcat "Total " (itoa CN) " done of " (itoa SL)))
       ) ;_ end of repeat
       ;;repeat
       (princ "\nNo input")
     ) ;_ end of if
     ;;if
    )
    ;;T
    ((= OP "W")
     (setq NW (getreal "\nNew Text Width for Attribute: "))
     (if SS
       (repeat (setq SL (sslength SS))
         (setq
           SN (ssname SS CN)
           NE (entnext SN)
         ) ;_ end of setq
         ;;setq
         (while (and
                  NE
                  (/= (setq EN (cdr (assoc 0 (setq DT (entget NE)))))
                      "SEQEND"
                  ) ;_ end of /=
                ) ;_ end of and
           (if (= EN "ATTRIB")
             (progn
               (setq DT (subst (cons 41 NW) (assoc 41 DT) DT))
               (entmod DT)
               (entupd SN)
             ) ;_ end of progn
             ;;progn
           ) ;_ end of if
           ;;if
           (setq NE (entnext NE))
         ) ;_ end of while
         ;;while
         (setq CN (1+ CN))
         (repeat 25 (princ "\010"))
         (princ (strcat "Total " (itoa CN) " done of " (itoa SL)))
       ) ;_ end of repeat
       ;;repeat
       (princ "\nNo input")
     ) ;_ end of if
     ;;if
    )
    ;;W
  ) ;_ end of cond
  ;;cond
  (setvar "CMDECHO" CE)
  (setq *ERROR* OLDERR)
  (princ)
) ;_ end of defun
;;C:EAT



;;


; Allows editing of multiple attributes
; ษอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออป
; บ  Program: EDAT.LSP                                                    บ                        
; บ  Purpose: Allows editing of multiple attributes                         บ
; บ   Syntax: ed_att                                                        บ
; บ       By: RESOLUTIONS Computer Consulting                               บ
; บ           P.O. Box 1265                                                 บ
; บ           Sumner, WA 98390                                              บ
; บ           (206) 845-2200                                                บ
; บ                                                                         บ
; บ     Date: 6/6/92, 2/17/95, 3/9/95                                       บ
; บ                                                                         บ
; บ  Revisions:                                                             บ
; บ        4/20/95  Added option to list the TAG names & prompts            บ
; บ        5/31/95  Added option to change attrib Elevation                 บ
; บ        1/12/96  Removed testing statement from "*" position             บ
; บ        3/3 /98  Oblique angle added                                     บ
; บ                                                                         บ
; บ                                                                         บ
; ศอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผ
;;(princ "\nLoading....Please wait.\n")
(defun c:edat (
;(defun c:ed_att (/ p1 p2 newval ss tag ans nr i l e fvalue pl val
;					askstring ins_pt pt rot_pt r_fill ent
				)
	(defun r_fill (s len / space)
	   (setq space "" i (- len (strlen s)))
	   (substr (strcat s (repeat i (setq space (strcat space " ")))) 1 len)
	)
	(defun val (nr e) (cdr (assoc nr e)))
	(defun askstring (prmpt default / str)                ; ask for string
		(if (null default)
			(setq default "")
		)
		(princ (strcat "\n" prmpt " <" default ">: "))  ; show prompt & default value
		(setq str (getstring T))
		(if (= str "")
			default                       ; not typed so return default
			str                           ; string was typed so return it
		)
	)
	(if (setq ss (ssget '((0 . "INSERT") (66 . 1))))
		(progn
			(setq tag "*")
			(setq tag (strcase (askstring "Attribute TAG to edit (or ?)" tag)))
			(while (= tag "?")
				(textpage)
				(princ "\nTAG Name        Prompt")
				(princ "\n--------        ------")
				(setq e (entget (ssname ss 0)))
				(setq ent (val -2 (tblsearch "block" (val 2 e))))
				(while ent
					(setq e (entget ent))
					(if (= (val 0 e) "ATTDEF")
						(princ (strcat "\n" (r_fill (val 2 e) 16) (val 3 e)))
					)
					(setq ent (entnext (val -1 e)))
				)
				(princ "\n")
				(setq tag (strcase (askstring "Attribute TAG to edit (or ?)" "*")))
			)
			(graphscr)
			(initget 1 "Color Decimals Elevation Height Layer Oblique Position Rotation Style Value")
			(setq ans (getkword "\nColor/Decimals/Elevation/Height/Layer/Oblique/Position/Rotation/Style/Value: "))
			(cond
				((= ans "Color") (setq nr 62 newval (getint "\nNew Color Number (0 = BYBLOCK, 256 = BYLAYER): ")))
				((= ans "Decimals") (setq nr 1 newval T pl (getint "\nNumber of decimal places: ")))
				((= ans "Height") (setq nr 40 newval (getdist "\nNew Height: ")))
				((= ans "Oblique") (setq nr 51 newval (getangle "\nNew Oblique angle: ")))
				((= ans "Elevation") (setq nr 10 elev (getreal "\nNew Elevation: ")))
				((= ans "Layer") (setq nr 8 newval (getstring "\nNew Layer: "))
					(while (= (tblsearch ans newval) nil)
						(princ (strcat "\n" (strcase newval) " not defined:"))
						(setq newval (getstring "\nNew Layer: "))
					)
				)
				((= ans "Position")(setq nr 10 p1 (getpoint "\nBase point: "))
					(if p1
						(setq p2 (getpoint p1 "\nNew point: ") newval T)
					)
				)
				((= ans "Rotation")
					(setq nr 50 newval (getangle "\nNew Angle: "))
					(initget 1 "Attribute Block")
					(setq rot_pt (getkword "\nRotate about? (Attribute/Block): "))
				)
				((= ans "Style") (setq nr 7 newval (getstring "New Style: "))
					(while (= (tblsearch ans newval) nil)
						(princ (strcat "\n" (strcase newval) " not defined:"))
						(setq newval (getstring "\nNew Style: "))
					)
				)
				((= ans "Value") (setq nr 1 newval (getstring T "\nNew Value: ")))
			)
			(setq i 0 l (sslength ss))
			(while (and newval (< i l))
				(setq e (entget (ssname ss i)))
				(if (and (= (val 0 e) "INSERT") (= (val 66 e) 1))
					(progn
						(setq ins_pt (val 10 e))
						(princ ".")
						(setq e (entget (entnext (val -1 e))))
						(cond 
							((= tag "*")
								(while (/= (val 0 e) "SEQEND")
									(cond
										((= ans "Color")
											(if (null (val 62 e))
												(setq e (append (list (cons 62 7)) e))
											)
										)
										((= ans "Decimals")
											(setq fvalue (atof (val 1 e)))
											(if (zerop fvalue)
												(setq newval (val 1 e))
												(setq newval (rtos fvalue 2 pl))
											)
										)
										((= ans "Position")
											(setq newval (polar (val 10 e) (angle p1 p2) (distance p1 p2)))
;											(princ newval)
;											(getstring)
										)
										((= ans "Elevation")
											(setq newval (list (car (val 11 e)) (cadr (val 11 e)) elev))
											(setq e (subst (cons 11 newval) (assoc 11 e) e))
											(setq newval (list (car (val 10 e)) (cadr (val 10 e)) elev))
										)
									)
									(setq e (subst (cons nr newval) (assoc nr e) e))
									(entmod e)
									(entupd (val -1 e))
									(setq e (entget (entnext (val -1 e))))
								)
							)
							(t (while (/= (val 0 e) "SEQEND")
								(if (= tag (val 2 e))
									(progn
										(cond
											((= ans "Color")
												(if (null (val 62 e))
													(setq e (append (list (cons 62 7)) e))
												)
											)
											((= ans "Decimals")
												(setq fvalue (atof (val 1 e)))
												(if (zerop fvalue)
													(setq newval (val 1 e))
													(setq newval (rtos fvalue 2 pl))
												)
											)
											((= ans "Position")
												(setq newval (polar (val 10 e) (angle p1 p2) (distance p1 p2)))
											)
											((= ans "Elevation")
												(setq newval (list (car (val 11 e)) (cadr (val 11 e)) elev))
												(setq e (subst (cons 11 newval) (assoc 11 e) e))
												(setq newval (list (car (val 10 e)) (cadr (val 10 e)) elev))
											)
											((= ans "Rotation")
												(if (= rot_pt "Block")
													(progn
														(setq pt (polar ins_pt newval (distance ins_pt (val 10 e))))
														(setq e (subst (cons 10 pt) (assoc 10 e) e))
													)
												)
											)
										)
										(setq e (subst (cons nr newval) (assoc nr e) e))
										(entmod e)
										(entupd (val -1 e))
									)
								)
								(setq e (entget (entnext (val -1 e)))))
							)
						)
					)
				)
				(setq i (1+ i))
			)
		)
		(princ "\nNothing selected.")
	)
	(princ)
)
;;(princ "\nMultiple Attribute Edit.  Version 1.3")
(princ)



;;

;; http://www.cadtutor.net/forum/showthread.php?t=45159
;; Lee McDonnell  February 23rd,2010

(defun c:ela (/ ent layer i ss ent)
  (vl-load-com)
  
  (cond (  (setq ent (car (nentsel "\nSelect Object on Layer to Delete: ")))

           (setq layer (cdr (assoc 8 (entget ent))))

           (setq i -1 ss (ssget "_X" (list (cons 8 layer))))
           (while (setq ent (ssname ss (setq i (1+ i)))) (entdel ent))

           (vlax-for blks (vla-get-Blocks
                            (vla-get-ActiveDocument
                              (vlax-get-acad-object)))

             (vlax-for obj blks
               (if (eq (strcase layer) (strcase (vla-get-layer obj)))
                 (vla-delete obj))))))
  (princ))

;;

;Tip1702:   esc.LSP         Quick scale table   (c)2009, Paulo Gil
(defun C:esc  ()
  (alert
    "\nEscala	Estand	Titulos	DimscaleLtscale		Scale		Stand	Title	DimscaleLtscale
\ 1	3.175	6.350	25.4	10.16		1'-0=1'-0		0.125	0.250	1	0.4
5	15.875	31.750	127.0	50.80		6''=1'-0		0.250	0.50	2	0.8
10	31.750	63.500	254.0	101.60		3''=1'-0''		0.500	1.00	4	1.6
20	63.500	127.000	508.0	203.20		1 1/2''=1'-0''	1.000	2.00	8	3.2
25	79.375	158.750	635.0	254.00		1''=1'-0''		1.500	3.00	12	4.8
30	95.250	190.500	762.0	304.80		3/4''= 1'-0''	2.000	4.00	16	6.4
40	127.000	254.000	1016.0	406.40		1/2''= 1'-0''	3.000	6.00	24	9.6
50	158.750	317.500	1270.0	508.00		3/8''= 1'-0''	4.000	8.00	32	12.8
60	190.500	381.000	1524.0	609.60		1/4''= 1'-0''	6.000	12.00	48	19.2
70	222.250	444.500	1778.0	711.20		3/16''= 1'-0''	8.000	16.00	64	25.6
75	238.125	476.250	1905.0	762.00		1/8''=1'-0''	12.0	24.00	96	38.4
80	254.000	508.000	2032.0	812.80		3/32''=1'-0''	16.0	32.00	128	51.2
100	317.500	635.000	2540.0	1016.00		1/16''=1'-0''	24.0	48.00	192	76.8
125	396.875	793.750	3175.0	1270.00		1''=10'		15.0	30.00	120	48.0
150	476.250	952.500	3810.0	1524.00		1''=20'		30.0	60.00	240	96.0
175	555.625	1111.25	4445.0	1778.00		1''=30'		45.0	90.00	360	144.0
200	635.000	1270.00	5080.0	2032.00		1''=40'		60.0	120.0	480	192.0
250	793.750	1587.50	6350.0	2540.00		1''=50'		75.0	150.0	600	240.0
300	952.500	1905.00	7620.0	3048.00		1''=60'		90.0	180.0	720	288.0
350	1111.25	2222.50	8890.0	3556.00		1''=70'		105.0	210.0	840	336.0
400	1270.00	2540.00	10160	4064.00		1''=80'		120.0	240.0	960	384.0
500	1587.50	3175.00	12700	5080.00		1''=90'		135.0	270.0	1080	432.0
750	2381.25	4762.50	19050	7620.00		1''=100'		150.0	300.0	1200	480.0
800	2540.00	5080.00	20320	8128.00		1''=200'		300.0	600.0	2400	960.0
1000	3175.00	6350.00	25400	10160.00		1''=300'		450.0	900.0	3600	1440.0
1250	3968.75	7937.50	31750	12700.00		1''=400'		600.0	1200.0	4800	1920.0
2000	6350.0	12700.0	50800	20320.00		1''=500'		750.0	1500.0	6000	2400.0
2500	7937.5	15875.0	63500	25400.00		1''=600'		900.0	1800.0	7200	2880.0
3000	9525.0	19050.0	76200	30480.00		1''=800'		1200.0	2400.0	9600	3840.0
4000	12700.0	25400.0	101600	40640.00		1''=1000'		1500.0	3000.0	12000	4800.0
5000	15875.0	31750.0	127000	50800.00
10000	31750.0	63500.0	254000	101600.00
\n")
  (princ)
  )


;;

;;;
;;;    BURST.LSP
;;;    Copyright ฉ 1999 by Autodesk, Inc.
;;;
;;;    Your use of this software is governed by the terms and conditions of the
;;;    License Agreement you accepted prior to installation of this software.
;;;    Please note that pursuant to the License Agreement for this software,
;;;    "[c]opying of this computer program or its documentation except as
;;;    permitted by this License is copyright infringement under the laws of
;;;    your country.  If you copy this computer program without permission of
;;;    Autodesk, you are violating the law."
;;;
;;;    AUTODESK PROVIDES THIS PROGRAM "AS IS" AND WITH ALL FAULTS.
;;;    AUTODESK SPECIFICALLY DISCLAIMS ANY IMPLIED WARRANTY OF
;;;    MERCHANTABILITY OR FITNESS FOR A PARTICULAR USE.  AUTODESK, INC.
;;;    DOES NOT WARRANT THAT THE OPERATION OF THE PROGRAM WILL BE
;;;    UNINTERRUPTED OR ERROR FREE.
;;;
;;;    Use, duplication, or disclosure by the U.S. Government is subject to
;;;    restrictions set forth in FAR 52.227-19 (Commercial Computer
;;;    Software - Restricted Rights) and DFAR 252.227-7013(c)(1)(ii)
;;;    (Rights in Technical Data and Computer Software), as applicable.
;;;
;;;  ----------------------------------------------------------------

(Defun C:EXB (/ item bitset bump att-text lastent burst-one burst
                  BCNT BLAYER BCOLOR ELAST BLTYPE ETYPE PSFLAG ENAME )

   ;-----------------------------------------------------
   ; Item from association list
   ;-----------------------------------------------------
   (Defun ITEM (N E) (CDR (Assoc N E)))
   ;-----------------------------------------------------
   ; Error Handler
   ;-----------------------------------------------------

  (acet-error-init
    (list
      (list "cmdecho" 0
            "highlight" 1
      )
      T     ;flag. True means use undo for error clean up.
    );list
  );acet-error-init


   ;-----------------------------------------------------
   ; BIT SET
   ;-----------------------------------------------------

   (Defun BITSET (A B) (= (Boole 1 A B) B))

   ;-----------------------------------------------------
   ; BUMP
   ;-----------------------------------------------------

   (Setq bcnt 0)
   (Defun bump (prmpt)
      (Princ
         (Nth bcnt '("\r-" "\r\\" "\r|" "\r/"))
      )
      (Setq bcnt (Rem (1+ bcnt) 4))
   )

   ;-----------------------------------------------------
   ; Convert Attribute Entity to Text Entity
   ;-----------------------------------------------------

   (Defun ATT-TEXT (AENT / TENT ILIST INUM)
      (Setq TENT '((0 . "TEXT")))
      (ForEach INUM '(8
            6
            38
            39
            62
            67
            210
            10
            40
            1
            50
            41
            51
            7
            71
            72
            73
            11
         )
         (If (Setq ILIST (Assoc INUM AENT))
            (Setq TENT (Cons ILIST TENT))
         )
      )
      (Setq
         tent (Subst
                 (Cons 73 (item 74 aent))
                 (Assoc 72 tent)
                 tent
              )
      )
      (EntMake (Reverse TENT))
   )

   ;-----------------------------------------------------
   ; Find True last entity
   ;-----------------------------------------------------

   (Defun LASTENT (/ E0 EN)
      (Setq E0 (EntLast))
      (While (Setq EN (EntNext E0))
         (Setq E0 EN)
      )
      E0
   )

   ;-----------------------------------------------------
   ; Burst one entity
   ;-----------------------------------------------------

   (Defun BURST-ONE (BNAME / BENT ANAME ENT ATYPE AENT AGAIN ENAME
                     ENT SS-COLOR SS-LAYER SS-LTYPE mirror ss-mirror
                     mlast)
      (Setq
         BENT   (EntGet BNAME)
         BLAYER (ITEM 8 BENT)
         BCOLOR (ITEM 62 BENT)
         BCOLOR (Cond
                   ((> BCOLOR 0) BCOLOR)
                   ((= BCOLOR 0) "BYBLOCK")
                   ("BYLAYER")
                )
         BLTYPE (Cond ((ITEM 6 BENT)) ("BYLAYER"))
      )
      (Setq ELAST (LASTENT))
      (If (= 1 (ITEM 66 BENT))
         (Progn
            (Setq ANAME BNAME)
            (While (Setq
                      ANAME (EntNext ANAME)
                      AENT  (EntGet ANAME)
                      ATYPE (ITEM 0 AENT)
                      AGAIN (= "ATTRIB" ATYPE)
                   )
               (bump "Converting attributes")
               (ATT-TEXT AENT)
            )
         )
      )
         (Progn
            (bump "Exploding block")
            (Command "_.explode" BNAME)
         )
      (Setq
         SS-LAYER (SsAdd)
         SS-COLOR (SsAdd)
         SS-LTYPE (SsAdd)
         ENAME    ELAST
      )
      (While (Setq ENAME (EntNext ENAME))
         (bump "Gathering pieces")
         (Setq
            ENT   (EntGet ENAME)
            ETYPE (ITEM 0 ENT)
         )
         (If (= "ATTDEF" ETYPE)
            (Progn
               (If (BITSET (ITEM 70 ENT) 2)
                  (ATT-TEXT ENT)
               )
               (EntDel ENAME)
            )
            (Progn
               (If (= "0" (ITEM 8 ENT))
                  (SsAdd ENAME SS-LAYER)
               )
               (If (= 0 (ITEM 62 ENT))
                  (SsAdd ENAME SS-COLOR)
               )
               (If (= "BYBLOCK" (ITEM 6 ENT))
                  (SsAdd ENAME SS-LTYPE)
               )
            )
         )
      )
      (If (> (SsLength SS-LAYER) 0)
         (Progn
            (bump "Fixing layers")
            (Command
               "_.chprop" SS-LAYER "" "_LA" BLAYER ""
            )
         )
      )
      (If (> (SsLength SS-COLOR) 0)
         (Progn
            (bump "Fixing colors")
            (Command
               "_.chprop" SS-COLOR "" "_C" BCOLOR ""
            )
         )
      )
      (If (> (SsLength SS-LTYPE) 0)
         (Progn
            (bump "Fixing linetypes")
            (Command
               "_.chprop" SS-LTYPE "" "_LT" BLTYPE ""
            )
         )
      )
   )

   ;-----------------------------------------------------
   ; BURST MAIN ROUTINE
   ;-----------------------------------------------------

   (Defun BURST (/ SS1)
      (setq PSFLAG (if (= 1 (caar (vports)))
                       1 0
                   )
      )
      (Setq SS1 (SsGet (list (cons 0 "INSERT")(cons 67 PSFLAG))))
      (If SS1
         (Progn
            (Setvar "highlight" 0)
            (terpri)
            (Repeat
               (SsLength SS1)
               (Setq ENAME (SsName SS1 0))
               (SsDel ENAME SS1)
               (BURST-ONE ENAME)
            )
            (princ "\n")
         )
      )
   )

   ;-----------------------------------------------------
   ; BURST COMMAND
   ;-----------------------------------------------------

   (BURST)

  (acet-error-restore)

);end defun

(Princ)



;;




;;

;explode multiple.. .por Tom Beauford

;Explodes selected
;(defun C:ex ( / ssAll drwordr)
; (setq ss2 (ssget)
;	   drwordr (getvar "draworderctl")
; )
; (setvar "draworderctl" 0);supress warnings
; (sssetfirst nil ss2) ;makes ss2 both gripped and selected. 
; (command "explode")
; (setvar "draworderctl" drwordr)
;);end defun
;
;;



;Made by ;kpblc  in Cadtutor.com
;http://www.cadtutor.net/forum/showthread.php?t=19161
;fixb will change selected blocks in current drawing 
;to layer 0, color, linetype & lineweight bylayer

(defun c:fixb (/ *error* adoc lst_layer func_restore-layers)
(princ " Select blocks to redefine to color, linetype and lineweight Bylayer:") 
  (defun *error* (msg)
    (func_restore-layers)
    (vla-endundomark adoc)
    (princ msg)
    (princ)
    ) ;_ end of defun

  (defun func_restore-layers ()
    (foreach item lst_layer
      (vla-put-lock (car item) (cdr (assoc "lock" (cdr item))))
      (vl-catch-all-apply
        '(lambda ()
           (vla-put-freeze
             (car item)
             (cdr (assoc "freeze" (cdr item)))
             ) ;_ end of vla-put-freeze
           ) ;_ end of lambda
        ) ;_ end of vl-catch-all-apply
      ) ;_ end of foreach
    ) ;_ end of defun

  (vl-load-com)
  (vla-startundomark
    (setq adoc (vla-get-activedocument (vlax-get-acad-object)))
    ) ;_ end of vla-startundomark
  (if (and (not (vl-catch-all-error-p
                  (setq selset
                         (vl-catch-all-apply
                           (function
                             (lambda ()
                               (ssget '((0 . "INSERT")))
                               ) ;_ end of lambda
                             ) ;_ end of function
                           ) ;_ end of vl-catch-all-apply
                        ) ;_ end of setq
                  ) ;_ end of vl-catch-all-error-p
                ) ;_ end of not
           selset
           ) ;_ end of and
    (progn
      (vlax-for item (vla-get-layers adoc)
        (setq
          lst_layer (cons (list item
                                (cons "lock" (vla-get-lock item))
                                (cons "freeze" (vla-get-freeze item))
                                ) ;_ end of list
                          lst_layer
                          ) ;_ end of cons
          ) ;_ end of setq
        (vla-put-lock item :vlax-false)
        (vl-catch-all-apply
          '(lambda () (vla-put-freeze item :vlax-false))
          ) ;_ end of vl-catch-all-apply
        ) ;_ end of vlax-for
      (foreach blk_def
               (mapcar
                 (function
                   (lambda (x)
                     (vla-item (vla-get-blocks adoc) x)
                     ) ;_ end of lambda
                   ) ;_ end of function
                 ((lambda (/ res)
                    (foreach item (mapcar
                                    (function
                                      (lambda (x)
                                        (vla-get-name
                                          (vlax-ename->vla-object x)
                                          ) ;_ end of vla-get-name
                                        ) ;_ end of lambda
                                      ) ;_ end of function
                                    ((lambda (/ tab item)
                                       (repeat (setq tab  nil
                                                     item (sslength selset)
                                                     ) ;_ end setq
                                         (setq
                                           tab
                                            (cons
                                              (ssname selset
                                                      (setq item (1- item))
                                                      ) ;_ end of ssname
                                              tab
                                              ) ;_ end of cons
                                           ) ;_ end of setq
                                         ) ;_ end of repeat
                                       tab
                                       ) ;_ end of lambda
                                     )
                                    ) ;_ end of mapcar
                      (if (not (member item res))
                        (setq res (cons item res))
                        ) ;_ end of if
                      ) ;_ end of foreach
                    (reverse res)
                    ) ;_ end of lambda
                  )
                 ) ;_ end of mapcar
        (vlax-for ent blk_def
          (vla-put-color ent 256)
          (vla-put-lineweight ent aclnwtbylayer)
          (vla-put-linetype ent "bylayer")
          ) ;_ end of vlax-for
        ) ;_ end of foreach
      (func_restore-layers)
      (vla-regen adoc acallviewports)
      ) ;_ end of progn
    ) ;_ end of if
  (vla-endundomark adoc)
  (princ)
  ) ;_ end of defun
---------

***************



;;

;It will fix selected text and mtext to M3 standard style format
;It will not fix adjusted mtext, run SMT and SBMT to strip mtext and nested mtext
(defun c:FIXS (/) (c:FIXSTYLE))
(defun c:fixstyle (/ OLD CO ST NEWHT TEMP OLDHT NEWWID)
(command "_.-STYLE" "standard" "simplex.shx" "0" "0.8" "0" "N" "N" "N")
(setq OLD (ssget '((-4 . "<OR") (0 . "TEXT") (0 . "MTEXT") (-4 . "OR>"))))
(if OLD
(progn
(setq ST (getvar "textstyle"))
(if (tblsearch "style" ST)
(progn (setq NEWHT (assoc 40 (tblsearch "style" ST)))
(if (not (> (cdr NEWHT) 0))
(progn (prompt "\n The style you have chosen has a preset height of 0.")
(prompt "\n The existing height of the text will be maintained.")
)
)
(setq CO 0)
(while (< CO (sslength OLD))
(progn (setq TEMP (entget (ssname OLD CO))
CO (1+ CO)
)
(if (or (= "TEXT" (cdr (assoc 0 TEMP))) (= "MTEXT" (cdr (assoc 0 TEMP))))
(progn (setq OLDHT (assoc 40 TEMP))
(setq NEWWID (assoc 41 (tblsearch "style" ST))
NEWHT (assoc 40 (tblsearch "style" ST))
)
(if (= (cdr NEWHT) 0.0)
(setq NEWHT OLDHT)
)
(setq TEMP (subst (cons 7 ST) (assoc 7 TEMP) TEMP))
(setq TEMP (subst NEWWID (assoc 41 TEMP) TEMP))
(setq TEMP (subst NEWHT (assoc 40 TEMP) TEMP))
(entmod TEMP)
)
)
)
)
)
(prompt "\n Next time select a text style that exists.")
)
)
(prompt "\n This routine works better if you select something.")
)
)
(princ)


;;


 ;Copyright 2000 EMT Software, Inc.
 ;
(defun C:FLAT (/ #ENT #ELS #KWD
                 @ENT-TYPE-1 @ENT-TYPE-2 @ENT-TYPE-3 @ENT-TYPE-4)

  ; for entities: "ARC", "ARCALIGNEDTEXT", "ATTRIB", "CIRCLE", "ELLIPSE",
  ;               "HATCH", "INSERT", "POINT", "POLYLINE", "VERTEX", "XLINE".
  (defun @ENT-TYPE-1 (%A / #OLD #NEW)
    (setq #OLD (cdr (assoc 10 %A))
          #NEW (list (car #OLD) (cadr #OLD) 0.0)
          %A (subst (cons 10 #NEW) (cons 10 #OLD) %A))
    (entmod %A)
    (entupd (cdr (assoc -1 %A))))

  ; for "LWPOLYLINE".
  (defun @ENT-TYPE-2 (%A / #OLD #NEW)
    (setq %A (subst (cons 38 0.0) (assoc 38 %A) %A))
    (entmod %A))

  ; for entities: "ATTDEF", "LINE", "MTEXT", "RAY", "RTEXT", "TEXT", "TOLERANCE".
  (defun @ENT-TYPE-3 (%A / #OLD #NEW)
    (setq #OLD (cdr (assoc 10 %A))
          #NEW (list (car #OLD) (cadr #OLD) 0.0)
          %A (subst (cons 10 #NEW) (cons 10 #OLD) %A))
    (if (setq #OLD (cdr (assoc 11 %A)))
      (setq #NEW (list (car #OLD) (cadr #OLD) 0.0)
            %A (subst (cons 11 #NEW) (cons 11 #OLD) %A)))
    (entmod %A))

  ; for "SOLID" and "TRACE".
  (defun @ENT-TYPE-4 (%A / #OLD #NEW)
    (setq #OLD (cdr (assoc 10 %A))
          #NEW (list (car #OLD) (cadr #OLD) 0.0)
          %A (subst (cons 10 #NEW) (cons 10 #OLD) %A)
          #OLD (cdr (assoc 11 %A))
          #NEW (list (car #OLD) (cadr #OLD) 0.0)
          %A (subst (cons 11 #NEW) (cons 11 #OLD) %A)
          #OLD (cdr (assoc 12 %A))
          #NEW (list (car #OLD) (cadr #OLD) 0.0)
          %A (subst (cons 12 #NEW) (cons 12 #OLD) %A)
          #OLD (cdr (assoc 13 %A))
          #NEW (list (car #OLD) (cadr #OLD) 0.0)
          %A (subst (cons 13 #NEW) (cons 13 #OLD) %A))
    (entmod %A))

  (initget "Simple Complex Text All")
  (setq #KWD (getkword "\nEnter the type of entity to change [Simple/Complex/Text/All]: <All> "))
  (if (not #KWD)
    (setq #KWD "All"))
  (setq #ENT (entnext))
  (while #ENT
    (setq #ELS (entget #ENT))
    ; determine the type of entity and change the Z or elevation to 0.0.
    (cond
      ((= #KWD "Simple")
       (cond
         ((member (cdr (assoc 0 #ELS)) (list "ARC" "CIRCLE" "ELLIPSE" "POINT" "XLINE"))
          (@ENT-TYPE-1 #ELS))
         ((member (cdr (assoc 0 #ELS)) (list "LINE" "RAY" ))
          (@ENT-TYPE-3 #ELS))
         ((member (cdr (assoc 0 #ELS)) (list "SOLID" "TRACE"))
          (@ENT-TYPE-4 #ELS))))
      ((= #KWD "Complex")
       (cond
         ((member (cdr (assoc 0 #ELS)) (list "ATTRIB" "HATCH" "INSERT" "POLYLINE" "VERTEX"))
          (@ENT-TYPE-1 #ELS))
         ((member (cdr (assoc 0 #ELS)) (list "LWPOLYLINE"))
          (@ENT-TYPE-2 #ELS))))
      ((= #KWD "Text")
       (cond
         ((member (cdr (assoc 0 #ELS)) (list "ARCALIGNEDTEXT"))
          (@ENT-TYPE-1 #ELS))
         ((member (cdr (assoc 0 #ELS)) (list "ATTDEF" "MTEXT" "RTEXT" "TEXT" "TOLERANCE"))
          (@ENT-TYPE-3 #ELS))))
      ((= #KWD "All")
       (cond
         ((member (cdr (assoc 0 #ELS)) (list "ARC" "CIRCLE" "ELLIPSE" "POINT" "XLINE"
                                             "ATTRIB" "HATCH" "INSERT" "POLYLINE" "VERTEX"
                                             "ARCALIGNEDTEXT"))
          (@ENT-TYPE-1 #ELS))
         ((member (cdr (assoc 0 #ELS)) (list "LWPOLYLINE"))
          (@ENT-TYPE-2 #ELS))
         ((member (cdr (assoc 0 #ELS)) (list "LINE" "RAY"
                                             "ATTDEF" "MTEXT" "RTEXT" "TEXT" "TOLERANCE"))
          (@ENT-TYPE-3 #ELS))
         ((member (cdr (assoc 0 #ELS)) (list "SOLID" "TRACE"))
          (@ENT-TYPE-4 #ELS)))))

    (setq #ENT (entnext #ENT)))

  (princ))


;;; Uncomment for the language needed.

(princ)

;;


;;; FLATTEN.LSP version 2k.01, 25-Jun-1999
;;;
;;; FLATTEN sets the Z-coordinates of these types of objects to 0
;;; in the World Coordinate System:
;;;  "3DFACE" "ARC" "ATTDEF" "CIRCLE" "DIMENSION" 
;;;  "ELLIPSE" "HATCH" "INSERT" "LINE" "LWPOLYLINE"
;;;  "MTEXT" "POINT" "POLYLINE" "SOLID" "TEXT"
;;;
;;;-----------------------------------------------------------------------
;;; copyright 1990-1999 by Mark Middlebrook
;;;   Daedalus Consulting
;;;   e-mail: markmiddlebrook@compuserve.com
;;;
;;; Thanks to Vladimir Livshiz for improvements in polyline handling
;;; and the addition of several other object types.
;;;
;;; You are free to distribute FLATTEN.LSP to others so long as you do not
;;; charge for it.
;;;
;;;-----------------------------------------------------------------------
;;; Revision history
;;;  v. 2k.0   25-May-1999  First release for AutoCAD 2000.
;;;  v. 2k.01  25-Jun-1999  Fixed two globalization bugs ("_World" & "_X")
;;;                         and revised error handler.
;;;-----------------------------------------------------------------------
;;;*Why Use FLATTEN?
;;;
;;; FLATTENing is useful in at least two situations:
;;;  1) You receive a DXF file created by another CAD program and discover
;;;     that all the Z coordinates contain small round-off errors. These
;;;     round-off errors can prevent you from object snapping to
;;;     intersections and make your life difficult in other ways as well.
;;;  2) In a supposedly 2D drawing, you accidentally create one object with
;;;     a Z elevation and end up with a drawing containing objects partly
;;;     in and partly outside the Z=0 X-Y plane. As with the round-off
;;;     problem, this situation can make object snaps and other procedures
;;;     difficult.
;;;
;;; Warning: FLATTEN is not for flattening the custom objects created by
;;; applications such as Autodesk's Architectural Desktop. ADT and similar
;;; programs create "application-defined objects" that only the
;;; application really knows what to do with. FLATTEN has no idea how
;;; to handle application-defined objects, so it leaves them alone.
;;;
;;;-----------------------------------------------------------------------
;;;*How to Use FLATTEN
;;;
;;; This version of FLATTEN works with AutoCAD R12 through 2000.
;;;
;;; To run FLATTEN, load it using AutoCAD's APPLOAD command, or type:
;;;   (load "FLATTEN")
;;; at the AutoCAD command prompt. Once you've loaded FLATTEN.LSP, type:
;;;   FLATTEN
;;; to run it. FLATTEN will tell you what it's about to do and ask you
;;; to confirm that you really want to flatten objects in the current
;;; drawing. If you choose to proceed, FLATTEN prompts you to select objects
;;; to be flattened (press ENTER to flatten all objects in the drawing).
;;; After you've selected objects and pressed ENTER, FLATTEN goes to work.
;;; It reports the number of objects it flattens and the number left
;;; unflattenened (because they were objects not recognized by FLATTEN; see 
;;; the list of supported objects above).
;;;
;;; If you don't like the results, just type U to undo FLATTEN's work.
;;;
;;;-----------------------------------------------------------------------
;;;*Known limitations
;;;  1) FLATTEN doesn't support all of AutoCAD's object types. See above
;;;     for a list of the object types that it does work on.
;;;  2) FLATTEN doesn't flatten objects nested inside of blocks.
;;;     (You can explode blocks before flattening. Alternatively, you can
;;;     WBLOCK block definitions to separate DWG files, run FLATTEN in
;;;     each of them, and then use INSERT in the parent drawing to update
;;;     the block definitions. Neither of these methods will flatten
;;;     existing attributes, though.
;;;  3) FLATTEN flattens objects onto the Z=0 X-Y plane in AutoCAD's
;;;     World Coordinate System (WCS). It doesn't currently support
;;;     flattening onto other UCS planes.
;;;
;;;=======================================================================

(defun C:FLAT2 (/       tmpucs  olderr  oldcmd  zeroz   ss1     ss1len
                  i       numchg  numnot  numno0  ssno0   ename   elist
                  etype   yorn    vrt     crz
                 )
  (setq tmpucs "$FLATTEN-TEMP$")        ;temporary UCS

  ;;Error handler
  (setq olderr *error*)
  (defun *error* (msg)
    (if (or
          (= msg "Function cancelled")
          (= msg "quit / exit abort")
        )
      ;;if user cancelled or program aborted, exit quietly
      (princ)
      ;;otherwise report error message
      (princ (strcat "\nError: " msg))
    )
    (setq *error* olderr)
    (if (tblsearch "UCS" tmpucs)
      (command "._UCS" "_Restore" tmpucs "._UCS" "_Delete" tmpucs)
    )
    (command "._UNDO" "_End")
    (setvar "CMDECHO" oldcmd)
    (princ)
  )

  ;;Function to change Z coordinate to 0

  (defun zeroz (key zelist / oplist nplist)
    (setq oplist (assoc key zelist)
          nplist (reverse (append '(0.0) (cdr (reverse oplist))))
          zelist (subst nplist oplist zelist)
    )
    (entmod zelist)
  )
  ;;Setup
  (setq oldcmd (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)
  (command "._UNDO" "_Group")
  (command "._UCS" "_Delete" tmpucs "._UCS" "_Save" tmpucs "._UCS" "_World")
                                        ;set World UCS

  ;;Get input
  (prompt
    (strcat
      "\nFLATTEN fija la coordenada Z de los objetos en Z=0."
    )
  )

  (initget "Yes No")
  (setq yorn (getkword "\nQuieres continuar? <Y>: "))
  (cond ((/= yorn "No")
         (graphscr)
         (prompt "\nEscoge los objetos que quieras bajar a Z=0 ")
         (prompt
           "[Pulsa return para seleccionar todos los objetos del dibujo]"
         )
         (setq ss1 (ssget))
         (if (null ss1)                 ;if enter...
           (setq ss1 (ssget "_X"))      ;select all entities in database
         )


         ;;*initialize variables
         (setq ss1len (sslength ss1)    ;length of selection set
               i      0                 ;loop counter
               numchg 0                 ;number changed counter
               numnot 0                 ;number not changed counter
               numno0 0                 ;number not changed and Z /= 0 counter
               ssno0  (ssadd)           ;selection set of unchanged entities
         )                              ;setq

         ;;*do the work
         (prompt "\ntrabajando.")
         (while (< i ss1len)            ;while more members in the SS
           (if (= 0 (rem i 10))
             (prompt ".")
           )
           (setq ename (ssname ss1 i)   ;entity name
                 elist (entget ename)   ;entity data list
                 etype (cdr (assoc 0 elist)) ;entity type
           )

           ;;*Keep track of entities not flattened
           (if (not (member etype
                            '("3DFACE"     "ARC"        "ATTDEF"
                              "CIRCLE"     "DIMENSION"  "ELLIPSE"
                              "HATCH"      "INSERT"     "LINE"
                              "LWPOLYLINE" "MTEXT"      "POINT"
                              "POLYLINE"   "SOLID"      "TEXT"
                             )
                    )
               )
             (progn                     ;leave others alone
               (setq numnot (1+ numnot))
               (if (/= 0.0 (car (reverse (assoc 10 elist))))
                 (progn                 ;add it to special list if Z /= 0
                   (setq numno0 (1+ numno0))
                   (ssadd ename ssno0)
                 )
               )
             )
           )

           ;;Change group 10 Z coordinate to 0 for listed entity types.
           (if (member etype
                       '("3DFACE"    "ARC"       "ATTDEF"    "CIRCLE"
                         "DIMENSION" "ELLIPSE"   "HATCH"     "INSERT"
                         "LINE"      "MTEXT"     "POINT"     "POLYLINE"
                         "SOLID"     "TEXT"
                        )
               )
             (setq elist  (zeroz 10 elist) ;change entities in list above
                   numchg (1+ numchg)
             )
           )

           ;;Change group 11 Z coordinate to 0 for listed entity types.
           (if (member etype
                       '("3DFACE" "ATTDEF" "DIMENSION" "LINE" "TEXT" "SOLID")
               )
             (setq elist (zeroz 11 elist))
           )

           ;;Change groups 12 and 13 Z coordinate to 0 for SOLIDs and 3DFACEs.
           (if (member etype '("3DFACE" "SOLID"))
             (progn
               (setq elist (zeroz 12 elist))
               (setq elist (zeroz 13 elist))
             )
           )

           ;;Change groups 13, 14, 15, and 16
           ;;Z coordinate to 0 for DIMENSIONs.
           (if (member etype '("DIMENSION"))
             (progn
               (setq elist (zeroz 13 elist))
               (setq elist (zeroz 14 elist))
               (setq elist (zeroz 15 elist))
               (setq elist (zeroz 16 elist))
             )
           )

           ;;Change each polyline vertex Z coordinate to 0.
           ;;Code provided by Vladimir Livshiz, 09-Oct-1998
           (if (= etype "POLYLINE")
             (progn
               (setq vrt ename)
               (while (not (equal (cdr (assoc 0 (entget vrt))) "SEQEND"))
                 (setq elist (entget (entnext vrt)))
                 (setq crz (cadddr (assoc 10 elist)))
                 (if (/= crz 0)
                   (progn
                     (zeroz 10 elist)
                     (entupd ename)
                   )
                 )
                 (setq vrt (cdr (assoc -1 elist)))
               )
             )
           )

           ;;Special handling for LWPOLYLINEs
           (if (member etype '("LWPOLYLINE"))
             (progn
               (setq elist  (subst (cons 38 0.0) (assoc 38 elist) elist)
                     numchg (1+ numchg)
               )
               (entmod elist)
             )
           )

           (setq i (1+ i))              ;next entity
         )
         (prompt " Done.")

         ;;Print results
         (prompt (strcat "\n" (itoa numchg) " objecto(s) bajados a Z=0."))
         (prompt
           (strcat "\n" (itoa numnot) " object(s) no modificados.")
         )

         ;;If there any entities in ssno0, show them
         (if (/= 0 numno0)
           (progn
             (prompt (strcat "  ["
                             (itoa numno0)
                             " with non-zero base points]"
                     )
             )
             (getstring
               "\nPulsa enter para ver los objetos de Z no nula que o han sido cambiados... "
             )
             (command "._SELECT" ssno0)
             (getstring "\nPulsa enter para desseleccionarlos... ")
             (command "")
           )
         )
        )
  )

  (command "._UCS" "_Restore" tmpucs "._UCS" "_Delete" tmpucs)
  (command "._UNDO" "_End")
  (setvar "CMDECHO" oldcmd)
  (setq *error* olderr)
  (princ)
)
(princ)

;;;


;;

; FLATT.LSP - sets Z-coordinates of LINEs, POLYLINEs, CIRCLEs, ARCs,
;  TEXT, Block INSERTs, and POINTs to 0
;
; by Mark Middlebrook, Daedalus Consulting  (415) 547-0602
; version 1.0  12-17-90

(defun C:Flatt (/ SS1 SS1Len i NumChg NumNot NumNo0 SSNo0 EName Elist EType)

;*get input
   (textscr)
   (prompt "\nFLATTEN sets the Z coordinates of LINEs, POLYLINEs, CIRCLEs, ")
   (prompt "\nARCs, TEXT, Block INSERTs, and POINTs to zero.")
   (prompt "\nFLATLAND must be set to zero for FLATTEN to run.")
   (getstring "\n\nHit enter to continue...")

;*exit if FLATLAND /= 0 [for some reason using (setvar) to change FLATLAND
; within the routine causes some entities to be ignored.
   (if (/= 0 (getvar "FLATLAND"))
      (prompt "\n\nFLATLAND not set to 0 - exiting command.")
      (progn         ;FLATLAND is 0 - proceed
         (graphscr)  
         (prompt "\nChoose entities to FLATTEN, or return for all... ")
         (setq SS1 (ssget))
         (if (null SS1)             ;if enter, ZOOM All and choose everything
            (progn
               (command ".ZOOM" "A")
               (setq SS1 (ssget "C" (getvar "EXTMIN") (getvar "EXTMAX")))
            );progn
         );if

;*initialize variables
         (setq SS1Len (sslength SS1)   ;length of selection set
               i 0                     ;loop counter
               NumChg 0                ;number changed counter
               NumNot 0                ;number not changed counter
               NumNo0 0                ;number not changed and Z /= 0 counter
               SSNo0 (ssadd)           ;selection set of unchanged entities
         );setq

;*do the work
         (prompt "\nWorking.")
         (while (< i SS1Len)                    ;while more members in the SS
            (if (= 0 (rem i 10)) (prompt "."))
            (setq EName (ssname SS1 i)             ;entity name
                  EList (entget EName)             ;entity data list
                  EType (cdr (assoc 0 EList))      ;entity type
            );setq

;*change group 10 Z coordinate to 0 for listed entity types
            (if (member EType 
                  '("LINE" "POLYLINE" "TEXT" "INSERT" "CIRCLE" "ARC" "POINT"))
               (setq EList (zeroz 10 EList)     ;change entities in list above
                     NumChg (1+ NumChg)
               );setq
               (progn                           ;leave others alone
                  (setq NumNot (1+ NumNot))     
                  (if (/= 0.0 (car (reverse (assoc 10 EList))))
                     (progn                  ;add it to special list if Z /= 0
                        (setq NumNo0 (1+ NumNo0))
                        (ssadd EName SSNo0)
                     );progn
                  );if
               );progn
            );if

;*change group 11 Z coordinate to 0 for LINEs and TEXT
            (if (or (= EType "LINE") (= EType "TEXT"))
               (setq Elist (zeroz 11 EList))
            );if

            (setq i (1+ i))               ;next entity
         );while

;*print results
         (prompt (strcat "\n" (itoa NumChg) " entity(s) flattened"))
         (prompt (strcat "\n" (itoa NumNot) " entity(s) not flattened"))

         (if (/= 0 NumNo0)          ;if there any entities in SSNo0, show them
            (progn
               (prompt (strcat "  {" (itoa NumNo0) 
                     " with non-zero base points}"))
               (getstring "\nHit enter to see non-zero unchanged entities... ")
               (command ".SELECT" SSNo0)
               (getstring "\nHit enter to unhighlight them... ")
               (command "")
            );progn
         );if
      );progn [else]
   );if
   (princ)
);defun


;*function to change Z coordinate to 0

(defun zeroz (key ZEList / OPList NPList)
   (setq OPList (assoc key ZEList)
         NPList (reverse (append '(0.0) (cdr (reverse OPList))))
         ZEList (subst NPList OPList ZEList)
   );setq
   (entmod ZEList)
);defun


;;


;;;
;;;    GETSEL.LSP
;;;    Copyright ฉ 1999 by Autodesk, Inc.
;;;
;;;    Your use of this software is governed by the terms and conditions of the
;;;    License Agreement you accepted prior to installation of this software.
;;;    Please note that pursuant to the License Agreement for this software,
;;;    "[c]opying of this computer program or its documentation except as
;;;    permitted by this License is copyright infringement under the laws of
;;;    your country.  If you copy this computer program without permission of
;;;    Autodesk, you are violating the law."
;;;
;;;    AUTODESK PROVIDES THIS PROGRAM "AS IS" AND WITH ALL FAULTS.
;;;    AUTODESK SPECIFICALLY DISCLAIMS ANY IMPLIED WARRANTY OF
;;;    MERCHANTABILITY OR FITNESS FOR A PARTICULAR USE.  AUTODESK, INC.
;;;    DOES NOT WARRANT THAT THE OPERATION OF THE PROGRAM WILL BE
;;;    UNINTERRUPTED OR ERROR FREE.
;;;
;;;    Use, duplication, or disclosure by the U.S. Government is subject to
;;;    restrictions set forth in FAR 52.227-19 (Commercial Computer
;;;    Software - Restricted Rights) and DFAR 252.227-7013(c)(1)(ii)
;;;    (Rights in Technical Data and Computer Software), as applicable.
;;;
;;;  ----------------------------------------------------------------

(defun c:GT (/ LAY    ;; Layer of the selected entity
                   ENT    ;; Entity type of seleted entity
                   SS     ;; Selection set
                   SSLST  ;; Filter list
                   cspace ;; current space
                )

  (acet-error-init
         (list
           (list "cmdecho" 0
                 "expert"  0
           )
           T     ;flag. True means use undo for error clean up.
         )       ;list
  );acet-error-init


  ;;(setq LAY (car(entsel "\nSelect Object on layer to Select from <*>: ")))
  (setq LAY (car (entsel "\nSelect an object on the Source layer <*>: ")))

  (if LAY
    (setq LAY  (cdr(assoc 8 (entget LAY)))
          SSLST (list (cons 8 LAY ))
    )
  )

  ;;(setq ENT (car(entsel "\nSelect type of entity you want <*>: ")))
  (setq ENT (car(entsel "\nSelect an object of the Type you want <*>: ")))

  (if ENT
    (progn
      (setq ENT  (cdr(assoc 0 (entget ENT))))
      (if SSLST
         (setq SSLST (append (list (cons 0 ENT )) SSLST))
         (setq SSLST (list (cons 0 ENT )))
      )
    )
  )
  (if SSLST
    (progn
      (cond
        ((and LAY ENT)
          (prompt (acet-str-format "\nCollecting all %1 objects on layer %2..." ENT LAY))
        )
        (LAY
          (prompt (acet-str-format "\nCollecting ALL objects on layer %1..."  LAY ))
        )
        (ENT
          (prompt (acet-str-format "\nCollecting all %1 objects in the drawing..."  ENT ))
        )
        (T
          (prompt "\nCollecting all objects in the drawing...")
        )
      )
      (setq SS (ssget "_X" SSLST))
    )
    (progn
      (setq SS (ssget "_X"))
    ) ;progn
  )
  (if SS
    (progn
      (setq SS (sslength SS))
      (if (> SS 0)
        (if (= SS 1)
          (prompt
            (acet-str-format "\n%1 object has been placed in the active selection set." (itoa SS))
          )
          (prompt
            (acet-str-format "\n%1 objects have been placed in the active selection set." (itoa SS))
          )
        ) ;if
        (prompt"\nNothing selected.")
      )
    ) ;progn
  ) ;if

  (acet-error-restore)

  (princ)

);end defun

(princ)



;;

;;; HPOL.LSP ver 1.8
;;; Recreates hatch boundary by selecting a hatch
;;; Boundary is created in current layer/color/linetype in WCS
;;; By Jimmy Bergmark
;;; Copyright (C) 1997-2003 JTB World, All Rights Reserved
;;; Website: www.jtbworld.com / http://jtbworld.vze.com
;;; E-mail: info@jtbworld.com / jtbworld@hotmail.com
;;; 2000-02-12 - First release
;;; 2000-03-27 - Counterclockwise arc's and ellipse's fixed
;;;              Objects created joined to lwpolyline if possible
;;;              Error-handling, undo of command
;;;              Can handle PLINETYPE = 0,1,2
;;; 2000-03-30 - Integrating hatchb and hatchb14
;;;              Selection of many hatches
;;;              Splines supported if closed.
;;; 2001-04-02 - Fixed bug with entmake of line with no Z for r14
;;; 2001-07-31 - Removed an irritating semicolon to enable polylines to be created.
;;; 2001-10-04 - Changed mail and homepage so it's easy to find when new versions comes up.
;;; 2003-02-06 - Minor fix
;;; 2003-02-17 - Area returned if no islands is found since it's not consistant
;;; Tested on AutoCAD r14, 2000, 2000i, 2002
;;; should be working on older versions too.


(defun c:hpol (/     es    blay  ed1   ed2   loops1      bptf  part
             et    noe   plist ic    bul   nr    ang1  ang2  obj *ModelSpace* *PaperSpace*
             space cw errexit undox olderr oldcmdecho ss1 lastent en1 en2 ss lwp
             list->variantArray 3dPoint->2dPoint A2k ent i ss2
             knot-list controlpoint-list kn cn pos xv bot area hst
            )
 (setq A2k (>= (substr (getvar "ACADVER") 1 2) "15"))
 (if A2k
   (progn
     (defun list->variantArray (ptsList / arraySpace sArray)
       (setq arraySpace
	      (vlax-make-safearray
		vlax-vbdouble
		(cons 0 (- (length ptsList) 1))
	      )
       )
       (setq sArray (vlax-safearray-fill arraySpace ptsList))
       (vlax-make-variant sArray)
     )
     (defun areaOfObject (en / curve area)
       (if en
	 (if A2k
	   (progn
	     (setq curve (vlax-ename->vla-object en))
	     (if
	       (vl-catch-all-error-p
		 (setq
		   area
		    (vl-catch-all-apply 'vlax-curve-getArea (list curve))
		 )
	       )
		nil
		area
	     )
	   )
	   (progn
	     (command "._area" "_O" en)
	     (getvar "area")
	   )
	 )
       )
     )
   )
 )
 (if A2k
  (defun 3dPoint->2dPoint (3dpt)
    (list (float (car 3dpt)) (float (cadr 3dpt)))
  )
 )

  (defun errexit (s)
    (princ "\nError:  ")
    (princ s)
    (restore)
  )

  (defun undox ()
    (command "._ucs" "_p")
    (command "._undo" "_E")
    (setvar "cmdecho" oldcmdecho)
    (setq *error* olderr)
    (princ)
  )

  (setq olderr  *error*
        restore undox
        *error* errexit
  )
  (setq oldcmdecho (getvar "cmdecho"))
  (setvar "cmdecho" 0)
  (command "._UNDO" "_BE")
  (if A2k (progn
    (vl-load-com)
    (setq *ModelSpace* (vla-get-ModelSpace
                         (vla-get-ActiveDocument (vlax-get-acad-object))
                       )
          *PaperSpace* (vla-get-PaperSpace
                         (vla-get-ActiveDocument (vlax-get-acad-object))
                       )
    ))
  )


; For testing purpose
; (setq A2k nil)
  
  (if (/= (setq ss2 (ssget '((0 . "HATCH")))) nil)
   (progn
    (setq i 0)
    (setq area 0)
    (setq bMoreLoops nil)
    (while (setq ent (ssname ss2 i))
      (setq ed1 (entget ent))
      (if (not (equal (assoc 210 ed1) '(210 0.0 0.0 1.0))) (princ "\nHatch not in WCS!"))
      (setq xv (cdr (assoc 210 ed1)))
      (command "._ucs" "_w")
      (setq loops1 (cdr (assoc 91 ed1))) ; number of boundary paths (loops)
      (if (and A2k (= (strcase (cdr (assoc 410 ed1))) "MODEL"))
        (setq space *ModelSpace*)
        (setq space *PaperSpace*)
      )
      (repeat loops1
        (setq ed1 (member (assoc 92 ed1) ed1))
        (setq bptf (cdr (car ed1))) ; boundary path type flag
        (setq ic (cdr (assoc 73 ed1))) ; is closed
        (setq noe (cdr (assoc 93 ed1))) ; number of edges
	(setq bot (cdr (assoc 92 ed1))) ; boundary type
	(setq hst (cdr (assoc 75 ed1))) ; hatch style
        (setq ed1 (member (assoc 72 ed1) ed1))
        (setq bul (cdr (car ed1))) ; bulge
        (setq plist nil)
        (setq blist nil)
        (cond
          ((> (boole 1 bptf 2) 0) ; polyline
           (repeat noe
             (setq ed1 (member (assoc 10 (cdr ed1)) ed1))
             (setq plist (append plist (list (cdr (assoc 10 ed1)))))
             (setq blist (append blist
                                 (if (> bul 0)
                                   (list (cdr (assoc 42 ed1)))
                                   nil
                                 )
                         )
             )
           )
           (if A2k (progn
             (setq polypoints
                    (apply 'append
                           (mapcar '3dPoint->2dPoint plist)
                    )
             )
             (setq VLADataPts (list->variantArray polypoints))
             (setq obj (vla-addLightweightPolyline space VLADataPts))
             (setq nr 0)
             (repeat (length blist)
               (if (/= (nth nr blist) 0)
                 (vla-setBulge obj nr (nth nr blist))
               )
               (setq nr (1+ nr))
             )
             (if (= ic 1)
               (vla-put-closed obj T)
             )
            )
            (progn
              (if (= ic 1)
                (entmake '((0 . "POLYLINE") (66 . 1) (70 . 1)))
                (entmake '((0 . "POLYLINE") (66 . 1)))
              )
              (setq nr 0)
              (repeat (length plist)
                (if (= bul 0)
                  (entmake (list (cons 0 "VERTEX")
                                 (cons 10 (nth nr plist))
                           )
                  )
                  (entmake (list (cons 0 "VERTEX")
                                 (cons 10 (nth nr plist))
                                 (cons 42 (nth nr blist))
                           )
                  )
                )
                (setq nr (1+ nr))
              )
              (entmake '((0 . "SEQEND")))
            )
           )
          )
          (t ; not polyline
           (setq lastent (entlast))
           (setq lwp T)
           (repeat noe
             (setq et (cdr (assoc 72 ed1)))
             (cond
               ((= et 1) ; line
                (setq ed1 (member (assoc 10 (cdr ed1)) ed1))
                (if A2k
                  (vla-AddLine
                    space
                    (vlax-3d-point (cdr (assoc 10 ed1)))
                    (vlax-3d-point (cdr (assoc 11 ed1)))
                  )
                  (entmake
                    (list
                      (cons 0 "LINE")
                      (list 10 (cadr (assoc 10 ed1)) (caddr (assoc 10 ed1)) 0)
                      (list 11 (cadr (assoc 11 ed1)) (caddr (assoc 11 ed1)) 0)
		    ;  (cons 210 xv)
                    )
                  )
                )
                (setq ed1 (cddr ed1))
               )
               ((= et 2) ; circular arc
                 (setq ed1 (member (assoc 10 (cdr ed1)) ed1))
                 (setq ang1 (cdr (assoc 50 ed1)))
                 (setq ang2 (cdr (assoc 51 ed1)))
                 (setq cw (cdr (assoc 73 ed1)))
                 (if (equal ang2 6.28319 0.00001)
                   (progn
                     (if A2k
                       (vla-AddCircle
                         space
                         (vlax-3d-point (cdr (assoc 10 ed1)))
                         (cdr (assoc 40 ed1))
                       )
                       (entmake (list (cons 0 "CIRCLE")
                                      (assoc 10 ed1)
                                      (assoc 40 ed1)
                                )
                       )
                     )
                     (setq lwp nil)
                   )
                   (if A2k
                     (vla-AddArc
                       space
                       (vlax-3d-point (cdr (assoc 10 ed1)))
                       (cdr (assoc 40 ed1))
                       (if (= cw 0)
                         (- 0 ang2)
                         ang1
                       )
                       (if (= cw 0)
                         (- 0 ang1)
                         ang2
                       )
                     )
                     (entmake (list (cons 0 "ARC")
                                    (assoc 10 ed1)
                                    (assoc 40 ed1)
                                    (cons 50
                                          (if (= cw 0)
                                            (- 0 ang2)
                                            ang1
                                          )
                                    )
                                    (cons 51
                                          (if (= cw 0)
                                            (- 0 ang1)
                                            ang2
                                          )
                                    )
                              )
                     )
                   )
                 )
                 (setq ed1 (cddddr ed1))
               )
               ((= et 3) ; elliptic arc
                (setq ed1 (member (assoc 10 (cdr ed1)) ed1))
                (setq ang1 (cdr (assoc 50 ed1)))
                (setq ang2 (cdr (assoc 51 ed1)))
                (setq cw (cdr (assoc 73 ed1)))
                (if A2k (progn
                  (setq obj (vla-AddEllipse
                              space
                              (vlax-3d-point (cdr (assoc 10 ed1)))
                              (vlax-3d-point (cdr (assoc 11 ed1)))
                              (cdr (assoc 40 ed1))
                            )
                  )
                  (vla-put-startangle obj (if (= cw 0) (- 0 ang2) ang1))
                  (vla-put-endangle obj (if (= cw 0) (- 0 ang1) ang2))
                 )
                 (princ "\nElliptic arc not supported!")
                )
                (setq lwp nil)
               )
               ((= et 4) ; spline
                (setq ed1 (member (assoc 94 (cdr ed1)) ed1))
                (setq knot-list nil)
                (setq controlpoint-list nil)
		(setq kn (cdr (assoc 95 ed1)))
                (setq cn (cdr (assoc 96 ed1)))
                (setq pos (vl-position (assoc 40 ed1) ed1))
                (repeat kn
                  (setq knot-list (cons (cons 40 (cdr (nth pos ed1))) knot-list))
                  (setq pos (1+ pos))
                )
                (setq pos (vl-position (assoc 10 ed1) ed1))
                (repeat cn
                  (setq controlpoint-list (cons (cons 10 (cdr (nth pos ed1))) controlpoint-list))
                  (setq pos (1+ pos))
                )
                (setq knot-list (reverse knot-list))
                (setq controlpoint-list (reverse controlpoint-list))
                (entmake (append
		               (list '(0 . "SPLINE"))
                               (list (cons 100 "AcDbEntity"))
                               (list (cons 100 "AcDbSpline"))
                               (list (cons 70 (+ 1 8 (* 2 (cdr (assoc 74 ed1))) (* 4 (cdr (assoc 73 ed1))))))
                               (list (cons 71 (cdr (assoc 94 ed1))))
                               (list (cons 72 kn))
                               (list (cons 73 cn))
                               knot-list
                               controlpoint-list
                      )
                )
		(setq ed1 (member (assoc 10 ed1) ed1))
                (setq lwp nil)
               )
             ) ; end cond
           ) ; end repeat noe
           (if lwp (progn
             (setq en1 (entnext lastent))
             (setq ss (ssadd))
             (ssadd en1 ss)
             (while (setq en2 (entnext en1))
               (ssadd en2 ss)
               (setq en1 en2)
             )
             (command "_.pedit" (entlast) "_Y" "_J" ss "" "")
          ))

          ) ; end t
        ) ; end cond
;	Tries to get the area on islands but it's not clear how to know if an island is filled or not
;	and if it should be substracted or added to the total area.
;	(if (or (= bot 0) (= (boole 1 bot 1) 1)) (setq area (+ area (areaOfObject (entlast)))))
;	(if (and (/= hst 1) (/= bot 0) (= (boole 1 bot 1) 0)) (setq area (- area (areaOfObject (entlast)))))
;	(princ "\n") (princ bot) (princ "\n") (princ hst) (princ "\n")
;	(princ (areaOfObject (entlast)))
      ) ; end repeat loops1
      (if (= loops1 1) (setq area (+ area (areaOfObject (entlast)))) (setq bMoreLoops T))
      (setq i (1+ i))
    )
   )
  )
  (if (and area (not bMoreLoops)) (progn
    (princ "\nTotal Area = ")
    (princ area)
  ))
  (restore)
  (princ)
)


;;


; Increments the first postive number in a TEXT string by the given increment
;;; ==========================================================================
;;;  Program: INC.LSP  ver 1.22
;;;                                                                         
;;;  Purpose: Increments the first postive number in a TEXT string by the given increment
;;;
;;;  Syntax:  INC
;;;
;;;           Resolutions                                                   
;;;           P.O. Box 1265                                                 
;;;           Sumner WA 98390-0250                                          
;;;           206-845-2200                                                  
;;;
;;;  Date: 			5/10/95
;;;
;;;  Revisions:  ver 1.1  8/7/95    Added support for REALs
;;;
;;;  Revisions:  ver 1.2  12/12/95  Added support for Stations
;;;
;;;  Revisions:  ver 1.21 12/14/95  Fixed problem with decimal places
;;;
;;;  Revisions:  ver 1.22 1/16/96   Fixed problem with decimal places when
;;;                                 number is preceeded by alpha characters.
;;; ==========================================================================
(defun C:INC (/ ; Functions & Variables
	; Functions
			val put r_fill getdp at
	; Variables
			ss inc i l e j k ascii_nr string newstring nr count dp1 dp
			OldStation dp_pos end_pos
	)
;=============================
; Entity assoc list utilities
;-----------------------------
(defun val (nr e) (cdr (assoc nr e)))
(defun put (x nr e)(subst (cons nr x) (assoc nr e) e))
;;; ==========================================================================
;;; Function: AT
;;; Purpose : Returns the position of the first occurance of a string
;;;		   or NIL if not found
;;; Params  : string		String to search
;;;			   char			String to locate
;;;
;;; Uses	: 
;;; --------------------------------------------------------------------------
	(defun at (string char / i len clen)
		(if string
			(progn
				(setq i 1 len (strlen string) clen (strlen char))
				(while (and (<= i len) (/= (substr string i clen) char))
					(setq i (1+ i))
				)
				(if (> i len)
					(setq i nil)
				)
				(eval i)
			)
		)
	)
;;; ==========================================================================
;;; Function: R_FILL <string> <len>
;;; Purpose : Returns a string filled with spaces on the right
;;;
;;; Params  : string		String to fill
;;;           len 			String length
;;;
;;; --------------------------------------------------------------------------
(defun r_fill (s len / space i)
   (setq space "" i (- len (strlen s)))
   (if (> i 0)
	   (substr (strcat s (repeat i (setq space (strcat space " ")))) 1 len)
	   s
   )
)
;; Return number of decimal places of a REAL
(defun getdp (nr / n)
	(setq n 0 nr (abs nr))
	(while (null (equal (fix (+ nr 0.5)) nr 0.000001))
		(setq n (1+ n))
		(setq nr (* nr 10))
	)
	n
)
;;; ==========================================================================
	;-- Start C:TEXTINC
	(setvar "CMDECHO" 0)
	(princ "\nSelect TEXT containing NUMBERS to increment.")
	(if (and
			(setq ss (ssget '((0 . "*TEXT"))))
			(setq inc (getreal "\nIncrement: "))
			(/= inc 0)
		)
		(progn
			(setq i 0 l (sslength ss) count 0)
			(while (< i l)
				(setq e (entget (ssname ss i)))
				(setq string (val 1 e))
				;; --- Check for an number ---
				(if (and 
						(wcmatch string "*[0-9]*")       ; Find an INT
;						(wcmatch string "~*#.#*")        ; No REALs
						(wcmatch string "~*%%d*")        ; No BEARINGS
					)
					(progn
						(setq count (1+ count))
						(setq j 1 k (strlen string))
						(if (wcmatch string "*#+##*")  ; Check for Station
							(setq
								OldStation string
								j (at string "+")
								string (strcat
										(substr string 1 (1- j))
										(substr string (1+ j))
									)
								j 1
								k (strlen string)
							)
						)
						;; --- Step though the string looking
						;; --- for the first int ---
						(while (<= j k)
							(setq ascii_nr (ascii (substr string j 1)))
							(if (and (>= ascii_nr 48)(<= ascii_nr 57))
								(progn
									(setq end_pos j)
									(while (or (= ascii_nr 46)(and (>= ascii_nr 48)(<= ascii_nr 57)))
										(setq
											end_pos (1+ end_pos)
											ascii_nr (ascii (substr string end_pos 1))
										)
									)
									(setq
										dp_pos (at (substr string j) ".")
										nr	(atof (substr string j))
										dp1 (if dp_pos (- end_pos dp_pos j) 0)
										dp (max dp1 (getdp inc))
										nr (+ nr inc)
										newstring (strcat 
											(substr string 1 (1- j))
											(rtos nr 2 dp)
											(substr string end_pos)
										)
										j k     ;; Now exit
									)
								)
							)
							(setq j (1+ j))
						)
						;; If station then insert the "+"
						(if OldStation
							(progn
								(setq string Oldstation)
								(if (setq j (at newstring "."))
									(setq j (- j 3))
									(setq j (- (strlen newstring) 2))
								)
								(setq newstring
									(strcat (substr newstring 1 j) "+"
											(substr newstring (1+ j))
									)
								)
							)
						)
						;; --- Echo changes to screen ---
						(princ (strcat "\n" (r_fill string 12) "-->  " newstring))
						;; --- Update the TEXT entity ---
						(entmod (put newstring 1 e))
					)
					(princ (strcat "\nNo Numeric value: " string))
				)
				(setq i (1+ i))
			)
			(princ (strcat "\n" (itoa count) " TEXT number\(s\) incremented."))
		)
		(princ "\nTEXTINC cancelled.")
	)
	(princ)
)
;;(princ "\nTEXTINC.LSP v1.22. Type \"INC\" to start")
(princ)


;;


;; This routine is similar to Autocad command laymrg
;;It will merge all objects from 1st object picked Layer
;; To the 2nd object picked layer

(defun c:LME (/) (c:laymerge))
(defun c:laymerge (/ ent layer ent2 layer2 i ss ent)
  (vl-load-com)

  (cond ((and (setq ent (car (nentsel "\nSelect Object on Layer to Merge: ")))
              (setq layer (cdr (assoc 8 (entget ent))))
              (setq ent2 (car (entsel "\nSelect Object on Layer to Merge to: ")))
              (setq layer2 (cdr (assoc 8 (entget ent2))))
              (or (not (eq layer layer2)) (alert "Cannot merge layer with itself!"))
         ) ;_ and
         (setq i  -1
               ss (ssget "_X" (list (cons 8 layer)))
         ) ;_ setq
         (while (setq ent (ssname ss (setq i (1+ i))))
           (vla-put-layer (vlax-ename->vla-object ent) layer2)
         ) ;_ while
         (vlax-for blks (vla-get-Blocks
                          (vla-get-ActiveDocument
                            (vlax-get-acad-object)
                          ) ;_ vla-get-ActiveDocument
                        ) ;_ vla-get-Blocks
           (vlax-for obj blks
             (if (eq (strcase layer) (strcase (vla-get-layer obj)))
               (vla-put-layer obj layer2)
             ) ;_ if
           ) ;_ vlax-for
         ) ;_ vlax-for
        )
  ) ;_ cond
  (princ)
) ;_ defun


;;


; lines.LSP

; Paulo Gil
; Tel

; para cargar las lineas

(defun C:lines ()
  (setq rgm (getvar "regenmode"))
  (command "setvar" "regenmode" 0)
  (command "mspace" ".change" "all" "" "p" "ltscale" "1" "" "pspace")
  (command ".linetype" "load" "border" (strcat "C:/M3Cadd/2008Supp/acad.lin") "" "")
  (command ".linetype" "load" "border2" (strcat "C:/M3Cadd/2008Supp/acad.lin") "" "")
  (command ".linetype" "load" "center" (strcat "C:/M3Cadd/2008Supp/acad.lin") "" "")
  (command ".linetype" "load" "center2" (strcat "C:/M3Cadd/2008Supp/acad.lin") "" "")
  (command ".linetype" "load" "hidden" (strcat "C:/M3Cadd/2008Supp/acad.lin") "" "")
  (command ".linetype" "load" "hidden2" (strcat "C:/M3Cadd/2008Supp/acad.lin") "" "")
  (command ".linetype" "load" "dashdot" (strcat "C:/M3Cadd/2008Supp/acad.lin") "" "")
  (command ".linetype" "load" "dashdot2" (strcat "C:/M3Cadd/2008Supp/acad.lin") "" "")
  (command ".linetype" "load" "dashed" (strcat "C:/M3Cadd/2008Supp/acad.lin") "" "")
  (command ".linetype" "load" "dashed2" (strcat "C:/M3Cadd/2008Supp/acad.lin") "" "")
  (command ".linetype" "load" "phantom" (strcat "C:/M3Cadd/2008Supp/acad.lin") "" "")
  (command ".linetype" "load" "phantom2" (strcat "C:/M3Cadd/2008Supp/acad.lin") "" "")
  (command ".linetype" "load" "CapillaryTube" (strcat "C:/M3Cadd/2008Supp/acad.lin") "" "")
  (command ".linetype" "load" "Condensate" (strcat "C:/M3Cadd/2008Supp/acad.lin") "" "")
  (command ".linetype" "load" "Data" (strcat "C:/M3Cadd/2008Supp/acad.lin") "" "")
  (command ".linetype" "load" "PneumaticLine" (strcat "C:/M3Cadd/2008Supp/acad.lin") "" "")
  (command ".linetype" "load" "Vent" (strcat "C:/M3Cadd/2008Supp/acad.lin") "" "")
  (command ".linetype" "load" "DomesticColdWater" (strcat "C:/M3Cadd/2008Supp/acad.lin") "" "")
  (command ".linetype" "load" "DomesticHotWater" (strcat "C:/M3Cadd/2008Supp/acad.lin") "" "")
  (command ".linetype" "load" "HotWaterReturn" (strcat "C:/M3Cadd/2008Supp/acad.lin") "" "")
  (command ".linetype" "load" "Hot_Water_Supply" (strcat "C:/M3Cadd/2008Supp/acad.lin") "" "")
  (command ".linetype" "load" "GasLine1" (strcat "C:/M3Cadd/2008Supp/acad.lin") "" "")
  (command ".linetype" "load" "SanitarySewer" (strcat "C:/M3Cadd/2008Supp/acad.lin") "" "")
  (command ".linetype" "load" "Fenceline1" (strcat "C:/M3Cadd/2008Supp/acad.lin") "" "")
  (command ".linetype" "load" "Fenceline2" (strcat "C:/M3Cadd/2008Supp/acad.lin") "" "")
  (command ".linetype" "load" "Fenceline3" (strcat "C:/M3Cadd/2008Supp/acad.lin") "" "")
  (command ".linetype" "load" "Batting" (strcat "C:/M3Cadd/2008Supp/acad.lin") "" "")
  (command ".linetype" "load" "Tracks" (strcat "C:/M3Cadd/2008Supp/acad.lin") "" "")
  (command ".linetype" "load" "Zigzag" (strcat "C:/M3Cadd/2008Supp/acad.lin") "" "")
  (command "setvar" "regenmode" rgm)
; si funciona, como que no
  (princ)
)



;;


;Lk.LSP:  LOCK LAYERS.LSP    Encadena layers   (C)2003, Paulito Gil

(defun c:lk ()
     (setq lay (getvar "clayer")) 
     (prompt "Selecciona los layers a encadenar (lock)... ") (terpri)
        (setq ss (ssget)
              ss1(sslength ss)
              x   0
              s2 (cdr(assoc 8 (entget(ssname ss x)))) 
        )
        (command "layer" "s" lay "")
        (repeat ss1
          (setq ssn (ssname ss x)
                a   (entget ssn)
                s1  (cdr(assoc 8 a))
          )
             (command "layer" "lock" s1 "")
             (setq x (+ x 1))
        )
        (command "layer" "lock" s2 "")
        (prompt"Ya estan encadenados los layers...")(terpri)
        (princ)
)

;;


;Program by C.Gingerich, Freeware.
;If you come up with a better way of writing this e-main me
;and let me know.
;-----------------------------------> Qcel@pa.net
;
(defun c:LL (/ txtsz st midpt endpt htxts ang1 ang2 pt1 pt2 scle
                   arblk tsize)
(setq st nil
         midpt nil
         endpt nil)
(defun *error* (ms)
(setvar "orthomode" *ortho)
(setq tsize (getvar "textsize"))
(princ ms)
(princ)
)
(setvar "cmdecho" 0)
(setq tsize (getvar "textsize"))
(setq *ortho (getvar "orthomode"))
(setq scle  (getvar "dimscale"))
(setvar "orthomode" 0)
(setq st (getpoint "\nPick arrow end of leader: "))
(if (= st nil)(exit))
(setq midpt (getpoint st))
(setvar "orthomode" 1)
(if (= midpt nil)(exit))
(setq endpt (getpoint midpt))
(if (= endpt nil)(exit))
(command "leader" st midpt endpt "" "" "n")
(setvar "orthomode" *ortho)
(initget "Yes No")
(setq YorN (getkword "\nAdd note? <N> "))
(if (= YorN "Yes")
(progn
(setq htxts (/ tsize 2.0))
(setq ang2  (angle midpt endpt))
(setq pt1   (polar endpt ang2 htxts))
(setq pt2   (polar pt1 4.712389 htxts))
(if (< (car midpt)(car endpt))
(command "dtext" pt2)
(command "dtext" "r" pt2)
);end if
);end progn
);end if
)

;;

;;;

;Program by C.Gingerich, Freeware.
;If you come up with a better way of writing this e-main me
;and let me know.
;-----------------------------------> Qcel@pa.net
;
(defun c:LLL (/ txtsz st midpt endpt htxts ang1 ang2 pt1 pt2 scle
                   arblk tsize)
(setq st nil
         midpt nil
         endpt nil)
(defun *error* (ms)
(setq tsize (getvar "textsize"))
(princ ms)
(princ)
)
(setvar "cmdecho" 0)
(setq tsize (getvar "textsize"))
(setq *ortho (getvar "orthomode"))
(setq *os (getvar "osmode"))
(setvar "orthomode" 0)
(setvar "osmode" 2)
(setq st (getpoint "\nPick starting point of leader: "))
(if (= st nil)(exit))
(setvar "orthomode" 1)
(setvar "osmode" 0)
(setq midpt (getpoint st))
(if (= midpt nil)(exit))
(setvar "orthomode" 0)
(setvar "osmode" 512)
(setq endpt (getpoint midpt))
(if (= endpt nil)(exit))
(setvar "osmode" 0)
(command "leader" endpt midpt st "" "" "n")
(setvar "orthomode" *ortho)
(setvar "osmode" *os)
)


;;


;Program by C.Gingerich, Freeware.
;If you come up with a better way of writing this e-main me
;and let me know.
;-----------------------------------> Qcel@pa.net
;
(defun c:LLP (/ txtsz st midpt endpt htxts ang1 ang2 pt1 pt2 scle
                   arblk tsize)
(setq st nil
         midpt nil
         endpt nil)
(defun *error* (ms)
(setvar "orthomode" *ortho)
(setq tsize (getvar "textsize"))
(princ ms)
(princ)
)
(setvar "cmdecho" 0)
(setq tsize (getvar "textsize"))
(setq os (getvar "osmode"))
(setq *ortho (getvar "orthomode"))
(setq scle  (getvar "dimscale"))
(setvar "orthomode" 0)
(setq p1 (getpoint "\nPick arrow end of leader: "))
(if (= p1 nil)(exit))
(setq midpt (getpoint p1))
(setvar "orthomode" 1)
(if (= midpt nil)(exit))
(setq endpt (getpoint midpt))
(if (= endpt nil)(exit))
(setq px (rtos (nth 0 p1 ) 2 4))
(setq py (rtos (nth 1 p1 ) 2 4))
(setq pz (rtos (nth 2 p1 ) 2 4))
(setq txt (strcat "N " py " "))
(setq txt2 (strcat "E " px " "))
(setq txt3 (strcat "ELEV= " pz " "))
(command "point" p1)
(command "-osnap""none""leader" p1 midpt endpt "" txt txt2 txt3)
(setvar "orthomode" *ortho)
(setvar "osmode" os)
)


;;

;;;     This file contains a library of layer based routines. See individual
;;;     routines for descriptions.
;;;
;;;  External Functions:
;;;
;;;     ACET-ERROR-INIT         --> ACETUTIL.FAS   Intializes bonus error routine
;;;     ACET-ERROR-RESTORE      --> ACETUTIL.FAS   Restores old error routine
;;;     ACET-STR-FORMAT         --> ACETUTIL.ARX   Alternate to strcat
;;;

; ---------------------- LAYER OFF FUNCTION ----------------------
; Turns selected object's layer off
; ----------------------------------------------------------------

(defun C:LLO ()
; --------------------- Error initialization ---------------------

  (acet-error-init
    (list
      (list "cmdecho" 0
            "expert"  0
      )

      nil     ;flag. True means use undo for error clean up.
    );list
  );acet-error-init

  (layproc "off")

  (acet-error-restore)
  (princ)
)

; ------------- LAYER PROCESSOR FOR LAYOFF & LAYFRZ --------------
; Main program body for LAYOFF and LAYFRZ. Provides user with
; options for handling nested entities.
; ----------------------------------------------------------------

(defun LAYPROC ( TASK / NOEXIT OPT BLKLST CNT VPMODE EN PMT ANS LAY NEST BLKLST VPSS)



; -------------------- Variable initialization -------------------

  (setq NOEXIT T)

  (setq OPT (getenv (strcat "ACET_Lay" TASK)))    ; get default option setting
  (if (not (or (null OPT) (= OPT ""))) (setq OPT (atoi OPT)))

  (setq CNT 0)                                                ; cycle counter

  (if (and (= 0 (getvar "tilemode"))                          ; if in a paper space
           (/= 1 (getvar "cvport"))                           ; viewport
      )
    (setq VPMODE T)                                           ; set flag for freeze behavior
  )


; ----------------------- Selection Prompt -----------------------

  (while NOEXIT

    (setvar "errno" 7)
    (while (= (getvar "errno") 7)
      (setvar "errno" 0)
      (initget "Options Undo _Options Undo")
      (cond
        ((= TASK "off")
          (setq EN (nentsel "\nSelect an object on the layer to be turned off or [Options/Undo]: "))
        )
        ((= TASK "frz")
          (setq EN (nentsel "\nSelect an object on the layer to be frozen or [Options/Undo]: "))
        )
        ((= TASK "vpi")
          (setq EN (nentsel "\nSelect an object on the layer to be Isolated in viewport or [Options/Undo]: "))
        )
      )
      (if (= (getvar "errno") 7)
        (prompt "\nNothing selected.")
      )
    )

; ---------------------- Options  Selected -----------------------

    (cond
      ((= EN "Options")
        (initget "No Block Entity _No Block Entity")
        (cond
          ((= OPT 1)
            (setq PMT "\nEnter an option [Block level nesting/Entity level nesting/]<No nesting>: ")
          )
          ((= OPT 2)
            (setq PMT "\nEnter an option [Block level nesting/No nesting/]<Entity level nesting>: ")
          )
          (T
            (setq PMT "\nEnter an option [Entity level nesting/No nesting/]<Block level nesting>: ")
          )
        )
        (setq ANS (getkword PMT))

        (cond
          ((null ANS)
            (if (or (null OPT) (= OPT ""))
              (progn
                (setq OPT 3)
                (setenv (strcat "ACET_Lay" TASK) "3")
              )
            )
          )
          ((= ANS "No")
            (setq OPT 1)
            (setenv (strcat "ACET_Lay" TASK) "1")
          )
          ((= ANS "Entity")
            (setq OPT 2)
            (setenv (strcat "ACET_Lay" TASK) "2")
          )
          (T
            (setq OPT 3)
            (setenv (strcat "ACET_Lay" TASK) "3")
          )
        )
      )


; ---------------------- Undo selected ---------------------------

      ((= EN "Undo")
        (if (> CNT 0)
          (progn
            (command "_.u")
            (setq CNT (1- CNT))
          )
          (prompt "\nEverything has been undone.")
        )
      )

; ------------------------- Find Layer ---------------------------

    (EN

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
          (cond
            ((= TASK "off")
              (initget "Yes No _Yes No")
              (setq ANS (getkword (acet-str-format "\nReally want layer %1 (the CURRENT layer) off? [Yes/No] <No>: " LAY)))
              (setq ANS (if (null ANS) "No" ANS))
              (if (= ANS "No")
                (setq LAY nil)
              )
            )
            ((and (= TASK "frz") (not VPMODE))
              (prompt (acet-str-format "\nCannot freeze layer %1.  It is the CURRENT layer." LAY))
              (setq LAY nil)
            )
          )
          (setq ANS nil)
        )

        (if LAY
          (cond
            ((= TASK "off")
              (if ANS
                (command "_.-LAYER" "_OFF" LAY "_Yes" "")
                (command "_.-LAYER" "_OFF" LAY "")
              )
              (prompt (acet-str-format "\nLayer %1 has been turned off." LAY))
              (setq CNT (1+ CNT))
            )
            ((and (= TASK "frz") VPMODE)
              (command "_.VPLAYER" "_FREEZE" LAY "_current" "")
              (prompt (acet-str-format "\nLayer %1 has been frozen in this viewport." LAY))
              (setq CNT (1+ CNT))
            )
            ((= TASK "frz")
              (command "_.-LAYER" "_FREEZE" LAY "")
              (prompt (acet-str-format "\nLayer %1 has been frozen."  LAY ))
              (setq CNT (1+ CNT))
            )
            ((= TASK "vpi")
              (setq VPSS (ssget "_x" (list '(-4 . "<AND")
                                             '(0 . "VIEWPORT")                 ; get all viewports
                                             '(-4 . "<NOT")
                                                (cons 69 (getvar "cvport"))    ; except the current
                                             '(-4 . "NOT>")
                                             '(-4 . "<NOT")
                                                '(69 . 1)                      ; and the paperspace viewport (1)
                                             '(-4 . "NOT>")
                                           '(-4 . "AND>")
                                     )
                         )
              )
              (command "_.VPLAYER" "_FREEZE" LAY "_select" VPSS "" "")
              (prompt (acet-str-format "\nLayer %1 has been frozen in all viewports but the current one."  LAY ))
              (setq CNT (1+ CNT))
            )
          )
        )
      )

; ---------------------- Nothing  Selected -----------------------

      ((not EN)
        (setq NOEXIT nil)
      )
    )
  )
)

(princ)

;;


;;*****************************************************************************
;                     LASTN.LSP V1.0 by Zoltan Toth
;    ZOTO Technologies,
;    23 Greenhills Dve,
;    Melton, 3337.
;    E-MAIL: zoltan.toth@ains.net.au
;       WWW: http://www.ains.net.au/zoto/
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This program will select the last n objects created in a drawing where n
; is an integer input by the user. This is most useful when you create a
; number of objects with the COPY, MIRROR or ARRAY commands and you wish to
; work with the ones just created. LASTN has been written so that it can be
; used in three different ways for maximum flexibility. First, it can be
; called by itself at the "Command:" prompt and the objects so selected can
; be accessed by a later command with the "Previous" option. Second, it can
; be called transparently (with a preceding apostrophe) at a "Select
; objects:" prompt and the objects selected will be passed back to the
; waiting command. Since it can be tedious to type in the preceding
; apostrophe, it is best to incorporate this command in the menu with the
; apostrophe included to make it a quick "single pick" invokation. Thirdly,
; as the (LASTN) function is not nested within (C:LASTN), it can be called
; (with an integer argument) by other programs. As an example, to set symbol
; SS1 to a selection set containing the last 5 objects created, use:
;
; (setq SS1(lastn 5))
;
;      Any program that utilizes the (LASTN) function should, of course, check
; to see if it is already loaded and if not, load it. The following AutoLISP
; code would be satisfactory in most cases:
;
; (if(not LASTN)(load "LASTN"))
;
;      Note that although AutoCAD's "Last" option selects the last drawn
; object visible, at least partially, on screen, LASTN always selects the
; last n drawn objects, whether visible on screen or not. This includes
; objects on layers that are OFF or FROZEN. Objects on LOCKed layers are
; also selected but cannot be edited whereas objects on FROZEN or OFF layers
; can be edited. Caution: don't specify a value higher than the number of
; objects you have created in the current space (Paper or Model) since you
; last entered that space ie. changed TILEMODE - the results won't be what
; you want.
;;*****************************************************************************
(defun lastn (INT2 / SS2 SSL2)             ;define function to take 1 argument
 (setq SS2 (ssadd))                         ;set SS2 to an empty selection set
 (repeat INT2                                               ;repeat INT2 times
  (if (entlast)
   (progn
    (ssadd (entlast) SS2)          ;add last undeleted object to selection set
    (entdel (entlast))                           ;delete last undeleted object
   )
  )
 )
 (setq SSL2 (1- (sslength SS2)));set SSL2 to 1 less than size of selection set
  (while (>= SSL2 0)              ;while SSL2 is greater than or equal to zero
  (entdel (ssname SS2 SSL2))         ;undelete SSL2'th object in selection set 
  (setq SSL2 (1- SSL2))                                         ;decrement SL2
 )
 SS2                                 ;return selection set to calling function
)                                                        ;end (lastn) function
(defun C:loo (/ COUNT2)                                     ;define function
;set COUNT2 to number of objects
 (setq COUNT2 (getint "\nEnter number of objects: "))
 (if (= 0 (getvar "CMDACTIVE"))                 ;if no other command is active
  (progn                                                                 ;else
   (command "._SELECT" (lastn COUNT2) "")       ;run SELECT command and (lastn)
   (princ)                                                       ;exit quietly
  )
  (lastn COUNT2)                          ;call (lastn) function with argument
 )
)


;;


;;  LinesRegularizeAngles.lsp [command name: LRA]
;;  To Regularize all selected Lines, changing the Angle of each to the nearest
;;  multiple of the specified angular increment.  Rotates each Line around its
;;  midpoint, to stay at "average" original location and at original length.
;; 
;;  Kent Cooper, November 2009

(defun C:LRA
  (/ *error* cmde aunit osm blips anginc lines sstemp plpcs plpc
    ln lndata lnend1 lnend2 lnmid lnang lnangnew)
;
  (defun *error* (errmsg)
    (if (not (wcmatch errmsg "Function cancelled,quit / exit abort"))
      (princ (strcat "\nError: " errmsg))
    ); end if
    (command)
    (setvar 'aunits aunit)
    (setvar 'osmode osm)
    (setvar 'blipmode blips)
    (setvar 'clayer curlay)
    (command "_.undo" "_end")
    (setvar 'cmdecho cmde)
  ); end defun - *error*
;
  (setq cmde (getvar 'cmdecho))
  (setvar 'cmdecho 0)
  (command "_.undo" "_begin")
  (setq
    aunit (getvar 'aunits)
    osm (getvar 'osmode)
    blips (getvar 'blipmode)
    curlay (getvar 'clayer)
    anginc (getangle "\nRegularize Lines to nearest multiple of what angle? ")
  ); end setq
  (setvar 'osmode 0)
  (setvar 'blipmode 0)
  (setvar 'aunits 3); radians
;
  (initget "Yes No")
  (if
    (=
      (getkword "\nExplode Polylines and process Line segments? [Y/N] <Y>: ")
      "No"
    ); end =
    (setq lines (ssget '((0 . "LINE")))); then - only Lines
    (progn ; else - also Polylines, explode and add line segments to set
      (setq
        sstemp (ssget '((0 . "LINE,*POLYLINE")))
        lines (ssadd)
      ); end setq
      (repeat (sslength sstemp)
        (setq item (ssname sstemp 0))
        (ssdel item sstemp)
        (if (= (cdr (assoc 0 (entget item))) "LINE")
          (ssadd item lines); then - add to set of Lines
          (progn; else - it's a Polyline: explode, add resulting Lines to set
            (command "_.explode" item)
            (setq plpcs (ssget "_P"))
            (repeat (sslength plpcs)
              (setq plpc (ssname plpcs 0))
              (if (= (cdr (assoc 0 (entget plpc))) "LINE") (ssadd plpc lines))
              (ssdel plpc plpcs)
            ); end repeat
          ); end progn
        ); end if
      ); end repeat
    ); end progn - else
  ); end if
;
  (initget "Original New")
  (if
    (=
      (getkword "\nRegularize Original lines or copies on New layer? [O/N] <O>: ")
      "New"
    ); end =
    (command
      "_.layer" "_make" "ReguLines" "_color" 200 "" "" ; [change name & color number as desired]
      "_.copy" lines "" '(0 0 0) '(0 0 0)
      "_.chprop" lines "" "_layer" "ReguLines" ""
    ); end command
  ); end if  
;
  (repeat (sslength lines)
    (setq
      ln (ssname lines 0)
      lndata (entget ln)
      lnend1 (cdr (assoc 10 lndata))
      lnend2 (cdr (assoc 11 lndata))
      lnang (angle lnend1 lnend2)
      lnmid (mapcar '/ (mapcar '+ lnend1 lnend2) '(2 2 2))
      lnangnew
        (if (zerop anginc)
          0
          (* (fix (+ (/ lnang anginc) 0.5)) anginc)
        ); end if & lnangnew
    ); end setq
    (command "_.rotate" ln "" lnmid "_reference" lnang lnangnew)
    (ssdel ln lines)
  ); end repeat
;
  (setvar 'aunits aunit)
  (setvar 'osmode osm)
  (setvar 'blipmode blips)
  (setvar 'clayer curlay)
  (command "_.undo" "_end")
  (setvar 'cmdecho cmde)
  (princ)
); end defun
;

;;

;LU.LSP:   DESENCADENA LAYER.LSP    Cambia el color de Layers    (C)2003, Paulito Gil

(defun c:lu ()
     (setq lay (getvar "clayer")) 
     (prompt "Selecciona los layers a unlock: ") (terpri)
        (setq ss (ssget)
              ss1(sslength ss)
              x   0
              s2 (cdr(assoc 8 (entget(ssname ss x)))) 
        )
        (command "layer" "s" lay "")
        (repeat ss1
          (setq ssn (ssname ss x)
                a   (entget ssn)
                s1  (cdr(assoc 8 a))
          )
             (command "layer" "unlock" s1 "")
             (setq x (+ x 1))
        )
        (command "layer" "unlock" s2 "")
        (prompt"Ya estan desencadenados los layers...")(terpri)
        (princ)
)


;;



;;;   MG.lsp
;;;   Copyright (C) 1990 by Autodesk, Inc.
;;;  
;;;   Permission to use, copy, modify, and distribute this software and its
;;;   documentation for any purpose and without fee is hereby granted.  
;;;
;;;   THIS SOFTWARE IS PROVIDED "AS IS" WITHOUT EXPRESS OR IMPLIED WARRANTY. 
;;;   ALL IMPLIED WARRANTIES OF FITNESS FOR ANY PARTICULAR PURPOSE AND OF 
;;;   MERCHANTABILITY ARE HEREBY DISCLAIMED.
;;;   Creado por Marco V. Gil
;;;   April, 1990
;;;--------------------------------------------------------------------------
;;; DESCRIPCION
;;;
;;;  MG.LSP
;;; 
;;;   Esta rutina permite crear unas paralelas  en el actual UCS.     ;;;   
;;;
;;;--------------------------------------------------------------------------


(defun myerror (s)                    ; If an error (such as CTRL-C) occurs
                                      ; while this command is active...
  (if (/= s "Function cancelled")
    (princ (strcat "\nError: " s))
  )
  (setvar "cmdecho" ocmd)             ; Restore saved modes
  (setvar "blipmode" oblp)
  (setq *error* olderr)               ; Restore old *error* handler
  (princ)
)

(defun c:mg (/ olderr ocmd oblp pt1 length length2)
  (setq olderr  *error*
        *error* myerror)
  (setq ort (getvar "orthomode"))
  (setq ocmd (getvar "cmdecho"))
  (setq oblp (getvar "blipmode"))
  (setvar "cmdecho" 0)
  (initget 1)                         ;3D point can't be null
  (setq pt1 (getpoint (strcat "\nCorner of rectangle or square: ")))
  (setvar "ORTHOMODE" 1)
  (initget 7)                         ;Length can't be 0, neg, or null
  (setq length (getdist pt1 "\nLength: "))
  (setq length2 (* length 2))

  (command "mline""j""z""s" length2 pt1 pause "" "explode" "l")

  (setvar "ORTHOMODE" ort)
  (setvar "blipmode" oblp)
  (setq *error* olderr)               ; Restore old *error* handler
  (princ)
)
(princ)




;;


;;  MM.LSP    Por Paulo Gil Soto   2002   gil_soto_13@hotmail.com
;; No tiene copyright, pero de perdida mandame las gracias

(defun c:MM ()
(COND (T (SETVAR "CMDECHO" 0) (SETQ L1 nil)(WHILE (= L1 nil)(SETQ L1(ENTSEL "Pick entity on layer.")))(SETQ L1 (ENTGET (CAR L1)) L1 (CDR (ASSOC 8 L1))L1 (SSGET "X" (LIST (CONS 8 L1)))) 
(COMMAND "MOVE" L1 )(PRINC)))
)
             

;;



;;===================================================================
;;;MSF.LSP    Match Scale Factor    (c)1995, Steven Hamburg
;;Changes the scale factor of selected blocks to match the scale factor of the first block picked.
;;

 (DEFUN C:MSF (/ DUMMY N ENT BLK1 BLK2 SC ENTSET ENTITY SC1 INSPT)
   (setq DUMMY T N 0)
   (princ "\nThis routine enables the user to select an existing block in order\n")
   (princ "To change specified blocks in the dwg to the same scale factor.\n")
   (while DUMMY 
      (setq ENT (entsel "\nSelect block with desired scale factor:\n")
         BLK1 (car ENT)
      BLK2 (entget BLK1))
      (IF (= (assoc 2 BLK2) NIL)
         (princ "\n\nEntitiy is not a block\n")
         (setq SC (cdr (assoc 41 BLK2)) DUMMY NIL)
      ); end of if
   ); end of while
   (princ "\nSelect block(s) whose scale factor(s) you wish to be changed\n")
   (setq ENTSET (ssget)
   ENTITIES (sslength ENTSET))
   (while (< N ENTITIES)
      (setq ENTNAME (ssname ENTSET N)
      ENTITY (entget ENTNAME))
      (IF (/= (assoc 2 ENTITY) NIL)
         (progn
            (setq SC1 (cdr (assoc 41 ENTITY)))
            (setq INSPT (cdr (assoc 10 ENTITY)))
            (command "scale" (ssname ENTSET N) "" INSPT (/ SC SC1))
            (setq N (+ N 1))
         ); end of progn
         (setq N (+ N 1))
      ); end of if
   ); end of while
   (princ)
); end msf.lsp



;;


;;http://www.autolisp.com/forum/showthread.php?t=347
;;multiply text values by a value mult


(defun c:mult()
(setq meu-ss(ssget '((0 . "TEXT,MTEXT"))))
  (setq value (getdist "\nFactor to multiply numbers: "))
;
(setq cntr 0)
(while (< cntr (sslength meu-ss))
;
(setq en(ssname meu-ss cntr))
;
(setq enlist(entget en))
(setq s-tex(cdr(assoc 1 enlist)))
(setq n-tex(atof s-tex))
(setq nf-tex(* value n-tex))
(setq nft-tex(rtos nf-tex 2 2))
(setq enlist(subst (cons 1 nft-tex)(assoc 1 enlist) enlist))
(entmod enlist)
;
(setq cntr(+ cntr 1))
;
)
)


;;

;;http://discussion.autodesk.com/forums/thread.jspa?threadID=448625&tstart=0
;;Made by Rogerio Brazil
;;It will fit Mtext box size -height and width- to minimum for selected mtexts.

(defun c:mw (/ mtexts idx ename EntData dxf42 dxf43 EntData1);Reset Width - Mtext
(prompt "\n Select MText(s) object(s): ")
(if
(setq mtexts (ssget '((0 . "MTEXT"))))
(progn
(setq idx 0)
(repeat (sslength mtexts)
(setq ename (ssname mtexts idx))
(setq EntData (entget ename '("*")))
(setq dxf42 (* (CDR (ASSOC 42 EntData))1.015))
(setq dxf43 (cdr (assoc 43 EntData)))
(setq EntData1 (entmod (subst (cons 41 dxf42) (assoc 41 EntData) EntData)))
(entmod (subst (cons 46 dxf43) (assoc 46 EntData1) EntData1))
(setq idx (1+ idx))
);progn
);repeat
(princ "\n Null Selection!")
);if
(princ)
(setvar "orthomode" 0)
)



;;


;; ==================================================================== ;;
;;                                                                      ;;
;;  MY.LSP - The program copies the text from: DText, MText,           ;;
;;            Tables, Dimensions, Attributes, Attributes,               ;;
;;            Attributes Definitions, DText, MText and inner            ;;
;;            block's DText and MText to: DText, MText, Tables,         ;;
;;            Attribures and Attributes Definitions. There are          ;;
;;            Multiple and Pair-wise modes.                             ;;
;;                                                                      ;;
;; ==================================================================== ;;
;;                                                                      ;;
;;  Command(s) to call: MY                                             ;;
;;                                                                      ;;
;; ==================================================================== ;;
;;                                                                      ;;
;;  THIS PROGRAM AND PARTS OF IT MAY REPRODUCED BY ANY METHOD ON ANY    ;;
;;  MEDIUM FOR ANY REASON. YOU CAN USE OR MODIFY THIS PROGRAM OR        ;;
;;  PARTS OF IT ABSOLUTELY FREE.                                        ;;
;;                                                                      ;;
;;  THIS PROGRAM PROVIDES 'AS IS' WITH ALL FAULTS AND SPECIFICALLY      ;;
;;  DISCLAIMS ANY IMPLIED WARRANTY OF MERCHANTABILITY OR FITNESS        ;;
;;  FOR A PARTICULAR USE.                                               ;;
;;                                                                      ;;
;; ==================================================================== ;;
;;                                                                      ;;
;;  V1.3, 29 November, 2005, Riga, Latvia                               ;;
;;  ฉ Aleksandr Smirnov (ASMI)                                          ;;
;;  For AutoCAD 2000 - 2008 (isn't tested in a next versions)           ;;
;;                                                                      ;;
;;                             http://www.asmitools.com                 ;;
;;                                                                      ;;
;; ==================================================================== ;;

(defun c:my (/ actDoc vlaObj sObj sText curObj oldForm
                oType oldMode conFlag errFlag *error*)

  (vl-load-com)

      (setq actDoc(vla-get-ActiveDocument
        (vlax-get-acad-object)))
          (vla-StartUndoMark actDoc)

  (defun TTC_Paste(pasteStr / nslLst vlaObj hitPt
                   hitRes Row Column)
    (setq errFlag nil)
    (if
     (setq nslLst(nentsel "\nPaste text >"))
       (progn
        (cond
          ((and
             (= 4(length nslLst))
             (= "DIMENSION"(cdr(assoc 0(entget(car(last nslLst))))))
            ); end and
             (setq vlaObj(vlax-ename->vla-object
                (cdr(assoc -1(entget(car(last nslLst)))))))
           (if
             (vl-catch-all-error-p
               (vl-catch-all-apply
                 'vla-put-TextOverride(list vlaObj pasteStr)))
                   (progn
                     (princ "\n<!> Can't paste. Object may be on locked layer <!> ")
                     (setq errFlag T)
                    ); end progn
             ); end if
           ); end condition #1
          ((and
             (= 4(length nslLst))
             (= "ACAD_TABLE"(cdr(assoc 0(entget(car(last nslLst))))))
            ); end and
            (setq vlaObj
              (vlax-ename->vla-object
                 (cdr(assoc -1(entget(car(last nslLst))))))
                  hitPt(vlax-3D-Point(trans(cadr nslLst)1 0))
                  hitRes(vla-HitTest vlaObj hitPt
                        (vlax-3D-Point '(0.0 0.0 1.0)) 'Row 'Column)
            ); end setq
            (if(= :vlax-true hitRes)
             (progn
               (if(vl-catch-all-error-p
                    (vl-catch-all-apply
                      'vla-SetText(list vlaObj Row Column pasteStr)))
             (progn
               (princ "\n<!> Can't paste. Object may be on locked layer <!> ")
               (setq errFlag T)
               ); end progn
              ); end if
             ); end progn
            ); end if
           ); end condition # 2
          ((and
              (= 4(length nslLst))
              (= "INSERT"(cdr(assoc 0(entget(car(last nslLst))))))
           ); end and
            (princ "\n<!> Can't paste to block's DText or MText <!> ")
            (setq errFlag T)
            ); end condition #3
         ((and
            (= 2(length nslLst))
            (member(cdr(assoc 0(entget(car nslLst))))
             '("TEXT" "MTEXT" "ATTRIB" "ATTDEF"))
           ); end and
         (setq vlaObj(vlax-ename->vla-object(car nslLst)))
        (if(vl-catch-all-error-p
             (vl-catch-all-apply
               'vla-put-TextString(list vlaObj pasteStr)))
             (progn
               (princ "\n<!> Error. Can't pase text <!> ")
               (setq errFlag T)
             ); end progn
            ); end if
          ); end condition #4
        (T
          (princ "\n<!> Can't paste. Invalid object <!> ")
          (setq errFlag T)
         ); end condition #5
        ); end cond
              T
       ); end progn
             nil
            ); end if
     ); end of TTC_Paste


    (defun TTC_MText_Clear(Mtext / Text Str)
      (setq Text "")
      (while(/= Mtext "")
        (cond
          ((wcmatch(strcase
           (setq Str
            (substr Mtext 1 2)))"\\[\\{}`~]")
            (setq Mtext(substr Mtext 3)
               Text(strcat Text Str)
               ); end setq
           ); end condition #1
         ((wcmatch(substr Mtext 1 1) "[{}]")
          (setq Mtext
          (substr Mtext 2))
          ); end condition #2
         ((and
          (wcmatch
           (strcase
             (substr Mtext 1 2)) "\\P")
               (/=(substr Mtext 3 1) " ")
           ); end and
         (setq Mtext (substr Mtext 3)
               Text (strcat Text " ")
               ); end setq
           ); end condition #3
        ((wcmatch
           (strcase
             (substr Mtext 1 2)) "\\[LOP]")
             (setq Mtext(substr Mtext 3))
           ); end condition #4
        ((wcmatch
           (strcase
             (substr Mtext 1 2)) "\\[ACFHQTW]")
           (setq Mtext
            (substr Mtext
             (+ 2(vl-string-search ";" Mtext))))
           ); end condition #5
        ((wcmatch
           (strcase (substr Mtext 1 2)) "\\S")
             (setq Str(substr Mtext 3 (- (vl-string-search ";" Mtext) 2))
                   Text(strcat Text (vl-string-translate "#^\\" " " Str))
                   Mtext(substr Mtext (+ 4 (strlen Str)))
              ); end setq
            (print Str)
          ); end condition #6
         (T(setq Text(strcat Text(substr Mtext 1 1))
                 Mtext (substr Mtext 2)
                 ); end setq
         ); end condition #7
       ); end cond
     ); end while
   Text
 ); end of TTC_MText_Clear


  (defun TTC_Copy (/ sObj sText tType actDoc)
   (if
    (and
     (setq sObj(car(nentsel "\nCopy text... ")))
     (member(setq tType(cdr(assoc 0(entget sObj))))
      '("TEXT" "MTEXT" "ATTRIB" "ATTDEF"))
     ); end and
    (progn
      (setq actDoc(vla-get-ActiveDocument
        (vlax-get-Acad-object))
            sText(vla-get-TextString
       (vlax-ename->vla-object sObj))
      ); end setq
      (if(= tType "MTEXT")
         (setq sText(TTC_MText_Clear sText))
        ); end if
      ); end progn
     ); end if
    sText
    ); end of TTC_Copy

  (defun CCT_Str_Echo(paseStr / comStr)
    (if(< 20(strlen paseStr))
      (setq comStr
       (strcat
         (substr paseStr 1 17)"..."))
      (setq comStr paseStr)
      ); end if
     (princ(strcat "\nText = \"" comStr "\""))
    (princ)
    ); end of CCT_Str_Echo

    (defun *error*(msg)
    (vla-EndUndoMark
      (vla-get-ActiveDocument
        (vlax-get-acad-object)))
     (princ "\nQuit TTC")
    (princ)
    ); end of *error*

    (if(not ttc:Mode)(setq ttc:Mode "Multiple"))
     (initget "Multiple Pair-wise")
     (setq oldMode ttc:Mode
           ttc:Mode(getkword
                     (strcat "\nSpecify mode [Multiple/Pair-wise] <"ttc:Mode">: "))
           conFlag T
           paseStr ""
          ); end setq
    (if(null ttc:Mode)(setq ttc:Mode oldMode))
    (if(= ttc:Mode "Multiple")
      (progn
        (if(and(setq paseStr(TTC_Copy))conFlag)
         (progn
          (CCT_Str_Echo paseStr)
         (while(setq conFlag(TTC_Paste paseStr))T
            ); end while
        ); end progn
      ); end if
    ); end progn
      (progn
        (while(and conFlag paseStr)
           (setq paseStr(TTC_Copy))
            (if(and paseStr conFlag)
              (progn
               (CCT_Str_Echo paseStr)
                (setq errFlag T)
                  (while errFlag
                    (setq conFlag(TTC_Paste paseStr))
                );end while
              ); end progn
            ); end if
          ); end while
        ); end progn
      ); end if
   (vla-EndUndoMark actDoc)
   (princ "\nQuit my")
  (princ)
  ); end c:my



;;


;==========================================================
;Written by Len Nemirovsky                     September 2003
;Better Than Nothing Autolisp http://www.wport.com/~nemi 
;To match one string of text to another
;==========================================================
(defun c:my2 (/ l1 lll1 ll1 lin1 line1 l2 lll2 ll2 line2 
                 med1 med2)
   (setq l1 (nentsel "\nSelect Line of text to match to: "))
   (if (= l1 nil)(exit))
   (setq lll1 (car l1))
   (redraw lll1 3)
   (setq ll1 (entget (car l1)))
   (setq lin1 (cdr (assoc 0 ll1))) 
   (setq line1 (cdr (assoc 1 ll1)))
   (if (= line1 nil)(exit))
(while
     (setq l2 (nentsel "\nSelect  Line(s) of tex to be  matched<enter when done>: "))
     (setq lll2 (car l2))
     (redraw lll2 3)
     (setq ll2 (entget (car l2)))
     (setq lin2 (cdr (assoc 0 ll2)))
     (setq line2 (cdr (assoc 1 ll2)))
     (if (= line2 nil)(progn(redraw lll1 4) (exit)))

      (setq med2 ll2)
      (setq med2 
                (subst (cons 1 line1)
                       (assoc 1 med2)
                       med2
                )
      )
      (entmod med2)
(if
  (or
     (= lin1 "ATTRIB")
     (= lin2 "ATTRIB")
 )
 (command "redrawall")
)
)
(redraw lll1 4)
(princ)
)

;;


;;; ------------------------------------------------------------------------
;;;	CopyText.lsp v1.2
;;;
;;;	Copyrightฉ 03.16.09
;;;	Alan J. Thompson (alanjt)
;;;	alanjt@gmail.com
;;;
;;;	Permission to use, copy, modify, and distribute this software
;;;	for any purpose and without fee is hereby granted, provided
;;;	that the above copyright notice appears in all copies and
;;;	that both that copyright notice and the limited warranty and
;;;	restricted rights notice below appear in all supporting
;;;	documentation.
;;;
;;;	The following program(s) are provided "as is" and with all faults.
;;;	Alan J. Thompson DOES NOT warrant that the operation of the program(s)
;;;	will be uninterrupted and/or error free.
;;;
;;;	User has option to copy contents of selected text object or typed in
;;;	content, to any number of selected text objects (Text, Mtext, Multileader,
;;;	Attribute Definition). If only one target object is selected,
;;;	user is prompted with option to swap contents of source & target.
;;;	Will select objects in xrefs & blocks.
;;;
;;;	Revision History:
;;;
;;;	v1.1 (06.08.09) 1. Rewrite to code after replacing/updating subroutines.
;;;
;;;	v1.2 (09.18.09) 1. Added function to, if applicable, strip formatting codes
;;;			   of textstring taken from MtextAttributes.
;;;			2. Removed issue with selecting Multileaders with blocks.
;;;			3. Added option to select multiple 'target' text objects.
;;;			4. Added option to type in text value to copy to others.
;;;			5. Added subroutines: AT:SS->List, AT:TabFilter, AT:EditTextBox
;;;
;;; ------------------------------------------------------------------------

(defun c:MY3 (/) (c:CopyText))
(defun c:CopyText (/ *error* AT:Undo AT:Entsel #Count #SSPickfirst
                   _#Strip #SourceObj #SourceText #TargetEnt #Flag
                   #TargetObj #TargetText #Answer
                  )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SUBROUTINES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;; error handler
  (defun *error* (#Message)
    (AT:Undo "V" "E")
    (and #Message
         (not (wcmatch (strcase #Message) "*BREAK*,*CANCEL*,*QUIT*"))
         (princ (strcat "\nError: " #Message))
    ) ;_ and
  ) ;_ defun



;;; Undo Begin/End (Either VLA or Command)
;;; #CommandVLA - "V" for VLA OR "C" for Command
;;; #BeginEnd - "B" for Undo Begin OR "E" for Undo End
;;; Alan J. Thompson, 03.23.09
  (defun AT:Undo (#CommandVLA #BeginEnd / #OldCmdecho)
    (if
      (and
        (member (strcase #CommandVLA) (list "C" "V"))
        (member (strcase #BeginEnd) (list "B" "E"))
      ) ;_ and
       (cond
         ;; COMMAND Undo Options
         ((eq "C" (strcase #CommandVLA))
          (setq #OldCmdecho (getvar "cmdecho"))
          (setvar "cmdecho" 0)
          (cond
            ;; Undo Begin
            ((eq "B" (strcase #BeginEnd)) (command "_.undo" "_begin"))
            ;; Undo End
            ((eq "E" (strcase #BeginEnd)) (command "_.undo" "_end"))
          ) ;_ cond
          (setvar "cmdecho" #OldCmdecho)
         )
         ;; VLA Undo Options
         ((eq "V" (strcase #CommandVLA))
          (cond
            ;; Undo Begin
            ((eq "B" (strcase #BeginEnd))
             (vla-StartUndoMark
               (vla-get-ActiveDocument
                 (vlax-get-Acad-Object)
               ) ;_ vla-get-ActiveDocument
             ) ;_ vla-StartUndoMark
            )
            ;; Undo End
            ((eq "E" (strcase #BeginEnd))
             (vla-EndUndoMark
               (vla-get-ActiveDocument
                 (vlax-get-Acad-Object)
               ) ;_ vla-get-ActiveDocument
             ) ;_ vla-EndUndoMark
            )
          ) ;_ cond
         )
       ) ;_ cond
    ) ;_ if
  ) ;_ defun



;;; Entsel or NEntsel with options
;;; #Nested - Entsel or Nentsel (T for Nentsel, nil for Entsel)
;;; #Message - Selection message (if nil, "\nSelect object: " is used)
;;; #FilterList - DXF ssget style filtering (nil if not required)
;;;               "V" as first item in list to convert object to VLA-OBJECT (must be in list if no DXF filtering)
;;;               "L" as first item in list to ignore locked layers (must be in list if no DXF filtering)
;;; #Keywords - Keywords to match instead of object selection (nil if not required)
;;; Example: (AT:Entsel nil "\nSelect MText not on 0 layer [Settings]: " '("LV" (0 . "MTEXT")(8 . "~0")) "Settings")
;;; Example: (AT:Entsel T "\nSelect object [Settings]: " '("LV") "Settings")
;;; Alan J. Thompson, 04.16.09
;;; Updated: Alan J. Thompson, 06.04.09 (changed filter coding to work as ssget style dxf filtering)
;;; Updated: Alan J. Thompson, 09.07.09 (added option to ignore locked layers and convert object to VLA-OBJECT
;;; Updated: Alan J. Thompson, 09.18.09 (fixed 'missed pick' alert)
  (defun AT:Entsel (#Nested #Message #FilterList #Keywords / #Count
                    #Message #Choice #Ent #VLA&Locked #FilterList
                   )
    (vl-load-com)
    (setvar "errno" 0)
    (setq #Count 0)
    ;; fix message
    (or #Message (setq #Message "\nSelect object: "))
    ;; set entsel/nentsel
    (if #Nested
      (setq #Choice nentsel)
      (setq #Choice entsel)
    ) ;_ if
    ;; check if option to convert to vla-object or ignore locked layers in #FilterList variable
    (and (vl-consp #FilterList)
         (eq (type (car #FilterList)) 'STR)
         (setq #VLA&Locked (car #FilterList)
               #FilterList (cdr #FilterList)
         ) ;_ setq
    ) ;_ and
    ;; select object
    (while (and (not #Ent) (/= (getvar "errno") 52))
      ;; if keywords
      (and #Keywords (initget #Keywords))
      (cond
        ((setq #Ent (#Choice #Message))
         ;; if ignore locked layers
         (and
           #VLA&Locked
           (vl-consp #Ent)
           (wcmatch (strcase #VLA&Locked) "*L*")
           (not
             (zerop
               (cdr (assoc 70
                           (entget (tblobjname
                                     "layer"
                                     (cdr (assoc 8 (entget (car #Ent))))
                                   ) ;_ tblobjname
                           ) ;_ entget
                    ) ;_ assoc
               ) ;_ cdr
             ) ;_ zerop
           ) ;_ not
           (setq #Ent nil
                 #Flag T
           ) ;_ setq
         ) ;_ and
         ;; #FilterList check
         (if (and #FilterList (vl-consp #Ent))
           ;; process filtering from #FilterList
           (or
             (not
               (member
                 nil
                 (mapcar
                   '(lambda (x)
                      (wcmatch
                        (strcase
                          (vl-princ-to-string
                            (cdr (assoc (car x) (entget (car #Ent))))
                          ) ;_ vl-princ-to-string
                        ) ;_ strcase
                        (strcase (vl-princ-to-string (cdr x)))
                      ) ;_ wcmatch
                    ) ;_ lambda
                   #FilterList
                 ) ;_ mapcar
               ) ;_ member
             ) ;_ not
             (setq #Ent nil
                   #Flag T
             ) ;_ setq
           ) ;_ or
         ) ;_ if
        )
      ) ;_ cond
      (and (or (= (getvar "errno") 7) #Flag)
           (/= (getvar "errno") 52)
           (not #Ent)
           (setq #Count (1+ #Count))
           (prompt (strcat "\nNope, keep trying!  "
                           (itoa #Count)
                           " missed pick(s)."
                   ) ;_ strcat
           ) ;_ prompt
      ) ;_ and
    ) ;_ while
    (if (and (vl-consp #Ent)
             #VLA&Locked
             (wcmatch (strcase #VLA&Locked) "*V*")
        ) ;_ and
      (vlax-ename->vla-object (car #Ent))
      #Ent
    ) ;_ if
  ) ;_ defun



;;; Edit text box (Old Mtext editor)
;;; Returns typed in textstring
;;; Alan J. Thompson, 09.18.09
(defun AT:EditTextBox (/ *error* #Vars #OldVars #Mtext #String)
  (setq *error*  (lambda (msg)
                   (and #Mtext (entdel #Mtext))
                   (and #Vars #OldVars (mapcar 'setvar #Vars #OldVars))
                 ) ;_ lambda
        #OldVars (mapcar 'getvar (setq #Vars (list "mtexted" "cmdecho")))
  ) ;_ setq
  (setvar "cmdecho" 0)
  (vl-catch-all-apply 'setvar (list "mtexted" "OldEditor"))
  (setq #Mtext (entmakex (list
                           '(0 . "MTEXT")
                           '(100 . "AcDbEntity")
                           '(100 . "AcDbMText")
                           (cons 10 (trans (getvar "viewctr") 1 0))
                         ) ;_ list
               ) ;_ entmakex
  ) ;_ setq
  (vl-cmdf "_.mtedit" #Mtext)
  (setq #String (vla-get-textstring (vlax-ename->vla-object #Mtext)))
  (*error* nil)
  (if (/= #String "")
    #String
  ) ;_ if
) ;_ defun




;;; Convert selection set to list of ename or vla objects
;;; #Selection - SSGET selection set
;;; #VLAList - T for vla objects, nil for ename
;;; Alan J. Thompson, 04.20.09
  (defun AT:SS->List (#Selection #VlaList / #List)
    (and #Selection
         (setq #List (vl-remove-if
                       'listp
                       (mapcar 'cadr (ssnamex #Selection))
                     ) ;_ vl-remove-if
         ) ;_ setq
         #VlaList
         (setq #List (mapcar 'vlax-ename->vla-object #List))
    ) ;_ and
    #List
  ) ;_ defun



;;; Tab filter for ssget selection filtering
;;; Must use (list instead of '( to work
;;; Alan J. Thompson, 06.05.09
  (defun AT:TabFilter (/)
    (if (eq 2 (getvar "cvport"))
      (cons 410 "Model")
      (cons 410 (getvar "ctab"))
    ) ;_ if
  ) ;_ defun



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; MAIN ROUTINE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  (vl-load-com)

  (AT:Undo "V" "B")
  (setq #Count 0)
  (if (setq #SSPickfirst
             (ssget "_I" '((0 . "MTEXT,TEXT,MULTILEADER,ATTDEF")))
      ) ;_ setq
    (setq #TargetEnt "Multiple")
  ) ;_ if

  ;; format strip for Multiline Attributes, if applicable
  (setq _#Strip
         (lambda (#String / #String)
           (mapcar '(lambda (f r)
                      (while (vl-string-search f #String)
                        (setq #String (vl-string-subst r f #String))
                      ) ;_ while
                    ) ;_ lambda
                   ;; find list
                   (list "\\P" "\\L" "\\l" "\\O")
                   ;; replace list
                   (list " " "" "" "")
           ) ;_ mapcar
           (vl-string-right-trim
             "}"
             (vl-string-left-trim "{" #String)
           ) ;_ vl-string-right-trim
         ) ;_ lambda
  ) ;_ setq

  (if
    (and
      (setq #SourceObj
             (AT:Entsel
               T
               "\nSelect source text object for copying or [Type]: "
               '("LV"
                 (0 . "MTEXT,TEXT,MULTILEADER,ATTDEF,ATTRIB")
                )
               "Type"
             ) ;_ AT:Entsel
      ) ;_ setq
      (cond
        ;; text object selected
        ((eq (type #SourceObj) 'VLA-OBJECT)
         (not (vl-catch-all-error-p
                (setq #SourceText
                       (vl-catch-all-apply
                         'vlax-get-property
                         (list #SourceObj 'TextString)
                       ) ;_ vl-catch-all-apply
                ) ;_ setq
              ) ;_ vl-catch-all-error-p
         ) ;_ not
        )
        ;; "Type" option
        ((eq #SourceObj "Type") (setq #SourceText (AT:EditTextBox)))
      ) ;_ cond
    ) ;_ and
     (progn
       ;; time to select text object whose contents will be replaced with source
       (while (and (not #Flag)
                   (or #SSPickfirst
                       (setq #TargetEnt
                              (AT:Entsel
                                T
                                "\nSelect target text object to modify or [Multiple]: "
                                '("L"
                                  (0 . "MTEXT,TEXT,MULTILEADER,ATTDEF,ATTRIB")
                                 )
                                "Multiple"
                              ) ;_ AT:Entsel
                       ) ;_ setq
                   ) ;_ or
              ) ;_ and
         (if (or
               ;; multiple selection
               (and (eq #TargetEnt "Multiple")
                    (setq #TargetObj
                           (AT:SS->List
                             (ssget
                               ":L"
                               (list
                                 (AT:TabFilter)
                                 (cons 0 "MTEXT,TEXT,MULTILEADER,ATTDEF")
                               ) ;_ list
                             ) ;_ ssget
                             T
                           ) ;_ AT:SS->List
                    ) ;_ setq
                    (setq #Flag T)
               ) ;_ and
               ;; single selection
               (and (vl-consp #TargetEnt)
                    (setq #TargetObj
                           (list (vlax-ename->vla-object (car #TargetEnt))
                           ) ;_ list
                    ) ;_ setq
               ) ;_ and
             ) ;_ or
           (foreach x #TargetObj
             (cond
               ;; source & target are same object
               ((and (eq (type #SourceObj) 'VLA-OBJECT)
                     (eq (vlax-get-property #SourceObj 'ObjectID)
                         (vlax-get-property x 'ObjectID)
                     ) ;_ eq
                ) ;_ and
                (and (vl-consp #TargetEnt)
                     (alert "Cannot match source with itself!")
                ) ;_ and
               )
               ;; able to extract textstring
               ((not (vl-catch-all-error-p
                       (setq #TargetText
                              (vl-catch-all-apply
                                'vlax-get-property
                                (list x 'TextString)
                              ) ;_ vl-catch-all-apply
                       ) ;_ setq
                     ) ;_ vl-catch-all-error-p
                ) ;_ not
                (setq #Count (1+ #Count))
                (vl-catch-all-apply
                  'vlax-put-property
                  (list
                    x
                    'TextString
                    ;; account for formattting, if going from multiline attribute to text or single line attribute
                    (if
                      (and
                        ;; source is MtextAttribute
                        (eq (vl-catch-all-apply
                              'vlax-get-property
                              (list #SourceObj 'MTextAttribute)
                            ) ;_ vl-catch-all-apply
                            :vlax-true
                        ) ;_ eq
                        ;; target not MtextAttribute
                        (not (eq (vl-catch-all-apply
                                   'vlax-get-property
                                   (list x 'MTextAttribute)
                                 ) ;_ vl-catch-all-apply
                                 :vlax-true
                             ) ;_ eq
                        ) ;_ not
                        ;; target not Mtext or multileader
                        (not (member (vlax-get-property x 'ObjectName)
                                     (list "AcDbMText" "AcDbMLeader")
                             ) ;_ member
                        ) ;_ not
                      ) ;_ and
                       (_#Strip #SourceText)
                       #SourceText
                    ) ;_ if
                  ) ;_ list
                ) ;_ vl-catch-all-apply
               )
               ;; unable to extract text, must not be able to edit it
               (T
                (and (vl-consp #TargetEnt)
                     (alert "Cannot edit text within selected object!")
                ) ;_ and
               )
             ) ;_ cond
           ) ;_ foreach
         ) ;_ if
       ) ;_ while
       ;; if only 1 target object selected, option to switch source & target offered
       (and
         (eq 1 #Count)
         (not (eq (type #SourceObj) 'STR))
         (not (initget 0 "Yes No Swap"))
         (setq
           #Answer (getkword
                     "\nSwap source & target contents? [Yes/No] <No>: "
                   ) ;_ getkword
         ) ;_ setq
         (member #Answer (list "Yes" "Swap"))
         (vl-catch-all-apply
           'vlax-put-property
           (list
             #SourceObj
             'TextString
             ;; account for formatting, if going from multiline attribute to text or single line attribute
             (if
               (and
                 (eq 1 (length #TargetObj))
                 ;; target is MtextAttribute
                 (eq (vl-catch-all-apply
                       'vlax-get-property
                       (list (car #TargetObj) 'MTextAttribute)
                     ) ;_ vl-catch-all-apply
                     :vlax-true
                 ) ;_ eq
                 ;; source not MtextAttribute
                 (not (eq (vl-catch-all-apply
                            'vlax-get-property
                            (list #SourceObj 'MTextAttribute)
                          ) ;_ vl-catch-all-apply
                          :vlax-true
                      ) ;_ eq
                 ) ;_ not
                 ;; source not Mtext or multileader
                 (not (member (vlax-get-property #SourceObj 'ObjectName)
                              (list "AcDbMText" "AcDbMLeader")
                      ) ;_ member
                 ) ;_ not
               ) ;_ and
                (_#Strip #TargetText)
                #TargetText
             ) ;_ if
           ) ;_ list
         ) ;_ vl-catch-all-apply
       ) ;_ and
     ) ;_ progn
  ) ;_ if

  (*error* nil)

  (princ)
) ;_ defun

;;


;Matchtxt.lsp russ.steffy@ffeminerals.com made work like MATCHPROP for text content
;of attributes, dimensions, dtext, mtext, nested text in blocks... It works by
;changing the group association code 1 directly using (entmod) 19FEB2002
;
;
;

(defun C:MY4 (/ TXT_STR ENTITY ENTITY_NAME ENTITY_LIST OLD_VALUE
                     NEW_VALUE NEW_ENTITY_LIST
	          ) 

(setq ENTITY (entsel "\nSelect source text: "))
(setq ENTITY_NAME (car ENTITY))
(setq ENTITY_LIST (entget ENTITY_NAME))
 (if (and (= (cdr(assoc 0  ENTITY_LIST)) "INSERT")(= (cdr(assoc 66  ENTITY_LIST)) 1))
   (progn
     (setq ENTITY (nentsel "\nSelect attribute text: "))
     (setq ENTITY_NAME (car ENTITY))
     (setq ENTITY_LIST (entget ENTITY_NAME))
   );progn
 );if
 (if (and (= (cdr(assoc 0  ENTITY_LIST)) "INSERT")(= (cdr(assoc 66  ENTITY_LIST)) nil))
   (progn
     (setq ENTITY (nentsel "\nSelect nested text: "))
     (setq ENTITY_NAME (car ENTITY))
     (setq ENTITY_LIST (entget ENTITY_NAME))
   );progn
 );if 
 (if (and (= (cdr(assoc 0  ENTITY_LIST)) "MTEXT")(/= (cdr(assoc 3  ENTITY_LIST)) nil))
  (progn
    (alert "Text string is greater than 250 characters....exiting")
    (exit)
  );progn
 );if 
 (setq TXT_STR (cdr (assoc 1 ENTITY_LIST)))
(while  
 (setq ENTITY (entsel "\nSelect destination text: "))
 (setq ENTITY_NAME (car ENTITY))
 (setq ENTITY_LIST (entget ENTITY_NAME))
   (if (/= (cdr(assoc 0  ENTITY_LIST)) "INSERT")
    (progn 
     (setq OLD_VALUE       (assoc 1  ENTITY_LIST))
     (setq NEW_VALUE       (cons  1  TXT_STR))
     (if (and (= (cdr(assoc 0  ENTITY_LIST)) "MTEXT")(/= (cdr(assoc 3  ENTITY_LIST)) nil))
       (alert "Text string is greater than 250 characters....not updating")
       (progn
         (setq NEW_ENTITY_LIST (subst NEW_VALUE  OLD_VALUE  ENTITY_LIST))
         (entmod NEW_ENTITY_LIST)
         (if (setq ENTITY (cdr (assoc -1 ENTITY_LIST))) (entupd ENTITY))
       );progn
      );if
    );progn 
   );if
 (if (and (= (cdr(assoc 0  ENTITY_LIST)) "INSERT")(= (cdr(assoc 66  ENTITY_LIST)) 1))
   (progn
     (setq ENTITY (nentsel "\nSelect attribute text: "))
     (setq ENTITY_NAME (car ENTITY))
     (setq ENTITY_LIST (entget ENTITY_NAME))
     (setq OLD_VALUE       (assoc 1  ENTITY_LIST))
     (setq NEW_VALUE       (cons  1  TXT_STR))
     (setq NEW_ENTITY_LIST (subst NEW_VALUE  OLD_VALUE  ENTITY_LIST))
     (entmod NEW_ENTITY_LIST)
     (if (setq ENTITY (cdr (assoc -1 ENTITY_LIST))) (entupd ENTITY))     
   );progn
 );if
 (if (and (= (cdr(assoc 0  ENTITY_LIST)) "INSERT")(= (cdr(assoc 66  ENTITY_LIST)) nil))
   (progn
     (setq ENTITY (nentsel "\nSelect nested text: "))
     (setq ENTITY_NAME (car ENTITY))
     (setq ENTITY_LIST (entget ENTITY_NAME))
     (setq OLD_VALUE       (assoc 1  ENTITY_LIST))
     (setq NEW_VALUE       (cons  1  TXT_STR))
     (setq NEW_ENTITY_LIST (subst NEW_VALUE  OLD_VALUE  ENTITY_LIST))
     (entmod NEW_ENTITY_LIST)
     (if (setq ENTITY (cdr (assoc -1 ENTITY_LIST))) (entupd ENTITY))
     (command "REGEN")
   );progn
 );if
);while
(princ)  
);end C:MATCHTXT


;;

;* CURRENT LAYER OFFSET
;* Provides offsets to current layer.
;* Kent M. Taylor  5/90
;* Revised 4/91

(defun C:OL ( / ce cl ent side e1 e2 pt1 )
  (setq ce (getvar "cmdecho"))
  (setvar "cmdecho" 0)
  (setq cl (getvar "clayer"))
  (setq dist (getvar "offsetdist"))
  (while 
    (setq ent (entsel "\nSelect object to offset: "))
    (if ent
      (progn
        (if (not dist)
          (progn
            (setq pt1 (getpoint "\nThrough point: "))
            (mark)
            (command "OFFSET" "T" ent pt1 "")
          );progn
          (progn
            (setq side (getpoint "\nIndicate offset side: "))
            (mark)
            (command "OFFSET" dist ent side "")
          );progn
          );if
        (setq e2 (entnext e1))
        (command "CHANGE" e2 "" "P" "LA" cl "")
      );progn
    );if
  );while
  (setvar "cmdecho" ce)
; (setq dist nil)
  (princ)
);defun
(princ)

(defun mark ()
  (command nil nil nil "POINT" "@")                 ;place database marker
  (setq e1 (entlast))                               ;set as last entity
  (entdel e1)                                       ;delete
)
;;;  


;;


;* CURRENT LAYER OFFSET
;* Provides offsets to current layer.
;* Kent M. Taylor  5/90
;* Revised 4/91

(defun C:o๑ ( / ce cl ent side e1 e2 pt1 )
  (setq ce (getvar "cmdecho"))
  (setvar "cmdecho" 0)
  (setq cl (getvar "clayer"))
  (setq dist (getvar "offsetdist"))
  (while 
    (setq ent (entsel "\nSelect object to offset: "))
    (if ent
      (progn
        (if (not dist)
          (progn
            (setq pt1 (getpoint "\nThrough point: "))
            (mark)
            (command "OFFSET" "T" ent pt1 "")
          );progn
          (progn
            (setq side (getpoint "\nIndicate offset side: "))
            (mark)
            (command "OFFSET" dist ent side "")
          );progn
          );if
        (setq e2 (entnext e1))
        (command "CHANGE" e2 "" "P" "LA" cl "")
        (command "ERASE" ent "")
      );progn
    );if
  );while
  (setvar "cmdecho" ce)
; (setq dist nil)
  (princ)
);defun
(princ)

(defun mark ()
  (command nil nil nil "POINT" "@")                 ;place database marker
  (setq e1 (entlast))                               ;set as last entity
  (entdel e1)                                       ;delete
)
;;;  



;;


;TIP731.LSP  Offset Line Each Side  (c)1992, Art Houghton
(DEFUN c:OM (/ LAYER ECHO TEMP ENTITY OS DIS E PT1 PT2 PT3 A)
  (SETQ LAYER (GETVAR "clayer")
        ECHO (GETVAR "CMDECHO"))
  (SETVAR "CMDECHO" 0)
  (WHILE
   (PROGN
    (SETQ TEMP (GETSTRING (STRCAT
     "\nDestination Layer?<"layer">:")))
    (COND
     ((EQ TEMP "") NIL)
     ((tblsearch "LAYER" TEMP) (setq layer temp) nil)
    (t (princ "\nLayer not found."))
)))
  (setvar "cmdecho" echo)
  (princ)
  (setq os (getvar "osmode"))
  (setq dis (getdist "\nEnter offset distance  "))
  (setq dis (/ dis 2))
  (setq e 1)
  (while e
    (setvar "osmode" 512)
    (setq pt1 (getpoint "\nPick line to offset  "))
    (setvar "osmode" os)
    (setq pt2 (polar pt1 3.12414 1))
    (setq pt3 (polar pt1 3.12414 -1))
    (command "offset" dis pt1 pt2 "")
  (setq entity (entlast)
      entity (entget entity)
      entity (subst (cons 8 layer)
             (assoc 8 entity) entity))
    (entmod entity)
    (command "erase" "l" "")
    (command "offset" dis pt1 pt3 "")
  (setq entity (entlast)
      entity (entget entity)
      entity (subst (cons 8 layer)
             (assoc 8 entity) entity))
    (entmod entity)
    (command "oops")
    (setq a (getstring "\nEnter to continue or <E> to stop  "))
    (if (= (strcase a) "E") (setq e nil))
  )
)


;;



;
(defun c:page ()
	 (setq os (getvar "osmode")) 
	 (setvar "osmode" 0)
	 (command "tilemode""0""-plot""y""""Canon iR2020 3er Piso_e.pc3""11x17""I""L""N""W""25.4,3.81""908.685,603.885""F""0.75,0""Y""M3_11x17.ctb""Y""N""N""N""N""Y""N")
	 (setvar "osmode" os)
      (princ)
)
;
(defun c:page2 ()
	 (setq os (getvar "osmode")) 
	 (setvar "osmode" 0)
	 (command "tilemode""0""-plot""y""""Canon iR2020 3er Piso_e.pc3""11x17""I""L""N""W""1,0.15""35.775,23.775""F""0.75,0""Y""M3_11x17.ctb""Y""N""N""N""N""Y""N")
	 (setvar "osmode" os)
      (princ)
)
;
(defun c:pagei ()
	 (setq os (getvar "osmode")) 
	 (setvar "osmode" 0)
	 (command "tilemode""0""-plot""y""""Canon iR2020 3er Pisoi.pc3""11x17""I""L""N""W""25.4,3.81""908.685,603.885""F""0.75,0""Y""M3_11x17.ctb""Y""N""N""N""N""Y""N")
	 (setvar "osmode" os)
      (princ)
)
;
(defun c:pagei2 ()
	 (setq os (getvar "osmode")) 
	 (setvar "osmode" 0)
	 (command "tilemode""0""-plot""y""""Canon iR2020 3er Pisoi.pc3""11x17""I""L""N""W""1,0.15""35.775,23.775""F""0.75,0""Y""M3_11x17.ctb""Y""N""N""N""N""Y""N")
	 (setvar "osmode" os)
      (princ)
)
;



;;


(defun c:pdf ()
	 (setq os (getvar "osmode"))
         (setq DwgFilePath (getvar "dwgprefix"))
         (setq DwgNamed (substr (Getvar "DWGNAME") 1 (- (strlen (getvar "DWGNAME")) 4)))
	 (setvar "osmode" 0)
         	(cond
                	((= (atof (getvar 'AcadVer)) 17.2)(command "tilemode""0""-plot""y""""DWG To PDF2009.pc3""ARCH expand D (36.00 x 24.00 Inches)""I""L""N""W""25.4,3.81""908.685,603.885""1=25.4""0.75,-0.187452""Y""M3_11x17_pdf.ctb""Y""N""N""N" (strcat DwgFilePath DwgNamed ".pdf") "N""Y"))
                        ((= (atof (getvar 'AcadVer)) 17.1)(command "tilemode""0""-plot""y""""DWG To PDF2008.pc3""ARCH expand D (36.00 x 24.00 Inches)""I""L""N""W""25.4,3.81""908.685,603.885""1=25.4""0.75,-0.187452""Y""M3_11x17_pdf.ctb""Y""N""N""N" (strcat DwgFilePath DwgNamed ".pdf") "N""Y"))
                        ((= (atof (getvar 'AcadVer)) 18.0)(command "tilemode""0""-plot""y""""DWG To PDF2010.pc3""ARCH expand D (36.00 x 24.00 Inches)""I""L""N""W""25.4,3.81""908.685,603.885""1=25.4""0.75,-0.187452""Y""M3_11x17_pdf.ctb""Y""N""N""N" (strcat DwgFilePath DwgNamed ".pdf") "N""Y"))
			((= (atof (getvar 'AcadVer)) 18.1)(command "tilemode""0""-plot""y""""DWG To PDF2011.pc3""ARCH expand D (36.00 x 24.00 Inches)""I""L""N""W""25.4,3.81""908.685,603.885""1=25.4""0.75,-0.187452""Y""M3_11x17_pdf.ctb""Y""N""N""N" (strcat DwgFilePath DwgNamed ".pdf") "N""Y"))
		)
	(setvar "osmode" os)
)
;
(defun c:pde ()
	 (setq os (getvar "osmode"))
         (setq DwgFilePath (getvar "dwgprefix"))
         (setq DwgNamed (substr (Getvar "DWGNAME") 1 (- (strlen (getvar "DWGNAME")) 4)))
	 (setvar "osmode" 0)
         	(cond
                	((= (atof (getvar 'AcadVer)) 17.2)(command "tilemode""0""-plot""y""""DWG To PDF2009.pc3""ARCH expand D (36.00 x 24.00 Inches)""I""L""N""W""1,0.15""35.775,23.775""1=1""0.75,-0.187452""Y""M3_11x17_pdf.ctb""Y""N""N""N" (strcat DwgFilePath DwgNamed ".pdf") "N""Y"))
                        ((= (atof (getvar 'AcadVer)) 17.1)(command "tilemode""0""-plot""y""""DWG To PDF2008.pc3""ARCH expand D (36.00 x 24.00 Inches)""I""L""N""W""1,0.15""35.775,23.775""1=1""0.75,-0.187452""Y""M3_11x17_pdf.ctb""Y""N""N""N" (strcat DwgFilePath DwgNamed ".pdf") "N""Y"))
                        ((= (atof (getvar 'AcadVer)) 18.0)(command "tilemode""0""-plot""y""""DWG To PDF2010.pc3""ARCH expand D (36.00 x 24.00 Inches)""I""L""N""W""1,0.15""35.775,23.775""1=1""0.75,-0.187452""Y""M3_11x17_pdf.ctb""Y""N""N""N" (strcat DwgFilePath DwgNamed ".pdf") "N""Y"))
			((= (atof (getvar 'AcadVer)) 18.1)(command "tilemode""0""-plot""y""""DWG To PDF2010.pc3""ARCH expand D (36.00 x 24.00 Inches)""I""L""N""W""1,0.15""35.775,23.775""1=1""0.75,-0.187452""Y""M3_11x17_pdf.ctb""Y""N""N""N" (strcat DwgFilePath DwgNamed ".pdf") "N""Y"))
		)
	(setvar "osmode" os)
)
;
(defun c:5020 ()
	 (setq os (getvar "osmode")) 
	 (setvar "osmode" 0)
	 (command "tilemode""0""-plot""y""""Canon iR5020.pc3""11x17""I""L""N""W""25.4,3.81""908.685,603.885""F""0.75,0""Y""M3_11x17.ctb""Y""N""N""N""N""N""Y")
	 (setvar "osmode" os)
      (princ)
)
;
(defun c:2020 ()
	 (setq os (getvar "osmode")) 
	 (setvar "osmode" 0)
	 (command "tilemode""0""-plot""y""""Canon iR2020 3er Piso.pc3""11x17""I""L""N""W""25.4,3.81""908.685,603.885""F""0.75,0""Y""M3_11x17.ctb""Y""N""N""N""N""N""Y")
	 (setvar "osmode" os)
      (princ)
)
;
(defun c:50i ()
	 (setq os (getvar "osmode")) 
	 (setvar "osmode" 0)
	 (command "tilemode""0""-plot""y""""Canon iR5020i.pc3""11x17""I""L""N""W""25.4,3.81""908.685,603.885""F""0.75,0""Y""M3_11x17.ctb""Y""N""N""N""N""N""Y")
	 (setvar "osmode" os)
      (princ)
)
;
(defun c:20i ()
	 (setq os (getvar "osmode")) 
	 (setvar "osmode" 0)
	 (command "tilemode""0""-plot""y""""Canon iR2020 3er Pisoi.pc3""11x17""I""L""N""W""25.4,3.81""908.685,603.885""F""0.75,0""Y""M3_11x17.ctb""Y""N""N""N""N""N""Y")
	 (setvar "osmode" os)
      (princ)
)
;
(defun c:50e ()
	 (setq os (getvar "osmode")) 
	 (setvar "osmode" 0)
	 (command "tilemode""0""-plot""y""""Canon iR5020_e.pc3""11x17""I""L""N""W""1,0.15""35.775,23.775""F""0.75,0""Y""M3_11x17.ctb""Y""N""N""N""N""N""Y")
	 (setvar "osmode" os)
      (princ)
)
;
(defun c:20e ()
	 (setq os (getvar "osmode")) 
	 (setvar "osmode" 0)
	 (command "tilemode""0""-plot""y""""Canon iR2020 3er Piso_e.pc3""11x17""I""L""N""W""1,0.15""35.775,23.775""F""0.75,0""Y""M3_11x17.ctb""Y""N""N""N""N""N""Y")
	 (setvar "osmode" os)
      (princ)
)


;;


;;;  PLDIET.lsp [command name: PLD]
;;;  To put lightweight PolyLines on a DIET (remove excess vertices); usually
;;;    used for contours with too many too-closely-spaced vertices.
;;;  Concept from PVD routine [posted on AutoCAD Customization Discussion
;;;    Group by oompa_l, July 2009] by Brian Hailey, added to by CAB, and
;;;    WEED and WEED2 routines by Skyler Mills at Cadalyst CAD Tips [older
;;;    routines for "heavy" Polylines that won't work on newer lightweight ones];
;;;    simplified in entity data list processing, and enhanced in other ways [error
;;;    handling, default values, join collinear segments beyond max. distance,
;;;    limit to current space/tab, account for change in direction across 0 degrees,
;;;    option to keep or eliminate arc segments] by Kent Cooper, August 2009.
;
(defun C:PLD
  (/ *error* cmde disttemp cidtemp arctemp plinc plsel pldata
  ucschanged front 10to42 vinc verts vert1 vert2 vert3)
;
  (defun *error* (errmsg)
    (if (not (wcmatch errmsg "Function cancelled,quit / exit abort"))
      (princ (strcat "\nError: " errmsg))
    ); end if
    (if ucschanged (command "_.ucs" "_prev"))
      ; ^ i.e. don't go back unless routine reached UCS change but didn't change back
    (command "_.undo" "_end")
    (setvar 'cmdecho cmde)
  ); end defun - *error*
;
  (setq cmde (getvar 'cmdecho))
  (setvar 'cmdecho 0)
  (command "_.undo" "_begin")
  (setq
    disttemp
      (getdist
        (strcat
          "\nMaximum distance between non-collinear vertices to straighten"
          (if *distmax* (strcat " <" (rtos *distmax* 2 2) ">") ""); default only if not first use
          ": "
        ); end strcat
      ); end getdist & disttemp
    *distmax*
      (cond
        (disttemp); user entered number or picked distance
        (T *distmax*); otherwise, user hit Enter - keep value
      ); end cond & *distmax*
    cidtemp
      (getangle
        (strcat
          "\nMaximum change in direction to straighten"
          (strcat ; offer prior choice if not first use; otherwise 15 degrees
            " <"
            (if *cidmax* (angtos *cidmax*) (angtos (/ pi 12)))
            ">"
          ); end strcat
          ": "
        ); end strcat
      ); end getdist & cidtemp
    *cidmax*
      (cond
        (cidtemp); user entered number or picked angle
        (*cidmax*); Enter with prior value set - use that
        (T (/ pi 12)); otherwise [Enter on first use] - 15 degrees
      ); end cond & *cidmax*
    plinc 0 ; incrementer through selection set of Polylines
  ); end setq
  (initget "Retain Straighten")
  (setq
    arctemp
      (getkword
        (strcat
          "\nRetain or Straighten arc segments [R/S] <"
          (if *arcstr* (substr *arcstr* 1 1) "S"); at first use, S default; otherwise, prior choice
          ">: "
        ); end strcat
      ); end getkword
    *arcstr*
      (cond
        (arctemp); if User typed something, use it
        (*arcstr*); if Enter and there's a prior choice, keep that
        (T "Straighten"); otherwise [Enter on first use], Straighten
      ); end cond & *arcstr*
  ); end setq
;
  (prompt "\nSelect LWPolylines to put on a diet, or press Enter to select all: ")
  (cond
    ((setq plsel (ssget '((0 . "LWPOLYLINE"))))); user-selected Polylines
    ((setq plsel (ssget "X" (list '(0 . "LWPOLYLINE") (cons 410 (getvar 'ctab))))))
      ; all Polylines [in current space/tab only]
  ); end cond
;
  (repeat (sslength plsel)
    (setq pldata (entget (ssname plsel plinc)))
    (if (/= (cdr (last pldata)) (trans '(0 0 1) 1 0)); extr. direction not parallel current CS
        ; for correct angle & distance calculations [projected onto current construction
        ; plane], since 10-code entries for LWPolylines are only 2D points:
      (progn
        (command "_.ucs" "_new" "_object" (ssname plsel plinc)) ; set UCS to match object
        (setq ucschanged T) ; marker for *error* to reset UCS if routine doesn't
      ); end progn
    ); end if
    (setq
      front ; list of "front end" [pre-vertices] entries, minus entity names & handle
        (vl-remove-if
          '(lambda (x)
            (member (car x) '(-1 330 5 10 40 41 42 210))
          ); end lambda
          pldata
        ); end removal & front
      10to42 ; list of all code 10, 40, 41, 42 entries only
        (vl-remove-if-not
          '(lambda (x)
            (member (car x) '(10 40 41 42))
          ); end lambda
          pldata
        ); end removal & 10to42
      vinc (/ (length 10to42) 4); incrementer for vertices within each Polyline
      verts nil ; eliminate from previous Polyline [if any]
    ); end setq
    (if (= *arcstr* "Straighten")
      (progn
        (setq bulges ; find any bulge factors
          (vl-remove-if-not
            '(lambda (x)
              (and
                (= (car x) 42)
                (/= (cdr x) 0.0)
              ); end and
            ); end lambda
            10to42
          ); end removal & bulges
        ); end setq
        (foreach x bulges (setq 10to42 (subst '(42 . 0.0) x 10to42)))
          ; straighten all arc segments to line segments
      ); end progn
    ); end if
    (repeat vinc
      (setq
        verts ; sub-group list: separate list of four entries for each vertex
          (cons
            (list
              (nth (- (* vinc 4) 4) 10to42)
              (nth (- (* vinc 4) 3) 10to42)
              (nth (- (* vinc 4) 2) 10to42)
              (nth (1- (* vinc 4)) 10to42)
            ); end list
            verts
          ); end cons & verts
        vinc (1- vinc) ; will be 0 at end
      ); end setq
    ); end repeat
    (while (nth (+ vinc 2) verts); still at least 2 more vertices
      (if
        (or ; only possible if chose to Retain arc segments
          (/= (cdr (assoc 42 (nth vinc verts))) 0.0); next segment is arc
          (/= (cdr (assoc 42 (nth (1+ vinc) verts))) 0.0); following segment is arc
        ); end or
        (setq vinc (1+ vinc)); then - don't straighten from here; move to next
        (progn ; else - analyze from current vertex
          (setq
            vert1 (cdar (nth vinc verts)) ; point-list location of current vertex
            vert2 (cdar (nth (1+ vinc) verts)); of next one
            vert3 (cdar (nth (+ vinc 2) verts)); of one after that
            ang1 (angle vert1 vert2)
            ang2 (angle vert2 vert3)
          ); end setq
          (if
            (or
              (equal ang1 ang2 0.0001); collinear, ignoring distance
              (and
                (<= (distance vert1 vert3) *distmax*)
                  ; straightens if direct distance from current vertex to two vertices later is
                  ; less than or equal to maximum; if preferred to compare distance along
                  ; Polyline through intermediate vertex, replace above line with this:
                  ; (<= (+ (distance vert1 vert2) (distance vert2 vert3)) *distmax*)
                (<=
                  (if (> (abs (- ang1 ang2)) pi); if difference > 180 degrees
                    (+ (min ang1 ang2) (- (* pi 2) (max ang1 ang2)))
                      ; then - compensate for change in direction crossing 0 degrees
                    (abs (- ang1 ang2)); else - size of difference
                  ); end if
                  *cidmax*
                ); end <=
              ); end and
            ); end or
            (setq verts (vl-remove (nth (1+ vinc) verts) verts))
              ; then - remove next vertext, stay at current vertex for next comparison
            (setq vinc (1+ vinc)); else - leave next vertex, move to it as new base
          ); end if - distance & change in direction analysis
        ); end progn - line segments
      ); end if - arc segment check
    ); end while - working through vertices
    (setq
      front (subst (cons 90 (length verts)) (assoc 90 front) front)
        ; update quantity of vertices for front end
      10to42 nil ; clear original set
    ); end setq
    (foreach x verts (setq 10to42 (append 10to42 x)))
      ; un-group four-list vertex sub-lists back to one list of all 10, 40, 41, 42 entries
    (setq pldata (append front 10to42 (list (last pldata))))
        ; put front end, vertex entries and extrusion direction back together
    (entmake pldata)
    (entdel (ssname plsel plinc)); remove original
    (setq plinc (1+ plinc)); go on to next Polyline
    (if ucschanged
      (progn
        (command "_.ucs" "_prev")
        (setq ucschanged nil) ; eliminate UCS reset in *error* since routine did it already
      ); end progn
    ); end if - UCS reset
  ); end repeat - stepping through set of Polylines
  (command "_.undo" "_end")
  (setvar 'cmdecho cmde)
  (princ)
); end defun - PLD



;;



;Tip1702:   Q1.LSP         Quick command list   (c)2001, Alan Lindner


(defun C:Q1  ()
  (alert
    "\nABREVIATURAS PARA MODIFICACION DE OBJETOS -TRIM, ROTATE, EXPLODE, SCALE-

BRR	rompe una linea en un solo punto con un solo click
CHW	selecciona multiples lineas, arcos y polilineas para cambiar su grosor
LINES	Carga las lineas estandar de M3, corrigiendo las que hayan sido cargadas de autocad
SF, SD	hacen un stretch con un crossing, SF con ortho y SD sin ortho
SPL2PL	Cambia todas las spline seleccionadas a polylineas hechas con segmentos de lineas,
	especificando el tama๑o deseado de segmento -spl2pl.vlx- debe cargarse por separado
UL	dibuja una sola linea a partir de dos lineas seleccionadas, con
	las propiedades de la primera linea selecionada
ARA	hace un array linear con el angulo deseado
ARD	hace un array linear de un numero de objetos distribuidos en una distancia dada	
LRA	Endereza las lineas seleccionadas -ligeramente chuecas- a que esten perfectamente
	orthogonales -horizontales o verticales-
OM	dibuja una paralela a cada lado de un objeto seleccionado 
	con la distancia deseada y en el layer seleccionado (current)
OL	hace una sola paralela de un objeto en el layer current con la distancia 
	predeterminada del offset
PLD	Edita las polilineas seleccionadas para reducir el numero de vertices

		DIMENSIONES Y EDICION DE DIMENSIONES
ALL	dibuja un dimaligned tocando una linea y dando un punto
ARCD	Hace la dimension de la longitud de un arco seleccionado
CDD	Sobreescribe el texto de multiples dimensiones con el texto que contiene (para que
	no sea automatico)
CDA	Restaura el texto de multiples dimensiones al valor del texto original
DRE	selecciona un texto, mtext, leader, dimension o block para actualizar el dimscale
	de acuerdo con ese objeto
LL	hace una leader sin texto para anotaciones, de la forma optima de m3
LLL	hace una leader empezando por el final y terminando en la punta -hecha para 
	tags de equipo-")
  (princ)
  )


;;



(defun C:Q2  ()
  (alert
    "\n			ABREVIATURAS PARA LAYERS, OBJETOS EN LAYERS

AAC	Selecciona multiples objetos para cambiar el color de sus layers rapidamente
AC	selecciona un objeto para despues cambiar multiples objetos
	al layer del objeto seleccionado
ACC	selecciona multiples objetos que desees cambiar al layer current
AD	prende todos los layers que no esten congelados
AF 	selecciona un layer para congelarlo -es el mismo layfrz-
AS	selecciona el layer que quieras hacer current
AT 	Descongela todos los layers
CCU	Copia los objetos seleccionados al layer actual en el mismo lugar
CCO	De una seleccion de objetos, se cambiaran los objetos que tengan 
	colores diferentes de bylayer, los hara bylayer y los moverแ 
	a un layer llamado segun el color que tenian originalmente y con el prefijo M3-
CLB	cambia los objetos con un crossing a color y linetype bylayer
ELA	Borra todos los objetos de un layer seleccionando un objeto de ese layer, incluye objetos
	dentro de blocks. Similar al comando laydel
LME	Cambia todos los objetos del layer de un primer objeto seleccionado -incluyendo objetos
	dentro de blocks- al layer de un segundo objeto seleccionado. Similar al comando laymrg.
LLO	selecciona un objeto del layer que quieras apagar
LK	selecciona multiples objetos para encadenar (lock) su layer
LU	selecciona multiples objetos para desencadenar (unlock) su layer
MM	Mueve todos los objetos de un layer, seleccionando un objeto de ese layer -no incluye 
	objetos en blocks
ULL	desencadena todos los layers 
XA 	seleccionar uno o varios layer a dejar prendidos y apaga todos
	los demas -el layer del primer objeto queda como layer current-")
  (princ)
  )

;;


(defun C:Q3  ()
  (alert
    "\nABREVIATURAS PARA CREACION Y EDICION DE TEXTOS, SECUENCIA DE NUMEROS, SUMAS, AREAS, Y UTILERIAS DE NUMEROS

FIXS	Cambia los textos y mtextos seleccionados al formato de texto estandar de M3 
MY,MY3	Cambia el texto de dimensiones, mtext, dtext, y atributos, desde un texto seleccionado
	de cualquiera de esos tipos de textos a otro. (solo pueden cambiarse uno por uno)
MY4	Igual que el anterior pero respeta el valor de longitud de dimensiones
MW	Ajusta el textbox de los mtext seleccionados al ancho y altura del contenido del texto
TC	cambia los textos de mayusculas a minusculas y viceversa
TJ2	justifica multiples textos con base en su punto de insercion
TMM	Escoge un texto dtext para alinear otros textos debajo de el
TRE	selecciona un Dtext y reemplaza todos los Dtext seleccionados con 
	el valor de ese primer Dtext seleccionado.
T2	Selecciona text o mtext de uno en uno para formar un solo mtext
T5	Convierte los textos seleccionados a mtext de forma individual con cuatro puntos de control
TTM	Cambia una seleccion de dtextos a un solo Mtext con cuatro puntos de control
SEQ	Dibuja una secuencia determinada de numeros, dando el punto de insercion uno por uno
SEQ2	Reemplaza los numeros seleccionados en orden (pick, crossing o fence) 
	por una secuencia de numeros determinada
SEQ3	Dibuja una secuencia de numeros con un angulo y distancia
SEQ4	Hace un arreglo de numeros en secuencia dibujados en fila hacia abajo (a 270 grados)
UMT	Une dos o mas textos de tipo text o mtext formando un solo mtext.
UT	Une dos dtextos formando un solo dtexto
INC	incrementa los numeros seleccionados (suma) con un nuevo valor, puede restar si se coloca el
	signo - en el valor a sumar
SMT,SMT2 Restaura las propiedades de los mtext que tengan caracteristicas ajustadas a sus 
	caracteristicas originales.
SBMT	Hace lo mismo que el anterior, pero en los mtext adentro de blocks.
SUML	Escribe la suma de multiples lineas, arcos y polilineas seleccionadas
SUMN	Selecciona varios numeros en dtext para encontrar la suma de ellos
TOUT	Convierte multiples textos Dtext de autocad a un archivo .txt (util para sumas en excel)")
  (princ)
  )

;;



(defun C:Q4  ()
  (alert
    "\n 	-ABREVIATURAS PARA UTILERIAS VARIAS -PLOT, OSNAP, CALCULADORA-

AU	Carga el comando Audit, para arreglar los errores de un dibujo de autocad
BA,BAD,BAL 	De una seleccion de objetos, a todos aquellos text, mtext y dimensiones les coloca un
		Background color fill, similar al textmask pero con mayores ventajas. antes de usar, 
		se debe asegurar que las dimensiones seleccionadas esten como el estilo actual.
DU	Selecciona un detalle completo para actualizar el tama๑o de los text, dtext, leaders, dimensions
	y blocks estandar de M3 de acuerdo con el dimscale actual.
ESC	Muestra en un mensaje la tabla de escalas de M3
++	calculadora con raiz cuadrada y funciones trigonometricas
SUMA 	Escoge varias polilineas cerradas para conocer la suma de las areas
SUMATODO	Escribe la suma de multiples polilineas, splines, lineas y arcos seleccionados
PDF,PDE	Crea un archivo pdf del layout actual y lo guarda con el nombre del dibujo actual y en el 
	directorio del dibujo actual
PUR	purga todo en el dibujo sin preguntar -hacer varias veces-
U2,U3,U4,U5,U6 	Cambia las unidades del dibujo a metricas y con dos, tres, cuatro, cinco y 
		seis decimales
ZR	Rota todos los textos, mtext y blocks seleccionados a Rotacion cero con respecto al UCS actual

				UTILIDADES PARA BLOCKS

ATRE	Redefine blocks con atributos sin alterar los valores existentes
B1	Cambia la escala X, Y y Z de los blocks seleccionados a 1 positivo.
B1-	Cambia la escala X, Y y Z de los blocks seleccionados a 1 respetando el valor positivo 
	o negativo que tengan (respeta blocks espejeados)
BI	Inserta en el dibujo actual todos los dibujos de un directorio seleccionado, separados 
	por una distancia.
BINCIRCLE. 	Reemplaza todos los circulos seleccionados con el block -Column Row Bubble- 
	de M3, insertado Usando el dimscale actual")
  (princ)
  )

;;


(defun C:Q5  ()
  (alert
    "\n			UTILIDADES PARA BLOCKS

BIP. 	Cambia el punto de insercion de un block.
BL0	Redefine blocks al layer 0 y color bylayer, no altera atributos
BL02	Cambia las propiedades de los objetos de todos los blocks del dibujo a bylayer. similar
	al comando setbylayer, pero sin cambiar los tipos de linea a bylayer, solo color.
BL03	Cambia las propiedades de los objetos de todos los blocks del dibujo a layer 0, no cambia
	ninguna otra propiedad de los blocks.
BRE	Usando un primer block seleccionado reemplaza todos los demas blocks seleccionados
	por el primero respetando las escalas, rotacion y puntos de insercion de lada uno.
BRO	Rota todos los blocks seleccionados con un nuevo factor escala especificado, 
	con base en el punto de inserci๓n propio de cada block.
BS	Escala todos los blocks seleccionados con un nuevo angulo especificado, con base en el
	punto de inserci๓n propio de cada block.
BU	Cambia la escala X, Y y Z de los blocks seleccionados de acuerdo con el valor del 
	dimscale actual positivo.
BU-	Cambia la escala X, Y y Z de los blocks seleccionados de acuerdo con el valor del 
	dimscale actual pero respetando sus signo positivo o negativo original en X, Y o Z
EAT 	Permite cambiar algunas propiedades de los atributos de los blocks seleccionados, 
	incluyendo el width
EDAT	cambia las propiedades de multiples atributos como altura, 
	rotacion, estilo, color, layer y valor
EXB	Explota los blocks con atributos y convierte los atributos a texto.
MSF	Aplica el factor escala de un block seleccionado a una seleccion de blocks, respetando
	puntos de inserci๓n y angulos de los blocks originales
RES	Redefine los blocks seleccionado tomado su tama๑o actual y convirtiendolos en su 
	nueva escala X,Y,z = 1
SB,SB2	picando un block se seleccionan todos los bloques que existan en el dibujo con
	el nombre del block seleccionado (todas las ocurrencias del block en el dibujo)
SMB	Esta rutina seleccionara todos los blocks con escala X negativa, o -mirrored blocks-
WBA	Hace wblocks -dibujos particulares- todos los blocks del dibujo que estemos trabajando")
  (princ)
  )


;;


(defun C:Q6  ()
  (alert
    "\n	ABREVIATURAS PARA VISTAS, UCS, SNAPS Y UTILERIAS DE SELECCION, IMAGENES Y HATCH

DVA	alinea la vista de todo el dibujo con una linea seleccionada
DVW	devuelve la vista del dibujo a la alineacion normal (world)
HPOL	Crea polilineas con los contornos de uno o varios hatch seleccionados
GT	Realiza la seleccion de un tipo de objeto en un tipo de layer de todo el dibujo.
	Es el comando Getsel
SEL	De una selecci๓n de objetos, se especifica el tipo de objetos que se requieren 
	seleccionar, como objetos de un layer especifico, objetos con un color especifico, tipo de linea, 
	objetos especificos como line, lwpolyline, insert, spline, circle, text, o cualquier otro
	y quedan seleccionados unicamente los objetos del tipo especificado.
SOL	Seleccionar un objeto para quedar seleccionados todos los objetos de 
	ese layer - no incluye objetos dentro de blocks.
LOO	comando para seleccionar los ultimos objetos creados, dandole el Numero de ultimos objetos
	creados que se quiera seleccionar

		EDICION DE OBJETOS SIMPLES EN 3D y TOPOGRAFIA

L0	hace lineas con z=0, dando un los click en puntos x,y sin importar su elevacion
FLAT	pone la coordenada z=0 de todas las lineas, arcos, polilineas, 3dpolilineas, textos
	y atributos del dibujo completo
FLATT	pone z=0 de multiples lineas y arcos seleccionados
FLAT2	pone z=0 de todos los tipos de objetos simples seleccionados.
LLP	Escribe las coordenadas X y Y y la Elevacion de un punto seleccionado con una leader")
  (princ)
  )


;;
;;


;;function to rename some blocks to a different name.
;;if old block exists, and new block doesn't exist, the old block is simply renamed.
;;if old block exists, it does nothing
;;if old block it alerts 'Block not found'.
(defun renblock (ol nl / ss i ent )
  (cond ((and (tblsearch "block" ol) (not (tblsearch "block" nl))) 
	 (command "._rename" "block" ol nl)
	)
	((and (tblsearch "block" ol)(tblsearch "block" nl))
	  (setq ss (ssget "x" (list (cons 2 ol))))
	  (setq i -1)
	   (repeat (sslength ss)
	      (setq ent (entget (ssname ss (setq i (1+ i))))
		    ent (subst (cons 2 nl) (cons 2 (cdr (assoc 2 ent))) ent)
	      )    
	      (entmod ent)
           )
	)
	((not (tblsearch "block" ol))
	  (prompt (strcat "\nBlock " ol " not found. "))
        )
  )
  (princ)
)

;;example
(defun c:renamesomeblocks ()
  (renblock "Ind Wall Ceil 1" "Ind Wall Ceil 1_old")
  (renblock "Equipment Tag2" "Equipment Tag2_old")
  (renblock "Match line sp2" "Match line sp2_old")
)

;;


;;function to rename a layer.
;;if old layer exists, and new layer doesn't exist, the old layer is simply renamed.
;;if old layer exists, and new layer is already there, it takes everything on old layer and puts them on new layer.
;;if old layer doesn't exist, it does nothing.
(defun renlay (ol nl / ss i ent )
  (cond ((and (tblsearch "layer" ol) (not (tblsearch "layer" nl))) 
	 (command "._rename" "la" ol nl)
	)
	((and (tblsearch "layer" ol)(tblsearch "layer" nl))
	  (setq ss (ssget "x" (list (cons 8 ol))))
	  (setq i -1)
	   (repeat (sslength ss)
	      (setq ent (entget (ssname ss (setq i (1+ i))))
		    ent (subst (cons 8 nl) (cons 8 (cdr (assoc 8 ent))) ent)
	      )    
	      (entmod ent)
           )
	)
	((not (tblsearch "layer" ol))
	  (prompt (strcat "\nLayer " ol " not found. "))
        )
  )
  (princ)
)

;;example
(defun c:renamesomelayers ()
  (renlay "ARSTAIR" "A-Flor-Strs")
  (renlay "ARPARTITION" "A-Flor-Tptn")
  (renlay "ARWOOD" "A-Flor-Wdwk")
  (renlay "ARFURNITURE" "A-Furn")
  (renlay "ARWINDOW" "A-Glaz")
)

;;

  Re: Replace selected blocks 
ซ Reply #7 on: December 23, 2009, 03:22:16 pm ป Reply with quote  

--------------------------------------------------------------------------------
Similar, ReName Selected Block  


Code:
;; Block ReName   by Lee McDonnell   [31.05.09]

(defun BlkReName  (oBlk nBlk / tdef)
  (if (and (setq tdef
             (tblsearch "BLOCK" oBlk))
           (snvalid nBlk))
    (progn
      (entmake
        (subst
          (cons 2 nBlk)
            (assoc 2 tdef) tdef))
      (mapcar 'entmake
        (mapcar 'entget
          (GetObj (tblobjname "BLOCK" oBlk))))
      (entmake
        (list
          (cons 0 "ENDBLK")
            (cons 8 "0"))))
    nil)
  Nme)

; Get Sub-Entities from Table Def
(defun GetObj  (bObj)
  (if (setq bObj (entnext bObj))
    (cons bObj (GetObj bObj))))

; Test Function
(defun c:renb (/ Blk Nme)
  (if (and (setq Blk (car (entsel "\nSelect Block to Change: ")))
           (eq "INSERT" (cdr (assoc 0 (setq Blk (entget Blk)))))
           (setq Nme (getstring t "\nSpecify New Block Name: ")))
    (if (BlkReName (cdr (assoc 2 Blk)) Nme)
      (entmod
        (subst
          (cons 2 Nme)
            (assoc 2 Blk) Blk))
      (princ "\n<< Block ReName Failed >>")))
  (princ)) 


;;


(defun c:res (/ acdoc blocks ss scl name def base)
  (vl-load-com)
  (setq acdoc  (vla-get-ActiveDocument (vlax-get-acad-object))
        blocks (vla-get-Blocks acdoc)
  )
  (if (ssget '((0 . "iNSERT")))
    (progn
      (vla-StartUndoMark acdoc)
      (vlax-for b (setq ss (vla-get-ActiveSelectionSet acdoc))
        (setq scl (vla-get-XScaleFactor b))
        (if (and (equal scl (vla-get-YScaleFactor b) 1e-9)
                 (/= 1.0 scl)
                 (setq name (vla-get-Name b))
                 (setq def (vla-item blocks name))
            )
          (progn
            (setq base (vla-get-Origin def))
            (vlax-for o def
              (vla-ScaleEntity o base scl)
            )
            (vla-put-XScaleFactor b 1.0)
            (vla-put-YScaleFactor b 1.0)
            (vla-put-ZScaleFactor b 1.0)
            (if (= (vla-get-HasAttributes b) :vlax-true)
              (vl-cmdf "_.attsync" "_name" name)
            )
          )
        )
      )
      (vla-Delete ss)
      (vla-Regen acdoc acAllViewports)
      (vla-EndUndoMark acdoc)
    )
  )
  (princ)
)

;;

;; Rescaleblocks.lsp
;; Rescales all blocks in the current drawing using their current size 
;; to be their now scale 1,1,1

(defun c:resall (/ acdoc blocks ss scl name def base)
  (vl-load-com)
  (setq acdoc  (vla-get-ActiveDocument (vlax-get-acad-object))
        blocks (vla-get-Blocks acdoc)
  )
  (if (ssget "X" '((0 . "iNSERT")))
    (progn
      (vla-StartUndoMark acdoc)
      (vlax-for b (setq ss (vla-get-ActiveSelectionSet acdoc))
        (setq scl (vla-get-XScaleFactor b))
        (if (and (equal scl (vla-get-YScaleFactor b) 1e-9)
                 (/= 1.0 scl)
                 (setq name (vla-get-Name b))
                 (setq def (vla-item blocks name))
            )
          (progn
            (setq base (vla-get-Origin def))
            (vlax-for o def
              (vla-ScaleEntity o base scl)
            )
            (vla-put-XScaleFactor b 1.0)
            (vla-put-YScaleFactor b 1.0)
            (vla-put-ZScaleFactor b 1.0)
            (if (= (vla-get-HasAttributes b) :vlax-true)
              (vl-cmdf "_.attsync" "_name" name)
            )
          )
        )
      )
      (vla-Delete ss)
      (vla-Regen acdoc acAllViewports)
      (vla-EndUndoMark acdoc)
    )
  )
  (princ)
)


;;




;This routine selects all instances of a block by picking one instance of that block
(defun c:sb    (/ e name n out ss x rjp-getblockname)
(vl-load-com)
(prompt "\n   Pick BLOCK to acquire its instances in the drawing...") 
  (defun rjp-getblockname (obj)
    (if    (vlax-property-available-p obj 'effectivename)
      (vla-get-effectivename obj)
      (vla-get-name obj)
    )
  )
  (if (setq x     (ssget '((0 . "INSERT")))
        x     (ssname x 0)
        name (rjp-getblockname (vlax-ename->vla-object x))
        ss     (ssget "_X" '((0 . "INSERT")))
        n     -1
        out     (ssadd)
      )
    (while (setq e (ssname ss (setq n (1+ n))))
      (if (= (rjp-getblockname (vlax-ename->vla-object e)) name)
    (ssadd e out)
      )
    )
  )
  (sssetfirst nil out)
  (princ)
)

;;

;This routine selects all instances of a block by picking one instance of that block

(defun c:sb2 (/ ent)
  (if (and(setq ent (car (entsel))) (eq "INSERT" (cdr (assoc 0 (entget ent)))))
    (sssetfirst nil (ssget "_X" (list '(0 . "INSERT") (assoc 2 (entget ent))))))
  (princ))

;;


(defun c:sel (/ a n c s k ss1 n2 n sc ent x z)
 (setvar "cmdecho" 0)
 (setq a (ssget))
 (setq n (sslength a))
  (initget 1 "C LA LT E B T")
  (setq c (getkword
    "\nSelect by...(C)Color,(LA)LAyer,(LT)LineType,(E)Entity,(B)Block,(T)Text style: "))
  (if (= "C" c) (progn
    (setq c 62)
    (setq s
      (getint "\nColor to select? "))
  ))
  (if (= "LA" c) (progn
    (setq c 8)
    (setq s
      (getstring "\nLayer to select? "))
    (setq s (strcase s))
  ))
  (if (= "LT" c) (progn
    (setq c 6)
    (setq s
      (getstring "\nLineType to select? "))
    (setq s (strcase s))
  ))
  (if (= "E" c) (progn
    (setq c 0)
    (setq s
      (getstring "\nEntity type to select? "))
    (setq s (strcase s))
  ))
  (if (= "B" c) (progn
    (setq c 2)
    (setq s
      (getstring "\nBlock name (Reference) to select? "))
    (setq s (strcase s))
  ))
  (if (= "T" c) (progn
    (setq c 7)
    (setq s
      (getstring "\nText style to select? "))
    (setq s (strcase s))
  ))
    (setq k 0)
(SETQ SS1 (SSADD))
(SETQ N2 (1- N))
(SETQ N 0)
(WHILE (>= N2 N)(SETQ ENT (ENTGET (SSNAME A N)))
(SETQ SC (CDR (ASSOC C ENT)))(IF (= SC S)(PROGN 
(SETQ ENT (CDR (ASSOC -1 ENT)))
(SETQ SS1 (SSADD ENT SS1))))
(SETQ N (1+ N)))
(SETQ X (SSLENGTH SS1))
(COMMAND "SELECT" SS1 "")
(SETQ X (ITOA X))
(SETQ Z (STRCAT "      "X" Found.")) 
(PROMPT Z)
(PRINC)
)


;;


;;This routine selects all mirrored blocks in the drawing, 
;; In other words it selects all blocks with x scale factor negative

(defun c:smb ()
  (setq cmd (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)
  (setq savosmode (getvar "OSMODE"))
  (setvar "osmode" 0)
  (setq blks (ssget "x" '((0 . "INSERT"))))
  (setq count (sslength blks))
  (setq count (sslength blks))
  (setq index 0)
  (repeat count
    (setq b1 (entget (ssname blks index)))
    (setq b2 (cdr(assoc 41 b1)))
    (setq b3 (rtos b2 2 0))
    (setq b4 (substr b3 1 1))
    (if (= b4 "-")
      (progn
 (setq c1 (cdr(assoc 10 b1)))
 (setq sset (ssget "X" '((0 . "INSERT")(-4 . "<")(41 . 0))))
 );end progn
      );end if
    (setq index (+ index 1))
    );end repeat
  (setvar "CMDECHO" cmd)
  (setvar "OSMODE" savosmode)
  (princ)
)

;;


;;  sol.LSP    Por Paulo Gil Soto   2002   gil_soto_13@hotmail.com
;; No tiene copyright, pero de perdida mandame las gracias
;; Este lisp sirve para seleccionar todos los objetos de un layer al seleccionar un objeto que
;; pertenezca a ese layer, luego se puede accesar a esos objetos con la opcion de seleccion -previous-

(defun c:sol ()
(COND (T (SETVAR "CMDECHO" 0) (SETQ L1 nil)(WHILE (= L1 nil)(SETQ L1(ENTSEL "Pick entity on layer.")))(SETQ L1 (ENTGET (CAR L1)) L1 (CDR (ASSOC 8 L1))L1 (SSGET "X" (LIST (CONS 8 L1)))) 
(COMMAND ".SELECT" L1 )(PRINC)))
)
             


;;


;;  CAB  10/09/2007
;;  Strip Mtext within blocks

(defun c:SBMT (/) (c:STRIPBLOCKMTEXT))
(defun c:StripBlockMtext (/ adoc text_style_name text_height)
  (vl-load-com)
  (setq	adoc (vla-get-activedocument (vlax-get-acad-object))) 
  (vla-startundomark adoc)
  (vlax-for blk (vla-get-blocks adoc)
    ;; Exclude model and paper spaces and  anonymus blocks
    (if (and  (equal (vla-get-IsLayout blk) :vlax-false)
              (equal (vla-get-IsXref blk) :vlax-false)
              (/= (substr (vla-get-Name blk) 1 1) "*")
	     ) 
	(vlax-for ent blk
	  (if (= (vla-get-objectname ent) "AcDbMText")
	    (progn
	      (setq str (strip_text (vla-get-textstring ent) "*"))
	      (vl-catch-all-apply 'vla-put-textstring (list ent str))
	    ) 
	  ) 
      ) 
    ) 
  ) 
  (vla-regen adoc acactiveviewport)
  (vla-endundomark adoc)
  (princ)
)


;;;=======================[ Strip_Text.lsp ]=============================
;;; Author:  Charles Alan Butler Copyrightฉ 2005-2007 
;;; Version: 2.3  Jan. 26, 2006
;;; Version: 3.0  Jun. 19, 2007
;;; Purpose: Strip format characters from text or mtext string
;;; Returns: A string  
;;; Sub Routines: -None
;;; Arguments: A string variable to remove formats from & Flag string of formats to remove
;;; Format Flag:
;;;   *    Remove All Formats found
;;;   A    Alignment
;;;   C    Color
;;;   F    Font
;;;   H    Height
;;;   L    Underscore
;;;   O    Overscore
;;;   P    Linefeed (Paragraph)  **** ??
;;;   Q    Obliquing
;;;   S    Spacing (Stacking)
;;;   t    Tabs
;;;   T    Tracking
;;;   W    Width
;;;   ~    Non-breaking Space
;;;   %    Plain Text Formatting
;;   
;;;======================================================================

(defun strip_text (str fmt / skipcnt ndx newlst char fmtcode lst_len
                   IS_MTEXT LST  NEXTCHR PT TMP)

(if (or (/= (type fmt) 'Str) (= fmt "*") (= fmt ""))
	(setq fmt (vl-string->list "AaCcFfHhLlOoPpQqSsTtQqWw~%"))
	(setq fmt (vl-string->list fmt))
)
  (setq ndx 0
        ;; "fmtcode" is a list of code flags that will end with ; 
        fmtcode
         (vl-string->list "CcFfHhTQqWwAa") ;("\C" "\F" "\H" "\T" "\Q" "\W" "\A")
  )
  (if (/= str "") ; skip if empty text ""
    (progn
      (setq lst      (vl-string->list str)
            lst_len  (length lst)
            newlst   '()
            is_mtext nil ; true if mtext
      )
      (while (< ndx lst_len)
        ;; step through text and find FORMAT CHARACTERS
        (setq char    (nth ndx lst) ; Get next character
              nextchr (nth (1+ ndx) lst)
              skipcnt 0
        )

        (cond
          ((and (= char 123) (= nextchr 92)) ; "{\" mtext code
           (setq is_mtext t
                 skipcnt 1
           )
          )

          ((and (= char 125) is_mtext) ; "}"
           (setq skipcnt 1)
          )


          ((= char 37) ; code start with "%"
           (if (null nextchr) ; true if % is last char in text
             (setq skipcnt 1)
             ;;  Dtext codes
             (if (= nextchr 37) ; %% code found 
               (if (< 47 (nth (+ ndx 2) lst) 58) ; is a number
                 (if (vl-position 37 fmt)
                 ;;  number found so fmtcode %%nnn
                 ;;  convert the nnn to a character
                 (setq skipcnt 5
                       newlst  (append newlst (list (atoi (strcat (chr (nth (+ ndx 2) lst))
                                                                  (chr (nth (+ ndx 3) lst))
                                                                  (chr (nth (+ ndx 4) lst))
                 )))))
                   ;;  keep the code in the string
                   (setq skipcnt 5
                         newlst  (append newlst (list 37 37 (nth (+ ndx 2) lst)
                                                            (nth (+ ndx 3) lst)
                                                            (nth (+ ndx 4) lst)
                   )))
                 )
                 
                 ;; else letter code, so fmtcode %%p, %%d, %%c
                 ;;  CAB note - this code does not always exist in the string
                 ;;  it is used to create the character but the actual ascii code
                 ;;  is used in the string, not the case for %%c
                 (if (vl-position 37 fmt)
                 (setq skipcnt 3
                       newlst  (append newlst (list (cond ((= (nth (+ ndx 2) lst) "p") 177)
                                                          ((= (nth (+ ndx 2) lst) "d") 176)
                                                          ((= (nth (+ ndx 2) lst) "c") 216)
                                                          ((= (nth (+ ndx 2) lst) "%")  37)
                 ))))
                 (setq skipcnt 3
                       newlst  (append newlst (list 37 37 (nth (+ ndx 2) lst)
                 )))
                 )
               ) ; endif
             ) ; endif
           ) ; endif
          ) ; end cond (= char "%"))


          ((= char 92) ; code start with "\" 
           ;;  This section processes mtext codes

           (cond
             ;; Process Coded information
             ((null nextchr) ; true if \ is last char in text
              (setq skipcnt 1)
             ) ; end cond 1

             ((member nextchr fmtcode) ; this code will end with ";"
              ;; fmtcode -> ("\C" "\F" "\H" "\T" "\Q" "\W" "\A"))
              (while (/= (setq char (nth (+ skipcnt ndx) lst)) 59)
                (setq skipcnt (1+ skipcnt))
              )
              (setq skipcnt (1+ skipcnt))
             ) ; end cond 


             ;; found \U then get 7 character group
             ((= nextchr 85) (setq skipcnt (+ skipcnt 7)))

             ;; found \M then get 8 character group
             ((= nextchr 77) (setq skipcnt (+ skipcnt 8)))

             ;; found \P then replace with CR LF 13 10
             ;;  debug do not add CR LF, just remobe \P
             ((= nextchr 80) ; "\P"
              (if (vl-position 80 fmt)
                (setq newlst  (append newlst '(32))
                      ;ndx     (+ ndx 1)
                      skipcnt 2
                )
              )
             ) ; end cond 


             ((= nextchr 123) ; "\{" normal brace
              (setq ndx (+ ndx 1))
             ) ; end cond 

             ((= nextchr 125) ; "\}" normal brace
              (setq ndx (+ ndx 1))
             ) ; end cond 

             ((= nextchr 126) ; "\~" non breaking space
              (if (vl-position 126 fmt)
                (setq newlst (append newlst '(32)) ; " "
                      skipcnt 2) ; end cond 9
              )
             )

             ;; 2 character group \L \l \O \o
            ((member nextchr '(76 108 79 111)) 
              (setq skipcnt 2)
             ) ; end cond 

             ;;  Stacked text format as "[ top_txt / bot_txt ]"
             ((= nextchr 83) ; "\S"
              (setq pt  (1+ ndx)
                    tmp '()
              )
              (while
                (not
                  (member
                    (setq tmp (nth (setq pt (1+ pt)) lst))
                    '(94 47 35) ; "^" "/" "#" seperator
                  )
                )
                 (setq newlst (append newlst (list tmp)))
              )
              (setq newlst (append newlst '(47))) ; "/"
              (while (/= (setq tmp (nth (setq pt (1+ pt)) lst)) 59) ; ";"
                (setq newlst (append newlst (list tmp)))
              )
              (setq ndx     pt
                    skipcnt (1+ skipcnt)
              )
             ) ; end cond 


           ) ; end cond stmt  Process Coded information
          ) ; end cond  (or (= char "\\")

        ) ; end cond stmt
        ;;  Skip format code characters
        (if (zerop skipcnt) ; add char to string
          (setq newlst (append newlst (list char))
                ndx    (+ ndx 1)
          )
          ;;  else skip some charactersPLOTTABS

          (setq ndx (+ ndx skipcnt))
        )

      ) ; end while Loop
    ) ; end progn
  ) ; endif
  (vl-list->string newlst) ; return the stripped string
) ; end defun
;;(princ
;;  "\nStripBlockMtext loaded. type \"STRIPBLOCKMTEXT\" or \"SBMT\" to start"
;;)


;;


;===============================================================================
;     SEQ - Automatic alpha/numeric text incrementing
;===============================================================================

(defun C:SEQ ()

    (prompt "\nSEQUENCE - Automatic alpha/numeric text incrementing")

    (setq OLD_CMDECHO (getvar "CMDECHO"))
    (setvar "CMDECHO" 0)

    (initget 1 "A N")
    (setq INC_TYPE (getkword "\nIncremento Numerico o Alfabetico <A or N> ? "))

    (if (equal INC_TYPE "N")
        (progn
           (setq INC_VALUE  (getint "\nCual es el primer Numero ? "))
           (setq INC_AMOUNT (getint "\nDe cuanto es el Incremento  ? "))
        )
        (progn
           (setq INC_VALUE  (getstring "\nCual es la primera Letra ? "))
           (setq INC_AMOUNT 1)
        )
    )

    (initget 1 "L R C M")
    (setq JUSTIFY  (getkword "\nJustificacion <Left Right Center Middle> ? "))

    (setq HEIGHT   (getdist "\nAltura   ? "))

    (setq ROTATION (getreal "\nRotacion ? "))

    (prompt "\nAhora indica puntos donde va el texto.....")

    (while (setq PT (getpoint "\nLugar del Texto: "))
           (if (equal INC_TYPE "N")
               (progn
                   (setq OUT_STRING (itoa INC_VALUE))
                   (setq INC_VALUE      (+        INC_VALUE  INC_AMOUNT))
               )
               (progn
                   (setq OUT_STRING       INC_VALUE)
                   (setq INC_VALUE (chr (+ (ascii INC_VALUE) INC_AMOUNT)))
               )
           )

           (if (equal JUSTIFY "L")
               (command ".TEXT"         PT HEIGHT ROTATION OUT_STRING)
               (command ".TEXT" JUSTIFY PT HEIGHT ROTATION OUT_STRING)
           )

    )

    (setvar "CMDECHO" OLD_CMDECHO)
    (prompt "\nProgram complete.")
    (princ)
)



;;


;SEQ2.LSP: Ets lets you convert a series of text objects into a set of
;         sequential numbers.
;____________________________________________________________________________

 (defun c:seq2 ( / txt v1 v2 v3 tp snew new old unt prec)
 (setvar "cmdecho" 0)
 (if (not *uglb)(setq *uglb 2))
 (if (not *prglb)(setq *prglb 0))
 (if (not *incglb)(setq *incglb 1.0))
          (princ "Pick numbers to be changed in order of increment: ")
          (setq v1 (ssget '((0 . "TEXT")) ))
          (initget "Scientific Decimal Engin Arch")
          (setq tp (getkword "\nEnter unit type Scientific/Decimal/Engin/Arch <D>: "))
          (cond
                ((= tp "Scientific")(setq unt 1))
                ((= tp "Decimal")(setq unt 2))
                ((= tp "Engin")(setq unt 3))
                ((= tp "Arch")(setq unt 4))
                ((not tp) (setq unt *uglb))
          )
          (setq uglb unt)
          (setq prec (getint (strcat "\nEnter precision value <" (itoa *prglb) ">: ")))
          (if (not prec)
              (setq prec *prglb)(setq *prglb prec)
          )
          (setq inc (getreal (strcat "\nEnter increment value <" (rtos *incglb 2 2) ">: ")))
          (if (not inc)
              (setq inc *incglb)(setq *incglb inc)
          )
          (setq new (getreal "\nEnter new beginning value: "))
          (setq v2 0)
             (if (and v1 new)
                 (while (< v2 (sslength v1))
                        (setq snew (rtos new unt prec))
                        (setq snew (cons 1 snew))
                        (setq txt (ssname v1 v2))
                        (setq old (assoc 1 (setq v3 (entget txt))))
                        (entmod (subst snew old v3))
                        (entupd txt)
                        (setq new (+ new inc))
                        (setq v2 (+ v2 1))
                 )
             )
(princ)
)


;;


(Defun C:SEQ3 ()
       (Setvar "Cmdecho" 0)
       (Setq A (Getint "\nStarting number: "))
       (Setq B (Getint "\nEnding number: "))
       (Setq P1 (Getpoint "\nStarting point: "))
       (Setq C (Getdist P1 "\nDistance between numbers: "))
       (Setq A1 (Getangle P1 "\nAngle to run numbers: "))
       (Setq D (Getvar "textsize"))
       (If (> A B)
           (Setq E -1)
           (Setq E 1)
       )
                (Repeat (+ 1 (Abs (- A B)))
                        (Setq F (Itoa A))
                        (Command "Text" P1 D 0 F)
                        (Setq A (+ A E))
                        (Setq P1 (Polar P1 A1 C))
                )
       (princ)
)


;;


(defun C:SEQ4 (/ n1 n2 s1 d1 t1)
   (defun dtr (a)
     (* pi (/ a 180.0))
   )
   (graphscr)
   (setq n1 (getint "\nCual es el primer numero: "))
   (setq n2 (getint "\nCual es el ultimo numero: "))
   (setq s1 (getreal "\nDe a cuanto es la separacion: "))
   (setq d1 (getpoint "\nPica el primer punto... "))
   (setq t1 (getvar "textsize"))
      (while (>= n2 n1)
         (command "text"  "r" d1 t1 0 n1)
         (setq d1 (polar d1 (dtr 270) s1))
         (setq n1 (+ n1  1))
      )
)



;;


;|

StripMtext 4 BETA
Main function that performs the format removal written by John Uhden
All other supporting code and user interface written by Steve Doman

-------------------------------------------------------------------

Notes for Beta 4A 7/18/2005:

1) New file names are: StripMtext.lsp & StripMtext.dcl
2) Added support for Acad Tables.
3) Fields inside Mtext objects seem to process ok, but need more testing.
4) Currently working on Tab removal.  DCL shows Tabs, but it doesn't work yet.
5) The report which prints a count of objects processed is temporarily disabled.
6) Please email bug reports, comments, or annoyances to: sdoman@qwest.net
7) Should I add support for the new fangled ArcLength Dimensions?

|;

(defun c:StripMtext (/
                     ;; Local Functions
                     *error*
                     AcceptButton
                     ClearAllButton
                     MainDialog
                     SelectAllButton
                     Setup
                     StripMtext
                     Unformat
                     ;; Local Variables
                     dcl_id
                     dclfilemsg
                     dclfilename
                     dialogmsg
                     keylist
                     modcnt
                     save
                     settings
                     space
                     ss
                     tilemsg
                     versionmsg
                    )
  ;;
  ;; Define Local functions
  ;;
  (defun *error* (msg)
    (if docobj
      (vla-endundomark docobj)
    )
    (cond ((member
             msg
             '("Function cancelled" "quit / exit abort" "console break")
           )
          )
          ((princ (strcat " Error: " msg)))
    )
    (princ)
  )
  (defun SelectAllButton ()
    (foreach key keylist (set_tile key on))
    (set_tile "error" "")
    (mode_tile "accept" 2)
  )
  (defun ClearAllButton ()
    (foreach key keylist (set_tile key off))
    (set_tile "error" tilemsg)
  )
  (defun AcceptButton ()
    ;; Build string to be passed later to the Unformat function
    ;; Strcat key character for each checkmarked key in DCL dialog
    (setq settings "")
    (foreach key keylist
      (if (= (get_tile key) on)
        (setq settings (strcat settings key))
      )
    )
    ;; If no keys are checkmarked, show error message
    ;; Else if "Save Settings" key is checked, save settings to registry
    (if (= settings "")
      (set_tile "error" tilemsg)
      (progn
        (if (= (get_tile "save") on)
          (progn (vl-registry-write StripMtextKey "Settings" settings)
                 (vl-registry-write StripMtextKey "Save" on)
          )
          (vl-registry-write StripMtextKey "Save" off)
        )
        (if (= (strlen settings) (length keylist))
          (setq settings "*")
        )
      ) ;_progn
    ) ;_if
  )
  (defun MainDialog (/ status done)
    ;; Display DCL checkbox default values
    ;; and define checkbox callbacks
    (set_tile "save" save)
    (foreach key keylist
      (if (vl-string-search key settings)
        (set_tile key on)
      )
      (action_tile key "(set_tile \"error\" \"\" )")
    )
    ;; Define button callbacks
    (action_tile "clearall" "(ClearAllButton)")
    (action_tile "selectall" "(SelectAllButton)")
    (action_tile "accept" "(AcceptButton)(done_dialog 1)")
    (action_tile "cancel" "(done_dialog 0)")
    (setq status (start_dialog))
    (unload_dialog dcl_id)
    ;; Return key used to close dialog
    ;; If status = 0 , then Cancel button hit
    ;; If status = 1 , then Accept button hit
    status
  )
  ;;
  ;; I am very grateful to John Uhden for supplying us
  ;; with the following function which he authored.
  ;; (It has been modified slightly for this routine)
  ;;
  ;; More of John Uhden's work can be found at:
  ;; http://www.cadlantic.com
  ;;
  ;; -------------------------------------------------
  ;;
  ;; Unformat by John Uhden
  ;; Primary function to perform the format stripping:
  ;;
  ;; Arguments:
  ;;   Mtext   - the text string to be Unformatted
  ;;   Formats - a string containing some or all of 
  ;;             the following characters:
  ;;
  ;;     A - Alignment
  ;;     C - Color
  ;;     F - Font
  ;;     H - Height
  ;;     L - Underscore
  ;;     O - Overscore
  ;;     P - Linefeed (Paragraph)
  ;;     Q - Obliquing
  ;;     S - Spacing (Stacking)
  ;;     t - Tabs
  ;;     T - Tracking
  ;;     W - Width
  ;;     ~ - Non-breaking Space
  ;;   Optional Formats -
  ;;     * - All formats
  ;; Returns:
  ;;   nil  - if not a valid Mtext object
  ;;   Text - the Mtext textstring with none, some, or all
  ;;          of the formatting removed, depending on what
  ;;          formats were present and what formats were
  ;;          specified for removal.
  ;;
  (defun UnFormat (Mtext Formats / All Format1 Format2 Text Str)
    (and
      Mtext
      Formats
      (= (type Mtext) 'STR)
      (= (type Formats) 'STR)
      (setq Formats (strcase Formats))
      (setq Text "")
      (setq All t)
      (if (= Formats "*")
        (setq Formats "S"
              Format1 "\\[LO`~]"
              Format2 "\\[ACFHQTW]"
              Format3 "\\P"
        )
        (progn (setq Format1 ""
                     Format2 ""
                     Format3 ""
               )
               (foreach item '("L" "O" "~")
                 (if (vl-string-search item Formats)
                   (setq Format1 (strcat Format1 "`" item))
                   (setq All nil)
                 )
               )
               (if (= Format1 "")
                 (setq Format1 nil)
                 (setq Format1 (strcat "\\[" Format1 "]"))
               )
               (foreach item '("A" "C" "F" "H" "Q" "T" "W")
                 (if (vl-string-search item Formats)
                   (setq Format2 (strcat Format2 item))
                   (setq All nil)
                 )
               )
               (if (= Format2 "")
                 (setq Format2 nil)
                 (setq Format2 (strcat "\\[" Format2 "]"))
               )
               (if (vl-string-search "P" Formats)
                 (setq Format3 "\\P")
                 (setq Format3 nil
                       All nil
                 )
               )
               t
        )
      )
      (while (/= Mtext "")
        (cond
          ((wcmatch (strcase (setq Str (substr Mtext 1 2))) "\\[\\{}]")
           (setq Mtext (substr Mtext 3)
                 Text  (strcat Text Str)
           )
          )
          ((and All (wcmatch (substr Mtext 1 1) "[{}]"))
           (setq Mtext (substr Mtext 2))
          )
          ((and Format1 (wcmatch (strcase (substr Mtext 1 2)) Format1))
           (setq Mtext (substr Mtext 3))
          )
          ((and Format2 (wcmatch (strcase (substr Mtext 1 2)) Format2))
           (setq
             Mtext (substr Mtext (+ 2 (vl-string-search ";" Mtext)))
           )
          )
          ((and Format3 (wcmatch (strcase (substr Mtext 1 2)) Format3))
           (if (or (= " " (substr Text (strlen Text)))
                   (= " " (substr Mtext 3 1))
               )
             (setq Mtext (substr Mtext 3))
             (setq Mtext (substr Mtext 3)
                   Text  (strcat Text " ")
             )
           )
          )
          ((and (vl-string-search "S" Formats)
                (wcmatch (strcase (substr Mtext 1 2)) "\\S")
           )
           (setq Str   (substr Mtext 3 (- (vl-string-search ";" Mtext) 2))
                 Text  (strcat Text (vl-string-translate "#^\\" "/^\\" Str))
                 Mtext (substr Mtext (+ 4 (strlen Str)))
           )
          )
          (1
           (setq Text  (strcat Text (substr Mtext 1 1))
                 Mtext (substr Mtext 2)
           )
          )
        )
      )
    )
    Text
  )
  (defun StripMtext
         (ss / docobj cnt mtextobj objname txtprop txtvalue errobj)
    ;;  Repeat for each entity in pickset:
    ;;  Get Mtext textstring and pass it to the Unformat function
    ;;  Put returned stripped textstring back into entity
    ;;  If successful, increment count of modified entities
    (vl-load-com)
    (setq docobj (vla-get-activedocument (vlax-get-acad-object))
          cnt    0
          modcnt 0
    )
    (vla-startundomark docobj)
    (repeat (sslength ss)
      (setq mtextobj (vlax-ename->vla-object (ssname ss cnt))
            objname  (vla-get-objectname mtextobj)
      )
      (cond
        ((= objname "AcDbMText")
         (setq txtvalue (vla-get-textstring mtextobj)
               errobj   (vl-catch-all-apply
                          'vla-put-textstring
                          (list mtextobj (Unformat txtvalue settings))
                        )
         )
        )
        ((member objname
                 '("AcDb3PointAngularDimension"
                   "AcDbAlignedDimension"
                   "AcDbAngularDimension"
                   "AcDb2LineAngularDimension"
                   "AcDbDiametricDimension"
                   "AcDbOrdinateDimension"
                   "AcDbRadialDimension"
                   "AcDbRotatedDimension"
                  )
         )
         (setq txtvalue (vla-get-textoverride mtextobj)
               errobj   (vl-catch-all-apply
                          'vla-put-textoverride
                          (list mtextobj (Unformat txtvalue settings))
                        )
         )
        )
        ((= objname "AcDbTable")
         (setq rowmax (vla-get-rows mtextobj)
               colmax (vla-get-columns mtextobj)
               row    0
               col    0
         )
         (while (< row rowmax)
           (while (< col colmax)
             (if (= (vla-getcelltype mtextobj row col) actextcell)
               (progn
                 (setq txtvalue (vla-gettext mtextobj row col))
                 (if (/= txtvalue "")
                   (progn (setq errobj (vl-catch-all-apply
                                         'vla-settext
                                         (list mtextobj
                                               row
                                               col
                                               (Unformat txtvalue settings)
                                         )
                                       )
                          )
                   ) ;_progn
                 ) ;_if ""
               ) ;_progn
             ) ;_if acTextCell
             (setq col (1+ col))
           ) ;_while col
           (setq row (1+ row))
           (setq col 0)
         ) ;_while row
        )
        (t (alert "StripMtext 4 Beta: Condition Failed"))
      ) ;_cond
      (setq modcnt (if (not (vl-catch-all-error-p errobj))
                     (1+ modcnt)
                   )
            cnt    (1+ cnt)
      )
    ) ;_repeat
    (vla-endundomark docobj)
  )
  (defun Setup ()
    (setq ;; --- Set Constants ---
          ;; Toggles for dcl checkbox status
          on            "1"
          off           "0"
          ;; Error messages
          tilemsg       "Select one or more settings or press \"Cancel\" to exit"
          versionmsg    "StripMtext error:\nRequires AutoCAD 2000 or higher"
          dialogmsg     "StripMtext error:\nUnable to load dialog"
          dclfilemsg    "StripMtext error:\nCannot load DCL file \"StripMtext.dcl\""
          ;; DCL file
          dclfilename   "StripMtext.dcl"
          ;; List of dcl checkbox key names
          ;; Must correspond with DCL keys and Unformat function 
          keylist       '("A" "C" "F" "H" "L" "O" "P" "Q" "S" "T" "W" "~")
          ;; Registry path for storing user's settings
          StripMtextkey "HKEY_CURRENT_USER\\SOFTWARE\\StripMtext\\"
          ;; --- Set Defaults ---
          ;; Get user's default settings from registry if exist
          ;; If user has not saved default settings, use coded default
          settings      (cond
                          ((vl-registry-read StripMtextKey "Settings"))
                          ((vl-registry-write StripMtextKey "Settings" "CFH"))
                        )
          save          (cond ((vl-registry-read StripMtextKey "Save"))
                              ((vl-registry-write StripMtextKey "Save" "1"))
                        )
    )
  )
;;;
;;; Main Program
;;;
  (princ "\nStripMtext v4.A BETA")
  (Setup)
  (cond ;; Running in Acad 2000 or above
        ((< (atoi (getvar "acadver")) 15) (alert versionmsg))
        ;; Find dcl file
        ((< (setq dcl_id (load_dialog dclfilename)) 0)
         (alert dclfilemsg)
        )
        ;; Succesful pickset
        ((not
           (setq ss (ssget ":L" '((0 . "MTEXT,DIMENSION,ACAD_TABLE"))))
         )
         (princ "\nNothing selected")
        )
        ;; Successful dcl load
        ((not (new_dialog "stripmtext" dcl_id)) (alert dialogmsg))
        ;; If user exits dcl using Accept button, process pickset
        ((= (MainDialog) 1)
         ;; Process
         (StripMtext ss)
         ;; display count of stripped objects
;;;       (princ
;;;         (strcat
;;;          "\nStripped: " (itoa modcnt) " mtext object"
;;;          (if (= 1 modcnt) " " "s ")
;;;         )
;;;       )
        )
  ) ;_cond
  (princ)
) ;_defun c:StripMtext

;;(princ
;;  "\nStripMtext v4.A BETA loaded. type \"SMT\" to start"
;;)
(princ)

(defun C:SMT ()
	(C:STRIPMTEXT)
	(princ)
	)


;;


;; smt2.lsp 
;; This routine will strip selected mtext objects
;; (delete all forced properties from mtext objects)
;; http://www.hispacad.com/foro/viewtopic.php?t=20463

(defun c:smt2 ( / textos indice caso lent contenido inicio final subcadena)
   (setq textos (ssget '((0 . "MTEXT")) )
        indice 0
   )
   (while (setq caso (ssname textos indice))
      (setq lent (entget caso)
           contenido (cdr (assoc 1 lent))
           indice (1+ indice)
      )
      (while (and caso (setq inicio (vl-string-search "\\" contenido)))
         (if (setq final (vl-string-position (ascii ";" ) contenido inicio))
             (setq  subcadena (substr contenido (1+ inicio) (1+ (- final inicio)))
              contenido (vl-string-subst "" subcadena contenido))
          (setq caso nil)
         )
      )
      (entmod (subst (cons 1 contenido) (assoc 1 lent) lent))
   )
)

;;

;===============================================================================
;     SQ - Dibuja una hoja de papel o un plano con una escala de Ploteo.
;===============================================================================
; Creado por Marco V. Gil --- UNI-SON ---modificado por Paulo Gil Soto Agregado tama๑o de hoja y margen de 1.2 cms.
;
(defun C:SQ (/)
;  (prompt "Dibujara una hoja de la siguiente medida ")
   (setq os (getvar "osmode"))
   (setq T (getreal "\Hoja tamano carta= 1, Plano de 90x60  = 2 "))     
   (setq pt1 (getpoint "\nDame el punto de insercion : "))
   (setq pt2 (polar pt1 (DTR 90.0) 1))
   (setq pt3 (polar Pt2 (DTR 0.0) 1))
   (if (= T 1)
       (command "osnap""none""pline" pt1 "@21.6,0" "@0,27.9" "@-21.6,0" "close" "move" "l" "" "0,0" "0,0" "pline" pt3 "@19.6,0" "@0,25.9" "@-19.6,0" "close" "move" "p" "l" "" "0,0" "0,0")
       (command "osnap""none""pline" pt1 "@90,0" "@0,60" "@-90,0" "close" "move" "l" "" "0,0" "0,0" "pline" pt3 "@88,0" "@0,58" "@-88,0" "close" "move" "p" "l" "" "0,0" "0,0")
   )
   (setq esc (getreal "\nEscala a plotear=  1 : "))
   (setq escplt (/ esc 100))
   (command "scale" "p" "" pt1 escplt)
;  (command "STYLE" "RS" "ROMANS" "0" "0.95" "0" "N" "N" "N")
;  (setq HT (* ESCPLT 2))
   (setq PLT (/ ESC 1000))
   (setvar "osmode" os)
;  (command "TEXT" "S" "RS" (polar pt1 (/ pi 4) HT) HT "0" "ESCALA DE PLOTEO: 1=") 
;  (command "TEXT" "S" "RS" (polar pt1 (/ pi 82.8916) 37.2779) HT "0" (rtos PLT 4))
   (prompt " Escala de ploteo: 1=") (princ (rtos PLT 2))
   (princ)

)



;;


 ; SUMA - Sums up pline areas picked in acres or sf
 

;/////////////////////////////////////////////////////////////////
(DEFUN
    C:SUMA () ; sum up pline areas picked
   (SETQ AREA 0)
   (if (= adjfac nil)
      (progn
         (print "(setq adjfac #) to divide area by adjustment for vertical scale differences.")
         (setq adjfac 1.0)
      )
   )
   (IF (= DISPACSF NIL)
      (PROGN (INITGET 0 "1 2") (SETQ DISPACSF (GETKWORD "\n1. Acres or 2. Square Feet: ")))
   )
   (PRINC "\nSelect Circles or Enclosed Polylines: ")
   (setq picks (ssget))
   (setq len (sslength picks))
   (while (> len 0)
      (setq E (ssname picks (- len 1)))
      (setq MA (entget E))
      (SETQ MA (ASSOC 0 MA))
      (SETQ MA (CDR MA))
      (IF (OR (= mA "POLYLINE") (= mA "LWPOLYLINE") (= mA "CIRCLE"))
         (PROGN (COMMAND "AREA" "O" E) (setq a (getvar "AREA")) (SETQ AREA (+ AREA A)))
      )
      (setq len (- len 1))
   )
   (setq area (/ area adjfac))
   (setq acre (/ area 43560.0))
   (if (= rv nil)
      (setq rv (getint "\nRound values to how many places? "))
   )
   (PRINC "\n\n Total Area: ")
   (princ acre)
   (princ " ac    ")
   (princ area)
   (princ " sf")
   (IF (= "1" DISPACSF)
      (SETQ AREATEXT (RTOS ACRE 2 rv))
   )
   (IF (= "2" DISPACSF)
      (SETQ AREATEXT (RTOS AREA 2 rv))
   )
   (txt areatext (cadr (grread 1)) 0)
   (mlast)
   (princ)
)


;;


; TOTLEN.LSP    c.2000  Rob Herr    robherr@hotmail.com
; 'Add selected lines, plines, splines, and arcs for total length'
; v 1.0    10 Feb 2000
; 
;  ___________________________________________________________________
;  |     PERMISSION HEREBY GRANTED BLA, BLA, BLA, TO MODIFY ETC.     |
;  |   As long as name and email remain with the original program    |
;  | unaltered. However I would like to know of any bugs or problems |
;  |   that arise with the actual program. And of course I take no   |
;  |  responsibility for lost limbs, auto repair bills, mechanical   |
;  |         or electronic difficulties, or snake venom.             |
;  -------------------------------------------------------------------

(defun tlines ()
  (setq lbeg (cdr (assoc '10 ent)))
  (setq lend (cdr (assoc '11 ent)))
  (setq llen (distance lbeg lend))
  (setq tlen (+ tlen llen))
  (ssdel sn ss1)
)

(defun tarcs ()
 (setq cen (cdr (assoc '10 ent)))
 (setq rad (cdr (assoc '40 ent)))
 (setq dia (* rad 2.0))
 (setq circ (* (* rad pi) 2.0))
 (setq sang (cdr (assoc '50 ent)))
 (setq eang (cdr (assoc '51 ent)))
 (if (< eang sang)
  (setq eang (+ eang (* pi 2.0)))
 )
 (setq tang (- eang sang))
 (setq tang2 (* (/ tang pi) 180.0))
 (setq circ2 (/ tang2 360.0))
 (setq alen (* circ2 circ))
 (setq tlen (+ tlen alen))
 (princ)
 (ssdel sn ss1)
)

(defun tplines ()
 (command "area" "e" sn)
 (setq tlen (+ tlen (getvar "perimeter")))
 (ssdel sn ss1)
)

(defun tsplines ()
 (command "area" "e" sn)
 (setq tlen (+ tlen (getvar "perimeter")))
 (ssdel sn ss1)
)

(DEFUN C:SUMATODO (/ tlen ss1 sn sn2 et)
 (setq cmdecho (getvar "cmdecho"))
 (setvar "cmdecho" 0)
 (setq tlen 0)  
 (prompt "\nSelect only those entities you want for total length: ")
 (setq ss1 (ssget))
 (while (> (sslength ss1) 0)
  (setq sn (ssname ss1 0))
  (setq ent (entget sn))
  (setq et (cdr (assoc '0 ent)))
  (cond
   ((= et "LINE") (tlines))
   ((= et "ARC") (tarcs))
   ((= et "LWPOLYLINE") (tplines))
   ((= et "POLYLINE") (tplines))
   ((= et "SPLINE") (tsplines))
   ((or
     (/= et "LINE")
     (/= et "ARC")
     (/= et "LWPOLYLINE")
     (/= et "POLYLINE")
     (/= et "SPLINE")
    )
    (ssdel sn ss1)
   )
  )
 )
 (alert (strcat "\nThe Total Length of Selected Lines, Polylines, and Arcs is: " (rtos tlen 2 2)))
 (setvar "cmdecho" cmdecho)
 (prompt "\nBy Rob Herr   robherr@hotmail.com  ")
 (princ)
)



;;


 ; SUML - Sums up the lengths of ;///////////////////////////////////////////////////////////////
 ; lines, plines, and arcs picked

;///////////////////////////////////////////////////////////////
 ; SUM ENTITIES - BY ALEX KONIECZKA
 ; THIS ROUTINE WILL RETURN THE LENGTHS OF ALL LINES, POLYLINES, OR ARCS
 ; PICKED AS A SELECTION SET. IT IS GREAT FOR DOING TAKE-OFFS ON SIGNING
 ; AND MARKING PLANS OR GETING INFORMATION ON DISTANCES IN A DRAWING.
 ;
(DEFUN
    C:suml ()
   (if (= rv nil)
      (setq rv (getint "\nRound values to how many places? "))
   )
   (setq total 0)
   (setq d1 0)
   (setq d2 0)
   (princ "\nSelect your lines, arcs, or polylines: ")
   (setq picks (ssget))
   (setq len (sslength picks))
   (while (> len 0)
      (setq it (entget (ssname picks (- len 1)))) ;LINE
      (if (= (cdr (assoc 0 it)) "LINE")
         (progn
            (setq D1 (CDR (assoc 10 it)))
            (setq D2 (CDR (assoc 11 it)))
            (setq total (+ total (distance d1 d2)))
         )
      )
      (if (= (cdr (assoc 0 it)) "ARC")
         (progn
            (command "PEDIT" (ssname picks (- len 1)) "" "")
            (command "area" "e" "L" "EXPLODE" "L" "")
            (setq t (getvar "perimeter"))
            (setq total (+ t total))
         )
      )
      (if (or (= (cdr (assoc 0 it)) "LWPOLYLINE") (= (cdr (assoc 0 it)) "POLYLINE"))
         (progn
            (command "area" "e" (ssname picks (- len 1)))
            (setq t (getvar "perimeter"))
            (setq total (+ t total))
         )
      )
      (setq len (- len 1))
   ) ; END cond
   (SETQ TOTAL (RTOS TOTAL 2 2))
   (princ "\nTotal: ")
   (princ total)
   (princ "\nPick starting point of new text or old text to be changed: ")
   (if (setq pp (entsel))
      (progn
         (setq pt (nth 0 (cdr pp)))
         (command "change" pt "" "" "" "" "" "" total) ; for text without a fixed height
 ;(command "change" pt "" "" "" "" "" total); for text with a fixed height
      )
      (progn (txt total (cadr (grread 1)) 0) (mlast))
   )
   (princ)
)


;;


; ----------------------------------------------------------------------
;               (Returns the sum of selected line objects)
;            Copyright (C) 1997 DotSoft, All Rights Reserved
;                      Website: www.dotsoft.com
; ----------------------------------------------------------------------
; DISCLAIMER:  DotSoft Disclaims any and all liability for any damages
; arising out of the use or operation, or inability to use the software.
; FURTHERMORE, User agrees to hold DotSoft harmless from such claims.
; DotSoft makes no warranty, either expressed or implied, as to the
; fitness of this product for a particular purpose.  All materials are
; to be considered ‘as-is’, and use of this software should be
; considered as AT YOUR OWN RISK.
; ----------------------------------------------------------------------

; watch out for lines with diffent elevations at the endpoints

(defun C:SUML2 ()
  (setq sset (ssget '((0 . "LINE"))))
  (if sset
    (progn
      (setq tot 0.0)
      (setq num (sslength sset) itm 0)
      (while (< itm num)
        (setq hnd (ssname sset itm))
        (setq ent (entget hnd))
        (setq pt1 (cdr (assoc 10 ent)))
        (setq pt2 (cdr (assoc 11 ent)))
        (setq dis (distance pt1 pt2))
        (setq tot (+ tot dis))
        (setq itm (1+ itm))
      )
      (princ (strcat "\nTotal Distance = " (rtos tot)))
    )
  )
  (princ)
)


;;



; Mean.lsp  by Alex Konieczka 
 ; 
 ; Finds the sum of numbers picked from the screen - good for end area volumes
 ;

(defun
    c:sumn ()
   (if (= rv nil)
      (setq rv (getint "\nRound values to how many places? "))
   )
   (setq
      total 0
      mm 0.0
   )
   (princ "\nSelect your numbers: ")
   (setq picks (ssget))
   (setq len (sslength picks))
   (while (> len 0)
      (setq num (entget (ssname picks (- len 1))))
      (if (= (cdr (assoc 0 num)) "TEXT")
         (progn
            (setq num (assoc 1 num))
            (setq num (cdr num)) ;/////////////
            (setq ss nil)
            (setq scount 1)
            (while (< scount (+ (strlen num) 1))
               (setq q (substr num scount 1))
               (setq scount (+ scount 1))
               (if (= q ",")
                  (princ)
                  (progn
                     (if (= ss nil)
                        (setq ss q)
                        (setq ss (strcat ss q))
                     )
                  )
               )
            )
            (setq num ss) ;/////////////
            (setq num (atof num))
            (setq
               total (+ total num)
               mm    (1+ mm)
            )
            (princ "\nSub Total: ")
            (princ total)
            (print)
         )
      )
      (setq len (- len 1))
   )
   (SETQ
      TOTAL (/ total mm)
      TOTAL (RTOS TOTAL 2 RV)
   )
   (princ "\nTotal: ")
   (princ total)
   (princ "\nPick starting point of new text or old text to be changed: ")
   (if (setq pp (entsel))
      (progn
         (setq pt (nth 0 (cdr pp)))
         (command "change" pt "" "" "" "" "" "" total) ; for text without a fixed height
 ;(command "change" pt "" "" "" "" "" total); for text with a fixed height
      )
      (progn (txt total (cadr (grread 1)) 0) (mlast))
   )
   (princ)
)


;;
;;


;;syb.lsp sinchronizes selected blocks

(defun c:syb (/ *error* doc oldc ss sel)
  (vl-load-com)
 
  (defun *error* (msg)
    (if doc (vla-EndUndoMark doc))
    (if oldc (setvar "CMDECHO" oldc))
    (if (not
          (wcmatch
            (strcase msg) "*BREAK,*CANCEL*,*EXIT*"))
      (princ (strcat "\n** Error: " msg " **")))
    (princ))
 
  (setq doc (vla-get-ActiveDocument
              (vlax-get-acad-object)))
  (setq oldc (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)
  (prompt "\nSelect Blocks to synchronize... ")
  (if (setq ss (ssget '((0 . "INSERT"))))
    (progn
      (vla-StartUndoMark doc)
      (vlax-for Obj (setq sel (vla-get-ActiveSelectionSet doc))        
        (if (eq :vlax-true (vla-get-HasAttributes Obj))
          (command "_.attsync" "_Name"
            (vlax-get-property Obj
              (if (eq :vlax-true
                    (vla-get-isDynamicBlock Obj)) 'EffectiveName 'Name)))))
      (vla-delete sel)
      (vla-EndUndoMark doc)))
 
  (setvar "CMDECHO" oldc)
  (princ))


;;


;;;คบฐ`ฐบค๘,ธธ,๘คบฐ`ฐบค๘,ธธ,๘คบฐ`ฐบค๘,ธธ,๘คบฐ`ฐบค๘,ธธ,๘คบฐ`ฐบค๘,ธธ,๘คบฐ`ฐบค๘,ธธ,;;;
;;;๘,ธธ,๘คบฐ`ฐบค๘,ธธ,๘คบฐ`ฐบค๘,ธธ,๘คบฐ`ฐบค๘,ธธ,๘คบฐ`ฐบค๘,ธธ,๘คบฐ`ฐบค๘,ธธ,คบฐ`ฐบค;;;
;;                                                                               ;;
;;                   --=={  Text 2 MText Upgraded  }==--                         ;;
;;                                                                               ;;
;;  Similar to the Txt2MTxt Express Tools function, but allows the user          ;;
;;  additional control over where the text is placed in the resultant MText.     ;;
;;                                                                               ;;
;;  The user can pick MText or DText, positioning such text using one of two     ;;
;;  modes: "New Line" or "Same Line". The Modes can be switched by pressing      ;;
;;  Space between picks.                                                         ;;
;;                                                                               ;;
;;  The user can also hold shift and pick text to keep the original text in      ;;
;;  place, and press "u" between picks to undo the last text pick.               ;;
;;                                                                               ;;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=;;
;;                                                                               ;;
;;  FUNCTION SYNTAX:  T2M                                                        ;;
;;                                                                               ;;
;;  Notes:-                                                                      ;;
;;  --------                                                                     ;;
;;  Shift-click functionality requires the user to have Express Tools installed. ;;
;;                                                                               ;;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=;;
;;                                                                               ;;
;;  AUTHOR:                                                                      ;;
;;                                                                               ;;
;;  Copyright ฉ Lee McDonnell, September 2009. All Rights Reserved.              ;;
;;                                                                               ;;
;;      { Contact: Lee Mac @ TheSwamp.org, CADTutor.net }                        ;;
;;                                                                               ;;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=;;
;;                                                                               ;;
;;  VERSION:                                                                     ;;
;;                                                                               ;;
;;    ๘ 1.0   ~ค~   27th September 2009   ~ค~   บ First Release                  ;;
;;...............................................................................;;
;;    ๘ 1.1   ~ค~   29th September 2009   ~ค~   บ Minor Bug Fixes                ;;
;;...............................................................................;;
;;    ๘ 1.2   ~ค~   29th September 2009   ~ค~   บ Fixed Alignment Bug            ;;
;;                                              บ Added Code to match Height     ;;
;;...............................................................................;;
;;    ๘ 1.3   ~ค~      1st October 2009   ~ค~   บ Added option to Copy Text.     ;;
;;...............................................................................;;
;;    ๘ 1.4   ~ค~      1st October 2009   ~ค~   บ Added option to Undo Last text ;;
;;                                                Selection                      ;;
;;...............................................................................;;
;;    ๘ 1.5   ~ค~       30th March 2010   ~ค~   บ Modified code to allow for     ;;
;;                                                mis-click.                     ;;
;;                                              บ Updated UndoMarks.             ;;
;;...............................................................................;;
;;    ๘ 1.6   ~ค~       15th April 2010   ~ค~   บ MText objects now have correct ;;
;;                                                width.                         ;;
;;                                              บ Accounted for %%U symbol.      ;;
;;...............................................................................;;
;;    ๘ 1.7   ~ค~       16th April 2010   ~ค~   บ Fixed %%U bug.                 ;;
;;                                              บ Trimmed Spaces when in         ;;
;;                                                'Same Line' mode.              ;;
;;                                              บ Fixed Width when Undo is used. ;;
;;                                              บ Allowed Shift-Click to keep    ;;
;;                                                first text object selected.    ;;
;;...............................................................................;;
;;    ๘ 1.8   ~ค~         10th May 2010   ~ค~   บ Allowed for UCS variations.    ;;
;;                                              บ Matched initial text rotation. ;;
;;...............................................................................;;
;;    ๘ 1.9   ~ค~         21st May 2010   ~ค~   บ Added ability to use           ;;
;;                                                SelectionSet to select text.   ;;
;;...............................................................................;;
;;    ๘ 2.0   ~ค~         7th June 2010   ~ค~   บ Fixed offset from cursor with  ;;
;;                                                rotated text.                  ;;
;;...............................................................................;;
;;                                                                               ;;
;;=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=;;
;;                                                                               ;;
;;;คบฐ`ฐบค๘,ธธ,๘คบฐ`ฐบค๘,ธธ,๘คบฐ`ฐบค๘,ธธ,๘คบฐ`ฐบค๘,ธธ,๘คบฐ`ฐบค๘,ธธ,๘คบฐ`ฐบค๘,ธธ,;;;
;;;๘,ธธ,๘คบฐ`ฐบค๘,ธธ,๘คบฐ`ฐบค๘,ธธ,๘คบฐ`ฐบค๘,ธธ,๘คบฐ`ฐบค๘,ธธ,๘คบฐ`ฐบค๘,ธธ,คบฐ`ฐบค;;;


(defun c:t2 ( /  ;; -={ Local Functions }=-

                   *error* align_Mt Get_MTOffset_pt
                   GetTextWidth ReplaceUnderline

                  ;; -={ Local Variables }=-

                  CODE
                  DATA DOC
                  ELST ENT ET
                  FORMFLAG
                  GRDATA
                  LHGT LLST
                  MLST MSG
                  NOBJ NSTR
                  OBJ
                  SHFT SPC
                  TENT TOBJ TEXTSS
                  UFLAG UNDER
                  WLST
              
                  ;; -={ Global Variables }=-

                  ; *T2M_mode*  ~  Mode for line addition
)
  
  (vl-load-com)


;     --=={ Sub Functions  }==--      ;



  ;; -={ Error Handler }=-

  (defun *error* (err)
    (and uFlag (vla-EndUndoMark doc))
    (and tObj  (not (vlax-erased-p tObj)) (vla-delete tObj))
    
    (if eLst (mapcar (function entdel)
               (vl-remove-if (function null) eLst)))
    
    (or (wcmatch (strcase err) "*BREAK,*CANCEL*,*EXIT*")
        (princ (strcat "\n** Error: " err " **")))
    (princ))

  
 ;...............................................................................;
  

  (defun align_Mt (obj / al)
    (cond (  (eq "AcDbMText" (vla-get-ObjectName obj))
             (vla-get-AttachmentPoint obj))

          (  (eq "AcDbText" (vla-get-ObjectName obj))
             (setq al (vla-get-Alignment obj))

             (cond (  (<= 0 al 2) (1+ al))
                   (  (<= 3 al 5) 1)
                   (t (- al 5))))))
  

 ;...............................................................................;
  

  (defun Get_MTOffset_pt ( obj pt / miP maP al )
    (vla-getBoundingBox obj 'miP 'maP)
    (setq miP (vlax-safearray->list miP)
          maP (vlax-safearray->list maP))

    (setq al (vla-get-AttachmentPoint obj) r (vla-get-rotation obj))

    (cond (  (or (eq acAttachmentPointTopLeft   al)
                 (eq acAttachmentPointTopCenter al)
                 (eq acAttachmentPointTopRight  al))
           
             (polar pt (- r (/ pi 2.)) (vla-get-Height obj)))

          (  (or (eq acAttachmentPointMiddleLeft   al)
                 (eq acAttachmentPointMiddleCenter al)
                 (eq acAttachmentPointMiddleRight  al))
           
             (polar pt (- r (/ pi 2.)) (+ (vla-get-Height obj)
                                          (/ (- (cadr maP) (cadr miP)) 2.))))
  
          (  (or (eq acAttachmentPointBottomLeft   al)
                 (eq acAttachmentPointBottomCenter al)
                 (eq acAttachmentPointBottomRight  al))
           
             (polar pt (- r (/ pi 2.)) (+ (vla-get-Height obj)
                                          (- (cadr maP) (cadr miP)))))))
  

 ;...............................................................................;
  

  (defun GetTextWidth (obj / tBox eLst)
    (cond (  (eq "AcDbText" (vla-get-objectname obj))

             (setq eLst (entget  (vlax-vla-object->ename obj))
                   tBox (textbox
                          (subst
                            (cons 1 (strcat "..." (cdr (assoc 1 eLst))))
                              (assoc 1 eLst) eLst)))

             (- (caadr tBox) (caar tBox)))

          (  (vla-get-Width obj))))
  

 ;...............................................................................;
  

  (defun ReplaceUnderline (str / i under)
    (if (vl-string-search "%%U" (strcase Str))
      (progn
        (while (and (< i (strlen Str))
                    (setq i (vl-string-search "%%U" (strcase Str) i)))
          (if under
            (setq Str (strcat (substr Str 1 i) "\\l" (substr Str (+ i 4))) i (+ i 4) under nil)
            (setq Str (strcat (substr Str 1 i) "\\L" (substr Str (+ i 4))) i (+ i 4) under t  )))
        
        (if under (setq str (strcat str "\\l")))))
    
    str)
  



;     --=={ Main Function  }==--

  

  (setq doc (vla-get-ActiveDocument
              (vlax-get-acad-object))

        spc (if (or (eq AcModelSpace (vla-get-activespace doc))
                    (eq :vlax-true   (vla-get-MSpace doc)))

              (vla-get-modelspace doc)
              (vla-get-paperspace doc)))
  
  (setq Et
      (and (vl-position "acetutil.arx" (arx))
           (not
             (vl-catch-all-error-p
               (vl-catch-all-apply
                 (function (lambda nil (acet-sys-shift-down))))))))

  (or *T2M_Mode* (setq *T2M_Mode* 0))
  (setq mLst '("New Line " "Same Line"))

  (while
    (progn
      (setq ent (car (entsel "\nSelect Text/MText [Shift-Click keep original]: ")))
      (and et (setq shft (acet-sys-shift-down)))
      
      (cond (  (not ent)
               (princ "\n** Nothing Selected **"))
            
            (  (not (wcmatch (cdr (assoc 0 (entget ent))) "*TEXT"))
               (princ "\n** Object is not Text **")))))

  (setq uFlag (not (vla-StartUndoMark doc)))

  (setq tObj
    (vla-AddMText spc
      
      (vla-get-InsertionPoint
        (setq obj (vlax-ename->vla-object ent))) (GetTextWidth obj)
      
          (ReplaceUnderline (vla-get-TextString obj))))

  (foreach p '(InsertionPoint Layer Color StyleName Height)
    (vlax-put-property tObj p
      (vlax-get-property obj p)))

  (vla-put-rotation tObj
    (if (eq "AcDbText" (vla-get-ObjectName obj))
      (- (vla-get-rotation obj)
         (angle '(0. 0. 0.)
           (trans (getvar 'UCSXDIR) 0 (trans '(0. 0. 1.) 1 0 t))))
      (vla-get-rotation obj)))
  
  (vla-put-AttachmentPoint tObj (align_Mt obj))

  (or (and shft
           (setq eLst (cons nil eLst)))
      (and (entdel ent)
           (setq eLst (cons ent eLst))))

  (princ (eval (setq msg '(strcat "\n~ค~  Current Mode: " (nth *T2M_mode* mLst) " ~ค~   [Space to Change]"
                                  "\n~ค~ Select Text to Convert [Shift-Click keep original] [Undo] <Place MText> ~ค~"))))

  (while
    (progn
      (setq grdata (grread 't 15 2)
            code   (car grdata) data (cadr grdata))

      (cond (  (and (= 5 code) (listp data))

               (vla-put-InsertionPoint tObj
                 (vlax-3D-point
                   (Get_MTOffset_pt tObj (trans data 1 0)))) t)

            (  (and (= 3 code) (listp data))

               (if (and (setq tEnt (car (nentselp data)))
                        (wcmatch (cdr (assoc 0 (entget tEnt))) "*TEXT"))
                 
                 (AddtoMTextSelection tEnt)

                 (progn
                   (vla-put-Visible tObj :vlax-false)

                   (if (setq textss (GetSelectionSet "\nPick Corner Point: " data '((0 . "TEXT,MTEXT"))))
                     (
                       (lambda ( i )
                         (while (setq e (ssname textss (setq i (1+ i))))
                           (AddtoMTextSelection e)
                         )
                         (princ (eval msg))
                       )
                       -1
                     )
                     (princ (strcat "\n** No Text/MText Selected **" (eval msg)))
                   )
                   
                   (vla-put-Visible tObj :vlax-true) t
                 )
               )
            )

            (  (= 25 code) nil)

            (  (= 2 code)

               (cond (  (= 13 data) nil)
                     
                     (  (= 32 data)
                      
                        (setq *T2M_mode* (- 1 *T2M_mode*))
                        (princ (eval msg)))
                     
                     (  (vl-position data '(85 117))
                      
                        (if (< 1 (length eLst))
                          (progn
                            
                            (vla-put-TextString tObj
                              (substr (vla-get-TextString tObj) 1 (car lLst)))

                            (vla-put-Width tObj (car wLst))
                            
                            (if (car eLst) (entdel (car eLst)))
                            (setq eLst (cdr eLst) lLst (cdr lLst) wLst (cdr wLst)) t)
                          
                          (progn
                            (princ "\n** Nothing to Undo **")
                            (princ (eval msg)))))                           
                            
                     (t )))

            (t ))))

  (setq uFlag (vla-EndUndoMark doc))
  (princ))

(princ)


;;                             End of Program Code                               ;;



(defun AddtoMTextSelection ( tEnt / nStr nObj formflag )
  (setq lLst (cons (strlen (vla-get-TextString tObj)) lLst)
        wLst (cons (vla-get-Width tObj) wLst))
  
  (setq nStr
     (vla-get-TextString
       (setq nObj
          (vlax-ename->vla-object tEnt))) formflag nil)
  
  (vla-put-Width tObj
    ((if (= *T2M_mode* 1) + max)
      (vla-get-Width tObj) (GetTextWidth nObj)))
  
  (if (not (or (eq (vla-get-Color nObj) (vla-get-Color tObj))
             (vl-position (vla-get-Color nObj) '(255 0))))
    
    (setq nStr (strcat "\\C" (itoa (vla-get-Color nObj)) ";" nStr) formflag t))
  
  (setq nStr (ReplaceUnderline nStr))
  
  (if (not (or (eq (vla-get-Height nObj) (vla-get-Height tObj))
             (and lHgt (eq (vla-get-Height nObj) lHgt))))
    
    (setq nStr (strcat "\\H" (rtos (/ (float (vla-get-Height nObj))
                                      (cond (lHgt) ((vla-get-Height tObj)))) 2 2)  "x;" nStr)
      lHgt (vla-get-Height nObj) formflag t))
  
  (if (not (eq (vla-get-StyleName nObj) (vla-get-StyleName tObj)))
    (setq nStr
       (strcat "\\F" (vla-get-fontfile
                       (vla-item
                         (vla-get-TextStyles doc)
                         (vla-get-StyleName nObj))) ";" nStr) formflag t))
  
  (if formflag (setq nStr (strcat "{" nStr "}")))
  
  (vla-put-TextString tObj
    (strcat
      (vla-get-TextString tObj)
      (if (zerop *T2M_mode*)
        (strcat "\\P" nStr)
        (strcat " "  (vl-string-left-trim (chr 32) nStr)))))
  
  (vla-update tObj)
  (or (and et (acet-sys-shift-down)
        (setq eLst (cons nil eLst)))
    (and (entdel tEnt)
      (setq eLst (cons tEnt eLst)))) t)


(defun GetSelectionSet ( str pt filter / gr data pt1 pt2 lst )
  (princ str)

  (while (and (= 5 (car (setq gr (grread t 13 0)))) (listp (setq data (cadr gr))))
    (redraw)

    (setq pt1 (list (car data) (cadr pt) (caddr data))
          pt2 (list (car pt) (cadr data) (caddr data)))

    (grvecs
      (setq lst
        (list
          (if (minusp (- (car data) (car pt))) -30 30)
          pt pt1 pt pt2 pt1 data pt2 data
        )
      )
    )
  )

  (redraw)

  (ssget (if (minusp (car lst)) "_C" "_W") pt data filter)
(setvar "orthomode" 0)
)


;;

;changes text to individual mtext by Carl B.

;;

  (DEFUN mw5 (mtexts / mtexts idx ename EntData dxf42 dxf43 EntData1)
    (IF mtexts
      (PROGN
 (SETQ idx 0)
 (REPEAT (SSLENGTH mtexts)
   (SETQ ename (SSNAME mtexts idx))
   (SETQ EntData (ENTGET ename '("*")))
   (SETQ dxf42 (* (CDR (ASSOC 42 EntData))1.07))
   (SETQ dxf43 (CDR (ASSOC 43 EntData)))
   (SETQ EntData1
   (ENTMOD (SUBST (CONS 41 dxf42) (ASSOC 41 EntData) EntData))
   )
   (ENTMOD (SUBST (CONS 46 dxf43) (ASSOC 46 EntData1) EntData1)
   )
   (SETQ idx (1+ idx))
 )    ;progn
      )     ;repeat
      (PRINC "\n Null Selection!")
    )     ;if
    (PRINC)
  )
  

;;

(defun c:t5 ()
  (setq Tset (ssget '((0 . "*TEXT"))))   ;filter text in selection set
                    
  (setq    Setlen (sslength Tset)       ;setq number of entties in selection set, setq count(er) to 0
    Count  0
  )
                    
  (repeat SetLen                             ;repeat setq times
                    
    (setq Ename (ssname Tset Count))   ;setq ename to be the "0..." entity in selection set Tset
                   
    (command "_txt2mtxt" Ename "")


    (setq Count (+ 1 Count))                  ; add 1 to Count(er)

                 
  )                ; Repeat  

  (mw5 Tset)

  (princ)

(setvar "orthomode" 0)

)


;;


;;; ------------------------------------------------------------------------
;;;	RotateObjects.lsp v1.5
;;;
;;;	Copyrightฉ March 2009
;;;	Alan J. Thompson (alanjt)
;;;	alanjt@gmail.com
;;;
;;;	Permission to use, copy, modify, and distribute this software
;;;	for any purpose and without fee is hereby granted, provided
;;;	that the above copyright notice appears in all copies and
;;;	that both that copyright notice and the limited warranty and
;;;	restricted rights notice below appear in all supporting
;;;	documentation.
;;;
;;;	User is able to set rotation of selected objects (blocks, text,
;;;	mtext, multileaders), based on rotation of selected object
;;;	(ie: block, text, mtext, multileader, line, polyline, arc).
;;;	After objects have been rotated to specified angle, the user
;;;	has the additional option to rotate the objects 180ฐ.
;;;	In addition to rotating objects along selected object, the user
;;;	also has the option to pick/type in an angle, set selected
;;;	objects to a zero rotation (relative to current UCS) or select
;;;	a nested object (block or xref) to use for rotation.
;;;
;;;	Many thanks to: Stig Madsen, Mark Thoms, Charles Alan Butler
;;;	and Tim Willey. Without the opportunity to look at bits of
;;;	their coding and use some of their subroutines, I would never
;;;	have figured everything out.
;;;
;;;	Revision History:
;;;
;;;	v1.1 (03.16.09): Added subroutines "XrefNameList" & "lst2str"
;;;			 and coding to filter Xrefs from selection set
;;;			 for objects to be rotated.
;;;
;;;	v1.2 (04.02.09): Added subroutine "AT:AnnoReset" and coding to
;;;			 reset any objects if annotative.
;;;
;;;	v1.2 (04.20.09): Replaced 'AT:SS->List' subroutine, after complete rewrite.
;;;
;;;	v1.3 (05.06.09): Removed coding to only select objects in current tab, to
;;;			 eliminate issues with not being able to select objects in
;;;			 modelspace through paperspace.
;;;
;;;	v1.4 (08.07.09): Added additional coding to select old-school Polylines.
;;;
;;;	v1.5 (10.13.09): Changed Rotate 180ฐ option at end to give user option
;;;			 to rotate object(s) an additional 90ฐ, 180ฐ or 270ฐ.
;;;
;;; ------------------------------------------------------------------------

(defun c:ta (/ *error* getSegment getEnt_kWords getNent_kWords
                        AT:UCSAngle XrefNameList lst2str AT:AnnoReset
                        AT:SS->List AT:Undo #XrefList #UCSAngle #OldCmdecho
                        #OldUCSFollow #OldUCS #Entsel #Angle #Object #ObjectName
                        #PntList #PntEnd #PntBeg #ssget #ssList #Answer #Flip
                       )

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SUBROUTINES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;error handler
  (defun *error* (msg)
    (if #OldUCS
      (vl-cmdf "_.ucs" 3 "" #OldUCS "")
    ) ;_ if
    (if #OldUCSFollow
      (setvar "ucsfollow" #OldUCSFollow)
    ) ;_ if
    (if #OldCmdecho
      (setvar "cmdecho" #OldCmdecho)
    ) ;_ if
    (AT:Undo "V" "E")
    (if
      (not
        (member
          msg
          '("console break" "Function cancelled" "quit / exit abort")
        ) ;_ member
      ) ;_ not
       (princ (strcat "\nError: " msg))
    ) ;_ if
  ) ;_ defun



;;; credit Stig Madsen 
  (defun getSegment (obj pt / cpt eParam stParam)
    (cond
      ((setq cpt (vlax-curve-getClosestPointTo obj pt))
       (setq eParam (fix (vlax-curve-getEndParam obj)))
       (if (= eParam
              (setq stParam (fix (vlax-curve-getParamAtPoint obj cpt)))
           ) ;_ =
         (setq stParam (1- stParam))
         (setq eParam (1+ stParam))
       ) ;_ if
       (list eParam
             (vlax-curve-getPointAtParam obj stParam)
             (vlax-curve-getPointAtParam obj eParam)
       ) ;_ list
      )
    ) ;_ cond
  ) ;_ defun


;;; entsel with keywords, missed pick handling & object filtering
;;; by: Stig Madsen
  (defun getEnt_kWords (msg lst kwords / ent)
    (setvar "ERRNO" 0)
    (and (not msg) (setq msg "\nSelect object: "))
    (while (and (not ent) (/= (getvar "ERRNO") 52))
      (and kwords (initget kwords))
      (cond
        ((setq ent (entsel msg))
         (cond
           ((= (type ent) 'STR))
           ((vl-consp ent)
            (if (not (member (cdr (assoc 0 (entget (car ent)))) lst))
              (setq ent nil)
            ) ;_ if
           )
         ) ;_ cond
        )
      ) ;_ cond
    ) ;_ while
    ent
  ) ;_ defun


;;; nentsel with keywords, missed pick handling & object filtering
;;; by: Stig Madsen (i just changed it to nentsel)
  (defun getNent_kWords (msg lst kwords / ent)
    (setvar "ERRNO" 0)
    (and (not msg) (setq msg "\nSelect object: "))
    (while (and (not ent) (/= (getvar "ERRNO") 52))
      (and kwords (initget kwords))
      (cond
        ((setq ent (nentsel msg))
         (cond
           ((= (type ent) 'STR))
           ((vl-consp ent)
            (if (not (member (cdr (assoc 0 (entget (car ent)))) lst))
              (setq ent nil)
            ) ;_ if
           )
         ) ;_ cond
        )
      ) ;_ cond
    ) ;_ while
    ent
  ) ;_ defun


;;; Retreive current UCS angle
  (defun AT:UCSAngle (/ xdir)
    (setq xdir (getvar "ucsxdir"))
    (atan (cadr xdir) (car xdir))
  ) ;_ defun


;;; List of Xref Names
;;; xref retreival credit: Tim Willey
;;; written by: Alan J. Thompson, 3.16.09
  (defun XrefNameList (/ #list)
    (vlax-for i (vla-get-filedependencies
                  (vla-get-activedocument (vlax-get-acad-object))
                ) ;_ vla-get-filedependencies
      (if (= (vla-get-feature i) "Acad:XRef")
        (setq
          #list (cons (vl-filename-base (vla-get-filename i)) #list)
        ) ;_ setq
      ) ;_ if
    ) ;_ vlax-for
    (vl-sort #list '<)
  ) ;_ defun


;;; lST2STR
;;; Returns a string which is the concatenation of a list and a  separator
;;;
;;; Arguments
;;; str = the string
;;; sep = the separator pattern
  (defun lst2str (lst sep)
    (if (cadr lst)
      (strcat (vl-princ-to-string (car lst))
              sep
              (lst2str (cdr lst) sep)
      ) ;_ strcat
      (vl-princ-to-string (car lst))
    ) ;_ if
  ) ;_ defun


;;; Check if an object is annotative & reset
  (defun AT:AnnoReset (#Entity / #Check)
    (if
      (and
        (setq #Check (cdr (assoc 360 (entget #Entity))))
        (setq #Check (dictsearch #Check "AcDbContextDataManager"))
        (setq #Check (dictsearch
                       (cdr (assoc -1 #Check))
                       "AcDb_AnnotationScales"
                     ) ;_ dictsearch
        ) ;_ setq
        (setq #Check (assoc 350 #Check))
      ) ;_ and
       (vl-cmdf "_.annoreset" #Entity "")
    ) ;_ if
  ) ;_ defun


;;; ------------------------------------------------------------------------
;;;	AT:SS->List
;;;	(SubRoutine)
;;;
;;;	Copyrightฉ 04.20.09
;;;	Alan J. Thompson (alanjt)
;;;	alanjt@gmail.com
;;;
;;;	Permission to use, copy, modify, and distribute this software
;;;	for any purpose and without fee is hereby granted, provided
;;;	that the above copyright notice appears in all copies and
;;;	that both that copyright notice and the limited warranty and
;;;	restricted rights notice below appear in all supporting
;;;	documentation.
;;;
;;;	Convert selection set (SSGET) to list of either, VLA objects
;;;	or enames.
;;;
;;;	Arguments:
;;;	#Selection - Selection set (ssget)
;;;	#VlaList - List type output
;;;		   T: list will be VLA objects
;;;		   nil: list will be Ename objects
;;;
;;;	Examples:
;;;	(AT:SS->List (ssget) t)
;;;	(setq ss (ssget)) (AT:SS->List ss nil)
;;;
;;;	Revision History:
;;;
;;; ------------------------------------------------------------------------


  (defun AT:SS->List (#Selection #VlaList / #List)
    (and #Selection
         (setq #List (vl-remove-if
                       'listp
                       (mapcar 'cadr (ssnamex #Selection))
                     ) ;_ vl-remove-if
         ) ;_ setq
         (if #VlaList
           (setq #List (mapcar 'vlax-ename->vla-object #List))
         ) ;_ if
    ) ;_ and
    #List
  ) ;_ defun


;;; ------------------------------------------------------------------------
;;;	AT:Undo.lsp v1.0
;;;	(SubRoutine)
;;;
;;;	Copyrightฉ 03.23.09
;;;	Alan J. Thompson (alanjt)
;;;	alanjt@gmail.com
;;;
;;;	Permission to use, copy, modify, and distribute this software
;;;	for any purpose and without fee is hereby granted, provided
;;;	that the above copyright notice appears in all copies and
;;;	that both that copyright notice and the limited warranty and
;;;	restricted rights notice below appear in all supporting
;;;	documentation.
;;;
;;;	Undo "BEGIN" and "END" options, with choice of using "COMMAND"
;;;	or "VLA". User inputs coding choice (Command or VLA) and the
;;;	choice to issue an 'undo begin' or 'undo end'.
;;;
;;;	Arguments:
;;;	#CommandVLA - Option to use command or VLA for undo marking.
;;;		      ("V" for VLA, "C" for Command)
;;;	#BeginEnd - Option to issue an 'Undo Begin' or 'Undo End'.
;;;		    ("B" for Begin, "E" for End).
;;;
;;;	Examples:
;;;	(defun c:TEST ( / p1 p2 )
;;;          (AT:Undo "C" "B")
;;;          (and
;;;            (setq p1 (getpoint "\nPoint 1: "))
;;;            (setq p2 (getpoint p1 "\nPoint 2: "))
;;;            (command "_.line" p1 p2 ""
;;;                     "_.circle" p1 2
;;;                     "_.circle" p2 2))
;;;            (AT:Undo "C" "E"))
;;;
;;;	Revision History:
;;;
;;; ------------------------------------------------------------------------

  (defun AT:Undo (#CommandVLA #BeginEnd / #OldCmdecho)
    (if
      (and
        (member (strcase #CommandVLA) (list "C" "V"))
        (member (strcase #BeginEnd) (list "B" "E"))
      ) ;_ and
       (cond
         ;; COMMAND Undo Options
         ((eq "C" (strcase #CommandVLA))
          (setq #OldCmdecho (getvar "cmdecho"))
          (setvar "cmdecho" 0)
          (cond
            ;; Undo Begin
            ((eq "B" (strcase #BeginEnd)) (command "_.undo" "_be"))
            ;; Undo End
            ((eq "E" (strcase #BeginEnd)) (command "_.undo" "_e"))
          ) ;_ cond
          (setvar "cmdecho" #OldCmdecho)
         )
         ;; VLA Undo Options
         ((eq "V" (strcase #CommandVLA))
          (cond
            ;; Undo Begin
            ((eq "B" (strcase #BeginEnd))
             (vla-StartUndoMark
               (vla-get-ActiveDocument
                 (vlax-get-Acad-Object)
               ) ;_ vla-get-ActiveDocument
             ) ;_ vla-StartUndoMark
            )
            ;; Undo End
            ((eq "E" (strcase #BeginEnd))
             (vla-EndUndoMark
               (vla-get-ActiveDocument
                 (vlax-get-Acad-Object)
               ) ;_ vla-get-ActiveDocument
             ) ;_ vla-EndUndoMark
            )
          ) ;_ cond
         )
       ) ;_ cond
    ) ;_ if
  ) ;_ defun



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; MAIN ROUTINE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  (vl-load-com)

;;; Startup Operations
  (AT:Undo "V" "B")
  (if (XrefNameList)
    (setq #XrefList (lst2str (XrefNameList) ","))
    (setq #XrefList "")
  ) ;_ if
  (setq #UCSAngle (AT:UCSAngle))
  (setq #OldCmdecho (getvar "cmdecho"))
  (setq #OldUCSFollow (getvar "ucsfollow"))
  (setvar "cmdecho" 0)
  (setvar "ucsfollow" 0)
  (if
    (eq (getvar "worlducs")
        0
    ) ;_ eq
     (progn
       (setq #OldUCS (getvar "ucsxdir"))
       (vl-cmdf "_.ucs" "")
     ) ;_ progn
     (setq #OldUCS nil)
  ) ;_ if


  ;; Select something
  (if
    (setq #Entsel
           (getEnt_kWords
             "\nSelect object for alignment [\"Angle\" \"Xref/Nested\" \"Zero/East\"]: "
             (list "TEXT" "MTEXT" "INSERT" "MULTILEADER" "LINE" "POLYLINE" "ARC"
                   "LWPOLYLINE"
                  ) ;_ list
 ;_ list
 ;_ list
 ;_ list
 ;_ list
 ;_ list
 ;_ list
 ;_ list
             "Angle East Nested Xref Zero"
           ) ;_ getEnt_kWords
    ) ;_ setq
     (progn
       ;; Xref/Nested Option Selected, Select a Nested Object
       (if
         (member #Entsel
                 (list "Nested" "Xref")
         ) ;_ member
          (progn
            (setq #Entsel nil)
            (if
              (setq #Entsel
                     (getNent_kWords
                       "\nSelect nested object for alignment [\"Angle\" \"Zero/East\"]: "
                       (list "TEXT" "MTEXT" "INSERT" "MULTILEADER" "LINE"
                             "POLYLINE" "ARC" "LWPOLYLINE"
                            ) ;_ list
 ;_ list
 ;_ list
 ;_ list
 ;_ list
 ;_ list
 ;_ list
 ;_ list
                       "Angle East Zero"
                     ) ;_ getNent_kWords
              ) ;_ setq
               (if
                 (listp #Entsel)
                  (setq #Entsel (list (car #Entsel)
                                      (cadr #Entsel)
                                ) ;_ list
                  ) ;_ setq
               ) ;_ if
            ) ;_ if
          ) ;_ progn
       ) ;_ if
       (cond
         ;; Angle to be Entered or Picked
         (
          (eq #Entsel
              "Angle"
          ) ;_ eq
          (setq #Angle
                 (getangle "\nSpecify rotation angle: ")
          ) ;_ setq
         )
         ;; Zero Rotation for Selected Objects
         (
          (member #Entsel
                  (list "East" "Zero")
          ) ;_ member
          (setq #Angle #UCSAngle)
         )
         ;; Object was Selected
         (
          (vl-consp #Entsel)
          (progn
            (setq #Object     (vlax-ename->vla-object (car #Entsel))
                  #ObjectName (vlax-get-property #Object 'ObjectName)
            ) ;_ setq
            (cond
              ;; Polyline or 3dPolyline Selected
              (
               (member #ObjectName
                       (list "AcDbPolyline" "AcDb2dPolyline" "AcDb3dPolyline")
               ) ;_ member
               (if
                 (setq #PntList
                        (getSegment #Object (last #Entsel))
                 ) ;_ setq
                  (setq #Angle
                         (angle (cadr #PntList)
                                (caddr #PntList)
                         ) ;_ angle
                  ) ;_ setq
               ) ;_ if
              )
              ;; Line Selected
              (
               (eq #ObjectName
                   "AcDbLine"
               ) ;_ eq
               (setq #Angle (vlax-get-property #Object 'Angle))
              )
              ;; Arc Selected
              (
               (eq #ObjectName
                   "AcDbArc"
               ) ;_ eq
               (setq #PntEnd (vlax-safearray->list
                               (vlax-variant-value
                                 (vla-get-EndPoint #Object)
                               ) ;_ vlax-variant-value
                             ) ;_ vlax-safearray->list
                     #PntBeg (vlax-safearray->list
                               (vlax-variant-value
                                 (vla-get-StartPoint #Object)
                               ) ;_ vlax-variant-value
                             ) ;_ vlax-safearray->list
                     #Angle  (angle #PntBeg #PntEnd)
               ) ;_ setq
              )
              ;; Text, MText, Block Selected
              (
               (member #ObjectName
                       (list "AcDbMText" "AcDbText" "AcDbBlockReference")
               ) ;_ member
               (setq #Angle (vlax-get-property #Object 'Rotation))
              )
              ;; MultiLeader Selected
              (
               (eq #ObjectName
                   "AcDbMLeader"
               ) ;_ eq
               (setq #Angle (vlax-get-property #Object 'TextRotation))
              )

            ) ;_ cond
          ) ;_ progn
         )
       ) ;_ cond
       ;; Time to create a selection set
       (if #Angle
         (prompt "\nSelect object(s) to rotate: ")
       ) ;_ if
       (if
         (and
           #Angle
           (setq #ssget
                  (ssget ":L"
                         (list
                           (cons 0 "TEXT,MTEXT,MULTILEADER,INSERT")
                           '(-4 . "<NOT")
                           (cons 2 #XrefList)
                           '(-4 . "NOT>")
                         ) ;_ list
                  ) ;_ ssget
           ) ;_ setq
         ) ;_ and
          (progn
            (setq #ssList (AT:SS->List #ssget T))
            (foreach x #ssList
              (cond
                ;; Process Text, MText, Blocks Selected
                (
                 (member (vlax-get-property x 'ObjectName)
                         (list "AcDbMText" "AcDbText" "AcDbBlockReference")
                 ) ;_ member
                 (vlax-put-property x 'Rotation #Angle)
                )
                ;; Process MultiLeaders Selected
                (
                 (eq (vlax-get-property x 'ObjectName)
                     "AcDbMLeader"
                 ) ;_ eq
                 (vlax-put-property x 'TextRotation #Angle)
                )
              ) ;_ cond

              ;; Reset object if annotative
              (AT:AnnoReset (vlax-vla-object->ename x))

            ) ;_ foreach

            ;; After rotating objects specified angle, option to rotate 90ฐ, 180ฐ, 270ฐ
            (initget 0 "1 2 3 Yes No")
            (setq #Answer
                   (getkword
                     "\nRotate object(s)? 1=90ฐ, 2=180ฐ, 3=270ฐ [1/2/3] <No>: "
                   ) ;_ getkword
            ) ;_ setq
            (if (cond ((eq #Answer "1") (setq #Flip (* pi 0.5)))
                      ((member #Answer (list "2" "Yes")) (setq #Flip pi))
                      ((eq #Answer "3") (setq #Flip (* pi 1.5)))
                ) ;_ cond
              (foreach x #ssList
                (cond
                  ;; Flip Text, MText, Blocks
                  (
                   (member
                     (vlax-get-property x 'ObjectName)
                     (list "AcDbMText" "AcDbText" "AcDbBlockReference")
                   ) ;_ member
                   (vlax-put-property
                     x
                     'Rotation
                     (+ #Flip
                        (vlax-get-property x 'Rotation)
                     ) ;_ +
                   ) ;_ vlax-put-property
                  )
                  ;; Flip Multileaders
                  (
                   (eq (vlax-get-property x 'ObjectName)
                       "AcDbMLeader"
                   ) ;_ eq
                   (vlax-put-property
                     x
                     'TextRotation
                     (+ #Flip
                        (vlax-get-property x 'TextRotation)
                     ) ;_ +
                   ) ;_ vlax-put-property
                  )
                ) ;_ cond

                ;; Reset object if annotative
                (AT:AnnoReset (vlax-vla-object->ename x))

              ) ;_ foreach
            ) ;_ if
            (prompt (strcat
                      "\n "
                      (rtos (sslength #ssget) 2 0)
                      " object(s) rotated!"
                    ) ;_ strcat
            ) ;_ prompt
          ) ;_ progn
       ) ;_ if
     ) ;_ progn
  ) ;_ if

;;; Exit Operations
  (if #OldUCS
    (vl-cmdf "_.ucs" 3 "" #OldUCS "")
  ) ;_ if
  (setvar "cmdecho" #OldCmdecho)
  (setvar "ucsfollow" #OldUCSFollow)
  (AT:Undo "V" "E")

  (princ)
) ;_ defun


;;


;;CADALYST 01/04 Tip1923: ULCASE.LSP  Uppercase
;;(c) 2004 Martin Fryer and Christopher Eriksen

					;ulcase.lsp v1.0
					;Christopher Eriksen and Martin Fryer
					;June 25 2003
					;Changes multiple selected text entities
					;from upper case to lower case and visa versa

(defun c:tc	()
  (prompt "Convert case to [Upper or Lower]:")
  (setq casestr (getstring))
  (if (or (or (= casestr "u") (= casestr "U")) (= casestr ""))
    (setq casemode nil)
					;else
    (if	(or (= casestr "l") (= casestr "L"))
      (setq casemode 1)
    )
  )
  (prompt "\nPick lines of text: ")
  (setq ss (ssget '((0 . "TEXT,MTEXT"))))
  (if (/= ss nil)
    (progn
      (setq ssposition 0)		;Setup index to point at first entity in selection set
      (while (< ssposition (sslength ss))
					;For each entity in the selection set, do....
	(setq entityname (ssname ss ssposition))
					;Get next entities name from the selection set
	(setq entity1 (entget entityname)) ;Get entity list from name
	(setq ssposition (+ ssposition 1)) ;Advance index

	(setq string1 (cdr (assoc 1 entity1)))
	(setq string1 (strcase string1 casemode))
					;Convert text to upper/lower case
	(setq string1 (fixmtext string1))
	(setq
	  entity1 (subst (cons 1 string1) (assoc 1 entity1) entity1)
	)				;Substitue new text element with new
	(entmod entity1)		;Update entity
      )					;end while
    )					;end progn
					;else
    (princ "No text entities were selected")
  )					;end if
  (princ)				;Exit quietly

)					;end defun


(defun fixmtext	(string1)
  (while (/= (vl-string-search "\\p" string1) nil)
    (setq string1 (vl-string-subst "\\P" "\\p" string1))
  )
  (while (/= (vl-string-search "\\l" string1) nil)
    (setq string1 (vl-string-subst "\\L" "\\l" string1))
  )
  (while (/= (vl-string-search "\\F" string1) nil)
    (setq string1 (vl-string-subst "\\f" "\\F" string1))
  )
  (while (/= (vl-string-search "\\h" string1) nil)
    (setq string1 (vl-string-subst "\\H" "\\h" string1))
  )
  (while (/= (vl-string-search "\\s" string1) nil)
    (setq string1 (vl-string-subst "\\s" "\\S" string1))
  )
  (while (/= (vl-string-search "\\q" string1) nil)
    (setq string1 (vl-string-subst "\\q" "\\Q" string1))
  )
  (while (/= (vl-string-search "\\t" string1) nil)
    (setq string1 (vl-string-subst "\\t" "\\T" string1))
  )
  (while (/= (vl-string-search "\\w" string1) nil)
    (setq string1 (vl-string-subst "\\w" "\\W" string1))
  )
  (while (/= (vl-string-search "\\a" string1) nil)
    (setq string1 (vl-string-subst "\\a" "\\A" string1))
  )
  (while (/= (vl-string-search "\\o" string1) nil)
    (setq string1 (vl-string-subst "\\o" "\\O" string1))
  )

  string1
)					;end defun

;;

;Tmm.LSP:   TXTSTACK.LSP   Restack Text   (C)1998, Terry W. Dotson

(defun C:Tmm ( / tmp vscl ntht bitm bent sset bins itm num
                      done ndis nhnd nent chnd cent cins cdis txht)
  (setq cmdecho (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)
  (command "UNDO" "G")
  (setq tmp (getreal "\nInterline Scale Factor <1.62>: "))
  (if (/= tmp nil)(setq vscl tmp)(setq vscl 1.62))
  (setq tmp (getreal "\nNew Text Height <Unchanged>: "))
  (if (/= tmp nil)(setq ntht tmp)(setq ntht 0))
  (setq bitm (car (entsel "\nPick Base String: ")))
  (setq bent (entget bitm))
  (if (= "TEXT" (cdr (assoc 0 bent))) 
    (progn
      (princ "\nSelect Text to Align: ")
      (setq sset (ssget '((0 . "TEXT"))))
      (if sset
        (progn
          (if (> ntht 0)
            (progn
              (setq bent (subst (cons 40 ntht)(assoc 40 bent) bent))
              (entmod bent)
            )
          )
          (if (> (cdr (assoc 72 bent)) 0)
            (setq bins (cdr (assoc 11 bent)))
            (setq bins (cdr (assoc 10 bent)))
          )
          (setq bang (cdr (assoc 50 bent)))
          (setq tang (- bang (/ PI 2)))
          (setq nins bins)
          (ssdel bitm sset)
          (while (> (sslength sset) 0)
            (setq num (sslength sset) itm 0)
            (setq ndis 99999999.9)
            (while (< itm num)
              (setq chnd (ssname sset itm))
              (setq cent (entget chnd))
              (if (> (cdr (assoc 72 cent)) 0)
                (setq cins (cdr (assoc 11 cent)))
                (setq cins (cdr (assoc 10 cent)))
              )
              (setq cdis (distance bins cins))
              (if (< cdis ndis)
                (setq ndis cdis nhnd chnd nent cent)
              )
              (setq itm (1+ itm))
            )
            (if (> ntht 0)
              (progn
                (setq nent (subst (cons 40 ntht)(assoc 40 nent) nent))
                (setq txht ntht)
              )
              (setq txht (cdr (assoc 40 nent)))
            )
            (setq nins (polar nins tang (* txht vscl)))
            (if (> (cdr (assoc 72 nent)) 0)
              (setq nent (subst (cons 11 nins)(assoc 11 nent) nent))
              (setq nent (subst (cons 10 nins)(assoc 10 nent) nent))
            )
            (setq nent (subst (cons 50 bang)(assoc 50 nent) nent))
            (entmod nent)
            (ssdel nhnd sset)
          )
        )
      )
    )
  )
  ;
  (setq sset nil)
  (command "UNDO" "E")
  (setvar "CMDECHO" cmdecho)
  (princ)
)


;;


;===============================================================================
;     TJUSTIFY - Text Rejustification
;===============================================================================

(defun C:TJ2 ()

   (prompt "\nTJUSTIFY - Text Rejustification")

   (setq OLD_CMDECHO (getvar "CMDECHO"))
   (setvar "CMDECHO" 0)

   (setq SELECTION_SET (ssget))
   (setq NO_OF_ITEMS   (sslength SELECTION_SET))

   (initget 1 "L R C M")
   (setq OPTION (getkword "\nNew justification Left/Right/Center/Middle ? "))

   (if (equal OPTION "L") (setq NEW_JUSTIFY (cons 72 0)))
   (if (equal OPTION "C") (setq NEW_JUSTIFY (cons 72 1)))
   (if (equal OPTION "R") (setq NEW_JUSTIFY (cons 72 2)))
   (if (equal OPTION "M") (setq NEW_JUSTIFY (cons 72 4)))

   (setq SSPOSITION 0)
   (repeat NO_OF_ITEMS

          (setq ENTITY_NAME (ssname SELECTION_SET SSPOSITION))
          (setq OLDLIST     (entget ENTITY_NAME))
          (setq ENTITY_TYPE (cdr (assoc 0 OLDLIST)))

          (if (equal ENTITY_TYPE "TEXT")
              (progn

                 (setq OLD_JUSTIFY (assoc 72 OLDLIST))

                 (if (member (cdr OLD_JUSTIFY) (list 0 3 5))
                     (setq OLDINSPT (cdr (assoc 10 OLDLIST)))
                     (setq OLDINSPT (cdr (assoc 11 OLDLIST)))
                 )

                 (setq NEWLIST (subst NEW_JUSTIFY OLD_JUSTIFY OLDLIST))

                 (entmod NEWLIST)
                 (setq NEWLIST (entget ENTITY_NAME))

                 (if (member (cdr NEW_JUSTIFY) (list 0 3 5))
                     (setq NEWINSPT (cdr (assoc 10 NEWLIST)))
                     (setq NEWINSPT (cdr (assoc 11 NEWLIST)))
                 )
                 (command ".MOVE" ENTITY_NAME "" NEWINSPT OLDINSPT)
              )
          )
          (setq SSPOSITION (1+ SSPOSITION))
   )
   (setvar "CMDECHO" OLD_CMDECHO)
   (prompt "\nProgram complete.")
   (princ)
)



;;


; Exports AutoCAD text to an ASCII file sorted by Y coordinate.
;;; ==========================================================================
;;; Program: TOUT.LSP
;;; Purpose: Exports ASCII text to an ASCII file.
;;; Syntax: Textout
;;;
;;; Resolutions
;;; P.O. Box 1265
;;; Sumner, WA 98390-0250
;;; (206) 845-2200
;;; 
;;; Date: 3/19/89, 7/6/95
;;; ==========================================================================
(defun c:tout(/ fname fp ss val index YList nsort SnapAngle i p0 pt)
;;; ==========================================================================
;;; Function: VAL
;;; Purpose : Returns the data from an assoc list
;;;
;;; --------------------------------------------------------------------------
	(defun val (nr e) (cdr (assoc nr e)))
;;; ==========================================================================
;;; Function: nsort <list>
;;; Purpose : Returns a sorted index to the list
;;; Params  : nlist.......List to index
;;;
;;; --------------------------------------------------------------------------
(defun nsort (nlist / size index i out in i1 i2)
	(setq size (length nlist) index '() i 0)
	(repeat size
		(setq
			index (append index (list i))
			i (1+ i)
		)
	)
	(setq out 0)
	(while (< out (- size 1))
		(setq in (+ out 1))
		(while (< in size)
			(setq i1 (nth out index) i2 (nth in index))
			(if (> (nth i1 nlist) (nth i2 nlist))
				(setq
					index (subst i1 -1 (subst i2 i1 (subst -1 i2 index)))
				)
			)
			(setq in (1+ in))
		)
		(setq out (1+ out))
	)
	index
)
;;; ==========================================================================

;;; --- Start TEXTOUT ---

	(setq SnapAngle (getvar "SNAPANG"))

	(prompt "\nSelect TEXT:")
	(cond
		((null (setq ss (ssget '((0 . "TEXT"))))) (princ "\nNo TEXT selected."))
		((null (setq fname (getfiled "ASCII file to create" "" "TXT" 1)))(princ "\nNo file selected."))
		(T
			;; --- Sort the TEXT by the Y coord ---
			(setq i 0 YList '())
			(repeat (sslength ss)
				(setq
					pt (val 10 (entget (ssname ss i)))
					p0 (list 0 0 0)
					pt (polar p0 (- (angle p0 pt) SnapAngle) (distance p0 pt))
					YList (append Ylist (list (cadr pt)))
					i (1+ i)
				)
			)
			(princ "\nSorting TEXT by 'Y' Coordinate. Please wait...")
			(setq index (reverse (nsort YList)))
			;; --- Write out the Sorted index ---
			(if (setq fp (open fname "w"))
				(progn
					(foreach x index
						(write-line (val 1 (entget (ssname ss x))) fp)
					)
					(close fp)
					(princ (strcat "\n" (itoa (length index)) " Lines of TEXT written to file " fname))
				)
				(alert "*Error*  Opening file")
			)
		)
	)
	(princ)
)
;;; --- End of TEXTOUT ---



;;


; TIP350.LSP   Matching Text Changes,  (c)1988, David Schoenherr

(defun C:TRE (/ A B C D E)
  (prompt "\nSelect text to match: ")
  (setq E (ssget))
  (setq E (cdr (assoc 1 
    (entget (ssname E 0)))))
  (prompt "\nSelect text to change: ")
  (setq A (ssget))
  (setq B (sslength A))
  (setq C 0)
  (while (<= 1 B)
    (setq D (ssname A C))
    (if (eq (cdr (assoc 0 
      (entget D))) "TEXT")
    (entmod (subst (cons 1 E)(assoc 1 
      (entget D)) (entget D))))
    (setq B (- B 1))
    (setq C (+ C 1)) 
  )
)
(PRINC)


;;


(defun c:tro ( / rot ss1 rpnt num)
  (WSD_sv)
  (command ".undo" "m")
  (setq rot (getreal "\nEnter rotation angle: ") num 0)
  (prompt "\nSelect text to rotate: ")
  (setq ss1 (ssget '((-4 . "<OR")(-4 . "<AND")
                       (0 . "TEXT")
                     (-4 . "AND>")(-4 . "<AND")
                       (0 . "MTEXT")
                     (-4 . "AND>")(-4 . "OR>"))
            )
  )
  (repeat (sslength ss1)
    (setq rpnt (cdr (assoc 10 (entget (ssname ss1 num)))))
    (command "._rotate" (ssname ss1 num) "" rpnt rot)
    (setq num (1+ num))
  )
  (command ".undo" "e")
  (WSD_rv)
)
(princ)
;;*******************************************************************************
;; (WSD_SV) Save vars and set error handler - Lisp initiation JRW
;;*******************************************************************************
(defun WSD_sv ()
  (command ".undo" "begin")
  (setq #dscl (getvar "dimscale"))
  (setq #bm (getvar "blipmode"))
					;(setq #os (getvar "osmode"))
  (setq #ce (getvar "cmdecho"))
  (setq #me (getvar "menuecho"))
  (setq	#oe	*error*
	*error*	JSD_err
  )
  (setvar "blipmode" 0)
					;(setvar "osmode" 0)
  (setvar "cmdecho" 0)
  (setvar "menuecho" 0)
  (graphscr)
) ;_ end of defun
;;*******************************************************************************
;; (WSD_RV) Reset vars and reset error handler - Lisp end JRW            
;;*******************************************************************************
(defun WSD_rv ()
  (command "undo" "end")
  (setvar "dimscale" #dscl)
  (setvar "blipmode" #bm)
					;(setvar "osmode" #os)
  (setvar "cmdecho" #ce)
  (setq	*error*	#oe
	#oe nil
  ) ;_ end of setq
					;(prompt "\n           Written by James R Wilson")
  (prompt "\n\nDone...  (C) Copyright 2004 WSD")
  (prompt "\n             All Rights Reserved")
  (princ)
) ;_ end of defun

;;

; ----------------------------------------------------------------------
;                   (Converts Stack of TEXT to MTEXT)
;            Copyright (C) 1998 DotSoft, All Rights Reserved
;                      Website: www.dotsoft.com
; ----------------------------------------------------------------------
; DISCLAIMER:  DotSoft Disclaims any and all liability for any damages
; arising out of the use or operation, or inability to use the software.
; FURTHERMORE, User agrees to hold DotSoft harmless from such claims.
; DotSoft makes no warranty, either expressed or implied, as to the
; fitness of this product for a particular purpose.  All materials are
; to be considered ‘as-is’, and use of this software should be
; considered as AT YOUR OWN RISK.
; ----------------------------------------------------------------------

(defun col2str (inp)
  (cond
    ((= inp nil)(setq ret "BYLAYER"))
    ((= inp 256)(setq ret "BYLAYER"))
    ((= inp 0)(setq ret "BYBLOCK"))
    ((and (> inp 0)(< inp 255))(setq ret (itoa inp)))
    (t nil)
  )
)

(defun savprop ()
  (setq clayer (getvar "CLAYER"))
  (setq cecolor (getvar "CECOLOR"))
  (setvar "CECOLOR" "BYLAYER")
  (setq celtype (getvar "CELTYPE"))
  (setvar "CELTYPE" "BYLAYER")
  (setq thickness (getvar "THICKNESS"))
  (setvar "THICKNESS" 0)
  (if (>= (atoi (getvar "ACADVER")) 13)
    (progn
      (setq celtscale (getvar "CELTSCALE"))
      (setvar "CELTSCALE" 1.0)
    )
  )
)

(defun resprop ()
  (if (>= (atoi (getvar "ACADVER")) 13)
    (setvar "CELTSCALE" celtscale)
  )
  (setvar "THICKNESS" thickness)
  (setvar "CELTYPE" celtype)
  (setvar "CECOLOR" cecolor)
  (setvar "CLAYER" clayer)
)

(defun textrect (tent / ang sinrot cosrot t1 t2 p1 p2 p3 p4)
  (setq p0 (cdr (assoc 10 tent))
    ang (cdr (assoc 50 tent))
    sinrot (sin ang)
    cosrot (cos ang)
    t1 (car (textbox tent))
    t2 (cadr (textbox tent))
    p1 (list (+ (car p0)
       (- (* (car t1) cosrot) (* (cadr t1) sinrot)))
       (+ (cadr p0)
       (+ (* (car t1) sinrot) (* (cadr t1) cosrot))))
    p2 (list (+ (car p0)
       (- (* (car t2) cosrot) (* (cadr t1) sinrot)))
       (+ (cadr p0)
       (+ (* (car t2) sinrot) (* (cadr t1) cosrot))))
    p3 (list (+ (car p0)
       (- (* (car t2) cosrot) (* (cadr t2) sinrot)))
       (+ (cadr p0)
       (+ (* (car t2) sinrot) (* (cadr t2) cosrot))))
    p4 (list (+ (car p0)
       (- (* (car t1) cosrot) (* (cadr t2) sinrot)))
       (+ (cadr p0)
       (+ (* (car t1) sinrot) (* (cadr t2) cosrot))))
  )
  (list p1 p2 p3 p4)
)

(defun C:TTM ( / mwid dset ibrk bitm bent sset rect mlay mcol mlst
                      bins bang tang nins num ndis chnd cent nhnd nstr
                      str pt1 pt2 pt3 dis dvx dvy dvz new)
  (if (< (atoi (getvar "ACADVER")) 13)
    (alert "This Function Requires\nRelease 13 or Higher")
    (progn
      (setq cmdecho (getvar "CMDECHO"))
      (setvar "CMDECHO" 0)
      (command "_.UNDO" "_G")
      (setq mwid 0.0)
      (setq dset (ssadd))
      ;
      (initget "Y N")
      (setq tmp (getkword "\nDS> Include Line Breaks <Y>/N: "))
      (if (/= tmp "N")(setq ibrk "Y")(setq ibrk "N"))
      ;
      (setq bitm (car (entsel "\nDS> Pick Base String: ")))
      (setq bent (entget bitm))
      (setq rect (textrect bent))
      (setq chk (distance (car rect)(cadr rect)))
      (if (> chk mwid)(setq mwid chk))
      ;
      (if (= "TEXT" (cdr (assoc 0 bent))) 
        (progn
          (redraw bitm 3)
          (princ "\nDS> Select Remaining Text: ")
          (setq sset (ssget '((0 . "TEXT"))))
          (if sset
            (progn
              (setq rect (textrect bent))
              (setq orig rect)
              (setq mlay (cdr (assoc 8 bent)))
              (setq mcol (cdr (assoc 62 bent)))
              (setq mlst (list (cdr (assoc 1 bent))))
              ;
              (if (> (cdr (assoc 72 bent)) 0)
                (setq bins (cdr (assoc 11 bent)))
                (setq bins (cdr (assoc 10 bent)))
              )
              (setq bang (cdr (assoc 50 bent)))
              (setq tang (- bang (/ PI 2)))
              (setq nins bins)
              (ssdel bitm sset)
              (while (> (sslength sset) 0)
                (setq num (sslength sset) itm 0)
                (setq ndis 99999999.9)
                (while (< itm num)
                  (setq chnd (ssname sset itm))
                  (setq cent (entget chnd))
                  (if (> (cdr (assoc 72 cent)) 0)
                    (setq cins (cdr (assoc 11 cent)))
                    (setq cins (cdr (assoc 10 cent)))
                  )
                  (setq cdis (distance bins cins))
                  (if (< cdis ndis)
                    (setq ndis cdis nhnd chnd nent cent)
                  )
                  (setq itm (1+ itm))
                )
                (setq dset (ssadd nhnd dset))
                (ssdel nhnd sset)
                ;
                (setq rect (textrect nent))
                (setq chk (distance (car rect)(cadr rect)))
                (if (> chk mwid)(setq mwid chk))
                ;
                (setq nstr (cdr (assoc 1 nent)))
                (setq mlst (append mlst (list nstr)))
              )
              ;
              (entdel bitm)
              (setq num (sslength dset) itm 0)
              (while (< itm num)
                (setq hnd (ssname dset itm))
                (entdel hnd)
                (setq itm (1+ itm))
              )
              ;
              (savprop)
              (setvar "CLAYER" mlay)
              (if (/= mcol nil)
                (setvar "CECOLOR" (col2str mcol))
              )
              (setq mwid (+ mwid (* mwid 0.025)))
              (setq pt1 (car orig))
              (setq pt2 (cadr orig))
              (setq dis (distance pt1 pt2))
              (setq dvx (/ (- (car pt2)(car pt1)) dis))
              (setq dvy (/ (- (cadr pt2)(cadr pt1)) dis))
              (setq pt3 (list dvx dvy 0.0))
              (setq nins (list (car (cadddr orig))
                         (cadr (cadddr orig))
                         (nth 2 (cdr (assoc 10 bent)))))
              ;
              (setq new '((0 . "MTEXT")(100 . "AcDbEntity")(100 . "AcDbMText")))
              (setq new (append new (list (assoc 7 bent))))
              (setq new (append new (list (assoc 8 bent))))
              (setq new (append new (list (cons 10 nins))))
              (setq new (append new (list (cons 11 pt3))))
              (foreach lin mlst
                (if (= ibrk "Y")
                  (if (/= lin (last mlst))
                    (setq lin (strcat lin "\\P"))
                  )
                  (setq lin (strcat lin " "))
                )
                (setq new (append new (list (cons 1 lin))))
              )
              (setq new (append new (list (assoc 40 bent))))
              (setq new (append new (list (cons 41 mwid))))
              (setq new (append new (list (cons 71 1))))
              (setq new (append new (list (cons 72 1))))
              (entmake new)
              (resprop)
              ;
              (setq sset nil)
              (setq dset nil)
              (setq lst nil)
              (command "_.UNDO" "_E")
              (setvar "CMDECHO" cmdecho)
            )
            (redraw bitm 4)
          )
        )
      )
    )
  )
  (setq sset nil)
  (setq mlst nil)
  (princ)
)



;;

;UL.LSP
;
;Draws a single line between the two most-distant points of two
;user-selected lines.  Erases the two user-selected lines.  Assigns
;to the new line the same properties of Layer, Color, Linetype, and
;Thickness as those of the first user-selected line.
;
;For AutoCAD Release 10
;
;Written 02/19/1989  Brad Zehring  Autodesk, Inc. Training Department
;
(defun C:UL (/ l1 l2 e1 e2 dl ml temp p pt1 pt2
                 old_flatland old_cmdecho)
  (setq old_flatland (getvar "flatland"))
  (setq old_cmdecho (getvar "cmdecho"))
  (setvar "flatland" 0)
  (setvar "cmdecho" 0)
  (setq l1 (entsel "\nSelect first line: "))
  (setq l2 (entsel "\nSelect second line: "))
  (if
    (or (eq l1 nil) (eq l2 nil))
    (prompt "\nRequires two lines. *Invalid*")
    (progn
      (if
        (not
          (and
            (eq "LINE" (cdr (assoc 0 (setq e1 (entget (car l1))))))
            (eq "LINE" (cdr (assoc 0 (setq e2 (entget (car l2))))))
          )
        )
        (prompt "\nRequires two lines. *Invalid*")
        (progn
          (setq dl nil)
          (setq dl
            (cons
              (list (distance (cdr (assoc 10 e1)) (cdr (assoc 10 e2))) 11)
              dl
            )
          )
          (setq dl
            (cons
              (list (distance (cdr (assoc 10 e1)) (cdr (assoc 11 e2))) 12)
              dl
            )
          )
          (setq dl
            (cons
              (list (distance (cdr (assoc 11 e1)) (cdr (assoc 10 e2))) 21)
              dl
            )
          )
          (setq dl
            (cons
              (list (distance (cdr (assoc 11 e1)) (cdr (assoc 11 e2))) 22)
              dl
            )
          )
          (setq ml nil temp dl)
          (repeat 4
            (setq ml (cons (car (car temp)) ml))
            (setq temp (cdr temp))
          )
          (setq p (car (cdr (assoc (eval (cons 'MAX ml)) dl))))
          (cond
            ((= p 11)
             (setq pt1 (cdr (assoc 10 e1)))
             (setq pt2 (cdr (assoc 10 e2)))
            )
            ((= p 12)
             (setq pt1 (cdr (assoc 10 e1)))
             (setq pt2 (cdr (assoc 11 e2)))
            )
            ((= p 21)
             (setq pt1 (cdr (assoc 11 e1)))
             (setq pt2 (cdr (assoc 10 e2)))
            )
            ((= p 22)
             (setq pt1 (cdr (assoc 11 e1)))
             (setq pt2 (cdr (assoc 11 e2)))
            )
            (t)
          )
          (command ".line" pt1 pt2 "")
          (command ".chprop" (entlast) ""
                   "LA" (cdr (assoc 8 e1))
                   "C"  (if
                          (null (cdr (assoc 62 e1)))
                          ""
                          (cdr (assoc 62 e1))
                        )
                   "LT" (if
                          (null (cdr (assoc 6 e1)))
                          ""
                          (cdr (assoc 6 e1))
                        )
                   "T"  (if
                          (null (cdr (assoc 39 e1)))
                          ""
                          (cdr (assoc 39 e1))
                        )
                   ""
          )
          (command ".erase" l1 l2 "")
        )
      )
    )
  )
  (setvar "flatland" old_flatland)
  (setvar "cmdecho" old_cmdecho)
  (prin1)
)



;;


;Unlocks all layers

(defun c:ULL (/ OLDECH )

(SETQ OLDECH (GETVAR "CMDECHO") )
(SETVAR "CMDECHO" 0)
(COMMAND ".LAYER" "UNLOCK" "*" "")
(SETVAR "CMDECHO" OLDECH)
(PRINC))


;;

; http://forums.cadalyst.com/showthread.php?t=6110
;;
;;
(defun c:umt (/ first delete second delete1 mtx1 mtx2 mtx ed)
(prompt "\nTo merge two MTEXT entities")
(setq key 1)
;;;;;;;;;;;;;;;;;;;;
(setq first (entget (car(entsel"\nSelect first MTEXT entity: "))))
(if (= first nil)(exit))
(setq delete1(cdr(assoc -1 first)))
(redraw delete1 3)
(setq second (entget (car(entsel"\nSelect NEXT MTEXT or TEXT entity: "))))
(if (= second nil)(exit))
(setq delete (cdr(assoc -1 second)))
(redraw delete 3)
(setq mtx1 (cdr (assoc 1 first)))
(setq mtx2 (cdr (assoc 1 second)))
(setq mtx (strcat mtx1 "\\P" mtx2))
(command "erase" delete delete1 "")
(setq ed first)
(setq ed
(subst (cons 1 mtx)
(assoc 1 ed)
ed
)
)
(entmake ed)
;;;;;;;;;;;;;;;;;;;
(while (= key 1)
(setq first (entget (entlast)))
(if (= first nil)(exit))
(setq delete1(cdr(assoc -1 first)))
(redraw delete1 3)
(setq second (entget (car(entsel"\nSelect NEXT MTEXT or TEXT string: "))))
(if (= second nil)(exit))
(setq delete (cdr(assoc -1 second)))
(redraw delete 3)
(setq mtx1 (cdr (assoc 1 first)))
(setq mtx2 (cdr (assoc 1 second)))
(setq mtx (strcat mtx1 "\\P" mtx2))
(command "erase" delete delete1 "")
(setq ed first)
(setq ed
(subst (cons 1 mtx)
(assoc 1 ed)
ed
)
)
(entmake ed)
(princ)
)
(princ)

) 


;;


;=============================================== 
;    UnAnon.Lsp                                   Jul 05, 1998 
;====================================== 
;;(princ "\nCopyright (C) 1998, Fabricated Designs, Inc.") 
;;(princ "\nLoading UnAnon v1.0 ") 
(setq uan_ nil lsp_file "UnAnon") 

;================== For Automated Calling From Another Program ========= 
(defun uan_auto (ar1) (UnAnon ar1)) 

;================== Macros ============================================= 
(defun PDot ()(princ ".")) 

(PDot);++++++++++++ Set Modes & Error ++++++++++++++++++++++++++++++++++ 
(defun uan_smd () 
 (SetUndo) 
 (setq olderr *error* 
      *error* (lambda (e) 
                (and (/= e "quit / exit abort") 
                     (princ (strcat "\nError: *** " e " *** "))) 
                (command "_.UNDO" "_END" "_.U") 
                (uan_rmd)) 
       uan_var '( 
  ("CMDECHO"   . 0) ("MENUECHO" . 0) ("MENUCTL"   . 0) ("MACROTRACE" . 0) 
  ("OSMODE"    . 0) ("SORTENTS" . 119)("MODEMACRO" . ".") 
  ("BLIPMODE"  . 0) ("EXPERT"   . 0) ("SNAPMODE"  . 1) ("PLINEWID"   . 0.0) 
  ("ORTHOMODE" . 1) ("GRIDMODE" . 0) ("ELEVATION" . 0) ("THICKNESS"  . 0) 
  ("FILEDIA"   . 0) ("FILLMODE" . 0) ("SPLFRAME"  . 0) ("UNITMODE"   . 0) 
  ("TEXTEVAL"  . 0) ("ATTDIA"   . 0) ("AFLAGS"    . 0) ("ATTREQ"     . 1) 
  ("ATTMODE"   . 1) ("UCSICON"  . 1) ("HIGHLIGHT" . 1) ("REGENMODE"  . 1) 
  ("COORDS"    . 2) ("DRAGMODE" . 2) ("DIMZIN"    . 1) ("PDMODE"     . 0) 
  ("CECOLOR"   . "BYLAYER") ("CELTYPE" . "BYLAYER"))) 
 (foreach v uan_var 
      (setq m_v (cons (getvar (car v)) m_v) 
            m_n (cons (car v) m_n)) 
      (setvar (car v) (cdr v))) 
 (princ (strcat (getvar "PLATFORM") " Release " (substr (ver) 18 2) 
   " -  Convert To Anonymous Blocks ....\n")) 
 (princ)) 

(PDot);++++++++++++ Return Modes & Error +++++++++++++++++++++++++++++++ 
(defun uan_rmd () 
  (setq *error* olderr) 
  (mapcar 'setvar m_n m_v) 
  (command "_.UNDO" "_END") 
  (prin1)) 

(PDot);++++++++++++ Set And Start An Undo Group ++++++++++++++++++++++++ 
(defun SetUndo () 
 (and (zerop (getvar "UNDOCTL")) 
      (command "_.UNDO" "_ALL")) 
 (and (= (logand (getvar "UNDOCTL") 2) 2) 
      (command "_.UNDO" "_CONTROL" "_ALL")) 
 (and (= (logand (getvar "UNDOCTL") 8) 8) 
      (command "_.UNDO" "_END")) 
 (command "_.UNDO" "_GROUP")) 

(PDot);++++++++++++ Get Entity Name ++++++++++++++++++++++++++++++++++++ 
(defun GetOne (/ st os) 
 (setq os (getvar "SNAPMODE") s nil) 
 (setvar "SNAPMODE" 0) 
 (while (not st) 
        (setq st (ssget))) 
 (while (> (sslength st) 1) 
        (setq st nil) 
        (princ "\nOnly 1 At A Time Please\n") 
        (while (not st) 
               (setq st (ssget)))) 
 (setvar "SNAPMODE" os) 
 (setq s (ssname st 0))) 

(PDot);++++++++++++ Convert An Anonymous Block To Named Block ++++++++++ 
(defun UnAnon (b / tdef en ed bc bn bd in)          ;Supply ename 
  (setq bn "TEMP1" bc 1) 
  (while (tblsearch "BLOCK" bn) 
         (setq bc (1+ bc) bn (strcat "TEMP" (itoa bc)))) 
  (and (= (type b) 'ENAME) 
       (setq bd (entget b) 
             in (cdr (assoc 2 bd)))) 
  (if (or (not bd) 
          (not in) 
          (/= "INSERT" (cdr (assoc 0 bd))) 
          (/= "*U" (substr in 1 2)) 
          (= (logand (cdr (assoc 70 (tblsearch "BLOCK" in)))  4)  4) 
          (= (logand (cdr (assoc 70 (tblsearch "BLOCK" in))) 16) 16) 
          (= (logand (cdr (assoc 70 (tblsearch "BLOCK" in))) 32) 32)) 
       (progn 
         (princ "*** Not An Anonomymous Block *** ") 
         (setq bn nil bc nil bd nil in nil b nil) 
         (exit))) 
  (setq tdef (tblsearch "BLOCK" in) 
          en (cdr (assoc -2 tdef)) 
          ed (entget en)) 
  (entmake (list (cons 0 "BLOCK") 
                 (cons 2 bn) 
                 (cons 70 0) 
                 (cons 10 (cdr (assoc 10 tdef))))) 
  (entmake ed) 
  (while (setq en (entnext en)) 
         (setq ed (entget en)) 
         (entmake ed)) 
  (entmake (list (cons 0 "ENDBLK"))) 
  (setq bd (subst (cons 2 bn) (assoc 2 bd) bd)) 
  (entmod bd) 
  (entupd b) 
  (princ (strcat "\n" bn))) 

(PDot);************ Main Program *************************************** 
(defun uan_ (/ m_v m_n olderr uan_var s) 
  (uan_smd) 
  (GetOne) 
  (UnAnon s) 
  (uan_rmd)) 

(defun c:UnAnonall (/ ss i) 
 (setq ss (ssget "X" (list (cons 0 "INSERT")(cons 67 (if (= (getvar "TILEMODE") 1) 0 1))))) 
 (and ss 
   (setq i (sslength ss)) 
   (while (not (minusp (setq i (1- i)))) 
          (setq en (ssname ss i)) 
          (if (= "*U" (substr (cdr (assoc 2 (entget en))) 1 2)) 
              (UnAnon en)))) 
 (prin1)) 

(PDot);************ Load Program *************************************** 
(defun C:UnAnon () (uan_)) 
(if uan_ (princ)) 
(prin1) 
;================== End Program ======================================== 



;;


;Change all blocks in a drawing to unitless
(defun c:unitless ()
(vl-load-com)
(vlax-for x(vla-get-Blocks(vla-get-activedocument (vlax-get-acad-object)))(vlax-put-property x "Units" 0)(vlax-put-property x "insunits" 0))
)
;Copy and paste it into the command line and it will change all of the blocks to unitless. 
;If the 0 is changed to 1 then the blocks are changed to inches,;
;2 is feet, 3 is miles, 4 is mm, 5 is cm, 6 is meters, 7 is km,;
; 8 is microinches, 9 is mils, 10 is yards, 11 is Angstroms, ;
;12 is nanometers, 13 is microns, 14 is decimeters, 15 is Dekameters,;
;16 is Hectometers, 17 is Gigameters, 18 is Astronomical Units, ;
;19 is Light Years, 20 is Parsecs.



;;

;"Glue" text strings.  All adopt first's properties.
;	Author:
;		Henry C. Francis
;		425 N. Ashe St.
;		Southern Pines, NC 28387
;	http://www.pinehurst.net/~pfrancis
;	e-mail hfrancis@pinehurst.net
;	All rights reserved.
(defun c:ut ( / ename ent1 ent2 old1 oldsl old10 old11 old40 old50 newstr newsl new1 new10 new11)
(while
  (not
    (and
      (setq ename1 (car(entsel "\nSelect first text string to join: ")))
      (setq ent1 (entget ename1))
      (eq(cdr(assoc 0 ent1))"TEXT")
    );and
  );not
);while
(setq old1 (cdr(assoc 1 ent1)))
(while
  (not
    (and
      (setq ename2 (car(entsel "\nSelect second text string to join: ")))
      (setq ent2 (entget ename2))
      (eq(cdr(assoc 0 ent2))"TEXT")
      (not(eq ename1 ename2))
    );and
  );not
);while
(setq old2 (cdr(assoc 1 ent2)))
(setq new1 (strcat old1 " " old2)
      ent1
        (subst (cons 1 new1)
               (assoc 1 ent1)
               ent1)
);setq
(entmod ent1)
(entdel ename2)
(princ)
);defun


;;


; ----------------------------------------------------------------------
;          (Wblocks all local block definitions to target path)
;            Copyright (C) 2000 DotSoft, All Rights Reserved
;                   Website: http://www.dotsoft.com
; ----------------------------------------------------------------------
; DISCLAIMER:  DotSoft Disclaims any and all liability for any damages
; arising out of the use or operation, or inability to use the software.
; FURTHERMORE, User agrees to hold DotSoft harmless from such claims.
; DotSoft makes no warranty, either expressed or implied, as to the
; fitness of this product for a particular purpose.  All materials are
; to be considered ‘as-is’, and use of this software should be
; considered as AT YOUR OWN RISK.
; ----------------------------------------------------------------------

(defun c:wba ()
  (setq cmdecho (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)
  ;
  (if (not dos_getdir)
    (setq path (getstring "\nDS> Target Folder: " T))
    (setq path (dos_getdir "Target Folder" (getvar "DWGPREFIX")))
  )
  (if (/= path nil)
    (progn
      (if (= (substr path (strlen path) 1) "\\")
        (setq path (substr path 1 (1- (strlen path))))
      ) 
      (princ "\nDS> Building List of Blocks ... ")
      (setq lst nil)
      (setq itm (tblnext "BLOCK" T))
      (while (/= itm nil)
        (setq nam (cdr (assoc 2 itm)))
        (setq pass T)
        (if (/= (cdr (assoc 1 itm)) nil)
          (setq pass nil)
          (progn
            (setq ctr 1)
            (repeat (strlen nam)
              (setq chk (substr nam ctr 1))
              (if (or (= chk "*")(= chk "|"))
                (setq pass nil)
              )
              (setq ctr (1+ ctr))
            )
          )
        )
        (if (= pass T)
          (setq lst (cons nam lst))
        )
        (setq itm (tblnext "BLOCK"))
      )
      (setq lst (acad_strlsort lst))
      (princ "Done.")
      ;
      (foreach blk lst
        (setq fn (strcat path (chr 92) blk))
        (if (findfile (strcat fn ".dwg"))
          (command "_.WBLOCK" fn "_Y" blk)
          (command "_.WBLOCK" fn blk)
        )
      )
    )
  )
  ;
  (setvar "CMDECHO" cmdecho)
  (princ)
)



;;

;XA.LSP:   ISOLATE.LSP    Isolate Multiple Layers    (C)1998, William E. Stewart

(defun c:xa ()
     (setq lay (getvar "clayer")) 
     (prompt "Select layers to be on: ") (terpri)
        (setq ss (ssget)
              ss1(sslength ss)
              x   0
              s2 (cdr(assoc 8 (entget(ssname ss x)))) 
        )
        (command "layer" "s" lay ""
                 "layer" "off" lay "y" ""
                 "layer" "off" "*" "" "")
        (repeat ss1
          (setq ssn (ssname ss x)
                a   (entget ssn)
                s1  (cdr(assoc 8 a))
          )
             (command "layer" "on" s1 "")
             (setq x (+ x 1))
        )
        (command "layer" "s" s2 "")
        (prompt"Only the selection set layers are on...")(terpri)
        (princ)
)


;;


;;YU.lsp
;;Ayuda a trazar una linea geometricamente definida del punto medio entre
;;dos paralelas


(defun c:yu (/)
(command "ortho""off""-osnap""END,INT,NEA,PER""line" pause pause """ORTHO""ON""-osnap""mid""line" pause pause ))


;;

;;


;;; ------------------------------------------------------------------------
;;;	ZeroRotation.lsp v1.1
;;;
;;;	Copyrightฉ 03.09.09
;;;	Alan J. Thompson (alanjt)
;;;	alanjt@gmail.com
;;;
;;;	Permission to use, copy, modify, and distribute this software
;;;	for any purpose and without fee is hereby granted, provided
;;;	that the above copyright notice appears in all copies and
;;;	that both that copyright notice and the limited warranty and
;;;	restricted rights notice below appear in all supporting
;;;	documentation.
;;;
;;;	The following program(s) are provided "as is" and with all faults.
;;;	Alan J. Thompson DOES NOT warrant that the operation of the program(s)
;;;	will be uninterrupted and/or error free.
;;;
;;;	Set objects (Multileaders, Text, Mtext, Blocks) with a
;;;	rotation of 0 (relative to current UCS).
;;;
;;;	Revision History:
;;;
;;;	v1.1 (10.23.09) 1. Minor rewrite for speed optimization.
;;;
;;; ------------------------------------------------------------------------

(defun c:ZR () (c:ZeroRotation))
(defun c:ZeroRotation (/ *error* AT:UCSAngle #SS)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SUBROUTINES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;; error handler
  (defun *error* (#Message)
    (and *AcadDoc* (vla-endundomark *AcadDoc*))
    (and #Message
         (not (wcmatch (strcase #Message) "*BREAK*,*CANCEL*,*QUIT*"))
         (princ (strcat "\nError: " #Message))
    ) ;_ and
  ) ;_ defun


;;; Retreive current UCS angle
;;; Alan J. Thompson, 03.09.09
  (defun AT:UCSAngle (/ xdir)
    (setq xdir (getvar "ucsxdir"))
    (atan (cadr xdir) (car xdir))
  ) ;_ defun


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;; MAIN ROUTINE ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  (vl-load-com)

  (or *AcadDoc* (setq *AcadDoc* (vla-get-activedocument (vlax-get-acad-object))))
  (vla-startundomark *AcadDoc*)

  (cond
    ((setq #SS (ssget "_:L" '((0 . "TEXT,MTEXT,MULTILEADER,INSERT"))))
     (vlax-for x (setq #SS (vla-get-activeselectionset *AcadDoc*))
       (cond
         ;; Text, Block
         ((vl-position (vla-get-objectname x) '("AcDbBlockReference" "AcDbText"))
          (vla-put-rotation x (AT:UCSAngle))
         )
         ;; MText
         ((eq (vla-get-objectname x) "AcDbMText") (vla-put-rotation x 0.0))
         ;; Multileader
         ((eq (vla-get-objectname x) "AcDbMLeader")
          (vl-catch-all-apply 'vla-put-textrotation (list x 0.0))
         )
       ) ;_ cond
     ) ;_ vlax-for
     (princ (strcat "\n" (itoa (vla-get-count #SS)) " objects processed."))
     (vl-catch-all-apply 'vla-delete (list #SS))
    )
  ) ;_ cond
  (*error* nil)
  (princ)
) ;_ defun


;;