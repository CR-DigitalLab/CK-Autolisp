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
;;;* ERROR.LSP
;;;* The *ERROR* function is designed to maintain the system's integrity.
;;;* The main function calls #ERROR, a function containing a list of
;;;* actions. Each action must be a valid LISP expression. The error list
;;;* can be modified throughout the course of a program using ADDERR
;;;* and DELERR. INITERR resets #ERROR to your standard settings.
;;;* RESET resets the environment. It can be called at the end of a
;;;* program for normal resetting.
;;;*

;;;* INITERR sets default #ERROR for resetting environment and/or
;;;* error recovery
(defun initerr ()
  (defun #error ()
    (setvar "BLIPMODE" 1)                 ;Blipmode should be on
    (setvar "MENUECHO" 1)                 ;Menu echo on
  );defun
);defun

;;;* ADDERR adds one item to the #ERROR list. ITEM must be quoted
;;;* expression, or in form: (list 'FUNCTION arg arg arg...) where
;;;* arguments are quoted or not depending on whether you pass the
;;;* current value or use them literally.
(defun adderr (item)
  (if (not (member item #error))                     ;If not a duplicate item
    (setq #error (append '(nil) (list item) (cdr #error)));Add it to the list
  );if
);defun
;;;*

;;;* DELERR deletes one item from the #ERROR list.
;;;* ITEM is same format as ADDERR.
(defun delerr (item)
   (setq #error (subst '() item #error))  ;Replace item with a null list
);defun
;;;*

;;;* #ERR stores the original standard error function, before it
;;;* gets redefined.
(if #err nil (setq #err *error*))

;;;* *ERROR* redefines the standard error function. 
(defun *error* (msg / errno)
  (setvar "CMDECHO" 0)                    ;Command echo off
  ;;Variables declared local to a program can become global when an
  ;;error occurs
  ;;Include (setq args '(v1 v2 v3 . . . args) in programs, where
  ;;v1, v2, v3 etc. are its locals
  ;;This won't stop errors from stepping on globals with same
  ;;names as locals, but will keep from littering the landscape
  ;;with new globals
  (foreach arg args (set arg nil))        ;Clear locals 
  (command)                               ;Cancel any pending command
  (grtext)                                ;Restore status and menu areas

  ;; If user did not cancel program, print message, but
  ;compare messages to suppress
  (if (not (member msg '("console break" "Function cancelled")))
    (progn                                ;Then program bug
      (prompt
        (strcat "Program ERROR: "                     ;Print error message
                (if (> 11 (read (getvar "ACADVER")))  ;If R10 or earlier
                  ""                                  ;Add nothing
                  (progn                              ;Add error number
                    (setq errno (itoa (getvar "ERRNO")))
                    (setvar "ERRNO" 0)  errno
                ) );if&progn
                " " msg
        );strcat
  ) ) );if,progn,prompt
  (reset msg)                    ;Process #ERROR list, restore environment
);defun *ERROR*
;;;*

;;;* RESET function resets the standard environment. You can call
;;;* it at the end of a function to put the settings back in order,
;;;* including any tasks you ADDERR but do not DELERR. If you call
;;;* it from a function for normal termination, supply a nil argument.
(defun reset (msg)
  (command "_.UNDO" "_E")                       ;Close any UNDO Group
  (if msg (prompt "\nResetting environment..."))
  (#error)                                      ;Evaluate error list
  (initerr)                                     ;Reset default #ERROR list
  (setvar "CMDECHO" 1)                          ;Command echo on
  (if msg (prompt " Done."))
  (princ)
);defun RESET
;;;*

;;;* C:*ERROR* restores the standard AutoLISP *ERROR* function for testing,
;;;* using the #ERR variable which stored *ERROR*.
(defun C:*ERROR* () (setq *error* #err))

(princ)
;;;* End of ERROR.LSP
;;;*
