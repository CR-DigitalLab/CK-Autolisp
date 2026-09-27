;This function is freeware courtesy of the author's of "Inside AutoLisp" for rel. 10 published by New Riders Publications.  This credit must accompany all copies of this function.

;;;October 19, 2004 added function chkkwds (see description at end of file)

;* UINT User interface function 
;* BIT (0 for none) and KWD key word ("" for none) are same as for INITGET.
;* MSG is the prompt string, to which a default real is added as <DEF> (nil
;* for none), and a : is added.
;*
(defun uint (bit kwd msg def / inp)
;;;  (IF chkkwds nil (load "chkkwds" "\nFile CHKKWDS.LSP not loaded! "))
;;;  (chkkwds kwd)
  (if def 
    (setq msg (strcat "\n" msg " <" (if (eq (type def) 'REAL) (rtos def 2 0)(if (eq (type def) 'INT) (itoa def) def)) ">: ")
          bit (* 2 (fix (/ bit 2)))
    )
    (setq msg (strcat "\n" msg ": "))
  );if
  (initget bit kwd)
  (setq inp (getint msg))
  (if inp inp def)
);defun
;*
(princ)
;*
