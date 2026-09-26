   ;   Erase Second Last
   ;   By SW  (and others - strong evidence
   ;   that there really is a need for this...)
  (DEFUN C:SL ( / aaa lll)
    (setvar "cmdecho" 0) 
    (setq aaa (entlast))
    (entdel aaa)
    (entdel (entlast))
    (entdel aaa)
    (PRINC))