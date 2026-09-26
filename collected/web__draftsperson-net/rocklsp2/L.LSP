 ; Lisp routine loader/system variable setter/error handler.
 ; by SW for Rocket Software  1991
 ; Saves irritation if anyone else works on your drawings. 
 (DEFUN C:L () 
 ;-------------------------------Error Handler--------------------------------
  (DEFUN *ERROR* (shk)
     (if (/= shk "Function cancelled")
         (print shk))
     (grtext)
     (princ))
 ;------------------------------Sysvar Resetter-------------------------------
   (command "limits" (getvar "extmin") (getvar "extmax"))
   (command "snap" "0.5")
   (command "ucsicon" "off")
   (setvar "orthomode" 1)
   (setvar "snapmode" 1)
   (setvar "coords" 2)
   (setvar "cmdecho" 0)
   (setvar "regenmode" 0)
 ;-----------------------------Lisp routine loader-----------------------------
   (LOAD "Z")     (LOAD "TCH")    (LOAD "SQ")
   (LOAD "AXE")   (LOAD "SWX")    (LOAD "WMX")
   (LOAD "XNG")   (LOAD "LYNX")   (LOAD "ZE")
   (LOAD "BOO")   (LOAD "P")      (LOAD "SNAPPER")
   (LOAD "WN")    (LOAD "S")      (LOAD "F")
   (LOAD "INF")   (LOAD "SC")     (LOAD "VBC")
   (LOAD "VBL")   (LOAD "VB")     (LOAD "PID")
   (LOAD "PL")    (LOAD "GET")    (LOAD "XX")
   (LOAD "LD")    (LOAD "SNAME")  (LOAD "BOOM")
   (LOAD "2")
   (C:SNAME)
   (PRINC))