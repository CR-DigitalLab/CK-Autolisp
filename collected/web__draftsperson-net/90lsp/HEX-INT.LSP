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
;;;* The following is a collection of functions for the handling of hexadecimal
;;;* numbers. They are very useful when working with entity handles, which are
;;;* themselves hexadecimal numbers stored as strings.

;;;* HTOI (Hex TO Integer) accepts a hex string and returns it
;;;* as a base 10 integer.
(defun htoi (str / prmpt num int)
  (setq int 0  str (strcase str)                  ;Force str uppercase
        prmpt (strcat "\nInvalid hex value " str) ;Build error prompt
  )
  (while                                          ;Process each
    (/= 0 (setq num (substr str 1 1)              ;Get 1st character
                     str (substr str 2)           ;Remainder
                     num (ascii num)              ;Return ascii value
    )     )
    (if (setq num                                 ;Return base 10 value
          (cond
            ( (< num 48) (prompt prmpt))          ;Not a number
            ( (< num 58) (- num 48))              ;Convert 0-9
            ( (< num 65) (prompt prmpt))          ;Not a number
            ( (< num 71) (- num 55))              ;Convert A-F
            ( T          (prompt prmpt))
        ) )
        (setq int (+ int (* (expt 16 (strlen str)) num)))  ;Accumulate
  ) );while&if
);defun HTOI

;;;* ITOH (Integer TO Hex) accepts a base 10 integer and returns it as a
;;;* hexadecimal string.
(defun itoh (num / str int)
  (setq str "")                                   ;Empty string
  (while (> num 0)                                ;Positive?
    (setq str 
      (strcat
        (if (> (setq int (rem num 16)) 9)         ;Process 1's
          (chr (+ 55 int))                        ;Convert A-F
          (chr (+ 48 int))                        ;Convert 0-9
        )
        str                                       ;Accumulate results
      )
      num (/ num 16)                              ;Powers of 16
    )
  )
  str                                             ;Return result
)

;;;* HX+1 accepts a hexadecimal string, increments it by 1, and returns the
;;;* result as a hexadecimal string.
;;;* Increment a hex string
(defun hx+1 (str / lst)
  (setq lst (hxlist str))                             ;Get list of powers of 16
  (setq lst (append (list (1+ (car lst))) (cdr lst))) ;Pull out 1's, increment,
  (listhx lst)                                      ;Rebuild list and send to
)                                                   ;Get a hex back

;;;* HX+INT accepts a hexadecimal string and an integer as arguments, and returns
;;;* their sum as a hexadecimal string.
(defun hx+int (str int / lst)
  (setq lst (hxlist str))                           ;Get list of powers of 16
  (setq lst (append (list (+ int (car lst))) (cdr lst)))  ;Pull out 1's, add,
  (listhx lst)                                      ;Rebuild list and send to
)                                                   ;Get a hex back

;;;* HX+HX accepts a two hexadecimal strings as arguments, and returns
;;;* their sum as a single hexadecimal string.
(defun hx+hx (str str2 / lst)
  (setq str (strcat "0" str)              ;Add leading 0 for single char
        str2 (strcat "0" str2)            ;Hex strings
  )
  (setq lst (mapcar '+ (hxlist str) (hxlist str2))) ;Breakdown into component
  (listhx lst)                                      ;Powers of 16 and add
)                                                   ;Convert back to hex

;;;* HXLIST accepts a hexadecimal string and returns it as
;;;* a list in the form:(1's 16s 16x16s 16x16x16s ...)
(defun hxlist (str / prmpt num int lst)
  (setq int 0  str (strcase str)                  ;Force str uppercase
        prmpt (strcat "\nInvalid hex value " str) ;Build error prompt
  )
  (while                                          ;Process each character
    (/= 0 (setq num (substr str 1 1)              ;Get 1st
                     str (substr str 2)           ;Remainder
                     num (ascii num)              ;Return ascii value
    )     )
    (if (setq num                                 ;Return base 10 value
          (cond
            ( (< num 48) (prompt prmpt))          ;Not a number
            ( (< num 58) (- num 48))              ;Convert 0-9
            ( (< num 65) (prompt prmpt))          ;Not a number
            ( (< num 71) (- num 55))              ;Convert A-F
            ( T          (prompt prmpt))          ;Anything else
        ) )
        (setq lst (append (list num) lst))        ;Accumulate results
  ) );while&if
  lst                                             ;Return results
);defun HXLIST

;;;* LISTHX accepts a list in the form:(1's 16s 16x16s 16x16x16s ...)
;;;* and returns it as a hexadecimal string. The list may be either stored
;;;* in a variable (listhx var), or quoted (listhx '(integer integer ...)).
(defun listhx (lst / carry remain rest int str)
  ;; Reverse list & correct if needed
  (setq carry 0  rest lst  lst nil)               ;Initialize
  (while (setq int (car rest))                    ;Get 1st member
    (setq rest (cdr rest)                         ;Remainder of list
          int (+ int carry)                       ;Accumulate 1's
          remain (rem int 16)                     ;Remainder
          carry (/ int 16)                        ;Pull out multiples of 16
          lst (append (list remain) lst)          ;Rebuild list
  ) )
  ;; Convert to hex
  (setq str "")
  (while (setq int (car lst))                     ;Process each int at a time
    (setq str 
      (strcat                                     ;Build a string
        str
        (if (> int 9)
          (chr (+ 55 int))                        ;Convert 0-9
          (chr (+ 48 int))                        ;Convert A-F
        )
      )
      lst (cdr lst)                               ;Reset lst to remainder of lst
    )
  )
  str                                             ;Return string result
);defun listhx
