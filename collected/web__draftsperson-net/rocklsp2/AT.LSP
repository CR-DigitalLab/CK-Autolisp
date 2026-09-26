  ; AT - attribute value replacer.
  ; Copyright 1991  Rocket Software
  ; Text is superior for most applications, but attributes have that
  ; certain mystique: they're harder to set up and irritating to use
  ; - a must for the serious corporate climber.
 (DEFUN C:AT (/ snp tt fn) 
  (setvar "cmdecho" 0)
  (if (= (type stt) 'STR)
         (setq tt (strcat "New text <" stt ">: "))
         (setq tt "New text: "))
  (setq fn (getstring T tt))
  (if (/= fn "") (setq stt fn))
  (write-line "Select attribute: ")
  (command "attedit" "" "" "" "" pause "" "v" "r" stt "")
 (PRINC))
