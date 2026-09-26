  ; This routine changes the first occurrence of a string in
  ; an attribute to another string.  Defaults are provided in case
  ; you want to do it again.  Basically it's similar to CHGTEXT.
  ; Copyright 1991  Rocket Software
  ; Isn't it time you painted your computer a different colour?
 (DEFUN C:ACH (/ tt fn) 
  (setvar "cmdecho" 0)
  (if (= (type stt) 'STR)
         (setq tt (strcat "String to change <" stt ">: "))
         (setq tt "String to change: "))
  (setq fn (getstring T tt))
  (if (/= fn "") (setq stt fn))
  (if (= (type nt) 'STR)
         (setq tt (strcat "New string <" nt ">: "))
         (setq tt "New string: "))
  (setq fn (getstring T tt))
  (if (/= fn "") (setq nt fn))
  (write-line "Select attribute: ")
  (command "attedit" "" "" "" "" pause "" "v" "c" stt nt "")
 (PRINC))