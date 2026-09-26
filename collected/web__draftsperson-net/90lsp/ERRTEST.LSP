;;; AutoLISP File for
;;; Maximizing AutoLISP - IL DISK (c) 1987, '88, '89, '91, '92 New Riders Publ.
;;;                Version 12.00 for Release 12 PC-DOS/MS-DOS                 
;;;       Developed by Rustin Gesner, Joseph Smith, and Patrick Haessly       
;;;
;;;       Permission to use, copy, modify, and distribute this software       
;;;       for any purpose is hereby granted, provided that no fees are        
;;;       collected directly or indirectly and that the above copyright       
;;;       notice and this permission notice appear in all copies and in       
;;;       all supporting documentation. See IL DISK DISCLAIMER.TXT file.
;;;
;;;* Example error control code in the style of AutoCAD sample files.
;;;*
;;; --------------------------Error Function---------------------------------
 
(defun err (s)                        ;If an error (such as CTRL-C) occurs
                                      ;while this command is active...
  (if (not (member s '("console break" "Function cancelled")))
    (princ (strcat "\nError: " s))
  ) 
  (setq S nil)                        ;Free selection-set if any
  (command "UNDO" "E")                ;End any outstanding UNDO Group
  (setvar "CMDECHO" cmdech)           ;Restore saved mode
  (setq *error* olderr)               ;Restore old *error* handler
  (princ)
) 

;;; ------------------------- Main Program ----------------------------------

(defun C:TEST (/ olderr ) 
  (setq olderr *error*  *error* err)
  (setq cmdech (getvar "CMDECHO"))
  (setvar "CMDECHO" 0)
  (command "UNDO" "G")

  (while (strcase (getreal "Enter a number to cause error."))) ; body of function goes here  

  (setvar "CMDECHO" ocmd)             ;Restore saved mode
  (setq *error* olderr)               ;Restore old *error* handler
  (princ)
) 

;;; --------------------------------------------------------------------------;

(princ)
;;;* End of ERRTEST.LSP
