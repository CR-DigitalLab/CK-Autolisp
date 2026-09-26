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
;;;* ETOS (Expression TO String) takes any expression or SYM entity type and
;;;* converts it to a string. "STRings" are returned as double-quoted
;;;* ""STRings"". The READ function can be used to return the original value
;;;* of any string returned by ETOS.
;;;*
(defun etos (arg / file)
  (if (= 'STR (type arg))                ;If ARG is a string
      (setq arg (strcat "\"" arg "\""))) ;format it with second quotes
  (setq file (open "$" "w"))             ;Open temp file named $
  (princ arg file)                       ;Write string to file
  (close file)
  (setq file (open "$" "r"))             ;Reopen to read
  (setq arg (read-line file))            ;Set ARG to string read from file
  (close file)
  (close (open "$" "w"))                 ;Scrunch file down to 0 bytes
  arg                                    ;Return string read from file
);defun ETOS
;;;*
