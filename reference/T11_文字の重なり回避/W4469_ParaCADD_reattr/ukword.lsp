;;; This function is freeware courtesy of the author's of "Inside AutoLisp" for rel. 10 published by New
;;; Riders Publications.  This credit must accompany all copies of this
;;; function.

;;;October 19, 2004 added function chkkwds (see description at end of file)

;;;* UKWORD User key word. DEF, if any, must match one of the KWD strings
;;;* BIT (1 for no null, 0 for none) and KWD key word ("" for none) are same as
;;;* for INITGET. MSG is the prompt string, to which a default string is added
;;;* as <DEF> (nil or "" for none), and a : is added.
;;;*
(DEFUN ukword (bit kwd msg def / inp)
  (IF chkkwds nil (load "chkkwds" "\nFile CHKKWDS.LSP not loaded! "))
  (chkkwds kwd)
  (IF (AND def (/= def ""))
    (SETQ msg (STRCAT "\n" msg " <" def ">: ")
          bit (* 2 (FIX (/ bit 2)))
    );setq
  );if
  (INITGET bit kwd)
  (SETQ inp (GETKWORD msg))
  (IF inp
    inp
    def
  ) ;_ end of if
);defun
;*
(PRINC)
;*

